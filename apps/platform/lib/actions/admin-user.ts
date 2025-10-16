'use server'

import { createClient, createAdminClient } from '@/lib/supabase/server'
import { createAdminUserSchema, updateAdminUserSchema } from '@/lib/validations/admin-user'
import { revalidatePath } from 'next/cache'
import { requireSuperAdmin } from '@/lib/auth/helpers'

export async function createAdminUser(formData: FormData) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()
    const adminClient = createAdminClient()

    const data = createAdminUserSchema.parse({
      tenant_id: formData.get('tenant_id'),
      email: formData.get('email'),
      password: formData.get('password'),
      first_name: formData.get('first_name'),
      last_name: formData.get('last_name'),
      phone_number: formData.get('phone_number') || undefined,
      role: formData.get('role'),
    })

    // Check if email already exists
    const { data: existingUser } = await adminClient.auth.admin.listUsers()
    const emailExists = existingUser?.users.some((user) => user.email === data.email)

    if (emailExists) {
      return {
        success: false,
        error: 'Email address is already in use',
      }
    }

    // Create auth user using admin client
    const { data: authUser, error: authError } = await adminClient.auth.admin.createUser({
      email: data.email,
      password: data.password,
      email_confirm: true,
      user_metadata: {
        first_name: data.first_name,
        last_name: data.last_name,
        role: data.role,
        tenant_id: data.tenant_id,
      },
    })

    if (authError || !authUser.user) {
      console.error('Error creating auth user:', authError)
      return {
        success: false,
        error: authError?.message || 'Failed to create auth user',
      }
    }

    // Create user profile
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .insert([
        {
          id: authUser.user.id,
          tenant_id: data.tenant_id,
          email: data.email,
          first_name: data.first_name,
          last_name: data.last_name,
          phone_number: data.phone_number,
          role: data.role,
          is_active: true,
        },
      ])
      .select()
      .single()

    if (profileError) {
      console.error('Error creating user profile:', profileError)
      // Rollback: delete auth user using admin client
      await adminClient.auth.admin.deleteUser(authUser.user.id)
      return {
        success: false,
        error: profileError.message,
      }
    }

    // Create user role assignment
    const { error: roleError } = await supabase.from('user_roles').insert([
      {
        user_id: authUser.user.id,
        tenant_id: data.tenant_id,
        role: data.role,
        is_active: true,
      },
    ])

    if (roleError) {
      console.error('Error creating user role:', roleError)
      // Rollback: delete profile and auth user
      await supabase.from('user_profiles').delete().eq('id', authUser.user.id)
      await adminClient.auth.admin.deleteUser(authUser.user.id)
      return {
        success: false,
        error: roleError.message,
      }
    }

    revalidatePath(`/tenants/${data.tenant_id}/admin-users`)

    return {
      success: true,
      data: profile,
    }
  } catch (error) {
    console.error('Error in createAdminUser:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create admin user',
    }
  }
}

export async function updateAdminUser(formData: FormData) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    const data = updateAdminUserSchema.parse({
      id: formData.get('id'),
      tenant_id: formData.get('tenant_id') || undefined,
      email: formData.get('email') || undefined,
      first_name: formData.get('first_name') || undefined,
      last_name: formData.get('last_name') || undefined,
      phone_number: formData.get('phone_number') || undefined,
      role: formData.get('role') || undefined,
      is_active: formData.get('is_active') === 'true',
    })

    const { id, ...updateData } = data

    // If email is being updated, check uniqueness
    if (data.email) {
      const { data: existingUser } = await supabase.auth.admin.listUsers()
      const emailExists = existingUser?.users.some(
        (user) => user.email === data.email && user.id !== id
      )

      if (emailExists) {
        return {
          success: false,
          error: 'Email address is already in use',
        }
      }

      // Update auth user email
      const { error: authError } = await supabase.auth.admin.updateUserById(id, {
        email: data.email,
      })

      if (authError) {
        console.error('Error updating auth user email:', authError)
        return {
          success: false,
          error: authError.message,
        }
      }
    }

    // Update user metadata if role, first_name, or last_name changed
    if (data.role || data.first_name || data.last_name) {
      const { error: metadataError } = await supabase.auth.admin.updateUserById(id, {
        user_metadata: {
          ...(data.role && { role: data.role }),
          ...(data.first_name && { first_name: data.first_name }),
          ...(data.last_name && { last_name: data.last_name }),
        },
      })

      if (metadataError) {
        console.error('Error updating user metadata:', metadataError)
        return {
          success: false,
          error: metadataError.message,
        }
      }
    }

    // Update user profile
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (profileError) {
      console.error('Error updating user profile:', profileError)
      return {
        success: false,
        error: profileError.message,
      }
    }

    revalidatePath(`/tenants/${profile.tenant_id}/admin-users`)

    return {
      success: true,
      data: profile,
    }
  } catch (error) {
    console.error('Error in updateAdminUser:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update admin user',
    }
  }
}

export async function deleteAdminUser(userId: string) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    // Get user profile for tenant_id
    const { data: profile } = await supabase
      .from('user_profiles')
      .select('tenant_id')
      .eq('id', userId)
      .single()

    // Delete auth user (cascade will delete profile)
    const { error: authError } = await supabase.auth.admin.deleteUser(userId)

    if (authError) {
      console.error('Error deleting auth user:', authError)
      return {
        success: false,
        error: authError.message,
      }
    }

    if (profile) {
      revalidatePath(`/tenants/${profile.tenant_id}/admin-users`)
    }

    return {
      success: true,
    }
  } catch (error) {
    console.error('Error in deleteAdminUser:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to delete admin user',
    }
  }
}

export async function getAdminUsers(tenantId: string) {
  try {
    const supabase = await createClient()

    const { data: users, error } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('tenant_id', tenantId)
      .in('role', ['admin_head', 'admin_officer'])
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching admin users:', error)
      return []
    }

    return users || []
  } catch (error) {
    console.error('Error in getAdminUsers:', error)
    return []
  }
}

export async function getAdminUser(userId: string) {
  try {
    const supabase = await createClient()

    const { data: user, error } = await supabase
      .from('user_profiles')
      .select('*, tenants(id, name)')
      .eq('id', userId)
      .single()

    if (error) {
      console.error('Error fetching admin user:', error)
      return { success: false, error: error.message }
    }

    return { success: true, data: user }
  } catch (error) {
    console.error('Error in getAdminUser:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch admin user',
    }
  }
}
