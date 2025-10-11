import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { HomeIcon, BuildingIcon, UsersIcon, SettingsIcon, ChevronDownIcon, ChevronRightIcon, LayersIcon, BarChart3Icon, HelpCircleIcon } from 'lucide-react';
const Sidebar: React.FC = () => {
  const location = useLocation();
  const [expandedSection, setExpandedSection] = useState<string | null>('communities');
  const mainNavItems = [{
    name: 'Dashboard',
    icon: HomeIcon,
    path: '/'
  }, {
    name: 'Communities',
    icon: BuildingIcon,
    path: '/communities',
    submenu: [{
      name: 'All Communities',
      path: '/communities'
    }, {
      name: 'Add New',
      path: '/communities/new'
    }, {
      name: 'Gates Management',
      path: '/gates'
    }]
  }, {
    name: 'Users',
    icon: UsersIcon,
    path: '/users',
    submenu: [{
      name: 'All Users',
      path: '/users'
    }, {
      name: 'Add User',
      path: '/users/new'
    }, {
      name: 'Roles & Permissions',
      path: '/users/roles'
    }]
  }, {
    name: 'Reports',
    icon: BarChart3Icon,
    path: '/reports'
  }, {
    name: 'Settings',
    icon: SettingsIcon,
    path: '/settings',
    submenu: [{
      name: 'General',
      path: '/settings/general'
    }, {
      name: 'Security',
      path: '/settings/security'
    }, {
      name: 'Notifications',
      path: '/settings/notifications'
    }]
  }];
  const toggleSection = (section: string) => {
    if (expandedSection === section) {
      setExpandedSection(null);
    } else {
      setExpandedSection(section);
    }
  };
  const isActive = (path: string) => {
    if (path === '/') {
      return location.pathname === '/';
    }
    return location.pathname.startsWith(path);
  };
  return <div className="bg-white w-64 h-full shadow-md flex flex-col overflow-hidden">
      <div className="p-6 border-b">
        <h1 className="text-2xl font-bold text-[#105640]">ResidenceHub</h1>
        <p className="text-sm text-gray-600">Platform Administration</p>
      </div>
      <div className="flex-1 overflow-y-auto py-4">
        <nav className="px-3">
          {mainNavItems.map(item => <div key={item.name} className="mb-2">
              {item.submenu ? <div>
                  <button onClick={() => toggleSection(item.name.toLowerCase())} className={`w-full flex items-center justify-between py-3 px-4 rounded-lg hover:bg-gray-100 ${isActive(item.path) ? 'bg-[#F0F9F6] text-[#105640]' : 'text-gray-700'}`}>
                    <div className="flex items-center">
                      <item.icon className={`h-5 w-5 mr-3 ${isActive(item.path) ? 'text-[#105640]' : 'text-gray-500'}`} />
                      <span className={`${isActive(item.path) ? 'font-medium text-[#105640]' : ''}`}>
                        {item.name}
                      </span>
                    </div>
                    {expandedSection === item.name.toLowerCase() ? <ChevronDownIcon className="h-4 w-4" /> : <ChevronRightIcon className="h-4 w-4" />}
                  </button>
                  {expandedSection === item.name.toLowerCase() && <div className="mt-1 ml-4 pl-4 border-l border-gray-200">
                      {item.submenu.map(subItem => <Link key={subItem.name} to={subItem.path} className={`flex items-center py-2 px-3 text-sm rounded-lg ${location.pathname === subItem.path ? 'bg-[#F0F9F6] text-[#105640] font-medium' : 'text-gray-600 hover:bg-gray-50'}`}>
                          {subItem.name}
                        </Link>)}
                    </div>}
                </div> : <Link to={item.path} className={`flex items-center py-3 px-4 rounded-lg hover:bg-gray-100 ${isActive(item.path) ? 'bg-[#F0F9F6] text-[#105640]' : 'text-gray-700'}`}>
                  <item.icon className={`h-5 w-5 mr-3 ${isActive(item.path) ? 'text-[#105640]' : 'text-gray-500'}`} />
                  <span className={`${isActive(item.path) ? 'font-medium text-[#105640]' : ''}`}>
                    {item.name}
                  </span>
                </Link>}
            </div>)}
        </nav>
      </div>
      <div className="p-4 border-t">
        <Link to="/help" className="flex items-center py-2 px-4 text-sm text-gray-600 hover:bg-gray-50 rounded-lg">
          <HelpCircleIcon className="h-5 w-5 mr-3 text-gray-500" />
          Help & Support
        </Link>
      </div>
    </div>;
};
export default Sidebar;