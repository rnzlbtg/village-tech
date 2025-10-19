# Guest Management User Acceptance Testing (UAT)

## Overview
This document provides comprehensive testing procedures for the Guest Management functionality of the Sentinel mobile app. Gate guards will use this checklist to validate that all guest management features work correctly in real-world scenarios.

## Testing Requirements

### Prerequisites
- Sentinel mobile app installed on test device
- Guard account with proper permissions
- Test data available (households, pre-registered guests)
- Network connectivity (test both online and offline scenarios)
- NFC-enabled device (for fallback testing)

### Test Environment Setup
- [ ] Test device charged and functioning
- [ ] App logged in with guard credentials
- [ ] Test households created in system
- [ ] Pre-registered guests in system
- [ ] Network connectivity stable
- [ ] Camera permissions enabled
- [ ] Phone/SMS permissions enabled

## UAT Test Scenarios

### 1. Guest Registration Workflow

#### Test Case 1.1: Pre-registered Guest Check-in
**Objective**: Validate checking in guests who were pre-registered

**Test Steps:**
1. [ ] Navigate to Guest List screen
2. [ ] Verify "Today's Guests" section displays pre-registered guests
3. [ ] Tap on a pre-registered guest with "Expected" status
4. [ ] Verify guest details screen shows correct information:
   - Guest name matches registration
   - Phone number is correct
   - Purpose of visit is displayed
   - Scheduled date and time are correct
   - Host household information is accurate
5. [ ] Tap "Check In" button
6. [ ] Verify confirmation dialog appears
7. [ ] Confirm check-in
8. [ ] Verify guest status changes to "Checked In"
9. [ ] Verify check-in timestamp is recorded
10. [ ] Verify guest appears in "Checked In" section

**Expected Results:**
- All guest information displays correctly
- Check-in process completes smoothly
- Status updates immediately
- Timestamp is accurate
- Guest moves to appropriate list section

**Pass/Fail Criteria:**
- [ ] All verification steps pass
- [ ] No errors or crashes occur
- [ ] Process completes within 3 seconds

#### Test Case 1.2: Walk-in Guest Registration
**Objective**: Validate registering guests who arrive without pre-registration

**Test Steps:**
1. [ ] Navigate to Guest Registration screen
2. [ ] Fill in guest information:
   - Enter guest full name (test: "John Visitor")
   - Enter phone number (test: "09123456789")
   - Select purpose of visit (test: "Personal Visit")
   - Select date as today
   - Set arrival time within 15 minutes
3. [ ] Search for host household:
   - Enter household name/number (test: "Household A-101")
   - Verify search results appear
   - Select correct household
4. [ ] Add optional vehicle information:
   - Enter plate number (test: "ABC 123")
   - Select vehicle type
5. [ ] Add delivery notes if applicable
6. [ ] Review all entered information
7. [ ] Tap "Register Guest" button
8. [ ] Verify registration success message
9. [ ] Verify guest appears in guest list with "Expected" status
10. [ ] Navigate to guest details and verify all information

**Expected Results:**
- Form validation works correctly
- Household search returns relevant results
- Registration completes without errors
- Guest appears in appropriate lists
- All information is saved accurately

**Pass/Fail Criteria:**
- [ ] Form validation prevents invalid submissions
- [ ] Registration completes within 5 seconds
- [ ] Guest appears in guest list immediately
- [ ] All information is preserved accurately

#### Test Case 1.3: Form Validation Testing
**Objective**: Ensure form properly validates input and prevents invalid submissions

**Test Steps:**
1. [ ] Navigate to Guest Registration screen
2. [ ] Test empty form submission:
   - Leave all fields empty
   - Tap "Register Guest"
   - Verify validation errors appear
3. [ ] Test invalid phone number:
   - Enter "123" as phone number
   - Verify phone validation error
4. [ ] Test past date selection:
   - Select yesterday's date
   - Verify date validation error
5. [ ] Test missing household selection:
   - Fill all fields except household
   - Verify household required error
6. [ ] Test extremely long name:
   - Enter 100+ character name
   - Verify length validation

**Expected Results:**
- All validation errors are clear and helpful
- Invalid submissions are prevented
- Error messages guide correction
- Form highlights problematic fields

**Pass/Fail Criteria:**
- [ ] All invalid submissions blocked
- [ ] Error messages are user-friendly
- [ ] Validation provides immediate feedback
- [ ] No crashes occur during validation

### 2. Guest Search and Retrieval

#### Test Case 2.1: Name Search
**Objective**: Test searching guests by name

**Test Steps:**
1. [ ] Navigate to Guest List screen
2. [ ] Tap search bar
3. [ ] Enter partial guest name (test: "John")
4. [ ] Verify search results show matching guests
5. [ ] Enter full guest name (test: "John Visitor")
6. [ ] Verify precise match appears first
7. [ ] Test case-insensitive search (test: "john visitor")
8. [ ] Verify same results appear
9. [ ] Test non-existent name (test: "XYZ Guest")
10. [ ] Verify "No results found" message

**Expected Results:**
- Search works with partial names
- Full names return precise matches
- Search is case-insensitive
- Non-existent searches show appropriate message
- Search results update in real-time

**Pass/Fail Criteria:**
- [ ] Search responds within 2 seconds
- [ ] Results are accurate and relevant
- [ ] No crashes during search operations
- [ ] Real-time search works smoothly

#### Test Case 2.2: Phone Search
**Objective**: Test searching guests by phone number

**Test Steps:**
1. [ ] Navigate to Guest List screen
2. [ ] Tap search bar
3. [ ] Enter complete phone number (test: "09123456789")
4. [ ] Verify exact match appears
5. [ ] Enter partial phone number (test: "0912")
6. [ ] Verify matching results appear
7. [ ] Test with different formats (test: "+639123456789")
8. [ ] Verify format handling works correctly
9. [ ] Test non-existent number
10. [ ] Verify appropriate "no results" handling

**Expected Results:**
- Complete numbers return exact matches
- Partial numbers return relevant matches
- Different number formats work correctly
- Non-existent numbers handled gracefully

**Pass/Fail Criteria:**
- [ ] Phone search works quickly
- [ ] Format handling is robust
- [ ] Results are accurate
- [ ] No crashes with invalid formats

#### Test Case 2.3: Household Search
**Objective**: Test searching guests by household

**Test Steps:**
1. [ ] Navigate to Guest List screen
2. [ ] Apply household filter if available
3. [ ] Search by household name (test: "Household A-101")
4. [ ] Verify all guests for that household appear
5. [ ] Test partial household name (test: "A-101")
6. [ ] Verify matching results
7. [ ] Test with household number only
8. [ ] Verify correct filtering

**Expected Results:**
- Household search returns all associated guests
- Partial matching works correctly
- Filter combinations work properly

**Pass/Fail Criteria:**
- [ ] Household filtering is accurate
- [ ] Search performance is acceptable
- [ ] All guests for household appear

### 3. Guest Status Management

#### Test Case 3.1: Check-in Workflow
**Objective**: Test complete guest check-in process

**Test Steps:**
1. [ ] Locate a guest with "Expected" status
2. [ ] Tap on guest to view details
3. [ ] Verify all guest information is correct
4. [ ] Tap "Check In" button
5. [ ] Verify check-in confirmation dialog
6. [ ] Confirm the check-in
7. [ ] Verify success message appears
8. [ ] Verify status changes to "Checked In"
9. [ ] Verify check-in timestamp is recorded
10. [ ] Verify guest moves to "Checked In" section

**Expected Results:**
- Check-in confirmation prevents accidental check-ins
- Status updates immediately
- Timestamp is accurate to the second
- Guest appears in correct section

**Pass/Fail Criteria:**
- [ ] Check-in completes within 3 seconds
- [ ] Status update is immediate
- [ ] Timestamp accuracy is within 1 second
- [ ] No errors during process

#### Test Case 3.2: Check-out Workflow
**Objective**: Test guest check-out process

**Test Steps:**
1. [ ] Locate a guest with "Checked In" status
2. [ ] Tap on guest to view details
3. [ ] Verify check-in information is displayed
4. [ ] Tap "Check Out" button
5. [ ] Verify check-out confirmation dialog
6. [ ] Confirm the check-out
7. [ ] Verify success message appears
8. [ ] Verify status changes to "Completed"
9. [ ] Verify check-out timestamp is recorded
10. [ ] Verify total visit duration is calculated

**Expected Results:**
- Check-out is confirmed before execution
- Status changes to "Completed"
- Check-out timestamp is accurate
- Visit duration is calculated correctly

**Pass/Fail Criteria:**
- [ ] Check-out completes within 3 seconds
- [ ] Duration calculation is accurate
- [ ] Guest moves to completed section
- [ ] All timestamps recorded correctly

#### Test Case 3.3: Auto Check-out Testing
**Objective**: Test automatic check-out for overdue guests

**Test Steps:**
1. [ ] Identify a guest who has overstayed scheduled time
2. [ ] Verify guest shows "Overdue" status
3. [ ] Tap on guest details
4. [ ] Verify overdue warning is displayed
5. [ ] Test manual check-out for overdue guest
6. [ ] Verify system handles overdue status correctly

**Expected Results:**
- Overdue guests are clearly marked
- Warnings are displayed for overdue guests
- Manual check-out handles overdue status properly

**Pass/Fail Criteria:**
- [ ] Overdue status updates automatically
- [ ] Warnings are clear and visible
- [ ] Manual check-out works for overdue guests

### 4. Unregistered Guest Workflow

#### Test Case 4.1: Complete Unregistered Guest Process
**Objective**: Test full workflow for guests arriving without registration

**Test Steps:**
1. [ ] Navigate to Unregistered Guest screen
2. [ ] Ask guest for host household information
3. [ ] Search for household by name/number
4. [ ] Verify search results show correct households
5. [ ] Select the host household
6. [ ] Verify household contact information appears
7. [ ] Tap "Call Household" button
8. [ ] Verify call interface opens
9. [ ] After call confirmation, tap "Send SMS" button
10. [ ] Verify SMS interface opens with pre-filled message
11. [ ] After receiving approval, proceed with registration
12. [ ] Fill in guest details (name, phone, purpose)
13. [ ] Complete registration process
14. [ ] Verify immediate check-in option appears
15. [ ] Check in the guest
16. [ ] Verify guest appears in checked-in list

**Expected Results:**
- Household search works efficiently
- Contact integration works seamlessly
- Registration after approval is smooth
- Immediate check-in works correctly

**Pass/Fail Criteria:**
- [ ] Entire process completes within 10 minutes
- [ ] No crashes during any step
- [ ] All integrations work correctly
- [ ] Guest is properly registered and checked in

#### Test Case 4.2: Household Search Accuracy
**Objective**: Test household search functionality

**Test Steps:**
1. [ ] Navigate to Unregistered Guest screen
2. [ ] Test household search by exact name
3. [ ] Test household search by partial name
4. [ ] Test household search by unit number
5. [ ] Test household search by resident name
6. [ ] Verify search accuracy in all cases
7. [ ] Test with non-existent household
8. [ ] Verify "no results" handling

**Expected Results:**
- Search works with various input types
- Results are accurate and relevant
- Non-existent searches handled gracefully

**Pass/Fail Criteria:**
- [ ] Search returns relevant results quickly
- [ ] Multiple search types work correctly
- [ ] No crashes with invalid inputs

### 5. Household Contact Integration

#### Test Case 5.1: Phone Call Integration
**Objective**: Test calling household heads for verification

**Test Steps:**
1. [ ] Select any guest or unregistered guest workflow
2. [ ] Locate household contact information
3. [ ] Tap "Call Household" button
4. [ ] Verify phone dialer opens with correct number
5. [ ] Verify call is logged in contact history
6. [ ] Complete test call (can be simulated)
7. [ ] Verify call result is recorded

**Expected Results:**
- Phone dialer opens with correct number
- Call attempts are logged
- Call results are recorded accurately

**Pass/Fail Criteria:**
- [ ] Phone integration works smoothly
- [ ] Call logging is automatic
- [ ] No errors during call initiation

#### Test Case 5.2: SMS Integration
**Objective**: Test SMS messaging to households

**Test Steps:**
1. [ ] Navigate to guest verification or household contact
2. [ ] Tap "Send SMS" button
3. [ ] Verify SMS app opens with pre-filled message
4. [ ] Verify message includes relevant guest information
5. [ ] Send test SMS
6. [ ] Verify SMS is logged in contact history
7. [ ] Verify delivery status tracking

**Expected Results:**
- SMS app opens with appropriate message
- Message includes necessary guest details
- SMS attempts are logged successfully

**Pass/Fail Criteria:**
- [ ] SMS integration works correctly
- [ ] Message templates are appropriate
- [ ] Logging is automatic and accurate

#### Test Case 5.3: Contact History Tracking
**Objective**: Test that all household contacts are properly tracked

**Test Steps:**
1. [ ] Make multiple test contacts (calls/SMS) to different households
2. [ ] Navigate to contact history section
3. [ ] Verify all contacts appear in chronological order
4. [ ] Check that contact details are accurate:
   - Contact type (call/SMS)
   - Contact person
   - Timestamp
   - Associated guest name
   - Contact result
5. [ ] Verify contact statistics are updated
6. [ ] Test filtering contact history

**Expected Results:**
- All contacts are logged accurately
- History is properly organized
- Statistics reflect contact activity
- Filtering works correctly

**Pass/Fail Criteria:**
- [ ] Contact logging is automatic and complete
- [ ] History organization is logical
- [ ] Statistics calculations are accurate
- [ ] Filtering provides useful views

### 6. Business Rules Validation

#### Test Case 6.1: Maximum Guests Validation
**Objective**: Test system enforcement of guest limits

**Test Steps:**
1. [ ] Identify household with existing guests
2. [ ] Attempt to register additional guests beyond limit
3. [ ] Verify system warning about guest limit
4. [ ] Test if registration is blocked or allowed with warning
5. [ ] Verify guest count tracking is accurate

**Expected Results:**
- System warns about approaching limits
- Excessive registrations are handled appropriately
- Guest counts are accurate

**Pass/Fail Criteria:**
- [ ] Business rules are enforced correctly
- [ ] Warnings are clear and actionable
- [ ] Guest tracking is accurate

#### Test Case 6.2: Time Duration Validation
**Objective**: Test visit duration limits and enforcement

**Test Steps:**
1. [ ] Register guest with very long visit duration
2. [ ] Verify system flags unusually long durations
3. [ ] Test check-out for guests who overstayed
4. [ ] Verify overdue status handling
5. [ ] Test extension of visit time

**Expected Results:**
- Long durations are flagged appropriately
- Overdue handling works correctly
- Time extensions are handled properly

**Pass/Fail Criteria:**
- [ ] Time rules are enforced consistently
- [ ] Overdue handling is clear
- [ ] Extensions work when appropriate

### 7. Performance Testing

#### Test Case 7.1: Search Performance
**Objective**: Ensure search operations meet performance targets

**Test Steps:**
1. [ ] Test guest name search with large guest list
2. [ ] Measure search response time
3. [ ] Test phone search performance
4. [ ] Test household search performance
5. [ ] Test simultaneous filtering criteria

**Expected Results:**
- All search operations complete within 2 seconds
- Large guest lists don't significantly impact performance
- Multiple filters work efficiently

**Pass/Fail Criteria:**
- [ ] Search response time < 2 seconds
- [ ] No performance degradation with large data
- [ ] Smooth filtering experience

#### Test Case 7.2: Registration Performance
**Objective**: Test guest registration performance

**Test Steps:**
1. [ ] Measure time from form open to submission success
2. [ ] Test with various form complexities
3. [ ] Test with slow network connection
4. [ ] Test registration in offline mode

**Expected Results:**
- Registration completes within 5 seconds online
- Offline registration queues for sync
- Performance remains acceptable

**Pass/Fail Criteria:**
- [ ] Registration < 5 seconds online
- [ ] Offline mode works correctly
- [ ] No hangs or crashes

### 8. Error Handling and Edge Cases

#### Test Case 8.1: Network Connectivity Issues
**Objective**: Test app behavior during network problems

**Test Steps:**
1. [ ] Disable network connection
2. [ ] Attempt guest registration
3. [ ] Verify offline mode indication
4. [ ] Verify operation queues for later sync
5. [ ] Re-enable network connection
6. [ ] Verify queued operations sync automatically

**Expected Results:**
- Clear indication of offline status
- Operations queue properly
- Automatic sync when connection restored

**Pass/Fail Criteria:**
- [ ] Offline mode is clearly indicated
- [ ] No data loss during offline operations
- [ ] Automatic sync works reliably

#### Test Case 8.2: Concurrent Operations
**Objective**: Test handling multiple simultaneous operations

**Test Steps:**
1. [ ] Start guest registration for Guest A
2. [ ] Quickly switch to check-in Guest B
3. [ ] Attempt search while registration in progress
4. [ ] Verify all operations complete correctly
5. [ ] Check for data consistency

**Expected Results:**
- Multiple operations work without interference
- Data consistency is maintained
- No crashes or hangs occur

**Pass/Fail Criteria:**
- [ ] Concurrent operations handled correctly
- [ ] No data corruption or loss
- [ ] Responsive UI during operations

## UAT Sign-off Criteria

### Must Pass (Critical)
- [ ] All guest registration workflows complete successfully
- [ ] Guest search and retrieval works accurately
- [ ] Check-in/check-out processes function correctly
- [ ] Unregistered guest workflow is complete
- [ ] Household contact integration works
- [ ] Business rules are enforced properly
- [ ] Performance targets are met
- [ ] No crashes or data loss occurs

### Should Pass (Important)
- [ ] Form validation is comprehensive and user-friendly
- [ ] Error messages are clear and helpful
- [ ] Offline mode functions correctly
- [ ] Contact history tracking is accurate
- [ ] UI responsiveness is acceptable

### Could Pass (Nice to Have)
- [ ] Advanced search filters work well
- [ ] Performance is excellent in all scenarios
- [ ] Edge cases are handled gracefully

## Test Results Summary

### Overall Assessment
- Total Test Cases: ____
- Passed: ____
- Failed: ____
- Blocked: ____

### Critical Issues Found
1. [ ] Issue description
2. [ ] Issue description
3. [ ] Issue description

### Minor Issues Found
1. [ ] Issue description
2. [ ] Issue description

### Recommendations
1. [ ] Recommendation for improvement
2. [ ] Recommendation for improvement

## Sign-off

### Tester Information
- Tester Name: _________________________
- Test Date: ___________________________
- Device Used: _________________________
- App Version: _________________________

### Approval
- Gate Guard Supervisor: _________________
- Date: ________________________________
- Comments: ____________________________

### Final Status
- [ ] **Approved** - Guest management is ready for production
- [ ] **Approved with Minor Issues** - Ready for production with documented workarounds
- [ ] **Not Approved** - Critical issues must be resolved before production deployment

---

## Appendix: Test Data Setup

### Required Test Data
- At least 5 households with different names and numbers
- 10+ pre-registered guests for today
- Mix of guest types (personal, delivery, service)
- Various phone number formats
- Different scheduled times throughout the day
- Test scenarios for overdue guests

### Test Accounts
- Guard account with full permissions
- Test household contacts with real phone numbers
- Various guest profiles for testing

This UAT documentation ensures comprehensive validation of all guest management features and provides clear criteria for production readiness.