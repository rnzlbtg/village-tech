'use client'

import React from 'react'
import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { toast } from 'sonner'
import {
  Home,
  Users,
  Car,
  Building2,
  FileText,
  Megaphone,
  DollarSign,
  BookOpen,
  X,
  LogOut,
  HelpCircle,
} from 'lucide-react'

interface SidebarProps {
  tenantName?: string
  userName?: string
  sidebarOpen?: boolean
  setSidebarOpen?: (open: boolean) => void
}

const Sidebar: React.FC<SidebarProps> = ({ tenantName, userName, sidebarOpen, setSidebarOpen }) => {
  const pathname = usePathname()
  const router = useRouter()

  const navigation = [
    { name: 'Dashboard', href: '/dashboard', icon: Home },
    { name: 'Properties', href: '/properties', icon: Building2 },
    { name: 'Households', href: '/households', icon: Users },
    { name: 'Vehicle Stickers', href: '/stickers', icon: Car },
    { name: 'Construction Permits', href: '/permits', icon: FileText },
    { name: 'Announcements', href: '/announcements', icon: Megaphone },
    { name: 'Fees & Payments', href: '/fees', icon: DollarSign },
    { name: 'Village Rules', href: '/rules', icon: BookOpen },
  ]

  const handleLogout = async () => {
    const supabase = createClient()
    await supabase.auth.signOut()
    toast.success('Logged out successfully')
    router.push('/login')
    router.refresh()
  }

  const isActive = (href: string) => {
    return pathname === href || (pathname?.startsWith(href + '/') ?? false)
  }

  return (
    <aside
      className={`fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-md flex flex-col transform transition-transform duration-300 lg:translate-x-0 lg:static ${
        sidebarOpen ? 'translate-x-0' : '-translate-x-full'
      }`}
    >
      <div className="flex flex-col h-full overflow-hidden">
        {/* Logo */}
        <div className="p-6 border-b">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-primary">Village Tech</h1>
              <p className="text-sm text-gray-600">Community Admin</p>
            </div>
            <button
              onClick={() => setSidebarOpen?.(false)}
              className="lg:hidden p-2 rounded-lg hover:bg-gray-100"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>

        {/* Tenant info */}
        {tenantName && (
          <div className="px-6 py-4 bg-primary-light border-b">
            <p className="text-sm font-medium text-gray-900">{tenantName}</p>
            {userName && <p className="text-xs text-gray-600 mt-1">{userName}</p>}
          </div>
        )}

        {/* Navigation */}
        <nav className="flex-1 px-3 py-4 overflow-y-auto">
          {navigation.map((item) => {
            const Icon = item.icon
            const active = isActive(item.href)
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors mb-2 ${
                  active
                    ? 'bg-primary-light text-primary font-medium'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
                onClick={() => setSidebarOpen?.(false)}
              >
                <Icon className={`h-5 w-5 ${active ? 'text-primary' : 'text-gray-500'}`} />
                <span>{item.name}</span>
              </Link>
            )
          })}
        </nav>

        {/* Help & Logout */}
        <div className="p-4 border-t">
          <Link
            href="/help"
            className="flex items-center gap-3 px-4 py-2 text-sm text-gray-600 hover:bg-gray-50 rounded-lg mb-2"
          >
            <HelpCircle className="h-5 w-5 text-gray-500" />
            Help & Support
          </Link>
          <button
            onClick={handleLogout}
            className="flex items-center gap-3 w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg transition-colors"
          >
            <LogOut className="h-5 w-5" />
            Logout
          </button>
        </div>
      </div>
    </aside>
  )
}

export default Sidebar
