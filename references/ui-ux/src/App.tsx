import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import MainLayout from './components/layout/MainLayout';
import Dashboard from './components/Dashboard';
import CommunityList from './components/communities/CommunityList';
import CommunityForm from './components/communities/CommunityForm';
import CommunityDetail from './components/communities/CommunityDetail';
import UserForm from './components/users/UserForm';
import UserList from './components/users/UserList';
import AddUserForm from './components/users/AddUserForm';
import RolesPermissions from './components/users/RolesPermissions';
import SettingsLayout from './components/settings/SettingsLayout';
import GeneralSettings from './components/settings/GeneralSettings';
import SecuritySettings from './components/settings/SecuritySettings';
import NotificationSettings from './components/settings/NotificationSettings';
export function App() {
  return <Router>
      <MainLayout>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/communities" element={<CommunityList />} />
          <Route path="/communities/new" element={<CommunityForm />} />
          <Route path="/communities/:id" element={<CommunityDetail />} />
          <Route path="/communities/:id/users/new" element={<UserForm />} />
          {/* Users Routes */}
          <Route path="/users" element={<UserList />} />
          <Route path="/users/new" element={<AddUserForm />} />
          <Route path="/users/roles" element={<RolesPermissions />} />
          {/* Settings Routes */}
          <Route path="/settings/general" element={<SettingsLayout>
                <GeneralSettings />
              </SettingsLayout>} />
          <Route path="/settings/security" element={<SettingsLayout>
                <SecuritySettings />
              </SettingsLayout>} />
          <Route path="/settings/notifications" element={<SettingsLayout>
                <NotificationSettings />
              </SettingsLayout>} />
        </Routes>
      </MainLayout>
    </Router>;
}