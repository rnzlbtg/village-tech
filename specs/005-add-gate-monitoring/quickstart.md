# Quickstart Guide: Gate Monitoring Feature

**Feature**: Gate Monitoring Feature
**Application**: 002-admin-app-residential
**Date**: 2025-10-16

## Overview

The Gate Monitoring Feature provides real-time monitoring, access control, and security management for residential community gates. This guide helps developers quickly understand and implement the feature.

## Prerequisites

- Node.js 20 LTS or higher
- PostgreSQL 14+ with Row-Level Security enabled
- Redis for real-time messaging (optional for single-instance deployment)
- Existing Village Tech v4 setup with admin app structure

## Core Concepts

### Multi-Tenant Architecture
- Each residential community (tenant) has isolated gate data
- Row-Level Security (RLS) ensures data separation
- Admin users can only access their own tenant's gates and data

### Real-time Monitoring
- WebSocket connections for live gate activity updates
- 5-second latency requirement for activity display
- Automatic fallback to HTTP polling when WebSockets unavailable

### Access Control System
- Role-based permissions (admin, guard, household_head, resident)
- Time-based access restrictions and curfew enforcement
- Visitor management with temporary access credentials

## Getting Started

### 1. Database Setup

```sql
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create indexes for performance
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_gate_access_logs_tenant_timestamp
ON gate_access_logs(tenant_id, access_timestamp DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_access_permissions_user_active
ON access_permissions(user_id, is_active) WHERE is_active = true;
```

### 2. Environment Variables

```bash
# Real-time messaging
REDIS_URL=redis://localhost:6379
WEBSOCKET_PORT=3001

# Security
JWT_SECRET=your-jwt-secret-here
ACCESS_CODE_EXPIRY_MINUTES=30

# Notifications
EMAIL_FROM=noreply@villagetech.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
```

### 3. API Integration

#### Real-time Monitoring Setup

```typescript
// Client-side WebSocket connection
import io from 'socket.io-client';

const socket = io(process.env.REACT_APP_WS_URL, {
  transports: ['websocket'],
  upgrade: false
});

// Subscribe to gate activities
socket.emit('subscribe-gate-events', ['gate-1', 'gate-2']);

// Listen for real-time updates
socket.on('gate-activity', (activity) => {
  updateActivityFeed(activity);
});

socket.on('security-alert', (alert) => {
  showAlertNotification(alert);
});
```

#### Access Validation

```typescript
// Server-side access validation
const validateAccess = async (request: AccessValidationRequest) => {
  const { user_id, gate_id, access_type, verification_method } = request;

  // Check permissions
  const hasPermission = await checkAccessPermission(user_id, gate_id);
  if (!hasPermission) {
    return { allowed: false, reason: 'Access denied: No permission' };
  }

  // Check curfew
  const curfewResult = await validateCurfewAccess(user_id, gate_id);
  if (!curfewResult.allowed) {
    return { allowed: false, reason: curfewResult.reason };
  }

  // Log access attempt
  await logAccessAttempt({
    user_id,
    gate_id,
    access_type,
    verification_method,
    verification_status: 'granted',
    access_timestamp: new Date()
  });

  return { allowed: true, access_code: generateAccessCode() };
};
```

### 4. Frontend Components

#### Activity Timeline Component

```typescript
import React, { useState, useEffect } from 'react';
import { socket } from '../services/socket';

const ActivityTimeline: React.FC = () => {
  const [activities, setActivities] = useState<GateActivity[]>([]);

  useEffect(() => {
    // Listen for real-time updates
    socket.on('gate-activity', (newActivity: GateActivity) => {
      setActivities(prev => [newActivity, ...prev.slice(0, 99)]);
    });

    return () => socket.off('gate-activity');
  }, []);

  return (
    <div className="activity-timeline">
      {activities.map(activity => (
        <ActivityItem key={activity.id} activity={activity} />
      ))}
    </div>
  );
};
```

#### Access Permission Management

```typescript
const AccessPermissionForm: React.FC = () => {
  const [formData, setFormData] = useState({
    user_id: '',
    gate_id: '',
    access_level: 'full',
    access_days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
    valid_from: new Date().toISOString().split('T')[0],
    valid_until: '',
    access_time_start: '00:00',
    access_time_end: '23:59'
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    try {
      const response = await fetch('/api/access/permissions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      if (response.ok) {
        // Show success message and refresh permissions list
        showNotification('Access permission created successfully');
        refreshPermissionsList();
      }
    } catch (error) {
      showNotification('Failed to create access permission', 'error');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields for access permission */}
    </form>
  );
};
```

## Key API Endpoints

### Gates Management
- `GET /gates` - List all gates with current status
- `POST /gates` - Create new gate
- `PUT /gates/{id}` - Update gate configuration
- `GET /gates/{id}/status` - Get real-time gate status

### Access Control
- `POST /access/validate` - Validate access request
- `GET /access/permissions` - List access permissions
- `POST /access/permissions` - Create access permission
- `PUT /access/permissions/{id}` - Update permission
- `DELETE /access/permissions/{id}` - Revoke permission

### Visitor Management
- `GET /visitors/requests` - List visitor requests
- `POST /visitors/requests` - Create visitor request
- `POST /visitors/requests/{id}/approve` - Approve visitor
- `POST /visitors/requests/{id}/reject` - Reject visitor

### Security & Monitoring
- `GET /logs/access` - Get access logs with filtering
- `GET /alerts` - List security alerts
- `POST /alerts/{id}/acknowledge` - Acknowledge alert
- `POST /alerts/{id}/resolve` - Resolve alert

## WebSocket Events

### Client Events
```typescript
// Subscribe to gate activities
socket.emit('subscribe-gate-events', ['gate-1', 'gate-2']);

// Subscribe to security alerts
socket.emit('subscribe-alerts', { severity: ['high', 'critical'] });
```

### Server Events
```typescript
// Gate activity updates
socket.on('gate-activity', (data: GateActivity) => {
  // Update activity feed
});

// Security alerts
socket.on('security-alert', (data: SecurityAlert) => {
  // Show alert notification
});

// Gate status changes
socket.on('gate-status-change', (data: GateStatus) => {
  // Update gate status display
});
```

## Testing

### Unit Tests
```typescript
// Access validation test
describe('Access Validation', () => {
  test('should allow access for authorized user', async () => {
    const request = {
      user_id: 'user-uuid',
      gate_id: 'gate-uuid',
      access_type: 'entry',
      verification_method: 'rfid'
    };

    const result = await validateAccess(request);
    expect(result.allowed).toBe(true);
  });

  test('should deny access during curfew', async () => {
    // Mock curfew time
    const result = await validateAccess(request);
    expect(result.allowed).toBe(false);
    expect(result.reason).toContain('curfew');
  });
});
```

### Integration Tests
```typescript
// WebSocket connection test
describe('Real-time Updates', () => {
  test('should receive gate activity updates', (done) => {
    const socket = io('http://localhost:3001');

    socket.on('gate-activity', (activity) => {
      expect(activity.gate_id).toBe('test-gate');
      socket.disconnect();
      done();
    });

    // Simulate gate activity
    simulateGateActivity({
      gate_id: 'test-gate',
      access_type: 'entry',
      verification_status: 'granted'
    });
  });
});
```

## Performance Considerations

### Database Optimization
- Use composite indexes for frequently queried columns
- Implement database partitioning for high-volume access logs
- Cache frequently accessed permissions in Redis

### Real-time Performance
- Batch WebSocket messages to reduce network overhead
- Implement connection pooling for WebSocket servers
- Use Redis pub/sub for horizontal scaling

### Memory Management
- Implement sliding window for activity display (max 1000 items)
- Use virtual scrolling for large log lists
- Clear expired data from client-side cache

## Security Best Practices

### Multi-tenant Isolation
- All database queries must include tenant_id filter
- Use Row-Level Security (RLS) policies
- Validate tenant ownership on all operations

### Data Protection
- Encrypt sensitive personal information
- Implement audit logging for all access control changes
- Use secure authentication tokens with proper expiration

### Access Control
- Implement principle of least privilege
- Use role-based permissions with proper segregation
- Validate all input parameters and sanitize data

## Troubleshooting

### Common Issues

**WebSocket Connection Failed**
```typescript
// Add fallback to HTTP polling
const connectWithFallback = () => {
  const socket = io(wsUrl, {
    transports: ['websocket', 'polling'],
    timeout: 5000
  });

  socket.on('connect_error', () => {
    console.warn('WebSocket failed, using HTTP polling');
    startPollingFallback();
  });

  return socket;
};
```

**High Database Load**
```typescript
// Implement caching for permissions checks
const permissionCache = new Map();

const checkPermissionWithCache = async (userId: string, gateId: string) => {
  const cacheKey = `${userId}-${gateId}`;

  if (permissionCache.has(cacheKey)) {
    return permissionCache.get(cacheKey);
  }

  const permission = await checkAccessPermission(userId, gateId);
  permissionCache.set(cacheKey, permission);

  // Clear cache after 5 minutes
  setTimeout(() => permissionCache.delete(cacheKey), 300000);

  return permission;
};
```

### Debug Mode
Enable debug logging to troubleshoot issues:
```bash
# Set environment variable
DEBUG=gate-monitoring:* npm run dev

# Check WebSocket connection
# Check database queries
# Verify RLS policies
```

## Next Steps

1. **Phase 1**: Implement core real-time monitoring and basic access control
2. **Phase 2**: Add visitor management and security alerts
3. **Phase 3**: Implement curfew enforcement and advanced features
4. **Phase 4**: Add analytics and reporting capabilities
5. **Phase 5**: Performance optimization and monitoring

For detailed implementation guidance, refer to the [data model](./data-model.md) and [API contracts](./contracts/gate-monitoring-api.yaml).