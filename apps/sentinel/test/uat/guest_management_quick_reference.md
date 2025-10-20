# Guest Management Quick Reference Guide

## Purpose
This guide provides quick instructions for gate guards using the Sentinel app's Guest Management features during User Acceptance Testing.

## Getting Started

### 1. App Login
- Open Sentinel app
- Enter guard credentials
- Ensure all permissions are granted (Camera, Phone, SMS)

### 2. Daily Setup
- Check network connectivity
- Verify today's guest list
- Review any pending registrations

---

## Guest Registration

### Pre-registered Guests (Today's Guests)
1. **Find Guest:**
   - Open Guest List
   - Look in "Today's Guests" section
   - Use search if needed

2. **Verify Identity:**
   - Check guest name matches ID
   - Verify phone number
   - Confirm purpose of visit

3. **Check-in Process:**
   - Tap on guest → Details screen
   - Tap "Check In" button
   - Confirm the check-in
   - Status changes to "Checked In"

### Walk-in Guests (New Registrations)
1. **Start Registration:**
   - Tap "Register New Guest"
   - Fill in guest information:
     - Full name (required)
     - Phone number (required)
     - Purpose of visit (required)
     - Date and time (defaults to now)
     - Vehicle information (optional)

2. **Find Host Household:**
   - Search by household name or number
   - Select from search results
   - Verify contact information

3. **Complete Registration:**
   - Review all information
   - Tap "Register Guest"
   - Guest appears in "Expected" list
   - Proceed to check-in if approved

---

## Guest Search

### Quick Search Methods
- **By Name:** Type guest's full or partial name
- **By Phone:** Enter phone number (any format)
- **By Household:** Search by household name/number

### Search Tips
- Search is case-insensitive
- Partial names work (e.g., "John" finds "Johnson")
- Results update as you type
- Use filters to narrow results

---

## Guest Status Management

### Status Types
- **Expected:** Scheduled but not arrived
- **Checked In:** Currently in the community
- **Completed:** Has checked out
- **Overdue:** Stayed past scheduled time

### Check-in Process
1. Find guest (Expected status)
2. Tap on guest → Details
3. Tap "Check In" → Confirm
4. Status changes immediately

### Check-out Process
1. Find guest (Checked In status)
2. Tap on guest → Details
3. Tap "Check Out" → Confirm
4. Status changes to Completed
5. Visit duration is calculated

---

## Unregistered Guest Workflow

### When Guest Arrives Without Registration
1. **Get Host Information:**
   - Ask guest for household name/number
   - Ask for host's name if known

2. **Search for Household:**
   - Use Unregistered Guest screen
   - Search by household details
   - Select correct household

3. **Contact Household:**
   - Tap "Call Household" → Verify guest
   - Or tap "Send SMS" → Send notification
   - Wait for approval/response

4. **Register if Approved:**
   - Fill guest registration form
   - Link to verified household
   - Check in immediately

---

## Household Contact

### Making Phone Calls
- Tap "Call Household" button
- Phone dialer opens with correct number
- Introduce yourself and purpose
- Verify guest's visit

### Sending SMS Messages
- Tap "Send SMS" button
- Message template opens with guest info
- Review and send message
- Wait for text response

### Contact History
- All contacts are automatically logged
- View in contact history section
- Includes time, type, and result

---

## Business Rules

### Guest Limits
- Each household has maximum guest limits
- System warns when approaching limits
- May block additional registrations

### Visit Duration
- Standard visit duration is 2-4 hours
- Overdue guests are flagged
- Extensions may be granted by household

### Time Restrictions
- Some communities have visiting hours
- System enforces time-based rules
- Special approvals may be needed

---

## Performance Targets

### Response Times
- **Guest Search:** < 2 seconds
- **Guest Registration:** < 5 seconds
- **Check-in/Check-out:** < 3 seconds
- **Unregistered Guest Process:** < 10 minutes

### What to Do If Targets Aren't Met
1. Note the actual time taken
2. Describe what was slow
3. Report in UAT checklist
4. Include network conditions

---

## Troubleshooting

### Common Issues

#### Search Not Working
- Check network connection
- Verify spelling of search terms
- Try different search criteria
- Restart app if needed

#### Registration Fails
- Check all required fields are filled
- Verify phone number format
- Ensure household is selected
- Check network connectivity

#### Check-in Issues
- Verify guest is in "Expected" status
- Check if already checked in
- Ensure proper confirmation
- Contact supervisor if needed

#### Contact Problems
- Verify phone permissions are granted
- Check if phone number is correct
- Try both call and SMS options
- Use alternative contact if available

### Error Messages
- **"Guest Already Checked In":** Guest may already be on premises
- **"Household Not Found":** Verify household information with guest
- **"Network Error":** Try again when connection improves
- **"Permission Denied":** Check app permissions in settings

---

## Testing Guidelines

### During UAT Testing
1. **Follow the test checklist exactly**
2. **Time each operation** (use stopwatch)
3. **Note any errors or unusual behavior**
4. **Test both online and offline scenarios**
5. **Try edge cases and unusual inputs**
6. **Document all findings in checklist**

### What to Report
- ✅ **Working correctly:** Mark as passed
- ❌ **Not working:** Describe the issue
- ⚠️ **Working but slow:** Note the time
- ❓ **Unclear:** Describe confusion

### Performance Testing
- Use actual stopwatch for timing
- Test with different network conditions
- Try with large amounts of data
- Note any lag or delays

---

## Daily Workflow Summary

### Start of Shift
1. Log into Sentinel app
2. Check today's scheduled guests
3. Review any pending approvals
4. Verify network connectivity

### During Shift
1. **Guest Arrivals:**
   - Search for pre-registered guests
   - Check in approved guests
   - Register walk-in guests as needed

2. **Guest Departures:**
   - Check out guests leaving
   - Note any unusual circumstances
   - Update guest information if needed

3. **Ongoing Tasks:**
   - Monitor guest statuses
   - Contact households for verification
   - Handle any issues or exceptions

### End of Shift
1. Check out any remaining guests
2. Complete any pending registrations
3. Review contact history
4. Report any issues to supervisor

---

## Emergency Procedures

### System Not Working
1. Use manual logbook as backup
2. Report issue immediately
3. Document all guest activity manually
4. Update system when restored

### Security Concerns
1. Follow community security protocols
2. Contact supervisor immediately
3. Document incident in system if possible
4. Use emergency contacts if needed

### Power/Internet Outage
1. App may work in offline mode
2. Operations queue for later sync
3. Use manual procedures if needed
4. Ensure data is saved when restored

---

## Contact Information

### Technical Support
- **App Issues:** Contact IT support
- **System Problems:** Report to supervisor
- **Urgent Issues:** Use emergency contact

### Supervisor
- **Name:** _________________________
- **Phone:** _______________________
- **Email:** ________________________

### IT Support
- **Help Desk:** ____________________
- **Emergency:** ____________________

---

## Quick Commands Summary

| Task | Screen/Menu | Action |
|------|-------------|--------|
| Find Today's Guests | Guest List | Look in "Today's Guests" section |
| Register New Guest | Guest Registration | Fill form, select household |
| Check In Guest | Guest Details | Tap "Check In" → Confirm |
| Check Out Guest | Guest Details | Tap "Check Out" → Confirm |
| Search by Name | Guest List | Type name in search bar |
| Call Household | Guest Details | Tap "Call Household" |
| Send SMS | Guest Details | Tap "Send SMS" |
| View Contact History | Contact Section | Scroll through history |
| Handle Unregistered Guest | Unregistered Screen | Search household, contact, register |

---

*This quick reference guide should be kept handy during daily operations and UAT testing.*