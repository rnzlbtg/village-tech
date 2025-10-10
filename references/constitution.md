Development Constitution

Core Philosophy

- Intent-first development (understand why before building how)
- Specification-driven workflow (no implementation without an approved spec)
- Build for clarity, consistency, and maintainability
- Quality and correctness take precedence over speed
- Every change must be traceable from spec → plan → task → code → test

Code Standards

- Follow consistent naming conventions (PascalCase for classes, snake_case for files)
- Keep functions small, single-purpose, and readable
- Avoid duplication – follow the DRY principle
- Prefer explicit logic over clever abstractions
- Maintain consistent code formatting and linting rules
- Write self-documenting code; minimize unnecessary comments

Architecture

- Follow modular, layered architecture (UI → Application → Domain → Infrastructure)
- Keep dependencies explicit; avoid circular imports or hidden coupling
- Encapsulate business logic in the domain layer, not the UI
- Use clear boundaries between internal and external APIs
- Design for scalability, observability, and testability from day one

Security and Privacy

- Sanitize all user input and validate data before processing
- Use secure defaults for authentication, encryption, and storage
- Never log sensitive information (e.g., credentials, tokens, PII)
- Follow least-privilege principles in permissions and data access
- Regularly review dependencies for known vulnerabilities

UX and Design Principles

- Accessibility first (WCAG 2.1 AA compliance minimum)
- Maintain color contrast ratio of at least 4.5:1
- Mobile-first, responsive layouts
- Use a responsive grid system and consistent breakpoints
- Maintain usability and visual clarity across all devices
- Clear visual hierarchy, minimalism, and readable typography
- Use minimal colors and sufficient whitespace
- Maintain visual balance and rhythm across UI components
- Use design tokens (spacing, color, typography) for consistency
- Avoid hard-coded color or size values
- Include dark mode support
- Apply the golden ratio (1:1.618) where possible for spacing, typography, and layout proportions
- Only use icons from the provided library or package
- Icons should align visually with text and follow consistent stroke weight and grid sizing

Performance

- Optimize for readability first, then for speed
- Measure performance using metrics before optimizing
- Ensure API responses are under target latency (e.g., < 200 ms)
- Use caching and lazy loading responsibly
- Prevent unnecessary computation, rendering, or data fetching

Error Handling and Logging

- Use structured, descriptive error messages with consistent codes
- Catch and handle errors gracefully; never expose raw stack traces
- Log meaningful events only – avoid noise
- Use correlation IDs to trace user and system events
- Treat warnings as early indicators of failure, not ignorable noise

Testing

- Write tests for all critical paths and new features
- Maintain at least 80% test coverage per module
- Prefer unit tests for logic, integration tests for interaction, and end-to-end tests for flows
- Tests must be deterministic and independent

Documentation

- Every module must include a brief purpose and usage note
- Public APIs require inline docstrings and examples
- Update README or architecture docs when structural changes occur
- Document assumptions, edge cases, and known limitations

Refactoring and Maintenance

- Remove dead code, unused dependencies, and obsolete comments
- Prioritize fixing technical debt before adding new features
- Maintain backward compatibility unless deprecation is approved

Mobile (Flutter) Principles

- Follow clean architecture and MVVM or BLoC pattern for maintainability.
- Ensure cross-platform consistency between iOS, Android, and web builds.
- Use responsive and adaptive layouts for various screen sizes.
- Apply state management best practices (e.g., Riverpod, Provider, Bloc).
- Implement null safety and type-safe Dart code across all modules.
- Optimize build size, widget tree depth, and rendering performance.
- Maintain consistent theming with shared design tokens.
- Support offline mode and graceful error handling where possible.
- Follow Flutter’s official accessibility guidelines.
- Automate testing (unit, widget, and integration) in CI/CD workflows.
