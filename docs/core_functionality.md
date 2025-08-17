# Core Functionality

This document details the essential processes and components of the application, based on an investigation of the controllers, routes, models, services, and jobs.

---

## End-to-End Chat Flow (Summary)

1.  A user sends a message from the conversation view.
2.  `MessagesController#create` receives the request. A `before_action` (`enforce_daily_limit`) first checks if the user has exceeded their daily cost limit by checking aggregated data in `open_router_daily_summaries`.
3.  The controller immediately appends the user's message to the chat UI via a Turbo Stream for instant feedback.
4.  The controller dispatches a background job: `ContentGenerationJob` if a stencil is used, otherwise `ProcessLlmChatJob`.
5.  The **Job** runs asynchronously via the `SolidQueue` backend. It prepares the prompt (using a stencil's system prompt and JSON schema if applicable) and calls the **`OpenRouterClient` service**.
6.  The **Service** sends the request to the OpenRouter.ai API.
7.  Upon receiving a response, the Job logs the token usage and cost via the `open_router_usage_tracker` gem.
8.  The Job creates new database records (a `Message` for the assistant's reply, and possibly an `Artifact`).
9.  The Job broadcasts multiple **Turbo Stream updates** back to the client to append the assistant's message and update any other relevant UI components (like artifact buttons).
10. If any error occurs during this process, the `ToastHelper` is used to broadcast an error notification to the user via another Turbo Stream.

---

## Layer-by-Layer Breakdown

### 1. Routes & Controllers (Request/Response Layer)

This section details the entry points and initial handling of user requests.

#### Projects
- **Controller:** `app/controllers/projects_controller.rb`
- **Logic**: Standard CRUD. `create` redirects directly to the conversation. `update` responds to Turbo Streams.

#### Conversations & Messages
- **Controllers:** `conversations_controller.rb`, `messages_controller.rb`
- **Logic**: `ConversationsController` sets up the main chat view. `MessagesController` is the entry point for all chat messages and kicks off the background jobs.
- **Custom Action**: `conversations#artifact` exists to render generated artifacts (e.g., Mermaid diagrams) inside the chat view.

#### Other Controllers
- **`ArtifactStencilsController`**: CRUD for managing stencils, with authorization to ensure users can only access published or self-owned stencils.
- **`FavoriteArtifactStencilsController`**: Manages the user-stencil relationship. The `index` action contains complex queries that are a candidate for refactoring.
- **`InvitesController`**: An **Admin-Only** feature for managing user invite codes.

### 2. Stimulus (Front-end Layer)

This section maps Rails views to their corresponding Stimulus JS controllers.

#### Confirmed Stimulus Connections

| View File                                    | `data-controller` Attribute | JavaScript File                    |
| :------------------------------------------- | :-------------------------- | :--------------------------------- |
| `conversations/_artifact.html.erb`           | `artifact-select`           | `artifact_select_controller.js`    |
|                                              | `svg-zoom`                  | `svg_zoom_controller.js`           |
| `conversations/_chat.html.erb`               | `assistant-user-chat`       | `assistant_user_chat_controller.js`|
| `conversations/show.html.erb`                | `artifact`                  | `artifact_controller.js`           |
|                                              | `chat-scroll`               | `chat_scroll_controller.js`        |
| `favorite_artifact_stencils/index.html.erb`  | `tab-switcher`              | `tab_switcher_controller.js`       |
| `layouts/_flash_messages_timed.html.erb`     | `removable`                 | `removable_controller.js`          |
| `pages/landing/_features.html.erb`           | `viewport`                  | `viewport_controller.js`           |
| `projects/_menu.html.erb`                    | `project-menu`              | `project_menu_controller.js`       |
| `shared/_toast.html.erb`                     | `toast`                     | `toast_controller.js`              |

#### Analysis
- **Fragmentation**: The chat functionality is split across at least 5 different controllers, confirming the need for consolidation.
- **Potentially Unused**: `auto_expand_controller.js` and `message_form_controller.js` appear to be unused.

### 3. Data & Business Logic Layer

This is the core of the application, containing the primary business logic, data structures, and external API communication.

#### Database Schema & Models
- **`User`**: Has an `account_type` enum (`free`, `paid`, `admin`). Contains the `cost_exceeded?` method which is central to the daily usage limit feature.
- **`Project`**: `after_create` callback automatically creates an associated `Conversation`.
- **`Conversation`**: Has a `TOKEN_LIMIT` constant. An `after_create` callback creates an associated `TotalToken` record.
- **`Message`**: Has a `role` enum (`user`, `assistant`). An `after_create_commit` callback runs `check_token_limit` to see if the conversation should be disabled.
- **`ArtifactStencil`**: Contains the core prompts and configuration for generating artifacts.
- **Cost Tracking**: A set of tables (`open_router_usage_logs`, `open_router_daily_summaries`, `total_tokens`, `weekly_consumptions`) provides a detailed and robust system for monitoring all token usage and costs.

#### Services & Jobs
- **`OpenRouterClient` (Service)**: The single gateway to the external LLM API (OpenRouter.ai). It wraps all API calls, providing standardized error handling and logging.
- **`OpenRouterUsageTracker` (Service/Model)**: A dedicated class responsible for logging every API call's cost and usage details to the database.
- **`ProcessLlmChatJob` (Job)**: Handles standard, non-stencil-based chat. It calls the API, creates an assistant message, and broadcasts the response back to the user via a single Turbo Stream.
- **`ContentGenerationJob` (Job)**: Handles complex artifact generation. It uses a JSON schema to get structured output from the LLM, then creates both a `Message` (for the explanation) and an `Artifact` (for the content). It broadcasts multiple Turbo Streams to update all relevant UI components.
- **`ToastHelper` (Helper)**: A reusable module to display toast notifications from anywhere in the backend by broadcasting a Turbo Stream to the user.

### 4. Infrastructure & Dependencies

This section describes the foundational technologies that support the application.

- **Background Jobs**: The application uses `SolidQueue`, a modern, database-backed queuing system. This is a robust choice for production environments.
- **Deployment**: The application is configured for deployment using `Kamal`, a Docker-based tool.
- **Code Style**: Code quality is enforced by `rubocop-rails-omakase`. The codebase is demonstrably clean and adheres to the style guide.
- **Key Gems**:
    - `solid_cache` / `solid_cable`: Modern database-backed infrastructure for caching and WebSockets.
    - `ruby-openai`: The underlying client for communicating with the LLM API.
    - `open_router_usage_tracker`: A custom, dedicated gem for the critical function of tracking API usage and cost.

---

## Appendix: The Discovery & Analysis Journey

This section provides context on the analysis process undertaken to produce this document, in accordance with Step 1 of the `revitalization_plan.md`.

Our investigation proceeded in four main phases, moving from a micro to a macro view of the project.

**Phase 1: Code & Architecture Analysis**

The initial investigation focused on understanding the application's structure as-is. This involved:
- A review of all controllers and routes to map the request/response layer.
- A search of the `app/views` directory to identify all Stimulus controller connections, which confirmed a high degree of front-end fragmentation.
- A deep dive into the `app/models`, `app/jobs`, and `app/services` directories. This was the most critical step, as it uncovered the true end-to-end business logic, including the automated conversation creation, the robust cost-tracking system, the asynchronous nature of all LLM interactions via background jobs, and the structured data generation in `ContentGenerationJob`.

**Phase 2: Project Health & Ecosystem Review**

With the application logic understood, the analysis expanded to the project's surrounding ecosystem and development practices. This included:
- An assessment of the testing strategy, which identified the Minitest/fixture setup as a key risk for a large-scale refactor.
- An analysis of the `Gemfile` and `Procfile.dev`, which revealed a modern and powerful backend stack (SolidQueue, Kamal) but also a flaw in the development environment configuration (missing the job queue processor).
- A code quality check using RuboCop, which confirmed the codebase is clean and stylistically consistent.

**Phase 3: Product Viability & Market Simulation**

At this stage, the analysis pivoted from the technical implementation to the product's purpose and market viability. This was prompted by high-level questions about user adoption.
- A simulated user research sprint was conducted using targeted web searches to validate the core problem.
- The research confirmed that potential users actively struggle with the problems SpecMaker solves (prompt management, inconsistent LLM output) and are already using manual workarounds (saving prompts in documents).
- This phase validated that a real market need exists for this product.

**Phase 4: Strategic Synthesis & Action Blueprint**

The final phase synthesized all prior findings into a single, actionable strategy. The conclusion of the analysis was that the product is viable and the technology is strong, but the primary risk to the refactor is the inadequate test suite. Therefore, a detailed, prioritized blueprint for migrating to RSpec and FactoryBot was created. This blueprint serves as the direct, evidence-based starting point for the next phase of the project.

This exhaustive, multi-faceted analysis provides a robust foundation for the planned refactoring effort and the future development of the application.
