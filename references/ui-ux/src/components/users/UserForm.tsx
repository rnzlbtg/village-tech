import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeftIcon } from 'lucide-react';
const UserForm: React.FC = () => {
  const navigate = useNavigate();
  const {
    id: communityId
  } = useParams<{
    id: string;
  }>();
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    role: 'admin-head'
  });
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const {
      name,
      value
    } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // In a real app, you would submit the form data to your backend
    console.log({
      communityId,
      ...formData
    });
    // Redirect to the community detail page after submission
    navigate(`/communities/${communityId}`);
  };
  return <div className="space-y-6">
      <div className="flex items-center space-x-2">
        <button onClick={() => navigate(`/communities/${communityId}`)} className="text-gray-600 hover:text-gray-800">
          <ArrowLeftIcon className="h-5 w-5" />
        </button>
        <h1 className="text-2xl font-bold text-gray-800">Add Admin User</h1>
      </div>
      <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label htmlFor="firstName" className="block text-sm font-medium text-gray-700 mb-1">
              First Name *
            </label>
            <input type="text" id="firstName" name="firstName" required value={formData.firstName} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
          </div>
          <div>
            <label htmlFor="lastName" className="block text-sm font-medium text-gray-700 mb-1">
              Last Name *
            </label>
            <input type="text" id="lastName" name="lastName" required value={formData.lastName} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
          </div>
        </div>
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
            Email Address *
          </label>
          <input type="email" id="email" name="email" required value={formData.email} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
        </div>
        <div>
          <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-1">
            Phone Number *
          </label>
          <input type="tel" id="phone" name="phone" required value={formData.phone} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]" />
        </div>
        <div>
          <label htmlFor="role" className="block text-sm font-medium text-gray-700 mb-1">
            Admin Role *
          </label>
          <select id="role" name="role" required value={formData.role} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-[#105640]">
            <option value="admin-head">Admin Head</option>
            <option value="admin-officer">Admin Officer</option>
          </select>
        </div>
        <div className="border-t pt-6 flex justify-end space-x-4">
          <button type="button" onClick={() => navigate(`/communities/${communityId}`)} className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100">
            Cancel
          </button>
          <button type="submit" className="px-4 py-2 bg-[#105640] hover:bg-[#2D7D5C] text-white rounded-lg">
            Add User
          </button>
        </div>
      </form>
    </div>;
};
export default UserForm;