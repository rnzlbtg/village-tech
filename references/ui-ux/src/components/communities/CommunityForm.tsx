import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeftIcon, AlertTriangleIcon, PlusIcon, XIcon, InfoIcon, CheckIcon } from 'lucide-react';
const CommunityForm: React.FC = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    name: '',
    location: '',
    address: '',
    totalUnits: '',
    description: '',
    type: 'residential',
    status: 'active'
  });
  const [gates, setGates] = useState([{
    id: 1,
    name: '',
    description: ''
  }]);
  const [errors, setErrors] = useState<{
    [key: string]: string;
  }>({});
  const [showSuccessMessage, setShowSuccessMessage] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const {
      name,
      value
    } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    // Clear error when field is modified
    if (errors[name]) {
      setErrors(prev => {
        const newErrors = {
          ...prev
        };
        delete newErrors[name];
        return newErrors;
      });
    }
  };
  const handleGateChange = (id: number, field: string, value: string) => {
    setGates(prev => prev.map(gate => gate.id === id ? {
      ...gate,
      [field]: value
    } : gate));
    // Clear gate errors
    if (errors[`gate-${id}-${field}`]) {
      setErrors(prev => {
        const newErrors = {
          ...prev
        };
        delete newErrors[`gate-${id}-${field}`];
        return newErrors;
      });
    }
  };
  const addGate = () => {
    const newId = gates.length ? Math.max(...gates.map(g => g.id)) + 1 : 1;
    setGates(prev => [...prev, {
      id: newId,
      name: '',
      description: ''
    }]);
  };
  const removeGate = (id: number) => {
    if (gates.length > 1) {
      setGates(prev => prev.filter(gate => gate.id !== id));
      // Remove any errors for this gate
      setErrors(prev => {
        const newErrors = {
          ...prev
        };
        Object.keys(newErrors).forEach(key => {
          if (key.startsWith(`gate-${id}`)) {
            delete newErrors[key];
          }
        });
        return newErrors;
      });
    }
  };
  const validateStep = (step: number) => {
    const newErrors: {
      [key: string]: string;
    } = {};
    if (step === 1) {
      if (!formData.name.trim()) {
        newErrors.name = 'Community name is required';
      }
      if (!formData.location.trim()) {
        newErrors.location = 'Location is required';
      }
      if (!formData.address.trim()) {
        newErrors.address = 'Address is required';
      }
      if (!formData.totalUnits) {
        newErrors.totalUnits = 'Total units is required';
      } else if (parseInt(formData.totalUnits) <= 0) {
        newErrors.totalUnits = 'Total units must be greater than 0';
      }
    }
    if (step === 2) {
      gates.forEach(gate => {
        if (!gate.name.trim()) {
          newErrors[`gate-${gate.id}-name`] = 'Gate name is required';
        }
      });
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };
  const handleNextStep = () => {
    if (validateStep(currentStep)) {
      setCurrentStep(prev => prev + 1);
      window.scrollTo(0, 0);
    }
  };
  const handlePrevStep = () => {
    setCurrentStep(prev => prev - 1);
    window.scrollTo(0, 0);
  };
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateStep(currentStep)) {
      return;
    }
    setIsSubmitting(true);
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      // In a real app, you would submit the form data to your backend
      console.log({
        ...formData,
        gates
      });
      setShowSuccessMessage(true);
      // Redirect to the community list page after submission
      setTimeout(() => {
        navigate('/communities');
      }, 2000);
    } catch (error) {
      console.error('Error submitting form:', error);
      setErrors({
        submit: 'An error occurred while creating the community. Please try again.'
      });
    } finally {
      setIsSubmitting(false);
    }
  };
  return <div className="space-y-6">
      <div className="flex items-center space-x-2">
        <button onClick={() => navigate('/communities')} className="text-gray-600 hover:text-gray-800">
          <ArrowLeftIcon className="h-5 w-5" />
        </button>
        <h1 className="text-2xl font-bold text-gray-800">
          Create New Residential Community
        </h1>
      </div>
      {/* Success Message */}
      {showSuccessMessage && <div className="bg-[#F0F9F6] border-l-4 border-[#105640] p-4 rounded-md">
          <div className="flex items-center">
            <CheckIcon className="h-5 w-5 text-[#105640] mr-2" />
            <p className="text-[#105640]">
              Community created successfully! Redirecting...
            </p>
          </div>
        </div>}
      {/* Error Message */}
      {errors.submit && <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-md">
          <div className="flex items-center">
            <AlertTriangleIcon className="h-5 w-5 text-red-500 mr-2" />
            <p className="text-red-700">{errors.submit}</p>
          </div>
        </div>}
      <div className="bg-white rounded-lg shadow p-6">
        {/* Progress Steps */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div className="w-full flex items-center">
              <div className={`flex items-center justify-center w-10 h-10 rounded-full ${currentStep >= 1 ? 'bg-[#105640] text-white' : 'bg-gray-200'}`}>
                1
              </div>
              <div className={`flex-1 h-1 mx-2 ${currentStep >= 2 ? 'bg-[#105640]' : 'bg-gray-200'}`}></div>
              <div className={`flex items-center justify-center w-10 h-10 rounded-full ${currentStep >= 2 ? 'bg-[#105640] text-white' : 'bg-gray-200'}`}>
                2
              </div>
              <div className={`flex-1 h-1 mx-2 ${currentStep >= 3 ? 'bg-[#105640]' : 'bg-gray-200'}`}></div>
              <div className={`flex items-center justify-center w-10 h-10 rounded-full ${currentStep >= 3 ? 'bg-[#105640] text-white' : 'bg-gray-200'}`}>
                3
              </div>
            </div>
          </div>
          <div className="flex justify-between mt-2">
            <div className="text-center w-1/3">
              <p className={`text-sm ${currentStep === 1 ? 'font-medium text-[#105640]' : 'text-gray-500'}`}>
                Community Information
              </p>
            </div>
            <div className="text-center w-1/3">
              <p className={`text-sm ${currentStep === 2 ? 'font-medium text-[#105640]' : 'text-gray-500'}`}>
                Gates & Entrances
              </p>
            </div>
            <div className="text-center w-1/3">
              <p className={`text-sm ${currentStep === 3 ? 'font-medium text-[#105640]' : 'text-gray-500'}`}>
                Review & Submit
              </p>
            </div>
          </div>
        </div>
        <form onSubmit={handleSubmit}>
          {/* Step 1: Community Information */}
          {currentStep === 1 && <div className="space-y-6">
              <h2 className="text-xl font-semibold text-gray-800 border-b pb-2">
                Community Information
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
                    Community Name *
                  </label>
                  <input type="text" id="name" name="name" value={formData.name} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${errors.name ? 'border-red-500' : ''}`} />
                  {errors.name && <p className="mt-1 text-sm text-red-500">{errors.name}</p>}
                </div>
                <div>
                  <label htmlFor="location" className="block text-sm font-medium text-gray-700 mb-1">
                    Location/City *
                  </label>
                  <input type="text" id="location" name="location" value={formData.location} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${errors.location ? 'border-red-500' : ''}`} />
                  {errors.location && <p className="mt-1 text-sm text-red-500">
                      {errors.location}
                    </p>}
                </div>
              </div>
              <div>
                <label htmlFor="address" className="block text-sm font-medium text-gray-700 mb-1">
                  Complete Address *
                </label>
                <input type="text" id="address" name="address" value={formData.address} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${errors.address ? 'border-red-500' : ''}`} />
                {errors.address && <p className="mt-1 text-sm text-red-500">{errors.address}</p>}
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label htmlFor="totalUnits" className="block text-sm font-medium text-gray-700 mb-1">
                    Total Housing Units *
                  </label>
                  <input type="number" id="totalUnits" name="totalUnits" min="1" value={formData.totalUnits} onChange={handleInputChange} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${errors.totalUnits ? 'border-red-500' : ''}`} />
                  {errors.totalUnits && <p className="mt-1 text-sm text-red-500">
                      {errors.totalUnits}
                    </p>}
                </div>
                <div>
                  <label htmlFor="type" className="block text-sm font-medium text-gray-700 mb-1">
                    Community Type
                  </label>
                  <select id="type" name="type" value={formData.type} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="residential">Residential</option>
                    <option value="commercial">Commercial</option>
                    <option value="mixed">Mixed Use</option>
                  </select>
                </div>
              </div>
              <div>
                <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
                  Description
                </label>
                <textarea id="description" name="description" rows={4} value={formData.description} onChange={handleInputChange} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter a brief description of the community..." />
              </div>
              <div>
                <label htmlFor="status" className="block text-sm font-medium text-gray-700 mb-1">
                  Initial Status
                </label>
                <div className="flex items-center space-x-4">
                  <label className="inline-flex items-center">
                    <input type="radio" name="status" value="active" checked={formData.status === 'active'} onChange={handleInputChange} className="form-radio h-4 w-4 text-blue-600" />
                    <span className="ml-2 text-gray-700">Active</span>
                  </label>
                  <label className="inline-flex items-center">
                    <input type="radio" name="status" value="pending" checked={formData.status === 'pending'} onChange={handleInputChange} className="form-radio h-4 w-4 text-yellow-600" />
                    <span className="ml-2 text-gray-700">Pending</span>
                  </label>
                </div>
              </div>
            </div>}
          {/* Step 2: Gates & Entrances */}
          {currentStep === 2 && <div className="space-y-6">
              <div className="flex justify-between items-center border-b pb-2">
                <h2 className="text-xl font-semibold text-gray-800">
                  Community Gates/Entrances
                </h2>
                <button type="button" onClick={addGate} className="bg-[#105640] hover:bg-[#2D7D5C] text-white py-1 px-3 rounded-lg text-sm flex items-center">
                  <PlusIcon className="h-4 w-4 mr-1" />
                  Add Gate
                </button>
              </div>
              <div className="bg-[#F0F9F6] border-l-4 border-[#105640] p-4 rounded-md mb-4">
                <div className="flex">
                  <InfoIcon className="h-5 w-5 text-[#105640] mr-2" />
                  <p className="text-sm text-[#105640]">
                    Add all entry/exit points for the community. Each gate can
                    be configured separately.
                  </p>
                </div>
              </div>
              <div className="space-y-6">
                {gates.map(gate => <div key={gate.id} className="p-4 border rounded-lg space-y-4 transition-all duration-300 hover:shadow-md">
                    <div className="flex justify-between items-center">
                      <h3 className="font-medium flex items-center">
                        <span className="w-6 h-6 bg-[#105640] text-white rounded-full flex items-center justify-center text-xs mr-2">
                          {gate.id}
                        </span>
                        Gate #{gate.id}
                      </h3>
                      <button type="button" onClick={() => removeGate(gate.id)} className="text-red-500 hover:text-red-700 text-sm flex items-center" disabled={gates.length === 1}>
                        <XIcon className="h-4 w-4 mr-1" />
                        Remove
                      </button>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Gate Name *
                      </label>
                      <input type="text" value={gate.name} onChange={e => handleGateChange(gate.id, 'name', e.target.value)} className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${errors[`gate-${gate.id}-name`] ? 'border-red-500' : ''}`} placeholder="e.g., Main Gate, North Gate" />
                      {errors[`gate-${gate.id}-name`] && <p className="mt-1 text-sm text-red-500">
                          {errors[`gate-${gate.id}-name`]}
                        </p>}
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Description
                      </label>
                      <input type="text" value={gate.description} onChange={e => handleGateChange(gate.id, 'description', e.target.value)} className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="e.g., Located at the north side of the community" />
                    </div>
                  </div>)}
              </div>
            </div>}
          {/* Step 3: Review & Submit */}
          {currentStep === 3 && <div className="space-y-6">
              <h2 className="text-xl font-semibold text-gray-800 border-b pb-2">
                Review Community Information
              </h2>
              <div className="bg-gray-50 p-4 rounded-lg">
                <h3 className="font-medium text-gray-800 mb-3">
                  Community Details
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                  <div>
                    <p className="text-sm text-gray-500">Name</p>
                    <p className="font-medium">{formData.name}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Location</p>
                    <p className="font-medium">{formData.location}</p>
                  </div>
                  <div className="md:col-span-2">
                    <p className="text-sm text-gray-500">Address</p>
                    <p className="font-medium">{formData.address}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Total Units</p>
                    <p className="font-medium">{formData.totalUnits}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Type</p>
                    <p className="font-medium capitalize">{formData.type}</p>
                  </div>
                  <div className="md:col-span-2">
                    <p className="text-sm text-gray-500">Description</p>
                    <p className="font-medium">
                      {formData.description || 'No description provided'}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Initial Status</p>
                    <p className="font-medium">
                      <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${formData.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                        {formData.status === 'active' ? 'Active' : 'Pending'}
                      </span>
                    </p>
                  </div>
                </div>
                <h3 className="font-medium text-gray-800 mb-3 border-t pt-3">
                  Gates & Entrances
                </h3>
                <div className="space-y-3">
                  {gates.map(gate => <div key={gate.id} className="p-3 bg-white rounded border">
                      <div className="flex justify-between">
                        <h4 className="font-medium text-gray-800">
                          {gate.name || 'Unnamed Gate'}
                        </h4>
                        <span className="text-sm text-gray-500">
                          Gate #{gate.id}
                        </span>
                      </div>
                      <p className="text-sm text-gray-600 mt-1">
                        {gate.description || 'No description provided'}
                      </p>
                    </div>)}
                </div>
              </div>
              <div className="bg-amber-50 border-l-4 border-[#F59E0B] p-4 rounded-md">
                <div className="flex">
                  <AlertTriangleIcon className="h-5 w-5 text-[#F59E0B] mr-2" />
                  <div>
                    <p className="text-sm text-amber-700 font-medium">
                      Please verify all information before submitting
                    </p>
                    <p className="text-sm text-amber-600 mt-1">
                      After creating the community, you will be able to add
                      admin users and configure additional settings.
                    </p>
                  </div>
                </div>
              </div>
            </div>}
          <div className="flex justify-between space-x-4 pt-6 border-t mt-8">
            {currentStep > 1 ? <button type="button" onClick={handlePrevStep} className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100 transition-colors duration-200">
                Previous
              </button> : <button type="button" onClick={() => navigate('/communities')} className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100 transition-colors duration-200">
                Cancel
              </button>}
            {currentStep < 3 ? <button type="button" onClick={handleNextStep} className="px-6 py-2 bg-[#105640] hover:bg-[#2D7D5C] text-white rounded-lg transition-colors duration-200">
                Next
              </button> : <button type="submit" disabled={isSubmitting} className={`px-6 py-2 bg-[#105640] hover:bg-[#2D7D5C] text-white rounded-lg flex items-center transition-colors duration-200 ${isSubmitting ? 'opacity-70 cursor-not-allowed' : ''}`}>
                {isSubmitting ? <>
                    <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Processing...
                  </> : 'Create Community'}
              </button>}
          </div>
        </form>
      </div>
    </div>;
};
export default CommunityForm;