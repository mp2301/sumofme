---
Last Reviewed: 2025-09-05
Tags: build, buy, procurement, architecture, decision
---
# Build vs Buy

Structured evaluation for deciding whether to build a solution internally or acquire (buy) a commercial / SaaS / open-source option. For deep multi-vendor due diligence, see the [Vendor Selection Framework](vendor-selection.md). Record the final decision as an [ADR](adr.md); use a [PoC](poc.md) or a [Bootstrap Workshop](bootstrap-workshop.md) when accelerated technical validation is needed. Early business context should come from effective [Customer Engagement & Discovery](customer-engagement.md).

## When to run a Build vs Buy assessment
Run this assessment when the initiative:
- Represents meaningful spend (engineering capacity or licensing) beyond a trivial prototype.
- Touches core workflows, regulated data, or cross-team integration boundaries.
- Could become a strategic differentiator OR is likely a commodity (need to classify which).

Skip or streamline if:
- The capability is already clearly commodity and an existing approved tool covers the need.
- It’s an experimental spike preceding a formal evaluation (document as a small PoC first).

## Decision drivers (expanded checklist)
- Requirements clarity & stability (are core needs well understood?).
- Time to market / opportunity cost (delay cost vs. cost to implement).
- Strategic differentiation (would building create defensible IP or unique capability?).
- Total cost of ownership (engineering build + maintenance + infra + support + depreciation of tooling) vs subscription/license & vendor management effort.
- Integration complexity (APIs, auth models, data pipelines, identity mapping, eventing).
- Security & compliance (data residency, encryption features, access controls, audit trails, certifications).
- Operational maturity (SLAs, SLOs, DR, monitoring, support responsiveness, roadmap transparency).
- Vendor lock-in risk (data portability, proprietary interfaces, migration cost, multi-region availability).
- Talent & skill availability (can we staff & retain required expertise sustainably?).
- Ecosystem & extensibility (plugin model, API surface, community support, SDK quality).

## Quick heuristic matrix
| Factor | Lean Build If | Lean Buy If |
|--------|----------------|-------------|
| Differentiation | Core to value prop | Commodity / supporting |
| Time to market | Moderate runway | Urgent competitive / regulatory deadline |
| Internal expertise | Strong & available | Scarce / hiring risk |
| Feature evolution | Needs rapid tailored change | Stable, commoditized scope |
| TCO 3+ years | Clear cost advantage emerging | Vendor cost predictable & lower |
| Lock-in risk | OSS / standards available | Proprietary but acceptable exit plan |
| Security posture | We can exceed market | Vendor provides higher baseline |

## Process flow
1. Discovery & problem framing (see [Customer Engagement](customer-engagement.md)).
2. Minimal option list: Build, Buy (could be multiple vendor variants), Hybrid.
3. Define evaluation criteria & weighting (align with Vendor Selection if expanded).
4. Evidence gathering: demos, vendor docs, internal effort estimates, small [PoC](poc.md).
5. Option scoring & narrative (qualitative + quantitative where possible).
6. Draft ADR with decision rationale, trade-offs, follow-ups.
7. Review via peer review or escalate to [ARB](arb.md) if cross-cutting.
8. Execute / contract or backlog build tasks; track outcome metrics.

## Evidence & artifacts
- Comparative cost model (engineering FTE estimates vs subscription + infra + hidden costs).
- High-level architecture deltas (build option integration vs vendor integration path).
- Risk register (security, delivery, vendor viability, migration risk, operability).
- Performance / scale assumption notes (validated via PoC or vendor SLAs).
- Data portability & exit plan notes (export formats, escrow, alternative paths).

## Sample lightweight scoring table
| Criterion | Weight | Build Score (1–5) | Buy Score (1–5) | Notes |
|-----------|--------|-------------------|-----------------|-------|
| Strategic Differentiation | 0.20 | 5 | 2 | Building creates proprietary analytics IP |
| Time to Market | 0.15 | 2 | 5 | Vendor can be live in 4 weeks |
| TCO (3-yr) | 0.15 | 3 | 4 | Slight vendor cost advantage |
| Integration Complexity | 0.10 | 3 | 4 | Vendor has native connectors |
| Security & Compliance | 0.10 | 4 | 4 | Both meet baseline; build offers finer-grain logging |
| Talent Availability | 0.10 | 4 | 3 | Team has domain expertise |
| Extensibility | 0.10 | 5 | 3 | Internal roadmap needs tailoring |
| Lock-in Risk | 0.05 | 4 | 2 | Vendor proprietary schema |
| Operational Maturity | 0.05 | 2 | 5 | Vendor has 99.9% historical SLA |
| Vendor Viability / Roadmap | 0.05 | n/a | 4 | Vendor stable & transparent |
| Total | 1.00 | 3.75 (weighted) | 3.55 (weighted) | Example only |

> **Important – Interpret Scores Carefully**  
> The table is a decision aid, not an algorithm. Use scores directionally; the written narrative, explicit trade-offs, and documented assumptions matter more than arithmetic differences in weighted totals.

## Common pitfalls & mitigations
| Pitfall | Mitigation |
|---------|------------|
| Over-engineering scorecard with false precision | Limit to top 8–12 criteria; round weights; focus on rationale. |
| Ignoring long-term maintenance burden | Include sustaining engineering + upgrade effort in TCO. |
| Lock-in underestimated | Explicitly document exit path & switching triggers. |
| Building undifferentiated commodity | Validate differentiation claim with product leadership. |
| Under-scoped security assessment | Engage security early; reuse controls checklist. |

## Follow-up after decision
- Track 2–3 success metrics (e.g., adoption %, cycle time reduction, cost vs forecast).
- Reassess build/buy choice if assumptions (cost, growth, vendor roadmap) materially drift.
- If Buy: ensure contract includes data export & performance clauses; add to risk register.
- If Build: schedule architecture checkpoint (ARB) at major maturity milestone.

## Related guidance
- [Customer Engagement & Discovery](customer-engagement.md)
- [Vendor Selection Framework](vendor-selection.md)
- [Bootstrap Workshop Model](bootstrap-workshop.md)
- [Proof of Concept guidance](poc.md)
- [Architecture Decision Records (ADR)](adr.md)
- [Architectural Review Board (ARB)](arb.md)

## ADR linkage
Final choice MUST be captured as an [ADR](adr.md) including:
- Problem & context summary (link to discovery notes).
- Options considered (include Build + each Vendor variant even if rejected early).
- Decision rationale & key trade-offs.
- Assumptions & measurable success criteria.
- Revisit triggers (what would cause reconsideration?).

## Optional template snippet
```
Context: <problem summary + strategic importance>
Options: <Build | Vendor A | Vendor B | Hybrid>
Criteria & Weights: <table ref or inline summary>
Decision: <chosen option>
Rationale: <why this over next best>
Assumptions: <key cost / adoption / performance>
Risks & Mitigations: <top 3>
Exit / Revisit Triggers: <conditions to re-evaluate>
Success Metrics: <up to 3>
```

## Escalation guidance
Escalate to the [ARB](arb.md) if:
- Cross-domain impact (security + data + platform) is significant.
- Spend or strategic importance exceeds threshold policy.
- Decision reversibility is low and risk of lock-in is high.

Otherwise, peer review + ADR suffices.

Include: `../_footer.md`
