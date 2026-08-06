Look for security vulnerabilities in newly written code so that we can fix them before the code is committed to main.
Below is a non-exhaustive list of reminders/preferences around certain security practices.

## Secret handling

Use env vars or secure config management for sensitive data. Never put literal secrets in code.
Secrets should only be stored encrypted. They should be encrypted in transit (HTTPS).

## Data exfiltration and redaction

Code that can touch production data should have restricted network access.
Production data should be redacted before being printed, logged, or otherwise leaving the code.

## Defense in depth

Consider how to add security at different boundaries and interfaces.

## Boundaries

Inputs, particularly dirctly from end users or untrused clients should be validated.
Use parameterized queries for database access.
Escape special characters in user-generated content before rendering it in HTML.
When generating output contexts such as HTML or SQL, use safe frameworks or encoding functions to avoid vulnerabilities. 

Always include appropriate security headers (Content Security Policy, X-Frame-Options, etc.) in web responses, and use frameworks’ built-in protections for cookies and sessions.

## Libraries

Evaluate the security posture of libraries before using them.
Consider whether we can use a small custom implementation of a few functions rather than a large library.
Prefer high-level libraries for cryptography rather than rolling your own.

Generate a Software Bill of Materials (SBOM) by using tools that support standard formats like SPDX or CycloneDX.

## Infrastructure

When adding important external resources (scripts, containers, etc.), include steps to verify integrity (like checksum verification or signature validation) if applicable. If running as a service, drop privileges when possible. When using containers, use minimal base images and avoid running containers with the root user.

## Version pinning

Pin dependency versions to immutable digests. Verify signatures.
