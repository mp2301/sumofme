---
Last Reviewed: 2025-09-04
Tags: chatgpt, generative-ai

## TLDR and starter checklist

TLDR: Use enterprise-managed ChatGPT or API-based integrations for production and RAG systems; keep consumer accounts for low-risk exploration only. Treat prompts and retrieval stores as sensitive assets and apply access, logging and retention controls.

Starter checklist for a pilot (quick wins):

- Classify the data your pilot will touch (sensitive / regulated / public).
- Choose offering: consumer for exploration, enterprise or API for production.
- Implement input filters to redact PII and set up central logging for prompts/outputs (if allowed).
- Define a human-in-the-loop approval point and an incident contact.
- Run a short safety test suite (5 prompts) and an initial hallucination/regression check.

---
Last Reviewed: 2025-09-04
Tags: chatgpt, generative-ai
---

# OpenAI & ChatGPT

High-level guidance for using ChatGPT and other generative AI tools responsibly in enterprise contexts: data handling, prompt engineering, rate limits, and acceptable use.

## Quick TOC

- [TL;DR & Starter checklist](#tldr--starter-checklist)
- [Topics](#topics)
	- [Data privacy and PII handling](#data-privacy-and-pii-handling)
	- [Prompt engineering and reuse](#prompt-engineering-and-reuse)
	- [Human-in-the-loop verification](#human-in-the-loop-verification)
	- [API usage vs hosted services](#api-usage-vs-hosted-services)
- [Why provide an enterprise ChatGPT service?](#why-provide-an-enterprise-chatgpt-service)
- [ChatGPT offerings and typical use cases](#chatgpt-offerings-and-typical-use-cases)
- [How to choose](#how-to-choose)
- [OpenAI / provider feature catalog & enterprise use cases](#openai--provider-feature-catalog--enterprise-use-cases)
- [Secure RAG sketch (ASCII)](#secure-rag-sketch-ascii)
- [Hard rules (do not bypass)](#hard-rules-do-not-bypass)

---

## TL;DR & Starter checklist

TL;DR: Use enterprise-managed ChatGPT or API-based integrations for production and RAG systems; keep consumer accounts for low-risk exploration only. Treat prompts and retrieval stores as sensitive assets and apply access, logging and retention controls.

Starter checklist for a pilot (quick wins):

- Classify the data your pilot will touch (sensitive / regulated / public).
- Choose offering: consumer for exploration, enterprise or API for production.
- Implement input filters to redact PII and set up central logging for prompts/outputs (if allowed).
- Define a human-in-the-loop approval point and an incident contact.
- Run a short safety test suite (5 prompts) and an initial hallucination/regression check.

---

## Topics

### Data privacy and PII handling

Enterprises must treat any conversational data as potentially sensitive. Key controls include input filtering (redacting PII before it is sent to a model), enforced data classification rules that prevent certain categories from leaving corporate boundaries, and centralized logging with access controls and retention policies. For RAG or vector stores, ensure the retrieval layer does not persist raw user inputs and that vector data is encrypted at rest. When possible, use pseudonymisation or tokenisation and support legal processes (e.g., data subject requests and legal holds).

Operational points:

- Maintain a denylist policy for sending customer-identifiable data to public models.
- Log prompts and model responses only when required; protect logs with the same controls as other sensitive telemetry.
- Include deletion workflows in vendor contracts and document retention expectations.

### Prompt engineering and reuse

Treat prompts as product assets: version them, store them in a searchable repo, and test them against representative inputs. Use templates for common tasks (summaries, extraction, classification) and parameterize them so minimal dynamic data is injected. Encourage teams to author prompt tests (expected outputs, edge cases) and run them as part of CI when prompts are used in production flows.

Practical guidance:

- Provide a small library of canonical prompt templates and record who owns each template.
- Use system messages to consistently set role, tone and safety constraints for chat-style models.
- Track prompt provenance (who edited, when, and what model was used) for auditability.

### Human-in-the-loop verification

LLMs are useful but fallible. Define where a human must review or approve outputs (financial actions, HR decisions, anything legal or high-risk). Build guardrails that escalate low-confidence or policy-flagged responses to a reviewer, and keep an auditable trail of the human decision. For chatbots, provide a clear handoff with context and a short checklist for the reviewer.

Operational points:

- Implement confidence thresholds and automatic escalation rules.
- Keep short, pragmatic review playbooks so reviewers act consistently and quickly.

### API usage vs hosted services

Decide early whether a workflow should use a hosted conversational UI (e.g., ChatGPT web client) or programmatic APIs. Hosted services are fast for human exploration and low-friction adoption, but lack the fine-grained controls and observability of APIs. APIs enable integration (RAG, function-calling, agents) and are easier to place behind corporate egress controls and VPCs.

Guidance:

- Reserve hosted web clients for low-risk, exploratory use under controlled enterprise accounts.
- Gate API keys via central platform teams, require short-lived credentials, and integrate call-logging into your observability pipelines.
- For production integrations, require input sanitisation, output validation and a threat assessment (what could be exposed if the model or store is compromised).

---

## Why provide an enterprise ChatGPT service?

Allowing employees to use personal ChatGPT accounts creates operational, legal and security risks. An enterprise-managed offering centralises control and reduces risk:

- Data governance: route prompts and responses through approved logging, retention and redaction controls so PII and IP are handled according to policy.
- Access control & SSO: integrate with corporate SSO and conditional access to enforce MFA, device compliance and session control.
- Billing & procurement: central billing avoids ad-hoc purchases and gives procurement leverage for enterprise SLAs and support.
- Model selection & compliance: standardise on vetted models (or provider-managed enterprise offerings) with contract protections and enterprise-grade data handling.
- Audit & incident response: capture audit logs, conversation evidence (where allowed), and revoke keys centrally during incidents.
- Consistent policy enforcement: apply organisation-level guardrails (prompt filters, disallowed categories) and avoid shadow IT.

Providing a managed ChatGPT reduces legal exposure, simplifies compliance, and gives SRE/Security teams a clear control plane for incidents.

---

## ChatGPT offerings and typical use cases

This catalog summarises common ChatGPT or similar offerings and where they fit in the enterprise.

- Consumer / Free tier
	- Use case: low-risk exploration, personal learning, prototyping by individuals.
	- Not suitable for sensitive data or production workflows. No enterprise SLAs or central controls.

- ChatGPT Plus / paid consumer
	- Use case: improved availability and latency for power users; acceptable for low-risk, non-sensitive tasks.
	- Still lacks enterprise controls (SSO, audit, contractual data protections).

- ChatGPT Enterprise (or provider enterprise plans)
	- Use case: organisation-wide access with SSO, admin controls, data loss prevention integrations, and contractual assurances about data handling.
	- Suitable for knowledge work, documentation drafting, support augmentation, and internal automation where PII is controlled or redacted.

- API access (OpenAI API / Azure OpenAI)
	- Use case: integrated application workflows (chatbots, RAG pipelines, automation) where teams need programmatic access, model selection, and scaling.
	- Requires governance: input filtering, output validation, and VPC/egress design if sending sensitive data.

- Private / On-prem or Isolated deployments
	- Use case: highest-control scenarios where data residency or regulatory constraints prevent using public hosted models.
	- Often used for classified data, regulated industries, or when vendors offer an air-gapped option.

---

## How to choose

- Start by classifying data and use cases: block sensitive PII from consumer tools and require enterprise-managed paths for regulated data.
- Match risk to offering: use consumer tiers for experimentation, enterprise plans or API paths for production and RAG integrations, and private deployments for regulated workloads.
- Bake governance into procurement: require contractual clauses for data handling, deletion, and incident response when negotiating with providers.

---

## OpenAI / provider feature catalog & enterprise use cases

Below is a concise catalog of commonly available OpenAI-style features (GPT ecosystem) and how organisations typically use them — plus short enterprise notes for each.

- GPTs / Custom assistants
	- Use cases: branded assistants, role-specific helpers (HR, legal, engineering), guided workflows for customers or internal teams.
	- Enterprise notes: require vetting of plugin/connectors, ensure data controls for downloaded knowledge bases, and record versions for audit.

- Agents & orchestrators
	- Use cases: multi-step autonomous workflows (ticket triage, data enrichment, automated remediation) that call tools/APIs, decide, and act.
	- Enterprise notes: define strict guardrails, require human-in-the-loop approvals for high-risk actions, and log all tool calls and decisions for traceability.

- Code generation / Copilot-style assistants
	- Use cases: accelerate development, generate tests, refactor code, scaffold services, and suggest fixes during PRs.
	- Enterprise notes: run static analysis and security scanners on generated code; require developer review and provenance metadata (prompt -> generated snippet).

- Image generation & drawings (e.g., DALL·E-like)
	- Use cases: marketing assets, rapid mockups, UI concepts, or diagram generation from text prompts.
	- Enterprise notes: confirm licensing terms, filter for brand-safe content, and avoid sending protected imagery or customer data to public models.

- Speech / audio and TTS/STT
	- Use cases: voice assistants, call summarisation, accessibility features, and audio content generation.
	- Enterprise notes: capture consent for recordings, redact sensitive content before transcription where required, and secure audio artifacts.

- Vision / OCR / multimodal
	- Use cases: image understanding, document OCR, invoice extraction, and visual search.
	- Enterprise notes: treat images as potentially sensitive (PII in photos), apply redaction and store only derived metadata where possible.

- Embeddings & semantic search (RAG)
	- Use cases: knowledge retrieval, semantic search over manuals, FAQ bot grounding, similarity-based matching and recommendations.
	- Enterprise notes: control vector storage access, encrypt at rest, and implement provenance so responses reference source documents.

- Function calling & tool integration
	- Use cases: structured outputs, calling internal APIs (inventory, ticketing), and triggering workflows securely from an LLM.
	- Enterprise notes: validate inputs/outputs, apply role-based access for callable functions, and ensure tool APIs authenticate using short-lived credentials.

- Moderation & safety APIs
	- Use cases: filter unsafe or disallowed content from user inputs/LLM outputs, flag policy violations, and route escalations.
	- Enterprise notes: tune moderation thresholds to business needs, and pipeline moderation events into incident systems for review.

Enterprise mapping tip: for each planned feature, document the data flow (what is sent to model, what is stored), the threat model (what can be leaked), and the guardrails (filters, human approvals, observability) before piloting.

---

## Secure RAG sketch (ASCII)

Recommended minimal pattern for Retrieval-Augmented Generation (RAG):

```
User -> Frontend/UI -> Input filter/redaction -> Query Service ->
	-> Vector DB (private, encrypted)  <-- Indexing pipeline (ingestion, PII redaction)
	-> Retrieval results -> LLM (via API on controlled egress) -> Output filter -> User

Monitoring/Logging: central logging (prompts/metadata), SIEM integration, and audit trail for retrieval evidence.
```

---

## Hard rules (do not bypass)

- DO NOT allow user-entered PII or customer data to be sent to consumer-tier models.
- DO provision enterprise API keys and authenticate via corporate identity (no shared/static keys in code).
- DO require a human approval step for any LLM-driven action that changes customer state (billing, access, HR actions).

---

Include: `../../_footer.md`
Return to [AI Index](_index.md) | [Enterprise Index](../_index.md) | [Root README](../../README.md)
