import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import Link from 'next/link'
import {
  Users,
  Car,
  FileText,
  Megaphone,
  DollarSign,
  Home,
  TrendingUp,
  AlertCircle,
  CheckCircle,
  Clock,
} from 'lucide-react'

export const metadata = {
  title: 'Dashboard | Community Admin',
  description: 'Community administration dashboard overview',
}

export default async function DashboardPage() {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  // Fetch dashboard statistics
  const [
    { count: householdsCount },
    { count: stickersCount },
    { count: permitsCount },
    { count: announcementsCount },
  ] = await Promise.all([
    supabase.from('households').select('*', { count: 'exact', head: true }).eq('tenant_id', tenantId),
    supabase.from('sticker_requests').select('*', { count: 'exact', head: true }).eq('tenant_id', tenantId),
    supabase.from('construction_permits').select('*', { count: 'exact', head: true }).eq('tenant_id', tenantId),
    supabase.from('announcements').select('*', { count: 'exact', head: true }).eq('tenant_id', tenantId),
  ])

  // Fetch recent activities
  const { data: recentPermits } = await supabase
    .from('construction_permits')
    .select('id, household_id, project_description, status, created_at')
    .eq('tenant_id', tenantId)
    .order('created_at', { ascending: false })
    .limit(5)

  const { data: recentStickers } = await supabase
    .from('sticker_requests')
    .select('id, vehicle_plate, status, requested_at')
    .eq('tenant_id', tenantId)
    .order('requested_at', { ascending: false })
    .limit(5)

  const stats = [
    {
      name: 'Total Households',
      value: householdsCount || 0,
      icon: Users,
      href: '/households',
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
    },
    {
      name: 'Vehicle Stickers',
      value: stickersCount || 0,
      icon: Car,
      href: '/stickers',
      color: 'text-green-600',
      bgColor: 'bg-green-100',
    },
    {
      name: 'Construction Permits',
      value: permitsCount || 0,
      icon: FileText,
      href: '/permits',
      color: 'text-orange-600',
      bgColor: 'bg-orange-100',
    },
    {
      name: 'Announcements',
      value: announcementsCount || 0,
      icon: Megaphone,
      href: '/announcements',
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
    },
  ]

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'approved':
      case 'completed':
        return <CheckCircle className="h-4 w-4 text-green-600" />
      case 'pending':
        return <Clock className="h-4 w-4 text-yellow-600" />
      case 'rejected':
        return <AlertCircle className="h-4 w-4 text-red-600" />
      default:
        return <TrendingUp className="h-4 w-4 text-blue-600" />
    }
  }

  const getStatusBadge = (status: string) => {
    const badges = {
      approved: 'bg-green-100 text-green-800',
      completed: 'bg-green-100 text-green-800',
      pending: 'bg-yellow-100 text-yellow-800',
      rejected: 'bg-red-100 text-red-800',
      distributed: 'bg-blue-100 text-blue-800',
    }
    return badges[status as keyof typeof badges] || 'bg-gray-100 text-gray-800'
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Dashboard</h1>
          <p className="text-gray-600 mt-1">Welcome to your community administration portal</p>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat) => (
          <Link
            key={stat.name}
            href={stat.href}
            className="bg-white rounded-lg shadow p-6 card-hover"
          >
            <div className="flex items-center">
              <div className={`${stat.bgColor} p-3 rounded-lg`}>
                <stat.icon className={`h-6 w-6 ${stat.color}`} />
              </div>
              <div className="ml-4">
                <p className="text-gray-500 text-sm">{stat.name}</p>
                <p className="text-2xl font-semibold text-gray-800">{stat.value}</p>
              </div>
            </div>
          </Link>
        ))}
      </div>

      {/* Recent Activities */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Permit Requests */}
        <div className="bg-white rounded-lg shadow">
          <div className="p-6 border-b">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-800">Recent Permit Requests</h2>
              <Link href="/permits" className="text-sm text-primary hover:text-secondary">
                View All →
              </Link>
            </div>
          </div>
          <div className="p-6">
            {recentPermits && recentPermits.length > 0 ? (
              <div className="space-y-4">
                {recentPermits.map((permit) => (
                  <div key={permit.id} className="flex items-start gap-3 pb-4 border-b last:border-0">
                    {getStatusIcon(permit.status)}
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-800 truncate">
                        {permit.project_description}
                      </p>
                      <div className="flex items-center gap-2 mt-1">
                        <span className={`text-xs px-2 py-0.5 rounded-full ${getStatusBadge(permit.status)}`}>
                          {permit.status}
                        </span>
                        <span className="text-xs text-gray-500">
                          {new Date(permit.created_at).toLocaleDateString()}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-gray-500 text-sm text-center py-8">No recent permit requests</p>
            )}
          </div>
        </div>

        {/* Recent Sticker Requests */}
        <div className="bg-white rounded-lg shadow">
          <div className="p-6 border-b">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-800">Recent Sticker Requests</h2>
              <Link href="/stickers" className="text-sm text-primary hover:text-secondary">
                View All →
              </Link>
            </div>
          </div>
          <div className="p-6">
            {recentStickers && recentStickers.length > 0 ? (
              <div className="space-y-4">
                {recentStickers.map((sticker) => (
                  <div key={sticker.id} className="flex items-start gap-3 pb-4 border-b last:border-0">
                    {getStatusIcon(sticker.status)}
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-800">
                        {sticker.vehicle_plate}
                      </p>
                      <div className="flex items-center gap-2 mt-1">
                        <span className={`text-xs px-2 py-0.5 rounded-full ${getStatusBadge(sticker.status)}`}>
                          {sticker.status}
                        </span>
                        <span className="text-xs text-gray-500">
                          {new Date(sticker.requested_at).toLocaleDateString()}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-gray-500 text-sm text-center py-8">No recent sticker requests</p>
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-800 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <Link
            href="/households/new"
            className="flex items-center gap-3 p-4 border-2 border-gray-200 rounded-lg hover:border-primary hover:bg-primary-light transition-colors"
          >
            <Users className="h-5 w-5 text-primary" />
            <span className="text-sm font-medium text-gray-700">Add Household</span>
          </Link>
          <Link
            href="/announcements"
            className="flex items-center gap-3 p-4 border-2 border-gray-200 rounded-lg hover:border-primary hover:bg-primary-light transition-colors"
          >
            <Megaphone className="h-5 w-5 text-primary" />
            <span className="text-sm font-medium text-gray-700">New Announcement</span>
          </Link>
          <Link
            href="/fees"
            className="flex items-center gap-3 p-4 border-2 border-gray-200 rounded-lg hover:border-primary hover:bg-primary-light transition-colors"
          >
            <DollarSign className="h-5 w-5 text-primary" />
            <span className="text-sm font-medium text-gray-700">Manage Fees</span>
          </Link>
          <Link
            href="/rules"
            className="flex items-center gap-3 p-4 border-2 border-gray-200 rounded-lg hover:border-primary hover:bg-primary-light transition-colors"
          >
            <FileText className="h-5 w-5 text-primary" />
            <span className="text-sm font-medium text-gray-700">Village Rules</span>
          </Link>
        </div>
      </div>
    </div>
  )
}
