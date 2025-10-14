import { renderToBuffer } from '@react-pdf/renderer'
import { PaymentReceipt, PaymentReceiptData } from './PaymentReceipt'
import { createClient } from '@/lib/supabase/server'

/**
 * Generate PDF receipt and upload to Supabase Storage
 * Returns the public URL of the uploaded receipt
 */
export async function generateAndUploadReceipt(
  receiptData: PaymentReceiptData,
  tenantId: string
): Promise<{ success: boolean; url?: string; error?: string }> {
  try {
    // Generate PDF buffer
    const pdfBuffer = await renderToBuffer(<PaymentReceipt data={receiptData} />)

    // Upload to Supabase Storage
    const supabase = await createClient()
    const fileName = `${tenantId}/${receiptData.receipt_number}.pdf`

    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('receipt-archives')
      .upload(fileName, pdfBuffer, {
        contentType: 'application/pdf',
        upsert: true, // Allow overwriting if receipt is regenerated
      })

    if (uploadError) {
      console.error('Receipt upload error:', uploadError)
      return { success: false, error: 'Failed to upload receipt' }
    }

    // Get public URL
    const { data: urlData } = supabase.storage
      .from('receipt-archives')
      .getPublicUrl(fileName)

    return { success: true, url: urlData.publicUrl }
  } catch (error) {
    console.error('Receipt generation error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to generate receipt',
    }
  }
}

/**
 * Download receipt as buffer (for email attachments or direct download)
 */
export async function generateReceiptBuffer(
  receiptData: PaymentReceiptData
): Promise<{ success: boolean; buffer?: Buffer; error?: string }> {
  try {
    const pdfBuffer = await renderToBuffer(<PaymentReceipt data={receiptData} />)
    return { success: true, buffer: Buffer.from(pdfBuffer) }
  } catch (error) {
    console.error('Receipt buffer generation error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to generate receipt',
    }
  }
}
