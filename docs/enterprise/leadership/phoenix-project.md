---
Last Reviewed: 2025-09-04
Tags: leadership, devops, book, phoenix-project
---
# The Phoenix Project — practical lessons for engineering leadership

Purpose
- Summarise key lessons from *The Phoenix Project* and provide a small facilitation guide to run a book-club or team playbook session.

Short summary
- *The Phoenix Project* (Gene Kim, Kevin Behr, George Spafford) is a fictional story that illustrates DevOps principles through the lens of rescuing a troubled IT project.
- The book introduces the Three Ways (Flow, Feedback, Continual Learning) and highlights the importance of visible work, reducing batch size, and prioritising business value.

## Quick TOC

- [Purpose](#purpose)
- [Short summary](#short-summary)
- [Key ideas and how they map to practice](#key-ideas-and-how-they-map-to-practice)
  - [The Three Ways](#the-three-ways)
- [Types of work](#types-of-work)
- [Visible work and kanban](#visible-work-and-kanban)
- [Deployment & automation](#deployment--automation)
- [Operational readiness](#operational-readiness)
- [Discussion questions](#discussion-questions)
- [Character: Brent — role and lessons](#character-brent--role-and-lessons)
- [Action checklist for leaders](#action-checklist-for-leaders)
- [Further reading](#further-reading)

Key ideas and how they map to practice

- The Three Ways
  - Flow: make work flow from development to operations; visualise queues and reduce handoffs.
  - Feedback: create fast feedback loops (automated tests, monitoring, and early validation).
  - Continual Learning & Experimentation: create a culture that tolerates safe-to-fail experiments and learns fast.

- Types of work
  - Business projects (features), Internal projects (infrastructure), and Unplanned work (incidents).
  - Keep unplanned work visible; treat it as a signal to improve processes.

- Visible work and kanban
  - Use a team board that shows WIP, blockers, and cycle times.
  - Limit WIP and address long-lived items with a root-cause approach.

- Deployment & automation
  - Invest in CI/CD, automated testing, infra-as-code, and small frequent releases.

- Operational readiness
  - Define service ownership, runbooks, and SLOs; practice incident response with blameless postmortems.

Discussion questions
- Where are our biggest queues and handoffs? How do we visualise them today?
- What is unplanned work telling us about our processes?
- Which small automation could unblock our fastest feedback loop?

Character: Brent — role and lessons

Brent is the (satirical) archetype of an overworked operations manager in *The Phoenix Project*. He holds institutional knowledge, controls key access, and becomes a single point of coordination for many recovery and delivery activities. While the book uses his character for humour, Brent's role highlights important organisational risks and opportunities:

- Single point of knowledge: Brent demonstrates how critical tribal knowledge is often concentrated in a few people. Lesson: invest in documentation, runbooks, and cross-training to avoid bus-factor risk.
- Operational friction: Brent's workload shows how ad-hoc requests and firefighting block long-term improvements. Lesson: reduce unplanned work by improving flow, visibility, and prioritisation.
- The value of practical expertise: Brent's deep familiarity with systems is essential during incidents. Lesson: recognise and reward operational skills and create career paths that value reliability and operational excellence.
- Empowerment and tooling: Brent often solves problems manually. Lesson: invest in automation and safer self-service tools so operational tasks are repeatable and less error-prone.

Action checklist for leaders
- Sponsor one cross-team experiment that reduces lead time.
- Fund a small automation PoC (CI/CD or infra-as-code) with metrics to measure impact.
- Run blameless retros for incidents and track systemic actions.

Further reading
- The DevOps Handbook (Gene Kim et al.)
- Accelerate (Nicole Forsgren, Jez Humble, Gene Kim)

Include: `../_footer.md`



