# Feature Specification: Sentinel App - Gate Guard Access Control Mobile Application

**Feature Branch**: `004-sentinel-app-mobile`
**Created**: 2025-10-10
**Status**: Draft
**Input**: User description: "Sentinel App - Mobile application for gate guards to manage entry of residents, guests, deliveries, and construction workers at community gates with RFID verification and visitor logging"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Manage Resident Entry with RFID Verification (Priority: P1)

Gate guard verifies resident vehicles at gate entrance using RFID sticker scanning, validates sticker status and expiration, and grants or denies entry based on verification results.

**Why this priority**: Resident vehicle entry is the most frequent gate operation. This is the primary function of gate security and must work reliably for daily operations.

**Independent Test**: Can be fully tested by scanning an RFID sticker, verifying the system validates sticker status, and confirming entry is granted for valid stickers or denied for invalid/expired stickers.

**Acceptance Scenarios**:

1. **Given** a vehicle approaches the gate with RFID sticker, **When** gate guard scans the sticker, **Then** system validates sticker and displays resident information and sticker status
2. **Given** a valid active sticker, **When** verification completes, **Then** system grants entry and logs entry timestamp, vehicle plate, and resident information
3. **Given** an expired or invalid sticker, **When** verification completes, **Then** system denies entry and displays reason for denial
4. **Given** no sticker is detected, **When** vehicle approaches, **Then** system prompts guard to verify identity manually

---

### User Story 2 - Manage Guest Entry with Pre-Registration Check (Priority: P1)

Gate guard checks arriving guests against pre-registered guest list from households, verifies guest identity, calls household for unregistered guests, and logs guest entry with details.

**Why this priority**: Guest management is a core security function that balances access control with resident convenience. This is used multiple times daily.

**Independent Test**: Can be fully tested by checking a pre-registered guest on the list and granting entry, then attempting entry for an unregistered guest, calling the household head for verification, and logging entry.

**Acceptance Scenarios**:

1. **Given** guest arrives at gate, **When** guard searches guest list by name or expected household, **Then** system displays pre-registered guests for the current date
2. **Given** guest is found on pre-registered list, **When** guard verifies guest identity, **Then** system grants entry and logs guest name, time, destination household, and purpose
3. **Given** guest is not on pre-registered list, **When** guard searches for guest, **Then** system prompts guard to call household head for verification
4. **Given** household head is called, **When** household head approves guest entry remotely, **Then** system grants entry and logs approval details
5. **Given** household head denies or cannot be reached, **When** guard receives response, **Then** system denies entry and logs denial reason

---

### User Story 3 - Manage Delivery Entry and Tracking (Priority: P2)

Gate guard logs delivery arrivals, verifies delivery address, checks recipient availability, handles perishable delivery instructions, and monitors delivery duration with timers.

**Why this priority**: Delivery management is important for resident convenience but can be handled with basic logging if this feature is not available initially.

**Independent Test**: Can be fully tested by logging a delivery with delivery details, starting delivery timer, verifying recipient address, and logging delivery exit or completion.

**Acceptance Scenarios**:

1. **Given** delivery arrives at gate, **When** guard enters delivery details (company, recipient address, package type), **Then** system logs delivery arrival and verifies address exists in community
2. **Given** delivery address is verified, **When** guard checks recipient availability, **Then** system displays household contact information for verification
3. **Given** recipient is available, **When** delivery is authorized, **Then** system starts delivery timer and logs entry
4. **Given** delivery timer exceeds expected duration, **When** timer alert triggers, **Then** system notifies guard to follow up on delivery status
5. **Given** delivery exits gate, **When** guard logs exit, **Then** system records exit time and calculates total delivery duration
6. **Given** recipient is unavailable and package is perishable, **When** guard receives special instructions from household, **Then** system logs instructions and stores package per household preference

---

### User Story 4 - Manage Construction Worker Entry with Permit Verification (Priority: P2)

Gate guard verifies construction permits at gate, checks worker authorization against approved permit, monitors worker entry and exit, and tracks construction project duration.

**Why this priority**: Construction worker management is important for security and accountability but is not a daily operation for most communities.

**Independent Test**: Can be fully tested by scanning or entering permit reference, verifying worker is authorized, logging entry, tracking time on-site, and logging exit.

**Acceptance Scenarios**:

1. **Given** construction worker arrives with permit reference, **When** guard enters permit information, **Then** system displays approved permit details and authorized worker list
2. **Given** worker is on authorized list, **When** guard verifies worker identity, **Then** system grants entry and logs worker name, time, and associated permit
3. **Given** worker is not on authorized list, **When** guard checks permit, **Then** system denies entry and prompts guard to contact admin
4. **Given** multiple workers enter throughout the day, **When** guard logs entries and exits, **Then** system tracks which workers are currently on-site
5. **Given** construction project duration expires, **When** guard views permit status, **Then** system alerts guard that permit is expired and entry should be denied
6. **Given** construction is completed, **When** admin marks project complete, **Then** system automatically denies further worker entry attempts

---

### User Story 5 - Incident Reporting and Communication (Priority: P3)

Gate guard reports security incidents, suspicious activity, or rule violations, communicates with guard house dispatch, and receives instructions for incident response.

**Why this priority**: Incident reporting enhances security operations but can initially be handled through existing communication channels while this feature is developed.

**Independent Test**: Can be fully tested by creating an incident report with details, sending it to guard house, receiving acknowledgment, and viewing incident history.

**Acceptance Scenarios**:

1. **Given** guard observes an incident, **When** they create incident report with type, description, and location, **Then** report is sent to guard house dispatch immediately
2. **Given** incident is reported, **When** guard house receives report, **Then** dispatch can communicate with guard and provide response instructions
3. **Given** incident requires security response, **When** dispatch assigns response team, **Then** guard receives notification of incoming support
4. **Given** incident is resolved, **When** guard marks incident complete, **Then** system logs resolution time and details
5. **Given** rule violation occurs, **When** guard logs violation with violator information, **Then** system records violation for admin review

---

### User Story 6 - View Village Rules and Announcements (Priority: P3)

Gate guard accesses village rules, curfew times, and announcements from admin to stay informed about community policies and special instructions.

**Why this priority**: Rules and announcements improve guard effectiveness but are not critical for basic gate operations and can be communicated through other channels initially.

**Independent Test**: Can be fully tested by viewing village rules, checking curfew times, and reading announcements sent by admin.

**Acceptance Scenarios**:

1. **Given** guard opens app, **When** they navigate to rules section, **Then** system displays current village rules and guidelines
2. **Given** curfew is configured, **When** guard checks curfew times, **Then** system displays curfew hours and enforcement instructions
3. **Given** admin sends announcement, **When** guard logs in, **Then** announcement appears in notification feed
4. **Given** urgent announcement is sent, **When** guard is on duty, **Then** system sends push notification to alert guard immediately

---

### Edge Cases

- What happens when RFID reader hardware fails and guard cannot scan stickers?
- How does the system handle guest entry when household head cannot be reached for verification?
- What happens when a delivery stays on-site beyond expected duration and resident is not responsive?
- How does the system prevent duplicate entry logs if a vehicle tries to re-enter immediately after exit?
- What happens when a construction worker permit is valid but the specific worker is not on the authorized list?
- How are incidents handled during network connectivity issues when guard house cannot be reached?
- What happens when multiple guards at different gates log the same incident?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow gate guard to scan RFID stickers for vehicle verification
- **FR-002**: System MUST validate RFID sticker status (active, expired, invalid) in real-time
- **FR-003**: System MUST display resident information and sticker status after RFID scan
- **FR-004**: System MUST grant or deny entry based on RFID verification results
- **FR-005**: System MUST log all entry events with timestamp, vehicle information, and resident details
- **FR-006**: System MUST allow gate guard to search pre-registered guest list by name or household
- **FR-007**: System MUST display pre-registered guests for current date with visit details
- **FR-008**: System MUST allow gate guard to verify guest identity and grant entry
- **FR-009**: System MUST prompt guard to call household head when guest is not pre-registered
- **FR-010**: System MUST allow household head to approve or deny guest entry remotely when called
- **FR-011**: System MUST log all guest entries with name, time, destination household, and purpose
- **FR-012**: System MUST allow gate guard to log delivery arrivals with company, recipient, and package details
- **FR-013**: System MUST verify delivery address exists in community
- **FR-014**: System MUST display recipient contact information for delivery verification
- **FR-015**: System MUST start delivery timer when delivery enters gate
- **FR-016**: System MUST alert guard when delivery duration exceeds expected time
- **FR-017**: System MUST log delivery exit and calculate total delivery duration
- **FR-018**: System MUST allow gate guard to enter special instructions for perishable deliveries
- **FR-019**: System MUST allow gate guard to verify construction permits by permit reference
- **FR-020**: System MUST display approved permit details and authorized worker list
- **FR-021**: System MUST allow gate guard to verify worker identity against authorized list
- **FR-022**: System MUST log construction worker entry and exit with permit association
- **FR-023**: System MUST track which construction workers are currently on-site
- **FR-024**: System MUST alert guard when construction permit is expired
- **FR-025**: System MUST prevent construction worker entry when project is marked complete
- **FR-026**: System MUST allow gate guard to create incident reports with type, description, and location
- **FR-027**: System MUST send incident reports to guard house dispatch immediately
- **FR-028**: System MUST allow communication between gate guard and guard house dispatch
- **FR-029**: System MUST allow gate guard to log rule violations with violator information
- **FR-030**: System MUST allow gate guard to view village rules and guidelines
- **FR-031**: System MUST display curfew times and enforcement instructions
- **FR-032**: System MUST display announcements from admin in notification feed
- **FR-033**: System MUST send push notifications for urgent announcements
- **FR-034**: System MUST log all entry and exit events for audit trail
- **FR-035**: System MUST operate with offline capability for basic logging when network is unavailable

### Assumptions

- Gate guard user accounts are created by admin officers during security personnel setup
- RFID readers are configured and connected to gate guard mobile devices or nearby equipment
- Gate guards are trained on verification procedures and conflict resolution
- Household heads have mobile phones and can be reached during gate calls
- Delivery companies follow standard check-in procedures at gate
- Construction permits are printed or accessible digitally for worker verification
- Guard house dispatch personnel are available during gate operating hours
- Mobile app requires internet connectivity for real-time verification but can log offline
- Multiple guards may be assigned to different gates within the same community

### Key Entities

- **RFID Sticker Verification**: Real-time validation of vehicle sticker; contains sticker ID, resident information, status, expiration date, and validation result
- **Pre-Registered Guest**: Scheduled visitor on household guest list; contains guest name, household, visit date, duration, and verification status
- **Guest Entry Log**: Record of guest entry; contains guest name, time, destination household, purpose, verification method, and guard who approved
- **Delivery Log**: Record of delivery entry and tracking; contains delivery company, recipient address, package details, entry time, exit time, duration, and special instructions
- **Construction Permit Verification**: Validation of construction authorization; contains permit reference, approved worker list, project duration, expiration status, and associated household
- **Worker Entry Log**: Record of construction worker entry and exit; contains worker name, permit reference, entry time, exit time, and on-site status
- **Incident Report**: Security incident or rule violation record; contains incident type, description, location, timestamp, reporting guard, and resolution status
- **Entry/Exit Record**: Comprehensive log of all gate activity; contains entry type (resident/guest/delivery/worker), timestamp, vehicle or person details, and guard who processed

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: RFID sticker verification and entry decision complete in under 5 seconds per vehicle
- **SC-002**: Pre-registered guests are granted entry in under 30 seconds without requiring household calls
- **SC-003**: 95% of RFID scans successfully validate sticker status on first attempt
- **SC-004**: Unregistered guest verification (including household call) completes in under 3 minutes
- **SC-005**: Delivery logging and timer start complete in under 1 minute per delivery
- **SC-006**: Construction permit verification and worker entry decision complete in under 2 minutes
- **SC-007**: Incident reports are delivered to guard house dispatch within 10 seconds of submission
- **SC-008**: System maintains 100% accurate entry/exit logs with timestamp and guard attribution
- **SC-009**: Gate guards can process up to 50 entry events per hour without performance degradation
- **SC-010**: System provides offline logging capability with automatic sync when connectivity is restored
