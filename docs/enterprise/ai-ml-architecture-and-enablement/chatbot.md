---
Last Reviewed: 2025-09-04
Tags: ai, chatbots, rag, governance
---

# Chatbots

Practical guidance for designing, deploying and operating chatbots and conversational agents in an enterprise context.

## Overview

Chatbots can improve customer experience, automate common support flows, and accelerate internal workflows. They also introduce risks: data leakage, hallucination, privacy and brand reputation issues. Treat chatbot projects as product integrations with clear scoping, governance and monitoring.

## Quick TOC

- [Basic concepts & architecture](#basic-concepts--architecture)
- [Common use cases](#common-use-cases)
- [How to build a chatbot on Azure](#how-to-build-a-chatbot-on-azure)
	- [Minimal architecture (RAG)](#minimal-architecture-rag)
	- [Azure services mapping](#azure-services-mapping)
	- [Step-by-step build checklist](#step-by-step-build-checklist)
	- [Security & governance checklist](#security--governance-checklist)
- [Operational readiness & monitoring](#operational-readiness--monitoring)

---

## When to build vs integrate

- Use an integrated SaaS assistant when the need is generic and data residency/control is low.
- Build or vet a custom solution when you need control over data, integration with internal systems, or strict auditability.

## Common architecture patterns

- Retrieval-Augmented Generation (RAG): use a retrieval store (vector DB) plus a generation model to ground responses in your docs and assets.
- Rules + fallback: combine deterministic flows for sensitive tasks and LLM responses for open text.
- Hybrid on-prem / cloud: keep sensitive retrieval/content stores in your VNet and call hosted models via protected egress.

## Data privacy & handling

- Avoid sending PII/unredacted customer data to external models unless contractually allowed and logged.
- Implement input filters, PII redaction, and data minimization before sending to a model.
- Maintain a retention policy for conversation logs and vector stores; support legal hold and data subject requests.

## Safety, hallucination & trust

- Use grounding sources and cite evidence when returning factual claims.
- Add confidence thresholds, and degrade to a human handoff when confidence is low or the request touches sensitive actions.
- Regularly evaluate outputs against a test-suite for hallucinations and safety regressions.

## Observability & monitoring

- Log prompts, responses (where permitted), model-id, and retrieval evidence for audit and troubleshooting.
- Track KPIs: accuracy, escalation rate, user satisfaction, latency, cost per session.

## Security & abuse mitigation

- Protect APIs and keys using managed identities and short-lived credentials.
- Rate-limit and detect anomalous traffic; quarantine suspicious sessions.
- Validate and harden any downstream actions (e.g., account changes) triggered by the bot.

## Operational playbook

- Define an on-call rotation for escalation paths and a short incident playbook: isolate model keys, preserve logs, and notify legal/security.
- Plan regular model updates, bias audits, and regression tests before production rollouts.

## Testing & evaluation

- Maintain unit tests for prompt templates and synthetic tests for end-to-end flows.
- Use holdout datasets and human review for high-risk categories.

## References & further reading
---

## Basic concepts & architecture

Core components of a modern chatbot:

- Frontend / UI: web, mobile or messaging channel that collects user input and displays responses.
- Orchestration layer: routes requests, enforces auth/quotas, and calls the LLM and retrieval services.
- Retriever (vector search / semantic search): fetches relevant documents or snippets from an indexed corpus.
- Embeddings service: converts documents and queries into vector representations.
- Vector DB / semantic index: stores embeddings and supports nearest-neighbour queries.
- LLM / model endpoint: generates responses, optionally with retrieval evidence and function calls.
- Connectors & tools: downstream APIs for tickets, databases, identity, and other systems.
- Observability & ops: logging, metrics, alerts, and tooling for incident response.

Typical flow (high level):

User -> Frontend -> Orchestrator -> Retriever -> LLM -> Orchestrator -> Frontend

When using RAG: Retriever returns evidence that the LLM uses to ground answers; evidence ids should be surfaced with responses.

---

## Common use cases

- Internal knowledge assistant: search across manuals, runbooks, and wikis to answer employee questions.
- Customer support bot: handle tier-1 requests, triage issues, and create tickets in the support system.
- Developer assistant: code search, repo summaries, and quick scaffolding (often integrated with Copilot-style tooling).
- Process automation: trigger internal workflows (provisioning, approvals) via function-calls with human approvals.
- Compliance and SOP lookup: quick access to regulatory or process steps for auditors and operators.

Each use case has different risk profiles — e.g., customer support may handle PII and needs stricter controls than a public-facing FAQ bot.

---

## How to build a chatbot on Azure

Below is a practical guide for building a chatbot using Microsoft Azure services and recommended patterns. This assumes you will use an LLM (Azure OpenAI or similar) and a retrieval layer for grounding.

### Minimal architecture (RAG)

```
User -> Channel (Web/Teams/Slack) -> API Gateway/Orchestrator ->
  -> Input filter/redaction -> Retriever (Vector index) -> LLM (Azure OpenAI) ->
  -> Output filter -> Channel

Supporting components:
- Indexing pipeline: data ingestion, embedding generation, vector index updates
- Storage: blob/object store for raw docs, metadata store for sources
- Auth & secrets: Entra ID, Key Vault, Managed Identity
- Ops: App Insights, Log Analytics, runbooks
```

### Azure services mapping

- Channel/Frontend: static web on Azure Static Web Apps, Power Virtual Agents, Microsoft Teams app, or custom frontends hosted in App Service / AKS.
- Orchestration/API: Azure Functions, Azure API Management, or App Service.
- Embeddings & model: Azure OpenAI (embeddings endpoints, Chat Completions / function-calling) or vendor APIs behind a secure egress.
- Vector index / semantic search: Azure Cognitive Search (vector search), or hosted vector DBs in AKS (Milvus) or managed services.
- Storage: Azure Blob Storage for documents, Cosmos DB or Azure SQL for metadata and conversation logs if retention requires relational storage.
- Secrets & identity: Azure Key Vault + Managed Identity; Entra ID for user authentication and SSO.
- CI/CD: GitHub Actions or Azure DevOps Pipelines for builds, tests, and deployments.
- Observability: Application Insights + Log Analytics + Workbooks for dashboards; Azure Monitor alerts for SLOs.
- Runbooks & automation: Azure Automation, Logic Apps, or durable Functions for operational playbooks.

### Step-by-step build checklist

1. Scoping & data classification
	- Classify the data the bot will touch. Block PII from being sent to public models unless contractually permitted.
	- Define success criteria and SLOs (e.g., resolution rate, escalation rate, latency).

2. Prototype: simple Q&A
	- Ingest a small document set into Blob Storage.
	- Generate embeddings with Azure OpenAI embeddings and store them in Azure Cognitive Search (or a vector DB).
	- Build a tiny orchestrator (Azure Function) that accepts a query, retrieves top-k docs, calls the LLM with context, and returns the answer.

3. Add channel & auth
	- Expose the orchestrator via Azure API Management or directly behind App Service with Entra ID auth.
	- Integrate with the chosen channel (Teams/Slack/Web) and add user identity where required.

4. Hardening: safety & filtering
	- Add input redaction and PII filters before embeddings or model calls.
	- Implement an output safety filter or hallucination check; route low-confidence answers to human reviewers.

5. Scale & infra
	- Move ingestion to a pipeline (Azure Functions / Durable Functions) that batches embedding generation and updates the index.
	- Host retrieval and orchestrator with scaling (App Service/AKS). Monitor costs for vector queries and inference.

6. CI/CD, testing & governance
	- Add unit tests for prompt templates and synthetic queries for high-risk flows.
	- Automate deployments with GitHub Actions; include a canary stage that runs smoke tests for accuracy and hallucination checks.

7. Observability & ops
	- Log prompts (metadata only where privacy allows), model-id, and retrieval evidence ids to Log Analytics.
	- Create Workbooks dashboards with SLOs and an on-call runbook that references automated recovery steps.

### Security & governance checklist

- Store keys in Key Vault and use Managed Identities for services.
- Require Entra ID SSO for admin tooling and use Conditional Access policies for management consoles.
- Enforce Azure Policy to prevent unapproved region or SKU usage for data stores.
- Encrypt vector stores at rest and secure network access with private endpoints or VNet integration where possible.
- Keep an audit trail (who ran what prompt and which model/version) for high-risk workflows and retain per-policy.

---

## Operational readiness & monitoring

- Define an incident playbook: isolate model keys, pause ingestion, and preserve logs for investigation.
- Run regular regression tests for hallucination and coverage, and track model drift over time.
- Maintain a human-in-the-loop pathway for any action that changes customer state.

---


### Practical quick wins (Azure)

- Automate reindexing runbooks and expose a guarded "reindex" operation for operators (reduce manual interventions).
- Replace ad-hoc credential sharing with Key Vault references and Managed Identities for ingestion and runtime services.
- Add an automated smoke-test that runs after model or index updates and gates promotion if hallucination or coverage regressions are detected.
- Track costs with Azure Cost Management and set budgets/alerts for ingestion and inference spending.

Mapping to operational lessons
- Flow: automated ingestion and pipelines reduce manual touchpoints and keep knowledge fresh.

### References (selected Microsoft docs)

- Azure OpenAI Service quickstart: https://learn.microsoft.com/azure/cognitive-services/openai/quickstart
- Azure Cognitive Search (vector search): https://learn.microsoft.com/azure/search/search-what-is-azure-search
- Azure Key Vault overview: https://learn.microsoft.com/azure/key-vault/general/overview
- Azure Monitor & Application Insights: https://learn.microsoft.com/azure/azure-monitor/overview
- Azure Functions & Durable Functions: https://learn.microsoft.com/azure/azure-functions/
- Azure Cognitive Services (Speech, Vision, Language): https://learn.microsoft.com/azure/cognitive-services/
- Azure DevOps & GitHub Actions docs: https://learn.microsoft.com/azure/devops/ and https://docs.github.com/actions
- Azure Policy & governance: https://learn.microsoft.com/azure/governance/policy/overview



---

Include: `../../_footer.md`
