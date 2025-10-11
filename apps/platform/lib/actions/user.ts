'use server'

import { createClient } from '@/lib/supabase/server'
import { createUserSchema, updateUserSchema } from '@/lib/validations/user'
import { revalidatePath } from 'next/cache'
import { requireSuperAdmin } from '@/lib/auth/helpers'

export async function createUser(formData: FormData) {
  try {
    // Check authorization
    await requireSuperAdmin()

    // Parse and validate form data
    const rawData = {
      email: formData.get('email') as string,
      full_name: formData.get('full_name') as string,
      phone: formData.get('phone') as string || null,
      role: formData.get('role') as string,
      tenant_id: formData.get('tenant_id') as string || null,
      password: formData.get('password') as string,
      confirm_password: formData.get('confirm_password') as string,
    }

    const validatedData = createUserSchema.parse(rawData)

    // Create Supabase admin client (service role)
    const supabase = await createClient()

    // Check if email already exists
    const { data: existingUser } = await supabase
      .from('user_profiles')
      .select('email')
      .eq('email', validatedData.email)
      .single()

    if (existingUser) {
      return {
        success: false,
        error: 'A user with this email already exists',
      }
    }

    // Create auth user (this needs service role key)
    const { data: authUser, error: authError } = await supabase.auth.admin.createUser({
      email: validatedData.email,
      password: validatedData.password,
      email_confirm: true, // Auto-confirm email
      user_metadata: {
        full_name: validatedData.full_name,
      },
      app_metadata: {
        role: validatedData.role,
        tenant_id: validatedData.tenant_id,
      },
    })

    if (authError) {
      console.error('Auth user creation error:', authError)
      return {
        success: false,
        error: `Failed to create user account: ${authError.message}`,
      }
    }

    if (!authUser.user) {
      return {
        success: false,
        error: 'Failed to create user account',
      }
    }

    // Create user profile
    const { error: profileError } = await supabase.from('user_profiles').insert({
      id: authUser.user.id,
      email: validatedData.email,
      full_name: validatedData.full_name,
      phone: validatedData.phone,
      role: validatedData.role,
      tenant_id: validatedData.tenant_id,
      is_active: true,
    })

    if (profileError) {
      console.error('User profile creation error:', profileError)

      // Rollback: delete auth user if profile creation fails
      await supabase.auth.admin.deleteUser(authUser.user.id)

      return {
        success: false,
        error: `Failed to create user profile: ${profileError.message}`,
      }
    }

    // Create user role
    const { error: roleError } = await supabase.from('user_roles').insert({
      user_id: authUser.user.id,
      role: validatedData.role,
      tenant_id: validatedData.tenant_id,
    })

    if (roleError) {
      console.error('User role creation error:', roleError)

      // Rollback: delete profile and auth user
      await supabase.from('user_profiles').delete().eq('id', authUser.user.id)
      await supabase.auth.admin.deleteUser(authUser.user.id)

      return {
        success: false,
        error: `Failed to assign user role: ${roleError.message}`,
      }
    }

    // Revalidate the users page
    revalidatePath('/users')

    return {
      success: true,
      data: {
        id: authUser.user.id,
        email: validatedData.email,
        full_name: validatedData.full_name,
        role: validatedData.role,
      },
      message: 'User created successfully',
    }
  } catch (error) {
    console.error('Create user error:', error)

    if (error instanceof Error) {
      // Zod validation errors
      if (error.name === 'ZodError') {
        return {
          success: false,
          error: 'Validation failed. Please check your input.',
        }
      }

      return {
        success: false,
        error: error.message,
      }
    }

    return {
      success: false,
      error: 'An unexpected error occurred while creating the user',
    }
  }
}

export async function updateUser(formData: FormData) {
  try {
    // Check authorization
    await requireSuperAdmin()

    const rawData = {
      id: formData.get('id') as string,
      full_name: formData.get('full_name') as string,
      phone: formData.get('phone') as string || null,
      role: formData.get('role') as string,
      tenant_id: formData.get('tenant_id') as string || null,
      is_active: formData.get('is_active') === 'true',
    }

    const validatedData = updateUserSchema.parse(rawData)

    const supabase = await createClient()

    // Update user profile
    const { error: profileError } = await supabase
      .from('user_profiles')
      .update({
        full_name: validatedData.full_name,
        phone: validatedData.phone,
        role: validatedData.role,
        tenant_id: validatedData.tenant_id,
        is_active: validatedData.is_active,
      })
      .eq('id', validatedData.id)

    if (profileError) {
      return {
        success: false,
        error: `Failed to update user: ${profileError.message}`,
      }
    }

    // Update user role
    if (validatedData.role) {
      const { error: roleError } = await supabase
        .from('user_roles')
        .update({
          role: validatedData.role,
          tenant_id: validatedData.tenant_id,
        })
        .eq('user_id', validatedData.id)

      if (roleError) {
        console.error('User role update error:', roleError)
      }
    }

    // Update auth user metadata
    await supabase.auth.admin.updateUserById(validatedData.id, {
      app_metadata: {
        role: validatedData.role,
        tenant_id: validatedData.tenant_id,
      },
    })

    revalidatePath('/users')
    revalidatePath(`/users/${validatedData.id}`)

    return {
      success: true,
      message: 'User updated successfully',
    }
  } catch (error) {
    console.error('Update user error:', error)

    if (error instanceof Error) {
      return {
        success: false,
        error: error.message,
      }
    }

    return {
      success: false,
      error: 'An unexpected error occurred while updating the user',
    }
  }
}

export async function deleteUser(userId: string) {
  try {
    // Check authorization
    await requireSuperAdmin()

    const supabase = await createClient()

    // Delete from user_roles
    await supabase.from('user_roles').delete().eq('user_id', userId)

    // Delete from user_profiles
    await supabase.from('user_profiles').delete().eq('id', userId)

    // Delete auth user
    const { error: authError } = await supabase.auth.admin.deleteUser(userId)

    if (authError) {
      return {
        success: false,
        error: `Failed to delete user: ${authError.message}`,
      }
    }

    revalidatePath('/users')

    return {
      success: true,
      message: 'User deleted successfully',
    }
  } catch (error) {
    console.error('Delete user error:', error)

    return {
      success: false,
      error: 'An unexpected error occurred while deleting the user',
    }
  }
}

export async function toggleUserStatus(userId: string, isActive: boolean) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    const { error } = await supabase
      .from('user_profiles')
      .update({ is_active: isActive })
      .eq('id', userId)

    if (error) {
      return {
        success: false,
        error: `Failed to update user status: ${error.message}`,
      }
    }

    revalidatePath('/users')

    return {
      success: true,
      message: `User ${isActive ? 'activated' : 'deactivated'} successfully`,
    }
  } catch (error) {
    console.error('Toggle user status error:', error)

    return {
      success: false,
      error: 'An unexpected error occurred',
    }
  }
}
