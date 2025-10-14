import React, { useState } from 'react';
import { Sidebar, SidebarContent, SidebarGroup, SidebarGroupContent, SidebarGroupLabel, SidebarMenu, SidebarMenuButton, SidebarMenuItem, SidebarProvider, SidebarTrigger } from './components/ui/sidebar';
import { Button } from './components/ui/button';
import { TooltipProvider } from './components/ui/tooltip';
import { Building2, Home, Shield, Users, Settings, BarChart3, Plus, MapPin, LogOut } from 'lucide-react';
import { Dashboard } from './components/Dashboard';
import { TenantManagement } from './components/TenantManagement';
import { ResidenceSetup } from './components/ResidenceSetup';
import { GateManagement } from './components/GateManagement';
import { UserProvisioning } from './components/UserProvisioning';
import { PlatformConfiguration } from './components/PlatformConfiguration';
import { PlatformAnalytics } from './components/PlatformAnalytics';
import { Login } from './components/Login';

export default function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [activeSection, setActiveSection] = useState('dashboard');

  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: BarChart3 },
    { id: 'tenants', label: 'Tenant Management', icon: Building2 },
    { id: 'residences', label: 'Residence Setup', icon: Home },
    { id: 'gates', label: 'Gate Management', icon: Shield },
    { id: 'users', label: 'User Provisioning', icon: Users },
    { id: 'config', label: 'Configuration', icon: Settings },
    { id: 'analytics', label: 'Analytics', icon: BarChart3 },
  ];

  const renderContent = () => {
    switch (activeSection) {
      case 'dashboard':
        return <Dashboard />;
      case 'tenants':
        return <TenantManagement />;
      case 'residences':
        return <ResidenceSetup />;
      case 'gates':
        return <GateManagement />;
      case 'users':
        return <UserProvisioning />;
      case 'config':
        return <PlatformConfiguration />;
      case 'analytics':
        return <PlatformAnalytics />;
      default:
        return <Dashboard />;
    }
  };

  const handleLogin = () => {
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setActiveSection('dashboard');
  };

  // Show login page if not authenticated
  if (!isAuthenticated) {
    return <Login onLogin={handleLogin} />;
  }

  return (
    <TooltipProvider>
      <SidebarProvider>
        <div className="flex min-h-screen w-full bg-[#f8faf9]">
          <Sidebar className="border-r border-[#d1dcd6] bg-white shadow-sm">
            <SidebarContent>
              <div className="px-8 py-8 border-b border-[#d1dcd6]">
                <div className="flex items-center space-x-4">
                  <div className="w-12 h-12 bg-gradient-to-br from-[#105640] to-[#2D7D5C] rounded-xl flex items-center justify-center shadow-lg">
                    <Building2 className="h-6 w-6 text-white" />
                  </div>
                  <div>
                    <h1 className="text-xl font-semibold text-[#105640]">Village Tech</h1>
                    <p className="text-sm text-[#5a6c63] mt-0.5">Platform Admin</p>
                  </div>
                </div>
              </div>
              
              <div className="px-4 py-6">
                <SidebarGroup>
                  <SidebarGroupLabel className="text-xs font-semibold text-[#2D7D5C] uppercase tracking-wider mb-4 px-4">
                    Platform Management
                  </SidebarGroupLabel>
                  <SidebarGroupContent>
                    <SidebarMenu className="space-y-1.5">
                      {menuItems.map((item) => (
                        <SidebarMenuItem key={item.id}>
                          <SidebarMenuButton
                            onClick={() => setActiveSection(item.id)}
                            isActive={activeSection === item.id}
                            className="w-full justify-start py-3 px-4 text-[#5a6c63] hover:text-[#105640] hover:bg-[#f0f4f2] rounded-lg transition-all duration-200 data-[active=true]:bg-gradient-to-r data-[active=true]:from-[#105640] data-[active=true]:to-[#2D7D5C] data-[active=true]:text-white data-[active=true]:shadow-md"
                          >
                            <item.icon className="h-5 w-5 mr-3" />
                            <span className="font-medium">{item.label}</span>
                          </SidebarMenuButton>
                        </SidebarMenuItem>
                      ))}
                    </SidebarMenu>
                  </SidebarGroupContent>
                </SidebarGroup>
              </div>
            </SidebarContent>
          </Sidebar>

          <main className="flex-1 overflow-auto">
            <div className="bg-white border-b border-[#d1dcd6] shadow-sm">
              <div className="flex h-16 items-center justify-between px-8">
                <div className="flex items-center space-x-4">
                  <SidebarTrigger className="text-[#5a6c63] hover:text-[#105640] hover:bg-[#f0f4f2] rounded-lg" />
                  <div className="h-6 w-px bg-[#d1dcd6]"></div>
                  <h2 className="text-lg font-semibold text-[#105640] capitalize">
                    {menuItems.find(item => item.id === activeSection)?.label || 'Dashboard'}
                  </h2>
                </div>
                <div className="flex items-center space-x-3">
                  <Button size="sm" className="bg-[#F59E0B] hover:bg-[#d97706] text-white border-0 shadow-md hover:shadow-lg transition-all duration-200">
                    <Plus className="h-4 w-4 mr-2" />
                    New Tenant
                  </Button>
                  <Button 
                    size="sm" 
                    variant="outline" 
                    className="border-[#d1dcd6] text-[#5a6c63] hover:bg-[#f0f4f2] hover:text-[#105640] hover:border-[#105640]"
                    onClick={handleLogout}
                  >
                    <LogOut className="h-4 w-4 mr-2" />
                    Logout
                  </Button>
                </div>
              </div>
            </div>
            
            <div className="p-8">
              {renderContent()}
            </div>
          </main>
        </div>
      </SidebarProvider>
    </TooltipProvider>
  );
}