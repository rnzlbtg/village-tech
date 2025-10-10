# Implementation Roadmap
## Village Tech v4 - 5 Phase Delivery Plan

**Project Duration:** 26 weeks (6.5 months)
**Team Size:** 6 people (4 FT developers, 2 PT support)
**Delivery Model:** Agile sprints (2-week iterations)

---

## Phase Overview

```
Phase 1: Foundation          [Weeks 1-4]   ████████░░░░░░░░░░░░░░░░
Phase 2: Core Residential    [Weeks 5-10]  ░░░░░░░░████████████░░░░
Phase 3: Security & Access   [Weeks 11-16] ░░░░░░░░░░░░████████████
Phase 4: Advanced Operations [Weeks 17-22] ░░░░░░░░░░░░░░░░░░░░████████████
Phase 5: Governance & Polish [Weeks 23-26] ░░░░░░░░░░░░░░░░░░░░░░░░████████
```

---

## PHASE 1: FOUNDATION (Weeks 1-4)

**Objective:** Establish multi-tenant architecture and core platform capabilities

**Milestone:** Platform can onboard communities with admins and residences

### Sprint 1 (Weeks 1-2)

#### Backend (Supabase/PostgreSQL)
- [ ] Multi-tenant database schema design
- [ ] Core entities: PlatformTenant, Association, Residence, Household, User
- [ ] Row-level security (RLS) policies for tenant isolation
- [ ] Many-to-many relationship: Household ↔ Residence
- [ ] Authentication setup (Supabase Auth)
- [ ] RBAC foundation (roles and permissions)

**Deliverables:**
- Database schema deployed to dev environment
- RLS policies tested and verified
- Auth flow functional

**Acceptance Criteria:**
- Multi-tenant data isolation verified (tenant A cannot access tenant B data)
- All core entities created with relationships
- Household can be linked to multiple residences

---

#### Platform App (Web Frontend)
- [ ] Project setup (Next.js/React + TypeScript)
- [ ] Authentication and authorization UI
- [ ] Platform admin dashboard skeleton
- [ ] Tenant creation form (community/association)

**Deliverables:**
- Platform app deployed to dev environment
- Login/logout functional
- Tenant creation form skeleton

**Acceptance Criteria:**
- Platform admin can log in
- Dashboard accessible with navigation

---

### Sprint 2 (Weeks 3-4)

#### Backend
- [ ] Platform onboarding API endpoints
  - POST /api/tenants (create community)
  - POST /api/tenants/:id/residences (define residences)
  - POST /api/tenants/:id/gates (configure gates)
  - POST /api/tenants/:id/admins (create admin users)
- [ ] Tenant configuration storage (rules, fees, quotas)
- [ ] Email/SMS notification service integration

**Deliverables:**
- Complete tenant onboarding API
- Admin user provisioning functional
- Notification service connected

**Acceptance Criteria:**
- Platform admin can create complete community via API
- Admin Head and Officers created with credentials
- Welcome emails sent to new admins

---

#### Platform App (Web Frontend)
- [ ] Complete tenant onboarding wizard
  - Step 1: Community details
  - Step 2: Define residences
  - Step 3: Configure gates/entrances
  - Step 4: Create admin users
- [ ] Residence management interface
- [ ] Gate configuration interface
- [ ] Admin user management

**Deliverables:**
- Full onboarding wizard functional
- Tenant configuration UI complete

**Acceptance Criteria:**
- Platform admin can onboard new community end-to-end via UI
- Residences, gates, and admins created successfully
- Data persisted and tenant-isolated

---

#### Admin App (Web Frontend)
- [ ] Project setup (Next.js/React + TypeScript)
- [ ] Admin authentication and role-based UI
- [ ] Admin dashboard skeleton
- [ ] Navigation structure

**Deliverables:**
- Admin app project scaffolded
- Admin Head and Admin Officer can log in

**Acceptance Criteria:**
- Admin users can log in with role-appropriate access
- Dashboard displays tenant-specific data only

---

### Phase 1 Completion Criteria
✅ Platform admin can create and configure new community tenant
✅ Admin accounts provisioned for new community
✅ Residences defined and stored
✅ Gates configured
✅ Household can be linked to multiple residences
✅ RBAC fully functional across all user types
✅ Multi-tenant data isolation verified

---

## PHASE 2: CORE RESIDENTIAL OPERATIONS (Weeks 5-10)

**Objective:** Deliver essential resident-facing features and household management

**Milestone:** Residents can manage households, request stickers, and receive announcements

### Sprint 3 (Weeks 5-6)

#### Backend
- [ ] Vehicle entity and sticker assignment
- [ ] Sticker allocation API
  - POST /api/admin/sticker-allocations (set quotas)
  - POST /api/households/:id/stickers/request
  - GET /api/households/:id/stickers
- [ ] Household member management API
- [ ] Beneficial user management API

**Deliverables:**
- Vehicle and Sticker entities functional
- Sticker request workflow API complete

**Acceptance Criteria:**
- Admin can set sticker quotas per household
- Household can request stickers within quota
- Stickers assigned to vehicles
- Beneficial users can receive vehicle stickers

---

#### Admin App
- [ ] Household setup interface
- [ ] Sticker allocation configuration
  - Set number of stickers per household
  - Notify households of allocations
- [ ] Sticker approval workflow
- [ ] Household head user creation

**Deliverables:**
- Admin can set up households and allocate stickers

**Acceptance Criteria:**
- Admin can create household and household head user
- Admin can set and modify sticker quotas
- Sticker allocation notifications sent to households

---

#### Residence App (Mobile - Flutter)
- [ ] Project setup (Flutter + Supabase client)
- [ ] Authentication (household head and members)
- [ ] Household member management UI
  - Add/edit/remove members
  - Assign roles to members
- [ ] Beneficial user management UI
- [ ] Profile and settings

**Deliverables:**
- Residence app deployed to dev (iOS + Android)
- Household management functional

**Acceptance Criteria:**
- Household head can log in
- Household head can manage members
- Beneficial users can be added and managed

---

### Sprint 4 (Weeks 7-8)

#### Backend
- [ ] Payment entity and transaction tracking
- [ ] Payment gateway integration (Stripe/PayPal)
- [ ] Receipt generation service
- [ ] Association fee management API
- [ ] Payment history API

**Deliverables:**
- Payment processing functional
- Receipts auto-generated

**Acceptance Criteria:**
- Payments processed and tracked
- Receipts stored and retrievable
- Payment history accessible

---

#### Admin App
- [ ] Association fee management
  - Set fee schedules
  - Track fee collection
- [ ] Announcement system
  - Create and send announcements
  - Target all or specific households
- [ ] File and document storage interface

**Deliverables:**
- Admin can manage fees and send announcements

**Acceptance Criteria:**
- Admin can set association fees
- Announcements sent to all residents
- Documents uploaded and stored

---

#### Residence App
- [ ] Vehicle sticker request workflow
  - Request stickers for household vehicles
  - Register vehicle plate numbers
  - Track sticker status (pending, approved, collected)
- [ ] Notification center
  - Receive announcements
  - Sticker approval notifications

**Deliverables:**
- Residents can request and track stickers
- Notifications received

**Acceptance Criteria:**
- Household can request stickers within quota
- Vehicle plate numbers registered
- Sticker status visible (pending/approved)
- Announcements appear in notification center

---

### Sprint 5 (Weeks 9-10)

#### Backend
- [ ] Guest management API
  - POST /api/households/:id/guests (schedule guest)
  - GET /api/households/:id/guests
  - PUT /api/guests/:id/extend (visit extension)
- [ ] Guest list integration with Sentinel app
- [ ] Visit duration tracking (day-trip vs multi-day)

**Deliverables:**
- Guest scheduling API complete
- Visit extension functional

**Acceptance Criteria:**
- Household can schedule guests with duration
- Guest list accessible to Sentinel app
- Visit extensions tracked

---

#### Residence App
- [ ] Guest scheduling interface
  - Add guest (name, phone, plate, date, duration)
  - Day-trip vs multi-day selection
  - Guest list view
  - Extend or cancel guest visits
- [ ] Payment interface
  - View outstanding fees
  - Pay association fees
  - Payment history
  - View receipts

**Deliverables:**
- Residents can schedule guests and make payments

**Acceptance Criteria:**
- Household can schedule day-trip and multi-day guests
- Guest visits can be extended
- Payments processed in-app
- Receipts viewable

---

### Phase 2 Completion Criteria
✅ Household management fully functional
✅ Sticker allocation and request workflow complete
✅ Beneficial users manageable
✅ Vehicle registration and sticker assignment working
✅ Guest scheduling operational (with duration tracking)
✅ Payment processing and receipt generation functional
✅ Association fees manageable
✅ Announcements sent and received
✅ Financial transaction tracking in place

---

## PHASE 3: SECURITY & ACCESS CONTROL (Weeks 11-16)

**Objective:** Enable comprehensive gate management and security operations

**Milestone:** Guards can manage entry/exit, verify guests, and log incidents

### Sprint 6 (Weeks 11-12)

#### Backend
- [ ] Entry/exit logging API
  - POST /api/gates/:id/entries (log entry)
  - POST /api/gates/:id/exits (log exit)
  - GET /api/gates/:id/logs
- [ ] RFID sticker validation API
- [ ] Guest list verification API for guards
- [ ] Real-time communication (WebSocket/SSE)

**Deliverables:**
- Entry logging API complete
- RFID validation functional
- Real-time updates enabled

**Acceptance Criteria:**
- Guards can log entries and exits
- RFID stickers validated in real-time
- Guest lists accessible to guards
- Real-time notifications sent

---

#### Sentinel App (Mobile - Flutter)
- [ ] Project setup (Flutter + Supabase client)
- [ ] Guard authentication
- [ ] Gate selection (guard assigned to gate)
- [ ] RFID sticker scanner integration
  - Scan RFID/QR code
  - Validate sticker status
  - Allow/deny entry

**Deliverables:**
- Sentinel app deployed to dev
- RFID validation functional

**Acceptance Criteria:**
- Gate guards can log in
- Guards can select assigned gate
- RFID stickers scanned and validated
- Valid stickers allow entry

---

### Sprint 7 (Weeks 13-14)

#### Backend
- [ ] Construction permit API (if not done earlier)
  - POST /api/households/:id/construction-permits
  - PUT /api/construction-permits/:id/approve
  - POST /api/construction-permits/:id/workers (register workers)
- [ ] Construction worker gate pass generation
- [ ] Worker entry verification API

**Deliverables:**
- Construction permit workflow API complete
- Worker gate passes generated

**Acceptance Criteria:**
- Households can request construction permits
- Admin can approve permits and compute fees
- Workers registered and passes issued
- Worker passes validated at gate

---

#### Admin App
- [ ] Construction permit approval workflow
  - Receive construction requests
  - Compute road fees based on details
  - Approve/reject permits
  - Send permits to guard house
- [ ] Village rules and curfew settings
- [ ] Security coordination interface

**Deliverables:**
- Admin can approve construction permits

**Acceptance Criteria:**
- Admin receives construction requests
- Fees computed and payment tracked
- Permits approved and sent to guards
- Village rules and curfew configurable

---

#### Residence App
- [ ] Construction permit request
  - Submit construction details
  - Pay construction fees
  - Register construction workers
  - Schedule worker gate passes
  - Track permit status
- [ ] Guest pre-registration with duration

**Deliverables:**
- Residents can request construction permits and schedule workers

**Acceptance Criteria:**
- Household submits construction details
- Fees displayed and payable
- Workers registered individually
- Worker gate passes visible
- Permit status tracked (pending, approved, in-progress, completed)

---

### Sprint 8 (Weeks 15-16)

#### Sentinel App
- [ ] Guest verification workflow
  - Check guest against guest list
  - Call household if guest not on list
  - Log guest entry (name, time, plate, purpose)
  - Grant or deny entry
- [ ] Visitor identity verification (manual)
- [ ] Construction worker verification
  - Scan worker pass
  - Validate against construction permit
  - Log worker entry/exit
- [ ] Entry/exit logging UI

**Deliverables:**
- Full entry verification workflow functional

**Acceptance Criteria:**
- Guards verify guests against list
- Guards can call household for unlisted visitors
- Guest entries logged
- Worker passes verified
- Entry/exit logs visible

---

### Phase 3 Completion Criteria
✅ RFID sticker validation operational
✅ Visitor identity verification functional
✅ Guest list checking working
✅ Entry/exit logging complete
✅ Real-time communication with dispatch functional
✅ Construction permit approval workflow complete
✅ Construction worker gate passes issued and verified
✅ Admin can coordinate with security team

---

## PHASE 4: ADVANCED OPERATIONS (Weeks 17-22)

**Objective:** Complete specialized workflows for construction, delivery, and incidents

**Milestone:** Full construction lifecycle, delivery tracking, and incident management operational

### Sprint 9 (Weeks 17-18)

#### Backend
- [ ] Construction completion workflow API
  - PUT /api/construction-permits/:id/complete
  - Worker pass expiration on completion
- [ ] Delivery management API
  - POST /api/gates/:id/deliveries (log delivery)
  - PUT /api/deliveries/:id/status (update status)
  - Timer-based monitoring
- [ ] Delivery notification to households

**Deliverables:**
- Construction completion workflow complete
- Delivery tracking API functional

**Acceptance Criteria:**
- Construction permits can be marked complete
- Worker passes expire on completion
- Deliveries logged and tracked
- Household notified of deliveries

---

#### Admin App
- [ ] Construction completion verification
  - View in-progress construction
  - Mark as completed (with inspection if needed)
  - Final report or photos
- [ ] Construction monitoring dashboard

**Deliverables:**
- Admin can verify and complete construction

**Acceptance Criteria:**
- Admin sees in-progress construction list
- Admin can mark construction complete
- Completion notifications sent

---

#### Residence App
- [ ] Construction completion submission
  - Household marks construction complete
  - Upload final photos (optional)
- [ ] Delivery notifications
  - Real-time delivery arrival alerts
  - Delivery status tracking
  - Delivery history

**Deliverables:**
- Residents can complete construction and track deliveries

**Acceptance Criteria:**
- Household marks construction complete
- Delivery notifications received
- Delivery history viewable

---

### Sprint 10 (Weeks 19-20)

#### Backend
- [ ] Incident management API
  - POST /api/incidents (report incident)
  - PUT /api/incidents/:id/escalate (escalate to admin)
  - GET /api/incidents (for admin and dispatcher)
- [ ] Incident severity classification
- [ ] Incident escalation rules

**Deliverables:**
- Incident reporting and escalation API complete

**Acceptance Criteria:**
- Incidents reported and logged
- Severity classified
- High-severity incidents escalate to admin

---

#### Sentinel App
- [ ] Delivery management workflow
  - Log delivery arrival
  - Verify address
  - Check recipient availability
  - Perishable item handling
  - Timer monitoring
  - Delivery exit logging
- [ ] Incident reporting
  - Manual incident report
  - Incident type and severity
  - Photo/video upload
- [ ] Dispatcher coordination interface (basic)

**Deliverables:**
- Delivery and incident management functional

**Acceptance Criteria:**
- Guards log deliveries with timer
- Escalation protocol for delayed deliveries
- Incidents reported with details
- Dispatcher receives alerts

---

### Sprint 11 (Weeks 21-22)

#### Backend
- [ ] CCTV AI analysis integration (if applicable)
- [ ] Incident analytics API
- [ ] Response time tracking

**Deliverables:**
- Advanced incident features functional

**Acceptance Criteria:**
- CCTV alerts (if integrated) trigger incidents
- Incident analytics available

---

#### Admin App
- [ ] Incident dashboard
  - View all incidents
  - Filter by severity, status, date
  - Acknowledge and comment on incidents
- [ ] Incident escalation notifications

**Deliverables:**
- Admin can monitor and manage incidents

**Acceptance Criteria:**
- Admin sees incident dashboard
- High-severity incidents highlighted
- Admin can acknowledge and comment

---

#### Sentinel App
- [ ] Dispatcher dashboard
  - Monitor all gates
  - View live entry logs
  - Deploy guards to incidents
  - Communication with gate guards
- [ ] Roaming guard interface

**Deliverables:**
- Dispatcher coordination fully functional

**Acceptance Criteria:**
- Dispatcher sees all gate activity
- Dispatcher deploys guards
- Communication channels functional

---

### Phase 4 Completion Criteria
✅ Full construction permit lifecycle operational (request → approval → monitoring → completion)
✅ Construction worker gate passes functional
✅ Delivery logging and tracking complete
✅ Household delivery notifications working
✅ Incident reporting functional (manual and AI-based if applicable)
✅ Incident escalation to admin operational
✅ Dispatcher coordination complete

---

## PHASE 5: GOVERNANCE & ANALYTICS (Weeks 23-26)

**Objective:** Enable community governance and provide insights via dashboards

**Milestone:** Election system functional, dashboards live, system polished for production

### Sprint 12 (Weeks 23-24)

#### Backend
- [ ] Election management API
  - POST /api/elections (create election)
  - POST /api/elections/:id/nominations (nominate candidate)
  - POST /api/elections/:id/votes (cast vote)
  - GET /api/elections/:id/results (results)
- [ ] Voting mechanism (one vote per household head)
- [ ] Results tabulation
- [ ] Term tracking for elected officers

**Deliverables:**
- Election system API complete

**Acceptance Criteria:**
- Elections created with positions and timelines
- Household heads can nominate and vote
- One vote per household enforced
- Results tabulated and announced

---

#### Admin App
- [ ] Election management interface
  - Create election
  - Set nomination and voting periods
  - Monitor nominations and votes
  - View and announce results
- [ ] Officer term tracking

**Deliverables:**
- Admin can manage elections end-to-end

**Acceptance Criteria:**
- Admin creates election
- Nominations and votes tracked
- Results displayed and announced
- Elected officers tracked

---

#### Residence App
- [ ] Election participation
  - View active elections
  - Nominate candidates (self or others)
  - Cast votes
  - View results
- [ ] Polish and UI refinements

**Deliverables:**
- Residents can participate in elections

**Acceptance Criteria:**
- Household heads see active elections
- Nominations submitted
- Votes cast securely
- Results viewable

---

### Sprint 13 (Weeks 25-26)

#### Backend
- [ ] Analytics and reporting API
  - Entry/exit statistics
  - Sticker usage metrics
  - Financial reports (fees collected, outstanding)
  - Incident response times
- [ ] Dashboard data aggregation

**Deliverables:**
- Analytics API complete

**Acceptance Criteria:**
- Dashboard data aggregated and accessible
- Reports exportable (PDF, CSV)

---

#### Admin App
- [ ] Admin analytics dashboard
  - Entry statistics (daily, weekly, monthly)
  - Sticker usage and violations
  - Fees collected and outstanding
  - Announcements sent and read
  - Resident analytics
- [ ] Financial reports
- [ ] Export functionality

**Deliverables:**
- Admin dashboard with KPIs and reports

**Acceptance Criteria:**
- Dashboard displays key metrics
- Financial reports accurate
- Data exportable

---

#### Sentinel App
- [ ] Security analytics dashboard
  - Incident statistics
  - Response times
  - Entry logs and trends
  - Guard activity metrics
- [ ] Offline mode implementation (basic)
  - Cache critical data locally
  - Queue offline actions
  - Sync when online

**Deliverables:**
- Security dashboard and offline mode functional

**Acceptance Criteria:**
- Dispatcher sees security metrics
- Entry logs work offline
- Data syncs when online

---

#### All Apps
- [ ] Announcement read receipts
- [ ] Offline mode polish (Residence and Sentinel)
- [ ] Document management system (Admin)
- [ ] Guard shift management (Sentinel)
- [ ] Performance optimization
- [ ] Security audit and fixes
- [ ] User acceptance testing (UAT)

**Deliverables:**
- All minor gaps addressed
- System production-ready

**Acceptance Criteria:**
- Read receipts tracked
- Offline mode reliable
- Documents manageable
- Shifts schedulable
- Performance meets targets (API < 200ms, entry < 30s)
- Security audit passed
- UAT feedback incorporated

---

### Phase 5 Completion Criteria
✅ Election system fully functional
✅ Admin and security dashboards live
✅ Financial reports accurate
✅ Offline mode operational for mobile apps
✅ Document management functional
✅ Guard shift scheduling working
✅ Performance optimized
✅ Security audit passed
✅ System ready for production launch

---

## Deployment & Go-Live Plan

### Week 26: Production Deployment Preparation
- [ ] Production environment setup (Platform, Admin, Residence, Sentinel)
- [ ] Database migration scripts tested
- [ ] SSL certificates and domain configuration
- [ ] Production RBAC and security policies verified
- [ ] Backup and disaster recovery plan
- [ ] Monitoring and alerting setup (error tracking, uptime monitoring)

### Week 27: Soft Launch
- [ ] Pilot community onboarded (1-2 communities)
- [ ] Admin training conducted
- [ ] Household heads onboarded
- [ ] Guards trained on Sentinel app
- [ ] Monitor system performance and collect feedback

### Week 28: Full Launch
- [ ] Address pilot feedback
- [ ] Onboard remaining communities
- [ ] Marketing and communication to all residents
- [ ] Support team ready for inquiries
- [ ] Go-live announcement

---

## Resource Allocation

### Team Structure

| Role | Allocation | Responsibilities |
|------|------------|------------------|
| **Backend Developer** | 1 FT (100%) | Supabase, APIs, database, integrations |
| **Frontend Developer (Web)** | 1 FT (100%) | Platform App, Admin App (Next.js/React) |
| **Mobile Developer (Flutter)** | 1 FT (100%) | Residence App, Sentinel App |
| **Full-Stack Developer** | 1 FT (100%) | Support all apps, integrations, testing |
| **Product Manager/BA** | 1 PT (50%) | Requirements, stakeholder coordination, UAT |
| **DevOps/QA Engineer** | 1 PT (50%) | CI/CD, deployment, testing, monitoring |

---

## Risk Management

### High-Risk Areas & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Multi-tenant data leakage** | CRITICAL | LOW | Rigorous RLS testing, security audit, peer review of all queries |
| **Payment gateway integration delays** | HIGH | MEDIUM | Start integration early in Phase 2, use sandbox testing, have backup provider |
| **RFID hardware compatibility** | HIGH | MEDIUM | Define hardware specs in Phase 1, test with multiple RFID readers, implement fallback (QR codes) |
| **Scope creep** | MEDIUM | HIGH | Strict change control process, prioritize P0/P1 gaps only for V1 |
| **Mobile app performance (offline mode)** | MEDIUM | MEDIUM | Implement offline-first architecture from start, test on low-end devices |
| **Election security (vote tampering)** | HIGH | LOW | Use secure voting mechanism, one vote per household enforced at DB level, audit trail |

---

## Dependencies

### External Dependencies
- **Payment Gateway** (Stripe/PayPal): Account setup, API keys, testing
- **SMS/Email Service** (Twilio/SendGrid): Account setup, templates
- **RFID Hardware**: Specifications, procurement, testing
- **CCTV/AI Integration**: API access, data format, integration testing
- **Document Storage** (AWS S3 or compatible): Bucket setup, access policies

### Internal Dependencies
- **Platform App → Admin App**: Tenant data must exist before admin login
- **Admin App → Residence App**: Sticker allocations before requests
- **Residence App → Sentinel App**: Guest lists before gate verification
- **Phase 1 → Phase 2**: Data model must be complete before building features
- **Phase 2 → Phase 3**: Household and vehicle data required for gate operations

---

## Success Metrics (Post-Launch)

### Week 4 Post-Launch
- ✅ 3+ communities onboarded
- ✅ 90%+ households registered
- ✅ 95%+ gate entries processed < 30 seconds
- ✅ < 0.5% mobile app crash rate

### Week 12 Post-Launch
- ✅ 10+ communities onboarded
- ✅ 95%+ fee collection rate
- ✅ User satisfaction score > 4.0/5
- ✅ < 0.1% unauthorized entry attempts

### Week 26 Post-Launch (6 months)
- ✅ 25+ communities onboarded
- ✅ Platform tenant retention > 95%
- ✅ User satisfaction score > 4.5/5
- ✅ All KPIs met (see Executive Summary)

---

## Appendix: Sprint Planning Template

### Sprint Planning Checklist
- [ ] Sprint goal defined
- [ ] User stories prioritized
- [ ] Acceptance criteria clear
- [ ] Estimation complete (story points or hours)
- [ ] Dependencies identified
- [ ] Team capacity verified
- [ ] Sprint backlog finalized

### Daily Standup Questions
1. What did I complete yesterday?
2. What will I work on today?
3. Are there any blockers?

### Sprint Review & Retrospective
- Demo completed work to stakeholders
- Collect feedback
- Retrospective: What went well? What can improve?
- Update roadmap based on learnings

---

**Related Documents:**
- [Comprehensive Analysis](business-analysis-comprehensive.md)
- [Executive Summary](executive-summary.md)
- [Gap Analysis](gap-analysis.md)
- [Data Model Recommendations](data-model-recommendations.md)
