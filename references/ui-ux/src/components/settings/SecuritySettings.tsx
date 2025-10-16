import React, { useState } from 'react';
import { ShieldIcon, KeyIcon, SaveIcon, CheckIcon, AlertTriangleIcon, InfoIcon, ToggleLeftIcon, ToggleRightIcon } from 'lucide-react';
const SecuritySettings: React.FC = () => {
  const [settings, setSettings] = useState({
    passwordPolicy: {
      minLength: 8,
      requireUppercase: true,
      requireLowercase: true,
      requireNumbers: true,
      requireSpecialChars: true,
      expiryDays: 90
    },
    twoFactorAuth: {
      required: false,
      requiredForAdmins: true
    },
    sessionTimeout: 30,
    ipRestriction: {
      enabled: false,
      allowedIPs: ''
    },
    loginAttempts: 5
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const {
      name,
      value,
      type
    } = e.target;
    if (name.includes('.')) {
      const [section, field] = name.split('.');
      setSettings({
        ...settings,
        [section]: {
          ...settings[section as keyof typeof settings],
          [field]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : type === 'number' ? parseInt(value) : value
        }
      });
    } else {
      setSettings({
        ...settings,
        [name]: type === 'number' ? parseInt(value) : value
      });
    }
  };
  const handleToggle = (section: string, field: string) => {
    setSettings({
      ...settings,
      [section]: {
        ...settings[section as keyof typeof settings],
        [field]: !settings[section as keyof typeof settings][field as keyof (typeof settings)[keyof typeof settings]]
      }
    });
  };
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    // Simulate API call
    setTimeout(() => {
      setIsSubmitting(false);
      setShowSuccess(true);
      // Hide success message after 3 seconds
      setTimeout(() => {
        setShowSuccess(false);
      }, 3000);
    }, 1000);
  };
  return <div>
      <form onSubmit={handleSubmit} className="space-y-6">
        {showSuccess && <div className="bg-[#F0F9F6] border-l-4 border-[#105640] p-4 rounded-md mb-6">
            <div className="flex items-center">
              <CheckIcon className="h-5 w-5 text-[#105640] mr-2" />
              <p className="text-[#105640]">
                Security settings updated successfully!
              </p>
            </div>
          </div>}
        {/* Password Policy */}
        <div>
          <h2 className="text-lg font-medium text-gray-800 mb-4 flex items-center">
            <KeyIcon className="h-5 w-5 mr-2 text-[#105640]" />
            Password Policy
          </h2>
          <div className="bg-gray-50 p-4 rounded-lg space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label htmlFor="passwordPolicy.minLength" className="block text-sm font-medium text-gray-700 mb-1">
                  Minimum Password Length
                </label>
                <input type="number" id="passwordPolicy.minLength" name="passwordPolicy.minLength" min="6" max="24" value={settings.passwordPolicy.minLength} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
              </div>
              <div>
                <label htmlFor="passwordPolicy.expiryDays" className="block text-sm font-medium text-gray-700 mb-1">
                  Password Expiry (Days)
                </label>
                <input type="number" id="passwordPolicy.expiryDays" name="passwordPolicy.expiryDays" min="0" max="365" value={settings.passwordPolicy.expiryDays} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
                <p className="text-xs text-gray-500 mt-1">
                  Set to 0 for no expiration
                </p>
              </div>
            </div>
            <div className="space-y-2">
              <div className="flex items-center">
                <input type="checkbox" id="passwordPolicy.requireUppercase" name="passwordPolicy.requireUppercase" checked={settings.passwordPolicy.requireUppercase} onChange={e => handleToggle('passwordPolicy', 'requireUppercase')} className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" />
                <label htmlFor="passwordPolicy.requireUppercase" className="ml-2 text-sm text-gray-700">
                  Require at least one uppercase letter
                </label>
              </div>
              <div className="flex items-center">
                <input type="checkbox" id="passwordPolicy.requireLowercase" name="passwordPolicy.requireLowercase" checked={settings.passwordPolicy.requireLowercase} onChange={e => handleToggle('passwordPolicy', 'requireLowercase')} className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" />
                <label htmlFor="passwordPolicy.requireLowercase" className="ml-2 text-sm text-gray-700">
                  Require at least one lowercase letter
                </label>
              </div>
              <div className="flex items-center">
                <input type="checkbox" id="passwordPolicy.requireNumbers" name="passwordPolicy.requireNumbers" checked={settings.passwordPolicy.requireNumbers} onChange={e => handleToggle('passwordPolicy', 'requireNumbers')} className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" />
                <label htmlFor="passwordPolicy.requireNumbers" className="ml-2 text-sm text-gray-700">
                  Require at least one number
                </label>
              </div>
              <div className="flex items-center">
                <input type="checkbox" id="passwordPolicy.requireSpecialChars" name="passwordPolicy.requireSpecialChars" checked={settings.passwordPolicy.requireSpecialChars} onChange={e => handleToggle('passwordPolicy', 'requireSpecialChars')} className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" />
                <label htmlFor="passwordPolicy.requireSpecialChars" className="ml-2 text-sm text-gray-700">
                  Require at least one special character
                </label>
              </div>
            </div>
          </div>
        </div>
        {/* Two-Factor Authentication */}
        <div>
          <h2 className="text-lg font-medium text-gray-800 mb-4 flex items-center">
            <ShieldIcon className="h-5 w-5 mr-2 text-[#105640]" />
            Two-Factor Authentication
          </h2>
          <div className="bg-gray-50 p-4 rounded-lg space-y-4">
            <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
              <div>
                <h3 className="font-medium text-gray-800">
                  Require 2FA for all users
                </h3>
                <p className="text-sm text-gray-600 mt-1">
                  All users will be required to set up two-factor authentication
                </p>
              </div>
              <button type="button" onClick={() => handleToggle('twoFactorAuth', 'required')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.twoFactorAuth.required ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.twoFactorAuth.required ? 'translate-x-6' : ''}`}></div>
              </button>
            </div>
            <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
              <div>
                <h3 className="font-medium text-gray-800">
                  Require 2FA for admin users
                </h3>
                <p className="text-sm text-gray-600 mt-1">
                  Users with administrative privileges will be required to set
                  up two-factor authentication
                </p>
              </div>
              <button type="button" onClick={() => handleToggle('twoFactorAuth', 'requiredForAdmins')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.twoFactorAuth.requiredForAdmins ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.twoFactorAuth.requiredForAdmins ? 'translate-x-6' : ''}`}></div>
              </button>
            </div>
          </div>
        </div>
        {/* Session & Login Security */}
        <div>
          <h2 className="text-lg font-medium text-gray-800 mb-4">
            Session & Login Security
          </h2>
          <div className="bg-gray-50 p-4 rounded-lg space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label htmlFor="sessionTimeout" className="block text-sm font-medium text-gray-700 mb-1">
                  Session Timeout (minutes)
                </label>
                <input type="number" id="sessionTimeout" name="sessionTimeout" min="5" max="1440" value={settings.sessionTimeout} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
                <p className="text-xs text-gray-500 mt-1">
                  Users will be logged out after this period of inactivity
                </p>
              </div>
              <div>
                <label htmlFor="loginAttempts" className="block text-sm font-medium text-gray-700 mb-1">
                  Max Login Attempts
                </label>
                <input type="number" id="loginAttempts" name="loginAttempts" min="3" max="10" value={settings.loginAttempts} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
                <p className="text-xs text-gray-500 mt-1">
                  Account will be locked after this many failed attempts
                </p>
              </div>
            </div>
            <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
              <div>
                <h3 className="font-medium text-gray-800">
                  IP Address Restriction
                </h3>
                <p className="text-sm text-gray-600 mt-1">
                  Restrict access to specific IP addresses
                </p>
              </div>
              <button type="button" onClick={() => handleToggle('ipRestriction', 'enabled')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.ipRestriction.enabled ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.ipRestriction.enabled ? 'translate-x-6' : ''}`}></div>
              </button>
            </div>
            {settings.ipRestriction.enabled && <div>
                <label htmlFor="ipRestriction.allowedIPs" className="block text-sm font-medium text-gray-700 mb-1">
                  Allowed IP Addresses
                </label>
                <textarea id="ipRestriction.allowedIPs" name="ipRestriction.allowedIPs" value={settings.ipRestriction.allowedIPs} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" placeholder="Enter IP addresses, one per line" rows={3}></textarea>
                <p className="text-xs text-gray-500 mt-1">
                  Enter one IP address or range per line (e.g., 192.168.1.1 or
                  192.168.1.0/24)
                </p>
              </div>}
          </div>
        </div>
        <div className="flex justify-end pt-4 border-t">
          <button type="submit" disabled={isSubmitting} className={`px-6 py-2 bg-[#105640] hover:bg-[#2D7D5C] text-white rounded-lg flex items-center transition-colors duration-200 ${isSubmitting ? 'opacity-70 cursor-not-allowed' : ''}`}>
            {isSubmitting ? <>
                <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Saving...
              </> : <>
                <SaveIcon className="h-4 w-4 mr-2" />
                Save Changes
              </>}
          </button>
        </div>
      </form>
    </div>;
};
export default SecuritySettings;