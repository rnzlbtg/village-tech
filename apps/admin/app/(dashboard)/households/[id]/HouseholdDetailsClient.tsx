'use client'

import { useState } from 'react'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { AddMemberModal } from '@/components/household-members/AddMemberModal'

interface HouseholdDetailsClientProps {
  household: any
}

export function HouseholdDetailsClient({ household }: HouseholdDetailsClientProps) {
  const [showAddMemberModal, setShowAddMemberModal] = useState(false)

  return (
    <>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center gap-4">
          <Link href="/households" className="flex items-center text-gray-600 hover:text-gray-900">
            <ArrowLeft className="h-5 w-5" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{household.household_name}</h1>
            <p className="text-gray-600 mt-1">Household details and members</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main Details */}
          <div className="lg:col-span-2 space-y-6">
            {/* Household Information */}
            <div className="bg-white rounded-lg shadow">
              <div className="p-6 border-b">
                <h2 className="text-lg font-semibold text-gray-800">Household Information</h2>
              </div>
              <div className="p-6 space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-600">Household Name</p>
                    <p className="font-medium">{household.household_name}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Status</p>
                    <span
                      className={`inline-block px-2 py-1 text-xs rounded-full ${
                        household.status === 'active'
                          ? 'bg-green-100 text-green-800'
                          : household.status === 'inactive'
                          ? 'bg-gray-100 text-gray-800'
                          : 'bg-yellow-100 text-yellow-800'
                      }`}
                    >
                      {household.status}
                    </span>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Move-In Date</p>
                    <p className="font-medium">
                      {household.move_in_date
                        ? new Date(household.move_in_date).toLocaleDateString()
                        : 'N/A'}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Move-Out Date</p>
                    <p className="font-medium">
                      {household.move_out_date
                        ? new Date(household.move_out_date).toLocaleDateString()
                        : 'N/A'}
                    </p>
                  </div>
                </div>

                {household.notes && (
                  <div>
                    <p className="text-sm text-gray-600">Notes</p>
                    <p className="mt-1">{household.notes}</p>
                  </div>
                )}
              </div>
            </div>

            {/* Residence Unit */}
            {household.residence_unit && (
              <div className="bg-white rounded-lg shadow">
                <div className="p-6 border-b">
                  <h2 className="text-lg font-semibold text-gray-800">Residence Unit</h2>
                </div>
                <div className="p-6 space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <p className="text-sm text-gray-600">Property</p>
                      <p className="font-medium">{household.residence_unit.property?.name}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Unit Number</p>
                      <p className="font-medium">{household.residence_unit.unit_number}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Unit Type</p>
                      <p className="font-medium capitalize">{household.residence_unit.unit_type}</p>
                    </div>
                    {household.residence_unit.address && (
                      <div className="col-span-2">
                        <p className="text-sm text-gray-600">Address</p>
                        <p className="font-medium">{household.residence_unit.address}</p>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Household Members */}
            <div className="bg-white rounded-lg shadow">
              <div className="p-6 border-b flex justify-between items-center">
                <h2 className="text-lg font-semibold text-gray-800">Household Members</h2>
                <button
                  onClick={() => setShowAddMemberModal(true)}
                  className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-secondary transition-colors text-sm"
                >
                  Add Member
                </button>
              </div>
              <div className="p-6">
                {household.household_members && household.household_members.length > 0 ? (
                  <div className="space-y-4">
                    {household.household_members.map((member: any) => (
                      <div
                        key={member.id}
                        className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50"
                      >
                        <div className="flex-1">
                          <div className="flex items-center gap-3">
                            <div>
                              <p className="font-medium">
                                {member.first_name} {member.last_name}
                                {member.is_primary_contact && (
                                  <span className="ml-2 text-xs bg-blue-100 text-blue-800 px-2 py-0.5 rounded">
                                    Primary Contact
                                  </span>
                                )}
                              </p>
                              <p className="text-sm text-gray-600 capitalize">{member.relationship}</p>
                            </div>
                          </div>
                          {(member.email || member.phone_number) && (
                            <div className="mt-2 text-sm text-gray-600">
                              {member.email && <p>Email: {member.email}</p>}
                              {member.phone_number && <p>Phone: {member.phone_number}</p>}
                            </div>
                          )}
                        </div>
                        <Link
                          href={`/households/${household.id}/members/${member.id}`}
                          className="text-primary hover:text-secondary text-sm"
                        >
                          View
                        </Link>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <p className="text-gray-500 mb-4">No household members yet</p>
                    <button
                      onClick={() => setShowAddMemberModal(true)}
                      className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-secondary transition-colors text-sm"
                    >
                      Add First Member
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Quick Actions */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="font-semibold text-gray-800 mb-4">Quick Actions</h3>
              <div className="space-y-2">
                <Link
                  href={`/households/${household.id}/edit`}
                  className="block w-full px-4 py-2 text-center border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
                >
                  Edit Household
                </Link>
                <Link
                  href={`/stickers?household=${household.id}`}
                  className="block w-full px-4 py-2 text-center border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
                >
                  View Sticker Requests
                </Link>
                <Link
                  href={`/permits?household=${household.id}`}
                  className="block w-full px-4 py-2 text-center border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
                >
                  View Permits
                </Link>
              </div>
            </div>

            {/* Stats */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="font-semibold text-gray-800 mb-4">Statistics</h3>
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-gray-600">Total Members</span>
                  <span className="font-semibold">
                    {household.household_members?.length || 0}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Created</span>
                  <span className="font-semibold">
                    {new Date(household.created_at).toLocaleDateString()}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Add Member Modal */}
      <AddMemberModal
        isOpen={showAddMemberModal}
        onClose={() => setShowAddMemberModal(false)}
        householdId={household.id}
      />
    </>
  )
}