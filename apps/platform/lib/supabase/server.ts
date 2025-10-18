import { createServerClient } from '@supabase/ssr'
import { createClient as createSupabaseClient } from '@supabase/supabase-js'
import { cookies } from 'next/headers'

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing
            // user sessions.
          }
        },
      },
    }
  )
}

/**
 * Create a Supabase admin client with service role key
 * This client bypasses RLS and should only be used in server-side code
 * for administrative operations like creating users
 */
export function createAdminClient() {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!serviceRoleKey) {
    throw new Error('SUPABASE_SERVICE_ROLE_KEY is not set')
  }

  // Debug: Log the key format
  console.log('=== JWT Debug Info ===')
  console.log('Service Role Key length:', serviceRoleKey.length)
  console.log('Service Role Key prefix:', serviceRoleKey.substring(0, 30))
  console.log('Service Role Key suffix:', serviceRoleKey.substring(serviceRoleKey.length - 20))
  console.log('Service Role Key segments:', serviceRoleKey.split('.').length)
  console.log('Full key:', serviceRoleKey)
  console.log('Key type:', typeof serviceRoleKey)
  console.log('Has newlines:', serviceRoleKey.includes('\n'))
  console.log('Has quotes:', serviceRoleKey.includes('"'))
  console.log('=====================')

  return createSupabaseClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    serviceRoleKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  )
}
