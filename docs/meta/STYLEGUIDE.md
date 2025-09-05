---
Last Reviewed: 2025-09-04
Tags: meta, governance, style
---
# Documentation Style Guide

## Front Matter
Each Markdown file MUST begin with YAML front matter:
```
---
Last Reviewed: YYYY-MM-DD
Tags: tag-one, tag-two, domain-keyword
---
```
Rules:
- Last Reviewed date updates ONLY when a human meaningfully re-validates the page.
- Tags: 3â€“8 concise labels; include at least one domain (identity, network, shared, runbook, monitoring, hardening, governance).

## Headings
- Single H1 (`# Title`) per page matching filename (kebab to Title Case).
- Use sentence case for section headings (H2+).

## Lists
- Prefer ordered lists for stepwise procedures (runbooks).
- Keep bullets to max 2 lines; use sub-bullets for detail.

## Runbook Template (Required Sections)
1. Purpose
2. Preconditions / Signals
3. Severity & Escalation
4. Rapid Triage
5. Containment
6. Remediation
7. Validation & Recovery
8. Post-Incident Actions
9. Metrics & Thresholds
10. RACI Table
11. References (all links MUST resolve)

## Link Policy
- NO bare URLsâ€”use descriptive text.
- External links validated by automation weekly.
- Internal relative links must not traverse above `docs/` root (`../` outside docs is forbidden).

## Glossary Backlinks
- First use of a defined term links to glossary entry.

## Code & Config Blocks
- Specify language fences (```powershell, ```bash, ```json). Omit trailing spaces.

## Change Control Commit Conventions
Format: `migrate(identity): fundamentals batch 1` or `content(network): add nsg flow log tuning`.
Prefixes:
- migrate(domain)
- content(domain)
- fix(domain)
- chore(meta)

## Lint Expectations (Future Automation)
- Check: front matter schema, required runbook sections, link health, stale >180 days.

---
Return to [Root README](../../README.md)

---
Include: `../_footer.md`

