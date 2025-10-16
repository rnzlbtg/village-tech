import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Switch } from './ui/switch';
import { Textarea } from './ui/textarea';
import { Badge } from './ui/badge';
import { Upload, Image, Settings, DollarSign, Bell, Shield, Globe, Save, Mail } from 'lucide-react';
import { Separator } from './ui/separator';

const mockTenants = [
  { id: 1, name: 'Sunset Gardens HOA' },
  { id: 2, name: 'Oak Valley Estates' },
  { id: 3, name: 'Pine Ridge Community' },
];

export function PlatformConfiguration() {
  const [selectedTenant, setSelectedTenant] = useState('1');

  const selectedTenantName = mockTenants.find(t => t.id === parseInt(selectedTenant))?.name || '';

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1>Platform Configuration</h1>
          <p className="text-muted-foreground">
            Configure tenant-specific settings and platform-wide configurations
          </p>
        </div>
      </div>

      {/* Tenant Selection */}
      <Card>
        <CardHeader>
          <CardTitle>Select Community</CardTitle>
          <CardDescription>
            Choose a community to configure its settings
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
        <Tabs defaultValue="branding" className="space-y-4">
          <TabsList className="grid w-full grid-cols-6">
            <TabsTrigger value="branding">Branding</TabsTrigger>
            <TabsTrigger value="stickers">Stickers</TabsTrigger>
            <TabsTrigger value="fees">Fees</TabsTrigger>
            <TabsTrigger value="notifications">Notifications</TabsTrigger>
            <TabsTrigger value="rules">Rules</TabsTrigger>
            <TabsTrigger value="integrations">Integrations</TabsTrigger>
          </TabsList>

          <TabsContent value="branding" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Community Branding - {selectedTenantName}</CardTitle>
                <CardDescription>
                  Configure visual identity and branding elements
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid gap-6 md:grid-cols-2">
                  <div className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="logo-upload">Community Logo</Label>
                      <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                        <Image className="mx-auto h-12 w-12 text-gray-400" />
                        <div className="mt-2">
                          <Button variant="outline" size="sm">
                            <Upload className="h-4 w-4 mr-2" />
                            Upload Logo
                          </Button>
                        </div>
                        <p className="text-xs text-muted-foreground mt-1">
                          PNG, JPG up to 2MB (recommended: 200x200px)
                        </p>
                      </div>
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor="community-name">Community Display Name</Label>
                      <Input 
                        id="community-name"
                        defaultValue={selectedTenantName}
                      />
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor="tagline">Community Tagline</Label>
                      <Input 
                        id="tagline"
                        placeholder="Your community, secured"
                      />
                    </div>
                  </div>
                  
                  <div className="space-y-4">
                    <div className="space-y-2">
                      <Label>Color Scheme</Label>
                      <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <Label htmlFor="primary-color" className="text-sm">Primary Color</Label>
                          <div className="flex space-x-2">
                            <Input 
                              id="primary-color"
                              type="color"
                              defaultValue="#030213"
                              className="w-16 h-10 p-1"
                            />
                            <Input 
                              defaultValue="#030213"
                              className="flex-1"
                            />
                          </div>
                        </div>
                        <div className="space-y-2">
                          <Label htmlFor="secondary-color" className="text-sm">Secondary Color</Label>
                          <div className="flex space-x-2">
                            <Input 
                              id="secondary-color"
                              type="color"
                              defaultValue="#f3f4f6"
                              className="w-16 h-10 p-1"
                            />
                            <Input 
                              defaultValue="#f3f4f6"
                              className="flex-1"
                            />
                          </div>
                        </div>
                      </div>
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor="font-family">Font Family</Label>
                      <Select defaultValue="inter">
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="inter">Inter</SelectItem>
                          <SelectItem value="roboto">Roboto</SelectItem>
                          <SelectItem value="opensans">Open Sans</SelectItem>
                          <SelectItem value="lato">Lato</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor="theme">Theme Preference</Label>
                      <Select defaultValue="auto">
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="light">Light</SelectItem>
                          <SelectItem value="dark">Dark</SelectItem>
                          <SelectItem value="auto">Auto (System)</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                </div>
                
                <Separator />
                
                <div className="space-y-4">
                  <h3 className="font-medium">Preview</h3>
                  <div className="border rounded-lg p-4 bg-muted/50">
                    <div className="flex items-center space-x-3 mb-3">
                      <div className="w-12 h-12 bg-primary rounded-lg flex items-center justify-center">
                        <span className="text-primary-foreground font-bold">SG</span>
                      </div>
                      <div>
                        <h4 className="font-medium">{selectedTenantName}</h4>
                        <p className="text-sm text-muted-foreground">Your community, secured</p>
                      </div>
                    </div>
                    <p className="text-sm">This is how your community branding will appear in the resident app and communications.</p>
                  </div>
                </div>
                
                <Button>
                  <Save className="h-4 w-4 mr-2" />
                  Save Branding Settings
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="stickers" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Sticker Allocation Rules</CardTitle>
                <CardDescription>
                  Configure automatic sticker allocation for households
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid gap-6 md:grid-cols-2">
                  <div className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="default-stickers">Default Stickers per Household</Label>
                      <Input 
                        id="default-stickers"
                        type="number"
                        defaultValue="4"
                        min="1"
                        max="10"
                      />
                      <p className="text-xs text-muted-foreground">
                        Base allocation for new households
                      </p>
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor="max-stickers">Maximum Stickers per Household</Label>
                      <Input 
                        id="max-stickers"
                        type="number"
                        defaultValue="8"
                        min="1"
                        max="20"
                      />
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor="sticker-fee">Additional Sticker Fee</Label>
                      <div className="flex">
                        <span className="inline-flex items-center px-3 text-sm text-gray-900 bg-gray-200 border border-r-0 border-gray-300 rounded-l-md">
                          $
                        </span>
                        <Input 
                          id="sticker-fee"
                          type="number"
                          defaultValue="25.00"
                          step="0.01"
                          className="rounded-l-none"
                        />
                      </div>
                      <p className="text-xs text-muted-foreground">
                        Fee for stickers beyond the default allocation
                      </p>
                    </div>
                  </div>
                  
                  <div className="space-y-4">
                    <div className="space-y-3">
                      <Label>Allocation Rules by Unit Type</Label>
                      <div className="space-y-3">
                        <div className="flex items-center justify-between p-3 border rounded-lg">
                          <div>
                            <p className="font-medium">Single Family Home</p>
                            <p className="text-sm text-muted-foreground">Standard residential units</p>
                          </div>
                          <Input 
                            type="number"
                            defaultValue="4"
                            className="w-20"
                          />
                        </div>
                        <div className="flex items-center justify-between p-3 border rounded-lg">
                          <div>
                            <p className="font-medium">Townhouse</p>
                            <p className="text-sm text-muted-foreground">Multi-family units</p>
                          </div>
                          <Input 
                            type="number"
                            defaultValue="3"
                            className="w-20"
                          />
                        </div>
                        <div className="flex items-center justify-between p-3 border rounded-lg">
                          <div>
                            <p className="font-medium">Condo Unit</p>
                            <p className="text-sm text-muted-foreground">High-density units</p>
                          </div>
                          <Input 
                            type="number"
                            defaultValue="2"
                            className="w-20"
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                
                <Separator />
                
                <div className="space-y-4">
                  <Label>Advanced Options</Label>
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div>
                        <Label htmlFor="guest-stickers">Allow Guest Stickers</Label>
                        <p className="text-sm text-muted-foreground">Temporary stickers for visitors</p>
                      </div>
                      <Switch id="guest-stickers" defaultChecked />
                    </div>
                    <div className="flex items-center justify-between">
                      <div>
                        <Label htmlFor="auto-renewal">Auto-renewal</Label>
                        <p className="text-sm text-muted-foreground">Automatically renew stickers annually</p>
                      </div>
                      <Switch id="auto-renewal" defaultChecked />
                    </div>
                    <div className="flex items-center justify-between">
                      <div>
                        <Label htmlFor="replacement-fee">Replacement Fee</Label>
                        <p className="text-sm text-muted-foreground">Charge for lost/damaged sticker replacement</p>
                      </div>
                      <Switch id="replacement-fee" defaultChecked />
                    </div>
                  </div>
                </div>
                
                <Button>Save Sticker Configuration</Button>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="fees" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Fee Structures</CardTitle>
                <CardDescription>
                  Configure community fees and payment structures
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-6">
                  <div>
                    <h3 className="font-medium mb-4">Association Fees</h3>
                    <div className="grid gap-4 md:grid-cols-2">
                      <div className="space-y-2">
                        <Label htmlFor="monthly-hoa">Monthly HOA Fee</Label>
                        <div className="flex">
                          <span className="inline-flex items-center px-3 text-sm text-gray-900 bg-gray-200 border border-r-0 border-gray-300 rounded-l-md">
                            $
                          </span>
                          <Input 
                            id="monthly-hoa"
                            type="number"
                            defaultValue="150.00"
                            step="0.01"
                            className="rounded-l-none"
                          />
                        </div>
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="late-fee">Late Fee</Label>
                        <div className="flex">
                          <span className="inline-flex items-center px-3 text-sm text-gray-900 bg-gray-200 border border-r-0 border-gray-300 rounded-l-md">
                            $
                          </span>
                          <Input 
                            id="late-fee"
                            type="number"
                            defaultValue="25.00"
                            step="0.01"
                            className="rounded-l-none"
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div>
                    <h3 className="font-medium mb-4">Permit Fees</h3>
                    <div className="space-y-3">
                      <div className="flex items-center justify-between p-3 border rounded-lg">
                        <div>
                          <p className="font-medium">Construction Permit</p>
                          <p className="text-sm text-muted-foreground">Major renovations and additions</p>
                        </div>
                        <div className="flex items-center space-x-2">
                          <span>$</span>
                          <Input 
                            type="number"
                            defaultValue="500.00"
                            step="0.01"
                            className="w-24"
                          />
                        </div>
                      </div>
                      <div className="flex items-center justify-between p-3 border rounded-lg">
                        <div>
                          <p className="font-medium">Landscaping Permit</p>
                          <p className="text-sm text-muted-foreground">Yard modifications and plantings</p>
                        </div>
                        <div className="flex items-center space-x-2">
                          <span>$</span>
                          <Input 
                            type="number"
                            defaultValue="100.00"
                            step="0.01"
                            className="w-24"
                          />
                        </div>
                      </div>
                      <div className="flex items-center justify-between p-3 border rounded-lg">
                        <div>
                          <p className="font-medium">Moving Permit</p>
                          <p className="text-sm text-muted-foreground">Move-in/out coordination</p>
                        </div>
                        <div className="flex items-center space-x-2">
                          <span>$</span>
                          <Input 
                            type="number"
                            defaultValue="75.00"
                            step="0.01"
                            className="w-24"
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div>
                    <h3 className="font-medium mb-4">Other Fees</h3>
                    <div className="grid gap-4 md:grid-cols-2">
                      <div className="space-y-2">
                        <Label htmlFor="security-deposit">Security Deposit (Renters)</Label>
                        <div className="flex">
                          <span className="inline-flex items-center px-3 text-sm text-gray-900 bg-gray-200 border border-r-0 border-gray-300 rounded-l-md">
                            $
                          </span>
                          <Input 
                            id="security-deposit"
                            type="number"
                            defaultValue="200.00"
                            step="0.01"
                            className="rounded-l-none"
                          />
                        </div>
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="violation-fee">Violation Fine</Label>
                        <div className="flex">
                          <span className="inline-flex items-center px-3 text-sm text-gray-900 bg-gray-200 border border-r-0 border-gray-300 rounded-l-md">
                            $
                          </span>
                          <Input 
                            id="violation-fee"
                            type="number"
                            defaultValue="50.00"
                            step="0.01"
                            className="rounded-l-none"
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                
                <Button>
                  <DollarSign className="h-4 w-4 mr-2" />
                  Save Fee Structure
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="notifications" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Notification Preferences</CardTitle>
                <CardDescription>
                  Configure how residents receive notifications and communications
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-6">
                  <div>
                    <h3 className="font-medium mb-4">Notification Channels</h3>
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="email-notifications">Email Notifications</Label>
                          <p className="text-sm text-muted-foreground">Send notifications via email</p>
                        </div>
                        <Switch id="email-notifications" defaultChecked />
                      </div>
                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="sms-notifications">SMS Notifications</Label>
                          <p className="text-sm text-muted-foreground">Send urgent notifications via SMS</p>
                        </div>
                        <Switch id="sms-notifications" defaultChecked />
                      </div>
                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="push-notifications">Push Notifications</Label>
                          <p className="text-sm text-muted-foreground">Mobile app push notifications</p>
                        </div>
                        <Switch id="push-notifications" defaultChecked />
                      </div>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div>
                    <h3 className="font-medium mb-4">Notification Types</h3>
                    <div className="grid gap-3 md:grid-cols-2">
                      <div className="space-y-3">
                        <div className="flex items-center justify-between">
                          <Label htmlFor="security-alerts">Security Alerts</Label>
                          <Switch id="security-alerts" defaultChecked />
                        </div>
                        <div className="flex items-center justify-between">
                          <Label htmlFor="maintenance-updates">Maintenance Updates</Label>
                          <Switch id="maintenance-updates" defaultChecked />
                        </div>
                        <div className="flex items-center justify-between">
                          <Label htmlFor="community-news">Community News</Label>
                          <Switch id="community-news" defaultChecked />
                        </div>
                        <div className="flex items-center justify-between">
                          <Label htmlFor="payment-reminders">Payment Reminders</Label>
                          <Switch id="payment-reminders" defaultChecked />
                        </div>
                      </div>
                      <div className="space-y-3">
                        <div className="flex items-center justify-between">
                          <Label htmlFor="event-announcements">Event Announcements</Label>
                          <Switch id="event-announcements" defaultChecked />
                        </div>
                        <div className="flex items-center justify-between">
                          <Label htmlFor="violation-notices">Violation Notices</Label>
                          <Switch id="violation-notices" defaultChecked />
                        </div>
                        <div className="flex items-center justify-between">
                          <Label htmlFor="emergency-alerts">Emergency Alerts</Label>
                          <Switch id="emergency-alerts" defaultChecked />
                        </div>
                        <div className="flex items-center justify-between">
                          <Label htmlFor="system-messages">System Messages</Label>
                          <Switch id="system-messages" />
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div>
                    <h3 className="font-medium mb-4">Delivery Schedule</h3>
                    <div className="grid gap-4 md:grid-cols-2">
                      <div className="space-y-2">
                        <Label htmlFor="quiet-hours-start">Quiet Hours Start</Label>
                        <Input 
                          id="quiet-hours-start"
                          type="time"
                          defaultValue="22:00"
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="quiet-hours-end">Quiet Hours End</Label>
                        <Input 
                          id="quiet-hours-end"
                          type="time"
                          defaultValue="07:00"
                        />
                      </div>
                    </div>
                    <p className="text-sm text-muted-foreground">
                      Non-urgent notifications will be delayed during quiet hours
                    </p>
                  </div>
                </div>
                
                <Button>
                  <Bell className="h-4 w-4 mr-2" />
                  Save Notification Settings
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="rules" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Community Rules & Policies</CardTitle>
                <CardDescription>
                  Define community-specific rules, curfews, and policies
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-6">
                  <div>
                    <h3 className="font-medium mb-4">Curfew Times</h3>
                    <div className="grid gap-4 md:grid-cols-3">
                      <div className="space-y-2">
                        <Label htmlFor="adult-curfew">Adult Guests</Label>
                        <Input 
                          id="adult-curfew"
                          type="time"
                          defaultValue="23:00"
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="minor-curfew">Minor Guests</Label>
                        <Input 
                          id="minor-curfew"
                          type="time"
                          defaultValue="21:00"
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="noise-curfew">Noise Restrictions</Label>
                        <Input 
                          id="noise-curfew"
                          type="time"
                          defaultValue="22:00"
                        />
                      </div>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div>
                    <h3 className="font-medium mb-4">Visitor Policies</h3>
                    <div className="space-y-4">
                      <div className="space-y-2">
                        <Label htmlFor="max-visitors">Maximum Visitors per Household</Label>
                        <Input 
                          id="max-visitors"
                          type="number"
                          defaultValue="10"
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="visitor-duration">Maximum Visit Duration (hours)</Label>
                        <Input 
                          id="visitor-duration"
                          type="number"
                          defaultValue="12"
                        />
                      </div>
                      <div className="space-y-3">
                        <Label>Visitor Requirements</Label>
                        <div className="space-y-2">
                          <div className="flex items-center space-x-2">
                            <Switch id="pre-registration" defaultChecked />
                            <Label htmlFor="pre-registration">Require pre-registration</Label>
                          </div>
                          <div className="flex items-center space-x-2">
                            <Switch id="id-verification" />
                            <Label htmlFor="id-verification">ID verification required</Label>
                          </div>
                          <div className="flex items-center space-x-2">
                            <Switch id="escort-required" />
                            <Label htmlFor="escort-required">Resident escort required</Label>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div>
                    <h3 className="font-medium mb-4">Community Rules</h3>
                    <div className="space-y-4">
                      <div className="space-y-2">
                        <Label htmlFor="pet-policy">Pet Policy</Label>
                        <Textarea 
                          id="pet-policy"
                          rows={3}
                          defaultValue="Pets are allowed with registration. Maximum 2 pets per household. All pets must be leashed in common areas. Owners are responsible for cleaning up after pets."
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="parking-rules">Parking Rules</Label>
                        <Textarea 
                          id="parking-rules"
                          rows={3}
                          defaultValue="Each household is allocated 2 parking spaces. Guest parking is available in designated areas only. No overnight parking on streets. Vehicles must display valid parking stickers."
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="common-area-rules">Common Area Rules</Label>
                        <Textarea 
                          id="common-area-rules"
                          rows={3}
                          defaultValue="Common areas are for all residents to enjoy. No loud music or gatherings after 10 PM. Clean up after use. Pool hours: 6 AM - 10 PM. No glass containers in pool area."
                        />
                      </div>
                    </div>
                  </div>
                </div>
                
                <Button>
                  <Shield className="h-4 w-4 mr-2" />
                  Save Community Rules
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="integrations" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>External Integrations</CardTitle>
                <CardDescription>
                  Configure third-party services and API integrations
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-6">
                  <div>
                    <h3 className="font-medium mb-4">Payment Gateways</h3>
                    <div className="space-y-3">
                      <div className="flex items-center justify-between p-4 border rounded-lg">
                        <div className="flex items-center space-x-3">
                          <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                            <DollarSign className="h-5 w-5 text-blue-600" />
                          </div>
                          <div>
                            <p className="font-medium">Stripe</p>
                            <p className="text-sm text-muted-foreground">Credit card processing</p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Badge variant="default">Connected</Badge>
                          <Button variant="outline" size="sm">Configure</Button>
                        </div>
                      </div>
                      <div className="flex items-center justify-between p-4 border rounded-lg">
                        <div className="flex items-center space-x-3">
                          <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                            <DollarSign className="h-5 w-5 text-green-600" />
                          </div>
                          <div>
                            <p className="font-medium">PayPal</p>
                            <p className="text-sm text-muted-foreground">Online payments</p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Badge variant="secondary">Available</Badge>
                          <Button variant="outline" size="sm">Connect</Button>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div>
                    <h3 className="font-medium mb-4">SMS Providers</h3>
                    <div className="space-y-3">
                      <div className="flex items-center justify-between p-4 border rounded-lg">
                        <div className="flex items-center space-x-3">
                          <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                            <Bell className="h-5 w-5 text-red-600" />
                          </div>
                          <div>
                            <p className="font-medium">Twilio</p>
                            <p className="text-sm text-muted-foreground">SMS and voice services</p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Badge variant="default">Connected</Badge>
                          <Button variant="outline" size="sm">Configure</Button>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div>
                    <h3 className="font-medium mb-4">Email Services</h3>
                    <div className="space-y-3">
                      <div className="flex items-center justify-between p-4 border rounded-lg">
                        <div className="flex items-center space-x-3">
                          <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                            <Mail className="h-5 w-5 text-purple-600" />
                          </div>
                          <div>
                            <p className="font-medium">SendGrid</p>
                            <p className="text-sm text-muted-foreground">Email delivery service</p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Badge variant="default">Connected</Badge>
                          <Button variant="outline" size="sm">Configure</Button>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <Separator />
                  
                  <div>
                    <h3 className="font-medium mb-4">External APIs</h3>
                    <div className="space-y-4">
                      <div className="space-y-2">
                        <Label htmlFor="weather-api">Weather API Key</Label>
                        <Input 
                          id="weather-api"
                          type="password"
                          placeholder="Enter API key"
                        />
                        <p className="text-xs text-muted-foreground">
                          For weather alerts and community event planning
                        </p>
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="maps-api">Google Maps API Key</Label>
                        <Input 
                          id="maps-api"
                          type="password"
                          placeholder="Enter API key"
                        />
                        <p className="text-xs text-muted-foreground">
                          For location services and gate mapping
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
                
                <Button>
                  <Globe className="h-4 w-4 mr-2" />
                  Save Integration Settings
                </Button>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      )}
    </div>
  );
}