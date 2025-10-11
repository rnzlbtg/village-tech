import React from 'react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import { ArrowLeftIcon, PencilIcon, UserPlusIcon } from 'lucide-react';
const CommunityDetail: React.FC = () => {
  const {
    id
  } = useParams<{
    id: string;
  }>();
  const navigate = useNavigate();
  // Mock data for demonstration
  const community = {
    id: Number(id),
    name: 'Evergreen Heights',
    location: 'Makati City',
    address: '123 Evergreen St., Makati City',
    totalUnits: 150,
    description: 'A luxurious gated community with modern amenities and lush green spaces.',
    createdAt: '2023-09-15'
  };
  const gates = [{
    id: 1,
    name: 'Main Gate',
    description: 'Located at the front entrance, 24/7 security'
  }, {
    id: 2,
    name: 'East Gate',
    description: 'Secondary entrance for residents only'
  }];
  const adminUsers = [{
    id: 1,
    name: 'Juan Dela Cruz',
    role: 'Admin Head',
    email: 'juan@example.com'
  }, {
    id: 2,
    name: 'Maria Santos',
    role: 'Admin Officer',
    email: 'maria@example.com'
  }];
  return <div className="space-y-6">
      <div className="flex items-center space-x-2">
        <button onClick={() => navigate('/communities')} className="text-gray-600 hover:text-gray-800">
          <ArrowLeftIcon className="h-5 w-5" />
        </button>
        <h1 className="text-2xl font-bold text-gray-800">{community.name}</h1>
      </div>
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b flex justify-between items-center">
          <h2 className="text-lg font-semibold text-gray-800">
            Community Information
          </h2>
          <Link to={`/communities/${id}/edit`} className="flex items-center text-[#105640] hover:text-[#2D7D5C]">
            <PencilIcon className="h-4 w-4 mr-1" />
            Edit
          </Link>
        </div>
        <div className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <p className="text-sm text-gray-500">Location</p>
              <p className="font-medium">{community.location}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Total Units</p>
              <p className="font-medium">{community.totalUnits}</p>
            </div>
            <div className="md:col-span-2">
              <p className="text-sm text-gray-500">Address</p>
              <p className="font-medium">{community.address}</p>
            </div>
            <div className="md:col-span-2">
              <p className="text-sm text-gray-500">Description</p>
              <p className="font-medium">{community.description}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Created Date</p>
              <p className="font-medium">{community.createdAt}</p>
            </div>
          </div>
        </div>
      </div>
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b flex justify-between items-center">
          <div className="flex items-center">
            <div className="h-5 w-5 mr-2 text-[#105640]" />
            <h2 className="text-lg font-semibold text-gray-800">
              Gates & Entrances
            </h2>
          </div>
          <Link to={`/communities/${id}/gates/new`} className="flex items-center text-[#105640] hover:text-[#2D7D5C]">
            <PencilIcon className="h-4 w-4 mr-1" />
            Manage Gates
          </Link>
        </div>
        <div className="p-6">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Gate Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Description
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {gates.map(gate => <tr key={gate.id}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {gate.name}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">
                      {gate.description}
                    </div>
                  </td>
                </tr>)}
            </tbody>
          </table>
        </div>
      </div>
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b flex justify-between items-center">
          <div className="flex items-center">
            <UserPlusIcon className="h-5 w-5 mr-2 text-[#105640]" />
            <h2 className="text-lg font-semibold text-gray-800">Admin Users</h2>
          </div>
          <Link to={`/communities/${id}/users/new`} className="bg-[#105640] hover:bg-[#2D7D5C] text-white py-2 px-4 rounded-lg flex items-center">
            <UserPlusIcon className="h-4 w-4 mr-2" />
            Add Admin User
          </Link>
        </div>
        <div className="p-6">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Role
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Email
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {adminUsers.map(user => <tr key={user.id}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {user.name}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">{user.role}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">{user.email}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <Link to={`/communities/${id}/users/${user.id}/edit`} className="text-[#105640] hover:text-[#2D7D5C] mr-4">
                      Edit
                    </Link>
                  </td>
                </tr>)}
            </tbody>
          </table>
        </div>
      </div>
    </div>;
};
export default CommunityDetail;