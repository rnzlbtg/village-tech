import React from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { Building2, Users, Shield, TrendingUp, Activity, AlertTriangle } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';

const mockStats = {
  totalTenants: 48,
  activeTenants: 45,
  totalResidences: 12450,
  totalUsers: 28750,
  activeGates: 156,
  monthlyGrowth: 12.5
};

const usageData = [
  { month: 'Jan', tenants: 35, users: 18500 },
  { month: 'Feb', tenants: 38, users: 20200 },
  { month: 'Mar', tenants: 41, users: 22800 },
  { month: 'Apr', tenants: 43, users: 25100 },
  { month: 'May', tenants: 45, users: 27300 },
  { month: 'Jun', tenants: 48, users: 28750 },
];

const tenantActivity = [
  { name: 'Sunset Gardens', users: 1250, gates: 4, status: 'active' },
  { name: 'Oak Valley Estates', users: 890, gates: 3, status: 'active' },
  { name: 'Pine Ridge Community', users: 1100, gates: 5, status: 'active' },
  { name: 'Maple Grove', users: 750, gates: 2, status: 'trial' },
  { name: 'Cedar Hills', users: 980, gates: 3, status: 'active' },
];

export function Dashboard() {
  return (
    <div className="space-y-6">
      <div>
        <h1>Platform Overview</h1>
        <p className="text-muted-foreground">
          Monitor and manage all residential communities on the Village Tech platform
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Communities</CardTitle>
            <Building2 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{mockStats.totalTenants}</div>
            <p className="text-xs text-muted-foreground">
              <span className="text-green-600">+{mockStats.monthlyGrowth}%</span> from last month
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Communities</CardTitle>
            <Activity className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{mockStats.activeTenants}</div>
            <p className="text-xs text-muted-foreground">
              {mockStats.totalTenants - mockStats.activeTenants} suspended/trial
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Users</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{mockStats.totalUsers.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground">
              Across all communities
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Gates</CardTitle>
            <Shield className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{mockStats.activeGates}</div>
            <p className="text-xs text-muted-foreground">
              Monitoring access points
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Charts Row */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Growth Trends</CardTitle>
            <CardDescription>
              Community and user growth over the last 6 months
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={usageData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Line 
                  type="monotone" 
                  dataKey="tenants" 
                  stroke="#8884d8" 
                  strokeWidth={2}
                  name="Communities"
                />
                <Line 
                  type="monotone" 
                  dataKey="users" 
                  stroke="#82ca9d" 
                  strokeWidth={2}
                  name="Users"
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Community Activity</CardTitle>
            <CardDescription>
              Most active communities by user count
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={tenantActivity}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="users" fill="#8884d8" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Community Activity</CardTitle>
          <CardDescription>
            Latest updates from your managed communities
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {tenantActivity.map((community, index) => (
              <div key={index} className="flex items-center justify-between border-b pb-2 last:border-b-0">
                <div className="flex items-center space-x-3">
                  <Building2 className="h-5 w-5 text-muted-foreground" />
                  <div>
                    <p className="font-medium">{community.name}</p>
                    <p className="text-sm text-muted-foreground">
                      {community.users} users • {community.gates} gates
                    </p>
                  </div>
                </div>
                <Badge variant={community.status === 'active' ? 'default' : 'secondary'}>
                  {community.status}
                </Badge>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* System Health */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Activity className="h-5 w-5 text-green-600" />
              <span>System Health</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-sm">API Response</span>
                <span className="text-sm text-green-600">98.5ms</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm">Uptime</span>
                <span className="text-sm text-green-600">99.9%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm">Active Connections</span>
                <span className="text-sm">1,247</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <AlertTriangle className="h-5 w-5 text-yellow-600" />
              <span>Alerts</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <p className="text-sm">2 communities approaching user limits</p>
              <p className="text-sm">1 gate offline (Cedar Hills)</p>
              <p className="text-sm">5 pending user provisioning requests</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <TrendingUp className="h-5 w-5 text-blue-600" />
              <span>Quick Stats</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-sm">New signups today</span>
                <span className="text-sm font-medium">143</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm">Gate entries today</span>
                <span className="text-sm font-medium">8,521</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm">Support tickets</span>
                <span className="text-sm font-medium">12</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}