# Application Features - Village Tech v4

## Platform App (Web)
### Core Features
- Create new tenant (residential community)
- Define residence/property information
- Define community entrances and gates
- Create initial admin head user
- Create initial admin officer users

### Additional Features Found in Workflows
- Multi-tenant architecture configuration
- Gate/entrance equipment configuration (RFID readers)
- Association-level settings and rules provisioning
- Platform super admin role management

## Admin App (Web)
### Core Features
- Residential community administration interface
- Set up residence information and household head users
- Approve gate pass requests for vehicles (stickers)
- Send announcements to residents (guard house, gate guards, roaming guards)
- Set up periodic election of residential community officers
- Approve construction permits (receive details and collect payment)

### Additional Features Found in Workflows
- Set number of stickers per household
- Notify household heads about sticker availability
- Collect signatures for sticker pickup
- Store files and records (permits, rules, receipts)
- Compute construction road fees based on details
- Send construction permits to guard house
- Place construction on hold if payment not received
- Mark construction projects as completed
- Set village rules and guidelines
- Set curfew times
- Coordinate with security agency
- Set association fees
- Collect fees and issue receipts
- Communication channels to guard house and security personnel
- Store and distribute village rules and guidelines

## Residence App (Mobile)
### Core Features
- Manage members of the household
- Manage list of beneficial users (non-resident vehicle sticker recipients)
- Household head can manage one or more residences
- Request gate passes for vehicles (for household members and beneficial users)
- Send construction permit requests (details, pay fees, schedule workers)
- Schedule house guests for visits (day-trip or multi-day)

### Additional Features Found in Workflows
- Set up or update household head and household group
- Register household residents
- Receive sticker release notifications from association
- Request and collect vehicle stickers at admin office
- Sign release documents for sticker pickup
- Distribute stickers among household residents
- Register vehicle plate numbers for stickers
- Store household records
- Submit maintenance/construction requests with project details
- Receive fee computation notifications
- Pay construction fees
- Receive construction permit approval notifications
- Announce guests to gate in advance
- Notify gate of guest arrival
- Receive entry records and confirmations
- Confirm guest identity remotely when called by guards
- Allow or deny guest entry when not pre-registered
- Communicate with association admin
- Voting and signatory rights for elections
- Receive announcements from admin
- Receive notifications from gate guards
- Track visit duration (day vs multi-day visits)

## Sentinel App (Mobile)
### Core Features
- Manage entry of residents at gate entrances
- Manage entry of guests at gate entrances
- Manage entry of deliveries at gate entrances
- Manage entry of construction workers at gate entrances
- Track individuals passing through community gates
- Track vehicles passing through community gates
- Access guest lists sent by households
- Access list of construction workers with permits

### Additional Features Found in Workflows
- Verify RFID stickers at gate entrance
- Validate sticker status and expiration
- Verify identity when no valid sticker present
- Check visitor against pre-registered guest list
- Call home owner to verify unregistered visitors
- Enter visitor log (name, time, plate number, purpose)
- Record entry and exit of all personnel and vehicles
- Grant or deny entry based on household approval
- Delivery arrival logging
- Verify correct delivery address
- Check if recipient is available
- Handle perishable delivery instructions
- Monitor delivery duration with timer
- Follow response protocol for delayed deliveries
- Accept or store deliveries per household instructions
- Construction permit validation at gate
- Monitor construction worker entry and exit
- Track construction project duration
- Log construction completion
- Monitor entry of personnel and activity
- Live user incident reporting
- Receive CCTV AI threat/anomaly alerts
- Guard house coordination and deployment
- Dispatch security personnel to incidents
- Incident logging and reporting
- Communication with roaming guards
- Real-time communication with guard house dispatch
- Receive village rules and curfew information
- Receive announcements from admin
- Response protocols for various scenarios
- Track traffic violations and violators

---

**Note:** The Platform App workflows are not currently defined in the existing documentation (20% coverage). The election management feature for the Admin App is also not present in the workflows. Construction worker individual gate pass issuance process needs clarification between Residence App and Sentinel App integration.
