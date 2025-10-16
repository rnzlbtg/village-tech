import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ShieldIcon, PlusIcon, EditIcon, Trash2Icon, InfoIcon, CheckIcon, XIcon } from 'lucide-react';
const RolesPermissions: React.FC = () => {
  const [roles, setRoles] = useState([{
    id: 1,
    name: 'Super Admin',
    description: 'Full access to all features and settings',
    userCount: 2,
    permissions: {
      communities: {
        view: true,
        create: true,
        edit: true,
        delete: true
      },
      users: {
        view: true,
        create: true,
        edit: true,
        delete: true
      },
      settings: {
        view: true,
        edit: true
      },
      reports: {
        view: true,
        export: true
      }
    }
  }, {
    id: 2,
    name: 'Admin',
    description: 'Access to manage communities and users',
    userCount: 5,
    permissions: {
      communities: {
        view: true,
        create: true,
        edit: true,
        delete: false
      },
      users: {
        view: true,
        create: true,
        edit: true,
        delete: false
      },
      settings: {
        view: true,
        edit: false
      },
      reports: {
        view: true,
        export: true
      }
    }
  }, {
    id: 3,
    name: 'Manager',
    description: 'Limited access to manage specific communities',
    userCount: 12,
    permissions: {
      communities: {
        view: true,
        create: false,
        edit: true,
        delete: false
      },
      users: {
        view: true,
        create: false,
        edit: false,
        delete: false
      },
      settings: {
        view: false,
        edit: false
      },
      reports: {
        view: true,
        export: false
      }
    }
  }]);
  const [editingRole, setEditingRole] = useState<number | null>(null);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [roleToDelete, setRoleToDelete] = useState<number | null>(null);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newRole, setNewRole] = useState({
    name: '',
    description: '',
    permissions: {
      communities: {
        view: false,
        create: false,
        edit: false,
        delete: false
      },
      users: {
        view: false,
        create: false,
        edit: false,
        delete: false
      },
      settings: {
        view: false,
        edit: false
      },
      reports: {
        view: false,
        export: false
      }
    }
  });
  const handleDeleteClick = (roleId: number) => {
    setRoleToDelete(roleId);
    setShowDeleteModal(true);
  };
  const confirmDelete = () => {
    if (roleToDelete) {
      setRoles(roles.filter(role => role.id !== roleToDelete));
      setShowDeleteModal(false);
      setRoleToDelete(null);
    }
  };
  const handleCreateRole = () => {
    const newRoleWithId = {
      ...newRole,
      id: Math.max(...roles.map(r => r.id)) + 1,
      userCount: 0
    };
    setRoles([...roles, newRoleWithId]);
    setShowCreateModal(false);
    setNewRole({
      name: '',
      description: '',
      permissions: {
        communities: {
          view: false,
          create: false,
          edit: false,
          delete: false
        },
        users: {
          view: false,
          create: false,
          edit: false,
          delete: false
        },
        settings: {
          view: false,
          edit: false
        },
        reports: {
          view: false,
          export: false
        }
      }
    });
  };
  const togglePermission = (roleId: number, category: string, permission: string, value: boolean) => {
    setRoles(roles.map(role => {
      if (role.id === roleId) {
        return {
          ...role,
          permissions: {
            ...role.permissions,
            [category]: {
              ...role.permissions[category as keyof typeof role.permissions],
              [permission]: value
            }
          }
        };
      }
      return role;
    }));
  };
  return <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">
          Roles & Permissions
        </h1>
        <button onClick={() => setShowCreateModal(true)} className="bg-[#105640] hover:bg-[#2D7D5C] text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-200">
          <PlusIcon className="h-4 w-4 mr-2" />
          Create New Role
        </button>
      </div>
      <div className="bg-[#F0F9F6] border-l-4 border-[#105640] p-4 rounded-md mb-4">
        <div className="flex">
          <InfoIcon className="h-5 w-5 text-[#105640] mr-2" />
          <p className="text-sm text-[#105640]">
            Roles determine what actions users can perform in the system.
            Configure permissions carefully to maintain proper security.
          </p>
        </div>
      </div>
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b">
          <h2 className="text-lg font-semibold text-gray-800">System Roles</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {roles.map(role => <div key={role.id} className="p-6">
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className="text-lg font-medium text-gray-800 flex items-center">
                    <ShieldIcon className="h-5 w-5 mr-2 text-[#105640]" />
                    {role.name}
                  </h3>
                  <p className="text-sm text-gray-600 mt-1">
                    {role.description}
                  </p>
                  <p className="text-xs text-gray-500 mt-1">
                    {role.userCount} users with this role
                  </p>
                </div>
                <div className="flex space-x-2">
                  <button onClick={() => setEditingRole(editingRole === role.id ? null : role.id)} className={`px-3 py-1.5 rounded-lg text-sm flex items-center ${editingRole === role.id ? 'bg-[#F0F9F6] text-[#105640] border border-[#105640]' : 'border text-gray-600 hover:bg-gray-50'}`}>
                    <EditIcon className="h-3.5 w-3.5 mr-1" />
                    {editingRole === role.id ? 'Done Editing' : 'Edit Permissions'}
                  </button>
                  {role.name !== 'Super Admin' && <button onClick={() => handleDeleteClick(role.id)} className="px-3 py-1.5 border rounded-lg text-sm text-red-600 hover:bg-red-50 flex items-center">
                      <Trash2Icon className="h-3.5 w-3.5 mr-1" />
                      Delete
                    </button>}
                </div>
              </div>
              {editingRole === role.id && <div className="mt-4 border rounded-lg overflow-hidden">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Feature
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          View
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Create
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Edit
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Delete
                        </th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      <tr>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          Communities
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.communities.view} onChange={e => togglePermission(role.id, 'communities', 'view', e.target.checked)} />
                          </label>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.communities.create} onChange={e => togglePermission(role.id, 'communities', 'create', e.target.checked)} />
                          </label>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.communities.edit} onChange={e => togglePermission(role.id, 'communities', 'edit', e.target.checked)} />
                          </label>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.communities.delete} onChange={e => togglePermission(role.id, 'communities', 'delete', e.target.checked)} />
                          </label>
                        </td>
                      </tr>
                      <tr>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          Users
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.users.view} onChange={e => togglePermission(role.id, 'users', 'view', e.target.checked)} />
                          </label>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.users.create} onChange={e => togglePermission(role.id, 'users', 'create', e.target.checked)} />
                          </label>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.users.edit} onChange={e => togglePermission(role.id, 'users', 'edit', e.target.checked)} />
                          </label>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.users.delete} onChange={e => togglePermission(role.id, 'users', 'delete', e.target.checked)} />
                          </label>
                        </td>
                      </tr>
                      <tr>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          Settings
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.settings.view} onChange={e => togglePermission(role.id, 'settings', 'view', e.target.checked)} />
                          </label>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">-</td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.settings.edit} onChange={e => togglePermission(role.id, 'settings', 'edit', e.target.checked)} />
                          </label>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">-</td>
                      </tr>
                      <tr>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          Reports
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.reports.view} onChange={e => togglePermission(role.id, 'reports', 'view', e.target.checked)} />
                          </label>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">-</td>
                        <td className="px-6 py-4 whitespace-nowrap">-</td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <label className="inline-flex items-center">
                            <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={role.permissions.reports.export} onChange={e => togglePermission(role.id, 'reports', 'export', e.target.checked)} />
                          </label>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>}
            </div>)}
        </div>
      </div>
      {/* Delete Role Modal */}
      {showDeleteModal && <div className="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-lg p-6 max-w-md mx-4">
            <div className="flex items-center text-red-600 mb-4">
              <Trash2Icon className="h-6 w-6 mr-2" />
              <h3 className="text-lg font-medium">Delete Role</h3>
            </div>
            <p className="mb-6 text-gray-700">
              Are you sure you want to delete this role? All users with this
              role will need to be reassigned.
            </p>
            <div className="flex justify-end space-x-3">
              <button onClick={() => setShowDeleteModal(false)} className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100">
                Cancel
              </button>
              <button onClick={confirmDelete} className="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg flex items-center">
                <Trash2Icon className="h-4 w-4 mr-1" />
                Delete
              </button>
            </div>
          </div>
        </div>}
      {/* Create Role Modal */}
      {showCreateModal && <div className="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-lg p-6 max-w-lg mx-4 w-full">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-medium text-gray-900">
                Create New Role
              </h3>
              <button onClick={() => setShowCreateModal(false)} className="text-gray-400 hover:text-gray-500">
                <XIcon className="h-5 w-5" />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label htmlFor="roleName" className="block text-sm font-medium text-gray-700 mb-1">
                  Role Name *
                </label>
                <input type="text" id="roleName" value={newRole.name} onChange={e => setNewRole({
              ...newRole,
              name: e.target.value
            })} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" placeholder="e.g. Community Manager" required />
              </div>
              <div>
                <label htmlFor="roleDescription" className="block text-sm font-medium text-gray-700 mb-1">
                  Description *
                </label>
                <textarea id="roleDescription" value={newRole.description} onChange={e => setNewRole({
              ...newRole,
              description: e.target.value
            })} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" placeholder="Describe the responsibilities of this role" rows={3} required></textarea>
              </div>
              <div>
                <h4 className="text-sm font-medium text-gray-700 mb-2">
                  Default Permissions
                </h4>
                <div className="border rounded-lg overflow-hidden">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Feature
                        </th>
                        <th className="px-4 py-2 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                          View
                        </th>
                        <th className="px-4 py-2 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Create
                        </th>
                        <th className="px-4 py-2 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Edit
                        </th>
                        <th className="px-4 py-2 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Delete
                        </th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      <tr>
                        <td className="px-4 py-2 whitespace-nowrap text-sm font-medium text-gray-900">
                          Communities
                        </td>
                        <td className="px-4 py-2 whitespace-nowrap text-center">
                          <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={newRole.permissions.communities.view} onChange={e => setNewRole({
                        ...newRole,
                        permissions: {
                          ...newRole.permissions,
                          communities: {
                            ...newRole.permissions.communities,
                            view: e.target.checked
                          }
                        }
                      })} />
                        </td>
                        <td className="px-4 py-2 whitespace-nowrap text-center">
                          <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={newRole.permissions.communities.create} onChange={e => setNewRole({
                        ...newRole,
                        permissions: {
                          ...newRole.permissions,
                          communities: {
                            ...newRole.permissions.communities,
                            create: e.target.checked
                          }
                        }
                      })} />
                        </td>
                        <td className="px-4 py-2 whitespace-nowrap text-center">
                          <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={newRole.permissions.communities.edit} onChange={e => setNewRole({
                        ...newRole,
                        permissions: {
                          ...newRole.permissions,
                          communities: {
                            ...newRole.permissions.communities,
                            edit: e.target.checked
                          }
                        }
                      })} />
                        </td>
                        <td className="px-4 py-2 whitespace-nowrap text-center">
                          <input type="checkbox" className="rounded border-gray-300 text-[#105640] focus:ring-[#105640]" checked={newRole.permissions.communities.delete} onChange={e => setNewRole({
                        ...newRole,
                        permissions: {
                          ...newRole.permissions,
                          communities: {
                            ...newRole.permissions.communities,
                            delete: e.target.checked
                          }
                        }
                      })} />
                        </td>
                      </tr>
                      {/* Additional permission rows would follow the same pattern */}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
            <div className="mt-6 flex justify-end space-x-3">
              <button onClick={() => setShowCreateModal(false)} className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100">
                Cancel
              </button>
              <button onClick={handleCreateRole} disabled={!newRole.name || !newRole.description} className={`px-4 py-2 bg-[#105640] hover:bg-[#2D7D5C] text-white rounded-lg flex items-center ${!newRole.name || !newRole.description ? 'opacity-50 cursor-not-allowed' : ''}`}>
                <CheckIcon className="h-4 w-4 mr-1" />
                Create Role
              </button>
            </div>
          </div>
        </div>}
    </div>;
};
export default RolesPermissions;