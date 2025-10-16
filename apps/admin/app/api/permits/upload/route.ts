import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { getTenantId, requireAdmin } from '@/lib/auth/helpers'

const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB
const ALLOWED_TYPES = [
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/jpg',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document', // .docx
  'application/msword', // .doc
]

export async function POST(request: NextRequest) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return NextResponse.json({ error: 'Tenant ID not found' }, { status: 401 })
    }

    const formData = await request.formData()
    const file = formData.get('file') as File
    const permitId = formData.get('permitId') as string

    if (!file) {
      return NextResponse.json({ error: 'No file provided' }, { status: 400 })
    }

    if (!permitId) {
      return NextResponse.json({ error: 'Permit ID required' }, { status: 400 })
    }

    // Validate file size
    if (file.size > MAX_FILE_SIZE) {
      return NextResponse.json(
        { error: `File size must be less than ${MAX_FILE_SIZE / 1024 / 1024}MB` },
        { status: 400 }
      )
    }

    // Validate file type
    if (!ALLOWED_TYPES.includes(file.type)) {
      return NextResponse.json(
        { error: 'Invalid file type. Allowed: PDF, JPEG, PNG, DOC, DOCX' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // Verify permit belongs to tenant
    const { data: permit, error: permitError } = await supabase
      .from('construction_permits')
      .select('id')
      .eq('id', permitId)
      .eq('tenant_id', tenantId)
      .single()

    if (permitError || !permit) {
      return NextResponse.json({ error: 'Permit not found' }, { status: 404 })
    }

    // Generate unique file name
    const timestamp = Date.now()
    const extension = file.name.split('.').pop()
    const fileName = `${tenantId}/${permitId}/${timestamp}-${file.name}`

    // Upload to Supabase Storage
    const fileBuffer = await file.arrayBuffer()
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('permit-attachments')
      .upload(fileName, fileBuffer, {
        contentType: file.type,
        upsert: false,
      })

    if (uploadError) {
      console.error('Upload error:', uploadError)
      return NextResponse.json({ error: 'Failed to upload file' }, { status: 500 })
    }

    // Get public URL
    const { data: urlData } = supabase.storage
      .from('permit-attachments')
      .getPublicUrl(fileName)

    return NextResponse.json({
      success: true,
      fileName: file.name,
      filePath: uploadData.path,
      url: urlData.publicUrl,
    })
  } catch (error) {
    console.error('File upload error:', error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to upload file' },
      { status: 500 }
    )
  }
}
