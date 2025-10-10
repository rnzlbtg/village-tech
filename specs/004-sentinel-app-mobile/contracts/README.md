# API Contracts - Sentinel App Mobile

**Version**: 1.0.0
**Date**: 2025-10-10
**Format**: OpenAPI 3.0.3

---

## Overview

This directory contains OpenAPI specifications for all Sentinel App backend APIs. These contracts define the interface between the Flutter mobile app and Supabase Edge Functions.

---

## Contract Files

### 1. [rfid-verification.yaml](./rfid-verification.yaml)
**Purpose**: RFID sticker validation and resident vehicle verification

**Endpoints**:
- `POST /rfid/validate` - Validate RFID sticker and return resident/vehicle info
- `POST /rfid/log-entry` - Log RFID-verified entry event

**Key Features**:
- Real-time sticker status validation (active, expired, revoked, lost)
- Household and vehicle information retrieval
- Automatic entry decision (granted/denied) based on sticker status
- Expiry date tracking and alerts

---

### 2. [guest-management.yaml](./guest-management.yaml)
**Purpose**: Guest entry verification and pre-registration management

**Endpoints**:
- `GET /guests/search-preregistered` - Search pre-registered guest list
- `POST /guests/verify-entry` - Verify guest identity and log entry
- `POST /guests/household-call` - Request household head verification for unregistered guests
- `POST /guests/exit` - Log guest exit and calculate visit duration

**Key Features**:
- Pre-registered guest lookup by name or household
- Multiple verification methods: pre_registered, household_call, manual
- Household contact integration
- Visit duration tracking

---

### 3. [delivery-tracking.yaml](./delivery-tracking.yaml) *(To be created)*
**Purpose**: Delivery entry logging and timer tracking

**Planned Endpoints**:
- `POST /deliveries/log-entry` - Log delivery arrival
- `GET /deliveries/verify-address` - Verify recipient address exists
- `POST /deliveries/log-exit` - Log delivery exit
- `GET /deliveries/active` - List active deliveries with timers

---

### 4. [construction-permits.yaml](./construction-permits.yaml) *(To be created)*
**Purpose**: Construction permit verification and worker tracking

**Planned Endpoints**:
- `GET /permits/validate` - Validate permit by reference number
- `POST /permits/log-worker-entry` - Log construction worker entry
- `POST /permits/log-worker-exit` - Log construction worker exit
- `GET /permits/workers-onsite` - List workers currently on-site

---

### 5. [incident-reporting.yaml](./incident-reporting.yaml) *(To be created)*
**Purpose**: Security incident and rule violation reporting

**Planned Endpoints**:
- `POST /incidents/report` - Create incident report
- `POST /incidents/upload-photo` - Upload incident photo to Supabase Storage
- `GET /incidents/list` - List incidents for guard
- `PATCH /incidents/{id}/resolve` - Mark incident as resolved

---

### 6. [village-info.yaml](./village-info.yaml) *(To be created)*
**Purpose**: Village rules and announcements

**Planned Endpoints**:
- `GET /rules/list` - Get active village rules
- `GET /announcements/list` - Get active announcements
- `POST /announcements/mark-read` - Mark announcement as read

---

## Authentication

All API endpoints require **Supabase JWT Bearer Token** authentication.

**Header Format**:
```
Authorization: Bearer <supabase_jwt_token>
```

**Token Claims**:
- `user_id`: Guard's user ID from Supabase Auth
- `tenant_id`: Community/tenant ID for RLS enforcement
- `role`: User role (e.g., 'guard', 'admin')

---

## Error Handling

### Standard Error Response Format

```json
{
  "error": "Human-readable error message",
  "code": "ERROR_CODE",
  "details": {
    "field": "Additional context if applicable"
  }
}
```

### HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Successful GET/PATCH/DELETE |
| 201 | Created | Successful POST (resource created) |
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Missing/invalid authentication |
| 403 | Forbidden | Valid auth but insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Duplicate resource or state conflict |
| 422 | Unprocessable Entity | Validation error |
| 500 | Internal Server Error | Server-side error |

---

## Offline Support Considerations

### Optimistic Responses
Mobile app should optimistically update UI before receiving server response for better UX.

### Sync Queue Integration
Failed requests due to network issues should be queued in local `sync_queue` table:

```dart
// Pseudocode for offline queueing
try {
  final response = await apiClient.post('/rfid/log-entry', data);
  // Success - update local state
} catch (e) {
  if (e is NetworkException) {
    // Queue for later sync
    await syncQueue.add(
      operation: 'CREATE',
      entityType: 'entry_log',
      payload: data,
    );
  }
}
```

### Retry Strategy
- Use exponential backoff: `2^retryCount * baseDelay` with jitter
- Max retry count: 5 attempts
- After max retries: move to dead letter queue for manual review

---

## Data Validation Rules

### Request Validation
All API endpoints validate:
1. Required fields presence
2. Data type correctness
3. Enum value constraints
4. UUID format for IDs
5. Timestamp format (ISO 8601)
6. String length limits

### Business Logic Validation
Backend enforces:
1. Tenant isolation (RLS policies)
2. Guard authorization (can only create entries for assigned tenant)
3. Sticker expiry validation
4. Permit validity period checks
5. Household existence verification

---

## Rate Limiting

**Current**: No rate limiting (Supabase default)

**Recommended (Future)**:
- 100 requests per minute per guard
- 1000 requests per hour per tenant
- Implement via Supabase Edge Functions middleware

---

## Versioning Strategy

### API Versioning
- **Current**: v1 (embedded in base URL: `/functions/v1`)
- **Future versions**: `/functions/v2`, `/functions/v3`, etc.
- **Breaking changes**: Increment major version, maintain backward compatibility for 6 months

### Contract Versioning
- Contract files versioned in git alongside feature specs
- Breaking changes require new contract version and migration plan
- Mobile app should gracefully handle API version mismatches

---

## Testing

### Contract Validation
- Use OpenAPI validators (e.g., Spectral, openapi-generator)
- Generate mock servers from contracts for mobile app testing
- Run contract tests in CI/CD pipeline

### Example: Using Prism Mock Server
```bash
# Install Prism
npm install -g @stoplight/prism-cli

# Run mock server
prism mock contracts/rfid-verification.yaml
```

### Example: Generating Dart Client
```bash
# Install openapi-generator
npm install -g @openapitools/openapi-generator-cli

# Generate Dart client
openapi-generator-cli generate \
  -i contracts/rfid-verification.yaml \
  -g dart \
  -o lib/generated/api
```

---

## Migration from Current Implementation

### Phase 1: RFID & Guest Management (Priority: P1)
- ✅ `rfid-verification.yaml` - Complete
- ✅ `guest-management.yaml` - Complete
- ⏳ Mobile app implementation pending

### Phase 2: Delivery & Construction (Priority: P2)
- ⏳ `delivery-tracking.yaml` - To be created
- ⏳ `construction-permits.yaml` - To be created
- ⏳ Mobile app implementation pending

### Phase 3: Incidents & Rules (Priority: P3)
- ⏳ `incident-reporting.yaml` - To be created
- ⏳ `village-info.yaml` - To be created
- ⏳ Mobile app implementation pending

---

## Security Considerations

### Input Sanitization
- All user input sanitized on backend before database insertion
- Prevent SQL injection via parameterized queries (Supabase client handles this)
- Validate and escape special characters in text fields

### RFID Security
- Never trust RFID tag data alone - always validate against backend
- Implement challenge-response authentication for high-security scenarios
- Log all RFID validation attempts for audit trail

### Data Privacy
- PII fields encrypted at rest (Supabase handles database encryption)
- Minimize sensitive data in API responses
- Implement field-level redaction for non-authorized users

### Audit Trail
- All entry logs immutable (no DELETE operation)
- Track `created_by` and `updated_by` for all records
- Maintain comprehensive audit logs via database triggers

---

## Support & Maintenance

### Contract Updates
1. Update OpenAPI spec file
2. Validate with OpenAPI validator
3. Update mobile app client (regenerate if using codegen)
4. Update backend Edge Functions
5. Version and tag in git

### Breaking Changes Protocol
1. Document breaking change in CHANGELOG
2. Increment API version
3. Maintain backward compatibility for 6 months minimum
4. Notify mobile app developers via release notes
5. Provide migration guide

---

**Last Updated**: 2025-10-10
**Maintained By**: Village Tech v4 API Team
**Related Docs**: [data-model.md](../data-model.md), [quickstart.md](../quickstart.md)
