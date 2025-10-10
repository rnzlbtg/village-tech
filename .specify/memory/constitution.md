# Village Tech v4 Constitution

<!--
Sync Impact Report:
- Version change: [unversioned template] → 1.0.0
- Modified principles: All placeholders replaced with concrete principles from reference
- Added sections:
  * Code Standards
  * Architecture
  * Security and Privacy
  * UX and Design Principles
  * Performance
  * Error Handling and Logging
  * Testing
  * Documentation
  * Refactoring and Maintenance
  * Mobile (Flutter) Principles
- Removed sections: Generic placeholder sections replaced with concrete content
- Templates requiring updates:
  ✅ plan-template.md - Constitution Check section already generic (no update needed)
  ✅ spec-template.md - No constitution-specific references found (no update needed)
  ✅ tasks-template.md - Test and task organization aligns with constitution (no update needed)
  ✅ commands/*.md - No command files exist yet (no update needed)
- Follow-up TODOs: None - all placeholders filled
-->

## Core Principles

### I. Intent-First Development

Every change begins by understanding **why** before deciding **how**. Features and modifications must have clear intent documented before implementation begins. No code is written until the purpose, expected outcome, and success criteria are articulated and approved.

**Rationale**: Intent-first development prevents wasted effort on misunderstood requirements and ensures every line of code serves a documented purpose.

### II. Specification-Driven Workflow (NON-NEGOTIABLE)

No implementation without an approved specification. Every feature must flow from spec → plan → task → code → test. Specifications are living documents that capture requirements, constraints, and acceptance criteria before any code is written.

**Rationale**: Specifications serve as contracts between stakeholders and implementers, preventing scope drift and ensuring shared understanding.

### III. Clarity, Consistency, and Maintainability

Code must be clear in intent, consistent in style, and maintainable by others. Favor readability over cleverness. Use consistent naming conventions, formatting, and architectural patterns throughout the codebase.

**Rationale**: Code is read far more often than written. Prioritizing clarity reduces cognitive load and enables teams to move faster over time.

### IV. Quality Over Speed (NON-NEGOTIABLE)

Quality and correctness take precedence over delivery speed. Incomplete features must not ship. Technical debt must be justified, documented, and scheduled for resolution.

**Rationale**: Speed without quality creates compounding maintenance costs and erodes user trust. Quality first is speed later.

### V. Traceability

Every change must be traceable from spec → plan → task → code → test. This creates an audit trail that explains not just what changed, but why it changed and how it was validated.

**Rationale**: Traceability enables effective debugging, onboarding, and compliance while preventing orphaned code.

## Code Standards

### Naming Conventions

- **Classes and types**: PascalCase (e.g., `UserService`, `PaymentProcessor`)
- **Files and modules**: snake_case (e.g., `user_service.py`, `payment_processor.dart`)
- **Variables and functions**: camelCase or snake_case (language-dependent, but consistent within project)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `MAX_RETRY_ATTEMPTS`)

### Code Organization

- Keep functions small, single-purpose, and readable (ideally under 50 lines)
- Avoid duplication – follow the DRY (Don't Repeat Yourself) principle
- Prefer explicit logic over clever abstractions
- Write self-documenting code; minimize unnecessary comments
- Comments MUST explain **why**, not **what** (the code shows what)

### Formatting

- Maintain consistent code formatting and linting rules across the project
- Use automated formatters (e.g., Black, Prettier, dartfmt) and enforce in CI
- Configure editor to match project formatting rules

## Architecture

### Layered Architecture

Follow modular, layered architecture:

```
UI Layer → Application Layer → Domain Layer → Infrastructure Layer
```

- **UI Layer**: User interface, presentation logic, view models
- **Application Layer**: Use cases, orchestration, application-specific logic
- **Domain Layer**: Business logic, entities, domain rules (platform-agnostic)
- **Infrastructure Layer**: External integrations, databases, file systems, network

### Dependency Management

- Keep dependencies explicit; avoid circular imports or hidden coupling
- Use dependency injection where appropriate
- Document why each dependency exists

### Business Logic

- Encapsulate business logic in the domain layer, NOT in the UI
- UI components should be thin orchestrators, not decision-makers
- Domain models should be framework-agnostic

### API Boundaries

- Use clear boundaries between internal and external APIs
- Version all public APIs
- Document contracts explicitly (see contracts/ in spec structure)

### Foundational Qualities

Design for scalability, observability, and testability from day one:

- **Scalability**: Consider load, concurrency, and data growth early
- **Observability**: Structured logging, correlation IDs, metrics, tracing hooks
- **Testability**: Inject dependencies, avoid global state, design for unit + integration tests

## Security and Privacy

### Input Validation

- Sanitize all user input before processing
- Validate data types, ranges, formats, and lengths
- Use allowlists over blocklists where possible

### Secure Defaults

- Use secure defaults for authentication, encryption, and storage
- Enforce HTTPS, TLS 1.2+, strong password policies
- Enable security headers (CSP, HSTS, etc.) by default

### Secret Management

- NEVER log sensitive information (credentials, tokens, PII, API keys)
- Store secrets in environment variables or secret management systems
- Rotate secrets regularly and invalidate compromised credentials immediately

### Least Privilege

- Follow least-privilege principles in permissions and data access
- Grant only the minimum necessary permissions to users and services
- Audit access logs regularly

### Dependency Security

- Regularly review dependencies for known vulnerabilities
- Use automated tools (e.g., Dependabot, Snyk) to monitor and update dependencies
- Pin dependency versions and review changes before updating

## UX and Design Principles

### Accessibility (NON-NEGOTIABLE)

- WCAG 2.1 AA compliance minimum for all interfaces
- Maintain color contrast ratio of at least 4.5:1 for normal text
- Support keyboard navigation and screen readers
- Provide alt text for images and semantic HTML

### Responsive Design

- Mobile-first, responsive layouts
- Use a responsive grid system and consistent breakpoints (e.g., 320px, 768px, 1024px, 1440px)
- Test on real devices and screen sizes
- Maintain usability and visual clarity across all devices

### Visual Hierarchy

- Clear visual hierarchy, minimalism, and readable typography
- Use minimal colors and sufficient whitespace
- Maintain visual balance and rhythm across UI components
- Apply the golden ratio (1:1.618) where possible for spacing, typography, and layout proportions

### Design Tokens

- Use design tokens (spacing, color, typography) for consistency
- Avoid hard-coded color or size values in components
- Define tokens centrally and reference them throughout the codebase

### Dark Mode

- Include dark mode support for all interfaces
- Test contrast ratios in both light and dark modes
- Allow user preference to override system default

### Icons

- Only use icons from the provided library or package
- Icons should align visually with text
- Follow consistent stroke weight and grid sizing (e.g., 24x24px grid)

## Performance

### Optimization Philosophy

- Optimize for readability first, then for speed
- Measure performance using metrics before optimizing
- Document performance targets and monitor against them

### Latency Targets

- Ensure API responses are under target latency (e.g., < 200ms p95)
- Set and monitor SLOs (Service Level Objectives) for critical paths
- Profile and optimize hot paths only after measurement

### Resource Management

- Use caching and lazy loading responsibly
- Prevent unnecessary computation, rendering, or data fetching
- Monitor memory usage and prevent leaks
- Consider battery impact on mobile devices

## Error Handling and Logging

### Error Messages

- Use structured, descriptive error messages with consistent error codes
- Include actionable guidance in user-facing errors
- Log errors with sufficient context for debugging (stack trace, request ID, user context)

### Graceful Degradation

- Catch and handle errors gracefully; never expose raw stack traces to users
- Provide fallback behavior where possible
- Fail safely and predictably

### Logging Discipline

- Log meaningful events only – avoid noise
- Use correlation IDs to trace user and system events across services
- Log levels: ERROR (requires action), WARN (potential issue), INFO (business event), DEBUG (development only)
- Treat warnings as early indicators of failure, not ignorable noise

### Observability

- Emit structured logs in JSON format for machine parsing
- Include timestamps, log levels, correlation IDs, and context
- Integrate with centralized logging and monitoring systems

## Testing

### Test Coverage

- Write tests for all critical paths and new features
- Maintain at least 80% test coverage per module
- Measure coverage and enforce in CI

### Test Types

- **Unit tests**: Test individual functions and classes in isolation
- **Integration tests**: Test interactions between modules and services
- **End-to-end tests**: Test complete user flows from UI to database
- Choose the right test type for each scenario

### Test Quality

- Tests must be deterministic and independent
- Tests should run quickly (unit tests < 1s, integration tests < 10s)
- Use test doubles (mocks, stubs, fakes) appropriately
- Follow Arrange-Act-Assert pattern

### Test-First Development

- Write tests BEFORE implementation where possible (TDD)
- Ensure tests FAIL before implementation (red-green-refactor)
- Tests serve as executable specifications

## Documentation

### Module Documentation

- Every module must include a brief purpose and usage note
- Explain what the module does, not how it does it
- Keep documentation close to code (inline or adjacent README)

### API Documentation

- Public APIs require inline docstrings and examples
- Document parameters, return values, exceptions, and side effects
- Provide usage examples for non-trivial APIs

### Structural Documentation

- Update README or architecture docs when structural changes occur
- Maintain a high-level architecture diagram or description
- Document deployment, configuration, and operational procedures

### Edge Case Documentation

- Document assumptions, edge cases, and known limitations
- Explain non-obvious decisions and trade-offs
- Link to relevant specs or issues for context

## Refactoring and Maintenance

### Code Hygiene

- Remove dead code, unused dependencies, and obsolete comments
- Run automated linters and fix warnings
- Refactor opportunistically while working in an area

### Technical Debt

- Prioritize fixing technical debt before adding new features
- Document technical debt with TODO comments and track in issues
- Justify debt decisions and schedule resolution

### Backward Compatibility

- Maintain backward compatibility unless deprecation is approved
- Provide migration paths and deprecation warnings
- Version breaking changes and communicate them clearly

## Mobile (Flutter) Principles

### Architecture and Patterns

- Follow clean architecture and MVVM or BLoC pattern for maintainability
- Separate presentation, business logic, and data layers
- Use dependency injection for testability

### Cross-Platform Consistency

- Ensure cross-platform consistency between iOS, Android, and web builds
- Test on all target platforms before release
- Use platform-specific code only when necessary and isolate it

### Responsive and Adaptive Layouts

- Use responsive and adaptive layouts for various screen sizes
- Test on different device sizes and orientations
- Handle safe areas and notches gracefully

### State Management

- Apply state management best practices (e.g., Riverpod, Provider, Bloc)
- Choose state management solution appropriate to app complexity
- Document state flow and interactions

### Type Safety

- Implement null safety and type-safe Dart code across all modules
- Avoid dynamic types unless absolutely necessary
- Use strong typing to catch errors at compile time

### Performance Optimization

- Optimize build size, widget tree depth, and rendering performance
- Monitor jank (dropped frames) and fix performance issues
- Use const constructors where possible

### Theming

- Maintain consistent theming with shared design tokens
- Implement light and dark themes
- Use ThemeData and avoid hard-coded colors

### Offline Support

- Support offline mode and graceful error handling where possible
- Cache data locally for offline access
- Sync data when connectivity is restored

### Accessibility

- Follow Flutter's official accessibility guidelines
- Support screen readers (Semantics widgets)
- Test with TalkBack (Android) and VoiceOver (iOS)

### Testing and CI/CD

- Automate testing (unit, widget, and integration) in CI/CD workflows
- Run tests on every commit and before merges
- Use golden tests for visual regression testing

## Governance

### Constitution Authority

This constitution supersedes all other practices and conventions. When in doubt, refer to this document. All code reviews, pull requests, and architectural decisions must verify compliance with these principles.

### Amendment Process

Amendments to this constitution require:

1. Documented rationale for the change
2. Approval from project stakeholders
3. Migration plan if existing code is affected
4. Version increment (see Versioning Policy below)

### Versioning Policy

The constitution follows semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Backward incompatible governance changes, principle removals, or redefinitions
- **MINOR**: New principles, sections, or materially expanded guidance
- **PATCH**: Clarifications, wording fixes, typo corrections, non-semantic refinements

### Complexity Justification

Any deviation from these principles (e.g., violating DRY, adding excessive abstraction, using non-standard patterns) must be justified in writing with:

- The specific need that requires the exception
- Why simpler alternatives are insufficient
- Documented in the Complexity Tracking section of plan.md

### Compliance Review

- All pull requests must verify constitutional compliance
- Code reviews should explicitly check against relevant principles
- Architecture decisions should reference applicable principles

### Runtime Guidance

For runtime development guidance beyond this constitution, refer to project-specific documentation (e.g., quickstart.md, plan.md, research.md) generated during the specification and planning phases.

**Version**: 1.0.0 | **Ratified**: 2025-10-10 | **Last Amended**: 2025-10-10
