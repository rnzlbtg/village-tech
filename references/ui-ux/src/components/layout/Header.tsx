import React, { useEffect, useState, useRef } from 'react';
import { BellIcon, UserCircleIcon, LogOutIcon, SettingsIcon, HelpCircleIcon, XIcon, CheckIcon } from 'lucide-react';
const Header: React.FC = () => {
  const [notificationsOpen, setNotificationsOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [notifications, setNotifications] = useState([{
    id: 1,
    title: 'New Community Added',
    message: 'Sunset Valley has been added to your communities',
    time: '2 hours ago',
    read: false
  }, {
    id: 2,
    title: 'User Registration',
    message: 'New admin user registered for Maple Grove',
    time: '5 hours ago',
    read: false
  }, {
    id: 3,
    title: 'System Update',
    message: 'Platform will undergo maintenance on Friday, 10 PM',
    time: '1 day ago',
    read: true
  }]);
  const notificationRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);
  // Handle click outside to close dropdowns
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (notificationRef.current && !notificationRef.current.contains(event.target as Node)) {
        setNotificationsOpen(false);
      }
      if (userMenuRef.current && !userMenuRef.current.contains(event.target as Node)) {
        setUserMenuOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);
  // Mark notification as read
  const markAsRead = (id: number) => {
    setNotifications(prev => prev.map(notification => notification.id === id ? {
      ...notification,
      read: true
    } : notification));
  };
  // Mark all notifications as read
  const markAllAsRead = () => {
    setNotifications(prev => prev.map(notification => ({
      ...notification,
      read: true
    })));
  };
  // Count unread notifications
  const unreadCount = notifications.filter(n => !n.read).length;
  return <header className="bg-white shadow h-16 flex items-center justify-between px-6 z-10">
      <div className="flex items-center">
        <h2 className="text-xl font-semibold text-gray-800">
          Platform Administration
        </h2>
      </div>
      <div className="flex items-center space-x-4">
        <div className="relative" ref={notificationRef}>
          <button className="text-gray-500 hover:text-gray-700 relative" onClick={() => setNotificationsOpen(!notificationsOpen)}>
            <BellIcon className="h-6 w-6" />
            {unreadCount > 0 && <span className="absolute -top-1 -right-1 bg-[#F59E0B] text-white text-xs font-bold rounded-full h-4 w-4 flex items-center justify-center">
                {unreadCount}
              </span>}
          </button>
          {notificationsOpen && <div className="absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-lg border overflow-hidden z-10">
              <div className="p-3 border-b flex justify-between items-center">
                <h3 className="font-medium text-gray-800">Notifications</h3>
                {unreadCount > 0 && <button onClick={markAllAsRead} className="text-xs text-[#105640] hover:text-[#2D7D5C]">
                    Mark all as read
                  </button>}
              </div>
              <div className="max-h-96 overflow-y-auto">
                {notifications.length > 0 ? notifications.map(notification => <div key={notification.id} className={`p-3 border-b hover:bg-gray-50 ${!notification.read ? 'bg-[#F0F9F6]' : ''}`}>
                      <div className="flex justify-between">
                        <h4 className="text-sm font-medium text-gray-800">
                          {notification.title}
                        </h4>
                        {!notification.read && <button onClick={() => markAsRead(notification.id)} className="text-[#105640] hover:text-[#2D7D5C]" title="Mark as read">
                            <CheckIcon className="h-4 w-4" />
                          </button>}
                      </div>
                      <p className="text-xs text-gray-600 mt-1">
                        {notification.message}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">
                        {notification.time}
                      </p>
                    </div>) : <div className="p-4 text-center text-gray-500">
                    No notifications
                  </div>}
              </div>
              <div className="p-2 border-t bg-gray-50">
                <button className="w-full text-center text-xs text-[#105640] hover:text-[#2D7D5C] p-1">
                  View all notifications
                </button>
              </div>
            </div>}
        </div>
        <div className="relative" ref={userMenuRef}>
          <button onClick={() => setUserMenuOpen(!userMenuOpen)} className="flex items-center space-x-2 hover:bg-gray-100 p-2 rounded-lg transition-colors duration-200">
            <span className="text-sm font-medium text-gray-700">
              Super Admin
            </span>
            <UserCircleIcon className="h-8 w-8 text-[#105640]" />
          </button>
          {userMenuOpen && <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border overflow-hidden z-10">
              <div className="p-3 border-b">
                <p className="text-sm font-medium text-gray-800">Super Admin</p>
                <p className="text-xs text-gray-500">admin@example.com</p>
              </div>
              <div className="py-1">
                <button className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                  <UserCircleIcon className="h-4 w-4 mr-2 text-gray-500" />
                  My Profile
                </button>
                <button className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                  <SettingsIcon className="h-4 w-4 mr-2 text-gray-500" />
                  Settings
                </button>
                <button className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                  <HelpCircleIcon className="h-4 w-4 mr-2 text-gray-500" />
                  Help & Support
                </button>
              </div>
              <div className="py-1 border-t">
                <button className="flex items-center w-full px-4 py-2 text-sm text-red-600 hover:bg-gray-100">
                  <LogOutIcon className="h-4 w-4 mr-2" />
                  Sign Out
                </button>
              </div>
            </div>}
        </div>
      </div>
    </header>;
};
export default Header;