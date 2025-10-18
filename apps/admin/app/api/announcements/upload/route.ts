import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { getTenantId, requireAdmin } from '@/lib/auth/helpers'

const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB
const ALLOWED_TYPES = [
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/jpg',
  'image/gif',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document', // .docx
  'application/msword', // .doc
]

// Magic bytes for file type verification
const MAGIC_BYTES: Record<string, number[]> = {
  pdf: [0x25, 0x50, 0x44, 0x46], // %PDF
  jpeg: [0xff, 0xd8, 0xff],
  png: [0x89, 0x50, 0x4e, 0x47],
  gif: [0x47, 0x49, 0x46, 0x38],
  docx: [0x50, 0x4b, 0x03, 0x04], // ZIP format (DOCX is zipped XML)
}

function verifyFileType(buffer: ArrayBuffer, declaredType: string): boolean {
  const arr = new Uint8Array(buffer).slice(0, 10)

  if (declaredType.includes('pdf')) {
    return arr[0] === MAGIC_BYTES.pdf[0] && arr[1] === MAGIC_BYTES.pdf[1]
  }
  if (declaredType.includes('jpeg') || declaredType.includes('jpg')) {
    return arr[0] === MAGIC_BYTES.jpeg[0] && arr[1] === MAGIC_BYTES.jpeg[1]
  }
  if (declaredType.includes('png')) {
    return arr[0] === MAGIC_BYTES.png[0] && arr[1] === MAGIC_BYTES.png[1]
  }
  if (declaredType.includes('gif')) {
    return arr[0] === MAGIC_BYTES.gif[0] && arr[1] === MAGIC_BYTES.gif[1]
  }
  if (declaredType.includes('wordprocessing') || declaredType.includes('msword')) {
    return arr[0] === MAGIC_BYTES.docx[0] && arr[1] === MAGIC_BYTES.docx[1]
  }

  return true // Allow if we can't verify
}

export async function POST(request: NextRequest) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return NextResponse.json({ error: 'Tenant ID not found' }, { status: 401 })
    }

    const formData = await request.formData()
    const file = formData.get('file') as File

    if (!file) {
      return NextResponse.json({ error: 'No file provided' }, { status: 400 })
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
        { error: 'Invalid file type. Allowed: PDF, DOCX, DOC, JPEG, PNG, GIF' },
        { status: 400 }
      )
    }

    const fileBuffer = await file.arrayBuffer()

    // Verify magic bytes
    if (!verifyFileType(fileBuffer, file.type)) {
      return NextResponse.json(
        { error: 'File content does not match declared type' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // Generate unique file name
    const timestamp = Date.now()
    const sanitizedName = file.name.replace(/[^a-zA-Z0-9.-]/g, '_')
    const fileName = `${tenantId}/${timestamp}-${sanitizedName}`

    // Upload to Supabase Storage
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('announcement-files')
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
      .from('announcement-files')
      .getPublicUrl(fileName)

    return NextResponse.json({
      success: true,
      fileName: file.name,
      filePath: uploadData.path,
      url: urlData.publicUrl,
      size: file.size,
      type: file.type,
    })
  } catch (error) {
    console.error('File upload error:', error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to upload file' },
      { status: 500 }
    )
  }
}
