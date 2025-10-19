# Sentinel Mobile App - User Acceptance Testing (UAT) Plan

## Overview
This document outlines the User Acceptance Testing (UAT) plan for the Sentinel mobile gate guard access control application, focusing on Phase 3: User Story 1 - RFID Resident Entry functionality.

## Testing Objectives
1. **Verify Core RFID Functionality**: Ensure RFID scanning works within the 5-second performance requirement
2. **Validate User Experience**: Confirm the interface is intuitive for gate guards
3. **Test Error Handling**: Verify proper handling of NFC errors and network failures
4. **Confirm Offline Capability**: Test offline-first architecture when network is unavailable
5. **Validate Security**: Ensure proper authentication and data protection

## Test Environment Setup

### Hardware Requirements
- **Primary Device**: Android device with NFC capabilities (recommended: Android 10+)
- **RFID Stickers**: ISO/IEC 14443 Type A/B stickers compatible with NFC
- **Network Conditions**: Test with both stable and unstable network connections
- **Physical Environment**: Realistic gate guard operating conditions

### Software Setup
- **App Version**: Sentinel v1.0.0 (build #)
- **Backend**: Supabase test environment with sample data
- **Test Data**: Pre-configured resident RFID stickers and household data
- **Permissions**: NFC, Camera (optional), Storage permissions granted

## Test Scenarios

### T001: RFID Scanning Performance Test
**Objective**: Verify RFID scanning meets <5 second requirement

**Test Steps**:
1. Launch Sentinel app
2. Navigate to RFID scanning screen
3. Tap "Start Scanning" button
4. Present RFID sticker within 2 seconds
5. Measure time from scan start to success/deny result
6. Repeat 10 times with different stickers

**Expected Results**:
- Scan completion time < 5 seconds for all attempts
- Success rate > 95% in optimal conditions
- Clear visual feedback during scanning process

**Pass Criteria**: ✓ All scans complete within 5 seconds

---

### T002: Resident Entry Verification Flow
**Objective**: Test complete resident entry verification workflow

**Test Steps**:
1. Scan valid resident RFID sticker
2. Verify resident information display
3. Confirm entry decision screen shows correct options
4. Test "Grant Entry" flow
5. Test "Deny Entry" flow with reason selection
6. Verify entry log creation

**Expected Results**:
- Resident information displays correctly
- Entry/deny options are clear and functional
- Entry logs are created with accurate timestamps
- Visual confirmation of action taken

**Pass Criteria**: ✓ Complete workflow functions without errors

---

### T003: Error Handling Validation
**Objective**: Test application behavior with various error conditions

**Test Steps**:
1. **NFC Error**: Test with device NFC disabled
2. **Network Error**: Test with airplane mode enabled
3. **Invalid RFID**: Test with unrecognized/invalid RFID sticker
4. **Timeout Error**: Test scan timeout behavior
5. **Permission Error**: Test with revoked NFC permissions

**Expected Results**:
- Clear, user-friendly error messages
- Suggested recovery actions provided
- Manual verification option available when appropriate
- App remains stable and responsive

**Pass Criteria**: ✓ All errors handled gracefully with user guidance

---

### T004: Offline Mode Testing
**Objective**: Verify offline-first architecture functionality

**Test Steps**:
1. Disable network connectivity
2. Scan valid RFID sticker
3. Verify resident data from local cache
4. Process entry decision
5. Re-enable network connectivity
6. Verify data synchronization

**Expected Results**:
- Core functionality works offline
- Data is cached appropriately
- Sync occurs automatically when network restored
- No data loss during offline operations

**Pass Criteria**: ✓ Offline mode maintains core functionality

---

### T005: Manual Verification Fallback
**Objective**: Test manual verification when RFID scanning fails

**Test Steps**:
1. Initiate manual verification from RFID screen
2. Test search by resident name
3. Test search by phone number
4. Test search by address
5. Test search by RFID code (manual entry)
6. Verify manual entry log creation

**Expected Results**:
- Search functionality works across all fields
- Results display relevant resident information
- Manual entry logs are properly created
- Process is efficient for gate guard operations

**Pass Criteria**: ✓ Manual verification provides adequate fallback

---

### T006: User Interface Experience
**Objective**: Validate UI/UX for gate guard workflow

**Test Steps**:
1. Test one-handed operation
2. Verify readability in outdoor lighting
3. Test with various screen sizes
4. Verify accessibility features (large text, contrast)
5. Test navigation flow between screens
6. Verify button placement and sizing

**Expected Results**:
- Interface is intuitive and easy to use
- Text is readable in various lighting conditions
- Navigation is logical and efficient
- Buttons are appropriately sized for touch interaction
- Consistent visual design throughout app

**Pass Criteria**: ✓ UI meets usability standards for gate guard operations

---

## Performance Metrics

### Key Performance Indicators (KPIs)
| Metric | Target | Measurement Method |
|---------|--------|-------------------|
| RFID Scan Time | < 5 seconds | Stopwatch measurement |
| App Startup Time | < 3 seconds | Device logs |
| Screen Transition Time | < 1 second | Performance monitoring |
| Memory Usage | < 200MB peak | Device profiler |
| Battery Impact | < 5%/hour | Battery monitoring |
| Error Rate | < 2% of operations | Error tracking |

### Load Testing
- **Concurrent Users**: Test with 5+ guards using the system simultaneously
- **Volume**: Process 100+ entries in a single session
- **Duration**: 8-hour continuous operation test

## Test Data Requirements

### Sample Resident Data
- 20+ resident households with valid RFID stickers
- Mix of active, inactive, and guest RFID codes
- Various resident types (owners, tenants, family members)
- Recent entry history for testing

### Error Simulation Data
- Invalid/expired RFID stickers
- Stickers with reported issues
- Edge cases (very long names, special characters)
- Network failure scenarios

## Test Execution Plan

### Phase 1: Core Functionality (Days 1-2)
- RFID scanning performance tests
- Basic entry/exit workflows
- Error handling validation

### Phase 2: Edge Cases (Day 3)
- Offline mode testing
- Network failure scenarios
- Manual verification flows

### Phase 3: User Experience (Day 4)
- UI/UX validation
- Accessibility testing
- Real-world scenario testing

### Phase 4: Load & Stress Testing (Day 5)
- High-volume entry processing
- Multiple concurrent users
- Extended operation testing

## Success Criteria

### Must-Have Requirements
- ✓ RFID scanning < 5 seconds (95% of attempts)
- ✓ Successful resident verification > 98%
- ✓ Error handling with user-friendly messages
- ✓ Offline mode maintains core functionality
- ✓ Manual verification provides adequate fallback

### Should-Have Requirements
- ✓ Intuitive UI for gate guard operations
- ✓ Comprehensive audit trail functionality
- ✓ Real-time synchronization when online
- ✓ Proper security and data protection

### Could-Have Requirements
- ✓ Advanced search capabilities
- ✓ Performance analytics and reporting
- ✓ Integration with building management systems

## Test Reporting

### Daily Test Reports
- Tests executed vs. planned
- Pass/fail rates by scenario
- Issues identified and severity
- Performance metrics collected

### Final UAT Report
- Overall assessment of readiness
- Critical issues requiring resolution
- Performance against KPIs
- User feedback summary
- Go/No-Go recommendation

## Issue Classification

### Critical (Blocker)
- Security vulnerabilities
- Data corruption or loss
- Complete failure of core functionality
- Performance significantly below requirements

### High
- Frequent crashes or errors
- Major usability issues
- Significant performance degradation
- Missing critical functionality

### Medium
- Minor usability issues
- Inconsistent behavior
- Performance slightly below targets
- Workarounds available

### Low
- Cosmetic UI issues
- Minor documentation gaps
- Edge case scenarios
- Enhancement opportunities

## Sign-off Criteria

### Business Stakeholder Approval
- Functionality meets business requirements
- User experience is acceptable
- Performance meets operational needs
- Security requirements are satisfied

### Technical Approval
- Code quality and architecture standards met
- Performance benchmarks achieved
- Security testing completed
- Documentation is adequate

### User Acceptance
- Target users can complete required tasks
- Training requirements are minimal
- Workflow integration is successful
- Overall satisfaction is high

---

**Prepared by**: Development Team
**Date**: October 20, 2025
**Version**: 1.0
**Next Review**: Upon completion of UAT execution