/**
 * Sticker Distribution Receipt Generation
 *
 * For MVP, this generates a simple receipt data object.
 * In production, use @react-pdf/renderer to generate actual PDF receipts.
 */

export type StickerReceiptData = {
  receipt_number: string
  sticker_code: string
  household_name: string
  household_head_name?: string
  residence_unit: string
  vehicle_plate: string
  vehicle_make?: string
  vehicle_color?: string
  owner_name: string
  distributed_at: string
  distributed_by: string
  signature: string
  tenant_name?: string
}

/**
 * Generate sticker distribution receipt
 *
 * @param data - Receipt data
 * @returns Receipt object
 */
export function generateStickerReceipt(data: StickerReceiptData) {
  const receiptDate = new Date(data.distributed_at).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

  // For MVP: Return formatted receipt data
  // In production: Use @react-pdf/renderer to generate actual PDF
  return {
    receipt_number: data.receipt_number,
    title: 'Vehicle Sticker Distribution Receipt',
    date: receiptDate,
    sections: [
      {
        title: 'Household Information',
        fields: [
          { label: 'Household', value: data.household_name },
          { label: 'Residence Unit', value: data.residence_unit },
          { label: 'Household Head', value: data.household_head_name || 'N/A' },
        ],
      },
      {
        title: 'Vehicle Information',
        fields: [
          { label: 'Vehicle Plate', value: data.vehicle_plate },
          { label: 'Make/Model', value: data.vehicle_make || 'N/A' },
          { label: 'Color', value: data.vehicle_color || 'N/A' },
          { label: 'Owner Name', value: data.owner_name },
        ],
      },
      {
        title: 'Sticker Details',
        fields: [
          { label: 'Sticker Code', value: data.sticker_code },
          { label: 'Distribution Date', value: receiptDate },
          { label: 'Distributed By', value: data.distributed_by },
        ],
      },
      {
        title: 'Acknowledgment',
        fields: [
          {
            label: 'Signature',
            value: 'Received by household representative',
            signature: data.signature,
          },
        ],
      },
    ],
    footer: `This receipt serves as proof of vehicle sticker distribution. Keep this for your records. ${data.tenant_name || ''}`,
  }
}

/**
 * Format receipt for printing
 *
 * @param data - Receipt data
 * @returns HTML string for printing
 */
export function formatReceiptHTML(data: StickerReceiptData): string {
  const receipt = generateStickerReceipt(data)

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>${receipt.title}</title>
      <style>
        @media print {
          body { margin: 0; }
          .no-print { display: none; }
        }
        body {
          font-family: Arial, sans-serif;
          max-width: 800px;
          margin: 0 auto;
          padding: 20px;
        }
        .header {
          text-align: center;
          border-bottom: 2px solid #000;
          padding-bottom: 10px;
          margin-bottom: 20px;
        }
        .receipt-number {
          font-size: 12px;
          color: #666;
        }
        .section {
          margin-bottom: 20px;
        }
        .section-title {
          font-weight: bold;
          background-color: #f0f0f0;
          padding: 5px 10px;
          margin-bottom: 10px;
        }
        .field {
          display: flex;
          padding: 5px 10px;
        }
        .field-label {
          font-weight: bold;
          width: 150px;
        }
        .field-value {
          flex: 1;
        }
        .signature-box {
          border: 1px solid #ccc;
          min-height: 60px;
          margin-top: 5px;
          padding: 5px;
        }
        .footer {
          margin-top: 30px;
          text-align: center;
          font-size: 12px;
          color: #666;
          border-top: 1px solid #ccc;
          padding-top: 10px;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>${receipt.title}</h1>
        <div class="receipt-number">Receipt #: ${receipt.receipt_number}</div>
        <div>${receipt.date}</div>
      </div>

      ${receipt.sections
        .map(
          section => `
        <div class="section">
          <div class="section-title">${section.title}</div>
          ${section.fields
            .map(
              field => `
            <div class="field">
              <div class="field-label">${field.label}:</div>
              <div class="field-value">
                ${field.value}
                ${field.signature ? `<div class="signature-box">${field.signature}</div>` : ''}
              </div>
            </div>
          `
            )
            .join('')}
        </div>
      `
        )
        .join('')}

      <div class="footer">
        ${receipt.footer}
      </div>

      <div class="no-print" style="margin-top: 20px; text-align: center;">
        <button onclick="window.print()" style="padding: 10px 20px; font-size: 16px;">
          Print Receipt
        </button>
      </div>
    </body>
    </html>
  `
}
