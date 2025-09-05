---
Last Reviewed: 2025-09-04
Tags: adr, architecture, decision
---
# Architecture Decision Records (ADR)

ADRs are short, versioned documents that capture important architecture decisions, context, options considered, and the chosen approach. They provide traceability, enable onboarding, and reduce repetition. Cross-cutting decisions typically surface via the [Architectural Review Board (ARB)](arb.md); the ARB process produces or updates ADRs to preserve rationale.

## Table of contents

- [What is an ADR?](#what-is-an-adr)
- [ADR Index (folder listing)](adr/_index.md)
- [Why use ADRs?](#why-use-adrs)
- [Practical implementation within an architecture practice](#practical-implementation-within-an-architecture-practice)
- [Personas and ADR users](#personas-and-adr-users)
- [Use cases](#use-cases)
- [Template & helper](#template--helper)
- [Governance suggestion (lightweight CI check)](#governance-suggestion-lightweight-ci-check)
- [Tips](#tips)

## What is an ADR?

An Architecture Decision Record (ADR) is a concise, versioned document that captures a single important architecture decision: why it was made, the options considered, the chosen approach, and the consequences. ADRs are lightweight living artifacts that provide historical context and help new team members understand why systems look the way they do.

> Quick link: See the live ADR list in this folder at [ADR Index](adr/_index.md).

## Why use ADRs?

- Preserve decision rationale so teams don't have to rediscover why things were chosen.
- Improve onboarding by exposing architecture history.
- Reduce rework and debate by making trade-offs explicit.
- Provide inputs for regulatory or auditing needs when architecture decisions affect compliance.

## Information to capture in an ADR
- Title and short description
- Status (proposed / accepted / superseded / deprecated)
- Context and problem statement
- Options considered (short pros/cons for each)
- Decision (what is chosen) and justification
- Consequences & follow-ups (operational impacts, migration, owners)
- Links to diagrams, PoC repos, tickets, and ADRs that are superseded or related

## Practical implementation within an architecture practice
(assuming below that team use widly used ADR solution https://github.com/npryce/adr-tools)

1. Where to store ADRs
- Keep ADRs in the repository under `docs/enterprise/architecture/` (or an `adr/` subfolder) so they are versioned, discoverable, and reviewed with code/docs. A template and helper is included in the script in this folder to make creation consistent.

2. Naming convention
- Use `YYYY-MM-DD-short-title.md`. The date should correspond to when the ADR was created or accepted.

3. Creating an ADR (proposal)
- Use the `adr-template.md` and the `create-adr.ps1` helper to create a new draft.
- Fill the Context, Options, and proposed Decision sections. Keep the draft short Ã¢â‚¬â€ 1 page where possible.

4. Review & acceptance workflow
- Link the ADR in the [ARB](arb.md) meeting agenda when a cross-team decision is required. For small-scope decisions, a peer review (1-2 reviewers) is sufficient.
- Reviews should focus on constraints, alternatives, and operational consequences rather than implementation nitpicks.
- Record the outcome: update Status to `accepted` and note the approver (person or group) and date.

5. Integration with PoCs and ARB
- If a decision relies on a PoC, attach PoC results, links to the repo, and short runbook as evidence for the decision.
- Use the [ARB](arb.md) to resolve large cross-cutting decisions and to surface high-risk items; ARB decisions should result in ADRs or references to existing ADRs.

6. Lifecycle and evolution
- When conditions change or better options arise, create a new ADR that supersedes the previous one. Link back to the superseded ADR and mark its status accordingly.

7. Ownership and discoverability
- Each ADR should list an owner (team or person) responsible for monitoring consequences and updating the ADR if needed.
- Maintain a short index or use `_index.md` to make ADRs discoverable from the Architecture index page.

## Personas and ADR users

ADRs are used by a variety of people across product, engineering and operations. When you write an ADR, think about who will consume it and what they need to take action.

- Architect / Principal Engineer
  - Why: authorship or technical owner of a decision; keeps the big-picture system view.
  - What they need from ADRs: clear problem statement, alternatives considered, trade-offs, constraints, and the technical rationale.
  - How they use ADRs: to record intent, onboard new engineers, and refer back during design reviews.

- Product Manager / Product Owner
  - Why: owns business goals and prioritisation.
  - What they need from ADRs: concise executive summary, business impact, user-facing trade-offs, and acceptance criteria.
  - How they use ADRs: to decide whether the choice meets product objectives and to prioritise roadmap work.

- Engineering Lead / Developer
  - Why: implements the decision and estimates effort.
  - What they need from ADRs: implementation guidance, known risks, migration strategy and required PoC work.
  - How they use ADRs: to plan sprints, implement the selected alternative, and create tasks.

- Platform / DevOps / SRE
  - Why: ensures operational readiness, deployments and SLAs are feasible.
  - What they need from ADRs: deployment constraints, monitoring/runbook requirements, scaling implications and cost considerations.
  - How they use ADRs: to shape CI/CD pipelines, operational playbooks, and capacity planning.

- Security / Compliance
  - Why: validates that choices meet security and regulatory requirements.
  - What they need from ADRs: threat model notes, data handling, access controls, and auditability requirements.
  - How they use ADRs: to add acceptance gates, remediation steps and to record compliance sign-off.

- QA / Test Engineers
  - Why: verify the decision preserves quality and reliability.
  - What they need from ADRs: testing boundaries, failure modes, and non-functional requirements.
  - How they use ADRs: to design test plans and automated checks.

- UX / Design (when relevant)
  - Why: assess user-facing impacts and migration UX.
  - What they need from ADRs: user impact summary, migration UX considerations, and rollback plans.
  - How they use ADRs: to design user flows or flag unacceptable UX trade-offs.

- Executive Sponsor / Business Stakeholder
  - Why: provides strategic approval and funding.
  - What they need from ADRs: one-line summary, ROI, timeline and risk summary.
  - How they use ADRs: to approve investments and champion cross-team alignment.

## Use cases

ADRs are useful for many decision types. Below are common scenarios and what an ADR should capture for each.

- Technology selection (e.g., database, framework, message bus)
  - Capture: evaluation criteria, PoC results, long-term maintenance and licensing implications, migration costs.
  - Stakeholders: Architect, Engineering Lead, Product, Security.

- Integration patterns and APIs
  - Capture: contracts, compatibility expectations, versioning strategy, and backward-compatibility rules.
  - Stakeholders: Architects, Developers, API Consumers, QA.

- Security controls and data classification
  - Capture: risk assessment, required controls, encryption, key management, logging and retention.
  - Stakeholders: Security, Compliance, Platform.

- Operational model (deployment topology, multi-region strategy)
  - Capture: failover model, monitoring & alerting, runbooks, cost vs. availability trade-offs.
  - Stakeholders: Platform/SRE, Engineering, Product.

- Build vs Buy or vendor selection
  - Capture: cost comparison, support model, customisation limits, exit strategy.
  - Stakeholders: Product, Architects, Procurement, Legal.

- Major schema or data-model changes
  - Capture: migration plan, data validation, rollback plan, long-running migration concerns.
  - Stakeholders: Data Engineers, Architects, QA, Product.

- API/Contract versioning and deprecation policies
  - Capture: migration windows, consumer communication plan, compatibility guarantees.
  - Stakeholders: API Owners, Consumers, Product, Documentation teams.

Best practice note: tag ADRs with the primary persona(s) who should review or sign off, and include a short "acceptance criteria" section so reviewers from different functions can quickly confirm their concerns are addressed.

## Template & helper
- We include a small ADR template (`adr-template.md`) and a helper script `create-adr.ps1` in this folder to create new ADRs with the correct filename and basic frontmatter.

## Governance suggestion (lightweight CI check)

- Add a small CI check that warns when new ADR files do not follow the `YYYY-MM-DD-*.md` pattern or are missing required frontmatter fields (Title, Status, Owner). This keeps the ADR corpus consistent without blocking work.


## Tips
- Keep ADRs small (1 page when possible).
- Create ADRs early for cross-team-impacting decisions.
- Use a simple filename convention: YYYY-MM-DD-title.md

Example (from repo root PowerShell):

```powershell
cd docs/enterprise/architecture
.\create-adr.ps1 -Title "Choose message bus for telemetry"
```

Include: `../_footer.md`





