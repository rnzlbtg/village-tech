'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { X, Upload, Download, CheckCircle, AlertTriangle, Loader2 } from 'lucide-react'
import { parseResidenceUnitsCSV, downloadCSVTemplate } from '@/lib/utils/csv-parser'

interface BulkImportDialogProps {
  tenantId: string
  propertyId: string
  onClose: () => void
  onSuccess: () => void
}

export default function BulkImportDialog({
  tenantId,
  propertyId,
  onClose,
  onSuccess,
}: BulkImportDialogProps) {
  const router = useRouter()
  const [file, setFile] = useState<File | null>(null)
  const [loading, setLoading] = useState(false)
  const [progress, setProgress] = useState(0)
  const [error, setError] = useState<string | null>(null)
  const [validationErrors, setValidationErrors] = useState<string[]>([])
  const [success, setSuccess] = useState(false)
  const [result, setResult] = useState<any>(null)

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0]
    if (selectedFile) {
      // Validate file type
      const validTypes = ['text/csv', 'application/vnd.ms-excel', 'application/csv']
      const isCSV = selectedFile.name.endsWith('.csv') || validTypes.includes(selectedFile.type)

      if (!isCSV) {
        setError('Please select a CSV file (.csv)')
        setFile(null)
        return
      }

      // Validate file size (max 50MB)
      const maxSize = 50 * 1024 * 1024 // 50MB in bytes
      if (selectedFile.size > maxSize) {
        setError(`File size exceeds 50MB limit. Your file is ${(selectedFile.size / 1024 / 1024).toFixed(2)}MB`)
        setFile(null)
        return
      }

      // Warn if file is large (over 5MB)
      if (selectedFile.size > 5 * 1024 * 1024) {
        console.warn(`Large file detected: ${(selectedFile.size / 1024 / 1024).toFixed(2)}MB - this may take longer to process`)
      }

      setFile(selectedFile)
      setError(null)
      setValidationErrors([])
    }
  }

  const handleUpload = async () => {
    if (!file) {
      setError('Please select a file')
      return
    }

    setLoading(true)
    setError(null)
    setValidationErrors([])
    setProgress(25)

    try {
      // Parse CSV
      const parseResult = await parseResidenceUnitsCSV(file)
      setProgress(50)

      if (parseResult.errors.length > 0) {
        setValidationErrors(parseResult.errors)
        setError(`Found ${parseResult.errors.length} validation error(s)`)
        setLoading(false)
        setProgress(0)
        return
      }

      if (parseResult.validRows === 0) {
        setError('No valid rows found in CSV file')
        setLoading(false)
        setProgress(0)
        return
      }

      setProgress(60)

      // Upload to API
      const formData = new FormData()
      formData.append('tenant_id', tenantId)
      formData.append('property_id', propertyId)
      formData.append('units', JSON.stringify(parseResult.data))

      setProgress(75)

      const response = await fetch('/api/bulk-import', {
        method: 'POST',
        body: formData,
      })

      const data = await response.json()

      setProgress(100)

      if (!data.success) {
        setError(data.error || 'Import failed')
        if (data.partialSuccess) {
          setResult(data)
        }
        setLoading(false)
        return
      }

      setSuccess(true)
      setResult(data)

      setTimeout(() => {
        onSuccess()
        router.refresh()
      }, 2000)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An unexpected error occurred')
      setLoading(false)
      setProgress(0)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-2xl mx-4">
        <div className="flex items-center justify-between p-6 border-b">
          <h2 className="text-xl font-semibold text-gray-800">Bulk Import Residence Units</h2>
          <button
            onClick={onClose}
            disabled={loading}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="h-6 w-6" />
          </button>
        </div>

        <div className="p-6 space-y-6">
          {/* Download Template */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex items-start space-x-3">
              <Download className="h-5 w-5 text-blue-600 mt-0.5" />
              <div className="flex-1">
                <h3 className="font-medium text-blue-900 mb-1">Need a template?</h3>
                <p className="text-sm text-blue-700 mb-3">
                  Download our CSV template with example data to get started.
                </p>
                <button
                  onClick={() => downloadCSVTemplate()}
                  className="text-sm bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors"
                >
                  Download Template
                </button>
              </div>
            </div>
          </div>

          {/* File Upload */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Upload CSV File
            </label>
            <div className="flex items-center space-x-4">
              <input
                type="file"
                accept=".csv"
                onChange={handleFileChange}
                disabled={loading}
                className="flex-1 text-sm text-gray-600 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-primary file:text-white hover:file:bg-secondary file:cursor-pointer disabled:opacity-50"
              />
            </div>
            {file && (
              <p className="text-sm text-gray-600 mt-2">Selected: {file.name}</p>
            )}
          </div>

          {/* Progress Bar */}
          {loading && (
            <div className="space-y-2">
              <div className="flex justify-between text-sm text-gray-600">
                <span>Processing...</span>
                <span>{progress}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-primary h-2 rounded-full transition-all duration-300"
                  style={{ width: `${progress}%` }}
                />
              </div>
            </div>
          )}

          {/* Success Message */}
          {success && result && (
            <div className="bg-green-50 border-l-4 border-green-500 p-4 rounded-md">
              <div className="flex items-center">
                <CheckCircle className="h-5 w-5 text-green-500 mr-2" />
                <div>
                  <p className="text-green-700 font-medium">Import successful!</p>
                  <p className="text-sm text-green-600 mt-1">
                    Imported {result.inserted} units in {result.batches} batch(es)
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Error Message */}
          {error && (
            <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-md">
              <div className="flex items-start">
                <AlertTriangle className="h-5 w-5 text-red-500 mr-2 mt-0.5" />
                <div className="flex-1">
                  <p className="text-red-700 font-medium">{error}</p>
                  {result?.partialSuccess && (
                    <p className="text-sm text-red-600 mt-1">
                      Partially imported: {result.inserted} units before error
                    </p>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Validation Errors */}
          {validationErrors.length > 0 && (
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 max-h-60 overflow-y-auto">
              <h4 className="font-medium text-yellow-900 mb-2">Validation Errors:</h4>
              <ul className="text-sm text-yellow-800 space-y-1">
                {validationErrors.slice(0, 10).map((err, index) => (
                  <li key={index} className="flex items-start">
                    <span className="mr-2">•</span>
                    <span>{err}</span>
                  </li>
                ))}
                {validationErrors.length > 10 && (
                  <li className="text-yellow-700 italic">
                    ... and {validationErrors.length - 10} more errors
                  </li>
                )}
              </ul>
            </div>
          )}

          {/* CSV Format Instructions */}
          <div className="bg-gray-50 rounded-lg p-4 text-sm">
            <h4 className="font-medium text-gray-900 mb-2">CSV Format Requirements:</h4>
            <ul className="text-gray-700 space-y-1">
              <li>• Required: <code className="bg-gray-200 px-1 rounded">unit_number</code></li>
              <li>
                • Optional: floor_number, unit_type, bedrooms, bathrooms, square_meters,
                parking_slots, is_occupied, notes
              </li>
              <li>
                • Unit types: apartment, house, townhouse, condo, studio, other
              </li>
              <li>• is_occupied: true/false or yes/no</li>
            </ul>
          </div>
        </div>

        <div className="flex justify-end space-x-4 p-6 border-t">
          <button
            onClick={onClose}
            disabled={loading}
            className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
          >
            Cancel
          </button>
          <button
            onClick={handleUpload}
            disabled={!file || loading || success}
            className="px-6 py-2 bg-primary hover:bg-secondary text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
          >
            {loading ? (
              <>
                <Loader2 className="h-5 w-5 mr-2 animate-spin" />
                Processing...
              </>
            ) : (
              <>
                <Upload className="h-5 w-5 mr-2" />
                Import Units
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  )
}
