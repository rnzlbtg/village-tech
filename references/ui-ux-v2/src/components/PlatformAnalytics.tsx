import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from './ui/table';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell, Area, AreaChart } from 'recharts';
import { TrendingUp, TrendingDown, Users, Building2, Shield, DollarSign, Activity, AlertTriangle, Eye, Download, Calendar, Filter } from 'lucide-react';
import { DatePickerWithRange } from './ui/date-range-picker';
import { Separator } from './ui/separator';

const mockAnalyticsData = {
  platformStats: {
    totalRevenue: 487250,
    activeSubscriptions: 45,
    totalUsers: 28750,
    gatePasses: 156420,
    monthlyGrowth: 12.5,
    churnRate: 2.3,
  },
  tenantGrowth: [
    { month: 'Jan', tenants: 35, revenue: 98000 },
    { month: 'Feb', tenants: 38, revenue: 106400 },
    { month: 'Mar', tenants: 41, revenue: 114800 },
    { month: 'Apr', tenants: 43, revenue: 120400 },
    { month: 'May', tenants: 45, revenue: 126000 },
    { month: 'Jun', tenants: 48, revenue: 134400 },
  ],
  usageMetrics: [
    { date: '2024-01-01', logins: 1250, gateEntries: 3200, incidents: 5 },
    { date: '2024-01-02', logins: 1180, gateEntries: 2950, incidents: 3 },
    { date: '2024-01-03', logins: 1320, gateEntries: 3450, incidents: 7 },
    { date: '2024-01-04', logins: 1280, gateEntries: 3100, incidents: 4 },
    { date: '2024-01-05', logins: 1450, gateEntries: 3600, incidents: 6 },
    { date: '2024-01-06', logins: 1380, gateEntries: 3300, incidents: 2 },
    { date: '2024-01-07', logins: 1520, gateEntries: 3800, incidents: 8 },
  ],
  tenantBreakdown: [
    { name: 'Active', value: 42, color: '#22c55e' },
    { name: 'Trial', value: 6, color: '#3b82f6' },
    { name: 'Suspended', value: 3, color: '#ef4444' },
  ],
  topTenants: [
    { name: 'Sunset Gardens HOA', users: 1250, revenue: 8750, growth: 15.2 },
    { name: 'Oak Valley Estates', users: 890, revenue: 6230, growth: 8.7 },
    { name: 'Pine Ridge Community', users: 1100, revenue: 7700, growth: 12.1 },
    { name: 'Maple Grove HOA', users: 750, revenue: 5250, growth: -2.3 },
    { name: 'Cedar Hills', users: 980, revenue: 6860, growth: 9.4 },
  ],
  auditLogs: [
    { timestamp: '2024-01-15 14:30:22', user: 'admin@villagetech.com', action: 'Created new tenant: Willow Creek HOA', ip: '192.168.1.100' },
    { timestamp: '2024-01-15 13:45:11', user: 'admin@villagetech.com', action: 'Updated gate configuration for Sunset Gardens', ip: '192.168.1.100' },
    { timestamp: '2024-01-15 12:20:05', user: 'admin@villagetech.com', action: 'Generated platform analytics report', ip: '192.168.1.100' },
    { timestamp: '2024-01-15 11:15:33', user: 'admin@villagetech.com', action: 'Provisioned admin user for Oak Valley Estates', ip: '192.168.1.100' },
    { timestamp: '2024-01-15 10:30:44', user: 'admin@villagetech.com', action: 'Updated fee structure for Pine Ridge Community', ip: '192.168.1.100' },
  ],
};

export function PlatformAnalytics() {
  const [timeRange, setTimeRange] = useState('30d');
  const [selectedMetric, setSelectedMetric] = useState('all');

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(value);
  };

  const formatNumber = (value) => {
    return new Intl.NumberFormat('en-US').format(value);
  };

  const getGrowthColor = (growth) => {
    return growth >= 0 ? 'text-green-600' : 'text-red-600';
  };

  const getGrowthIcon = (growth) => {
    return growth >= 0 ? TrendingUp : TrendingDown;
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1>Platform Analytics</h1>
          <p className="text-muted-foreground">
            Monitor platform performance, usage metrics, and business intelligence
          </p>
        </div>
        <div className="flex space-x-2">
          <Select value={timeRange} onValueChange={setTimeRange}>
            <SelectTrigger className="w-[120px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="7d">Last 7 days</SelectItem>
              <SelectItem value="30d">Last 30 days</SelectItem>
              <SelectItem value="90d">Last 90 days</SelectItem>
              <SelectItem value="1y">Last year</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(mockAnalyticsData.platformStats.totalRevenue)}</div>
            <p className="text-xs text-muted-foreground">
              <span className={getGrowthColor(mockAnalyticsData.platformStats.monthlyGrowth)}>
                +{mockAnalyticsData.platformStats.monthlyGrowth}%
              </span> from last month
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Communities</CardTitle>
            <Building2 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{mockAnalyticsData.platformStats.activeSubscriptions}</div>
            <p className="text-xs text-muted-foreground">
              Churn rate: {mockAnalyticsData.platformStats.churnRate}%
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Users</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatNumber(mockAnalyticsData.platformStats.totalUsers)}</div>
            <p className="text-xs text-muted-foreground">
              Across all communities
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Gate Passes</CardTitle>
            <Shield className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatNumber(mockAnalyticsData.platformStats.gatePasses)}</div>
            <p className="text-xs text-muted-foreground">
              This month
            </p>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="overview" className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="tenants">Community Performance</TabsTrigger>
          <TabsTrigger value="usage">Usage Analytics</TabsTrigger>
          <TabsTrigger value="billing">Billing & Revenue</TabsTrigger>
          <TabsTrigger value="system">System Health</TabsTrigger>
          <TabsTrigger value="audit">Audit Logs</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>Platform Growth</CardTitle>
                <CardDescription>
                  Community count and revenue growth over time
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={300}>
                  <AreaChart data={mockAnalyticsData.tenantGrowth}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="month" />
                    <YAxis />
                    <Tooltip />
                    <Area 
                      type="monotone" 
                      dataKey="tenants" 
                      stackId="1"
                      stroke="#8884d8" 
                      fill="#8884d8"
                      name="Communities"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Community Status</CardTitle>
                <CardDescription>
                  Distribution of community subscription statuses
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie
                      data={mockAnalyticsData.tenantBreakdown}
                      cx="50%"
                      cy="50%"
                      innerRadius={60}
                      outerRadius={100}
                      paddingAngle={5}
                      dataKey="value"
                    >
                      {mockAnalyticsData.tenantBreakdown.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
                <div className="flex justify-center space-x-4 mt-4">
                  {mockAnalyticsData.tenantBreakdown.map((entry, index) => (
                    <div key={index} className="flex items-center space-x-2">
                      <div 
                        className="w-3 h-3 rounded-full" 
                        style={{ backgroundColor: entry.color }}
                      />
                      <span className="text-sm">{entry.name}: {entry.value}</span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Top Performing Communities</CardTitle>
              <CardDescription>
                Communities ranked by user count and revenue
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Community</TableHead>
                    <TableHead>Users</TableHead>
                    <TableHead>Monthly Revenue</TableHead>
                    <TableHead>Growth Rate</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {mockAnalyticsData.topTenants.map((tenant, index) => {
                    const GrowthIcon = getGrowthIcon(tenant.growth);
                    return (
                      <TableRow key={index}>
                        <TableCell>
                          <div className="flex items-center space-x-2">
                            <Building2 className="h-4 w-4 text-muted-foreground" />
                            <span className="font-medium">{tenant.name}</span>
                          </div>
                        </TableCell>
                        <TableCell>{formatNumber(tenant.users)}</TableCell>
                        <TableCell>{formatCurrency(tenant.revenue)}</TableCell>
                        <TableCell>
                          <div className={`flex items-center space-x-1 ${getGrowthColor(tenant.growth)}`}>
                            <GrowthIcon className="h-3 w-3" />
                            <span>{Math.abs(tenant.growth)}%</span>
                          </div>
                        </TableCell>
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="usage" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Daily Usage Metrics</CardTitle>
              <CardDescription>
                User activity and system usage over the last 7 days
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={400}>
                <LineChart data={mockAnalyticsData.usageMetrics}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis />
                  <Tooltip />
                  <Line 
                    type="monotone" 
                    dataKey="logins" 
                    stroke="#8884d8" 
                    strokeWidth={2}
                    name="User Logins"
                  />
                  <Line 
                    type="monotone" 
                    dataKey="gateEntries" 
                    stroke="#82ca9d" 
                    strokeWidth={2}
                    name="Gate Entries"
                  />
                  <Line 
                    type="monotone" 
                    dataKey="incidents" 
                    stroke="#ffc658" 
                    strokeWidth={2}
                    name="Incidents"
                  />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          <div className="grid gap-4 md:grid-cols-3">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Average Daily Logins</CardTitle>
                <Activity className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">1,340</div>
                <p className="text-xs text-muted-foreground">
                  <span className="text-green-600">+8.5%</span> from last week
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Gate Entries/Day</CardTitle>
                <Shield className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">3,343</div>
                <p className="text-xs text-muted-foreground">
                  <span className="text-green-600">+12.3%</span> from last week
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Incident Reports</CardTitle>
                <AlertTriangle className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">5</div>
                <p className="text-xs text-muted-foreground">
                  <span className="text-red-600">+2</span> from last week
                </p>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="billing" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Monthly Revenue Trend</CardTitle>
              <CardDescription>
                Revenue growth across all communities
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={mockAnalyticsData.tenantGrowth}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="month" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="revenue" fill="#8884d8" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          <div className="grid gap-4 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>Revenue Breakdown</CardTitle>
                <CardDescription>Sources of platform revenue</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex justify-between items-center">
                  <span>Subscription Fees</span>
                  <span className="font-medium">{formatCurrency(420000)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span>Setup Fees</span>
                  <span className="font-medium">{formatCurrency(35000)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span>Premium Features</span>
                  <span className="font-medium">{formatCurrency(25000)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span>Support Services</span>
                  <span className="font-medium">{formatCurrency(7250)}</span>
                </div>
                <Separator />
                <div className="flex justify-between items-center font-medium">
                  <span>Total</span>
                  <span>{formatCurrency(487250)}</span>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Subscription Metrics</CardTitle>
                <CardDescription>Key subscription performance indicators</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex justify-between items-center">
                  <span>Monthly Recurring Revenue</span>
                  <span className="font-medium">{formatCurrency(126000)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span>Average Revenue Per User</span>
                  <span className="font-medium">{formatCurrency(2800)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span>Customer Lifetime Value</span>
                  <span className="font-medium">{formatCurrency(84000)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span>Churn Rate</span>
                  <span className="font-medium">2.3%</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="system" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">System Uptime</CardTitle>
                <Activity className="h-4 w-4 text-green-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">99.97%</div>
                <p className="text-xs text-muted-foreground">Last 30 days</p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">API Response Time</CardTitle>
                <Activity className="h-4 w-4 text-blue-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">145ms</div>
                <p className="text-xs text-muted-foreground">Average response</p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Active Connections</CardTitle>
                <Users className="h-4 w-4 text-purple-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">2,847</div>
                <p className="text-xs text-muted-foreground">Real-time users</p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Error Rate</CardTitle>
                <AlertTriangle className="h-4 w-4 text-yellow-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">0.03%</div>
                <p className="text-xs text-muted-foreground">Last 24 hours</p>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>System Health Monitoring</CardTitle>
              <CardDescription>
                Real-time system performance metrics
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span>Database Performance</span>
                  <Badge variant="default">Healthy</Badge>
                </div>
                <div className="flex items-center justify-between">
                  <span>API Gateway</span>
                  <Badge variant="default">Operational</Badge>
                </div>
                <div className="flex items-center justify-between">
                  <span>Authentication Service</span>
                  <Badge variant="default">Online</Badge>
                </div>
                <div className="flex items-center justify-between">
                  <span>File Storage</span>
                  <Badge variant="default">Available</Badge>
                </div>
                <div className="flex items-center justify-between">
                  <span>Notification Service</span>
                  <Badge variant="secondary">Degraded</Badge>
                </div>
                <div className="flex items-center justify-between">
                  <span>Payment Processing</span>
                  <Badge variant="default">Active</Badge>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="audit" className="space-y-4">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <div>
                  <CardTitle>Audit Logs</CardTitle>
                  <CardDescription>
                    Platform-level operations and administrative actions
                  </CardDescription>
                </div>
                <div className="flex space-x-2">
                  <Select defaultValue="all">
                    <SelectTrigger className="w-[150px]">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Actions</SelectItem>
                      <SelectItem value="create">Create</SelectItem>
                      <SelectItem value="update">Update</SelectItem>
                      <SelectItem value="delete">Delete</SelectItem>
                    </SelectContent>
                  </Select>
                  <Button variant="outline" size="sm">
                    <Filter className="h-4 w-4 mr-2" />
                    Filter
                  </Button>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Timestamp</TableHead>
                    <TableHead>User</TableHead>
                    <TableHead>Action</TableHead>
                    <TableHead>IP Address</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {mockAnalyticsData.auditLogs.map((log, index) => (
                    <TableRow key={index}>
                      <TableCell className="text-sm">{log.timestamp}</TableCell>
                      <TableCell>{log.user}</TableCell>
                      <TableCell>{log.action}</TableCell>
                      <TableCell className="text-sm">{log.ip}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}