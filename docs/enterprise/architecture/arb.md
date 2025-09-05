---
Last Reviewed: 2025-09-04
Tags: arb, governance, architecture
---
# Architectural Review Board (ARB)

This page describes a lightweight ARB setup and recommended practices for reviewing architecture proposals, [ADRs](adr.md), and PoC outcomes. For how to capture and version architecture decisions, see the [Architecture Decision Records (ADR) guidance](adr.md).

## Table of contents

- [Purpose](#purpose)
- [Members & roles](#members--roles)
- [Meeting cadence & format](#meeting-cadence--format)
- [Submission requirements](#submission-requirements)
- [Decision recording and follow-up](#decision-recording-and-follow-up)
- [Practical tips](#practical-tips)

Purpose
- Provide rapid, pragmatic architectural guidance for cross-cutting changes.
- Avoid organizational bottlenecks by keeping reviews timeboxed and decision-focused.

Members & roles
- Chair: rotating senior architect or engineering lead who organizes reviews and tracks actions.
- Core members: representatives from platform, security, networking, and a product owner.
- Subject matter experts: invited as needed for specific topics.

Meeting cadence & format
- Weekly or bi-weekly 30-60 minute slots depending on intake volume.
- Use a short agenda: 5-minute context, 15-minute presentation, 10–20 minute Q&A and decision.
- Decisions: Approved, Approved with conditions, Deferred (needs more info), Rejected.

Submission requirements
- One-page summary (Architecture Elevator executive summary)
- [ADR](adr.md) draft or PoC results attached
- Clear ask: decision required, timeline, and impact

Decision recording and follow-up
- Record decisions as [ADRs](adr.md) and link to the ARB meeting notes.
- Track action items in a lightweight tracker (issue, board, or a shared doc) with owners and due dates.

Practical tips
- Encourage pre-reads: share materials 48 hours in advance.
- Timebox reviews: push deep design back to an engineering design review with engineers.
- Use the ARB for cross-team alignment and risk awareness rather than micromanagement.

Include: `../_footer.md`
