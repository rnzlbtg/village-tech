import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  let user = null
  try {
    const {
      data: { user: authUser },
    } = await supabase.auth.getUser()
    user = authUser
  } catch (error) {
    // If there's an error getting user, treat as not authenticated
    console.error('Auth error in middleware:', error)
  }

  // Check if user is on login page
  if (request.nextUrl.pathname.startsWith('/login')) {
    if (user) {
      // User is authenticated, redirect to dashboard
      return NextResponse.redirect(new URL('/', request.url))
    }
    return supabaseResponse
  }

  // Check if user is authenticated
  if (!user) {
    // User is not authenticated, redirect to login
    const redirectUrl = new URL('/login', request.url)
    redirectUrl.searchParams.set('redirect', request.nextUrl.pathname)
    return NextResponse.redirect(redirectUrl)
  }

  // Check if user has admin role
  const role = user.app_metadata?.role || user.user_metadata?.role

  if (!role || !['admin_head', 'admin_officer'].includes(role)) {
    // User doesn't have admin role
    return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
  }

  return supabaseResponse
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
