---
Last Reviewed: 2025-09-04
Tags: communication, stakeholders, architecture-elevator
---
# Architecture Elevator

The Architecture Elevator is a pattern for translating technical architecture decisions to non-technical stakeholders (executive level) and back to engineering teams. It helps maintain alignment and secures funding/approval.

Principles
- Two-way translation: have short elevator summaries for execs and a technical appendix for engineers.
- Focus on outcomes: describe business impact, risk, and ROI in the executive summary.
- Visuals: include a single-page architecture diagram for quick comprehension.
- Ask for decisions: be explicit about what you need from stakeholders (approval, budget, timeline).

Template
- One-line summary for executives.
- 3 bullets: impact, risk, ask.
- Technical appendix: diagrams, ADR links, PoC results, cost estimates.

Include: `../_footer.md`

## Table of contents

- [Principles](#principles)
- [Template](#template)
- [Personas and who to involve](#personas-and-who-to-involve)
- [Credits](#credits)

## Personas and who to involve

Effective architecture communication includes people from across delivery and operations. Below are common personas and how to involve them in the Architecture Elevator / ARB flow.

- Product Manager / Product Owner
	- Why include them: defines business goals, success metrics, and prioritization.
	- What they care about: time-to-market, user impact, ROI, customer risk.
	- How they contribute: shape the executive summary (impact & ask), provide prioritization trade-offs.

- Engineering Lead / Team Lead
	- Why include them: owns delivery plan and resource estimates.
	- What they care about: implementation effort, dependencies, team capability.
	- How they contribute: feasibility, sprint planning inputs, identify required PoC work.

- Platform / DevOps / SRE
	- Why include them: operational readiness, deployment, scaling, and observability requirements.
	- What they care about: deployment automation, runbook implications, cost and quotas, SLAs.
	- How they contribute: operational constraints, CI/CD requirements, runbook/monitoring acceptance criteria.

- Security / Compliance
	- Why include them: risk, compliance, data protection requirements.
	- What they care about: threat surface, encryption, access controls, auditability.
	- How they contribute: required controls, acceptance gates, compliance sign-off steps.

- UX / Research (when user-facing impact exists)
	- Why include them: user experience implications and adoption.
	- What they care about: latency, error states, user workflows, migration UX.
	- How they contribute: validation criteria, user-facing constraints for designs.

- Executives / Business Sponsors
	- Why include them: funding decision, strategic alignment, risk tolerance.
	- What they care about: business impact, ROI, timeline, strategic fit.
	- How they contribute: approval, budget, and advocacy across the organization.

Best practices for involving personas
- Invite the minimum set required to make the decision; use subject-matter experts for technical depth but keep the meeting focused.
- Prepare two artifacts: a one-line executive summary and a short technical appendix — offer the appendix in the meeting notes for reviewers who want depth.
- Assign an owner for follow-ups (typically the engineering lead or architect) and a product owner for business sign-off.


## Credits

This page and the "Architecture Elevator" pattern are inspired by the book "The Architecture Elevator" by Gregor Hohpe. The pattern and guidance here are adapted for concise internal guidance; please consult the original book for the full treatment.

- Author: Gregor Hohpe
- Book: The Architecture Elevator — O'Reilly Media: https://www.oreilly.com/library/view/the-architecture-elevator/9781492082858/
- Author site: https://www.gregorhohpe.com/
