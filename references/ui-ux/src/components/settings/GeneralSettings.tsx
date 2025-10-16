import React, { useState } from 'react';
import { GlobeIcon, SaveIcon, CheckIcon, ImageIcon, UploadIcon } from 'lucide-react';
const GeneralSettings: React.FC = () => {
  const [settings, setSettings] = useState({
    platformName: 'ResidenceHub',
    supportEmail: 'support@residencehub.com',
    contactPhone: '+1 (555) 123-4567',
    timeZone: 'America/New_York',
    dateFormat: 'MM/DD/YYYY',
    timeFormat: '12h',
    language: 'en-US',
    logo: '/logo.png'
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const {
      name,
      value
    } = e.target;
    setSettings({
      ...settings,
      [name]: value
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
              <p className="text-[#105640]">Settings updated successfully!</p>
            </div>
          </div>}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Platform Information */}
          <div className="md:col-span-2">
            <h2 className="text-lg font-medium text-gray-800 mb-4 flex items-center">
              <GlobeIcon className="h-5 w-5 mr-2 text-[#105640]" />
              Platform Information
            </h2>
            <div className="bg-gray-50 p-4 rounded-lg space-y-4">
              <div>
                <label htmlFor="platformName" className="block text-sm font-medium text-gray-700 mb-1">
                  Platform Name
                </label>
                <input type="text" id="platformName" name="platformName" value={settings.platformName} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="supportEmail" className="block text-sm font-medium text-gray-700 mb-1">
                    Support Email
                  </label>
                  <input type="email" id="supportEmail" name="supportEmail" value={settings.supportEmail} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
                </div>
                <div>
                  <label htmlFor="contactPhone" className="block text-sm font-medium text-gray-700 mb-1">
                    Contact Phone
                  </label>
                  <input type="text" id="contactPhone" name="contactPhone" value={settings.contactPhone} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
                </div>
              </div>
            </div>
          </div>
          {/* Logo & Branding */}
          <div className="md:col-span-2">
            <h2 className="text-lg font-medium text-gray-800 mb-4 flex items-center">
              <ImageIcon className="h-5 w-5 mr-2 text-[#105640]" />
              Logo & Branding
            </h2>
            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="flex items-center space-x-6">
                <div className="flex-shrink-0">
                  <div className="w-24 h-24 bg-white rounded-lg border flex items-center justify-center overflow-hidden">
                    <img src={settings.logo} alt="Platform Logo" className="max-w-full max-h-full" />
                  </div>
                </div>
                <div className="flex-grow">
                  <p className="text-sm text-gray-600 mb-2">
                    Upload your platform logo. Recommended size: 200x200px.
                  </p>
                  <label className="inline-flex items-center px-4 py-2 bg-white border border-gray-300 rounded-lg shadow-sm cursor-pointer hover:bg-gray-50 focus:outline-none">
                    <UploadIcon className="h-4 w-4 mr-2 text-gray-500" />
                    <span className="text-sm text-gray-700">
                      Upload New Logo
                    </span>
                    <input type="file" className="hidden" accept="image/*" />
                  </label>
                </div>
              </div>
            </div>
          </div>
          {/* Localization */}
          <div className="md:col-span-2">
            <h2 className="text-lg font-medium text-gray-800 mb-4">
              Localization
            </h2>
            <div className="bg-gray-50 p-4 rounded-lg space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="timeZone" className="block text-sm font-medium text-gray-700 mb-1">
                    Default Time Zone
                  </label>
                  <select id="timeZone" name="timeZone" value={settings.timeZone} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                    <option value="America/New_York">Eastern Time (ET)</option>
                    <option value="America/Chicago">Central Time (CT)</option>
                    <option value="America/Denver">Mountain Time (MT)</option>
                    <option value="America/Los_Angeles">
                      Pacific Time (PT)
                    </option>
                    <option value="Europe/London">
                      Greenwich Mean Time (GMT)
                    </option>
                  </select>
                </div>
                <div>
                  <label htmlFor="language" className="block text-sm font-medium text-gray-700 mb-1">
                    Default Language
                  </label>
                  <select id="language" name="language" value={settings.language} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                    <option value="en-US">English (US)</option>
                    <option value="en-GB">English (UK)</option>
                    <option value="es">Spanish</option>
                    <option value="fr">French</option>
                  </select>
                </div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="dateFormat" className="block text-sm font-medium text-gray-700 mb-1">
                    Date Format
                  </label>
                  <select id="dateFormat" name="dateFormat" value={settings.dateFormat} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                    <option value="MM/DD/YYYY">MM/DD/YYYY</option>
                    <option value="DD/MM/YYYY">DD/MM/YYYY</option>
                    <option value="YYYY-MM-DD">YYYY-MM-DD</option>
                  </select>
                </div>
                <div>
                  <label htmlFor="timeFormat" className="block text-sm font-medium text-gray-700 mb-1">
                    Time Format
                  </label>
                  <select id="timeFormat" name="timeFormat" value={settings.timeFormat} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                    <option value="12h">12-hour (AM/PM)</option>
                    <option value="24h">24-hour</option>
                  </select>
                </div>
              </div>
            </div>
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
export default GeneralSettings;