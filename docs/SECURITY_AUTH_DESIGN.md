# Security Issue: Auth User Creation Pattern

## The Problem

**Current Implementation (INSECURE):**
```typescript
// apps/admin/lib/actions/household.ts
const adminClient = await createAdminClient() // Uses service role
const { data: authUser } = await adminClient.auth.admin.createUser({
  email, password,
  app_metadata: {
    tenant_id: tenantId,  // ⚠️ Application-level trust
    role: 'household_head'
  }
})
```

### Why This Is Problematic

1. **Application-Level Security Only**
   - Relies on JavaScript code to set `tenant_id` correctly
   - No database-level enforcement
   - Vulnerable to code bugs or manipulation

2. **Service Role Bypasses RLS**
   - Admin client can create users for ANY tenant
   - If code is compromised, could create users in wrong tenants
   - Privilege escalation risk

3. **No Audit Trail**
   - Direct auth.users creation doesn't log who created the user
   - Hard to track unauthorized user creation

4. **Trust Model Issue**
   - We're trusting the admin app code to always pass correct tenant_id
   - Better: Let the database enforce tenant_id based on who's logged in

---

## Better Solutions

### Option 1: Invitation System (RECOMMENDED) ✅

**How it works:**
1. Admin creates an "invitation" record (RLS-protected)
2. Database automatically sets tenant_id from admin's JWT
3. Invitation email sent with signup link
4. User signs up via public signup (no service role)
5. Database trigger sets tenant_id from invitation

**Benefits:**
- ✅ No service role needed
- ✅ Database enforces tenant_id
- ✅ Full audit trail
- ✅ User can set their own password securely
- ✅ Can expire/revoke invitations

**Implementation:**

```typescript
// 1. Admin creates invitation (RLS enforces tenant_id)
export async function createHouseholdHeadInvitation(formData: FormData) {
  const supabase = await createClient() // Regular client, RLS applies
  const tenantId = await getTenantId()   // From JWT

  const { data, error } = await supabase
    .from('household_head_invitations')
    .insert({
      email: formData.get('email'),
      first_name: formData.get('first_name'),
      // tenant_id set automatically by RLS/trigger
      residence_unit_id: formData.get('residence_unit_id'),
    })
    .select()
    .single()

  if (error) return { success: false, error }

  // Send invitation email with signup link
  await sendInvitationEmail({
    to: data.email,
    token: data.invitation_token,
    signupUrl: `${APP_URL}/signup?token=${data.invitation_token}`
  })

  return { success: true, data }
}

// 2. User signs up via public endpoint
export async function acceptInvitation(token: string, password: string) {
  const supabase = createClient() // Public client

  // Verify invitation
  const { data: invitation } = await supabase
    .from('household_head_invitations')
    .select('*')
    .eq('invitation_token', token)
    .eq('status', 'pending')
    .gt('expires_at', new Date().toISOString())
    .single()

  if (!invitation) {
    return { success: false, error: 'Invalid or expired invitation' }
  }

  // Sign up (database trigger sets tenant_id from invitation)
  const { data: authData, error } = await supabase.auth.signUp({
    email: invitation.email,
    password,
    options: {
      data: {
        first_name: invitation.first_name,
        last_name: invitation.last_name,
      }
    }
  })

  if (error) return { success: false, error }

  // Database trigger automatically:
  // 1. Sets tenant_id from invitation
  // 2. Marks invitation as accepted
  // 3. Creates household record

  return { success: true, data: authData }
}
```

**Database Trigger (Runs on auth.users INSERT):**
```sql
CREATE OR REPLACE FUNCTION set_tenant_from_invitation()
RETURNS TRIGGER AS $$
DECLARE
  v_invitation household_head_invitations%ROWTYPE;
BEGIN
  SELECT * INTO v_invitation
  FROM household_head_invitations
  WHERE email = NEW.email
    AND status = 'pending'
    AND expires_at > NOW()
  LIMIT 1;

  IF FOUND THEN
    -- Set tenant_id from invitation (not from app code!)
    NEW.raw_app_meta_data := jsonb_build_object(
      'tenant_id', v_invitation.tenant_id::text,
      'role', 'household_head',
      'household_id', v_invitation.household_id::text
    );

    UPDATE household_head_invitations
    SET status = 'accepted'
    WHERE id = v_invitation.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### Option 2: Supabase Auth Hooks (Modern) ✅

Supabase recently added **Auth Hooks** - serverless functions that run on auth events.

**Setup:**
1. Create a Supabase Edge Function
2. Configure as a "Custom Access Token" hook
3. Hook adds tenant_id to JWT based on invitation

**Implementation:**

```typescript
// supabase/functions/custom-access-token/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from '@supabase/supabase-js'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { user } = await req.json()

  // Look up invitation for this user
  const { data: invitation } = await supabase
    .from('household_head_invitations')
    .select('tenant_id, household_id')
    .eq('email', user.email)
    .eq('status', 'accepted')
    .single()

  if (invitation) {
    // Add claims to JWT
    return new Response(
      JSON.stringify({
        claims: {
          tenant_id: invitation.tenant_id,
          app_role: 'household_head',
          household_id: invitation.household_id
        }
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  }

  return new Response(JSON.stringify({ claims: {} }))
})
```

**Benefits:**
- ✅ Serverless, automatic execution
- ✅ Managed by Supabase
- ✅ No custom triggers on auth.users
- ✅ Easy to test and deploy

---

### Option 3: Self-Service Signup + Admin Approval

**Flow:**
1. User signs up themselves (public signup)
2. Admin reviews and approves
3. Admin assigns to household
4. Approval triggers update to add tenant_id

**Less ideal because:**
- ❌ User has no tenant_id until approved
- ❌ Can't use app until admin approves
- ❌ More complex state management

---

## Migration Plan

### Phase 1: Add Invitation System (Non-Breaking)
1. ✅ Create `household_head_invitations` table (migration 036)
2. ✅ Add RLS policies
3. Create new invitation-based flow
4. Test thoroughly

### Phase 2: Deprecate Service Role Method
1. Update admin UI to use invitation flow
2. Add warning to old method
3. Monitor usage

### Phase 3: Remove Service Role Method
1. Remove `createAdminClient()` usage from household.ts
2. Delete old code paths
3. Update documentation

---

## Comparison Table

| Approach | Security | Complexity | User Experience | Audit Trail |
|----------|----------|------------|-----------------|-------------|
| **Current (Service Role)** | ⚠️ Low | Simple | Direct | ❌ Poor |
| **Invitation System** | ✅ High | Medium | Good (email flow) | ✅ Excellent |
| **Auth Hooks** | ✅ High | Low (managed) | Good | ✅ Good |
| **Self-Service** | ⚠️ Medium | High | ❌ Poor (wait for approval) | ✅ Good |

---

## Recommendation

**Use Invitation System (Option 1)** because:
1. ✅ **Most Secure**: Database enforces tenant_id
2. ✅ **Best Audit Trail**: Full record of who invited whom
3. ✅ **Industry Standard**: How most SaaS apps work
4. ✅ **Better UX**: User sets own password, gets welcome email
5. ✅ **No Service Role**: Reduces attack surface
6. ✅ **Revocable**: Can cancel invitations before acceptance

**Implementation already created:**
- Migration: `supabase/migrations/036_secure_household_head_creation.sql`
- Need to implement: Invitation-based signup flow in admin app

---

## Current Status

**As of now:**
- ⚠️ Admin app uses service role for user creation (insecure pattern)
- ✅ Migration 036 provides invitation table structure
- ❌ Invitation flow not yet implemented in application code
- ❌ Database trigger on auth.users not yet created (requires Supabase Dashboard or Auth Hooks)

**Action Items:**
1. Create invitation-based signup flow
2. Set up Auth Hook OR database trigger
3. Migrate existing household creation to use invitations
4. Remove service role usage from household.ts
5. Update documentation

---

## References

- [Supabase Auth Hooks](https://supabase.com/docs/guides/auth/auth-hooks)
- [Multi-Tenancy with RLS](https://supabase.com/docs/guides/auth/row-level-security)
- [Invitation Pattern Best Practices](https://www.ietf.org/rfc/rfc2812.txt)
