---
Last Reviewed: 2025-09-05
Tags: customer, engagement, discovery, listening, architecture
---
# Customer Engagement & Discovery

Practices for architects and engineers to actively listen to business partners, understand value from their perspective, and build durable trust and rapport.

## Why it matters
- Reduces misaligned solutions that solve symptoms, not root problems.
- Accelerates adoption because stakeholders feel heard and co-own outcomes.
- Surfaces latent constraints (compliance, data, process) early, lowering rework risk.

## Core principles
1. Seek to understand before proposing solutions.
2. Separate problem framing from solution exploration.
3. Make implicit assumptions explicit (write them down; validate).
4. Reflect and paraphrase to confirm understanding.
5. Map value in stakeholder terms (revenue, risk reduction, efficiency, experience).

## Engagement lifecycle
1. Preparation
2. Discovery conversations
3. Synthesis & validation
4. Option shaping
5. Decision capture (ADR / ARB)
6. Feedback & iteration

### 1. Preparation
- Review prior ADRs, tickets, metrics, and any existing process docs.
- Draft initial hypothesis: problem, impact, possible constraints (keep tentative).
- Identify stakeholders (primary users, sponsors, downstream/ops, risk owners).

### 2. Discovery conversations
Use open-ended prompts:
- "What outcome matters most in the next 6–12 months?"
- "What would ‘good’ look like if we solved this?"
- "What happens today when this process fails or is slow?"
- "Which metrics or reports do leadership watch here?"
- "What have you tried already? What worked / didn’t?"

Active listening techniques:
- Paraphrase: "What I’m hearing is... did I capture that?"
- Ladder down: ask for concrete examples & recent incidents.
- Note emotion + fact (frustration often signals hidden workflow friction).

### 3. Synthesis & validation
- Convert raw notes into: problem statement, current state summary, constraints, success metrics.
- Share a one-page recap within 24–48 hours for confirmation.
- Highlight explicitly what is NOT in scope yet (prevents scope creep early).

### 4. Option shaping
Frame 2–3 viable options with:
- Description & scope boundary.
- Benefits (mapped to stakeholder value dimensions).
- Risks / trade-offs.
- Effort & timeline rough order of magnitude.
- Dependencies & assumptions.

Use comparative language to keep choices clear (avoid false precision if data is weak).

### 5. Decision capture
- Use an [ADR](adr.md) for the selected option (or to defer with rationale).
- Route cross-cutting or high-risk decisions through the [ARB](arb.md) when needed.
- Link discovery summary and any evaluation artifacts (PoC, vendor matrix).

### 6. Feedback & iteration
- After initial delivery, schedule a short retrospective with business stakeholders.
- Validate: did projected value dimensions materialize? If not, why?
- Capture learnings to refine future discovery (update checklist/templates).

## Value mapping cheat sheet
| Value Theme | Example Questions | Example Metrics |
|-------------|-------------------|-----------------|
| Revenue / Growth | What increases conversion or upsell? | ARR impact %, conversion rate |
| Cost / Efficiency | What manual steps dominate time? | Hours saved / month, unit cost |
| Risk / Compliance | What audit findings recur? | # open findings, MTTR risk control |
| Reliability | What failure hurts most? | MTTR, incidents / quarter |
| Customer / User Experience | Where do users abandon? | NPS, CSAT, bounce rate |
| Velocity / Flow | What slows delivery? | Lead time, deployment frequency |

## Anti-patterns
- Jumping to a preferred tool/framework in the first meeting.
- Treating stakeholder quotes as validated facts (validate with data where possible).
- One-and-done interviews; no follow-up recap.
- Collecting requirements without probing "why" behind them.

## Lightweight artifacts
- Discovery notes (raw) → summarized recap.
- Problem statement & success metrics draft.
- Option comparison snippet (table or bullets).
- ADR referencing discovery; ARB link if escalated.
- Post-delivery value check-in notes.

## Suggested template snippet
```
Problem: <one sentence>
Stakeholders: <names / roles>
Success Metrics: <up to 3 quant / qual>
Constraints: <must/implicit>
Risks (early): <top 3>
Options (draft): <A,B,C one-liners>
Next Steps: <interviews, data pulls, PoC>
```

## Reading list (optional)
- Search terms: "active listening techniques", "value stream mapping", "Wardley mapping user needs" (use authoritative sources / books internally licensed).

---
Include: `../_footer.md`