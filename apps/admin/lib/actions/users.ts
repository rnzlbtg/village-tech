'use server'

/**
 * User Management Server Actions
 *
 * SECURITY NOTE: This file contains auth user creation that bypasses RLS.
 * - Uses createAdminClient() with service role to create auth users
 * - tenant_id is set by application code, not enforced by database
 * - Acceptable for MVP/development but should be improved for production
 */

import { createClient, createAdminClient } from '@/lib/supabase/server'
import { requireAdmin, getTenantId } from '@/lib/auth/helpers'
import { revalidatePath } from 'next/cache'
import {
  createUserSchema,
  updateUserSchema,
  resetPasswordSchema,
  CreateUserInput,
  UpdateUserInput,
  ResetPasswordInput,
} from '@/lib/validations/users'

export async function getUsers() {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const supabase = await createClient()

    // Get users with their profiles, limited to current tenant
    const { data: users, error } = await supabase
      .from('user_profiles')
      .select(`
        id,
        email,
        first_name,
        last_name,
        phone_number,
        role,
        is_active,
        created_at,
        updated_at
      `)
      .eq('tenant_id', tenantId)
      .in('role', ['admin_head', 'admin_officer', 'security_head', 'security_officer'])
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching users:', error)
      return { success: false, error: error.message }
    }

    return { success: true, data: users || [] }
  } catch (error) {
    console.error('Error in getUsers:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch users',
    }
  }
}

export async function createUser(formData: FormData) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const data = createUserSchema.parse({
      email: formData.get('email'),
      first_name: formData.get('first_name'),
      last_name: formData.get('last_name'),
      role: formData.get('role'),
      phone_number: formData.get('phone_number') || '',
      password: formData.get('password'),
      is_active: formData.get('is_active') === 'true',
    })

    const supabase = await createClient()
    const adminClient = await createAdminClient()

    // Check duplicate email in auth system
    const { data: existingUsers } = await adminClient.auth.admin.listUsers()
    const emailExists = existingUsers?.users.some((u) =>
      u.email?.toLowerCase() === data.email.toLowerCase()
    )

    if (emailExists) {
      return {
        success: false,
        error: 'This email address is already registered. Please use a different email.',
      }
    }

    // Create auth user
    // TODO: SECURITY CONCERN - This uses service role and bypasses RLS
    // The tenant_id is set by application code, not enforced by database
    // For production, implement invitation-based flow or use Auth Hooks
    const { data: authUser, error: authError } = await adminClient.auth.admin.createUser({
      email: data.email,
      password: data.password,
      email_confirm: true,
      user_metadata: {
        first_name: data.first_name,
        last_name: data.last_name,
        phone_number: data.phone_number,
        role: data.role,
      },
      app_metadata: {
        role: data.role,
        tenant_id: tenantId, // ⚠️ Manually set - no database enforcement
      },
    })

    if (authError || !authUser.user) {
      console.error('Error creating auth user:', authError)
      return { success: false, error: authError?.message || 'Failed to create user account' }
    }

    // Create user profile
    const { error: profileError } = await supabase
      .from('user_profiles')
      .insert({
        id: authUser.user.id,
        tenant_id: tenantId,
        email: data.email,
        first_name: data.first_name,
        last_name: data.last_name,
        phone_number: data.phone_number,
        role: data.role,
        is_active: data.is_active,
      })

    if (profileError) {
      // Rollback: delete auth user
      await adminClient.auth.admin.deleteUser(authUser.user.id)
      console.error('Error creating user profile:', profileError)
      return { success: false, error: profileError.message }
    }

    revalidatePath('/users')
    return {
      success: true,
      data: {
        id: authUser.user.id,
        email: data.email,
        first_name: data.first_name,
        last_name: data.last_name,
        role: data.role,
        is_active: data.is_active,
      },
      message: 'User created successfully'
    }
  } catch (error) {
    console.error('Error in createUser:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create user',
    }
  }
}

export async function updateUser(userId: string, formData: FormData) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const data = updateUserSchema.parse({
      first_name: formData.get('first_name') || undefined,
      last_name: formData.get('last_name') || undefined,
      role: formData.get('role') || undefined,
      phone_number: formData.get('phone_number') || '',
      is_active: formData.get('is_active') === 'true',
    })

    const supabase = await createClient()
    const adminClient = await createAdminClient()

    // Verify user belongs to current tenant
    const { data: existingUser } = await supabase
      .from('user_profiles')
      .select('id')
      .eq('id', userId)
      .eq('tenant_id', tenantId)
      .single()

    if (!existingUser) {
      return { success: false, error: 'User not found' }
    }

    // Update user profile
    const { data: updatedUser, error: profileError } = await supabase
      .from('user_profiles')
      .update(data)
      .eq('id', userId)
      .eq('tenant_id', tenantId)
      .select()
      .single()

    if (profileError) {
      console.error('Error updating user profile:', profileError)
      return { success: false, error: profileError.message }
    }

    // Update auth user metadata if name or role changed
    if (data.first_name || data.last_name || data.role) {
      const { error: authError } = await adminClient.auth.admin.updateUserById(
        userId,
        {
          user_metadata: {
            first_name: data.first_name,
            last_name: data.last_name,
            phone_number: data.phone_number,
            role: data.role,
          },
          app_metadata: {
            role: data.role,
            tenant_id: tenantId,
          },
        }
      )

      if (authError) {
        console.error('Error updating auth user:', authError)
        // Don't fail the operation if auth update fails, but log it
      }
    }

    revalidatePath('/users')
    revalidatePath(`/users/${userId}`)
    return { success: true, data: updatedUser }
  } catch (error) {
    console.error('Error in updateUser:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update user',
    }
  }
}

export async function deleteUser(userId: string) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const supabase = await createClient()
    const adminClient = await createAdminClient()

    // Verify user belongs to current tenant
    const { data: existingUser } = await supabase
      .from('user_profiles')
      .select('id, role')
      .eq('id', userId)
      .eq('tenant_id', tenantId)
      .single()

    if (!existingUser) {
      return { success: false, error: 'User not found' }
    }

    // Prevent deletion of admin_head if it's the current user
    const currentUser = await supabase.auth.getUser()
    if (currentUser.data.user?.id === userId && existingUser.role === 'admin_head') {
      return {
        success: false,
        error: 'Cannot delete your own admin_head account'
      }
    }

    // Delete user profile
    const { error: profileError } = await supabase
      .from('user_profiles')
      .delete()
      .eq('id', userId)
      .eq('tenant_id', tenantId)

    if (profileError) {
      console.error('Error deleting user profile:', profileError)
      return { success: false, error: profileError.message }
    }

    // Delete auth user
    const { error: authError } = await adminClient.auth.admin.deleteUser(userId)

    if (authError) {
      console.error('Error deleting auth user:', authError)
      return { success: false, error: authError.message }
    }

    revalidatePath('/users')
    return { success: true, message: 'User deleted successfully' }
  } catch (error) {
    console.error('Error in deleteUser:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to delete user',
    }
  }
}

export async function resetUserPassword(userId: string, formData: FormData) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const data = resetPasswordSchema.parse({
      new_password: formData.get('new_password'),
      confirm_password: formData.get('confirm_password'),
    })

    const supabase = await createClient()
    const adminClient = await createAdminClient()

    // Verify user belongs to current tenant
    const { data: existingUser } = await supabase
      .from('user_profiles')
      .select('id')
      .eq('id', userId)
      .eq('tenant_id', tenantId)
      .single()

    if (!existingUser) {
      return { success: false, error: 'User not found' }
    }

    // Update user password
    const { error: authError } = await adminClient.auth.admin.updateUserById(
      userId,
      {
        password: data.new_password,
      }
    )

    if (authError) {
      console.error('Error resetting user password:', authError)
      return { success: false, error: authError.message }
    }

    return { success: true, message: 'Password reset successfully' }
  } catch (error) {
    console.error('Error in resetUserPassword:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to reset password',
    }
  }
}

export async function toggleUserStatus(userId: string) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const supabase = await createClient()

    // Get current user status
    const { data: currentUser, error: fetchError } = await supabase
      .from('user_profiles')
      .select('is_active, role')
      .eq('id', userId)
      .eq('tenant_id', tenantId)
      .single()

    if (fetchError || !currentUser) {
      return { success: false, error: 'User not found' }
    }

    // Prevent deactivation of admin_head if it's the current user
    const currentAuthUser = await supabase.auth.getUser()
    if (currentAuthUser.data.user?.id === userId && currentUser.role === 'admin_head') {
      return {
        success: false,
        error: 'Cannot deactivate your own admin_head account'
      }
    }

    // Toggle status
    const newStatus = !currentUser.is_active
    const { data: updatedUser, error: updateError } = await supabase
      .from('user_profiles')
      .update({ is_active: newStatus })
      .eq('id', userId)
      .eq('tenant_id', tenantId)
      .select()
      .single()

    if (updateError) {
      console.error('Error toggling user status:', updateError)
      return { success: false, error: updateError.message }
    }

    revalidatePath('/users')
    return {
      success: true,
      data: updatedUser,
      message: `User ${newStatus ? 'activated' : 'deactivated'} successfully`
    }
  } catch (error) {
    console.error('Error in toggleUserStatus:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to toggle user status',
    }
  }
}