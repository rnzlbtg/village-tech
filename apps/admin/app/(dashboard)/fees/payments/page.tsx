import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import PaymentRecordingForm from '@/components/fees/PaymentForm'

export default async function PaymentRecordingPage() {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  // Fetch households with unpaid invoices
  const { data: households } = await supabase
    .from('households')
    .select(`
      id,
      household_name,
      residence_unit:residence_units(
        unit_number,
        property:properties(name)
      )
    `)
    .eq('tenant_id', tenantId)
    .order('household_name')

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Link href="/fees" className="flex items-center text-gray-600 hover:text-gray-900">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Record Payment</h1>
          <p className="text-gray-600 mt-1">Record association fee payments from households</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow">
        <PaymentRecordingForm households={households || []} />
      </div>
    </div>
  )
}
