import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Badge } from './ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from './ui/table';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from './ui/dialog';
import { Textarea } from './ui/textarea';
import { Plus, Search, Edit, Trash2, MoreHorizontal, Building2, MapPin, Users, Calendar } from 'lucide-react';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from './ui/dropdown-menu';

const mockTenants = [
  {
    id: 1,
    name: 'Sunset Gardens HOA',
    location: 'Phoenix, AZ',
    status: 'active',
    users: 1250,
    residences: 450,
    createdAt: '2023-01-15',
    contactEmail: 'admin@sunsetgardens.com',
    contactPhone: '+1-555-0123',
  },
  {
    id: 2,
    name: 'Oak Valley Estates',
    location: 'Austin, TX',
    status: 'trial',
    users: 890,
    residences: 320,
    createdAt: '2023-06-20',
    contactEmail: 'contact@oakvalley.com',
    contactPhone: '+1-555-0456',
  },
  {
    id: 3,
    name: 'Pine Ridge Community',
    location: 'Denver, CO',
    status: 'active',
    users: 1100,
    residences: 380,
    createdAt: '2022-11-08',
    contactEmail: 'info@pineridge.com',
    contactPhone: '+1-555-0789',
  },
  {
    id: 4,
    name: 'Maple Grove HOA',
    location: 'Portland, OR',
    status: 'suspended',
    users: 750,
    residences: 280,
    createdAt: '2023-03-12',
    contactEmail: 'admin@maplegrove.com',
    contactPhone: '+1-555-0321',
  },
];

export function TenantManagement() {
  const [tenants, setTenants] = useState(mockTenants);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [selectedTenant, setSelectedTenant] = useState(null);

  const filteredTenants = tenants.filter(tenant => {
    const matchesSearch = tenant.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         tenant.location.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || tenant.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'default';
      case 'trial': return 'secondary';
      case 'suspended': return 'destructive';
      case 'expired': return 'outline';
      default: return 'secondary';
    }
  };

  const handleCreateTenant = (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const newTenant = {
      id: tenants.length + 1,
      name: formData.get('name'),
      location: formData.get('location'),
      status: 'trial',
      users: 0,
      residences: parseInt(formData.get('residences')) || 0,
      createdAt: new Date().toISOString().split('T')[0],
      contactEmail: formData.get('contactEmail'),
      contactPhone: formData.get('contactPhone'),
    };
    setTenants([...tenants, newTenant]);
    setIsCreateDialogOpen(false);
  };

  const handleEditTenant = (tenant) => {
    setSelectedTenant(tenant);
    setIsEditDialogOpen(true);
  };

  const handleUpdateTenant = (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const updatedTenant = {
      ...selectedTenant,
      name: formData.get('name'),
      location: formData.get('location'),
      status: formData.get('status'),
      residences: parseInt(formData.get('residences')) || 0,
      contactEmail: formData.get('contactEmail'),
      contactPhone: formData.get('contactPhone'),
    };
    setTenants(tenants.map(t => t.id === selectedTenant.id ? updatedTenant : t));
    setIsEditDialogOpen(false);
    setSelectedTenant(null);
  };

  const handleDeleteTenant = (tenantId) => {
    setTenants(tenants.filter(t => t.id !== tenantId));
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1>Tenant Management</h1>
          <p className="text-muted-foreground">
            Manage residential communities and their configurations
          </p>
        </div>
        
        <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="h-4 w-4 mr-2" />
              Add Community
            </Button>
          </DialogTrigger>
          <DialogContent className="sm:max-w-[425px]">
            <form onSubmit={handleCreateTenant}>
              <DialogHeader>
                <DialogTitle>Create New Community</DialogTitle>
                <DialogDescription>
                  Add a new residential community to the platform.
                </DialogDescription>
              </DialogHeader>
              <div className="grid gap-4 py-4">
                <div className="grid gap-2">
                  <Label htmlFor="name">Community Name</Label>
                  <Input id="name" name="name" placeholder="Sunset Gardens HOA" required />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="location">Location</Label>
                  <Input id="location" name="location" placeholder="Phoenix, AZ" required />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="residences">Number of Residences</Label>
                  <Input id="residences" name="residences" type="number" placeholder="450" required />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="contactEmail">Contact Email</Label>
                  <Input id="contactEmail" name="contactEmail" type="email" placeholder="admin@community.com" required />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="contactPhone">Contact Phone</Label>
                  <Input id="contactPhone" name="contactPhone" placeholder="+1-555-0123" required />
                </div>
              </div>
              <DialogFooter>
                <Button type="submit">Create Community</Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search communities..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-8"
                />
              </div>
            </div>
            <div className="w-full sm:w-[180px]">
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger>
                  <SelectValue placeholder="Filter by status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Statuses</SelectItem>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="trial">Trial</SelectItem>
                  <SelectItem value="suspended">Suspended</SelectItem>
                  <SelectItem value="expired">Expired</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Tenants Table */}
      <Card>
        <CardHeader>
          <CardTitle>Communities ({filteredTenants.length})</CardTitle>
          <CardDescription>
            Manage all residential communities on the platform
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Community</TableHead>
                <TableHead>Location</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Users</TableHead>
                <TableHead>Residences</TableHead>
                <TableHead>Created</TableHead>
                <TableHead className="w-[50px]"></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredTenants.map((tenant) => (
                <TableRow key={tenant.id}>
                  <TableCell>
                    <div className="flex items-center space-x-3">
                      <Building2 className="h-5 w-5 text-muted-foreground" />
                      <div>
                        <p className="font-medium">{tenant.name}</p>
                        <p className="text-sm text-muted-foreground">{tenant.contactEmail}</p>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center space-x-2">
                      <MapPin className="h-4 w-4 text-muted-foreground" />
                      <span>{tenant.location}</span>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant={getStatusColor(tenant.status)}>
                      {tenant.status.charAt(0).toUpperCase() + tenant.status.slice(1)}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center space-x-2">
                      <Users className="h-4 w-4 text-muted-foreground" />
                      <span>{tenant.users.toLocaleString()}</span>
                    </div>
                  </TableCell>
                  <TableCell>{tenant.residences}</TableCell>
                  <TableCell>
                    <div className="flex items-center space-x-2">
                      <Calendar className="h-4 w-4 text-muted-foreground" />
                      <span>{tenant.createdAt}</span>
                    </div>
                  </TableCell>
                  <TableCell>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="sm">
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuItem onClick={() => handleEditTenant(tenant)}>
                          <Edit className="h-4 w-4 mr-2" />
                          Edit
                        </DropdownMenuItem>
                        <DropdownMenuItem 
                          onClick={() => handleDeleteTenant(tenant.id)}
                          className="text-destructive"
                        >
                          <Trash2 className="h-4 w-4 mr-2" />
                          Delete
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Edit Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="sm:max-w-[425px]">
          {selectedTenant && (
            <form onSubmit={handleUpdateTenant}>
              <DialogHeader>
                <DialogTitle>Edit Community</DialogTitle>
                <DialogDescription>
                  Update community information and settings.
                </DialogDescription>
              </DialogHeader>
              <div className="grid gap-4 py-4">
                <div className="grid gap-2">
                  <Label htmlFor="edit-name">Community Name</Label>
                  <Input 
                    id="edit-name" 
                    name="name" 
                    defaultValue={selectedTenant.name}
                    required 
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-location">Location</Label>
                  <Input 
                    id="edit-location" 
                    name="location" 
                    defaultValue={selectedTenant.location}
                    required 
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-status">Status</Label>
                  <Select name="status" defaultValue={selectedTenant.status}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="active">Active</SelectItem>
                      <SelectItem value="trial">Trial</SelectItem>
                      <SelectItem value="suspended">Suspended</SelectItem>
                      <SelectItem value="expired">Expired</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-residences">Number of Residences</Label>
                  <Input 
                    id="edit-residences" 
                    name="residences" 
                    type="number" 
                    defaultValue={selectedTenant.residences}
                    required 
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-contactEmail">Contact Email</Label>
                  <Input 
                    id="edit-contactEmail" 
                    name="contactEmail" 
                    type="email" 
                    defaultValue={selectedTenant.contactEmail}
                    required 
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-contactPhone">Contact Phone</Label>
                  <Input 
                    id="edit-contactPhone" 
                    name="contactPhone" 
                    defaultValue={selectedTenant.contactPhone}
                    required 
                  />
                </div>
              </div>
              <DialogFooter>
                <Button type="submit">Update Community</Button>
              </DialogFooter>
            </form>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}