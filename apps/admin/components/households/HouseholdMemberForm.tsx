'use client'

import { useState } from 'react'
import { InputField, SelectField } from '@/components/shared/FormField'
import { Plus, Trash2 } from 'lucide-react'

export interface HouseholdMember {
  id?: string
  first_name: string
  last_name: string
  date_of_birth?: string
  relationship: string
  phone_number?: string
}

interface HouseholdMemberFormProps {
  onChange?: (members: HouseholdMember[]) => void
  initialMembers?: HouseholdMember[]
}

const relationshipOptions = [
  { value: 'spouse', label: 'Spouse' },
  { value: 'child', label: 'Child' },
  { value: 'parent', label: 'Parent' },
  { value: 'sibling', label: 'Sibling' },
  { value: 'grandparent', label: 'Grandparent' },
  { value: 'grandchild', label: 'Grandchild' },
  { value: 'other_relative', label: 'Other Relative' },
  { value: 'tenant', label: 'Tenant' },
  { value: 'helper', label: 'Helper' },
  { value: 'other', label: 'Other' },
]

export default function HouseholdMemberForm({
  onChange,
  initialMembers = [],
}: HouseholdMemberFormProps) {
  const [members, setMembers] = useState<HouseholdMember[]>(
    initialMembers.length > 0
      ? initialMembers
      : [{ first_name: '', last_name: '', relationship: 'spouse' }]
  )

  const updateMember = (index: number, field: keyof HouseholdMember, value: string) => {
    const updatedMembers = [...members]
    updatedMembers[index] = { ...updatedMembers[index], [field]: value }
    setMembers(updatedMembers)
    onChange?.(updatedMembers)
  }

  const addMember = () => {
    const newMembers = [...members, { first_name: '', last_name: '', relationship: 'child' }]
    setMembers(newMembers)
    onChange?.(newMembers)
  }

  const removeMember = (index: number) => {
    if (members.length > 1) {
      const updatedMembers = members.filter((_, i) => i !== index)
      setMembers(updatedMembers)
      onChange?.(updatedMembers)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-gray-800 border-b pb-2">
            Household Members (Optional)
          </h2>
          <p className="text-sm text-gray-600 mt-1">
            Add other people living in this household
          </p>
        </div>
        <button
          type="button"
          onClick={addMember}
          className="inline-flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
        >
          <Plus className="h-4 w-4" />
          Add Member
        </button>
      </div>

      <div className="space-y-6">
        {members.map((member, index) => (
          <div
            key={index}
            className="relative p-4 border border-gray-200 rounded-lg bg-gray-50 space-y-4"
          >
            {/* Remove button */}
            {members.length > 1 && (
              <button
                type="button"
                onClick={() => removeMember(index)}
                className="absolute top-2 right-2 p-2 text-red-600 hover:bg-red-50 rounded-md transition-colors"
                title="Remove member"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            )}

            <div className="text-sm font-medium text-gray-700 mb-2">Member #{index + 1}</div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <InputField
                label="First Name"
                name={`member_${index}_first_name`}
                type="text"
                value={member.first_name}
                onChange={(e) => updateMember(index, 'first_name', e.target.value)}
                placeholder="First name"
              />

              <InputField
                label="Last Name"
                name={`member_${index}_last_name`}
                type="text"
                value={member.last_name}
                onChange={(e) => updateMember(index, 'last_name', e.target.value)}
                placeholder="Last name"
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <SelectField
                label="Relationship to Head"
                name={`member_${index}_relationship`}
                value={member.relationship}
                onChange={(e) => updateMember(index, 'relationship', e.target.value)}
                options={relationshipOptions}
              />

              <InputField
                label="Date of Birth"
                name={`member_${index}_date_of_birth`}
                type="date"
                value={member.date_of_birth || ''}
                onChange={(e) => updateMember(index, 'date_of_birth', e.target.value)}
              />

              <InputField
                label="Phone Number"
                name={`member_${index}_phone_number`}
                type="tel"
                value={member.phone_number || ''}
                onChange={(e) => updateMember(index, 'phone_number', e.target.value)}
                placeholder="Optional"
              />
            </div>
          </div>
        ))}
      </div>

      {members.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          <p>No household members added yet.</p>
          <button
            type="button"
            onClick={addMember}
            className="mt-2 text-primary hover:underline"
          >
            Add first member
          </button>
        </div>
      )}
    </div>
  )
}
