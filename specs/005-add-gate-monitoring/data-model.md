# Data Model: Gate Monitoring Feature

**Feature**: Gate Monitoring Feature
**Date**: 2025-10-16

## Core Entities

### Gates
```sql
CREATE TABLE gates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  location VARCHAR(255),
  gate_type VARCHAR(50) CHECK (gate_type IN ('main', 'pedestrian', 'service', 'emergency')),
  operational_status VARCHAR(50) DEFAULT 'active' CHECK (operational_status IN ('active', 'maintenance', 'offline', 'error')),
  equipment_config JSONB DEFAULT '{}',
  has_rfid_reader BOOLEAN DEFAULT false,
  has_barrier BOOLEAN DEFAULT false,
  operating_hours JSONB DEFAULT '{"24/7": true}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Access Permissions
```sql
CREATE TABLE access_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  household_id UUID REFERENCES households(id) ON DELETE CASCADE,
  gate_id UUID REFERENCES gates(id) ON DELETE CASCADE,
  permission_type VARCHAR(50) NOT NULL CHECK (permission_type IN ('resident', 'visitor', 'service', 'emergency')),
  access_level VARCHAR(50) NOT NULL CHECK (access_level IN ('full', 'limited', 'time_restricted')),
  valid_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  valid_until TIMESTAMPTZ,
  access_days JSONB DEFAULT '["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]',
  access_time_start TIME,
  access_time_end TIME,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, gate_id, valid_from)
);
```

### Visitor Access Requests
```sql
CREATE TABLE visitor_access_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  visitor_name VARCHAR(255) NOT NULL,
  visitor_contact VARCHAR(100),
  visitor_email VARCHAR(255),
  vehicle_plate VARCHAR(20),
  visit_purpose TEXT,
  expected_arrival TIMESTAMPTZ,
  expected_departure TIMESTAMPTZ,
  access_granted BOOLEAN DEFAULT false,
  access_granted_at TIMESTAMPTZ,
  granted_by UUID REFERENCES auth.users(id),
  qr_code VARCHAR(255) UNIQUE,
  temporary_access_code VARCHAR(255),
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'expired', 'checked_in', 'checked_out')),
  check_in_time TIMESTAMPTZ,
  check_out_time TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Gate Access Logs
```sql
CREATE TABLE gate_access_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  household_id UUID REFERENCES households(id),
  gate_id UUID NOT NULL REFERENCES gates(id),
  access_type VARCHAR(20) NOT NULL CHECK (access_type IN ('entry', 'exit')),
  verification_method VARCHAR(50) NOT NULL CHECK (verification_method IN ('rfid', 'qr_code', 'manual', 'face_recognition', 'license_plate')),
  verification_status VARCHAR(20) NOT NULL CHECK (verification_status IN ('granted', 'denied')),
  access_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  denial_reason TEXT,
  person_name VARCHAR(255),
  vehicle_plate VARCHAR(20),
  additional_data JSONB DEFAULT '{}',
  guard_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Security Alerts
```sql
CREATE TABLE security_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  alert_type VARCHAR(50) NOT NULL CHECK (alert_type IN ('multiple_failed_access', 'after_hours_access', 'unauthorized_vehicle', 'system_error', 'suspicious_activity')),
  severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  source_data JSONB,
  status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'investigating', 'resolved', 'false_positive')),
  assigned_to UUID REFERENCES auth.users(id),
  acknowledged_at TIMESTAMPTZ,
  acknowledged_by UUID REFERENCES auth.users(id),
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES auth.users(id),
  resolution_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Curfew Settings
```sql
CREATE TABLE curfew_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  days_of_week TEXT[] NOT NULL DEFAULT ARRAY['monday','tuesday','wednesday','thursday','friday','saturday','sunday'],
  affected_gates UUID[] DEFAULT '{}',
  exception_roles TEXT[] DEFAULT ARRAY['admin_head','admin_officer','guard'],
  is_active BOOLEAN DEFAULT true,
  grace_period_minutes INTEGER DEFAULT 15,
  notification_before_minutes INTEGER DEFAULT 30,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, name)
);
```

## Relationships

### Primary Relationships
- `tenants` 1→M `gates` (One tenant has many gates)
- `tenants` 1→M `access_permissions` (One tenant has many permissions)
- `gates` 1→M `access_permissions` (One gate has many permissions)
- `households` 1→M `access_permissions` (One household has many permissions)
- `users` 1→M `access_permissions` (One user has many permissions)
- `gates` 1→M `gate_access_logs` (One gate has many access logs)

### Secondary Relationships
- `tenants` 1→M `visitor_access_requests`
- `households` 1→M `visitor_access_requests`
- `tenants` 1→M `security_alerts`
- `tenants` 1→M `curfew_settings`

## Validation Rules

### Access Permissions
- `valid_from` must be before `valid_until` (if specified)
- `access_time_start` must be before `access_time_end` (if both specified)
- Either `user_id` or `household_id` must be specified
- `access_days` must contain valid day names

### Visitor Access Requests
- `expected_arrival` must be before `expected_departure`
- `access_granted_at` must be after request creation
- Status transitions must follow valid sequence

### Gate Access Logs
- `access_timestamp` cannot be in the future
- `denial_reason` required when `verification_status` is 'denied'
- Either `user_id`, `person_name`, or `vehicle_plate` must be specified

## Indexes

### Performance Indexes
```sql
-- Access validation queries
CREATE INDEX idx_access_permissions_user_active ON access_permissions(user_id, is_active) WHERE is_active = true;
CREATE INDEX idx_access_permissions_gate_active ON access_permissions(gate_id, is_active) WHERE is_active = true;

-- Log queries
CREATE INDEX idx_gate_access_logs_tenant_timestamp ON gate_access_logs(tenant_id, access_timestamp DESC);
CREATE INDEX idx_gate_access_logs_gate_timestamp ON gate_access_logs(gate_id, access_timestamp DESC);
CREATE INDEX idx_gate_access_logs_user_timestamp ON gate_access_logs(user_id, access_timestamp DESC);

-- Visitor management
CREATE INDEX idx_visitor_requests_status ON visitor_access_requests(status);
CREATE INDEX idx_visitor_requests_household ON visitor_access_requests(household_id);

-- Security alerts
CREATE INDEX idx_security_alerts_tenant_status ON security_alerts(tenant_id, status);
CREATE INDEX idx_security_alerts_severity ON security_alerts(severity, status);
```

### RLS Policy Indexes
```sql
CREATE INDEX idx_access_permissions_tenant_rls ON access_permissions(tenant_id);
CREATE INDEX idx_gate_access_logs_tenant_rls ON gate_access_logs(tenant_id);
CREATE INDEX idx_visitor_requests_tenant_rls ON visitor_access_requests(tenant_id);
CREATE INDEX idx_security_alerts_tenant_rls ON security_alerts(tenant_id);
```

## Data Types

### JSONB Schema Examples

#### Gates Equipment Config
```json
{
  "rfid_reader": {
    "enabled": true,
    "model": "XYZ-1000",
    "last_maintenance": "2024-10-01"
  },
  "camera": {
    "enabled": true,
    "resolution": "1080p",
    "night_vision": true
  },
  "barrier": {
    "type": "automatic",
    "opening_time_ms": 3000
  }
}
```

#### Access Days
```json
["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
```

#### Additional Data (Access Logs)
```json
{
  "temperature": 22.5,
  "weather": "clear",
  "confidence_score": 0.95,
  "image_url": "https://storage.example.com/access-images/abc123.jpg"
}
```

## State Transitions

### Visitor Status Flow
```
pending → approved → checked_in → checked_out
    ↓         ↓           ↓
 rejected  expired    expired
```

### Security Alert Status Flow
```
open → investigating → resolved
  ↓       ↓           ↓
false_positive  resolved
```

### Gate Status Changes
```
active → maintenance → active
   ↓         ↓
offline    error → active
```

## Data Retention

### Access Logs
- **Active period**: 90 days in main table
- **Archive period**: 2 years in archive table
- **Deletion**: After 2 years

### Security Alerts
- **Active alerts**: Retained indefinitely until resolved
- **Resolved alerts**: 1 year in active table, then archive

### Visitor Requests
- **Pending requests**: 30 days auto-expiration
- **Completed requests**: 1 year retention

### Audit Logs
- **System logs**: 6 months retention
- **Security logs**: 2 years retention