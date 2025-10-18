import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { approveConstructionPermit, rejectConstructionPermit, markPermitComplete, holdPermit, unholdPermit } from '@/lib/actions/permits'

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const permitId = params.id
    const body = await request.json()
    const { action } = body

    // Route to appropriate action based on the request
    switch (action) {
      case 'approve':
        const approveResult = await approveConstructionPermit({
          permit_id: permitId,
          ...body.data
        })
        return NextResponse.json(approveResult)

      case 'reject':
        const rejectResult = await rejectConstructionPermit({
          permit_id: permitId,
          rejection_reason: body.data.rejection_reason
        })
        return NextResponse.json(rejectResult)

      case 'complete':
        const completeResult = await markPermitComplete({
          permit_id: permitId,
          ...body.data
        })
        return NextResponse.json(completeResult)

      case 'hold':
        const holdResult = await holdPermit({
          permit_id: permitId,
          hold_reason: body.data.hold_reason
        })
        return NextResponse.json(holdResult)

      case 'unhold':
        const unholdResult = await unholdPermit({
          permit_id: permitId
        })
        return NextResponse.json(unholdResult)

      default:
        return NextResponse.json(
          { success: false, error: 'Invalid action specified' },
          { status: 400 }
        )
    }
  } catch (error) {
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error'
      },
      { status: 500 }
    )
  }
}

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const permitId = params.id
    const supabase = await createClient()
    const tenantId = await getTenantId()

    // Get permit with household info
    const { data: permit, error } = await supabase
      .from('construction_permits')
      .select(`
        *,
        household:households!inner(
          id,
          household_name,
          tenant_id,
          residence_unit:residence_units!inner(
            id,
            unit_number,
            property:properties!inner(
              id,
              property_name
            )
          )
        )
      `)
      .eq('id', permitId)
      .eq('household.tenant_id', tenantId)
      .single()

    if (error || !permit) {
      return NextResponse.json(
        { success: false, error: 'Construction permit not found' },
        { status: 404 }
      )
    }

    return NextResponse.json({ success: true, data: permit })
  } catch (error) {
    console.error('Error fetching permit:', error)
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error'
      },
      { status: 500 }
    )
  }
}