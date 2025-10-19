'use client'

import React, { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createTenant } from '@/lib/actions/tenant'
import { createAdminUser } from '@/lib/actions/admin-user'
import { createGate } from '@/lib/actions/gate'
import { sendAdminWelcomeEmail } from '@/lib/email'
import { Info, ArrowLeft, Plus, X, AlertTriangle, RefreshCw, Eye, EyeOff } from 'lucide-react'
import { toast } from 'sonner'

interface Gate {
  id: number
  name: string
  location: string
  gate_type: string
}

export default function TenantWizardForm() {
  const router = useRouter()
  const [currentStep, setCurrentStep] = useState(1)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const [showPassword, setShowPassword] = useState(false)
  const [createdCredentials, setCreatedCredentials] = useState<{
    email: string
    password: string
    tenantName: string
  } | null>(null)
  const [emailSent, setEmailSent] = useState(false)

  const [formData, setFormData] = useState({
    name: '',
    address: '',
    city: '',
    state: '',
    country: 'Philippines',
    postal_code: '',
    contact_name: '',
    contact_email: '',
    contact_phone: '',
    subscription_status: 'active' as const,
    subscription_plan: '',
    max_users: '',
    max_residences: '',
  })

  const [gates, setGates] = useState<Gate[]>([
    {
      id: 1,
      name: '',
      location: '',
      gate_type: 'main',
    },
  ])

  const [adminUser, setAdminUser] = useState({
    email: '',
    password: '',
    first_name: '',
    last_name: '',
    phone_number: '',
    role: 'admin_head' as const,
  })

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target
    setFormData((prev) => ({ ...prev, [name]: value }))

    if (fieldErrors[name]) {
      setFieldErrors((prev) => {
        const newErrors = { ...prev }
        delete newErrors[name]
        return newErrors
      })
    }
  }

  const handleGateChange = (id: number, field: string, value: string) => {
    setGates((prev) => prev.map((gate) => (gate.id === id ? { ...gate, [field]: value } : gate)))

    if (fieldErrors[`gate-${id}-${field}`]) {
      setFieldErrors((prev) => {
        const newErrors = { ...prev }
        delete newErrors[`gate-${id}-${field}`]
        return newErrors
      })
    }
  }

  const addGate = () => {
    const newId = gates.length ? Math.max(...gates.map((g) => g.id)) + 1 : 1
    setGates((prev) => [
      ...prev,
      {
        id: newId,
        name: '',
        location: '',
        gate_type: 'pedestrian',
      },
    ])
  }

  const removeGate = (id: number) => {
    if (gates.length > 1) {
      setGates((prev) => prev.filter((gate) => gate.id !== id))
      setFieldErrors((prev) => {
        const newErrors = { ...prev }
        Object.keys(newErrors).forEach((key) => {
          if (key.startsWith(`gate-${id}`)) {
            delete newErrors[key]
          }
        })
        return newErrors
      })
    }
  }

  const handleAdminUserChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target
    setAdminUser((prev) => ({ ...prev, [name]: value }))

    if (fieldErrors[`admin-${name}`]) {
      setFieldErrors((prev) => {
        const newErrors = { ...prev }
        delete newErrors[`admin-${name}`]
        return newErrors
      })
    }
  }

  const generateTemporaryPassword = () => {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*'
    let password = ''
    for (let i = 0; i < 12; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length))
    }

    setAdminUser((prev) => ({ ...prev, password }))

    if (fieldErrors['admin-password']) {
      setFieldErrors((prev) => {
        const newErrors = { ...prev }
        delete newErrors['admin-password']
        return newErrors
      })
    }

    toast.success('Temporary password generated!', {
      description: 'A secure 12-character password has been created.',
    })
  }

  const togglePasswordVisibility = () => {
    setShowPassword((prev) => !prev)
  }

  const validateStep = (step: number) => {
    const newErrors: Record<string, string> = {}

    if (step === 1) {
      if (!formData.name.trim()) {
        newErrors.name = 'Community name is required'
      }
      if (!formData.address.trim()) {
        newErrors.address = 'Address is required'
      }
      if (formData.address.trim().length < 5) {
        newErrors.address = 'Address must be at least 5 characters'
      }
    }

    if (step === 2) {
      gates.forEach((gate) => {
        if (!gate.name.trim()) {
          newErrors[`gate-${gate.id}-name`] = 'Gate name is required'
        }
        if (!gate.location.trim()) {
          newErrors[`gate-${gate.id}-location`] = 'Gate location is required'
        }
      })
    }

    if (step === 3) {
      if (!adminUser.email.trim()) {
        newErrors['admin-email'] = 'Email is required'
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(adminUser.email)) {
        newErrors['admin-email'] = 'Invalid email format'
      }

      if (!adminUser.password.trim()) {
        newErrors['admin-password'] = 'Temporary password is required'
      } else if (adminUser.password.length < 6) {
        newErrors['admin-password'] = 'Temporary password must be at least 6 characters'
      }

      if (!adminUser.first_name.trim()) {
        newErrors['admin-first_name'] = 'First name is required'
      }

      if (!adminUser.last_name.trim()) {
        newErrors['admin-last_name'] = 'Last name is required'
      }
    }

    setFieldErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleNextStep = () => {
    if (validateStep(currentStep)) {
      setCurrentStep((prev) => prev + 1)
      window.scrollTo(0, 0)
    }
  }

  const handlePrevStep = () => {
    setCurrentStep((prev) => prev - 1)
    window.scrollTo(0, 0)
  }

  const handleSubmit = async () => {
    if (!validateStep(4)) {
      return
    }

    setIsSubmitting(true)

    const toastId = toast.loading('Creating community...')

    try {
      // Step 1: Create the tenant
      const tenantData = new FormData()
      Object.entries(formData).forEach(([key, value]) => {
        if (value) tenantData.append(key, value)
      })

      const tenantResult = await createTenant(tenantData)

      if (!tenantResult.success) {
        toast.error('Failed to create community', {
          id: toastId,
          description: tenantResult.error || 'An error occurred while creating the community',
        })
        setIsSubmitting(false)
        return
      }

      const tenantId = tenantResult.data?.id

      if (!tenantId) {
        toast.error('Failed to create community', {
          id: toastId,
          description: 'Could not retrieve community ID',
        })
        setIsSubmitting(false)
        return
      }

      // Step 2: Create the admin user for the tenant
      toast.loading('Creating admin user...', { id: toastId })

      const adminUserData = new FormData()
      adminUserData.append('tenant_id', tenantId)
      adminUserData.append('email', adminUser.email)
      adminUserData.append('password', adminUser.password)
      adminUserData.append('first_name', adminUser.first_name)
      adminUserData.append('last_name', adminUser.last_name)
      if (adminUser.phone_number) {
        adminUserData.append('phone_number', adminUser.phone_number)
      }
      adminUserData.append('role', adminUser.role)

      const adminUserResult = await createAdminUser(adminUserData)

      if (!adminUserResult.success) {
        toast.error('Failed to create admin user', {
          id: toastId,
          description: `Community created but admin user creation failed: ${adminUserResult.error || 'Unknown error'}`,
        })
        setIsSubmitting(false)
        return
      }

      // Step 2.5: Send welcome email to admin user
      toast.loading('Sending welcome email...', { id: toastId })

      const adminLoginUrl = `${process.env.NEXT_PUBLIC_ADMIN_APP_URL || 'http://localhost:3001'}/login`
      const emailResult = await sendAdminWelcomeEmail({
        email: adminUser.email,
        firstName: adminUser.first_name,
        lastName: adminUser.last_name,
        password: adminUser.password,
        tenantName: formData.name,
        adminLoginUrl,
      })

      if (!emailResult.success) {
        console.error('Email sending failed:', emailResult.error)
        // Don't fail the entire process if email fails, but log it
        toast.warning('Community created but email may not have been sent', {
          id: toastId,
          description: 'Please manually share the login credentials with the admin user.',
        })
      } else {
        toast.success('Welcome email sent!', {
          description: 'Admin user will receive their login credentials via email.',
        })
      }

      // Step 3: Create gates if any were added
      if (gates.length > 0) {
        toast.loading(`Creating ${gates.length} gate(s)...`, { id: toastId })

        let gatesCreated = 0
        let gateErrors: string[] = []

        for (const gate of gates) {
          const gateData = new FormData()
          gateData.append('tenant_id', String(tenantId))
          gateData.append('name', gate.name.trim())
          if (gate.location && gate.location.trim()) {
            gateData.append('location', gate.location.trim())
          }
          gateData.append('gate_type', gate.gate_type)
          gateData.append('operational_status', 'active')

          const gateResult = await createGate(gateData)

          if (gateResult.success) {
            gatesCreated++
          } else {
            console.error('Gate creation error:', gateResult.error)
            gateErrors.push(`${gate.name}: ${gateResult.error}`)
          }
        }

        // Show partial success if some gates failed
        if (gateErrors.length > 0 && gatesCreated > 0) {
          toast.warning('Community created with some issues', {
            id: toastId,
            description: `${gatesCreated} gate(s) created, ${gateErrors.length} failed`,
          })
        } else if (gateErrors.length > 0) {
          toast.warning('Community created but gates failed', {
            id: toastId,
            description: 'Gates were not created successfully',
          })
        }
      }

      // Step 4: Success - Store credentials and show success screen
      setCreatedCredentials({
        email: adminUser.email,
        password: adminUser.password,
        tenantName: formData.name,
      })
      setEmailSent(emailResult.success)

      toast.success('Community created successfully!', {
        id: toastId,
        description: emailResult.success
          ? 'Welcome email has been sent to the admin user.'
          : 'Admin user credentials are ready to share.',
      })

      setCurrentStep(5)
      setIsSubmitting(false)
    } catch (err) {
      toast.error('An unexpected error occurred', {
        id: toastId,
        description: err instanceof Error ? err.message : 'Please try again',
      })
      setIsSubmitting(false)
    }
  }

  const steps = [
    { number: 1, title: 'Community Information' },
    { number: 2, title: 'Gates & Entrances' },
    { number: 3, title: 'Admin User' },
    { number: 4, title: 'Review & Submit' },
    { number: 5, title: 'Success' },
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-2">
        <button
          onClick={() => router.push('/tenants')}
          className="text-gray-600 hover:text-gray-800"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <h1 className="text-2xl font-bold text-gray-800">Create New Residential Community</h1>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        {/* Progress Steps */}
        <div className="mb-8">
          <div className="w-full flex items-start">
            {steps.map((step, index) => (
              <React.Fragment key={step.number}>
                <div className="flex flex-col items-center">
                  <div
                    className={`flex items-center justify-center w-10 h-10 rounded-full ${
                      currentStep >= step.number
                        ? 'bg-primary text-white'
                        : 'bg-gray-200 text-gray-600'
                    }`}
                  >
                    {step.number}
                  </div>
                  <p
                    className={`text-sm mt-2 text-center whitespace-nowrap ${
                      currentStep === step.number ? 'font-medium text-primary' : 'text-gray-500'
                    }`}
                  >
                    {step.title}
                  </p>
                </div>
                {index < steps.length - 1 && (
                  <div
                    className={`flex-1 h-1 mx-2 mt-5 ${
                      currentStep > step.number ? 'bg-primary' : 'bg-gray-200'
                    }`}
                  ></div>
                )}
              </React.Fragment>
            ))}
          </div>
        </div>

        <form onSubmit={(e) => e.preventDefault()}>
          {/* Step 1: Community Information */}
          {currentStep === 1 && (
            <div className="space-y-6">
              <h2 className="text-xl font-semibold text-gray-800 border-b pb-2">
                Community Information
              </h2>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
                    Community Name *
                  </label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary ${
                      fieldErrors.name ? 'border-red-500' : ''
                    }`}
                    placeholder="e.g., Sunset Valley Residences"
                  />
                  {fieldErrors.name && (
                    <p className="mt-1 text-sm text-red-500">{fieldErrors.name}</p>
                  )}
                </div>

                <div>
                  <label htmlFor="city" className="block text-sm font-medium text-gray-700 mb-1">
                    City
                  </label>
                  <input
                    type="text"
                    id="city"
                    name="city"
                    value={formData.city}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                    placeholder="e.g., Quezon City"
                  />
                </div>
              </div>

              <div>
                <label htmlFor="address" className="block text-sm font-medium text-gray-700 mb-1">
                  Complete Address *
                </label>
                <input
                  type="text"
                  id="address"
                  name="address"
                  value={formData.address}
                  onChange={handleInputChange}
                  className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary ${
                    fieldErrors.address ? 'border-red-500' : ''
                  }`}
                  placeholder="e.g., 123 Main Street, Barangay Example"
                />
                {fieldErrors.address && (
                  <p className="mt-1 text-sm text-red-500">{fieldErrors.address}</p>
                )}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <label htmlFor="state" className="block text-sm font-medium text-gray-700 mb-1">
                    State/Province
                  </label>
                  <input
                    type="text"
                    id="state"
                    name="state"
                    value={formData.state}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                    placeholder="e.g., Metro Manila"
                  />
                </div>

                <div>
                  <label htmlFor="country" className="block text-sm font-medium text-gray-700 mb-1">
                    Country
                  </label>
                  <input
                    type="text"
                    id="country"
                    name="country"
                    value={formData.country}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                </div>

                <div>
                  <label
                    htmlFor="postal_code"
                    className="block text-sm font-medium text-gray-700 mb-1"
                  >
                    Postal Code
                  </label>
                  <input
                    type="text"
                    id="postal_code"
                    name="postal_code"
                    value={formData.postal_code}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                    placeholder="e.g., 1100"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label
                    htmlFor="max_residences"
                    className="block text-sm font-medium text-gray-700 mb-1"
                  >
                    Total Housing Units
                  </label>
                  <input
                    type="number"
                    id="max_residences"
                    name="max_residences"
                    min="1"
                    value={formData.max_residences}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                    placeholder="e.g., 500"
                  />
                </div>

                <div>
                  <label
                    htmlFor="subscription_status"
                    className="block text-sm font-medium text-gray-700 mb-1"
                  >
                    Initial Status
                  </label>
                  <select
                    id="subscription_status"
                    name="subscription_status"
                    value={formData.subscription_status}
                    onChange={handleInputChange}
                    className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  >
                    <option value="active">Active</option>
                    <option value="trial">Trial</option>
                    <option value="inactive">Inactive</option>
                  </select>
                </div>
              </div>
            </div>
          )}

          {/* Step 2: Gates & Entrances */}
          {currentStep === 2 && (
            <div className="space-y-6">
              <div className="flex justify-between items-center border-b pb-2">
                <h2 className="text-xl font-semibold text-gray-800">Community Gates/Entrances</h2>
                <button
                  type="button"
                  onClick={addGate}
                  className="bg-primary hover:bg-primary/90 text-white py-1 px-3 rounded-lg text-sm flex items-center"
                >
                  <Plus className="h-4 w-4 mr-1" />
                  Add Gate
                </button>
              </div>

              <div className="bg-primary-light border-l-4 border-primary p-4 rounded-md mb-4">
                <div className="flex">
                  <Info className="h-5 w-5 text-primary mr-2" />
                  <p className="text-sm text-primary">
                    Add all entry/exit points for the community. Each gate can be configured
                    separately.
                  </p>
                </div>
              </div>

              <div className="space-y-6">
                {gates.map((gate) => (
                  <div
                    key={gate.id}
                    className="p-4 border rounded-lg space-y-4 transition-all duration-300 hover:shadow-md"
                  >
                    <div className="flex justify-between items-center">
                      <h3 className="font-medium flex items-center">
                        <span className="w-6 h-6 bg-primary text-white rounded-full flex items-center justify-center text-xs mr-2">
                          {gate.id}
                        </span>
                        Gate #{gate.id}
                      </h3>
                      <button
                        type="button"
                        onClick={() => removeGate(gate.id)}
                        className="text-red-500 hover:text-red-700 text-sm flex items-center"
                        disabled={gates.length === 1}
                      >
                        <X className="h-4 w-4 mr-1" />
                        Remove
                      </button>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Gate Name *
                      </label>
                      <input
                        type="text"
                        value={gate.name}
                        onChange={(e) => handleGateChange(gate.id, 'name', e.target.value)}
                        className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary ${
                          fieldErrors[`gate-${gate.id}-name`] ? 'border-red-500' : ''
                        }`}
                        placeholder="e.g., Main Gate, North Gate"
                      />
                      {fieldErrors[`gate-${gate.id}-name`] && (
                        <p className="mt-1 text-sm text-red-500">
                          {fieldErrors[`gate-${gate.id}-name`]}
                        </p>
                      )}
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Location *
                      </label>
                      <input
                        type="text"
                        value={gate.location}
                        onChange={(e) => handleGateChange(gate.id, 'location', e.target.value)}
                        className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary ${
                          fieldErrors[`gate-${gate.id}-location`] ? 'border-red-500' : ''
                        }`}
                        placeholder="e.g., Located at the north side of the community"
                      />
                      {fieldErrors[`gate-${gate.id}-location`] && (
                        <p className="mt-1 text-sm text-red-500">
                          {fieldErrors[`gate-${gate.id}-location`]}
                        </p>
                      )}
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Gate Type
                      </label>
                      <select
                        value={gate.gate_type}
                        onChange={(e) => handleGateChange(gate.id, 'gate_type', e.target.value)}
                        className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                      >
                        <option value="main">Main Gate</option>
                        <option value="pedestrian">Pedestrian Gate</option>
                        <option value="vehicle">Vehicle Gate</option>
                        <option value="service">Service Gate</option>
                        <option value="emergency">Emergency Exit</option>
                      </select>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Step 3: Admin User */}
          {currentStep === 3 && (
            <div className="space-y-6">
              <h2 className="text-xl font-semibold text-gray-800 border-b pb-2">
                Create Initial Admin User
              </h2>

              <div className="bg-primary-light border-l-4 border-primary p-4 rounded-md mb-4">
                <div className="flex">
                  <Info className="h-5 w-5 text-primary mr-2 flex-shrink-0 mt-0.5" />
                  <p className="text-sm text-primary">
                    Create the first administrative user who will manage this community. This user
                    will have full access to configure settings and manage other users.
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label
                    htmlFor="admin-first_name"
                    className="block text-sm font-medium text-gray-700 mb-1"
                  >
                    First Name *
                  </label>
                  <input
                    type="text"
                    id="admin-first_name"
                    name="first_name"
                    value={adminUser.first_name}
                    onChange={handleAdminUserChange}
                    className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary ${
                      fieldErrors['admin-first_name'] ? 'border-red-500' : ''
                    }`}
                    placeholder="e.g., Juan"
                  />
                  {fieldErrors['admin-first_name'] && (
                    <p className="mt-1 text-sm text-red-500">{fieldErrors['admin-first_name']}</p>
                  )}
                </div>

                <div>
                  <label
                    htmlFor="admin-last_name"
                    className="block text-sm font-medium text-gray-700 mb-1"
                  >
                    Last Name *
                  </label>
                  <input
                    type="text"
                    id="admin-last_name"
                    name="last_name"
                    value={adminUser.last_name}
                    onChange={handleAdminUserChange}
                    className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary ${
                      fieldErrors['admin-last_name'] ? 'border-red-500' : ''
                    }`}
                    placeholder="e.g., Dela Cruz"
                  />
                  {fieldErrors['admin-last_name'] && (
                    <p className="mt-1 text-sm text-red-500">{fieldErrors['admin-last_name']}</p>
                  )}
                </div>
              </div>

              <div>
                <label
                  htmlFor="admin-email"
                  className="block text-sm font-medium text-gray-700 mb-1"
                >
                  Email Address *
                </label>
                <input
                  type="email"
                  id="admin-email"
                  name="email"
                  value={adminUser.email}
                  onChange={handleAdminUserChange}
                  className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary ${
                    fieldErrors['admin-email'] ? 'border-red-500' : ''
                  }`}
                  placeholder="e.g., admin@example.com"
                />
                {fieldErrors['admin-email'] && (
                  <p className="mt-1 text-sm text-red-500">{fieldErrors['admin-email']}</p>
                )}
              </div>

              <div>
                <label
                  htmlFor="admin-phone_number"
                  className="block text-sm font-medium text-gray-700 mb-1"
                >
                  Phone Number
                </label>
                <input
                  type="tel"
                  id="admin-phone_number"
                  name="phone_number"
                  value={adminUser.phone_number}
                  onChange={handleAdminUserChange}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="+63 912 345 6789"
                />
              </div>

              <div>
                <label
                  htmlFor="admin-password"
                  className="block text-sm font-medium text-gray-700 mb-1"
                >
                  Temporary Password *
                </label>
                <div className="flex space-x-2">
                  <div className="flex-1 relative">
                    <input
                      type={showPassword ? "text" : "password"}
                      id="admin-password"
                      name="password"
                      value={adminUser.password}
                      onChange={handleAdminUserChange}
                      className={`w-full px-4 py-2 pr-10 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary ${
                        fieldErrors['admin-password'] ? 'border-red-500' : ''
                      }`}
                    />
                    <button
                      type="button"
                      onClick={togglePasswordVisibility}
                      className="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700 transition-colors duration-200"
                      title={showPassword ? "Hide password" : "Show password"}
                    >
                      {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                  <button
                    type="button"
                    onClick={generateTemporaryPassword}
                    className="px-4 py-2 bg-gray-100 hover:bg-gray-200 border border-gray-300 rounded-lg flex items-center space-x-2 transition-colors duration-200"
                    title="Generate secure temporary password"
                  >
                    <RefreshCw className="h-4 w-4" />
                    <span className="text-sm font-medium">Generate</span>
                  </button>
                </div>
                {fieldErrors['admin-password'] && (
                  <p className="mt-1 text-sm text-red-500">{fieldErrors['admin-password']}</p>
                )}
                <p className="mt-1 text-xs text-gray-500">
                  Set a temporary password for the admin user (minimum 6 characters). User will be
                  prompted to change it on first login. Click "Generate" for a secure 12-character password.
                </p>
              </div>

              <div>
                <label
                  htmlFor="admin-role"
                  className="block text-sm font-medium text-gray-700 mb-1"
                >
                  Role
                </label>
                <select
                  id="admin-role"
                  name="role"
                  value={adminUser.role}
                  onChange={handleAdminUserChange}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="admin_head">Admin Head (Full Access)</option>
                  <option value="admin_officer">Admin Officer (Limited Access)</option>
                </select>
              </div>
            </div>
          )}

          {/* Step 4: Review & Submit */}
          {currentStep === 4 && (
            <div className="space-y-6">
              <h2 className="text-xl font-semibold text-gray-800 border-b pb-2">
                Review Community Information
              </h2>

              <div className="bg-gray-50 p-4 rounded-lg">
                <h3 className="font-medium text-gray-800 mb-3">Community Details</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                  <div>
                    <p className="text-sm text-gray-500">Name</p>
                    <p className="font-medium">{formData.name}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">City</p>
                    <p className="font-medium">{formData.city || 'Not specified'}</p>
                  </div>
                  <div className="md:col-span-2">
                    <p className="text-sm text-gray-500">Address</p>
                    <p className="font-medium">{formData.address}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Total Units</p>
                    <p className="font-medium">{formData.max_residences || 'Not specified'}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Initial Status</p>
                    <p className="font-medium">
                      <span
                        className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          formData.subscription_status === 'active'
                            ? 'bg-green-100 text-green-800'
                            : formData.subscription_status === 'trial'
                              ? 'bg-amber-100 text-amber-800'
                              : 'bg-gray-100 text-gray-800'
                        }`}
                      >
                        {formData.subscription_status}
                      </span>
                    </p>
                  </div>
                </div>

                <h3 className="font-medium text-gray-800 mb-3 border-t pt-3">Gates & Entrances</h3>
                <div className="space-y-3">
                  {gates.map((gate) => (
                    <div key={gate.id} className="p-3 bg-white rounded border">
                      <div className="flex justify-between">
                        <h4 className="font-medium text-gray-800">{gate.name || 'Unnamed Gate'}</h4>
                        <span className="text-sm text-gray-500">Gate #{gate.id}</span>
                      </div>
                      <p className="text-sm text-gray-600 mt-1">
                        {gate.location || 'No location provided'}
                      </p>
                      <p className="text-xs text-gray-500 mt-1 capitalize">
                        Type: {gate.gate_type}
                      </p>
                    </div>
                  ))}
                </div>

                <h3 className="font-medium text-gray-800 mb-3 border-t pt-3 mt-4">Admin User</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-500">Name</p>
                    <p className="font-medium">
                      {adminUser.first_name} {adminUser.last_name}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Email</p>
                    <p className="font-medium">{adminUser.email}</p>
                  </div>
                  {adminUser.phone_number && (
                    <div>
                      <p className="text-sm text-gray-500">Phone</p>
                      <p className="font-medium">{adminUser.phone_number}</p>
                    </div>
                  )}
                  <div>
                    <p className="text-sm text-gray-500">Role</p>
                    <p className="font-medium capitalize">
                      {adminUser.role === 'admin_head' ? 'Admin Head' : 'Admin Officer'}
                    </p>
                  </div>
                </div>
              </div>

              <div className="bg-amber-50 border-l-4 border-accent p-4 rounded-md">
                <div className="flex">
                  <AlertTriangle className="h-5 w-5 text-accent mr-2" />
                  <div>
                    <p className="text-sm text-amber-700 font-medium">
                      Please verify all information before submitting
                    </p>
                    <p className="text-sm text-amber-600 mt-1">
                      The community and admin user will be created. You can configure additional
                      settings after submission.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Step 5: Success - Admin Credentials */}
          {currentStep === 5 && createdCredentials && (
            <div className="space-y-6">
              <div className="text-center py-8">
                <div className="mx-auto w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mb-6">
                  <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"></path>
                  </svg>
                </div>

                <h2 className="text-2xl font-bold text-gray-800 mb-2">
                  Community Created Successfully!
                </h2>
                <p className="text-gray-600 mb-8">
                  {createdCredentials.tenantName} has been set up and is ready for management.
                </p>

                {emailSent ? (
                  <div className="bg-green-50 border border-green-200 rounded-lg p-6 mb-8 max-w-2xl mx-auto">
                    <div className="flex items-start mb-4">
                      <svg className="h-5 w-5 text-green-600 mr-2 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                      </svg>
                      <div className="text-left">
                        <h3 className="font-medium text-green-800 mb-1">
                          ✅ Welcome Email Sent
                        </h3>
                        <p className="text-sm text-green-700">
                          The admin user ({createdCredentials.email}) has been sent their login credentials via email. They can access the admin dashboard immediately.
                        </p>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="bg-amber-50 border border-amber-200 rounded-lg p-6 mb-8 max-w-2xl mx-auto">
                    <div className="flex items-start mb-4">
                      <AlertTriangle className="h-5 w-5 text-amber-600 mr-2 mt-0.5 flex-shrink-0" />
                      <div className="text-left">
                        <h3 className="font-medium text-amber-800 mb-1">
                          Important: Save These Credentials
                        </h3>
                        <p className="text-sm text-amber-700">
                          The welcome email could not be sent automatically. Please save these credentials securely and share them with the community administrator.
                        </p>
                      </div>
                    </div>
                  </div>
                )}

                <div className="space-y-4">
                    <div className="bg-white rounded-lg p-4 border">
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Admin Login URL
                      </label>
                      <div className="flex items-center space-x-2">
                        <input
                          type="text"
                          readOnly
                          value={`${process.env.NEXT_PUBLIC_ADMIN_APP_URL || 'http://localhost:3001'}/login`}
                          className="flex-1 px-3 py-2 bg-gray-50 border rounded-lg text-sm"
                        />
                        <button
                          type="button"
                          onClick={() => {
                            navigator.clipboard.writeText(`${process.env.NEXT_PUBLIC_ADMIN_APP_URL || 'http://localhost:3001'}/login`)
                            toast.success('Login URL copied to clipboard!')
                          }}
                          className="px-3 py-2 bg-gray-100 hover:bg-gray-200 border rounded-lg text-sm"
                        >
                          Copy
                        </button>
                      </div>
                    </div>

                    <div className="bg-white rounded-lg p-4 border">
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Email Address
                      </label>
                      <div className="flex items-center space-x-2">
                        <input
                          type="text"
                          readOnly
                          value={createdCredentials.email}
                          className="flex-1 px-3 py-2 bg-gray-50 border rounded-lg text-sm"
                        />
                        <button
                          type="button"
                          onClick={() => {
                            navigator.clipboard.writeText(createdCredentials.email)
                            toast.success('Email copied to clipboard!')
                          }}
                          className="px-3 py-2 bg-gray-100 hover:bg-gray-200 border rounded-lg text-sm"
                        >
                          Copy
                        </button>
                      </div>
                    </div>

                    <div className="bg-white rounded-lg p-4 border">
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Temporary Password
                      </label>
                      <div className="flex items-center space-x-2">
                        <div className="flex-1 relative">
                          <input
                            type={showPassword ? "text" : "password"}
                            readOnly
                            value={createdCredentials.password}
                            className="w-full px-3 py-2 bg-gray-50 border rounded-lg text-sm pr-10"
                          />
                          <button
                            type="button"
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700"
                          >
                            {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                          </button>
                        </div>
                        <button
                          type="button"
                          onClick={() => {
                            navigator.clipboard.writeText(createdCredentials.password)
                            toast.success('Password copied to clipboard!')
                          }}
                          className="px-3 py-2 bg-gray-100 hover:bg-gray-200 border rounded-lg text-sm"
                        >
                          Copy
                        </button>
                      </div>
                    </div>
                  </div>

                  <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                    <p className="text-sm text-blue-800">
                      <strong>Next Steps:</strong> The admin user should log in immediately and change their temporary password. They will have full access to manage {createdCredentials.tenantName}.
                    </p>
                  </div>

                <div className="flex justify-center space-x-4">
                  <button
                    type="button"
                    onClick={() => {
                      navigator.clipboard.writeText(
                        `Admin Login: ${process.env.NEXT_PUBLIC_ADMIN_APP_URL || 'http://localhost:3001'}/login\nEmail: ${createdCredentials.email}\nPassword: ${createdCredentials.password}`
                      )
                      toast.success('All credentials copied to clipboard!')
                    }}
                    className="px-6 py-2 bg-gray-100 hover:bg-gray-200 border border-gray-300 rounded-lg flex items-center space-x-2"
                  >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"></path>
                    </svg>
                    <span>Copy All Credentials</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => {
                      // Use Next.js router for proper client-side navigation
                      router.push('/tenants')
                    }}
                    className="px-6 py-2 bg-primary hover:bg-primary/90 text-white rounded-lg"
                  >
                    Done
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Navigation Buttons */}
          {currentStep < 5 && (
            <div className="flex justify-between space-x-4 pt-6 border-t mt-8">
              {currentStep > 1 ? (
                <button
                  type="button"
                  onClick={handlePrevStep}
                  className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100 transition-colors duration-200"
                >
                  Previous
                </button>
              ) : (
                <button
                  type="button"
                  onClick={() => router.push('/tenants')}
                  className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100 transition-colors duration-200"
                >
                  Cancel
                </button>
              )}

              {currentStep < 4 ? (
                <button
                  type="button"
                  onClick={handleNextStep}
                  className="px-6 py-2 bg-primary hover:bg-primary/90 text-white rounded-lg transition-colors duration-200"
                >
                  Next
                </button>
              ) : (
                <button
                  type="button"
                  onClick={handleSubmit}
                  disabled={isSubmitting}
                  className={`px-6 py-2 bg-primary hover:bg-primary/90 text-white rounded-lg flex items-center transition-colors duration-200 ${
                    isSubmitting ? 'opacity-70 cursor-not-allowed' : ''
                  }`}
                >
                  {isSubmitting ? (
                    <>
                      <svg
                        className="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                      >
                        <circle
                          className="opacity-25"
                          cx="12"
                          cy="12"
                          r="10"
                          stroke="currentColor"
                          strokeWidth="4"
                        ></circle>
                        <path
                          className="opacity-75"
                          fill="currentColor"
                          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                        ></path>
                      </svg>
                      Processing...
                    </>
                  ) : (
                    'Create Community'
                  )}
                </button>
              )}
            </div>
          )}
        </form>
      </div>
    </div>
  )
}
