'use client'

import { useState } from 'react'
import { InputField } from '@/components/shared/FormField'

interface HouseholdHeadFormProps {
  onChange?: (data: HouseholdHeadFormData) => void
  initialData?: Partial<HouseholdHeadFormData>
}

export interface HouseholdHeadFormData {
  first_name: string
  last_name: string
  email: string
  phone_number: string
  date_of_birth?: string
  password: string
}

export default function HouseholdHeadForm({ onChange, initialData }: HouseholdHeadFormProps) {
  const [formData, setFormData] = useState<HouseholdHeadFormData>({
    first_name: initialData?.first_name || '',
    last_name: initialData?.last_name || '',
    email: initialData?.email || '',
    phone_number: initialData?.phone_number || '',
    date_of_birth: initialData?.date_of_birth || '',
    password: initialData?.password || '',
  })

  const handleChange = (field: keyof HouseholdHeadFormData, value: string) => {
    const updatedData = { ...formData, [field]: value }
    setFormData(updatedData)
    onChange?.(updatedData)
  }

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold text-gray-800 border-b pb-2">
        Household Head Information
      </h2>
      <p className="text-sm text-gray-600">
        This person will be able to log in to the residence app using these credentials
      </p>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <InputField
          label="First Name"
          name="first_name"
          type="text"
          required
          value={formData.first_name}
          onChange={(e) => handleChange('first_name', e.target.value)}
          placeholder="Juan"
        />

        <InputField
          label="Last Name"
          name="last_name"
          type="text"
          required
          value={formData.last_name}
          onChange={(e) => handleChange('last_name', e.target.value)}
          placeholder="Dela Cruz"
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <InputField
          label="Email Address"
          name="email"
          type="email"
          required
          value={formData.email}
          onChange={(e) => handleChange('email', e.target.value)}
          placeholder="juan@example.com"
          helpText="Used for login and notifications"
        />

        <InputField
          label="Phone Number"
          name="phone_number"
          type="tel"
          required
          value={formData.phone_number}
          onChange={(e) => handleChange('phone_number', e.target.value)}
          placeholder="+63 912 345 6789"
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <InputField
          label="Date of Birth"
          name="date_of_birth"
          type="date"
          value={formData.date_of_birth}
          onChange={(e) => handleChange('date_of_birth', e.target.value)}
          helpText="Optional"
        />

        <InputField
          label="Temporary Password"
          name="password"
          type="password"
          required
          value={formData.password}
          onChange={(e) => handleChange('password', e.target.value)}
          placeholder="Min. 6 characters"
          helpText="Simple temporary password - household head will change it on first login"
        />
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p className="text-sm text-blue-800">
          <strong>📧 Welcome Email:</strong> The household head will receive an email with their login credentials (temporary password). They will be required to change their password on first login for security.
        </p>
      </div>

      <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
        <p className="text-sm text-amber-800">
          <strong>⚠️ Security Note:</strong> Use a simple temporary password (e.g., "welcome123"). The household head will be forced to set a strong password after their first login to the residence app.
        </p>
      </div>
    </div>
  )
}
