import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { PlusIcon, SearchIcon, FilterIcon, MoreVerticalIcon, XIcon, CheckIcon, Trash2Icon, EyeIcon, EditIcon } from 'lucide-react';
const CommunityList: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterOpen, setFilterOpen] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState<string>('all');
  const [sortBy, setSortBy] = useState<string>('name');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc');
  const [activeDropdown, setActiveDropdown] = useState<number | null>(null);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [communityToDelete, setCommunityToDelete] = useState<number | null>(null);
  // Mock data for demonstration
  const communities = [{
    id: 1,
    name: 'Evergreen Heights',
    location: 'Makati City',
    units: 150,
    adminCount: 3,
    status: 'active',
    createdAt: '2023-09-15'
  }, {
    id: 2,
    name: 'Oakridge Estates',
    location: 'Quezon City',
    units: 200,
    adminCount: 4,
    status: 'active',
    createdAt: '2023-09-10'
  }, {
    id: 3,
    name: 'Maple Grove',
    location: 'Pasig City',
    units: 120,
    adminCount: 2,
    status: 'pending',
    createdAt: '2023-09-05'
  }, {
    id: 4,
    name: 'Sunset Valley',
    location: 'Taguig City',
    units: 180,
    adminCount: 3,
    status: 'active',
    createdAt: '2023-08-20'
  }, {
    id: 5,
    name: 'Palm Gardens',
    location: 'Paranaque City',
    units: 90,
    adminCount: 2,
    status: 'inactive',
    createdAt: '2023-08-15'
  }];
  // Get unique locations for filter
  const locations = ['all', ...new Set(communities.map(c => c.location))];
  // Handle filtering and sorting
  const filteredAndSortedCommunities = communities.filter(community => (community.name.toLowerCase().includes(searchTerm.toLowerCase()) || community.location.toLowerCase().includes(searchTerm.toLowerCase())) && (selectedLocation === 'all' || community.location === selectedLocation)).sort((a, b) => {
    if (sortBy === 'name') {
      return sortOrder === 'asc' ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name);
    } else if (sortBy === 'units') {
      return sortOrder === 'asc' ? a.units - b.units : b.units - a.units;
    } else if (sortBy === 'location') {
      return sortOrder === 'asc' ? a.location.localeCompare(b.location) : b.location.localeCompare(a.location);
    } else if (sortBy === 'date') {
      return sortOrder === 'asc' ? new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime() : new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
    }
    return 0;
  });
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
  // Toggle sort order and update sort column
  const handleSort = (column: string) => {
    if (sortBy === column) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(column);
      setSortOrder('asc');
    }
  };
  // Handle dropdown toggle with stopPropagation to prevent closing from document click
  const toggleDropdown = (e: React.MouseEvent, id: number) => {
    e.stopPropagation();
    setActiveDropdown(activeDropdown === id ? null : id);
  };
  // Handle delete confirmation
  const handleDeleteClick = (e: React.MouseEvent, id: number) => {
    e.stopPropagation();
    setActiveDropdown(null);
    setCommunityToDelete(id);
    setIsDeleteModalOpen(true);
  };
  const confirmDelete = () => {
    console.log(`Deleting community ${communityToDelete}`);
    // In a real app, you would delete the community here
    setIsDeleteModalOpen(false);
    setCommunityToDelete(null);
  };
  return <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">
          Residential Communities
        </h1>
        <Link to="/communities/new" className="bg-[#105640] hover:bg-[#2D7D5C] text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-200">
          <PlusIcon className="h-4 w-4 mr-2" />
          Add New Community
        </Link>
      </div>
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b flex flex-wrap justify-between items-center">
          <h2 className="text-lg font-semibold text-gray-800">
            All Communities
          </h2>
          <div className="flex items-center space-x-3">
            <div className="relative">
              <input type="text" placeholder="Search communities..." className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
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
                  Location
                </label>
                <select value={selectedLocation} onChange={e => setSelectedLocation(e.target.value)} className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                  {locations.map(location => <option key={location} value={location}>
                      {location === 'all' ? 'All Locations' : location}
                    </option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Sort By
                </label>
                <select value={sortBy} onChange={e => setSortBy(e.target.value)} className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
                  <option value="name">Name</option>
                  <option value="location">Location</option>
                  <option value="units">Units</option>
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
              setSelectedLocation('all');
              setSortBy('name');
              setSortOrder('asc');
            }} className="px-3 py-2 text-sm text-gray-600 hover:text-gray-800">
                  Reset Filters
                </button>
              </div>
            </div>
          </div>}
        <div className="p-6">
          {filteredAndSortedCommunities.length > 0 ? <table className="min-w-full divide-y divide-gray-200">
              <thead>
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-50" onClick={() => handleSort('name')}>
                    <div className="flex items-center">
                      Community Name
                      {sortBy === 'name' && <span className="ml-1">
                          {sortOrder === 'asc' ? '↑' : '↓'}
                        </span>}
                    </div>
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-50" onClick={() => handleSort('location')}>
                    <div className="flex items-center">
                      Location
                      {sortBy === 'location' && <span className="ml-1">
                          {sortOrder === 'asc' ? '↑' : '↓'}
                        </span>}
                    </div>
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-50" onClick={() => handleSort('units')}>
                    <div className="flex items-center">
                      Units
                      {sortBy === 'units' && <span className="ml-1">
                          {sortOrder === 'asc' ? '↑' : '↓'}
                        </span>}
                    </div>
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Admin Users
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
                {filteredAndSortedCommunities.map(community => <tr key={community.id} className="hover:bg-gray-50 transition-colors duration-150">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        {community.name}
                      </div>
                      <div className="text-xs text-gray-500">
                        Created: {community.createdAt}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-500">
                        {community.location}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-500">
                        {community.units}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-500">
                        {community.adminCount}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${community.status === 'active' ? 'bg-green-100 text-green-800' : community.status === 'pending' ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-800'}`}>
                        {community.status.charAt(0).toUpperCase() + community.status.slice(1)}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex items-center">
                        <Link to={`/communities/${community.id}`} className="text-[#105640] hover:text-[#2D7D5C] mr-3 flex items-center" title="View details">
                          <EyeIcon className="h-4 w-4" />
                        </Link>
                        <Link to={`/communities/${community.id}/edit`} className="text-[#2D7D5C] hover:text-[#105640] mr-3 flex items-center" title="Edit community">
                          <EditIcon className="h-4 w-4" />
                        </Link>
                        <div className="relative">
                          <button onClick={e => toggleDropdown(e, community.id)} className="text-gray-400 hover:text-gray-600">
                            <MoreVerticalIcon className="h-5 w-5" />
                          </button>
                          {activeDropdown === community.id && <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-10 border">
                              <div className="py-1">
                                <Link to={`/communities/${community.id}/users/new`} className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                  Add Admin User
                                </Link>
                                {community.status === 'active' ? <button className="block w-full text-left px-4 py-2 text-sm text-yellow-600 hover:bg-gray-100">
                                    Deactivate Community
                                  </button> : <button className="block w-full text-left px-4 py-2 text-sm text-[#105640] hover:bg-gray-100">
                                    Activate Community
                                  </button>}
                                <button onClick={e => handleDeleteClick(e, community.id)} className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100">
                                  Delete Community
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
                No communities found matching your criteria
              </p>
            </div>}
        </div>
      </div>
      {/* Delete Confirmation Modal */}
      {isDeleteModalOpen && <div className="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-lg p-6 max-w-md mx-4">
            <div className="flex items-center text-red-600 mb-4">
              <Trash2Icon className="h-6 w-6 mr-2" />
              <h3 className="text-lg font-medium">Delete Community</h3>
            </div>
            <p className="mb-6 text-gray-700">
              Are you sure you want to delete this community? This action cannot
              be undone.
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
export default CommunityList;