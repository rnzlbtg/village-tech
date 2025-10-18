import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import Link from 'next/link'
import {
  Users,
  Car,
  FileText,
  Megaphone,
  DollarSign,
  BookOpen,
  AlertCircle,
  CheckCircle,
  Clock,
  TrendingUp,
} from 'lucide-react'

export const metadata = {
  title: 'Dashboard | Admin',
  description: 'Admin dashboard overview',
}

export default async function DashboardPage() {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  // Fetch key metrics in parallel
  const [
    householdsResult,
    stickersResult,
    permitsResult,
    announcementsResult,
    paymentsResult,
  ] = await Promise.all([
    // Households
    supabase
      .from('households')
      .select('id, status', { count: 'exact' })
      .eq('tenant_id', tenantId),

    // Sticker Requests
    supabase
      .from('sticker_requests')
      .select('id, request_status', { count: 'exact' })
      .eq('tenant_id', tenantId),

    // Construction Permits
    supabase
      .from('construction_permits')
      .select('id, permit_status', { count: 'exact' })
      .eq('tenant_id', tenantId),

    // Announcements
    supabase
      .from('announcements')
      .select('id, priority, created_at', { count: 'exact' })
      .eq('tenant_id', tenantId)
      .gte('created_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()),

    // Recent Payments
    supabase
      .from('payment_logs')
      .select('id, payment_amount, payment_date', { count: 'exact' })
      .eq('tenant_id', tenantId)
      .is('voided_at', null)
      .gte('payment_date', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()),
  ])

  // Process households
  const totalHouseholds = householdsResult.count || 0
  const activeHouseholds =
    householdsResult.data?.filter((h) => h.status === 'active').length || 0

  // Process sticker requests
  const totalStickerRequests = stickersResult.count || 0
  const pendingStickerRequests =
    stickersResult.data?.filter((s) => s.request_status === 'pending').length || 0

  // Process permits
  const totalPermits = permitsResult.count || 0
  const activePermits =
    permitsResult.data?.filter((p) => p.permit_status === 'active').length || 0
  const pendingPermits =
    permitsResult.data?.filter((p) => p.permit_status === 'pending').length || 0

  // Process announcements
  const recentAnnouncements = announcementsResult.count || 0

  // Process payments
  const recentPayments = paymentsResult.count || 0
  const recentPaymentAmount =
    paymentsResult.data?.reduce((sum, p) => sum + Number(p.payment_amount), 0) || 0

  const stats = [
    {
      name: 'Total Households',
      value: totalHouseholds,
      subtext: `${activeHouseholds} active`,
      icon: Users,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
      href: '/households',
    },
    {
      name: 'Sticker Requests',
      value: pendingStickerRequests,
      subtext: 'pending review',
      icon: Car,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-100',
      href: '/stickers',
    },
    {
      name: 'Active Permits',
      value: activePermits,
      subtext: `${pendingPermits} pending`,
      icon: FileText,
      color: 'text-green-600',
      bgColor: 'bg-green-100',
      href: '/permits',
    },
    {
      name: 'Recent Payments',
      value: recentPayments,
      subtext: 'last 30 days',
      icon: DollarSign,
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
      href: '/fees/history',
    },
  ]

  // Fetch recent activity
  const { data: recentPaymentLogs } = await supabase
    .from('payment_logs')
    .select(
      `
      id,
      receipt_number,
      payment_amount,
      payment_date,
      household:households(household_name)
    `
    )
    .eq('tenant_id', tenantId)
    .is('voided_at', null)
    .order('payment_date', { ascending: false })
    .order('created_at', { ascending: false })
    .limit(5)

  const { data: recentStickers } = await supabase
    .from('sticker_requests')
    .select(
      `
      id,
      vehicle_type,
      request_status,
      requested_at,
      household:households(household_name)
    `
    )
    .eq('tenant_id', tenantId)
    .order('requested_at', { ascending: false })
    .limit(5)

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-800">Dashboard</h1>
        <p className="text-gray-600 mt-1">Overview of your community administration</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat) => (
          <Link key={stat.name} href={stat.href}>
            <div className="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow cursor-pointer">
              <div className="flex items-center justify-between">
                <div className={`${stat.bgColor} p-3 rounded-lg`}>
                  <stat.icon className={`h-6 w-6 ${stat.color}`} />
                </div>
                <div className="text-right">
                  <p className="text-2xl font-bold text-gray-800">{stat.value}</p>
                  <p className="text-sm text-gray-500">{stat.subtext}</p>
                </div>
              </div>
              <p className="text-gray-700 font-medium mt-4">{stat.name}</p>
            </div>
          </Link>
        ))}
      </div>

      {/* Revenue Summary */}
      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-800">Recent Collections (30 Days)</h2>
          <Link href="/fees/history" className="text-primary hover:underline text-sm">
            View All
          </Link>
        </div>
        <div className="flex items-center gap-4">
          <div className="bg-green-100 p-4 rounded-lg">
            <DollarSign className="h-8 w-8 text-green-600" />
          </div>
          <div>
            <p className="text-3xl font-bold text-gray-900">
              ₱{recentPaymentAmount.toLocaleString('en-PH', { minimumFractionDigits: 2 })}
            </p>
            <p className="text-sm text-gray-600">{recentPayments} payments received</p>
          </div>
        </div>
      </div>

      {/* Recent Activity Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Payments */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-800">Recent Payments</h2>
            <Link href="/fees/history" className="text-primary hover:underline text-sm">
              View All
            </Link>
          </div>
          <div className="space-y-3">
            {recentPaymentLogs && recentPaymentLogs.length > 0 ? (
              recentPaymentLogs.map((payment) => (
                <div key={payment.id} className="flex items-center justify-between py-2 border-b">
                  <div>
                    <p className="font-medium text-gray-900 text-sm">
                      {payment.household?.household_name || 'N/A'}
                    </p>
                    <p className="text-xs text-gray-500">{payment.receipt_number}</p>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold text-gray-900">
                      ₱{Number(payment.payment_amount).toLocaleString('en-PH')}
                    </p>
                    <p className="text-xs text-gray-500">
                      {new Date(payment.payment_date).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              ))
            ) : (
              <p className="text-gray-500 text-sm text-center py-4">No recent payments</p>
            )}
          </div>
        </div>

        {/* Recent Sticker Requests */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-800">Recent Sticker Requests</h2>
            <Link href="/stickers" className="text-primary hover:underline text-sm">
              View All
            </Link>
          </div>
          <div className="space-y-3">
            {recentStickers && recentStickers.length > 0 ? (
              recentStickers.map((sticker) => (
                <div key={sticker.id} className="flex items-center justify-between py-2 border-b">
                  <div>
                    <p className="font-medium text-gray-900 text-sm">
                      {sticker.household?.household_name || 'N/A'}
                    </p>
                    <p className="text-xs text-gray-500 capitalize">{sticker.vehicle_type}</p>
                  </div>
                  <div>
                    <span
                      className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${
                        sticker.request_status === 'pending'
                          ? 'bg-yellow-100 text-yellow-800'
                          : sticker.request_status === 'approved'
                            ? 'bg-green-100 text-green-800'
                            : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {sticker.request_status}
                    </span>
                  </div>
                </div>
              ))
            ) : (
              <p className="text-gray-500 text-sm text-center py-4">No recent sticker requests</p>
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-800 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
          <Link
            href="/households/new"
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Users className="h-6 w-6 text-blue-600 mb-2" />
            <span className="text-sm font-medium text-gray-700 text-center">Add Household</span>
          </Link>
          <Link
            href="/properties/new"
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <FileText className="h-6 w-6 text-green-600 mb-2" />
            <span className="text-sm font-medium text-gray-700 text-center">Add Property</span>
          </Link>
          <Link
            href="/fees/payments"
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <DollarSign className="h-6 w-6 text-purple-600 mb-2" />
            <span className="text-sm font-medium text-gray-700 text-center">
              Record Payment
            </span>
          </Link>
          <Link
            href="/announcements"
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Megaphone className="h-6 w-6 text-orange-600 mb-2" />
            <span className="text-sm font-medium text-gray-700 text-center">New Announcement</span>
          </Link>
          <Link
            href="/stickers"
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Car className="h-6 w-6 text-yellow-600 mb-2" />
            <span className="text-sm font-medium text-gray-700 text-center">
              Sticker Requests
            </span>
          </Link>
          <Link
            href="/permits"
            className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <FileText className="h-6 w-6 text-red-600 mb-2" />
            <span className="text-sm font-medium text-gray-700 text-center">View Permits</span>
          </Link>
        </div>
      </div>
    </div>
  )
}
