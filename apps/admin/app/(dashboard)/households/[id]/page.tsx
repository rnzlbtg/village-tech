import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { notFound } from 'next/navigation'
import { HouseholdDetailsClient } from './HouseholdDetailsClient'

export default async function HouseholdDetailsPage({
  params,
}: {
  params: { id: string }
}) {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  // Fetch household details
  const { data: household, error } = await supabase
    .from('households')
    .select(`
      *,
      residence_unit:residence_units(
        id,
        unit_number,
        unit_type,
        address,
        property:properties(
          id,
          name
        )
      ),
      household_members(
        id,
        first_name,
        last_name,
        relationship,
        email,
        phone_number,
        date_of_birth,
        is_primary_contact
      )
    `)
    .eq('id', params.id)
    .eq('tenant_id', tenantId)
    .single()

  if (error || !household) {
    notFound()
  }

  return <HouseholdDetailsClient household={household} />
}
