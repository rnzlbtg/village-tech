import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import StickerRequestsTable from './StickerRequestsTable'

export const metadata = {
  title: 'Vehicle Sticker Requests | Admin',
  description: 'Manage vehicle sticker requests and distribution',
}

export default async function StickersPage({
  searchParams,
}: {
  searchParams: { status?: string }
}) {
  const supabase = await createClient()
  const tenantId = await getTenantId()
  const statusFilter = searchParams.status || 'all'

  // Build query
  let query = supabase
    .from('sticker_requests')
    .select(`
      id,
      vehicle_plate,
      vehicle_make,
      vehicle_color,
      owner_name,
      status,
      requested_at,
      approved_at,
      distributed_at,
      rejection_reason,
      household:households!inner(
        id,
        household_name,
        residence_unit:residence_units(
          unit_number,
          property:properties(name)
        )
      )
    `)
    .eq('household.tenant_id', tenantId)
    .order('requested_at', { ascending: false })

  // Apply status filter
  if (statusFilter !== 'all') {
    query = query.eq('status', statusFilter)
  }

  const { data: requests, error } = await query

  if (error) {
    console.error('Error fetching sticker requests:', error)
    return (
      <div className="p-6">
        <h1 className="text-2xl font-bold mb-4">Vehicle Sticker Requests</h1>
        <p className="text-red-500">Failed to load sticker requests</p>
      </div>
    )
  }

  // Get active sticker program
  const { data: program } = await supabase
    .from('sticker_programs')
    .select('*')
    .eq('tenant_id', tenantId)
    .eq('active', true)
    .maybeSingle()

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold mb-2">Vehicle Sticker Requests</h1>
          <p className="text-gray-600">
            Manage vehicle sticker requests and distribution
          </p>
        </div>
        <a
          href="/stickers/program"
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Configure Program
        </a>
      </div>

      {program && (
        <div className="mb-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
          <h3 className="font-semibold mb-2">Active Program: {program.program_name}</h3>
          <p className="text-sm text-gray-700">
            Allocation: {program.stickers_per_household} stickers per household
            {program.expiry_date && ` • Expires: ${new Date(program.expiry_date).toLocaleDateString()}`}
          </p>
        </div>
      )}

      {!program && (
        <div className="mb-6 p-4 bg-yellow-50 rounded-lg border border-yellow-200">
          <p className="text-sm text-yellow-800">
            ⚠️ No active sticker program configured.{' '}
            <a href="/stickers/program" className="underline font-medium">
              Configure program
            </a>{' '}
            to enable sticker requests.
          </p>
        </div>
      )}

      <StickerRequestsTable
        requests={requests || []}
        currentStatus={statusFilter}
      />
    </div>
  )
}
