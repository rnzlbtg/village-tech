# Sentinel App - UAT Test Checklist

## Test Information
- **Tester Name**: _________________________
- **Date**: _________________________
- **Device Model**: _________________________
- **App Version**: _________________________
- **Test Location**: _________________________

## Instructions
For each test scenario:
1. Follow the test steps exactly as written
2. Record actual results and observations
3. Mark as PASS, FAIL, or PARTIAL
4. Note any issues or suggestions in comments
5. Take screenshots/photos of issues when possible

---

## T001: RFID Scanning Performance Test

### Test Steps:
1. [ ] Open Sentinel app
2. [ ] Navigate to RFID scanning screen
3. [ ] Tap "Start Scanning"
4. [ ] Present RFID sticker to device
5. [ ] Record scan time: ______ seconds
6. [ ] Repeat for different stickers (10 total)

### Results:
| Attempt | Scan Time (sec) | Result | Notes |
|---------|----------------|--------|-------|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |
| 6 | | | |
| 7 | | | |
| 8 | | | |
| 9 | | | |
| 10 | | | |

**Average Scan Time**: ______ seconds
**Success Rate**: ______ %
**Overall Result**: [ ] PASS [ ] FAIL [ ] PARTIAL

**Comments/Observations**:
______________________________________________________________
______________________________________________________________

---

## T002: Resident Entry Verification Flow

### Test Steps:
1. [ ] Scan valid resident RFID sticker
2. [ ] Verify resident information displays correctly
3. [ ] Check entry decision screen options
4. [ ] Select "Grant Entry"
5. [ ] Confirm entry is logged
6. [ ] Scan another sticker
7. [ ] Select "Deny Entry"
8. [ ] Select denial reason
9. [ ] Confirm denial is logged

### Expected Results:
- [ ] Resident name and photo display
- [ ] Address and unit information visible
- [ ] Entry/Deny buttons are clear
- [ ] Entry log created with timestamp
- [ ] Visual confirmation of action

**Actual Results**:
______________________________________________________________
______________________________________________________________

**Overall Result**: [ ] PASS [ ] FAIL [ ] PARTIAL

**Issues Found**:
______________________________________________________________
______________________________________________________________

---

## T003: Error Handling Validation

### 3A: NFC Disabled Test
1. [ ] Disable device NFC in settings
2. [ ] Open RFID scanning screen
3. [ ] Tap "Start Scanning"
4. [ ] Observe error message

**Error Message Shown**: ______________________________________
**Helpfulness**: [ ] Very Helpful [ ] Somewhat Helpful [ ] Not Helpful
**Overall Result**: [ ] PASS [ ] FAIL [ ] PARTIAL

### 3B: Network Error Test
1. [ ] Enable airplane mode (disable network)
2. [ ] Scan valid RFID sticker
3. [ ] Observe app behavior

**Behavior**: _________________________________________________
**Offline Functionality**: [ ] Works [ ] Partially Works [ ] Doesn't Work
**Overall Result**: [ ] PASS [ ] FAIL [ ] PARTIAL

### 3C: Invalid RFID Test
1. [ ] Scan invalid/unknown RFID sticker
2. [ ] Observe error handling

**Error Message**: ____________________________________________
**Options Available**: _________________________________________
**Overall Result**: [ ] PASS [ ] FAIL [ ] PARTIAL

---

## T004: Offline Mode Testing

### Test Steps:
1. [ ] Disable network connectivity
2. [ ] Scan valid resident RFID sticker
3. [ ] Process entry decision
4. [ ] Verify entry is logged locally
5. [ ] Re-enable network connectivity
6. [ ] Check if data syncs automatically

### Results:
**Offline Scanning**: [ ] Works [ ] Doesn't Work [ ] Partially
**Local Data Available**: [ ] Yes [ ] No [ ] Partial
**Entry Creation**: [ ] Success [ ] Failed
**Sync on Reconnect**: [ ] Automatic [ ] Manual [ ] Failed

**Overall Result**: [ ] PASS [ ] FAIL [ ] PARTIAL

**Comments**:
______________________________________________________________
______________________________________________________________

---

## T005: Manual Verification Fallback

### Test Steps:
1. [ ] From RFID screen, tap "Manual Verification"
2. [ ] Search by resident name: _________________
3. [ ] Search by phone number: _________________
4. [ ] Search by address: ____________________
5. [ ] Manual RFID code entry: _______________
6. [ ] Process manual entry
7. [ ] Verify entry log creation

### Results:
**Search by Name**: [ ] Success [ ] Failed [ ] Partial Results
**Search by Phone**: [ ] Success [ ] Failed [ ] Partial Results
**Search by Address**: [ ] Success [ ] Failed [ ] Partial Results
**Manual RFID Entry**: [ ] Success [ ] Failed
**Entry Log Creation**: [ ] Success [ ] Failed

**Overall Result**: [ ] PASS [ ] FAIL [ ] PARTIAL

**Search Speed**: [ ] Fast < 3 sec [ ] Medium 3-5 sec [ ] Slow > 5 sec

**Comments**:
______________________________________________________________
______________________________________________________________

---

## T006: User Interface Experience

### Usability Questions:
1. [ ] Is the app easy to navigate? (1-5 scale: 1=Poor, 5=Excellent)
   Rating: ______

2. [ ] Are buttons easy to tap with one hand? [ ] Yes [ ] No [ ] Sometimes

3. [ ] Is text readable in outdoor lighting? [ ] Yes [ ] No [ ] Sometimes

4. [ ] Are error messages clear and helpful? [ ] Yes [ ] No [ ] Sometimes

5. [ ] Does the app respond quickly to taps? [ ] Yes [ ] No [ ] Sometimes

6. [ ] Is the workflow logical for gate guard duties? [ ] Yes [ ] No [ ] Partially

### Best Feature:
______________________________________________________________

### Most Confusing Feature:
______________________________________________________________

### Suggested Improvements:
______________________________________________________________
______________________________________________________________

**Overall UX Rating**: [ ] Excellent [ ] Good [ ] Fair [ ] Poor

---

## Performance Observations

### App Performance:
1. **App Startup Time**: ______ seconds
2. **Screen Transition Speed**: [ ] Fast [ ] Medium [ ] Slow
3. **Battery Usage**: [ ] Minimal [ ] Moderate [ ] Heavy
4. **Memory Issues**: [ ] None [ ] Occasional lag [ ] Frequent crashes

### Network Performance:
1. **Sync Speed**: [ ] Fast [ ] Medium [ ] Slow
2. **Offline Reliability**: [ ] Excellent [ ] Good [ ] Poor
3. **Data Accuracy**: [ ] Always correct [ ] Sometimes incorrect [ ] Often incorrect

---

## Critical Issues Found

### Issue #1:
**Description**: ________________________________________________
**Severity**: [ ] Critical [ ] High [ ] Medium [ ] Low
**Steps to Reproduce**: _________________________________________
**Expected vs Actual**: ________________________________________

### Issue #2:
**Description**: ________________________________________________
**Severity**: [ ] Critical [ ] High [ ] Medium [ ] Low
**Steps to Reproduce**: _________________________________________
**Expected vs Actual**: ________________________________________

### Issue #3:
**Description**: ________________________________________________
**Severity**: [ ] Critical [ ] High [ ] Medium [ ] Low
**Steps to Reproduce**: _________________________________________
**Expected vs Actual**: ________________________________________

---

## Overall Assessment

### Readiness for Production:
[ ] **READY** - App meets all requirements and is ready for deployment
[ ] **READY WITH MINOR ISSUES** - App is functional but has minor issues to address
[ ] **NEEDS WORK** - App has significant issues that must be resolved before deployment
[ ] **NOT READY** - App has critical issues preventing deployment

### Key Strengths:
1. ____________________________________________________________
2. ____________________________________________________________
3. ____________________________________________________________

### Primary Concerns:
1. ____________________________________________________________
2. ____________________________________________________________
3. ____________________________________________________________

### Final Recommendation:
______________________________________________________________
______________________________________________________________

---

## Tester Information

**Tester Signature**: _________________________
**Date Completed**: _________________________
**Total Testing Time**: ______ hours
**Device Information**: _________________________
**Additional Comments**:
______________________________________________________________
______________________________________________________________

---

## Follow-up Required

### Issues Needing Attention:
1. ____________________________________________________________
2. ____________________________________________________________
3. ____________________________________________________________

### Scheduling Follow-up Testing:
[ ] Yes - schedule follow-up testing
[ ] No - testing complete
[ ] Maybe - depends on issue resolution

**Contact Information for Follow-up**:
Name: _________________________
Email: _________________________
Phone: _________________________

---

**Thank you for participating in the User Acceptance Testing process!**

Your feedback is valuable in improving the Sentinel app for all gate guards.