import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from './ui/table';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from './ui/dialog';
import { Textarea } from './ui/textarea';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Plus, Upload, Download, Building2, Home, Edit, Trash2 } from 'lucide-react';
import { Badge } from './ui/badge';

const mockTenants = [
  { id: 1, name: 'Sunset Gardens HOA' },
  { id: 2, name: 'Oak Valley Estates' },
  { id: 3, name: 'Pine Ridge Community' },
];

const mockResidences = [
  {
    id: 1,
    tenantId: 1,
    unitNumber: 'Block A - Lot 1',
    type: 'Single Family Home',
    size: '2,500 sq ft',
    occupancyLimit: 6,
    status: 'occupied',
    residents: 4,
  },
  {
    id: 2,
    tenantId: 1,
    unitNumber: 'Block A - Lot 2',
    type: 'Single Family Home',
    size: '2,200 sq ft',
    occupancyLimit: 6,
    status: 'vacant',
    residents: 0,
  },
  {
    id: 3,
    tenantId: 1,
    unitNumber: 'Block B - Unit 101',
    type: 'Townhouse',
    size: '1,800 sq ft',
    occupancyLimit: 4,
    status: 'occupied',
    residents: 3,
  },
  {
    id: 4,
    tenantId: 1,
    unitNumber: 'Block B - Unit 102',
    type: 'Townhouse',
    size: '1,800 sq ft',
    occupancyLimit: 4,
    status: 'maintenance',
    residents: 0,
  },
];

export function ResidenceSetup() {
  const [selectedTenant, setSelectedTenant] = useState('1');
  const [residences, setResidences] = useState(mockResidences);
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isBulkImportOpen, setIsBulkImportOpen] = useState(false);

  const filteredResidences = residences.filter(r => r.tenantId === parseInt(selectedTenant));

  const getStatusColor = (status) => {
    switch (status) {
      case 'occupied': return 'default';
      case 'vacant': return 'secondary';
      case 'maintenance': return 'destructive';
      default: return 'outline';
    }
  };

  const handleCreateResidence = (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const newResidence = {
      id: residences.length + 1,
      tenantId: parseInt(selectedTenant),
      unitNumber: formData.get('unitNumber'),
      type: formData.get('type'),
      size: formData.get('size'),
      occupancyLimit: parseInt(formData.get('occupancyLimit')),
      status: 'vacant',
      residents: 0,
    };
    setResidences([...residences, newResidence]);
    setIsCreateDialogOpen(false);
  };

  const handleDeleteResidence = (residenceId) => {
    setResidences(residences.filter(r => r.id !== residenceId));
  };

  const selectedTenantName = mockTenants.find(t => t.id === parseInt(selectedTenant))?.name || '';

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1>Residence Setup</h1>
          <p className="text-muted-foreground">
            Configure residential units and properties for communities
          </p>
        </div>
      </div>

      {/* Tenant Selection */}
      <Card>
        <CardHeader>
          <CardTitle>Select Community</CardTitle>
          <CardDescription>
            Choose a community to manage its residential units
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
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
            <div className="flex items-end space-x-2">
              <Dialog open={isBulkImportOpen} onOpenChange={setIsBulkImportOpen}>
                <DialogTrigger asChild>
                  <Button variant="outline">
                    <Upload className="h-4 w-4 mr-2" />
                    Bulk Import
                  </Button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle>Bulk Import Residences</DialogTitle>
                    <DialogDescription>
                      Upload a CSV file to import multiple residences at once.
                    </DialogDescription>
                  </DialogHeader>
                  <div className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="csv-file">CSV File</Label>
                      <Input id="csv-file" type="file" accept=".csv" />
                    </div>
                    <div className="p-4 bg-muted rounded-md">
                      <p className="text-sm font-medium mb-2">CSV Format:</p>
                      <code className="text-xs">
                        unitNumber,type,size,occupancyLimit<br/>
                        "Block A - Lot 1","Single Family Home","2500 sq ft",6<br/>
                        "Block B - Unit 101","Townhouse","1800 sq ft",4
                      </code>
                    </div>
                  </div>
                  <DialogFooter>
                    <Button variant="outline" onClick={() => setIsBulkImportOpen(false)}>
                      Cancel
                    </Button>
                    <Button>Import Residences</Button>
                  </DialogFooter>
                </DialogContent>
              </Dialog>
              
              <Button variant="outline">
                <Download className="h-4 w-4 mr-2" />
                Export Template
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {selectedTenant && (
        <Tabs defaultValue="residences" className="space-y-4">
          <TabsList>
            <TabsTrigger value="residences">Residential Units</TabsTrigger>
            <TabsTrigger value="numbering">Numbering Scheme</TabsTrigger>
            <TabsTrigger value="types">Unit Types</TabsTrigger>
          </TabsList>

          <TabsContent value="residences" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <div>
                    <CardTitle>Residential Units - {selectedTenantName}</CardTitle>
                    <CardDescription>
                      Manage individual residential units and their properties
                    </CardDescription>
                  </div>
                  
                  <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
                    <DialogTrigger asChild>
                      <Button>
                        <Plus className="h-4 w-4 mr-2" />
                        Add Unit
                      </Button>
                    </DialogTrigger>
                    <DialogContent>
                      <form onSubmit={handleCreateResidence}>
                        <DialogHeader>
                          <DialogTitle>Add Residential Unit</DialogTitle>
                          <DialogDescription>
                            Create a new residential unit for {selectedTenantName}.
                          </DialogDescription>
                        </DialogHeader>
                        <div className="grid gap-4 py-4">
                          <div className="grid gap-2">
                            <Label htmlFor="unitNumber">Unit Number / Identifier</Label>
                            <Input 
                              id="unitNumber" 
                              name="unitNumber" 
                              placeholder="Block A - Lot 1" 
                              required 
                            />
                          </div>
                          <div className="grid gap-2">
                            <Label htmlFor="type">Unit Type</Label>
                            <Select name="type" required>
                              <SelectTrigger>
                                <SelectValue placeholder="Select unit type" />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="Single Family Home">Single Family Home</SelectItem>
                                <SelectItem value="Townhouse">Townhouse</SelectItem>
                                <SelectItem value="Condo Unit">Condo Unit</SelectItem>
                                <SelectItem value="Apartment">Apartment</SelectItem>
                                <SelectItem value="Duplex">Duplex</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                          <div className="grid gap-2">
                            <Label htmlFor="size">Size</Label>
                            <Input 
                              id="size" 
                              name="size" 
                              placeholder="2,500 sq ft" 
                              required 
                            />
                          </div>
                          <div className="grid gap-2">
                            <Label htmlFor="occupancyLimit">Occupancy Limit</Label>
                            <Input 
                              id="occupancyLimit" 
                              name="occupancyLimit" 
                              type="number" 
                              placeholder="6" 
                              required 
                            />
                          </div>
                        </div>
                        <DialogFooter>
                          <Button type="submit">Add Unit</Button>
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
                      <TableHead>Unit Number</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead>Size</TableHead>
                      <TableHead>Occupancy</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Residents</TableHead>
                      <TableHead className="w-[100px]">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredResidences.map((residence) => (
                      <TableRow key={residence.id}>
                        <TableCell>
                          <div className="flex items-center space-x-2">
                            <Home className="h-4 w-4 text-muted-foreground" />
                            <span className="font-medium">{residence.unitNumber}</span>
                          </div>
                        </TableCell>
                        <TableCell>{residence.type}</TableCell>
                        <TableCell>{residence.size}</TableCell>
                        <TableCell>{residence.occupancyLimit} max</TableCell>
                        <TableCell>
                          <Badge variant={getStatusColor(residence.status)}>
                            {residence.status.charAt(0).toUpperCase() + residence.status.slice(1)}
                          </Badge>
                        </TableCell>
                        <TableCell>{residence.residents}/{residence.occupancyLimit}</TableCell>
                        <TableCell>
                          <div className="flex space-x-2">
                            <Button variant="ghost" size="sm">
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button 
                              variant="ghost" 
                              size="sm"
                              onClick={() => handleDeleteResidence(residence.id)}
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

          <TabsContent value="numbering" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Numbering Scheme Configuration</CardTitle>
                <CardDescription>
                  Set up the numbering scheme for residential units in {selectedTenantName}
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="scheme-type">Numbering Scheme Type</Label>
                    <Select defaultValue="block-lot">
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="block-lot">Block and Lot (Block A - Lot 1)</SelectItem>
                        <SelectItem value="unit-number">Unit Number (Unit 101)</SelectItem>
                        <SelectItem value="address">Address Based (123 Main St)</SelectItem>
                        <SelectItem value="building-unit">Building and Unit (Bldg 1 - Unit 1A)</SelectItem>
                        <SelectItem value="custom">Custom Format</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="prefix">Prefix (Optional)</Label>
                    <Input id="prefix" placeholder="RES" />
                  </div>
                </div>
                
                <div className="grid gap-4 md:grid-cols-3">
                  <div className="space-y-2">
                    <Label htmlFor="start-number">Starting Number</Label>
                    <Input id="start-number" type="number" defaultValue="1" />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="increment">Increment</Label>
                    <Input id="increment" type="number" defaultValue="1" />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="padding">Number Padding</Label>
                    <Select defaultValue="none">
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="none">None (1, 2, 3)</SelectItem>
                        <SelectItem value="2">2 digits (01, 02, 03)</SelectItem>
                        <SelectItem value="3">3 digits (001, 002, 003)</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="custom-format">Custom Format (for complex schemes)</Label>
                  <Input 
                    id="custom-format" 
                    placeholder="{BLOCK}-{LOT} or {BUILDING}{FLOOR}{UNIT}" 
                  />
                  <p className="text-xs text-muted-foreground">
                    Use placeholders like {`{BLOCK}, {LOT}, {BUILDING}, {FLOOR}, {UNIT}`}
                  </p>
                </div>

                <div className="flex space-x-2">
                  <Button>Save Numbering Scheme</Button>
                  <Button variant="outline">Preview Generated Numbers</Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="types" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Unit Types Configuration</CardTitle>
                <CardDescription>
                  Define and manage different types of residential units for {selectedTenantName}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="grid gap-4">
                    {[
                      { name: 'Single Family Home', count: 180, avgSize: '2,400 sq ft' },
                      { name: 'Townhouse', count: 120, avgSize: '1,800 sq ft' },
                      { name: 'Condo Unit', count: 150, avgSize: '1,200 sq ft' },
                    ].map((type, index) => (
                      <div key={index} className="flex items-center justify-between p-4 border rounded-lg">
                        <div className="flex items-center space-x-3">
                          <Building2 className="h-5 w-5 text-muted-foreground" />
                          <div>
                            <p className="font-medium">{type.name}</p>
                            <p className="text-sm text-muted-foreground">
                              {type.count} units • Avg size: {type.avgSize}
                            </p>
                          </div>
                        </div>
                        <div className="flex space-x-2">
                          <Button variant="ghost" size="sm">
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button variant="ghost" size="sm">
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                  
                  <Button>
                    <Plus className="h-4 w-4 mr-2" />
                    Add Unit Type
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      )}
    </div>
  );
}