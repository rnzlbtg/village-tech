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
import { Plus, Shield, MapPin, Clock, Wifi, Edit, Trash2, AlertCircle } from 'lucide-react';
import { Switch } from './ui/switch';

const mockTenants = [
  { id: 1, name: 'Sunset Gardens HOA' },
  { id: 2, name: 'Oak Valley Estates' },
  { id: 3, name: 'Pine Ridge Community' },
];

const mockGates = [
  {
    id: 1,
    tenantId: 1,
    name: 'Main Gate',
    type: 'vehicle',
    status: 'active',
    operatingHours: '24/7',
    rfidReaderId: 'RFID-001',
    coordinates: { lat: 33.4484, lng: -112.0740 },
    lastActivity: '2024-01-15 14:30:00',
  },
  {
    id: 2,
    tenantId: 1,
    name: 'Pedestrian Entrance',
    type: 'pedestrian',
    status: 'active',
    operatingHours: '06:00-22:00',
    rfidReaderId: 'RFID-002',
    coordinates: { lat: 33.4489, lng: -112.0745 },
    lastActivity: '2024-01-15 13:45:00',
  },
  {
    id: 3,
    tenantId: 1,
    name: 'Service Gate',
    type: 'service',
    status: 'maintenance',
    operatingHours: '08:00-17:00',
    rfidReaderId: 'RFID-003',
    coordinates: { lat: 33.4479, lng: -112.0735 },
    lastActivity: '2024-01-14 16:20:00',
  },
];

export function GateManagement() {
  const [selectedTenant, setSelectedTenant] = useState('1');
  const [gates, setGates] = useState(mockGates);
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);

  const filteredGates = gates.filter(g => g.tenantId === parseInt(selectedTenant));

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'default';
      case 'maintenance': return 'destructive';
      case 'closed': return 'secondary';
      default: return 'outline';
    }
  };

  const getTypeIcon = (type) => {
    switch (type) {
      case 'vehicle': return '🚗';
      case 'pedestrian': return '🚶';
      case 'service': return '🚛';
      default: return '🚪';
    }
  };

  const handleCreateGate = (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const newGate = {
      id: gates.length + 1,
      tenantId: parseInt(selectedTenant),
      name: formData.get('name'),
      type: formData.get('type'),
      status: 'active',
      operatingHours: `${formData.get('openTime')}-${formData.get('closeTime')}`,
      rfidReaderId: formData.get('rfidReaderId'),
      coordinates: {
        lat: parseFloat(formData.get('latitude')) || 0,
        lng: parseFloat(formData.get('longitude')) || 0,
      },
      lastActivity: new Date().toISOString().replace('T', ' ').slice(0, 19),
    };
    setGates([...gates, newGate]);
    setIsCreateDialogOpen(false);
  };

  const handleDeleteGate = (gateId) => {
    setGates(gates.filter(g => g.id !== gateId));
  };

  const selectedTenantName = mockTenants.find(t => t.id === parseInt(selectedTenant))?.name || '';

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1>Gate Management</h1>
          <p className="text-muted-foreground">
            Configure and monitor community entrance points and access control
          </p>
        </div>
      </div>

      {/* Tenant Selection */}
      <Card>
        <CardHeader>
          <CardTitle>Select Community</CardTitle>
          <CardDescription>
            Choose a community to manage its gates and entrance points
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
        <Tabs defaultValue="gates" className="space-y-4">
          <TabsList>
            <TabsTrigger value="gates">Gates & Entrances</TabsTrigger>
            <TabsTrigger value="rfid">RFID Readers</TabsTrigger>
            <TabsTrigger value="schedules">Operating Schedules</TabsTrigger>
          </TabsList>

          <TabsContent value="gates" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <div>
                    <CardTitle>Gates & Entrances - {selectedTenantName}</CardTitle>
                    <CardDescription>
                      Manage entrance points and their configurations
                    </CardDescription>
                  </div>
                  
                  <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
                    <DialogTrigger asChild>
                      <Button>
                        <Plus className="h-4 w-4 mr-2" />
                        Add Gate
                      </Button>
                    </DialogTrigger>
                    <DialogContent className="sm:max-w-[500px]">
                      <form onSubmit={handleCreateGate}>
                        <DialogHeader>
                          <DialogTitle>Add New Gate</DialogTitle>
                          <DialogDescription>
                            Create a new entrance point for {selectedTenantName}.
                          </DialogDescription>
                        </DialogHeader>
                        <div className="grid gap-4 py-4">
                          <div className="grid gap-2">
                            <Label htmlFor="name">Gate Name</Label>
                            <Input 
                              id="name" 
                              name="name" 
                              placeholder="Main Gate" 
                              required 
                            />
                          </div>
                          <div className="grid gap-2">
                            <Label htmlFor="type">Gate Type</Label>
                            <Select name="type" required>
                              <SelectTrigger>
                                <SelectValue placeholder="Select gate type" />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="vehicle">Vehicle Gate</SelectItem>
                                <SelectItem value="pedestrian">Pedestrian Gate</SelectItem>
                                <SelectItem value="service">Service/Delivery Gate</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                          <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                              <Label htmlFor="openTime">Opening Time</Label>
                              <Input 
                                id="openTime" 
                                name="openTime" 
                                type="time" 
                                defaultValue="00:00"
                              />
                            </div>
                            <div className="space-y-2">
                              <Label htmlFor="closeTime">Closing Time</Label>
                              <Input 
                                id="closeTime" 
                                name="closeTime" 
                                type="time" 
                                defaultValue="23:59"
                              />
                            </div>
                          </div>
                          <div className="grid gap-2">
                            <Label htmlFor="rfidReaderId">RFID Reader ID</Label>
                            <Input 
                              id="rfidReaderId" 
                              name="rfidReaderId" 
                              placeholder="RFID-001" 
                              required 
                            />
                          </div>
                          <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                              <Label htmlFor="latitude">Latitude</Label>
                              <Input 
                                id="latitude" 
                                name="latitude" 
                                type="number" 
                                step="any"
                                placeholder="33.4484"
                              />
                            </div>
                            <div className="space-y-2">
                              <Label htmlFor="longitude">Longitude</Label>
                              <Input 
                                id="longitude" 
                                name="longitude" 
                                type="number" 
                                step="any"
                                placeholder="-112.0740"
                              />
                            </div>
                          </div>
                        </div>
                        <DialogFooter>
                          <Button type="submit">Add Gate</Button>
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
                      <TableHead>Gate Name</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Operating Hours</TableHead>
                      <TableHead>RFID Reader</TableHead>
                      <TableHead>Last Activity</TableHead>
                      <TableHead className="w-[100px]">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredGates.map((gate) => (
                      <TableRow key={gate.id}>
                        <TableCell>
                          <div className="flex items-center space-x-2">
                            <span className="text-lg">{getTypeIcon(gate.type)}</span>
                            <div>
                              <p className="font-medium">{gate.name}</p>
                              <p className="text-sm text-muted-foreground">
                                <MapPin className="h-3 w-3 inline mr-1" />
                                {gate.coordinates.lat.toFixed(4)}, {gate.coordinates.lng.toFixed(4)}
                              </p>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell className="capitalize">{gate.type}</TableCell>
                        <TableCell>
                          <Badge variant={getStatusColor(gate.status)}>
                            {gate.status === 'maintenance' && <AlertCircle className="h-3 w-3 mr-1" />}
                            {gate.status.charAt(0).toUpperCase() + gate.status.slice(1)}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center space-x-1">
                            <Clock className="h-3 w-3" />
                            <span>{gate.operatingHours}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center space-x-1">
                            <Wifi className="h-3 w-3" />
                            <span>{gate.rfidReaderId}</span>
                          </div>
                        </TableCell>
                        <TableCell className="text-sm">{gate.lastActivity}</TableCell>
                        <TableCell>
                          <div className="flex space-x-2">
                            <Button variant="ghost" size="sm">
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button 
                              variant="ghost" 
                              size="sm"
                              onClick={() => handleDeleteGate(gate.id)}
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

          <TabsContent value="rfid" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>RFID Reader Configuration</CardTitle>
                <CardDescription>
                  Manage RFID readers and their assignments to gates
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid gap-4">
                  {filteredGates.map((gate) => (
                    <div key={gate.id} className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="flex items-center space-x-3">
                        <Wifi className="h-5 w-5 text-muted-foreground" />
                        <div>
                          <p className="font-medium">{gate.rfidReaderId}</p>
                          <p className="text-sm text-muted-foreground">
                            Assigned to: {gate.name}
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center space-x-4">
                        <Badge variant={gate.status === 'active' ? 'default' : 'destructive'}>
                          {gate.status === 'active' ? 'Online' : 'Offline'}
                        </Badge>
                        <Button variant="outline" size="sm">
                          Configure
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
                
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Add RFID Reader
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="schedules" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Operating Schedules</CardTitle>
                <CardDescription>
                  Configure operating hours and special schedules for gates
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                {filteredGates.map((gate) => (
                  <div key={gate.id} className="border rounded-lg p-4">
                    <div className="flex items-center justify-between mb-4">
                      <div className="flex items-center space-x-2">
                        <Shield className="h-5 w-5 text-muted-foreground" />
                        <h3 className="font-medium">{gate.name}</h3>
                      </div>
                      <Badge variant="outline">{gate.operatingHours}</Badge>
                    </div>
                    
                    <div className="grid gap-4 md:grid-cols-2">
                      <div className="space-y-3">
                        <Label>Regular Schedule</Label>
                        <div className="grid grid-cols-2 gap-2">
                          <div>
                            <Label htmlFor={`open-${gate.id}`} className="text-sm">Open Time</Label>
                            <Input 
                              id={`open-${gate.id}`}
                              type="time" 
                              defaultValue="06:00"
                              className="text-sm"
                            />
                          </div>
                          <div>
                            <Label htmlFor={`close-${gate.id}`} className="text-sm">Close Time</Label>
                            <Input 
                              id={`close-${gate.id}`}
                              type="time" 
                              defaultValue="22:00"
                              className="text-sm"
                            />
                          </div>
                        </div>
                      </div>
                      
                      <div className="space-y-3">
                        <Label>Special Settings</Label>
                        <div className="space-y-2">
                          <div className="flex items-center justify-between">
                            <Label htmlFor={`always-open-${gate.id}`} className="text-sm">24/7 Operation</Label>
                            <Switch id={`always-open-${gate.id}`} />
                          </div>
                          <div className="flex items-center justify-between">
                            <Label htmlFor={`holiday-hours-${gate.id}`} className="text-sm">Holiday Hours</Label>
                            <Switch id={`holiday-hours-${gate.id}`} />
                          </div>
                          <div className="flex items-center justify-between">
                            <Label htmlFor={`emergency-override-${gate.id}`} className="text-sm">Emergency Override</Label>
                            <Switch id={`emergency-override-${gate.id}`} />
                          </div>
                        </div>
                      </div>
                    </div>
                    
                    <div className="flex justify-end mt-4">
                      <Button size="sm" variant="outline">
                        Update Schedule
                      </Button>
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      )}
    </div>
  );
}