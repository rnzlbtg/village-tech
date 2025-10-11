import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { requireSuperAdmin } from '@/lib/auth/helpers'
import { bulkImportLimiter, getClientIdentifier } from '@/lib/utils/rate-limiter'

const BATCH_SIZE = 1000
const MAX_UNITS = 10000 // Maximum units per import
const MAX_PAYLOAD_SIZE = 50 * 1024 * 1024 // 50MB limit

export async function POST(request: NextRequest) {
  try {
    // Check authorization
    const user = await requireSuperAdmin()

    // Rate limiting (10 requests per minute per user)
    const clientId = getClientIdentifier(request, user?.id)
    const rateLimitResult = bulkImportLimiter.check(clientId)

    if (!rateLimitResult.allowed) {
      const resetIn = Math.ceil((rateLimitResult.resetTime - Date.now()) / 1000)
      return NextResponse.json(
        {
          success: false,
          error: `Rate limit exceeded. Please try again in ${resetIn} seconds.`,
          retryAfter: resetIn,
        },
        {
          status: 429,
          headers: {
            'Retry-After': resetIn.toString(),
            'X-RateLimit-Limit': '10',
            'X-RateLimit-Remaining': '0',
            'X-RateLimit-Reset': rateLimitResult.resetTime.toString(),
          },
        }
      )
    }

    const formData = await request.formData()
    const tenantId = formData.get('tenant_id') as string
    const propertyId = formData.get('property_id') as string
    const unitsData = formData.get('units') as string

    if (!tenantId || !propertyId || !unitsData) {
      return NextResponse.json(
        { success: false, error: 'Missing required fields' },
        { status: 400 }
      )
    }

    // Validate payload size (prevent DOS attacks)
    if (unitsData.length > MAX_PAYLOAD_SIZE) {
      return NextResponse.json(
        { success: false, error: 'Request payload too large (max 50MB)' },
        { status: 413 }
      )
    }

    const units = JSON.parse(unitsData)

    if (!Array.isArray(units) || units.length === 0) {
      return NextResponse.json({ success: false, error: 'No units provided' }, { status: 400 })
    }

    // Validate number of units
    if (units.length > MAX_UNITS) {
      return NextResponse.json(
        {
          success: false,
          error: `Too many units. Maximum ${MAX_UNITS} units per import. You have ${units.length} units. Consider splitting into multiple files.`
        },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // Check for duplicate unit numbers in the uploaded data
    const unitNumbers = units.map((u) => u.unit_number)
    const duplicatesInFile = unitNumbers.filter(
      (item, index) => unitNumbers.indexOf(item) !== index
    )

    if (duplicatesInFile.length > 0) {
      return NextResponse.json(
        {
          success: false,
          error: `Duplicate unit numbers in file: ${duplicatesInFile.join(', ')}`,
        },
        { status: 400 }
      )
    }

    // Check for existing unit numbers in the database
    const { data: existingUnits } = await supabase
      .from('residence_units')
      .select('unit_number')
      .eq('property_id', propertyId)
      .in('unit_number', unitNumbers)

    if (existingUnits && existingUnits.length > 0) {
      const existingNumbers = existingUnits.map((u) => u.unit_number)
      return NextResponse.json(
        {
          success: false,
          error: `These unit numbers already exist: ${existingNumbers.join(', ')}`,
        },
        { status: 400 }
      )
    }

    // Prepare units for insertion
    const unitsToInsert = units.map((unit: any) => ({
      tenant_id: tenantId,
      property_id: propertyId,
      unit_number: unit.unit_number,
      floor_number: unit.floor_number ? parseInt(unit.floor_number) : null,
      unit_type: unit.unit_type || null,
      bedrooms: unit.bedrooms ? parseInt(unit.bedrooms) : null,
      bathrooms: unit.bathrooms ? parseFloat(unit.bathrooms) : null,
      square_meters: unit.square_meters ? parseFloat(unit.square_meters) : null,
      parking_slots: unit.parking_slots ? parseInt(unit.parking_slots) : null,
      is_occupied: unit.is_occupied === 'true',
      notes: unit.notes || null,
    }))

    // Process in batches
    let totalInserted = 0
    const batches = []

    for (let i = 0; i < unitsToInsert.length; i += BATCH_SIZE) {
      const batch = unitsToInsert.slice(i, i + BATCH_SIZE)
      batches.push(batch)
    }

    // Insert batches sequentially with transaction-like behavior
    for (let i = 0; i < batches.length; i++) {
      const { data, error } = await supabase.from('residence_units').insert(batches[i]).select()

      if (error) {
        // If any batch fails, we can't rollback previous batches in Supabase
        // But we report the error and stop processing
        return NextResponse.json(
          {
            success: false,
            error: `Failed at batch ${i + 1}/${batches.length}: ${error.message}`,
            partialSuccess: totalInserted > 0,
            inserted: totalInserted,
          },
          { status: 500 }
        )
      }

      totalInserted += data.length
    }

    return NextResponse.json(
      {
        success: true,
        inserted: totalInserted,
        total: units.length,
        batches: batches.length,
      },
      {
        headers: {
          'X-RateLimit-Limit': '10',
          'X-RateLimit-Remaining': rateLimitResult.remaining.toString(),
          'X-RateLimit-Reset': rateLimitResult.resetTime.toString(),
        },
      }
    )
  } catch (error) {
    console.error('Bulk import error:', error)
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Bulk import failed',
      },
      { status: 500 }
    )
  }
}
