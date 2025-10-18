# Production Readiness Checklist

## Overview

This document tracks security and operational issues that should be addressed before deploying to production.

**Current Status**: MVP-ready for development/staging, requires security improvements for production.

---

## 🔴 Critical Issues (MUST FIX for Production)

### 1. Auth User Creation Bypasses RLS ⚠️

**Issue**: Household head creation uses service role and manually sets `tenant_id`

**Location**: `apps/admin/lib/actions/household.ts` (lines 99-119, 249-267)

**Risk**:
- Application code sets tenant_id, not database
- If code is compromised or has bug, could create users in wrong tenant
- No database-level enforcement of tenant isolation

**Solution Options**:
1. ✅ **Invitation System** (Recommended)
   - Migration already created: `036_secure_household_head_creation.sql`
   - User signs up via invitation link
   - Database enforces tenant_id from invitation
   - ~2-3 hours implementation

2. ✅ **Supabase Auth Hooks**
   - Use Edge Functions to set tenant_id
   - Managed by Supabase, less code
   - ~1 hour implementation + configuration

**Priority**: 🔴 HIGH - Fix before production

**References**:
- `docs/SECURITY_AUTH_DESIGN.md`
- `supabase/migrations/036_secure_household_head_creation.sql`

---

### 2. Email Service Configuration

**Issue**: Currently logs emails to console, doesn't actually send

**Location**: `apps/admin/lib/email/send.ts`

**Risk**: Household heads won't receive login credentials

**Solution**:
1. Choose email service (SendGrid, Resend, AWS SES)
2. Add API keys to environment variables
3. Implement actual email sending
4. Test delivery in staging

**Priority**: 🔴 HIGH - Required for operations

**Time Estimate**: 1-2 hours

**References**: `apps/admin/lib/email/README.md`

---

### 3. Supabase Storage Bucket Policies Not Applied

**Issue**: Policy SQL files created but not applied to Supabase

**Location**: `supabase/storage/*.sql`

**Risk**: File uploads may not work or have incorrect permissions

**Solution**:
1. Create storage buckets in Supabase Dashboard:
   - `household-documents` (10MB limit)
   - `permit-attachments` (10MB limit)
   - `announcement-files` (10MB limit)
   - `receipt-archives` (5MB limit)
2. Apply RLS policies from SQL files
3. Test file upload/download

**Setup Guide**: See `docs/STORAGE_SETUP_GUIDE.md` for detailed instructions

**Priority**: 🔴 HIGH - Required for file features

**Time Estimate**: 30 minutes

---

## 🟡 Medium Priority Issues

### 4. Residence App: Force Password Change on First Login

**Issue**: Temporary passwords allowed (6 chars, no complexity)

**Location**: Residence app (not yet implemented)

**Risk**: Users might keep weak temporary passwords

**Solution**:
1. Detect first login (check `password_changed_at`)
2. Force password change flow
3. Validate new password meets strict requirements
4. Block app access until password changed

**Priority**: 🟡 MEDIUM - Security UX issue

**Time Estimate**: 2-3 hours

---

### 5. Rate Limiting on File Uploads

**Issue**: No rate limiting implemented

**Location**: `apps/admin/app/api/*/upload/route.ts`

**Risk**: Abuse, DoS attacks

**Solution**:
1. Implement rate limiting middleware
2. Limit: 10 uploads per minute per user
3. Add to all upload endpoints

**Priority**: 🟡 MEDIUM - Anti-abuse

**Time Estimate**: 1-2 hours

---

### 6. CSRF Protection for Server Actions

**Issue**: No CSRF tokens implemented

**Location**: All Server Actions

**Risk**: Cross-site request forgery attacks

**Solution**:
1. Add CSRF token generation/validation
2. Include in all forms
3. Verify on server side

**Priority**: 🟡 MEDIUM - Security hardening

**Time Estimate**: 2-3 hours

**Note**: Next.js 14 App Router provides some built-in CSRF protection, but explicit tokens are better.

---

## 🟢 Low Priority / Polish

### 7. Global Search Functionality (T112)

**Status**: Not implemented

**Priority**: 🟢 LOW - Nice-to-have

**Time Estimate**: 3-4 hours

---

### 8. Export Functionality (T113-T114)

**Status**: Not implemented (CSV/Excel exports)

**Priority**: 🟢 LOW - Operational convenience

**Time Estimate**: 2-3 hours

---

### 9. Audit Log Viewer (T115)

**Status**: Not implemented

**Priority**: 🟢 LOW - Compliance feature

**Time Estimate**: 3-4 hours

---

### 10. Accessibility Improvements (T120)

**Status**: Basic accessibility, needs improvements

**Priority**: 🟢 LOW - Better UX

**Time Estimate**: 4-6 hours

---

## Environment Variables Checklist

### Development
```bash
✅ NEXT_PUBLIC_SUPABASE_URL
✅ NEXT_PUBLIC_SUPABASE_ANON_KEY
✅ SUPABASE_SERVICE_ROLE_KEY
```

### Production (Additional)
```bash
❌ SENDGRID_API_KEY (or chosen email service)
❌ NEXT_PUBLIC_RESIDENCE_APP_URL
❌ SUPPORT_EMAIL
❌ SUPPORT_PHONE
❌ SENTRY_DSN (error tracking)
❌ RATE_LIMIT_REDIS_URL (if using Redis for rate limiting)
```

---

## Database Migration Checklist

- ✅ All migrations run on dev database (034 migrations)
- ❌ Migrations tested on staging
- ❌ Migrations run on production
- ❌ Backup created before production migrations
- ❌ Rollback plan documented

---

## Testing Checklist

### Manual Testing
- ✅ Create household with all fields
- ✅ Create household with minimal fields
- ✅ Duplicate email validation works
- ✅ Duplicate unit number validation works
- ⚠️ Email sent to household head (logs only, not actual)
- ❌ Household head can log in to residence app
- ❌ Forced password change on first login
- ❌ File uploads work (need bucket policies)

### Integration Testing
- ❌ Multi-tenant isolation verified
- ❌ RLS policies tested for all tables
- ❌ Cross-tenant access blocked
- ❌ Service role usage minimized

### Security Testing
- ❌ Penetration testing
- ❌ SQL injection testing
- ❌ XSS testing
- ❌ CSRF testing
- ❌ Rate limiting testing

---

## Performance Checklist

- ❌ Database indexes verified
- ❌ Query performance analyzed
- ❌ Image optimization implemented
- ❌ Bundle size analyzed
- ❌ Loading time measured
- ❌ React Query caching implemented

---

## Monitoring & Observability

### Error Tracking
- ❌ Sentry or similar error tracking configured
- ❌ Error alerts set up
- ❌ Error dashboards created

### Logging
- ✅ Console logging for development
- ❌ Structured logging for production
- ❌ Log aggregation service configured

### Metrics
- ❌ User activity tracking
- ❌ Performance metrics
- ❌ Business metrics dashboard

---

## Backup & Recovery

- ❌ Database backup schedule configured
- ❌ Backup restoration tested
- ❌ Disaster recovery plan documented
- ❌ RTO/RPO defined

---

## Compliance & Legal

- ❌ Privacy policy created
- ❌ Terms of service created
- ❌ GDPR compliance reviewed (if applicable)
- ❌ Data retention policy defined
- ❌ User data deletion process implemented

---

## Documentation

- ✅ Email system documented
- ✅ Security concerns documented
- ✅ Storage policies documented
- ❌ API documentation
- ❌ Admin user manual
- ❌ Deployment guide
- ❌ Incident response playbook

---

## Deployment Checklist

### Pre-Deployment
- [ ] All critical issues resolved
- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] Backup created
- [ ] Rollback plan ready
- [ ] Stakeholders notified

### Deployment
- [ ] Deploy to staging first
- [ ] Run smoke tests on staging
- [ ] Monitor for errors
- [ ] Get stakeholder approval
- [ ] Deploy to production
- [ ] Verify all features working

### Post-Deployment
- [ ] Monitor error rates
- [ ] Monitor performance
- [ ] Check user feedback
- [ ] Document any issues
- [ ] Update runbook

---

## Risk Assessment

| Issue | Impact | Likelihood | Risk Level | Mitigation |
|-------|--------|------------|------------|------------|
| Auth bypasses RLS | High | Medium | 🔴 HIGH | Implement invitation system |
| No email service | High | High | 🔴 HIGH | Configure email provider |
| Missing storage policies | Medium | High | 🟡 MEDIUM | Apply policies in Supabase |
| Weak temporary passwords | Low | Medium | 🟢 LOW | Force change on first login |
| No rate limiting | Medium | Low | 🟡 MEDIUM | Add rate limiting |
| No CSRF protection | Medium | Low | 🟡 MEDIUM | Add CSRF tokens |

---

## Production Go/No-Go Decision

### ✅ GO (Requirements Met)
- All 🔴 Critical issues resolved
- Database migrations tested
- Email service configured
- Storage buckets configured
- Basic security testing passed
- Monitoring configured

### ❌ NO-GO (Requirements NOT Met - Current Status)
- 🔴 Auth still bypasses RLS
- 🔴 Email service not configured
- 🔴 Storage bucket policies not applied
- Missing forced password change
- No rate limiting
- No comprehensive testing

**Current Recommendation**: ❌ **NOT READY for production** - Critical issues must be addressed first.

**Suggested Timeline**:
1. Week 1: Fix critical issues (8-10 hours work)
2. Week 2: Configure services, apply policies (4-6 hours)
3. Week 3: Testing on staging (8-10 hours)
4. Week 4: Production deployment with monitoring

---

## Next Steps

1. **Immediate (This Sprint)**:
   - [ ] Choose invitation system OR Auth Hooks approach
   - [ ] Implement chosen auth security improvement
   - [ ] Configure email service (SendGrid/Resend)
   - [ ] Apply storage bucket policies

2. **Next Sprint**:
   - [ ] Implement forced password change in residence app
   - [ ] Add rate limiting
   - [ ] Comprehensive testing on staging
   - [ ] Set up monitoring

3. **Future**:
   - [ ] CSRF protection
   - [ ] Audit log viewer
   - [ ] Export functionality
   - [ ] Accessibility improvements

---

## Contact

For questions about production readiness:
- Security: `docs/SECURITY_AUTH_DESIGN.md`
- Email: `apps/admin/lib/email/README.md`
- Storage: `docs/STORAGE_SETUP_GUIDE.md`
- Migrations: `supabase/migrations/036_secure_household_head_creation.sql`
