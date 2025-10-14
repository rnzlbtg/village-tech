import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from './ui/table';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from './ui/dialog';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Plus, UserPlus, Mail, Shield, Users, Edit, Trash2, Send, Key } from 'lucide-react';
import { Textarea } from './ui/textarea';
import { Switch } from './ui/switch';

const mockTenants = [
  { id: 1, name: 'Sunset Gardens HOA' },
  { id: 2, name: 'Oak Valley Estates' },
  { id: 3, name: 'Pine Ridge Community' },
];

const mockUsers = [
  {
    id: 1,
    tenantId: 1,
    name: 'John Smith',
    email: 'john.smith@sunsetgardens.com',
    role: 'admin_head',
    status: 'active',
    lastLogin: '2024-01-15 09:30:00',
    createdAt: '2023-01-15',
    tempPassword: false,
  },
  {
    id: 2,
    tenantId: 1,
    name: 'Sarah Johnson',
    email: 'sarah.johnson@sunsetgardens.com',
    role: 'admin_officer',
    status: 'active',
    lastLogin: '2024-01-14 16:45:00',
    createdAt: '2023-02-20',
    tempPassword: false,
  },
  {
    id: 3,
    tenantId: 1,
    name: 'Mike Wilson',
    email: 'mike.wilson@sunsetgardens.com',
    role: 'admin_officer',
    status: 'pending',
    lastLogin: null,
    createdAt: '2024-01-10',
    tempPassword: true,
  },
];

export function UserProvisioning() {
  const [selectedTenant, setSelectedTenant] = useState('1');
  const [users, setUsers] = useState(mockUsers);
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isWelcomeDialogOpen, setIsWelcomeDialogOpen] = useState(false);

  const filteredUsers = users.filter(u => u.tenantId === parseInt(selectedTenant));

  const getRoleColor = (role) => {
    switch (role) {
      case 'admin_head': return 'default';
      case 'admin_officer': return 'secondary';
      default: return 'outline';
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'default';
      case 'pending': return 'secondary';
      case 'suspended': return 'destructive';
      default: return 'outline';
    }
  };

  const handleCreateUser = (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const newUser = {
      id: users.length + 1,
      tenantId: parseInt(selectedTenant),
      name: formData.get('name'),
      email: formData.get('email'),
      role: formData.get('role'),
      status: 'pending',
      lastLogin: null,
      createdAt: new Date().toISOString().split('T')[0],
      tempPassword: true,
    };
    setUsers([...users, newUser]);
    setIsCreateDialogOpen(false);
  };

  const handleDeleteUser = (userId) => {
    setUsers(users.filter(u => u.id !== userId));
  };

  const generateTempPassword = () => {
    return Math.random().toString(36).slice(2, 10).toUpperCase();
  };

  const selectedTenantName = mockTenants.find(t => t.id === parseInt(selectedTenant))?.name || '';

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1>User Provisioning</h1>
          <p className="text-muted-foreground">
            Create and manage initial admin accounts for community management
          </p>
        </div>
      </div>

      {/* Tenant Selection */}
      <Card>
        <CardHeader>
          <CardTitle>Select Community</CardTitle>
          <CardDescription>
            Choose a community to manage its admin users
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="w-full md:w-[300px]">
            <Label htmlFor="tenant-select">Community</Label>
            <Select value={selectedTenant} onValueChange={setSelectedTenant}>
              <SelectTrigger>
                <SelectValue placeholder="Select a community" />
              </SelectTrigger>
              <SelectContent>
                {mockTenants.map(tenant => (
                  <SelectItem key={tenant.id} value={tenant.id.toString()}>
                    {tenant.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {selectedTenant && (
        <Tabs defaultValue="users" className="space-y-4">
          <TabsList>
            <TabsTrigger value="users">Admin Users</TabsTrigger>
            <TabsTrigger value="roles">Role Configuration</TabsTrigger>
            <TabsTrigger value="welcome">Welcome Templates</TabsTrigger>
          </TabsList>

          <TabsContent value="users" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <div>
                    <CardTitle>Admin Users - {selectedTenantName}</CardTitle>
                    <CardDescription>
                      Manage administrative accounts for community management
                    </CardDescription>
                  </div>
                  
                  <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
                    <DialogTrigger asChild>
                      <Button>
                        <UserPlus className="h-4 w-4 mr-2" />
                        Add Admin User
                      </Button>
                    </DialogTrigger>
                    <DialogContent className="sm:max-w-[425px]">
                      <form onSubmit={handleCreateUser}>
                        <DialogHeader>
                          <DialogTitle>Create Admin User</DialogTitle>
                          <DialogDescription>
                            Add a new administrative user for {selectedTenantName}.
                          </DialogDescription>
                        </DialogHeader>
                        <div className="grid gap-4 py-4">
                          <div className="grid gap-2">
                            <Label htmlFor="name">Full Name</Label>
                            <Input 
                              id="name" 
                              name="name" 
                              placeholder="John Smith" 
                              required 
                            />
                          </div>
                          <div className="grid gap-2">
                            <Label htmlFor="email">Email Address</Label>
                            <Input 
                              id="email" 
                              name="email" 
                              type="email"
                              placeholder="john.smith@community.com" 
                              required 
                            />
                          </div>
                          <div className="grid gap-2">
                            <Label htmlFor="role">Admin Role</Label>
                            <Select name="role" required>
                              <SelectTrigger>
                                <SelectValue placeholder="Select role" />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="admin_head">Admin Head (Primary)</SelectItem>
                                <SelectItem value="admin_officer">Admin Officer (Supporting)</SelectItem>
                              </SelectContent>
                            </Select>
                            <p className="text-xs text-muted-foreground">
                              Admin Head: Primary community administrator with full access<br/>
                              Admin Officer: Supporting administrator with limited access
                            </p>
                          </div>
                          <div className="grid gap-2">
                            <Label>Temporary Password</Label>
                            <div className="flex space-x-2">
                              <Input 
                                value={generateTempPassword()}
                                readOnly
                                className="bg-muted"
                              />
                              <Button type="button" variant="outline" size="sm">
                                Generate
                              </Button>
                            </div>
                            <p className="text-xs text-muted-foreground">
                              User will be required to change password on first login
                            </p>
                          </div>
                        </div>
                        <DialogFooter>
                          <Button type="submit">Create User & Send Welcome Email</Button>
                        </DialogFooter>
                      </form>
                    </DialogContent>
                  </Dialog>
                </div>
              </CardHeader>
              <CardContent>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>User</TableHead>
                      <TableHead>Role</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Last Login</TableHead>
                      <TableHead>Created</TableHead>
                      <TableHead className="w-[150px]">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredUsers.map((user) => (
                      <TableRow key={user.id}>
                        <TableCell>
                          <div className="flex items-center space-x-3">
                            <Users className="h-5 w-5 text-muted-foreground" />
                            <div>
                              <p className="font-medium">{user.name}</p>
                              <p className="text-sm text-muted-foreground">{user.email}</p>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant={getRoleColor(user.role)}>
                            {user.role === 'admin_head' ? 'Admin Head' : 'Admin Officer'}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex flex-col space-y-1">
                            <Badge variant={getStatusColor(user.status)} className="w-fit">
                              {user.status.charAt(0).toUpperCase() + user.status.slice(1)}
                            </Badge>
                            {user.tempPassword && (
                              <Badge variant="outline" className="w-fit text-xs">
                                <Key className="h-3 w-3 mr-1" />
                                Temp Password
                              </Badge>
                            )}
                          </div>
                        </TableCell>
                        <TableCell className="text-sm">
                          {user.lastLogin || 'Never'}
                        </TableCell>
                        <TableCell className="text-sm">{user.createdAt}</TableCell>
                        <TableCell>
                          <div className="flex space-x-2">
                            <Button variant="ghost" size="sm" title="Send Welcome Email">
                              <Mail className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="sm" title="Reset Password">
                              <Key className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="sm" title="Edit User">
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button 
                              variant="ghost" 
                              size="sm"
                              title="Delete User"
                              onClick={() => handleDeleteUser(user.id)}
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="roles" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Role Configuration</CardTitle>
                <CardDescription>
                  Define permissions and access levels for admin roles
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-4">
                  <div className="border rounded-lg p-4">
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <h3 className="font-medium">Admin Head</h3>
                        <p className="text-sm text-muted-foreground">Primary community administrator with full access</p>
                      </div>
                      <Badge>1 per community</Badge>
                    </div>
                    
                    <div className="grid gap-3 md:grid-cols-2">
                      <div className="space-y-2">
                        <Label className="text-sm">Core Permissions</Label>
                        <div className="space-y-2 text-sm">
                          <div className="flex items-center justify-between">
                            <span>User Management</span>
                            <Switch checked disabled />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Community Settings</span>
                            <Switch checked disabled />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Financial Management</span>
                            <Switch checked disabled />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Reports & Analytics</span>
                            <Switch checked disabled />
                          </div>
                        </div>
                      </div>
                      
                      <div className="space-y-2">
                        <Label className="text-sm">Advanced Permissions</Label>
                        <div className="space-y-2 text-sm">
                          <div className="flex items-center justify-between">
                            <span>System Configuration</span>
                            <Switch checked disabled />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Gate Management</span>
                            <Switch checked disabled />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Audit Logs</span>
                            <Switch checked disabled />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Data Export</span>
                            <Switch checked disabled />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="border rounded-lg p-4">
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <h3 className="font-medium">Admin Officer</h3>
                        <p className="text-sm text-muted-foreground">Supporting administrator with configurable access</p>
                      </div>
                      <Badge variant="secondary">Multiple allowed</Badge>
                    </div>
                    
                    <div className="grid gap-3 md:grid-cols-2">
                      <div className="space-y-2">
                        <Label className="text-sm">Core Permissions</Label>
                        <div className="space-y-2 text-sm">
                          <div className="flex items-center justify-between">
                            <span>Resident Management</span>
                            <Switch defaultChecked />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Incident Reports</span>
                            <Switch defaultChecked />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Visitor Management</span>
                            <Switch defaultChecked />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Basic Reports</span>
                            <Switch defaultChecked />
                          </div>
                        </div>
                      </div>
                      
                      <div className="space-y-2">
                        <Label className="text-sm">Optional Permissions</Label>
                        <div className="space-y-2 text-sm">
                          <div className="flex items-center justify-between">
                            <span>Financial Access</span>
                            <Switch />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Gate Configuration</span>
                            <Switch />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>User Management</span>
                            <Switch />
                          </div>
                          <div className="flex items-center justify-between">
                            <span>System Settings</span>
                            <Switch />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                
                <Button>Save Role Configuration</Button>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="welcome" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Welcome Email Templates</CardTitle>
                <CardDescription>
                  Customize welcome emails and onboarding instructions for new admin users
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="subject">Email Subject</Label>
                    <Input 
                      id="subject"
                      defaultValue="Welcome to Village Tech - Your Admin Account is Ready!"
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="greeting">Email Greeting</Label>
                    <Textarea 
                      id="greeting"
                      rows={3}
                      defaultValue="Hello {USER_NAME},

Welcome to Village Tech! Your administrative account for {COMMUNITY_NAME} has been created and is ready for use."
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="instructions">Login Instructions</Label>
                    <Textarea 
                      id="instructions"
                      rows={6}
                      defaultValue="To get started:

1. Visit the admin portal at: {LOGIN_URL}
2. Use your email address: {USER_EMAIL}
3. Your temporary password is: {TEMP_PASSWORD}
4. You'll be required to create a new password on first login

For security reasons, this temporary password will expire in 7 days."
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="support">Support Information</Label>
                    <Textarea 
                      id="support"
                      rows={4}
                      defaultValue="If you need assistance or have questions:
- Email: support@villagetech.com
- Phone: 1-800-VILLAGE (1-800-845-5243)
- Documentation: {HELP_URL}

Welcome aboard!
Village Tech Support Team"
                    />
                  </div>
                </div>
                
                <div className="flex space-x-2">
                  <Button>Save Template</Button>
                  <Button variant="outline">Preview Email</Button>
                  <Dialog open={isWelcomeDialogOpen} onOpenChange={setIsWelcomeDialogOpen}>
                    <DialogTrigger asChild>
                      <Button variant="outline">
                        <Send className="h-4 w-4 mr-2" />
                        Send Test Email
                      </Button>
                    </DialogTrigger>
                    <DialogContent>
                      <DialogHeader>
                        <DialogTitle>Send Test Welcome Email</DialogTitle>
                        <DialogDescription>
                          Send a test email to verify the template
                        </DialogDescription>
                      </DialogHeader>
                      <div className="space-y-4">
                        <div className="space-y-2">
                          <Label htmlFor="test-email">Test Email Address</Label>
                          <Input 
                            id="test-email"
                            type="email"
                            placeholder="test@example.com"
                          />
                        </div>
                      </div>
                      <DialogFooter>
                        <Button onClick={() => setIsWelcomeDialogOpen(false)}>
                          Send Test Email
                        </Button>
                      </DialogFooter>
                    </DialogContent>
                  </Dialog>
                </div>
                
                <div className="mt-4 p-4 bg-muted rounded-lg">
                  <p className="text-sm font-medium mb-2">Available Variables:</p>
                  <div className="grid gap-1 text-xs text-muted-foreground">
                    <span><code>{`{USER_NAME}`}</code> - Full name of the user</span>
                    <span><code>{`{USER_EMAIL}`}</code> - Email address of the user</span>
                    <span><code>{`{COMMUNITY_NAME}`}</code> - Name of the community</span>
                    <span><code>{`{TEMP_PASSWORD}`}</code> - Generated temporary password</span>
                    <span><code>{`{LOGIN_URL}`}</code> - URL to the admin portal</span>
                    <span><code>{`{HELP_URL}`}</code> - URL to documentation</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      )}
    </div>
  );
}