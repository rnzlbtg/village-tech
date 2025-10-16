'use client'

import { useState } from 'react'
import { Bell, UserCircle, LogOut, Settings, HelpCircle, Menu } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

interface HeaderProps {
  onMenuClick?: () => void
}

export default function Header({ onMenuClick }: HeaderProps) {
  const [userMenuOpen, setUserMenuOpen] = useState(false)
  const router = useRouter()
  const supabase = createClient()

  const handleSignOut = async () => {
    await supabase.auth.signOut()
    router.push('/login')
    router.refresh()
  }

  return (
    <header className="bg-white shadow h-16 flex items-center justify-between px-4 md:px-6 z-10">
      <div className="flex items-center gap-3">
        {/* Mobile hamburger menu */}
        <button
          onClick={onMenuClick}
          className="md:hidden p-2 hover:bg-gray-100 rounded-lg transition-colors touch-target"
          aria-label="Open menu"
        >
          <Menu className="h-6 w-6 text-gray-700" />
        </button>
        <h2 className="text-lg md:text-xl font-semibold text-gray-800 truncate">
          Platform Admin
        </h2>
      </div>
      <div className="flex items-center space-x-2 md:space-x-4">
        <button className="text-gray-500 hover:text-gray-700 relative hidden sm:block touch-target">
          <Bell className="h-6 w-6" />
        </button>
        <div className="relative">
          <button
            onClick={() => setUserMenuOpen(!userMenuOpen)}
            className="flex items-center space-x-2 hover:bg-gray-100 p-2 rounded-lg transition-colors duration-200 touch-target"
          >
            <span className="text-sm font-medium text-gray-700 hidden sm:inline">Super Admin</span>
            <UserCircle className="h-7 w-7 md:h-8 md:w-8 text-primary" />
          </button>
          {userMenuOpen && (
            <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border overflow-hidden z-10">
              <div className="p-3 border-b">
                <p className="text-sm font-medium text-gray-800">Super Admin</p>
                <p className="text-xs text-gray-500">admin@example.com</p>
              </div>
              <div className="py-1">
                <button className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                  <UserCircle className="h-4 w-4 mr-2 text-gray-500" />
                  My Profile
                </button>
                <button className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                  <Settings className="h-4 w-4 mr-2 text-gray-500" />
                  Settings
                </button>
                <button className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                  <HelpCircle className="h-4 w-4 mr-2 text-gray-500" />
                  Help & Support
                </button>
              </div>
              <div className="py-1 border-t">
                <button
                  onClick={handleSignOut}
                  className="flex items-center w-full px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                >
                  <LogOut className="h-4 w-4 mr-2" />
                  Sign Out
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  )
}
