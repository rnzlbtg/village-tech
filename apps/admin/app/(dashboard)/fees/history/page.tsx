import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import PaymentHistoryTable from '@/components/fees/PaymentHistoryTable'

export default async function PaymentHistoryPage({
  searchParams,
}: {
  searchParams: { household?: string; start_date?: string; end_date?: string }
}) {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  // Fetch all households for filter dropdown
  const { data: households } = await supabase
    .from('households')
    .select(
      `
      id,
      household_name,
      residence_unit:residence_units(unit_number)
    `
    )
    .eq('tenant_id', tenantId)
    .order('household_name')

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Payment History</h1>
        <p className="text-gray-600 mt-1">View all recorded payments and download receipts</p>
      </div>

      <PaymentHistoryTable
        households={households || []}
        initialFilters={{
          household_id: searchParams.household,
          start_date: searchParams.start_date,
          end_date: searchParams.end_date,
        }}
      />
    </div>
  )
}
