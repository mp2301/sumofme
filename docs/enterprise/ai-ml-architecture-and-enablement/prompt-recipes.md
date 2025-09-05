---
Last Reviewed: 2025-09-04
Tags: ai, prompts, recipes, copilot
---

# Prompt recipes

This page collects short, reusable prompt templates and patterns that teams can adapt for safe, effective use of LLMs and Copilot-style tools. Treat these as starting points: always validate outputs, apply filters for sensitive data, and log prompts where required for governance.

## Quick TOC

- [How to use these recipes](#how-to-use-these-recipes)
- [Developer productivity](#developer-productivity)
- [Retrieval-augmented generation (RAG)](#retrieval-augmented-generation-rag)
- [Data transformation / extraction](#data-transformation--extraction)
- [Safety and red-teaming](#safety-and-red-teaming)
- [Prompt testing and governance](#prompt-testing-and-governance)

## How to use these recipes

- Replace bracketed tokens (e.g. [SUMMARY], [CONTEXT]) with real data.
- Keep prompts explicit about the desired output shape (format, fields, citations).
- Include a short system/instruction prefix for role & tone when using chat-style models.

## Developer productivity

Task: generate a concise function docstring

Prompt (copy & adapt):
```text
You are an expert software engineer. Given the following function signature and implementation, write a concise docstring (one paragraph) that explains purpose, inputs, outputs, and side-effects.

Function:
[FUNCTION]
```

Task: propose unit test cases

Prompt (copy & adapt):
```text
You are a senior QA engineer. Given the following function description and edge cases, produce a list of unit test names and a one-line assertion summary for each.

Function description: [DESCRIPTION]
Edge cases: [EDGE_CASES]

Return JSON array of objects with fields: name, summary.
```

## Retrieval-augmented generation (RAG)

Prompt (user, copy & adapt):
```text
Context documents: [DOC_SNIPPETS]  # short excerpts or a summary list, numbered
Question: [USER_QUESTION]

Instructions:
- Answer concisely in 3-6 sentences.
- After the answer, list the source ids used in square brackets, e.g. [1], [2].
- If uncertain, say "I am not sure" and suggest search terms or next steps.
```

## Data transformation / extraction

Task: extract structured fields from text

Prompt (copy & adapt):
```text
Extract the following fields from the text: date, customer_name, issue_summary. Return valid JSON with those keys or null if missing.

Text:
[RAW_TEXT]
```

## Safety and red-teaming

- Always use a system-level instruction restricting disallowed outputs (e.g., PII exfiltration, illegal instructions).
- Include a final sanity-check step in prompts to verify no sensitive tokens were included.

Example safety check prompt fragment:
```text
Before returning, verify the response contains no personal data (names, emails, IDs). If it does, redact or respond with 'contains-sensitive-data'.
```

## Prompt testing and governance

Testing:

- Keep 5–10 canonical prompts and expected outputs for high-risk paths.
- Run them in CI against model updates and flag regressions in a dashboard.
- Automate canary evaluations against a test corpus; compare response fingerprints for regressions.

Governance:

- Store prompts and audit metadata in a versioned repo or internal governance DB.
- Log prompt, model id, and selected retrieval evidence for auditability.
- Apply data minimization: remove or redact PII before sending for generation.

