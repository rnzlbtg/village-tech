'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Building2, Settings, DoorOpen, Users, Pencil, Eye } from 'lucide-react'
import { Tenant } from '@/lib/types/tenant'

interface TenantDetailTabsProps {
  tenant: Tenant
  adminUsers: any[]
  gates: any[]
  tenantId: string
}

export default function TenantDetailTabs({ tenant, adminUsers, gates, tenantId }: TenantDetailTabsProps) {
  const [activeTab, setActiveTab] = useState<'details' | 'properties' | 'gates' | 'admin-users' | 'settings'>('details')

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

        {/* Properties Tab */}
        {activeTab === 'properties' && (
          <div>
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-lg font-semibold text-gray-800">Properties</h2>
              <Link
                href={`/tenants/${tenantId}/properties/new`}
                className="bg-primary hover:bg-secondary text-white py-2 px-4 rounded-lg transition-colors"
              >
                Add Property
              </Link>
            </div>
            <div className="text-center py-12">
              <Building2 className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500">Properties management coming soon</p>
              <Link
                href={`/tenants/${tenantId}/properties`}
                className="text-primary hover:text-secondary text-sm mt-2 inline-block"
              >
                Go to Properties Page →
              </Link>
            </div>
          </div>
        )}

        {/* Gates Tab */}
        {activeTab === 'gates' && (
          <div>
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-lg font-semibold text-gray-800">Gates & Entrances</h2>
              <Link
                href={`/tenants/${tenantId}/gates/new`}
                className="bg-primary hover:bg-secondary text-white py-2 px-4 rounded-lg transition-colors"
              >
                Add Gate
              </Link>
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
                        <Link
                          href={`/tenants/${tenantId}/gates/${gate.id}`}
                          className="text-primary hover:text-secondary"
                        >
                          View
                        </Link>
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
              <Link
                href={`/tenants/${tenantId}/admin-users/new`}
                className="bg-primary hover:bg-secondary text-white py-2 px-4 rounded-lg flex items-center transition-colors"
              >
                <Users className="h-4 w-4 mr-2" />
                Add Admin User
              </Link>
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
                        <Link
                          href={`/tenants/${tenantId}/admin-users/${user.id}`}
                          className="text-primary hover:text-secondary"
                        >
                          View
                        </Link>
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
            <h2 className="text-lg font-semibold text-gray-800 mb-6">Association Settings</h2>
            <div className="text-center py-12">
              <Settings className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500">Settings management coming soon</p>
              <Link
                href={`/tenants/${tenantId}/settings`}
                className="text-primary hover:text-secondary text-sm mt-2 inline-block"
              >
                Go to Settings Page →
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
