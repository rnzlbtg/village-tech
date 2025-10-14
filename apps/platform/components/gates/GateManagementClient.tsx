'use client'

import { useState, useEffect } from 'react'
import { Plus, Shield, MapPin, Clock, Wifi, Edit, Trash2, AlertCircle, X } from 'lucide-react'
import { Tenant } from '@/lib/types/tenant'
import { Gate } from '@/lib/types/gate'
import { getGates, deleteGate } from '@/lib/actions/gate'
import GateForm from './GateForm'

interface GateManagementClientProps {
  tenants: Tenant[]
}

export default function GateManagementClient({ tenants }: GateManagementClientProps) {
  const [selectedTenant, setSelectedTenant] = useState<string>(tenants[0]?.id || '')
  const [gates, setGates] = useState<Gate[]>([])
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'gates' | 'rfid' | 'schedules'>('gates')
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [editingGate, setEditingGate] = useState<Gate | null>(null)

  useEffect(() => {
    if (selectedTenant) {
      loadGates()
    }
  }, [selectedTenant])

  const loadGates = async () => {
    setLoading(true)
    try {
      const data = await getGates(selectedTenant)
      setGates(data)
    } catch (error) {
      console.error('Failed to load gates:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteGate = async (gateId: string) => {
    if (!confirm('Are you sure you want to delete this gate?')) return

    try {
      await deleteGate(gateId)
      await loadGates()
    } catch (error) {
      console.error('Failed to delete gate:', error)
      alert('Failed to delete gate')
    }
  }

  const openCreateDialog = () => {
    setEditingGate(null)
    setIsCreateDialogOpen(true)
  }

  const openEditDialog = (gate: Gate) => {
    setEditingGate(gate)
    setIsCreateDialogOpen(true)
  }

  const closeDialog = () => {
    setIsCreateDialogOpen(false)
    setEditingGate(null)
  }

  const handleSuccess = () => {
    closeDialog()
    loadGates()
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'bg-green-100 text-green-800'
      case 'maintenance':
        return 'bg-red-100 text-red-800'
      case 'closed':
        return 'bg-gray-100 text-gray-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'vehicle':
        return '🚗'
      case 'pedestrian':
        return '🚶'
      case 'service':
        return '🚛'
      default:
        return '🚪'
    }
  }

  const selectedTenantName = tenants.find(t => t.id === selectedTenant)?.name || ''

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Gate Management</h1>
          <p className="text-gray-600 mt-1">
            Configure and monitor community entrance points and access control
          </p>
        </div>
      </div>

      {/* Tenant Selection */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b">
          <h2 className="text-lg font-semibold text-gray-800 mb-1">Select Community</h2>
          <p className="text-sm text-gray-600">
            Choose a community to manage its gates and entrance points
          </p>
        </div>
        <div className="p-6">
          <div className="w-full md:w-[300px]">
            <label htmlFor="tenant-select" className="block text-sm font-medium text-gray-700 mb-2">
              Community
            </label>
            <select
              id="tenant-select"
              value={selectedTenant}
              onChange={(e) => setSelectedTenant(e.target.value)}
              className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary"
            >
              {tenants.map(tenant => (
                <option key={tenant.id} value={tenant.id}>
                  {tenant.name}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {selectedTenant && (
        <>
          {/* Tabs */}
          <div className="bg-white rounded-lg shadow">
            <div className="border-b">
              <div className="flex space-x-4 px-6">
                <button
                  onClick={() => setActiveTab('gates')}
                  className={`py-4 px-2 border-b-2 font-medium text-sm transition-colors ${
                    activeTab === 'gates'
                      ? 'border-primary text-primary'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  Gates & Entrances
                </button>
                <button
                  onClick={() => setActiveTab('rfid')}
                  className={`py-4 px-2 border-b-2 font-medium text-sm transition-colors ${
                    activeTab === 'rfid'
                      ? 'border-primary text-primary'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  RFID Readers
                </button>
                <button
                  onClick={() => setActiveTab('schedules')}
                  className={`py-4 px-2 border-b-2 font-medium text-sm transition-colors ${
                    activeTab === 'schedules'
                      ? 'border-primary text-primary'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  Operating Schedules
                </button>
              </div>
            </div>

            {/* Gates Tab */}
            {activeTab === 'gates' && (
              <div className="p-6">
                <div className="flex justify-between items-center mb-6">
                  <div>
                    <h2 className="text-lg font-semibold text-gray-800">
                      Gates & Entrances - {selectedTenantName}
                    </h2>
                    <p className="text-sm text-gray-600">
                      Manage entrance points and their configurations
                    </p>
                  </div>
                  <button
                    onClick={openCreateDialog}
                    className="bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg flex items-center transition-colors"
                  >
                    <Plus className="h-4 w-4 mr-2" />
                    Add Gate
                  </button>
                </div>

                {loading ? (
                  <div className="text-center py-12">
                    <p className="text-gray-500">Loading gates...</p>
                  </div>
                ) : gates.length === 0 ? (
                  <div className="text-center py-12">
                    <p className="text-gray-500 text-lg">No gates found</p>
                    <p className="text-gray-400 text-sm mt-2">
                      Add your first gate to get started
                    </p>
                  </div>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                      <thead className="bg-gray-50">
                        <tr>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Gate Name
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Type
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Status
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Operating Hours
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            RFID Reader
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Actions
                          </th>
                        </tr>
                      </thead>
                      <tbody className="bg-white divide-y divide-gray-200">
                        {gates.map((gate) => (
                          <tr key={gate.id} className="hover:bg-gray-50">
                            <td className="px-6 py-4">
                              <div className="flex items-center space-x-3">
                                <span className="text-2xl">{getTypeIcon(gate.gate_type)}</span>
                                <div>
                                  <p className="font-medium text-gray-900">{gate.name}</p>
                                  {gate.location && (
                                    <p className="text-sm text-gray-500 flex items-center">
                                      <MapPin className="h-3 w-3 mr-1" />
                                      {gate.location}
                                    </p>
                                  )}
                                </div>
                              </div>
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap capitalize text-sm text-gray-900">
                              {gate.gate_type}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap">
                              <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(gate.status || 'active')}`}>
                                {gate.status === 'maintenance' && <AlertCircle className="h-3 w-3 mr-1" />}
                                {gate.status ? gate.status.charAt(0).toUpperCase() + gate.status.slice(1) : 'Active'}
                              </span>
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              <div className="flex items-center space-x-1">
                                <Clock className="h-3 w-3" />
                                <span>{gate.operating_hours || '24/7'}</span>
                              </div>
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              <div className="flex items-center space-x-1">
                                <Wifi className="h-3 w-3" />
                                <span>{gate.rfid_reader_id || 'N/A'}</span>
                              </div>
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                              <div className="flex space-x-2">
                                <button
                                  onClick={() => openEditDialog(gate)}
                                  className="text-primary hover:text-secondary p-2 rounded hover:bg-gray-100"
                                  title="Edit gate"
                                >
                                  <Edit className="h-4 w-4" />
                                </button>
                                <button
                                  onClick={() => handleDeleteGate(gate.id)}
                                  className="text-red-600 hover:text-red-800 p-2 rounded hover:bg-gray-100"
                                  title="Delete gate"
                                >
                                  <Trash2 className="h-4 w-4" />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            )}

            {/* RFID Readers Tab */}
            {activeTab === 'rfid' && (
              <div className="p-6">
                <div className="mb-6">
                  <h2 className="text-lg font-semibold text-gray-800">RFID Reader Configuration</h2>
                  <p className="text-sm text-gray-600">
                    Manage RFID readers and their assignments to gates
                  </p>
                </div>

                <div className="space-y-4">
                  {gates.map((gate) => (
                    <div key={gate.id} className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="flex items-center space-x-3">
                        <Wifi className="h-5 w-5 text-gray-400" />
                        <div>
                          <p className="font-medium text-gray-900">{gate.rfid_reader_id || 'No RFID Reader'}</p>
                          <p className="text-sm text-gray-500">Assigned to: {gate.name}</p>
                        </div>
                      </div>
                      <div className="flex items-center space-x-4">
                        <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                          gate.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                        }`}>
                          {gate.status === 'active' ? 'Online' : 'Offline'}
                        </span>
                        <button className="px-3 py-1 text-sm border border-gray-300 rounded-md hover:bg-gray-50">
                          Configure
                        </button>
                      </div>
                    </div>
                  ))}

                  <button className="w-full sm:w-auto bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg flex items-center justify-center transition-colors mt-4">
                    <Plus className="h-4 w-4 mr-2" />
                    Add RFID Reader
                  </button>
                </div>
              </div>
            )}

            {/* Operating Schedules Tab */}
            {activeTab === 'schedules' && (
              <div className="p-6">
                <div className="mb-6">
                  <h2 className="text-lg font-semibold text-gray-800">Operating Schedules</h2>
                  <p className="text-sm text-gray-600">
                    Configure operating hours and special schedules for gates
                  </p>
                </div>

                <div className="space-y-6">
                  {gates.map((gate) => (
                    <div key={gate.id} className="border rounded-lg p-6">
                      <div className="flex items-center justify-between mb-4">
                        <div className="flex items-center space-x-2">
                          <Shield className="h-5 w-5 text-gray-400" />
                          <h3 className="font-medium text-gray-900">{gate.name}</h3>
                        </div>
                        <span className="px-2 py-1 text-xs border border-gray-300 rounded-md">
                          {gate.operating_hours || '24/7'}
                        </span>
                      </div>

                      <div className="grid gap-4 md:grid-cols-2">
                        <div className="space-y-3">
                          <label className="block text-sm font-medium text-gray-700">Regular Schedule</label>
                          <div className="grid grid-cols-2 gap-2">
                            <div>
                              <label className="block text-xs text-gray-600 mb-1">Open Time</label>
                              <input
                                type="time"
                                defaultValue="06:00"
                                className="block w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                              />
                            </div>
                            <div>
                              <label className="block text-xs text-gray-600 mb-1">Close Time</label>
                              <input
                                type="time"
                                defaultValue="22:00"
                                className="block w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                              />
                            </div>
                          </div>
                        </div>

                        <div className="space-y-3">
                          <label className="block text-sm font-medium text-gray-700">Special Settings</label>
                          <div className="space-y-2">
                            <div className="flex items-center justify-between">
                              <label className="text-sm text-gray-700">24/7 Operation</label>
                              <input type="checkbox" className="h-4 w-4 text-primary border-gray-300 rounded focus:ring-primary" />
                            </div>
                            <div className="flex items-center justify-between">
                              <label className="text-sm text-gray-700">Holiday Hours</label>
                              <input type="checkbox" className="h-4 w-4 text-primary border-gray-300 rounded focus:ring-primary" />
                            </div>
                            <div className="flex items-center justify-between">
                              <label className="text-sm text-gray-700">Emergency Override</label>
                              <input type="checkbox" className="h-4 w-4 text-primary border-gray-300 rounded focus:ring-primary" />
                            </div>
                          </div>
                        </div>
                      </div>

                      <div className="flex justify-end mt-4">
                        <button className="px-4 py-2 text-sm border border-gray-300 rounded-md hover:bg-gray-50">
                          Update Schedule
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </>
      )}

      {/* Create/Edit Gate Modal */}
      {isCreateDialogOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
              <h2 className="text-xl font-bold text-gray-800">
                {editingGate ? 'Edit Gate' : 'Add New Gate'}
              </h2>
              <button
                onClick={closeDialog}
                className="text-gray-500 hover:text-gray-700 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>
            <div className="p-6">
              <GateForm
                tenantId={selectedTenant}
                initialData={editingGate || undefined}
                mode={editingGate ? 'edit' : 'create'}
                onSuccess={handleSuccess}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
