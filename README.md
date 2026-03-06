# Stencil-AI (Archived)

## 1) What This Project Is
Stencil-AI is an archived Rails prototype for a one-to-many AI workflow pattern: a single project conversation can produce multiple AI-generated outputs ("artifacts") by running selected reusable prompts ("stencils") against shared chat context.

This repository remains as an engineering archive and portfolio artifact. It demonstrates product direction, implemented system behavior, and architectural tradeoffs, but it is not positioned as an actively maintained or production-ready system.

## 2) Why It Exists (Problem and Concept)
Many AI workflows force repeated context switching:
- Ask one question.
- Copy context into another prompt.
- Reformat output manually.
- Repeat for each perspective (diagramming, planning, summarization, analysis).

Stencil-AI explored a different interaction model:
- Keep one evolving conversation per project as the source of truth.
- Attach reusable stencil prompts to that conversation.
- Trigger multiple outputs in parallel from the same context.

The product hypothesis was that concurrent artifact generation can reduce repetitive prompting and make multi-angle analysis faster for technical builders.

## 3) Core Workflow (Single Chat Context -> Multiple Stencil Outputs)
At a high level, the implemented workflow is:
1. User creates a project.
2. Project automatically gets a conversation.
3. User sends a message in chat.
4. User can optionally select one or more favorited stencils before submitting.
5. System either:
   - runs normal assistant chat (no stencils selected), or
   - fans out background jobs (one per selected stencil) to generate artifacts.
6. Results stream back into chat as assistant messages.
7. Artifact panel updates and allows artifact selection and viewing.

Stencil categories currently implemented:
- `regular_text`: structured JSON response with `content` + `explanation`.
- `mermaid`: structured JSON response with `mermaid` + `explanation`, then rendered in UI.

## 4) What Was Actually Built (Implemented Capabilities)
Implemented capabilities in this repo include:
- Account system with sessions, password reset, registration, and basic invite-gated signup.
- Projects workspace with project list/create/update/delete.
- One conversation per project, with persisted message history.
- Message composer with optional multi-stencil selection modal.
- Background job pipeline for:
  - general chat response generation,
  - stencil-specific artifact generation.
- Artifact persistence per project and stencil selection.
- Turbo stream updates for:
  - user and assistant messages,
  - artifact availability and selection UI,
  - toast notifications.
- Artifact side panel with:
  - selector for generated artifacts,
  - Mermaid rendering for diagram-type artifacts,
  - pan/zoom and fullscreen helpers.
- Stencil management:
  - create/view/delete personal stencils,
  - set public/private visibility,
  - categorize as text or Mermaid,
  - subscribe/unsubscribe through favorites.
- Basic shared/free stencil feed pattern (via a designated account convention).
- Invite creation/management flow for admin users.
- Usage and guardrail hooks:
  - conversation token limit checks,
  - daily cost-limit enforcement per account type,
  - usage logging through `open_router_usage_tracker` gem integration.

## 5) Architecture Snapshot
Backend stack:
- Ruby on Rails 8 (`ArtifactMaker` app module).
- PostgreSQL for primary application data.
- Active Job with Solid Queue.
- Solid Cable for production Action Cable backend.
- OpenRouter API access through `ruby-openai` client wrapper.

Frontend stack:
- Server-rendered Rails views with Hotwire/Turbo.
- Stimulus controllers for chat form, artifact panel behavior, tab switching, scrolling, and SVG interactions.
- Tailwind CSS + DaisyUI styling.
- Mermaid JS for diagram rendering.
- Panzoom for diagram interaction.

Core domain entities:
- `User`: authentication, account tier, invite validation.
- `Project`: container entity, belongs to user.
- `Conversation`: one-per-project message context.
- `Message`: conversation entries (`user`, `assistant`, `system` roles).
- `ArtifactStencil`: reusable prompt template, category + visibility.
- `FavoriteArtifactStencil`: user subscriptions to stencils.
- `Artifact`: generated output associated with project + stencil selection.

Core async behavior:
- `ProcessLlmChatJob`: normal assistant reply path.
- `ContentGenerationJob`: stencil fan-out path with JSON-schema response formatting and artifact update/broadcast.

## 6) Access and Usage Constraints
This prototype includes explicit product constraints:
- Invite gating:
  - Non-admin registration requires a valid invite code.
  - Admin account type can bypass invite requirement.
- Account-tier limits:
  - Project count limits by account type (free/paid/admin logic exists in model validation).
  - Stencil count limits by account type.
- Conversation/token guardrails:
  - Conversation token threshold constant (`96_000`) blocks further message flow when exceeded.
  - UI disables message form when conversation limit is reached.
- Daily cost guardrails:
  - Per-account-type daily cost caps enforced before message creation.
  - Requests are rejected with user-facing toast when daily cap is exceeded.

These guardrails were intended to keep usage bounded during early-stage experimentation.

## 7) Current Limitations and Why Archived
This repository is archived because scope and polish requirements outpaced available iteration bandwidth. Concrete limitations in the current snapshot include:
- Product maturity gap:
  - Core workflow exists, but UX and onboarding quality are prototype-level.
- Artifact type breadth:
  - Concept aimed at many output modes, but implementation is primarily text and Mermaid.
- Maintenance drift signals:
  - Some test names/reference points reflect earlier iterations and are not fully aligned with current job naming/history.
- Operational hardening not complete:
  - Suitable for demonstrating architecture and flow, not positioned as production-hardened software.

The value of this repo is as a documented prototype and engineering case study, not as an actively evolving product.

## 8) Light Local Setup (Local-First)
This section is intentionally lightweight and aimed at quickly understanding/running the archive.

Prerequisites:
- Ruby `3.3.7`
- PostgreSQL
- Node.js + Yarn
- Bundler

Environment/config notes:
- Database config expects PostgreSQL, with password via `POSTGRES_PASSWORD`.
- OpenRouter calls require credentials entry for `open_router_key`.
- Development mailer config expects Gmail credentials in Rails credentials.

Minimal local run path:
```bash
bundle install
yarn install
bin/rails db:prepare
bin/dev
```

`bin/dev` starts Rails server plus JS/CSS watchers via `foreman` and `Procfile.dev`.

Optional container path:
- `Dockerfile` and `docker-compose.yml` are present.
- Compose setup is more production-oriented; local-first Rails workflow is the primary path for archive exploration.

## 9) Repository Map (Key Areas)
- `app/controllers`: auth, projects, conversations, messages, stencils, favorites, invites.
- `app/models`: domain models and validation constraints.
- `app/jobs`: async chat + artifact generation jobs.
- `app/services/open_router_client.rb`: OpenRouter API wrapper.
- `app/views/conversations`: core chat and artifact interface partials.
- `app/javascript/controllers`: Stimulus interaction controllers.
- `db/schema.rb`: canonical data model snapshot.
- `db/stencils`: seeded example stencil modules and prompts.
- `test/`: model/controller/service/job coverage scaffold and regression tests.

## 10) What This Project Demonstrates
This archive demonstrates practical full-stack product engineering across:
- Product modeling:
  - translating a one-to-many AI workflow concept into concrete entities and user actions.
- Async orchestration:
  - combining background jobs, streaming UI updates, and persisted outputs.
- Prompt systems design:
  - reusable prompt templates with output-type-aware response shaping.
- Cost/risk controls:
  - account-tier limits, token thresholds, and daily usage guardrails.
- Rails + Hotwire implementation:
  - server-rendered UX with Stimulus-enhanced interactions and real-time updates.
- Prototype realism:
  - clear boundaries between validated architecture and unfinished product surface.

As archived documentation, this README is intended to make the implemented behavior and constraints legible to both technical reviewers and portfolio/resume readers.
