import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { UserPlusIcon, BoxIcon, EyeIcon, BarChart3Icon, ActivityIcon, AlertTriangleIcon } from 'lucide-react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
const Dashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState('overview');
  // Mock data for demonstration
  const stats = [{
    name: 'Total Communities',
    value: 12,
    icon: BoxIcon,
    change: '+2',
    trend: 'up'
  }, {
    name: 'Total Gates',
    value: 35,
    icon: BoxIcon,
    change: '+5',
    trend: 'up'
  }, {
    name: 'Total Admin Users',
    value: 48,
    icon: UserPlusIcon,
    change: '+3',
    trend: 'up'
  }];
  const recentCommunities = [{
    id: 1,
    name: 'Evergreen Heights',
    units: 150,
    createdAt: '2023-09-15',
    status: 'active'
  }, {
    id: 2,
    name: 'Oakridge Estates',
    units: 200,
    createdAt: '2023-09-10',
    status: 'active'
  }, {
    id: 3,
    name: 'Maple Grove',
    units: 120,
    createdAt: '2023-09-05',
    status: 'pending'
  }];
  const recentActivities = [{
    id: 1,
    action: 'Community Added',
    target: 'Sunset Valley',
    user: 'Admin',
    time: '2 hours ago'
  }, {
    id: 2,
    action: 'User Created',
    target: 'John Smith (Admin Officer)',
    user: 'Admin',
    time: '5 hours ago'
  }, {
    id: 3,
    action: 'Gate Added',
    target: 'West Gate (Maple Grove)',
    user: 'Admin',
    time: '1 day ago'
  }, {
    id: 4,
    action: 'Community Updated',
    target: 'Oakridge Estates',
    user: 'Admin',
    time: '2 days ago'
  }];
  const alerts = [{
    id: 1,
    message: 'Pending user approval for Evergreen Heights',
    severity: 'info'
  }, {
    id: 2,
    message: 'Community setup incomplete: Palm Gardens',
    severity: 'warning'
  }];
  // Data for distribution chart
  const communityDistribution = [{
    name: 'Residential',
    value: 8
  }, {
    name: 'Commercial',
    value: 3
  }, {
    name: 'Mixed-use',
    value: 1
  }];
  const COLORS = ['#105640', '#2D7D5C', '#F59E0B'];
  const renderCustomizedLabel = ({
    cx,
    cy,
    midAngle,
    innerRadius,
    outerRadius,
    percent
  }: any) => {
    const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
    const x = cx + radius * Math.cos(-midAngle * Math.PI / 180);
    const y = cy + radius * Math.sin(-midAngle * Math.PI / 180);
    return <text x={x} y={y} fill="white" textAnchor="middle" dominantBaseline="central">
        {`${(percent * 100).toFixed(0)}%`}
      </text>;
  };
  return <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">Dashboard</h1>
        <Link to="/communities/new" className="bg-[#105640] hover:bg-[#2D7D5C] text-white py-2 px-4 rounded-lg">
          Add New Community
        </Link>
      </div>
      {/* Stats Cards with Animation */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {stats.map(stat => <div key={stat.name} className="bg-white rounded-lg shadow p-6 transition-all duration-300 hover:shadow-lg hover:scale-105">
            <div className="flex items-center">
              <div className="bg-[#F0F9F6] p-3 rounded-lg">
                <stat.icon className="h-6 w-6 text-[#105640]" />
              </div>
              <div className="ml-4">
                <h3 className="text-gray-500 text-sm">{stat.name}</h3>
                <div className="flex items-center">
                  <p className="text-2xl font-semibold text-gray-800">
                    {stat.value}
                  </p>
                  <span className={`ml-2 text-sm ${stat.trend === 'up' ? 'text-green-500' : 'text-red-500'}`}>
                    {stat.change}
                  </span>
                </div>
              </div>
            </div>
          </div>)}
      </div>
      {/* Tabbed Interface */}
      <div className="bg-white rounded-lg shadow">
        <div className="border-b">
          <div className="flex">
            <button className={`px-6 py-3 font-medium text-sm focus:outline-none ${activeTab === 'overview' ? 'border-b-2 border-[#105640] text-[#105640]' : 'text-gray-500 hover:text-gray-700'}`} onClick={() => setActiveTab('overview')}>
              <div className="flex items-center">
                <EyeIcon className="h-4 w-4 mr-2" />
                Overview
              </div>
            </button>
            <button className={`px-6 py-3 font-medium text-sm focus:outline-none ${activeTab === 'analytics' ? 'border-b-2 border-[#105640] text-[#105640]' : 'text-gray-500 hover:text-gray-700'}`} onClick={() => setActiveTab('analytics')}>
              <div className="flex items-center">
                <BarChart3Icon className="h-4 w-4 mr-2" />
                Analytics
              </div>
            </button>
            <button className={`px-6 py-3 font-medium text-sm focus:outline-none ${activeTab === 'activity' ? 'border-b-2 border-[#105640] text-[#105640]' : 'text-gray-500 hover:text-gray-700'}`} onClick={() => setActiveTab('activity')}>
              <div className="flex items-center">
                <ActivityIcon className="h-4 w-4 mr-2" />
                Recent Activity
              </div>
            </button>
            <button className={`px-6 py-3 font-medium text-sm focus:outline-none ${activeTab === 'alerts' ? 'border-b-2 border-[#105640] text-[#105640]' : 'text-gray-500 hover:text-gray-700'}`} onClick={() => setActiveTab('alerts')}>
              <div className="flex items-center">
                <AlertTriangleIcon className="h-4 w-4 mr-2" />
                Alerts
                <span className="ml-2 bg-red-100 text-red-800 text-xs font-medium px-2.5 py-0.5 rounded">
                  {alerts.length}
                </span>
              </div>
            </button>
          </div>
        </div>
        <div className="p-6">
          {activeTab === 'overview' && <div>
              <h2 className="text-lg font-semibold text-gray-800 mb-4">
                Recently Added Communities
              </h2>
              <table className="min-w-full divide-y divide-gray-200">
                <thead>
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Community Name
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Units
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Created Date
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {recentCommunities.map(community => <tr key={community.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">
                          {community.name}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-500">
                          {community.units}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-500">
                          {community.createdAt}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${community.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                          {community.status === 'active' ? 'Active' : 'Pending'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <Link to={`/communities/${community.id}`} className="text-[#105640] hover:text-[#2D7D5C] mr-4">
                          View
                        </Link>
                      </td>
                    </tr>)}
                </tbody>
              </table>
            </div>}
          {activeTab === 'analytics' && <div>
              <h2 className="text-lg font-semibold text-gray-800 mb-4">
                Community Distribution
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="bg-gray-50 p-4 rounded-lg">
                  <div style={{
                width: '100%',
                height: 300
              }}>
                    <ResponsiveContainer>
                      <PieChart>
                        <Pie data={communityDistribution} cx="50%" cy="50%" labelLine={false} label={renderCustomizedLabel} outerRadius={100} fill="#8884d8" dataKey="value">
                          {communityDistribution.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)}
                        </Pie>
                        <Tooltip />
                      </PieChart>
                    </ResponsiveContainer>
                  </div>
                </div>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h3 className="text-md font-medium text-gray-800 mb-3">
                    Distribution by Type
                  </h3>
                  <div className="space-y-4">
                    {communityDistribution.map((item, index) => <div key={item.name} className="flex items-center">
                        <div className="w-4 h-4 rounded-full mr-2" style={{
                    backgroundColor: COLORS[index]
                  }}></div>
                        <div className="flex-1">
                          <div className="flex justify-between mb-1">
                            <span className="text-sm font-medium text-gray-700">
                              {item.name}
                            </span>
                            <span className="text-sm font-medium text-gray-700">
                              {item.value} communities
                            </span>
                          </div>
                          <div className="w-full bg-gray-200 rounded-full h-2.5">
                            <div className="h-2.5 rounded-full" style={{
                        width: `${item.value / communityDistribution.reduce((acc, curr) => acc + curr.value, 0) * 100}%`,
                        backgroundColor: COLORS[index]
                      }}></div>
                          </div>
                        </div>
                      </div>)}
                  </div>
                </div>
              </div>
            </div>}
          {activeTab === 'activity' && <div>
              <h2 className="text-lg font-semibold text-gray-800 mb-4">
                Recent Activity
              </h2>
              <div className="relative">
                {/* Activity Timeline */}
                <div className="ml-6 border-l-2 border-[#2D7D5C] pb-6">
                  {recentActivities.map((activity, index) => <div key={activity.id} className="mb-6 ml-6">
                      <div className="absolute -left-1.5 mt-1.5 h-3 w-3 rounded-full border-2 border-white bg-[#105640]"></div>
                      <div className="bg-white p-4 rounded-lg shadow">
                        <div className="flex justify-between items-center mb-2">
                          <h3 className="text-md font-medium text-gray-800">
                            {activity.action}
                          </h3>
                          <span className="text-xs text-gray-500">
                            {activity.time}
                          </span>
                        </div>
                        <p className="text-sm text-gray-600">
                          {activity.user} performed action on{' '}
                          <span className="font-medium">{activity.target}</span>
                        </p>
                      </div>
                    </div>)}
                </div>
              </div>
            </div>}
          {activeTab === 'alerts' && <div>
              <h2 className="text-lg font-semibold text-gray-800 mb-4">
                System Alerts
              </h2>
              {alerts.length > 0 ? <div className="space-y-4">
                  {alerts.map(alert => <div key={alert.id} className={`p-4 rounded-lg flex items-start ${alert.severity === 'warning' ? 'bg-yellow-50 border-l-4 border-[#F59E0B]' : 'bg-[#F0F9F6] border-l-4 border-[#105640]'}`}>
                      <AlertTriangleIcon className={`h-5 w-5 mr-3 ${alert.severity === 'warning' ? 'text-[#F59E0B]' : 'text-[#105640]'}`} />
                      <div>
                        <p className="text-sm font-medium text-gray-800">
                          {alert.message}
                        </p>
                        <div className="mt-2">
                          <button className="text-xs font-medium text-[#105640] hover:text-[#2D7D5C]">
                            View Details
                          </button>
                          <button className="text-xs font-medium text-gray-600 hover:text-gray-800 ml-3">
                            Dismiss
                          </button>
                        </div>
                      </div>
                    </div>)}
                </div> : <div className="text-center py-8 text-gray-500">
                  No alerts at this time
                </div>}
            </div>}
        </div>
      </div>
    </div>;
};
export default Dashboard;