import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeftIcon, CheckIcon, InfoIcon, EyeIcon, EyeOffIcon, UserIcon } from 'lucide-react';
const AddUserForm: React.FC = () => {
  const navigate = useNavigate();
  const [showSuccess, setShowSuccess] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    role: 'admin',
    status: 'active',
    password: '',
    confirmPassword: '',
    sendInvite: true,
    communities: [],
    profileImage: '',
    jobTitle: '',
    department: '',
    address: '',
    city: '',
    state: '',
    zipCode: '',
    bio: '',
    notificationPreferences: {
      email: true,
      sms: false,
      inApp: true
    }
  });
  // Mock data for roles and communities
  const availableRoles = [{
    id: 'super-admin',
    name: 'Super Admin'
  }, {
    id: 'admin',
    name: 'Admin'
  }, {
    id: 'manager',
    name: 'Manager'
  }];
  const availableCommunities = [{
    id: 1,
    name: 'Evergreen Heights'
  }, {
    id: 2,
    name: 'Oakridge Estates'
  }, {
    id: 3,
    name: 'Maple Grove'
  }, {
    id: 4,
    name: 'Sunset Valley'
  }, {
    id: 5,
    name: 'Palm Gardens'
  }];
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const {
      name,
      value,
      type
    } = e.target;
    if (type === 'checkbox') {
      const checked = (e.target as HTMLInputElement).checked;
      if (name.includes('.')) {
        const [parent, child] = name.split('.');
        setFormData({
          ...formData,
          [parent]: {
            ...formData[parent as keyof typeof formData],
            [child]: checked
          }
        });
      } else {
        setFormData({
          ...formData,
          [name]: checked
        });
      }
    } else {
      setFormData({
        ...formData,
        [name]: value
      });
    }
    // Clear error for this field
    if (errors[name]) {
      const newErrors = {
        ...errors
      };
      delete newErrors[name];
      setErrors(newErrors);
    }
  };
  const handleCommunityChange = (communityId: number) => {
    const currentCommunities = formData.communities as number[];
    if (currentCommunities.includes(communityId)) {
      setFormData({
        ...formData,
        communities: currentCommunities.filter(id => id !== communityId)
      });
    } else {
      setFormData({
        ...formData,
        communities: [...currentCommunities, communityId]
      });
    }
  };
  const validateForm = () => {
    const newErrors: Record<string, string> = {};
    // Required fields
    if (!formData.firstName.trim()) newErrors.firstName = 'First name is required';
    if (!formData.lastName.trim()) newErrors.lastName = 'Last name is required';
    // Email validation
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email is invalid';
    }
    // Phone validation (optional but if provided, must be valid)
    if (formData.phone && !/^\+?[0-9\s\-\(\)]+$/.test(formData.phone)) {
      newErrors.phone = 'Phone number is invalid';
    }
    // Password validation
    if (!formData.password) {
      newErrors.password = 'Password is required';
    } else if (formData.password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }
    // Password confirmation
    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
    }
    // Communities validation - at least one community must be selected for non-super-admins
    if (formData.role !== 'super-admin' && (formData.communities as number[]).length === 0) {
      newErrors.communities = 'At least one community must be assigned';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) {
      return;
    }
    setIsSubmitting(true);
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      console.log('Form data submitted:', formData);
      setShowSuccess(true);
      // Reset form or redirect after success
      setTimeout(() => {
        navigate('/users');
      }, 2000);
    } catch (error) {
      console.error('Error submitting form:', error);
    } finally {
      setIsSubmitting(false);
    }
  };
  return <div className="space-y-6">
      <div className="flex items-center space-x-2">
        <button onClick={() => navigate('/users')} className="text-gray-600 hover:text-gray-800">
          <ArrowLeftIcon className="h-5 w-5" />
        </button>
        <h1 className="text-2xl font-bold text-gray-800">Add New User</h1>
      </div>
      {showSuccess && <div className="bg-[#F0F9F6] border-l-4 border-[#105640] p-4 rounded-md">
          <div className="flex items-center">
            <CheckIcon className="h-5 w-5 text-[#105640] mr-2" />
            <p className="text-[#105640]">
              User created successfully! Redirecting to users list...
            </p>
          </div>
        </div>}
      <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow">
        {/* Basic Information Section */}
        <div className="p-6 border-b">
          <h2 className="text-lg font-semibold text-gray-800 flex items-center">
            <UserIcon className="h-5 w-5 mr-2 text-[#105640]" />
            Basic Information
          </h2>
        </div>
        <div className="p-6 space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="firstName" className="block text-sm font-medium text-gray-700 mb-1">
                First Name *
              </label>
              <input type="text" id="firstName" name="firstName" value={formData.firstName} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640] ${errors.firstName ? 'border-red-500' : ''}`} />
              {errors.firstName && <p className="mt-1 text-sm text-red-500">{errors.firstName}</p>}
            </div>
            <div>
              <label htmlFor="lastName" className="block text-sm font-medium text-gray-700 mb-1">
                Last Name *
              </label>
              <input type="text" id="lastName" name="lastName" value={formData.lastName} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640] ${errors.lastName ? 'border-red-500' : ''}`} />
              {errors.lastName && <p className="mt-1 text-sm text-red-500">{errors.lastName}</p>}
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                Email Address *
              </label>
              <input type="email" id="email" name="email" value={formData.email} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640] ${errors.email ? 'border-red-500' : ''}`} />
              {errors.email && <p className="mt-1 text-sm text-red-500">{errors.email}</p>}
            </div>
            <div>
              <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-1">
                Phone Number
              </label>
              <input type="tel" id="phone" name="phone" value={formData.phone} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640] ${errors.phone ? 'border-red-500' : ''}`} placeholder="+1 (555) 123-4567" />
              {errors.phone && <p className="mt-1 text-sm text-red-500">{errors.phone}</p>}
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="jobTitle" className="block text-sm font-medium text-gray-700 mb-1">
                Job Title
              </label>
              <input type="text" id="jobTitle" name="jobTitle" value={formData.jobTitle} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" placeholder="e.g. Community Manager" />
            </div>
            <div>
              <label htmlFor="department" className="block text-sm font-medium text-gray-700 mb-1">
                Department
              </label>
              <input type="text" id="department" name="department" value={formData.department} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" placeholder="e.g. Administration" />
            </div>
          </div>
          <div>
            <label htmlFor="bio" className="block text-sm font-medium text-gray-700 mb-1">
              Bio/Notes
            </label>
            <textarea id="bio" name="bio" rows={3} value={formData.bio} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" placeholder="Brief description or notes about this user"></textarea>
          </div>
        </div>
        {/* Account Settings Section */}
        <div className="p-6 border-t border-b">
          <h2 className="text-lg font-semibold text-gray-800">
            Account Settings
          </h2>
        </div>
        <div className="p-6 space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="role" className="block text-sm font-medium text-gray-700 mb-1">
                User Role *
              </label>
              <select id="role" name="role" value={formData.role} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                {availableRoles.map(role => <option key={role.id} value={role.id}>
                    {role.name}
                  </option>)}
              </select>
              <p className="mt-1 text-xs text-gray-500">
                This determines the user's permissions in the system
              </p>
            </div>
            <div>
              <label htmlFor="status" className="block text-sm font-medium text-gray-700 mb-1">
                Account Status
              </label>
              <select id="status" name="status" value={formData.status} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                <option value="active">Active</option>
                <option value="pending">Pending</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                Password *
              </label>
              <div className="relative">
                <input type={showPassword ? 'text' : 'password'} id="password" name="password" value={formData.password} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640] ${errors.password ? 'border-red-500' : ''}`} />
                <button type="button" className="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600" onClick={() => setShowPassword(!showPassword)}>
                  {showPassword ? <EyeOffIcon className="h-5 w-5" /> : <EyeIcon className="h-5 w-5" />}
                </button>
              </div>
              {errors.password && <p className="mt-1 text-sm text-red-500">{errors.password}</p>}
            </div>
            <div>
              <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 mb-1">
                Confirm Password *
              </label>
              <div className="relative">
                <input type={showPassword ? 'text' : 'password'} id="confirmPassword" name="confirmPassword" value={formData.confirmPassword} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640] ${errors.confirmPassword ? 'border-red-500' : ''}`} />
              </div>
              {errors.confirmPassword && <p className="mt-1 text-sm text-red-500">
                  {errors.confirmPassword}
                </p>}
            </div>
          </div>
          <div className="flex items-center">
            <input type="checkbox" id="sendInvite" name="sendInvite" checked={formData.sendInvite} onChange={handleInputChange} className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" />
            <label htmlFor="sendInvite" className="ml-2 text-sm text-gray-700">
              Send welcome email with login instructions
            </label>
          </div>
        </div>
        {/* Community Access Section */}
        <div className="p-6 border-t border-b">
          <h2 className="text-lg font-semibold text-gray-800">
            Community Access
          </h2>
        </div>
        <div className="p-6 space-y-4">
          <div className="bg-[#F0F9F6] border-l-4 border-[#105640] p-4 rounded-md mb-4">
            <div className="flex">
              <InfoIcon className="h-5 w-5 text-[#105640] mr-2" />
              <p className="text-sm text-[#105640]">
                {formData.role === 'super-admin' ? 'Super Admins have access to all communities by default.' : 'Select the communities this user will have access to.'}
              </p>
            </div>
          </div>
          {formData.role !== 'super-admin' && <>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {availableCommunities.map(community => <div key={community.id} className="flex items-center">
                    <input type="checkbox" id={`community-${community.id}`} checked={(formData.communities as number[]).includes(community.id)} onChange={() => handleCommunityChange(community.id)} className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" />
                    <label htmlFor={`community-${community.id}`} className="ml-2 text-sm text-gray-700">
                      {community.name}
                    </label>
                  </div>)}
              </div>
              {errors.communities && <p className="mt-1 text-sm text-red-500">
                  {errors.communities}
                </p>}
            </>}
        </div>
        {/* Notification Preferences Section */}
        <div className="p-6 border-t border-b">
          <h2 className="text-lg font-semibold text-gray-800">
            Notification Preferences
          </h2>
        </div>
        <div className="p-6 space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="flex items-center">
              <input type="checkbox" id="notificationPreferences.email" name="notificationPreferences.email" checked={formData.notificationPreferences.email} onChange={handleInputChange} className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" />
              <label htmlFor="notificationPreferences.email" className="ml-2 text-sm text-gray-700">
                Email Notifications
              </label>
            </div>
            <div className="flex items-center">
              <input type="checkbox" id="notificationPreferences.sms" name="notificationPreferences.sms" checked={formData.notificationPreferences.sms} onChange={handleInputChange} className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" />
              <label htmlFor="notificationPreferences.sms" className="ml-2 text-sm text-gray-700">
                SMS Notifications
              </label>
            </div>
            <div className="flex items-center">
              <input type="checkbox" id="notificationPreferences.inApp" name="notificationPreferences.inApp" checked={formData.notificationPreferences.inApp} onChange={handleInputChange} className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" />
              <label htmlFor="notificationPreferences.inApp" className="ml-2 text-sm text-gray-700">
                In-App Notifications
              </label>
            </div>
          </div>
        </div>
        {/* Form Actions */}
        <div className="p-6 border-t flex justify-end space-x-4">
          <button type="button" onClick={() => navigate('/users')} className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100">
            Cancel
          </button>
          <button type="submit" disabled={isSubmitting} className={`px-6 py-2 bg-[#105640] hover:bg-[#2D7D5C] text-white rounded-lg flex items-center transition-colors duration-200 ${isSubmitting ? 'opacity-70 cursor-not-allowed' : ''}`}>
            {isSubmitting ? <>
                <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Creating User...
              </> : 'Create User'}
          </button>
        </div>
      </form>
    </div>;
};
export default AddUserForm;