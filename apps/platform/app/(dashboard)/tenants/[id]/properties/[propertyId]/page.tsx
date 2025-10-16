'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { ArrowLeft, Plus, Upload } from 'lucide-react'
import { useRouter } from 'next/navigation'
import ResidenceUnitTable from '@/components/properties/ResidenceUnitTable'
import ResidenceUnitForm from '@/components/properties/ResidenceUnitForm'
import BulkImportDialog from '@/components/properties/BulkImportDialog'
import { deleteResidenceUnit, getResidenceUnits } from '@/lib/actions/residence-unit'
import { getProperty } from '@/lib/actions/property'

interface PropertyDetailPageProps {
  params: {
    id: string
    propertyId: string
  }
}

export default function PropertyDetailPage({ params }: PropertyDetailPageProps) {
  const router = useRouter()
  const [property, setProperty] = useState<any>(null)
  const [units, setUnits] = useState<any[]>([])
  const [showAddForm, setShowAddForm] = useState(false)
  const [showBulkImport, setShowBulkImport] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadData() {
      const [propertyResult, unitsData] = await Promise.all([
        getProperty(params.propertyId),
        getResidenceUnits(params.propertyId)
      ])

      if (propertyResult.success) {
        setProperty(propertyResult.data)
      }
      setUnits(unitsData)
      setLoading(false)
    }

    loadData()
  }, [params.propertyId])

  const handleDelete = async (unitId: string) => {
    if (!confirm('Are you sure you want to delete this unit?')) {
      return
    }

    const result = await deleteResidenceUnit(unitId)
    if (result.success) {
      setUnits(units.filter(u => u.id !== unitId))
      router.refresh()
    }
  }

  const handleFormSuccess = () => {
    setShowAddForm(false)
    router.refresh()
    // Reload units
    getResidenceUnits(params.propertyId).then(setUnits)
  }

  const handleBulkImportSuccess = () => {
    setShowBulkImport(false)
    router.refresh()
    // Reload units
    getResidenceUnits(params.propertyId).then(setUnits)
  }

  if (loading) {
    return <div className="text-center py-12">Loading...</div>
  }

  if (!property) {
    return <div className="text-center py-12">Property not found</div>
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <Link
            href={`/tenants/${params.id}/properties`}
            className="text-gray-600 hover:text-gray-800 transition-colors"
          >
            <ArrowLeft className="h-6 w-6" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-800">{property.name}</h1>
            <p className="text-gray-600 mt-1">{property.address}</p>
          </div>
        </div>
        {!showAddForm && (
          <div className="flex space-x-3">
            <button
              onClick={() => setShowBulkImport(true)}
              className="border border-primary text-primary hover:bg-primary-light px-4 py-2 rounded-lg flex items-center transition-colors duration-200"
            >
              <Upload className="h-5 w-5 mr-2" />
              Bulk Import
            </button>
            <button
              onClick={() => setShowAddForm(true)}
              className="bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg flex items-center transition-colors duration-200"
            >
              <Plus className="h-5 w-5 mr-2" />
              Add Unit
            </button>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg border p-4">
          <p className="text-sm text-gray-600">Total Units</p>
          <p className="text-2xl font-bold text-gray-800">{units.length}</p>
        </div>
        <div className="bg-white rounded-lg border p-4">
          <p className="text-sm text-gray-600">Occupied</p>
          <p className="text-2xl font-bold text-green-600">
            {units.filter(u => u.is_occupied).length}
          </p>
        </div>
        <div className="bg-white rounded-lg border p-4">
          <p className="text-sm text-gray-600">Vacant</p>
          <p className="text-2xl font-bold text-gray-600">
            {units.filter(u => !u.is_occupied).length}
          </p>
        </div>
        <div className="bg-white rounded-lg border p-4">
          <p className="text-sm text-gray-600">Occupancy Rate</p>
          <p className="text-2xl font-bold text-primary">
            {units.length > 0 ? Math.round((units.filter(u => u.is_occupied).length / units.length) * 100) : 0}%
          </p>
        </div>
      </div>

      {showAddForm && (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold text-gray-800 mb-4">Add New Unit</h2>
          <ResidenceUnitForm
            tenantId={params.id}
            propertyId={params.propertyId}
            mode="create"
            onSuccess={handleFormSuccess}
          />
        </div>
      )}

      <ResidenceUnitTable units={units} onDelete={handleDelete} />

      {showBulkImport && (
        <BulkImportDialog
          tenantId={params.id}
          propertyId={params.propertyId}
          onClose={() => setShowBulkImport(false)}
          onSuccess={handleBulkImportSuccess}
        />
      )}
    </div>
  )
}
