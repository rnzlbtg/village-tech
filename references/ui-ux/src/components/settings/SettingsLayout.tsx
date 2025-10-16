import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Settings2Icon, ShieldIcon, BellIcon, GlobeIcon, UserIcon, KeyIcon, MailIcon } from 'lucide-react';
interface SettingsLayoutProps {
  children: React.ReactNode;
}
const SettingsLayout: React.FC<SettingsLayoutProps> = ({
  children
}) => {
  const location = useLocation();
  const currentPath = location.pathname;
  const tabs = [{
    name: 'General',
    path: '/settings/general',
    icon: Settings2Icon
  }, {
    name: 'Security',
    path: '/settings/security',
    icon: ShieldIcon
  }, {
    name: 'Notifications',
    path: '/settings/notifications',
    icon: BellIcon
  }];
  return <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-800">Platform Settings</h1>
        <p className="text-sm text-gray-600 mt-1">
          Manage your platform configuration and preferences
        </p>
      </div>
      <div className="bg-white rounded-lg shadow">
        <div className="border-b">
          <div className="flex overflow-x-auto">
            {tabs.map(tab => <Link key={tab.name} to={tab.path} className={`px-6 py-4 font-medium text-sm focus:outline-none whitespace-nowrap ${currentPath === tab.path ? 'border-b-2 border-[#105640] text-[#105640]' : 'text-gray-500 hover:text-gray-700'}`}>
                <div className="flex items-center">
                  <tab.icon className={`h-4 w-4 mr-2 ${currentPath === tab.path ? 'text-[#105640]' : 'text-gray-500'}`} />
                  {tab.name}
                </div>
              </Link>)}
          </div>
        </div>
        <div className="p-6">{children}</div>
      </div>
    </div>;
};
export default SettingsLayout;