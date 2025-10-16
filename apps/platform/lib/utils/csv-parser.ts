import Papa from 'papaparse'

export interface CSVParseResult<T> {
  data: T[]
  errors: string[]
  totalRows: number
  validRows: number
}

export interface ResidenceUnitCSVRow {
  unit_number: string
  floor_number?: string
  unit_type?: string
  bedrooms?: string
  bathrooms?: string
  square_meters?: string
  parking_slots?: string
  is_occupied?: string
  notes?: string
}

/**
 * Parse CSV file for residence unit bulk import
 */
export async function parseResidenceUnitsCSV(
  file: File
): Promise<CSVParseResult<ResidenceUnitCSVRow>> {
  return new Promise((resolve) => {
    const errors: string[] = []
    const validData: ResidenceUnitCSVRow[] = []

    Papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      transformHeader: (header) => {
        // Normalize header names
        return header.toLowerCase().trim().replace(/\s+/g, '_')
      },
      complete: (results) => {
        let rowNumber = 1 // Header is row 0

        results.data.forEach((row: any) => {
          rowNumber++

          // Validate required fields
          if (!row.unit_number || row.unit_number.trim() === '') {
            errors.push(`Row ${rowNumber}: Unit number is required`)
            return
          }

          // Validate numeric fields
          if (row.floor_number && isNaN(Number(row.floor_number))) {
            errors.push(`Row ${rowNumber}: Floor number must be a number`)
            return
          }

          if (row.bedrooms && isNaN(Number(row.bedrooms))) {
            errors.push(`Row ${rowNumber}: Bedrooms must be a number`)
            return
          }

          if (row.bathrooms && isNaN(Number(row.bathrooms))) {
            errors.push(`Row ${rowNumber}: Bathrooms must be a number`)
            return
          }

          if (row.square_meters && isNaN(Number(row.square_meters))) {
            errors.push(`Row ${rowNumber}: Square meters must be a number`)
            return
          }

          if (row.parking_slots && isNaN(Number(row.parking_slots))) {
            errors.push(`Row ${rowNumber}: Parking slots must be a number`)
            return
          }

          // Validate unit type if provided
          const validUnitTypes = ['apartment', 'house', 'townhouse', 'condo', 'studio', 'other']
          if (row.unit_type && !validUnitTypes.includes(row.unit_type.toLowerCase())) {
            errors.push(
              `Row ${rowNumber}: Invalid unit type. Must be one of: ${validUnitTypes.join(', ')}`
            )
            return
          }

          // Validate boolean field
          if (
            row.is_occupied &&
            !['true', 'false', '1', '0', 'yes', 'no'].includes(row.is_occupied.toLowerCase())
          ) {
            errors.push(`Row ${rowNumber}: is_occupied must be true/false or yes/no`)
            return
          }

          validData.push({
            unit_number: row.unit_number.trim(),
            floor_number: row.floor_number || undefined,
            unit_type: row.unit_type?.toLowerCase() || undefined,
            bedrooms: row.bedrooms || undefined,
            bathrooms: row.bathrooms || undefined,
            square_meters: row.square_meters || undefined,
            parking_slots: row.parking_slots || undefined,
            is_occupied: row.is_occupied
              ? ['true', '1', 'yes'].includes(row.is_occupied.toLowerCase())
                ? 'true'
                : 'false'
              : undefined,
            notes: row.notes || undefined,
          })
        })

        // Add CSV parsing errors
        if (results.errors.length > 0) {
          results.errors.forEach((error) => {
            errors.push(`Parse error at row ${error.row}: ${error.message}`)
          })
        }

        resolve({
          data: validData,
          errors,
          totalRows: results.data.length,
          validRows: validData.length,
        })
      },
      error: (error) => {
        resolve({
          data: [],
          errors: [`CSV parsing failed: ${error.message}`],
          totalRows: 0,
          validRows: 0,
        })
      },
    })
  })
}

/**
 * Generate CSV template for residence units
 */
export function generateResidenceUnitTemplate(): string {
  const headers = [
    'unit_number',
    'floor_number',
    'unit_type',
    'bedrooms',
    'bathrooms',
    'square_meters',
    'parking_slots',
    'is_occupied',
    'notes',
  ]

  const examples = [
    ['101', '1', 'apartment', '2', '1.5', '75.5', '1', 'false', 'Corner unit'],
    ['102', '1', 'apartment', '3', '2', '95.0', '2', 'true', ''],
    ['201', '2', 'condo', '1', '1', '55.0', '1', 'false', 'City view'],
  ]

  const csv = [headers.join(','), ...examples.map((row) => row.join(','))].join('\n')

  return csv
}

/**
 * Download CSV template
 */
export function downloadCSVTemplate(filename: string = 'residence_units_template.csv') {
  const csv = generateResidenceUnitTemplate()
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)

  link.setAttribute('href', url)
  link.setAttribute('download', filename)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}
