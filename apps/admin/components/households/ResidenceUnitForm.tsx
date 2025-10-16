'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { InputField, SelectField, TextareaField } from '@/components/shared/FormField'

interface Property {
  id: string
  name: string
}

interface ResidenceUnitFormProps {
  onChange?: (data: ResidenceUnitFormData) => void
  initialData?: Partial<ResidenceUnitFormData>
}

export interface ResidenceUnitFormData {
  property_id: string
  unit_number: string
  unit_type: string
  unit_address: string
  bedrooms?: number
  bathrooms?: number
  square_meters?: number
  parking_slots?: number
}

export default function ResidenceUnitForm({ onChange, initialData }: ResidenceUnitFormProps) {
  const [properties, setProperties] = useState<Property[]>([])
  const [formData, setFormData] = useState<ResidenceUnitFormData>({
    property_id: initialData?.property_id || '',
    unit_number: initialData?.unit_number || '',
    unit_type: initialData?.unit_type || 'house',
    unit_address: initialData?.unit_address || '',
    bedrooms: initialData?.bedrooms,
    bathrooms: initialData?.bathrooms,
    square_meters: initialData?.square_meters,
    parking_slots: initialData?.parking_slots,
  })

  useEffect(() => {
    async function fetchProperties() {
      const supabase = createClient()
      const { data } = await supabase.from('properties').select('id, name').order('name')

      if (data) {
        setProperties(data)
      }
    }
    fetchProperties()
  }, [])

  const handleChange = (field: keyof ResidenceUnitFormData, value: any) => {
    const updatedData = { ...formData, [field]: value }
    setFormData(updatedData)
    onChange?.(updatedData)
  }

  const unitTypeOptions = [
    { value: 'house', label: 'House' },
    { value: 'studio', label: 'Studio' },
    { value: '1br', label: '1 Bedroom' },
    { value: '2br', label: '2 Bedrooms' },
    { value: '3br', label: '3+ Bedrooms' },
    { value: 'penthouse', label: 'Penthouse' },
    { value: 'townhouse', label: 'Townhouse' },
  ]

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold text-gray-800 border-b pb-2">
        Residence Unit Details
      </h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <SelectField
          label="Property"
          name="property_id"
          required
          value={formData.property_id}
          onChange={(e) => handleChange('property_id', e.target.value)}
          options={properties.map((p) => ({ value: p.id, label: p.name }))}
          placeholder="Select a property"
        />

        <InputField
          label="Unit Number"
          name="unit_number"
          type="text"
          required
          value={formData.unit_number}
          onChange={(e) => handleChange('unit_number', e.target.value)}
          placeholder="e.g., House 25, Unit 101, TH-5"
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <SelectField
          label="Residence Type"
          name="unit_type"
          required
          value={formData.unit_type}
          onChange={(e) => handleChange('unit_type', e.target.value)}
          options={unitTypeOptions}
        />

        <InputField
          label="Unit Address"
          name="unit_address"
          type="text"
          required
          value={formData.unit_address}
          onChange={(e) => handleChange('unit_address', e.target.value)}
          placeholder="Full address of the unit"
        />
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <InputField
          label="Bedrooms"
          name="bedrooms"
          type="number"
          min="0"
          value={formData.bedrooms || ''}
          onChange={(e) => handleChange('bedrooms', e.target.value ? parseInt(e.target.value) : undefined)}
          placeholder="0"
        />

        <InputField
          label="Bathrooms"
          name="bathrooms"
          type="number"
          min="0"
          step="0.5"
          value={formData.bathrooms || ''}
          onChange={(e) => handleChange('bathrooms', e.target.value ? parseFloat(e.target.value) : undefined)}
          placeholder="0"
        />

        <InputField
          label="Square Meters"
          name="square_meters"
          type="number"
          min="0"
          value={formData.square_meters || ''}
          onChange={(e) => handleChange('square_meters', e.target.value ? parseFloat(e.target.value) : undefined)}
          placeholder="0"
        />

        <InputField
          label="Parking Slots"
          name="parking_slots"
          type="number"
          min="0"
          value={formData.parking_slots || ''}
          onChange={(e) => handleChange('parking_slots', e.target.value ? parseInt(e.target.value) : undefined)}
          placeholder="0"
        />
      </div>
    </div>
  )
}
