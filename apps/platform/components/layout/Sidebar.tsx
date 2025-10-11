'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
  Home,
  Building,
  Users,
  Settings,
  ChevronDown,
  ChevronRight,
  HelpCircle,
  FileText,
  X,
} from 'lucide-react'

interface SidebarProps {
  isOpen?: boolean
  onClose?: () => void
  isMobile?: boolean
}

export default function Sidebar({ isOpen = true, onClose, isMobile = false }: SidebarProps) {
  const pathname = usePathname()
  const [expandedSection, setExpandedSection] = useState<string | null>('communities')

  // Close sidebar on navigation (mobile only)
  useEffect(() => {
    if (isMobile && onClose) {
      onClose()
    }
  }, [pathname, isMobile, onClose])

  const mainNavItems = [
    {
      name: 'Dashboard',
      icon: Home,
      path: '/dashboard',
    },
    {
      name: 'Communities',
      icon: Building,
      path: '/tenants',
    },
    {
      name: 'Users',
      icon: Users,
      path: '/users',
      submenu: [
        {
          name: 'All Users',
          path: '/users',
        },
        {
          name: 'Roles',
          path: '/users/roles',
        },
      ],
    },
    {
      name: 'Audit Logs',
      icon: FileText,
      path: '/audit-logs',
    },
    {
      name: 'Settings',
      icon: Settings,
      path: '/settings',
    },
  ]

  const toggleSection = (section: string) => {
    if (expandedSection === section) {
      setExpandedSection(null)
    } else {
      setExpandedSection(section)
    }
  }

  const isActive = (path: string) => {
    if (path === '/') {
      return pathname === '/'
    }
    return pathname.startsWith(path)
  }

  // Mobile overlay + slide-in drawer
  if (isMobile) {
    return (
      <>
        {/* Overlay */}
        {isOpen && (
          <div
            className="fixed inset-0 bg-black bg-opacity-50 z-40 md:hidden"
            onClick={onClose}
          />
        )}

        {/* Slide-in sidebar */}
        <div
          className={`fixed inset-y-0 left-0 z-50 bg-white w-64 shadow-xl transform transition-transform duration-300 ease-in-out md:hidden ${
            isOpen ? 'translate-x-0' : '-translate-x-full'
          }`}
        >
          <div className="h-full flex flex-col">
            {/* Header with close button */}
            <div className="p-4 border-b flex items-center justify-between">
              <div>
                <h1 className="text-xl font-bold text-primary">ResidenceHub</h1>
                <p className="text-xs text-gray-600">Platform Admin</p>
              </div>
              <button
                onClick={onClose}
                className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                aria-label="Close menu"
              >
                <X className="h-5 w-5 text-gray-600" />
              </button>
            </div>
            <div className="flex-1 overflow-y-auto py-4">
              <nav className="px-3">
                {mainNavItems.map((item) => (
                  <div key={item.name} className="mb-2">
                    {item.submenu ? (
                      <div>
                        <button
                          onClick={() => toggleSection(item.name.toLowerCase())}
                          className={`w-full flex items-center justify-between py-3 px-4 rounded-lg hover:bg-gray-100 touch-target ${
                            isActive(item.path) ? 'bg-primary-light text-primary' : 'text-gray-700'
                          }`}
                        >
                          <div className="flex items-center">
                            <item.icon
                              className={`h-5 w-5 mr-3 ${
                                isActive(item.path) ? 'text-primary' : 'text-gray-500'
                              }`}
                            />
                            <span className={`${isActive(item.path) ? 'font-medium text-primary' : ''}`}>
                              {item.name}
                            </span>
                          </div>
                          {expandedSection === item.name.toLowerCase() ? (
                            <ChevronDown className="h-4 w-4" />
                          ) : (
                            <ChevronRight className="h-4 w-4" />
                          )}
                        </button>
                        {expandedSection === item.name.toLowerCase() && (
                          <div className="mt-1 ml-4 pl-4 border-l border-gray-200">
                            {item.submenu.map((subItem) => (
                              <Link
                                key={subItem.name}
                                href={subItem.path}
                                className={`flex items-center py-2 px-3 text-sm rounded-lg touch-target ${
                                  pathname === subItem.path
                                    ? 'bg-primary-light text-primary font-medium'
                                    : 'text-gray-600 hover:bg-gray-50'
                                }`}
                              >
                                {subItem.name}
                              </Link>
                            ))}
                          </div>
                        )}
                      </div>
                    ) : (
                      <Link
                        href={item.path}
                        className={`flex items-center py-3 px-4 rounded-lg hover:bg-gray-100 touch-target ${
                          isActive(item.path) ? 'bg-primary-light text-primary' : 'text-gray-700'
                        }`}
                      >
                        <item.icon
                          className={`h-5 w-5 mr-3 ${isActive(item.path) ? 'text-primary' : 'text-gray-500'}`}
                        />
                        <span className={`${isActive(item.path) ? 'font-medium text-primary' : ''}`}>
                          {item.name}
                        </span>
                      </Link>
                    )}
                  </div>
                ))}
              </nav>
            </div>
            <div className="p-4 border-t">
              <Link
                href="/help"
                className="flex items-center py-2 px-4 text-sm text-gray-600 hover:bg-gray-50 rounded-lg touch-target"
              >
                <HelpCircle className="h-5 w-5 mr-3 text-gray-500" />
                Help & Support
              </Link>
            </div>
          </div>
        </div>
      </>
    )
  }

  // Desktop sidebar (original)
  return (
    <div className="hidden md:flex bg-white w-64 h-full shadow-md flex-col overflow-hidden">
      <div className="p-6 border-b">
        <h1 className="text-2xl font-bold text-primary">ResidenceHub</h1>
        <p className="text-sm text-gray-600">Platform Administration</p>
      </div>
      <div className="flex-1 overflow-y-auto py-4">
        <nav className="px-3">
          {mainNavItems.map((item) => (
            <div key={item.name} className="mb-2">
              {item.submenu ? (
                <div>
                  <button
                    onClick={() => toggleSection(item.name.toLowerCase())}
                    className={`w-full flex items-center justify-between py-3 px-4 rounded-lg hover:bg-gray-100 ${
                      isActive(item.path) ? 'bg-primary-light text-primary' : 'text-gray-700'
                    }`}
                  >
                    <div className="flex items-center">
                      <item.icon
                        className={`h-5 w-5 mr-3 ${
                          isActive(item.path) ? 'text-primary' : 'text-gray-500'
                        }`}
                      />
                      <span className={`${isActive(item.path) ? 'font-medium text-primary' : ''}`}>
                        {item.name}
                      </span>
                    </div>
                    {expandedSection === item.name.toLowerCase() ? (
                      <ChevronDown className="h-4 w-4" />
                    ) : (
                      <ChevronRight className="h-4 w-4" />
                    )}
                  </button>
                  {expandedSection === item.name.toLowerCase() && (
                    <div className="mt-1 ml-4 pl-4 border-l border-gray-200">
                      {item.submenu.map((subItem) => (
                        <Link
                          key={subItem.name}
                          href={subItem.path}
                          className={`flex items-center py-2 px-3 text-sm rounded-lg ${
                            pathname === subItem.path
                              ? 'bg-primary-light text-primary font-medium'
                              : 'text-gray-600 hover:bg-gray-50'
                          }`}
                        >
                          {subItem.name}
                        </Link>
                      ))}
                    </div>
                  )}
                </div>
              ) : (
                <Link
                  href={item.path}
                  className={`flex items-center py-3 px-4 rounded-lg hover:bg-gray-100 ${
                    isActive(item.path) ? 'bg-primary-light text-primary' : 'text-gray-700'
                  }`}
                >
                  <item.icon
                    className={`h-5 w-5 mr-3 ${isActive(item.path) ? 'text-primary' : 'text-gray-500'}`}
                  />
                  <span className={`${isActive(item.path) ? 'font-medium text-primary' : ''}`}>
                    {item.name}
                  </span>
                </Link>
              )}
            </div>
          ))}
        </nav>
      </div>
      <div className="p-4 border-t">
        <Link
          href="/help"
          className="flex items-center py-2 px-4 text-sm text-gray-600 hover:bg-gray-50 rounded-lg"
        >
          <HelpCircle className="h-5 w-5 mr-3 text-gray-500" />
          Help & Support
        </Link>
      </div>
    </div>
  )
}
