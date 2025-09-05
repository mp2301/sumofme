---
Last Reviewed: 2025-09-05
Tags: vendor, selection, procurement, architecture
---
# Vendor Selection Framework

Structured guidance for evaluating and selecting a third‑party vendor or SaaS platform.

## Objectives
- Reduce bias and ad‑hoc decisions.
- Make trade‑offs explicit (cost, risk, capability, lock‑in).
- Ensure security, compliance, data, and exit concerns are addressed before commitment.

## Phases
1. Problem & outcome definition
2. Long list (market scan)
3. Short list (screening)
4. Deep evaluation (RFP / demos / PoC)
5. Decision & ADR
6. Contract & governance handoff

## 1. Problem & outcome definition
Capture: business objective, scope boundaries, success metrics, must/should/may requirements, timeline, sponsoring stakeholders.

## 2. Long list (market scan)
Sources: analyst reports, community references, existing contracts, OSS alternatives.
Eliminate: obviously non-compliant regions, unsupported platforms, misaligned licensing models.

## 3. Short list (screening)
Scoring dimensions (baseline weighting example):
- Core capability fit (25%)
- Integration & extensibility (15%)
- Security & compliance posture (15%)
- Total cost of ownership (15%)
- Operational model & SRE readiness (10%)
- Roadmap alignment / vendor viability (10%)
- Data portability & exit (5%)
- UX / adoption friction (5%)

Adjust weights per context; document any major deviation in the ADR.

## 4. Deep evaluation (RFP / demos / PoC)
Activities:
- Structured demo scripts focused on must-have scenarios.
- Lightweight PoC or sandbox validating integration, data flows, identity model, rate limits, performance envelope.
- Security questionnaire (standard baseline – link internal template if available).
- Data handling & residency confirmation; review breach notification terms.

Outputs:
- Scored comparison matrix with evidence (link to sheets / repo docs).
- Risk register (key technical, vendor, contractual risks + mitigations).

## 5. Decision & ADR
Summarize final scores, rationale for winner vs runner-up, major trade-offs, negotiated concessions. Capture as an [ADR](adr.md) and link from any related [ARB](arb.md) review notes.

## 6. Contract & governance handoff
Ensure ownership transitions from evaluation team to service owner:
- Named technical owner & business owner.
- Runbook draft (provisioning, monitoring, backup/export strategy).
- Access model (RBAC mapping, SSO integration plan).
- Data classification & retention alignment.
- Exit strategy (export formats, notice periods).

## Risk and lock-in assessment
Consider:
- Proprietary data formats or no bulk export.
- High switching or migration cost after initial adoption.
- Single-region service with latency / sovereignty concerns.
- Security feature gaps needing compensating controls.

Mitigation examples:
- Negotiate contractual export guarantees.
- Maintain abstraction layer or adapter pattern internally.
- Pilot with non-production data first; stage rollout.

## Metrics after adoption
- Adoption & active usage.
- SLA / SLO adherence & incident count.
- Cost vs forecast (monthly, trailing 3-month view).
- Support ticket volume & resolution time.
- Feature delivery vs roadmap expectations.

## When to re-evaluate
- Missed critical roadmap items by >2 quarters.
- Sustained SLA misses.
- 25%+ cost variance without value justification.
- Security incidents impacting trust.

## Lightweight artifacts checklist
- Problem statement & success metrics
- Requirements matrix (must/should/may)
- Scoring spreadsheet or table
- Security & compliance questionnaire results
- PoC findings (if performed)
- Risk register & mitigations
- ADR documenting decision
- Onboarding/runbook & ownership record

## Quick reference decision triggers
Use this vendor selection framework when:
- Annual spend is material (threshold set by finance / procurement policy).
- Service handles regulated or sensitive data classes.
- Impacts cross-team platform or security posture.

If spend and risk are low, a simplified build vs buy assessment may be enough (see the [Build vs Buy](build-vs-buy.md) page).

---
Include: `../_footer.md`