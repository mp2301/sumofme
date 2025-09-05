---
Last Reviewed: 2025-09-05
Tags: bootstrap, workshop, acceleration, architecture, security, enablement
---
# Bootstrap Workshop Model

An intensive, time‑boxed collaborative workshop that accelerates product or platform initiation by combining discovery, rapid architecture design, security engagement, engineering scaffolding, and enablement. Often co-delivered with vendor engineers plus internal cross-functional teams (architecture, security, platform, product).

## Goals
- Collapse months of fragmented meetings into a focused, outcome-driven sprint.
- Produce validated architecture options and initial decisions (captured as [ADRs](adr.md)).
- Stand up foundational scaffolding (repos, CI/CD pipelines, environment baselines).
- Embed security & compliance requirements early (shift-left risk reduction).
- Transfer knowledge so internal teams can maintain momentum post-workshop.

## When to use
Use a Bootstrap Workshop when:
- New strategic product, platform capability, or migration is starting.
- Multiple vendors / technologies must be evaluated quickly.
- There is executive urgency but ambiguous requirements.
- High security / compliance impact needs early alignment.

Avoid when:
- Scope is narrow enough for a normal sprint spike.
- Stakeholders or required SMEs are not available for focused participation.

## Participants & roles
| Role | Responsibility |
|------|----------------|
| Facilitator (Architecture) | Orchestrates agenda, timeboxing, decision capture. |
| Product Owner / Sponsor | Business goals, success criteria, priority calls. |
| Lead Engineer(s) | Feasibility, scaffolding, prototype implementation. |
| Security / Compliance | Threat modeling, control mapping, data classification. |
| Platform / SRE | Operational model, environments, observability, cost. |
| Vendor Engineers | Deep product expertise, best practices, feature clarity. |
| Data / Analytics (if applicable) | Data flows, schemas, retention, quality gates. |

## Cadence & structure (example 5-day model)
| Day | Focus | Key Outputs |
|-----|-------|-------------|
| 0 (Prep) | Logistics, repo seeds, baseline context deck | Agenda, participants confirmed, baseline ADR shells |
| 1 | Problem framing & value mapping | Validated problem statement, success metrics, context ADR draft |
| 2 | Architecture option shaping & threat modeling | Option matrix, risks, preliminary threat model notes |
| 3 | Prototype / scaffolding & security control alignment | Running skeleton service/app, CI pipeline, control checklist |
| 4 | Decision convergence & backlog seeding | Accepted ADR(s), initial backlog, dependency & risk register |
| 5 (Optional) | Vendor deep dives / stretch objectives | Additional ADRs (if any), refined roadmap |

Adjust length (3–7 days) based on complexity and stakeholder availability.

## Core artifacts
- ADRs (one per significant decision; fast decisions still recorded).
- Option comparison table (include build vs buy / vendor selection links if relevant).
- Threat model summary & initial mitigations.
- Architecture diagram(s) (context + logical + deployment if time).
- Repo(s) with baseline structure: README, licensing, CI workflow, lint/test harness.
- Backlog seeds (epics, top 10 stories).
- Risk & dependency register.

## Decision capture discipline
- Use lightweight ADR shells pre-created (title, context placeholders) to encourage same-day completion.
- Tag ADRs with `workshop` for traceability.
- For deferred decisions, create ADR with Status `pending` + explicit unblocker criteria.

## Security integration
- Perform quick threat modeling (STRIDE or similar) on Day 2 while options are still fluid.
- Identify data classification & required controls early (encryption, logging, access boundaries).
- Capture control mapping gaps with owners & target dates.

## Engineering scaffolding checklist
- Repo created (naming aligned to standards).
- CI pipeline: build, test, lint, security scan job placeholders.
- Base service template (framework, health endpoint, logging baseline).
- Environment config strategy (12-factor alignment, secret management plan).
- Observability seeds (metrics & log structure agreed; tracing optional if time).

## Agenda facilitation tips
- Timebox relentlessly—defer deep dives to side sessions.
- Start each morning with recap + decisions captured + outstanding risks.
- Maintain a visible Kanban of "In Discussion / Decided / Deferred" decisions.
- Keep vendor demos focused on workshop objectives, not generic sales decks.

## Measuring success
- % of targeted ADRs completed & accepted.
- Prototype / scaffolding completeness (subjective: ready to extend?).
- Stakeholder confidence (fast pulse survey: clarity, alignment, momentum).
- Time from workshop end to first production or PoC milestone.

## Common pitfalls & mitigations
| Pitfall | Mitigation |
|---------|------------|
| Unbounded scope creep | Daily scope check; parking lot for out-of-scope ideas. |
| Decision fatigue | Limit major decisions to 3–5 per day; rotate presenters. |
| Vendor over-index | Anchor to objective criteria & ADR format, not feature marketing. |
| Security bolted-on last minute | Embed security lead from Day 1; add control checklist early. |
| Artifacts not finished | Allocate final afternoon for ADR completion & backlog grooming. |

## Exit criteria definition (example)
Success when:
- All critical architecture decisions documented (ADRs merged / accepted).
- Prototype runs in CI with green baseline pipeline.
- Threat model & top 5 risks logged with owners.
- Backlog prioritized for next 2 sprints.
- Ownership & next governance touchpoint (e.g., ARB review) scheduled.

## Related guidance
- [Architecture Decision Records (ADR)](adr.md)
- [Architectural Review Board (ARB)](arb.md)
- [Proof of Concept guidance](poc.md)
- [Build vs Buy](build-vs-buy.md)
- [Vendor Selection Framework](vendor-selection.md)
- [Customer Engagement & Discovery](customer-engagement.md)

---
Include: `../_footer.md`