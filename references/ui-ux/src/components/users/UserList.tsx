import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { UserPlusIcon, SearchIcon, FilterIcon, XIcon, EyeIcon, EditIcon, MoreVerticalIcon, Trash2Icon, UserIcon } from 'lucide-react';
const UserList: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterOpen, setFilterOpen] = useState(false);
  const [selectedRole, setSelectedRole] = useState('all');
  const [sortBy, setSortBy] = useState('name');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc');
  const [activeDropdown, setActiveDropdown] = useState<number | null>(null);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState<number | null>(null);
  // Mock data for demonstration
  const [users, setUsers] = useState([{
    id: 1,
    name: 'John Smith',
    email: 'john.smith@example.com',
    role: 'Super Admin',
    status: 'active',
    lastLogin: '2 hours ago',
    communities: ['Sunset Valley', 'Pine Ridge'],
    createdAt: '2023-01-15'
  }, {
    id: 2,
    name: 'Sarah Johnson',
    email: 'sarah.j@example.com',
    role: 'Admin',
    status: 'active',
    lastLogin: '1 day ago',
    communities: ['Maple Grove'],
    createdAt: '2023-02-20'
  }, {
    id: 3,
    name: 'Michael Brown',
    email: 'michael.brown@example.com',
    role: 'Manager',
    status: 'inactive',
    lastLogin: '2 weeks ago',
    communities: ['Sunset Valley'],
    createdAt: '2023-03-10'
  }, {
    id: 4,
    name: 'Emily Davis',
    email: 'emily.davis@example.com',
    role: 'Admin',
    status: 'active',
    lastLogin: '3 hours ago',
    communities: ['Pine Ridge', 'Oakwood Estates'],
    createdAt: '2023-04-05'
  }, {
    id: 5,
    name: 'David Wilson',
    email: 'david.wilson@example.com',
    role: 'Manager',
    status: 'pending',
    lastLogin: 'Never',
    communities: ['Maple Grove'],
    createdAt: '2023-05-12'
  }]);
  // Available roles for filter
  const roles = ['all', 'Super Admin', 'Admin', 'Manager'];
  // Handle search and filtering
  const filteredAndSortedUsers = users.filter(user => {
    const matchesSearch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) || user.email.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesRole = selectedRole === 'all' || user.role === selectedRole;
    return matchesSearch && matchesRole;
  }).sort((a, b) => {
    let comparison = 0;
    switch (sortBy) {
      case 'name':
        comparison = a.name.localeCompare(b.name);
        break;
      case 'email':
        comparison = a.email.localeCompare(b.email);
        break;
      case 'role':
        comparison = a.role.localeCompare(b.role);
        break;
      case 'date':
        comparison = new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
        break;
      default:
        comparison = 0;
    }
    return sortOrder === 'asc' ? comparison : -comparison;
  });
  // Handle sorting
  const handleSort = (column: string) => {
    if (sortBy === column) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(column);
      setSortOrder('asc');
    }
  };
  // Toggle dropdown menu for actions
  const toggleDropdown = (e: React.MouseEvent<HTMLButtonElement>, userId: number) => {
    e.stopPropagation();
    setActiveDropdown(activeDropdown === userId ? null : userId);
  };
  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = () => {
      setActiveDropdown(null);
    };
    document.addEventListener('click', handleClickOutside);
    return () => {
      document.removeEventListener('click', handleClickOutside);
    };
  }, []);
  // Handle delete click
  const handleDeleteClick = (e: React.MouseEvent<HTMLButtonElement>, userId: number) => {
    e.stopPropagation();
    setUserToDelete(userId);
    setIsDeleteModalOpen(true);
    setActiveDropdown(null);
  };
  // Confirm delete
  const confirmDelete = () => {
    if (userToDelete) {
      setUsers(users.filter(user => user.id !== userToDelete));
      setIsDeleteModalOpen(false);
      setUserToDelete(null);
    }
  };
  return <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">User Management</h1>
        <Link to="/users/new" className="bg-[#105640] hover:bg-[#2D7D5C] text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-200">
          <UserPlusIcon className="h-4 w-4 mr-2" />
          Add New User
        </Link>
      </div>
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b flex flex-wrap justify-between items-center">
          <h2 className="text-lg font-semibold text-gray-800">All Users</h2>
          <div className="flex items-center space-x-3">
            <div className="relative">
              <input type="text" placeholder="Search users..." className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
              <SearchIcon className="absolute left-3 top-2.5 h-5 w-5 text-gray-400" />
              {searchTerm && <button onClick={() => setSearchTerm('')} className="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600">
                  <XIcon className="h-4 w-4" />
                </button>}
            </div>
            <button onClick={() => setFilterOpen(!filterOpen)} className={`p-2 rounded-lg border ${filterOpen ? 'bg-[#F0F9F6] border-[#105640]' : 'hover:bg-gray-50'}`}>
              <FilterIcon className={`h-5 w-5 ${filterOpen ? 'text-[#105640]' : 'text-gray-500'}`} />
            </button>
          </div>
        </div>
        {/* Filter Panel */}
        {filterOpen && <div className="p-4 border-b bg-gray-50">
            <div className="flex flex-wrap items-center gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Role
                </label>
                <select value={selectedRole} onChange={e => setSelectedRole(e.target.value)} className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                  {roles.map(role => <option key={role} value={role}>
                      {role === 'all' ? 'All Roles' : role}
                    </option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Sort By
                </label>
                <select value={sortBy} onChange={e => setSortBy(e.target.value)} className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                  <option value="name">Name</option>
                  <option value="email">Email</option>
                  <option value="role">Role</option>
                  <option value="date">Date Created</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Order
                </label>
                <select value={sortOrder} onChange={e => setSortOrder(e.target.value as 'asc' | 'desc')} className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                  <option value="asc">Ascending</option>
                  <option value="desc">Descending</option>
                </select>
              </div>
              <div className="ml-auto self-end">
                <button onClick={() => {
              setSelectedRole('all');
              setSortBy('name');
              setSortOrder('asc');
            }} className="px-3 py-2 text-sm text-gray-600 hover:text-gray-800">
                  Reset Filters
                </button>
              </div>
            </div>
          </div>}
        <div className="p-6">
          {filteredAndSortedUsers.length > 0 ? <table className="min-w-full divide-y divide-gray-200">
              <thead>
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-50" onClick={() => handleSort('name')}>
                    <div className="flex items-center">
                      User
                      {sortBy === 'name' && <span className="ml-1">
                          {sortOrder === 'asc' ? '↑' : '↓'}
                        </span>}
                    </div>
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-50" onClick={() => handleSort('email')}>
                    <div className="flex items-center">
                      Email
                      {sortBy === 'email' && <span className="ml-1">
                          {sortOrder === 'asc' ? '↑' : '↓'}
                        </span>}
                    </div>
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-50" onClick={() => handleSort('role')}>
                    <div className="flex items-center">
                      Role
                      {sortBy === 'role' && <span className="ml-1">
                          {sortOrder === 'asc' ? '↑' : '↓'}
                        </span>}
                    </div>
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Communities
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Last Login
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredAndSortedUsers.map(user => <tr key={user.id} className="hover:bg-gray-50 transition-colors duration-150">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10 bg-[#F0F9F6] rounded-full flex items-center justify-center">
                          <UserIcon className="h-5 w-5 text-[#105640]" />
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {user.name}
                          </div>
                          <div className="text-xs text-gray-500">
                            Created: {user.createdAt}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-500">{user.email}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-500">{user.role}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-500">
                        {user.communities.join(', ')}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${user.status === 'active' ? 'bg-green-100 text-green-800' : user.status === 'pending' ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-800'}`}>
                        {user.status.charAt(0).toUpperCase() + user.status.slice(1)}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-500">
                        {user.lastLogin}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex items-center">
                        <Link to={`/users/${user.id}`} className="text-[#105640] hover:text-[#2D7D5C] mr-3 flex items-center" title="View details">
                          <EyeIcon className="h-4 w-4" />
                        </Link>
                        <Link to={`/users/${user.id}/edit`} className="text-[#2D7D5C] hover:text-[#105640] mr-3 flex items-center" title="Edit user">
                          <EditIcon className="h-4 w-4" />
                        </Link>
                        <div className="relative">
                          <button onClick={e => toggleDropdown(e, user.id)} className="text-gray-400 hover:text-gray-600">
                            <MoreVerticalIcon className="h-5 w-5" />
                          </button>
                          {activeDropdown === user.id && <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-10 border">
                              <div className="py-1">
                                <Link to={`/users/${user.id}/permissions`} className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                  Edit Permissions
                                </Link>
                                {user.status === 'active' ? <button className="block w-full text-left px-4 py-2 text-sm text-yellow-600 hover:bg-gray-100">
                                    Deactivate User
                                  </button> : <button className="block w-full text-left px-4 py-2 text-sm text-[#105640] hover:bg-gray-100">
                                    Activate User
                                  </button>}
                                <button onClick={e => handleDeleteClick(e, user.id)} className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100">
                                  Delete User
                                </button>
                              </div>
                            </div>}
                        </div>
                      </div>
                    </td>
                  </tr>)}
              </tbody>
            </table> : <div className="text-center py-8">
              <p className="text-gray-500">
                No users found matching your criteria
              </p>
            </div>}
        </div>
      </div>
      {/* Delete Confirmation Modal */}
      {isDeleteModalOpen && <div className="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-lg p-6 max-w-md mx-4">
            <div className="flex items-center text-red-600 mb-4">
              <Trash2Icon className="h-6 w-6 mr-2" />
              <h3 className="text-lg font-medium">Delete User</h3>
            </div>
            <p className="mb-6 text-gray-700">
              Are you sure you want to delete this user? This action cannot be
              undone.
            </p>
            <div className="flex justify-end space-x-3">
              <button onClick={() => setIsDeleteModalOpen(false)} className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100">
                Cancel
              </button>
              <button onClick={confirmDelete} className="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg flex items-center">
                <Trash2Icon className="h-4 w-4 mr-1" />
                Delete
              </button>
            </div>
          </div>
        </div>}
    </div>;
};
export default UserList;