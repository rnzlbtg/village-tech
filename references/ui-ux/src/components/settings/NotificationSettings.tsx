import React, { useState } from 'react';
import { BellIcon, MailIcon, SmartphoneIcon, SaveIcon, CheckIcon } from 'lucide-react';
const NotificationSettings: React.FC = () => {
  const [settings, setSettings] = useState({
    emailNotifications: {
      newCommunity: true,
      userRegistration: true,
      securityAlerts: true,
      systemUpdates: true,
      maintenanceAlerts: true
    },
    smsNotifications: {
      securityAlerts: false,
      systemUpdates: false,
      maintenanceAlerts: true
    },
    inAppNotifications: {
      newCommunity: true,
      userRegistration: true,
      securityAlerts: true,
      systemUpdates: true,
      maintenanceAlerts: true,
      activityLogs: true
    },
    digestEmails: {
      enabled: true,
      frequency: 'weekly'
    },
    quietHours: {
      enabled: false,
      startTime: '22:00',
      endTime: '07:00'
    }
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const handleToggle = (category: string, setting: string) => {
    setSettings({
      ...settings,
      [category]: {
        ...settings[category as keyof typeof settings],
        [setting]: !settings[category as keyof typeof settings][setting as keyof (typeof settings)[keyof typeof settings]]
      }
    });
  };
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const {
      name,
      value
    } = e.target;
    if (name.includes('.')) {
      const [section, field] = name.split('.');
      setSettings({
        ...settings,
        [section]: {
          ...settings[section as keyof typeof settings],
          [field]: value
        }
      });
    }
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
                Notification settings updated successfully!
              </p>
            </div>
          </div>}
        {/* Email Notifications */}
        <div>
          <h2 className="text-lg font-medium text-gray-800 mb-4 flex items-center">
            <MailIcon className="h-5 w-5 mr-2 text-[#105640]" />
            Email Notifications
          </h2>
          <div className="bg-gray-50 p-4 rounded-lg">
            <div className="space-y-3">
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">
                    New Community Added
                  </h3>
                  <p className="text-sm text-gray-600">
                    Receive an email when a new community is added
                  </p>
                </div>
                <button type="button" onClick={() => handleToggle('emailNotifications', 'newCommunity')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.emailNotifications.newCommunity ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.emailNotifications.newCommunity ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">
                    User Registration
                  </h3>
                  <p className="text-sm text-gray-600">
                    Receive an email when a new user registers
                  </p>
                </div>
                <button type="button" onClick={() => handleToggle('emailNotifications', 'userRegistration')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.emailNotifications.userRegistration ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.emailNotifications.userRegistration ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">Security Alerts</h3>
                  <p className="text-sm text-gray-600">
                    Receive an email for security-related events
                  </p>
                </div>
                <button type="button" onClick={() => handleToggle('emailNotifications', 'securityAlerts')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.emailNotifications.securityAlerts ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.emailNotifications.securityAlerts ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">System Updates</h3>
                  <p className="text-sm text-gray-600">
                    Receive an email about system updates and new features
                  </p>
                </div>
                <button type="button" onClick={() => handleToggle('emailNotifications', 'systemUpdates')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.emailNotifications.systemUpdates ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.emailNotifications.systemUpdates ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
            </div>
          </div>
        </div>
        {/* SMS Notifications */}
        <div>
          <h2 className="text-lg font-medium text-gray-800 mb-4 flex items-center">
            <SmartphoneIcon className="h-5 w-5 mr-2 text-[#105640]" />
            SMS Notifications
          </h2>
          <div className="bg-gray-50 p-4 rounded-lg">
            <div className="space-y-3">
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">Security Alerts</h3>
                  <p className="text-sm text-gray-600">
                    Receive SMS for critical security alerts
                  </p>
                </div>
                <button type="button" onClick={() => handleToggle('smsNotifications', 'securityAlerts')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.smsNotifications.securityAlerts ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.smsNotifications.securityAlerts ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">System Updates</h3>
                  <p className="text-sm text-gray-600">
                    Receive SMS about important system updates
                  </p>
                </div>
                <button type="button" onClick={() => handleToggle('smsNotifications', 'systemUpdates')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.smsNotifications.systemUpdates ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.smsNotifications.systemUpdates ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">
                    Maintenance Alerts
                  </h3>
                  <p className="text-sm text-gray-600">
                    Receive SMS about scheduled maintenance
                  </p>
                </div>
                <button type="button" onClick={() => handleToggle('smsNotifications', 'maintenanceAlerts')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.smsNotifications.maintenanceAlerts ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.smsNotifications.maintenanceAlerts ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
            </div>
          </div>
        </div>
        {/* In-App Notifications */}
        <div>
          <h2 className="text-lg font-medium text-gray-800 mb-4 flex items-center">
            <BellIcon className="h-5 w-5 mr-2 text-[#105640]" />
            In-App Notifications
          </h2>
          <div className="bg-gray-50 p-4 rounded-lg">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">
                    New Community Added
                  </h3>
                </div>
                <button type="button" onClick={() => handleToggle('inAppNotifications', 'newCommunity')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.inAppNotifications.newCommunity ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.inAppNotifications.newCommunity ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">
                    User Registration
                  </h3>
                </div>
                <button type="button" onClick={() => handleToggle('inAppNotifications', 'userRegistration')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.inAppNotifications.userRegistration ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.inAppNotifications.userRegistration ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">Security Alerts</h3>
                </div>
                <button type="button" onClick={() => handleToggle('inAppNotifications', 'securityAlerts')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.inAppNotifications.securityAlerts ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.inAppNotifications.securityAlerts ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">System Updates</h3>
                </div>
                <button type="button" onClick={() => handleToggle('inAppNotifications', 'systemUpdates')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.inAppNotifications.systemUpdates ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.inAppNotifications.systemUpdates ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">
                    Maintenance Alerts
                  </h3>
                </div>
                <button type="button" onClick={() => handleToggle('inAppNotifications', 'maintenanceAlerts')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.inAppNotifications.maintenanceAlerts ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.inAppNotifications.maintenanceAlerts ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
              <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
                <div>
                  <h3 className="font-medium text-gray-800">Activity Logs</h3>
                </div>
                <button type="button" onClick={() => handleToggle('inAppNotifications', 'activityLogs')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.inAppNotifications.activityLogs ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                  <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.inAppNotifications.activityLogs ? 'translate-x-6' : ''}`}></div>
                </button>
              </div>
            </div>
          </div>
        </div>
        {/* Notification Preferences */}
        <div>
          <h2 className="text-lg font-medium text-gray-800 mb-4">
            Notification Preferences
          </h2>
          <div className="bg-gray-50 p-4 rounded-lg space-y-4">
            <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
              <div>
                <h3 className="font-medium text-gray-800">
                  Weekly Digest Email
                </h3>
                <p className="text-sm text-gray-600">
                  Receive a weekly summary of all activity
                </p>
              </div>
              <button type="button" onClick={() => handleToggle('digestEmails', 'enabled')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.digestEmails.enabled ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.digestEmails.enabled ? 'translate-x-6' : ''}`}></div>
              </button>
            </div>
            {settings.digestEmails.enabled && <div>
                <label htmlFor="digestEmails.frequency" className="block text-sm font-medium text-gray-700 mb-1">
                  Digest Frequency
                </label>
                <select id="digestEmails.frequency" name="digestEmails.frequency" value={settings.digestEmails.frequency} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                  <option value="daily">Daily</option>
                  <option value="weekly">Weekly</option>
                  <option value="monthly">Monthly</option>
                </select>
              </div>}
            <div className="flex justify-between items-center p-3 border rounded-lg bg-white">
              <div>
                <h3 className="font-medium text-gray-800">Quiet Hours</h3>
                <p className="text-sm text-gray-600">
                  Disable notifications during specific hours
                </p>
              </div>
              <button type="button" onClick={() => handleToggle('quietHours', 'enabled')} className={`w-12 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${settings.quietHours.enabled ? 'bg-[#105640]' : 'bg-gray-300'}`}>
                <div className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${settings.quietHours.enabled ? 'translate-x-6' : ''}`}></div>
              </button>
            </div>
            {settings.quietHours.enabled && <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="quietHours.startTime" className="block text-sm font-medium text-gray-700 mb-1">
                    Start Time
                  </label>
                  <input type="time" id="quietHours.startTime" name="quietHours.startTime" value={settings.quietHours.startTime} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
                </div>
                <div>
                  <label htmlFor="quietHours.endTime" className="block text-sm font-medium text-gray-700 mb-1">
                    End Time
                  </label>
                  <input type="time" id="quietHours.endTime" name="quietHours.endTime" value={settings.quietHours.endTime} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
                </div>
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
export default NotificationSettings;