'use client'

import { useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import {
  Building2,
  Settings,
  DoorOpen,
  Users,
  Pencil,
  Eye,
  X,
  Plus,
  ChevronDown,
  ChevronUp,
} from 'lucide-react'
import { Tenant } from '@/lib/types/tenant'
import { Gate } from '@/lib/types/gate'
import { Property, PropertyWithCounts } from '@/lib/types/property'
import GateForm from '@/components/gates/GateForm'
import AdminUserForm from '@/components/admin-users/AdminUserForm'
import AssociationSettingsForm from '@/components/association-settings/AssociationSettingsForm'

interface TenantDetailTabsProps {
  tenant: Tenant
  adminUsers: any[]
  gates: Gate[]
  properties: (Property | PropertyWithCounts)[]
  tenantId: string
  associationSettings?: any
}

export default function TenantDetailTabs({
  tenant,
  adminUsers,
  gates,
  properties,
  tenantId,
  associationSettings,
}: TenantDetailTabsProps) {
  const router = useRouter()
  const [activeTab, setActiveTab] = useState<
    'details' | 'properties' | 'gates' | 'admin-users' | 'settings'
  >('details')
  const [isGateModalOpen, setIsGateModalOpen] = useState(false)
  const [editingGate, setEditingGate] = useState<Gate | null>(null)
  const [isAdminUserModalOpen, setIsAdminUserModalOpen] = useState(false)
  const [editingAdminUser, setEditingAdminUser] = useState<any | null>(null)
  const [isPropertyModalOpen, setIsPropertyModalOpen] = useState(false)
  const [editingProperty, setEditingProperty] = useState<Property | null>(null)
  const [isSettingsExpanded, setIsSettingsExpanded] = useState(true)

  const openGateModal = (gate?: Gate) => {
    setEditingGate(gate || null)
    setIsGateModalOpen(true)
  }

  const closeGateModal = () => {
    setIsGateModalOpen(false)
    setEditingGate(null)
    router.refresh()
  }

  const openAdminUserModal = (user?: any) => {
    setEditingAdminUser(user || null)
    setIsAdminUserModalOpen(true)
  }

  const closeAdminUserModal = () => {
    setIsAdminUserModalOpen(false)
    setEditingAdminUser(null)
    router.refresh()
  }

  const openPropertyModal = (property?: Property) => {
    setEditingProperty(property || null)
    setIsPropertyModalOpen(true)
  }

  const closePropertyModal = () => {
    setIsPropertyModalOpen(false)
    setEditingProperty(null)
    router.refresh()
  }

  return (
    <div className="bg-white rounded-lg shadow">
      {/* Tabs Navigation */}
      <div className="border-b">
        <div className="flex overflow-x-auto">
          <button
            className={`px-6 py-3 font-medium text-sm focus:outline-none whitespace-nowrap ${
              activeTab === 'details'
                ? 'border-b-2 border-primary text-primary'
                : 'text-gray-500 hover:text-gray-700'
            }`}
            onClick={() => setActiveTab('details')}
          >
            <div className="flex items-center">
              <Eye className="h-4 w-4 mr-2" />
              Community Details
            </div>
          </button>
          <button
            className={`px-6 py-3 font-medium text-sm focus:outline-none whitespace-nowrap ${
              activeTab === 'properties'
                ? 'border-b-2 border-primary text-primary'
                : 'text-gray-500 hover:text-gray-700'
            }`}
            onClick={() => setActiveTab('properties')}
          >
            <div className="flex items-center">
              <Building2 className="h-4 w-4 mr-2" />
              Properties
            </div>
          </button>
          <button
            className={`px-6 py-3 font-medium text-sm focus:outline-none whitespace-nowrap ${
              activeTab === 'gates'
                ? 'border-b-2 border-primary text-primary'
                : 'text-gray-500 hover:text-gray-700'
            }`}
            onClick={() => setActiveTab('gates')}
          >
            <div className="flex items-center">
              <DoorOpen className="h-4 w-4 mr-2" />
              Gates
            </div>
          </button>
          <button
            className={`px-6 py-3 font-medium text-sm focus:outline-none whitespace-nowrap ${
              activeTab === 'admin-users'
                ? 'border-b-2 border-primary text-primary'
                : 'text-gray-500 hover:text-gray-700'
            }`}
            onClick={() => setActiveTab('admin-users')}
          >
            <div className="flex items-center">
              <Users className="h-4 w-4 mr-2" />
              Admin Users
            </div>
          </button>
          <button
            className={`px-6 py-3 font-medium text-sm focus:outline-none whitespace-nowrap ${
              activeTab === 'settings'
                ? 'border-b-2 border-primary text-primary'
                : 'text-gray-500 hover:text-gray-700'
            }`}
            onClick={() => setActiveTab('settings')}
          >
            <div className="flex items-center">
              <Settings className="h-4 w-4 mr-2" />
              Settings
            </div>
          </button>
        </div>
      </div>

      {/* Tab Content */}
      <div className="p-6">
        {/* Community Details Tab */}
        {activeTab === 'details' && (
          <div>
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-lg font-semibold text-gray-800">Community Information</h2>
              <Link
                href={`/tenants/${tenantId}/edit`}
                className="flex items-center text-primary hover:text-secondary transition-colors"
              >
                <Pencil className="h-4 w-4 mr-1" />
                Edit
              </Link>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <p className="text-sm text-gray-500">Location</p>
                <p className="font-medium text-gray-800">
                  {tenant.city || '-'}
                  {tenant.state && `, ${tenant.state}`}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Total Units</p>
                <p className="font-medium text-gray-800">{tenant.max_residences || '-'}</p>
              </div>
              <div className="md:col-span-2">
                <p className="text-sm text-gray-500">Address</p>
                <p className="font-medium text-gray-800">{tenant.address}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Country</p>
                <p className="font-medium text-gray-800">{tenant.country || '-'}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Postal Code</p>
                <p className="font-medium text-gray-800">{tenant.postal_code || '-'}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Subscription Status</p>
                <p className="font-medium">
                  <span
                    className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      tenant.subscription_status === 'active'
                        ? 'bg-green-100 text-green-800'
                        : tenant.subscription_status === 'trial'
                          ? 'bg-amber-100 text-amber-800'
                          : tenant.subscription_status === 'suspended'
                            ? 'bg-red-100 text-red-800'
                            : 'bg-gray-100 text-gray-800'
                    }`}
                  >
                    {tenant.subscription_status.charAt(0).toUpperCase() +
                      tenant.subscription_status.slice(1)}
                  </span>
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Created Date</p>
                <p className="font-medium text-gray-800">
                  {new Date(tenant.created_at).toLocaleDateString()}
                </p>
              </div>
              {tenant.contact_name && (
                <div>
                  <p className="text-sm text-gray-500">Contact Name</p>
                  <p className="font-medium text-gray-800">{tenant.contact_name}</p>
                </div>
              )}
              {tenant.contact_email && (
                <div>
                  <p className="text-sm text-gray-500">Contact Email</p>
                  <p className="font-medium text-gray-800">{tenant.contact_email}</p>
                </div>
              )}
              {tenant.contact_phone && (
                <div>
                  <p className="text-sm text-gray-500">Contact Phone</p>
                  <p className="font-medium text-gray-800">{tenant.contact_phone}</p>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Properties Tab - Read Only */}
        {activeTab === 'properties' && (
          <div>
            <div className="mb-6">
              <h2 className="text-lg font-semibold text-gray-800 mb-2">Properties Overview</h2>
              <p className="text-sm text-gray-500">
                Property management is handled in the Admin Portal by tenant administrators.
              </p>
            </div>
            {properties.length > 0 ? (
              <div className="border rounded-lg overflow-hidden">
                <table className="w-full">
                  <thead className="bg-gray-50 border-b">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Property Name
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Address
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Type
                      </th>
                      <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Units
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {properties.map((property: any) => (
                      <tr key={property.id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="text-sm font-medium text-gray-900">{property.name}</div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="text-sm text-gray-700">{property.address || '-'}</div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="text-sm text-gray-700 capitalize">
                            {property.property_type || '-'}
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-right">
                          <div className="text-sm text-gray-700">
                            {property.residence_units?.[0]?.count || 0}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <div className="text-center py-12 border rounded-lg">
                <Building2 className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-500">No properties yet</p>
                <p className="text-sm text-gray-400 mt-2">
                  Tenant administrators will create properties through the Admin Portal.
                </p>
              </div>
            )}
          </div>
        )}

        {/* Gates Tab */}
        {activeTab === 'gates' && (
          <div>
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-lg font-semibold text-gray-800">Gates & Entrances</h2>
              <button
                onClick={() => openGateModal()}
                className="bg-primary hover:bg-secondary text-white py-2 px-4 rounded-lg transition-colors flex items-center"
              >
                <Plus className="h-4 w-4 mr-2" />
                Add Gate
              </button>
            </div>
            {gates.length > 0 ? (
              <table className="min-w-full divide-y divide-gray-200">
                <thead>
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Gate Name
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Location
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Type
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {gates.map((gate) => (
                    <tr key={gate.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{gate.name}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-500">{gate.location || '-'}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-500 capitalize">
                          {gate.gate_type?.replace('_', ' ') || '-'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span
                          className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                            gate.operational_status === 'active'
                              ? 'bg-green-100 text-green-800'
                              : gate.operational_status === 'maintenance'
                                ? 'bg-amber-100 text-amber-800'
                                : 'bg-gray-100 text-gray-800'
                          }`}
                        >
                          {gate.operational_status?.charAt(0).toUpperCase() +
                            gate.operational_status?.slice(1)}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button
                          onClick={() => openGateModal(gate)}
                          className="text-primary hover:text-secondary"
                        >
                          Edit
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <div className="text-center py-12">
                <DoorOpen className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-500">No gates found</p>
              </div>
            )}
          </div>
        )}

        {/* Admin Users Tab */}
        {activeTab === 'admin-users' && (
          <div>
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-lg font-semibold text-gray-800">Admin Users</h2>
              <button
                onClick={() => openAdminUserModal()}
                className="bg-primary hover:bg-secondary text-white py-2 px-4 rounded-lg flex items-center transition-colors"
              >
                <Users className="h-4 w-4 mr-2" />
                Add Admin User
              </button>
            </div>
            {adminUsers.length > 0 ? (
              <table className="min-w-full divide-y divide-gray-200">
                <thead>
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Name
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Role
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Email
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {adminUsers.map((user) => (
                    <tr key={user.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">
                          {user.first_name} {user.last_name}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-500">
                          {user.role === 'admin_head' ? 'Admin Head' : 'Admin Officer'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-500">{user.email}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span
                          className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                            user.is_active
                              ? 'bg-green-100 text-green-800'
                              : 'bg-gray-100 text-gray-800'
                          }`}
                        >
                          {user.is_active ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button
                          onClick={() => openAdminUserModal(user)}
                          className="text-primary hover:text-secondary"
                        >
                          Edit
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <div className="text-center py-12">
                <Users className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-500">No admin users found</p>
              </div>
            )}
          </div>
        )}

        {/* Settings Tab */}
        {activeTab === 'settings' && (
          <div>
            <div
              className="flex justify-between items-center mb-6 cursor-pointer group"
              onClick={() => setIsSettingsExpanded(!isSettingsExpanded)}
            >
              <h2 className="text-lg font-semibold text-gray-800">Association Settings</h2>
              <button type="button" className="text-gray-500 hover:text-gray-700 transition-colors">
                {isSettingsExpanded ? (
                  <ChevronUp className="h-5 w-5" />
                ) : (
                  <ChevronDown className="h-5 w-5" />
                )}
              </button>
            </div>

            {isSettingsExpanded && (
              <div className="border rounded-lg p-6 bg-gray-50">
                <AssociationSettingsForm tenantId={tenantId} initialData={associationSettings} />
              </div>
            )}
          </div>
        )}
      </div>

      {/* Gate Modal */}
      {isGateModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            {/* Modal Header */}
            <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
              <h2 className="text-xl font-bold text-gray-800">
                {editingGate ? 'Edit Gate' : 'Add New Gate'}
              </h2>
              <button
                onClick={closeGateModal}
                className="text-gray-500 hover:text-gray-700 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6">
              <GateForm
                tenantId={tenantId}
                initialData={editingGate || undefined}
                mode={editingGate ? 'edit' : 'create'}
                onSuccess={closeGateModal}
              />
            </div>
          </div>
        </div>
      )}

      {/* Admin User Modal */}
      {isAdminUserModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            {/* Modal Header */}
            <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
              <h2 className="text-xl font-bold text-gray-800">
                {editingAdminUser ? 'Edit Admin User' : 'Add New Admin User'}
              </h2>
              <button
                onClick={closeAdminUserModal}
                className="text-gray-500 hover:text-gray-700 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6">
              <AdminUserForm
                tenantId={tenantId}
                initialData={editingAdminUser || undefined}
                mode={editingAdminUser ? 'edit' : 'create'}
                onSuccess={closeAdminUserModal}
              />
            </div>
          </div>
        </div>
      )}

      {/* Property Modal */}
      {isPropertyModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            {/* Modal Header */}
            <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
              <h2 className="text-xl font-bold text-gray-800">
                {editingProperty ? 'Edit Property' : 'Add New Property'}
              </h2>
              <button
                onClick={closePropertyModal}
                className="text-gray-500 hover:text-gray-700 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6">
              <PropertyForm
                tenantId={tenantId}
                initialData={editingProperty || undefined}
                mode={editingProperty ? 'edit' : 'create'}
                onSuccess={closePropertyModal}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
