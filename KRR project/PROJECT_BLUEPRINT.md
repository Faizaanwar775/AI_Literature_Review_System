# PROJECT BLUEPRINT

This document is a full workspace map of the KRR project as it exists in this repository snapshot. The codebase is a small full-stack system that combines a FastAPI backend, a Vite + React frontend, local PDF ingestion, and Groq-powered academic text generation to support literature review workflows.

---

## 1. PROJECT OVERVIEW

### What this project is
KRR is an academic knowledge review and synthesis tool. It accepts PDF papers, extracts their text, sends that text to a large language model for structured analysis, and then lets the user compare multiple papers or generate a literature review from a topic and a set of source documents. The backend is responsible for PDF parsing, AI calls, authentication stubs, and document storage. The frontend is a single-page application that presents an ingestion flow, a document dashboard, per-paper analysis views, a comparison matrix, and a literature review writer.

### The problem it solves
The system reduces the manual effort of reading, annotating, comparing, and synthesizing research papers. Instead of forcing a user to read every PDF directly, it attempts to extract structured summaries, research problems, methods, results, gaps, and review prose that can be reused in downstream research writing.

### Intended users
The primary users are students, researchers, analysts, and anyone doing literature synthesis work. The UI language is oriented toward an executive or research-operations workflow, but the actual product behavior is closest to a lightweight research assistant for academic papers.

### Maturity stage
This is best classified as a prototype that is partway toward an MVP. The frontend is polished and navigable, but the backend still uses in-memory state, hardcoded credentials, duplicated route modules, and several unused or legacy files. There is no persistent database, no automated test suite, and no production deployment configuration.

### End-to-end summary
1. A user logs in through the frontend with a mock email/password pair.
2. The frontend stores the returned JWT in `localStorage`.
3. The user uploads a PDF. The backend extracts text with PyMuPDF, sends that text to Groq, and stores the resulting analysis in an in-memory dictionary.
4. The dashboard fetches the current library from the backend and displays the stored papers.
5. A paper can be opened in the analysis view to inspect abstract, methodology, results, limitations, and gap summaries.
6. The comparison screen requests a pairwise synthesis from the backend.
7. The literature review flow gathers paper IDs, sends them to the backend, and renders model-generated review sections in a report layout.

---

## 2. PROJECT STRUCTURE

### Annotated tree
```text
KRR project/
├── .env                         # Local secrets and runtime configuration; contains a real-looking GROQ key
├── .env.example                 # Template environment file with placeholder Groq key
├── .sixth/                      # Hidden folder; empty skills subfolder in this snapshot
├── .vscode/
│   └── settings.json            # VS Code environment manager preference
├── KRR project.zip              # Snapshot archive of the repository
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI app entry point and primary API routes
│   │   ├── api/
│   │   │   ├── auth.py          # JWT login helpers and current-user dependency
│   │   │   ├── papers.py        # Legacy paper upload/read router; not wired into main app
│   │   │   └── review.py        # Legacy literature review router; not wired into main app
│   │   ├── core/
│   │   │   ├── config.py        # Settings object and environment loading
│   │   │   └── models.py        # Pydantic schemas for paper metadata and review requests
│   │   └── services/
│   │       ├── ai_service.py    # Groq client wrapper and text-analysis workflows
│   │       └── pdf_service.py  # PyMuPDF-based PDF text extraction helper
│   └── uploads/
│       └── 25-021_491efe26-e444-4e02-b58e-f27300cde12f.pdf  # Sample uploaded paper artifact
├── frontend/
│   ├── package.json             # Vite app manifest, scripts, and JS dependencies
│   ├── package-lock.json        # npm lockfile for reproducible frontend installs
│   ├── vite.config.js           # Vite config with React and Tailwind v4 plugins
│   ├── tailwind.config.js       # Tailwind content scan config
│   ├── postcss.config.js       # PostCSS pipeline for Tailwind v4
│   ├── eslint.config.js        # ESLint flat config for React JSX files
│   ├── index.html               # Vite HTML shell and favicon entry point
│   ├── index.css                # Legacy top-level stylesheet; not imported by the app runtime
│   ├── README.md                # Frontend template documentation from Vite
│   ├── public/
│   │   ├── favicon.ico          # Browser favicon
│   │   ├── favicon.svg          # SVG favicon referenced by index.html
│   │   └── icons.svg            # Symbol sprite for icon assets
│   └── src/
│       ├── main.jsx             # React root mount and global stylesheet import
│       ├── App.jsx              # Router and layout wrapper
│       ├── App.css              # Empty legacy stylesheet
│       ├── index.css            # Actual Tailwind/theme stylesheet used by the app
│       ├── lib/
│       │   └── utils.ts         # `cn()` class name merge helper
│       ├── assets/
│       │   ├── hero.png         # Static hero image asset, currently not referenced in code
│       │   ├── react.svg        # Template React asset, unused
│       │   └── vite.svg         # Template Vite asset, unused
│       ├── components/
│       │   ├── layout/
│       │   │   ├── AppShell.jsx # Sidebar + header shell used for authenticated pages
│       │   │   └── Sidebar.jsx  # Left navigation for dashboard sections
│       │   └── ui/
│       │       ├── Button.jsx   # Shared button primitive
│       │       ├── Card.jsx     # Shared card primitives
│       │       └── Badge.jsx    # Shared badge primitive
│       └── pages/
│           ├── Login.jsx        # Mock login screen
│           ├── Dashboard.jsx    # Library overview and navigation hub
│           ├── Upload.jsx       # PDF ingestion screen
│           ├── AnalysisView.jsx # Per-paper analysis details
│           ├── TopicInput.jsx   # Topic capture for review generation
│           ├── ComparisonView.jsx # Paper comparison matrix
│           └── LiteratureReview.jsx # Generated review report view
├── logs/
│   ├── backend.log              # Runtime log output from the startup script
│   └── frontend.log             # Runtime log output from the startup script
├── requirements.txt             # Backend Python dependencies
├── setup.sh                     # Installer for Python and Node dependencies
├── start.sh                     # Dual-process local startup script
└── test paper/
    ├── Continuous_Testing_and_Solutions_for_Testing_Probl.pdf  # Sample research paper input
    └── 3549206.3549321.pdf     # Sample research paper input
```

### Naming conventions
The backend uses lowercase module names with underscores, which is conventional for Python packages. The frontend uses PascalCase for React components and page files, with `ui/` and `layout/` folders acting as primitive and shell layers. The repo is mixed-language: JavaScript, JSX, TypeScript, Python, shell, and static assets coexist without a monorepo toolchain.

---

## 3. DESIGN & ARCHITECTURE

### Architectural pattern
The system is a two-tier full-stack application with a thin API backend and a client-side React SPA. Inside the backend, the code loosely follows a route-service pattern: HTTP endpoints live in `main.py` or route modules, text extraction lives in `pdf_service.py`, model calls live in `ai_service.py`, and settings live in `config.py`. There is no durable repository layer yet, so persistence is currently an in-memory dictionary rather than a database abstraction.

### Why this pattern fits the current code
This architecture is simple to understand and easy to run locally. It keeps the user-facing flow responsive while allowing the backend to encapsulate PDF processing and Groq requests. The main tradeoff is persistence and scalability: everything in the paper library disappears on restart, and there is no shared database state across processes.

### System architecture diagram
```text
Browser / React SPA
    |
    | fetch / localStorage / route state
    v
Vite frontend (React 19 + Tailwind v4 + Framer Motion)
    |
    | HTTP requests to localhost:8000
    v
FastAPI backend
    |
    +--> auth.py (JWT login and current-user dependency)
    +--> pdf_service.py (PyMuPDF extraction)
    +--> ai_service.py (Groq chat completions)
    +--> in-memory db_papers dictionary
    |
    +--> CORS middleware for local dev origin
    |
    +--> /api/upload, /api/library, /api/compare, /api/generate-review
    v
External services
    +--> Groq API
    +--> Local filesystem uploads and logs
```

### Layer breakdown
#### Presentation
The frontend pages and reusable components form the presentation layer. They are responsible for collecting input, rendering outputs, routing the user through the workflow, and presenting loading and error states.

#### Business logic
The backend service layer is where the business logic lives. `ai_service.py` decides how much text to send to the model, how to parse JSON responses, and how to retry or fall back between Groq models. `main.py` orchestrates upload, comparison, and review generation.

#### Data
The data layer is intentionally minimal and currently ephemeral. The paper library exists as a module-level dictionary in memory. Uploaded files are written to disk, but no database schema or migrations are present.

#### Infrastructure
Infrastructure concerns are handled only through shell scripts and local config files. `setup.sh` installs dependencies, `start.sh` launches both processes, and the `.vscode` and Tailwind/Vite configs define local developer behavior.

### Patterns observed
- Router pattern in FastAPI: endpoints are grouped by concern.
- Service wrapper pattern in `ai_service.py` and `pdf_service.py`.
- Presentational component pattern in `Button`, `Card`, and `Badge`.
- Route-based SPA shell pattern in `App.jsx` and `AppShell.jsx`.
- In-memory repository pattern via `db_papers`.
- JWT bearer authentication scaffolding in `auth.py`, though it is only partially enforced.

### Separation of concerns assessment
The separation is adequate for a prototype but incomplete for production. The frontend UI is reasonably modular. The backend has the beginnings of clean boundaries, but route files are duplicated and the main application does not actually mount the legacy routers. Data persistence, auth enforcement, and review generation are all still coupled to runtime globals.

### Scalability and modularity observations
The current structure is easy to extend by adding new endpoints and new pages, but it will not scale horizontally without replacing the in-memory store and formalizing the repository layer. The frontend would benefit from a shared API client, typed response models, and a centralized auth state provider.

---

## 4. TECH STACK & DEPENDENCIES

### Runtime environment
The backend is Python 3 based and is launched through `python3 -m uvicorn app.main:app`. The exact Python minor version is not pinned in the repo, although the workspace contains bytecode artifacts for Python 3.10 and 3.13, which suggests the project has been run in more than one interpreter version. The frontend is a Node.js application managed with npm and Vite. The shell scripts assume standard Unix tooling such as `bash`, `lsof`, `awk`, `sed`, `hostname`, and `chmod`.

### Backend dependencies
| Package | Role | Notes |
|---|---|---|
| fastapi | Web framework for API routes and CORS middleware | Core runtime dependency |
| uvicorn | ASGI server | Used by `start.sh` and the backend entry point |
| PyMuPDF | PDF text extraction and metadata access | Imported as `fitz` in `pdf_service.py` |
| groq | Groq SDK client | Used for paper analysis and literature synthesis |
| pydantic | Request and config model validation | Runtime model layer |
| python-multipart | Multipart form upload handling | Required for `UploadFile` routes |
| python-jose[cryptography] | JWT signing and verification | Used by `auth.py` |
| pydantic-settings | Settings management | **Required by code but missing from `requirements.txt`** |

### Frontend dependencies
| Package | Role | Notes |
|---|---|---|
| react / react-dom | SPA UI runtime | React 19.2.5 |
| react-router-dom | Client routing and navigation | Used throughout the pages and shell |
| framer-motion | Page and panel animations | Used on dashboard, upload, analysis, comparison, and review views |
| lucide-react | Icon set | Used throughout the UI |
| clsx | Class name composition | Used by `cn()` |
| tailwind-merge | Tailwind conflict resolution | Used by `cn()` |
| axios | HTTP client | Declared but not used in the current code |
| recharts | Charting library | Declared but not used in the current code |

### Dev dependencies
The frontend uses Vite, React plugin support, Tailwind v4, PostCSS, ESLint, and React Hooks/Refresh lint plugins. The backend has no explicit dev dependency file and relies on the shell scripts plus installed packages.

### Risky or unused dependencies
- `axios` is declared but the code uses the native `fetch` API instead.
- `recharts` is declared but no chart components import it.
- `pydantic-settings` is required by `backend/app/core/config.py` but absent from `requirements.txt`.
- The frontend has leftover template assets (`react.svg`, `vite.svg`) that are not referenced.

### Package manager and lockfile notes
The frontend is locked with `package-lock.json`, which improves reproducibility. The backend has no lockfile, so installs are version-pinned only through `requirements.txt`. There is no Poetry, Pipenv, or uv project file in this snapshot.

---

## 5. CONFIGURATION & ENVIRONMENT

### Configuration files
| File | Role | Observations |
|---|---|---|
| `.env.example` | Template for local secrets | Provides a placeholder Groq API key |
| `.env` | Real runtime secrets | Contains a live-looking Groq API key and should be treated as sensitive |
| `backend/app/core/config.py` | Settings definition | Loads `.env` and defines default JWT and Groq config |
| `.vscode/settings.json` | IDE preference | Sets Python environment manager to system mode |
| `frontend/vite.config.js` | Vite plugins | React and Tailwind v4 integration |
| `frontend/tailwind.config.js` | Tailwind scan paths | Includes `index.html` and `src/**/*` |
| `frontend/postcss.config.js` | PostCSS pipeline | Enables Tailwind v4 and autoprefixer |
| `frontend/eslint.config.js` | Lint rules | Covers JS/JSX only, not the TS helper file |
| `requirements.txt` | Python dependencies | Missing `pydantic-settings` |
| `frontend/package.json` | Node scripts and deps | Defines `dev`, `build`, `lint`, and `preview` |

### Environment variables
| Name | Source | Purpose | Required | Format |
|---|---|---|---|---|
| `GROQ_API_KEY` | `.env` / `.env.example` | Authenticates Groq API requests | Yes for real analysis | String beginning with `gsk_...` |
| `SECRET_KEY` | `backend/app/core/config.py` default, optionally `.env` | Signs JWT access tokens | Yes for meaningful auth | Long random string |
| `ALGORITHM` | `backend/app/core/config.py` default | JWT signing algorithm | Yes | `HS256` by default |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `backend/app/core/config.py` default | JWT expiration window | Optional | Integer minutes |
| `PROJECT_NAME` | `backend/app/core/config.py` default | App display name | Optional | String |
| `VERSION` | `backend/app/core/config.py` default | App version | Optional | Semantic version string |
| `API_V1_STR` | `backend/app/core/config.py` default | API version prefix | Optional | Path prefix such as `/api/v1` |
| `VITE_API_URL` | Frontend runtime, inferred | Primary frontend API base URL | Optional | Full URL |
| `VITE_API_BASE_URL` | Frontend runtime, inferred | Fallback frontend API base URL | Optional | Full URL |

### Build system step by step
1. `setup.sh` checks for Python 3, Node.js, and npm.
2. It installs backend packages from `requirements.txt` with `pip install -r requirements.txt`.
3. It runs `npm install --force` in `frontend/`.
4. If `.env` is missing, it copies `.env.example` to `.env`.
5. `start.sh` validates that ports 8000 and 5173 are free.
6. It exports environment variables from `.env`.
7. It starts Uvicorn for the backend and Vite for the frontend in the background.
8. Logs are written to `logs/backend.log` and `logs/frontend.log`.

### CI/CD pipeline files
There is no committed CI/CD workflow in this snapshot. No GitHub Actions, GitLab CI, Dockerfile, or deployment manifest is present.

### Docker or container setup
No Dockerfiles or Compose files are present. The project is intended for local process execution rather than containerized startup.

---

## 6. ENTRY POINTS & BOOTSTRAPPING

### Main entry points
- Backend: [`backend/app/main.py`](backend/app/main.py)
- Frontend: [`frontend/src/main.jsx`](frontend/src/main.jsx)
- Local orchestrator: [`start.sh`](start.sh)

### Backend boot sequence
1. `main.py` creates the FastAPI app with the title `KRR - AI Literature Review System`.
2. It installs CORS middleware for the local Vite dev origins.
3. It mounts the authentication router under `/api/v1/auth`.
4. It defines in-memory paper storage and request models.
5. On startup, Uvicorn imports the module and exposes the FastAPI ASGI app.
6. The development server is launched with `--reload` by `start.sh`.

### Frontend boot sequence
1. `main.jsx` loads the root stylesheet and mounts React into `#root`.
2. `App.jsx` creates the router and the route table.
3. `LayoutWrapper` decides whether the sidebar shell should be shown.
4. The login page is rendered without the shell; all other routes are wrapped in `AppShell`.
5. Route transitions are handled client-side by React Router.

### Startup error handling
`start.sh` stops immediately if `.env` is missing or a required port is already in use. The backend catches some API-layer errors with `HTTPException`, while the frontend handles failed fetches in component state and console logs. There is no centralized exception boundary or application-wide recovery layer.

---

## 7. MODULES & COMPONENTS

### Backend modules

#### `backend/app/main.py`
- **File path:** [backend/app/main.py](backend/app/main.py)
- **Purpose:** Main FastAPI application, direct API endpoints, and in-memory paper library.
- **Inputs:** UploadFile payloads, compare request JSON, review request JSON, and incoming HTTP requests.
- **Outputs:** JSON success/error payloads, in-memory paper records, and logged console output.
- **Internal logic:** It validates PDF uploads, delegates extraction to `pdf_service`, delegates AI work to `ai_service`, and writes paper metadata plus analysis to `db_papers`.
- **State managed:** `db_papers` is a process-local dictionary that stores all uploaded paper records.
- **Dependencies:** `FastAPI`, `CORSMiddleware`, `UploadFile`, `File`, `HTTPException`, `pydantic.BaseModel`, `pdf_service`, and `ai_service` functions.
- **Dependents:** The dashboard, analysis view, comparison view, and literature review flow all depend on these routes.
- **Edge cases handled:** Non-PDF uploads, missing topic text, unknown paper IDs, and fewer than two valid papers for comparison.
- **Known limitations / TODOs:** No persistence, no auth enforcement on core routes, and only the first two valid paper IDs are used during comparison.

#### `backend/app/api/auth.py`
- **File path:** [backend/app/api/auth.py](backend/app/api/auth.py)
- **Purpose:** JWT login endpoint and bearer-token validation dependency.
- **Inputs:** OAuth2 password form data and JWT bearer tokens.
- **Outputs:** JWT access token payloads or 401 errors.
- **Internal logic:** It checks a hardcoded email/password pair, creates a signed JWT with `sub`, and decodes incoming tokens with `python-jose`.
- **State managed:** None beyond token expiry data embedded in JWTs.
- **Dependencies:** `datetime`, `timedelta`, `APIRouter`, `Depends`, `HTTPException`, `status`, `OAuth2PasswordBearer`, `OAuth2PasswordRequestForm`, `jwt`, and `settings`.
- **Dependents:** `review.py` depends on `get_current_user`, and the frontend login page posts to `/api/v1/auth/login`.
- **Edge cases handled:** Invalid credentials, missing `sub` claim, and JWT decode errors.
- **Known limitations / TODOs:** Hardcoded credentials, no user store, and no refresh-token or password hashing flow.

#### `backend/app/api/papers.py`
- **File path:** [backend/app/api/papers.py](backend/app/api/papers.py)
- **Purpose:** Legacy upload and retrieval router for paper objects.
- **Inputs:** PDF upload files and paper IDs.
- **Outputs:** In-memory paper records or 400/404/500 errors.
- **Internal logic:** It reads the uploaded file, attempts PDF extraction, runs `analyze_paper`, and stores the result in a module-local dictionary.
- **State managed:** Its own `db_papers` dictionary, separate from the one in `main.py`.
- **Dependencies:** `APIRouter`, `UploadFile`, `File`, `HTTPException`, `uuid`, `extract_text_from_pdf` (which does not exist in `pdf_service.py`), and `analyze_paper`.
- **Dependents:** None in the running app; it is not mounted in `main.py`.
- **Edge cases handled:** Non-PDF uploads and missing paper IDs.
- **Known limitations / TODOs:** Broken import path, duplicate storage layer, and route definitions that are not wired into the main app.

#### `backend/app/api/review.py`
- **File path:** [backend/app/api/review.py](backend/app/api/review.py)
- **Purpose:** Legacy literature-review endpoint that synthesizes paper summaries.
- **Inputs:** `LitReviewRequest` and authenticated user tokens.
- **Outputs:** Markdown-like review text wrapped in JSON or structured errors.
- **Internal logic:** It loads paper metadata from `papers.py`, builds a compressed context blob, and calls `generate_literature_review`.
- **State managed:** None directly, but it reads from the legacy `papers.py` in-memory store.
- **Dependencies:** `APIRouter`, `HTTPException`, `Depends`, `json`, `LitReviewRequest`, `generate_literature_review`, `get_current_user`, and `db_papers` from `papers.py`.
- **Dependents:** None in the running app; it is not mounted in `main.py`.
- **Edge cases handled:** Too few papers, missing IDs, and exceptions during synthesis.
- **Known limitations / TODOs:** It passes a JSON string to `generate_literature_review` even though the service expects a list, so the route would misbehave if mounted.

#### `backend/app/core/config.py`
- **File path:** [backend/app/core/config.py](backend/app/core/config.py)
- **Purpose:** Central application settings loaded from environment variables.
- **Inputs:** `.env` values and defaults from the class definition.
- **Outputs:** A shared `settings` object.
- **Internal logic:** `BaseSettings` resolves environment variables and ignores unknown keys.
- **State managed:** Configuration values only.
- **Dependencies:** `pydantic_settings.BaseSettings`.
- **Dependents:** `auth.py` uses JWT settings, and `main.py` indirectly depends on the same settings through the auth router.
- **Edge cases handled:** Missing values fall back to defaults.
- **Known limitations / TODOs:** `pydantic-settings` is not declared in `requirements.txt`.

#### `backend/app/core/models.py`
- **File path:** [backend/app/core/models.py](backend/app/core/models.py)
- **Purpose:** Typed Pydantic schemas for paper metadata and review requests.
- **Inputs:** JSON payloads or internal object construction.
- **Outputs:** Validated Pydantic model instances.
- **Internal logic:** It declares nested models for metadata, analysis, extracted papers, and review requests.
- **State managed:** None.
- **Dependencies:** `pydantic.BaseModel` and `typing.List`.
- **Dependents:** `review.py` uses `LitReviewRequest`; the other models are currently unused in runtime code.
- **Edge cases handled:** Pydantic validation on field presence and type shape.
- **Known limitations / TODOs:** The model fields do not match the runtime shape used by `main.py` and `ai_service.py`, so the schema has drifted from actual responses.

#### `backend/app/services/pdf_service.py`
- **File path:** [backend/app/services/pdf_service.py](backend/app/services/pdf_service.py)
- **Purpose:** Extract text and metadata from uploaded PDFs.
- **Inputs:** A FastAPI `UploadFile` object.
- **Outputs:** A dictionary with `text` and `metadata` keys.
- **Internal logic:** It reads the uploaded bytes, opens the PDF through PyMuPDF, iterates every page, concatenates extracted text, and returns `doc.metadata`.
- **State managed:** None.
- **Dependencies:** `fitz` from PyMuPDF and `UploadFile`.
- **Dependents:** `main.py` uses `process_pdf` directly.
- **Edge cases handled:** None beyond assuming the file is a valid PDF.
- **Known limitations / TODOs:** No page-level error isolation, OCR fallback, password-protected PDF handling, or malicious PDF screening.

#### `backend/app/services/ai_service.py`
- **File path:** [backend/app/services/ai_service.py](backend/app/services/ai_service.py)
- **Purpose:** Groq API wrapper for single-paper analysis, paper comparison, and literature review generation.
- **Inputs:** Paper text, paired paper summaries, topic strings, and paper summary lists.
- **Outputs:** Structured Python dictionaries or fallback error dictionaries.
- **Internal logic:** It trims context, creates system/user prompts, calls Groq chat completions, strips code fences from JSON, and falls back to smaller models when requests are too large or rate-limited.
- **State managed:** A module-level `client` instance and model selection constants.
- **Dependencies:** `json`, `os`, and `Groq`.
- **Dependents:** `main.py`, `papers.py`, and `review.py` all depend on these functions.
- **Edge cases handled:** Missing API key, JSON parsing failures, model size/rate errors, and general API exceptions.
- **Known limitations / TODOs:** The prompts are strongly coupled to the current frontend output shape; changes to response keys require coordinated edits in the UI and backend.

### Frontend modules and components

#### `frontend/src/main.jsx`
- **File path:** [frontend/src/main.jsx](frontend/src/main.jsx)
- **Purpose:** React application bootstrap.
- **Inputs:** The root DOM node from `index.html`.
- **Outputs:** Mounted React application.
- **Internal logic:** It creates the root, wraps the app in `React.StrictMode`, and imports the global Tailwind stylesheet.
- **State managed:** None.
- **Dependencies:** `react-dom/client`, `App`, and `./index.css`.
- **Dependents:** Everything in the frontend depends on this entry point.
- **Edge cases handled:** If the root node is missing, the app cannot mount.
- **Known limitations / TODOs:** None.

#### `frontend/src/App.jsx`
- **File path:** [frontend/src/App.jsx](frontend/src/App.jsx)
- **Purpose:** Defines client routes and decides when the app shell should appear.
- **Inputs:** Browser URL path and nested route children.
- **Outputs:** Rendered page component for the active route.
- **Internal logic:** It wraps the login route without the shell and wraps every other route in `AppShell`.
- **State managed:** None directly, but it reads the current location from React Router.
- **Dependencies:** `react-router-dom`, page components, and `AppShell`.
- **Dependents:** The entire frontend route system.
- **Edge cases handled:** Root path `/` is treated as the login page.
- **Known limitations / TODOs:** No protected-route guard and no fallback 404 route.

#### `frontend/src/components/layout/AppShell.jsx`
- **File path:** [frontend/src/components/layout/AppShell.jsx](frontend/src/components/layout/AppShell.jsx)
- **Purpose:** Provides the left sidebar, top header, and page body frame for authenticated routes.
- **Inputs:** `children` content from the active route.
- **Outputs:** Wrapped page layout.
- **Internal logic:** It renders the sidebar, a sticky header that displays the current path, and a motion-wrapped main content area.
- **State managed:** None.
- **Dependencies:** `Sidebar`, `framer-motion`, and the `window.location` browser API.
- **Dependents:** All non-login routes.
- **Edge cases handled:** The header path becomes an empty string for `/`, which it normalizes to `Home`.
- **Known limitations / TODOs:** Uses `window.location.pathname` instead of a router hook, so the header depends on browser state rather than React state.

#### `frontend/src/components/layout/Sidebar.jsx`
- **File path:** [frontend/src/components/layout/Sidebar.jsx](frontend/src/components/layout/Sidebar.jsx)
- **Purpose:** Global navigation sidebar for the application.
- **Inputs:** Active route state from React Router.
- **Outputs:** Side navigation links and a nonfunctional exit button.
- **Internal logic:** It maps a static navigation array to `NavLink` elements and highlights the active section.
- **State managed:** None.
- **Dependencies:** `react-router-dom`, `lucide-react`, and `cn` from `utils.ts`.
- **Dependents:** `AppShell`.
- **Edge cases handled:** Active and inactive styles are handled through the `NavLink` render function.
- **Known limitations / TODOs:** The logout/exit button is decorative only.

#### `frontend/src/components/ui/Button.jsx`
- **File path:** [frontend/src/components/ui/Button.jsx](frontend/src/components/ui/Button.jsx)
- **Purpose:** Reusable button primitive with visual variants and sizes.
- **Inputs:** `variant`, `size`, `className`, `children`, and native button props.
- **Outputs:** A styled `<button>` element.
- **Internal logic:** It merges base classes with variant and size maps using `cn`.
- **State managed:** None.
- **Dependencies:** `React` and `cn`.
- **Dependents:** Most pages use it for actions.
- **Edge cases handled:** Disabled state is styled through Tailwind utility classes.
- **Known limitations / TODOs:** Variants are hand-authored and not centralized in a design-token system.

#### `frontend/src/components/ui/Card.jsx`
- **File path:** [frontend/src/components/ui/Card.jsx](frontend/src/components/ui/Card.jsx)
- **Purpose:** Shared card container and subcomponent set.
- **Inputs:** `className`, `children`, and native div props.
- **Outputs:** Styled card blocks for sections, headers, and footers.
- **Internal logic:** It exposes `Card`, `CardHeader`, `CardTitle`, `CardContent`, and `CardFooter` wrappers with Tailwind classes.
- **State managed:** None.
- **Dependencies:** `React` and `cn`.
- **Dependents:** All major pages use the card primitives.
- **Edge cases handled:** None beyond class merging.
- **Known limitations / TODOs:** It is a styling wrapper only, not a semantic design-system primitive with variants.

#### `frontend/src/components/ui/Badge.jsx`
- **File path:** [frontend/src/components/ui/Badge.jsx](frontend/src/components/ui/Badge.jsx)
- **Purpose:** Small status and label pill component.
- **Inputs:** `variant`, `className`, `children`, and native span props.
- **Outputs:** A styled `<span>` badge.
- **Internal logic:** It maps a variant name to Tailwind color combinations and merges with `cn`.
- **State managed:** None.
- **Dependencies:** `React` and `cn`.
- **Dependents:** Dashboard, upload, topic input, analysis, and review views.
- **Edge cases handled:** Default variant styling is provided when no variant is passed.
- **Known limitations / TODOs:** The variant system is small and not theme-aware.

#### `frontend/src/lib/utils.ts`
- **File path:** [frontend/src/lib/utils.ts](frontend/src/lib/utils.ts)
- **Purpose:** Shared class name merge helper.
- **Inputs:** Any number of class name values.
- **Outputs:** A deduplicated Tailwind-safe class string.
- **Internal logic:** It uses `clsx` to flatten conditional values and `twMerge` to resolve Tailwind conflicts.
- **State managed:** None.
- **Dependencies:** `clsx` and `tailwind-merge`.
- **Dependents:** `Button`, `Card`, `Badge`, `Sidebar`, and `AnalysisView`.
- **Edge cases handled:** Conflicting Tailwind utilities are resolved predictably.
- **Known limitations / TODOs:** It is a single helper file with no additional utility grouping.

#### `frontend/src/pages/Login.jsx`
- **File path:** [frontend/src/pages/Login.jsx](frontend/src/pages/Login.jsx)
- **Purpose:** Mock sign-in screen that obtains and stores a JWT.
- **Inputs:** Email and password fields.
- **Outputs:** `authToken` and `tokenType` in `localStorage`, or an error message.
- **Internal logic:** It posts a form-encoded login request to the backend, stores the returned token, and redirects to `/dashboard` on success.
- **State managed:** `email`, `password`, `loading`, and `error`.
- **Dependencies:** `useState`, `useNavigate`, `Button`, `Card`, and icon components.
- **Dependents:** The auth flow starts here.
- **Edge cases handled:** Network failure, invalid credentials, and missing token responses.
- **Known limitations / TODOs:** Hardcoded styling uses some Tailwind class aliases flagged by diagnostics, and the token is not consumed by later pages.

#### `frontend/src/pages/Dashboard.jsx`
- **File path:** [frontend/src/pages/Dashboard.jsx](frontend/src/pages/Dashboard.jsx)
- **Purpose:** Main landing dashboard for the paper library.
- **Inputs:** Backend library data.
- **Outputs:** Document cards, summary metrics, and navigation actions.
- **Internal logic:** It fetches `/api/library`, counts documents, renders a loading skeleton, shows an empty state, or renders each stored paper as a clickable card.
- **State managed:** `library` and `loading`.
- **Dependencies:** `useEffect`, `useState`, `useNavigate`, `Card`, `Button`, `Badge`, and icons.
- **Dependents:** Users land here after login or after uploading a paper.
- **Edge cases handled:** Empty repository, backend fetch failure, and route navigation to analysis.
- **Known limitations / TODOs:** It uses a hardcoded backend URL and dynamic Tailwind color strings that may not be fully statically generated.

#### `frontend/src/pages/Upload.jsx`
- **File path:** [frontend/src/pages/Upload.jsx](frontend/src/pages/Upload.jsx)
- **Purpose:** Drag-and-drop PDF ingestion screen.
- **Inputs:** One or more selected PDF files.
- **Outputs:** Upload request to the backend and navigation to analysis on success.
- **Internal logic:** It builds a queue, accepts dropped/selected PDFs, but only submits the first file in the queue to the backend.
- **State managed:** `files`, `isUploading`, `dragActive`.
- **Dependencies:** `useRef`, `useNavigate`, `Card`, `Button`, `Badge`, `framer-motion`, and icons.
- **Dependents:** Dashboard CTA and the document ingestion workflow.
- **Edge cases handled:** Invalid file types, drag state toggling, empty queue, and network failure.
- **Known limitations / TODOs:** The multi-file queue is misleading because only `files[0]` is posted.

#### `frontend/src/pages/TopicInput.jsx`
- **File path:** [frontend/src/pages/TopicInput.jsx](frontend/src/pages/TopicInput.jsx)
- **Purpose:** Captures the review topic and prepares paper IDs for synthesis.
- **Inputs:** Topic textarea and current library state fetched from the backend.
- **Outputs:** Navigation to `/literature-review` and persistence to `localStorage`.
- **Internal logic:** It fetches the library, derives the list of IDs, and stores the topic plus paper IDs for later reuse.
- **State managed:** `topic` and `libraryIds`.
- **Dependencies:** `useEffect`, `useNavigate`, `Card`, `Button`, `Badge`, and icons.
- **Dependents:** The literature review generation screen.
- **Edge cases handled:** Empty topic, empty library, and fetch failures.
- **Known limitations / TODOs:** It defaults to all document IDs rather than letting the user choose a subset.

#### `frontend/src/pages/LiteratureReview.jsx`
- **File path:** [frontend/src/pages/LiteratureReview.jsx](frontend/src/pages/LiteratureReview.jsx)
- **Purpose:** Generates and displays the literature review report.
- **Inputs:** Topic and paper IDs from route state, `localStorage`, or a fallback library fetch.
- **Outputs:** Rendered report, error messaging, and a plain-text export.
- **Internal logic:** It hydrates the inputs, sends them to `/api/generate-review`, renders loading/error/content states, and flattens the generated review object into export text.
- **State managed:** `reviewData`, `loading`, `error`, `resolvedTopic`, and `resolvedPaperIds`.
- **Dependencies:** `useEffect`, `useLocation`, `useNavigate`, `Card`, `Button`, `Badge`, `framer-motion`, and icons.
- **Dependents:** The topic input flow and dashboard navigation.
- **Edge cases handled:** Missing topic, missing paper IDs, malformed `localStorage`, and backend errors.
- **Known limitations / TODOs:** The export format is a simple concatenation of object values, not a structured report template.

#### `frontend/src/pages/ComparisonView.jsx`
- **File path:** [frontend/src/pages/ComparisonView.jsx](frontend/src/pages/ComparisonView.jsx)
- **Purpose:** Displays pairwise comparison results between papers.
- **Inputs:** The current backend library.
- **Outputs:** Similarities, differences, complementary aspects, and combined insights.
- **Internal logic:** It fetches the library, posts paper IDs to `/api/compare`, and renders loading, empty, error, or result states.
- **State managed:** `comparison`, `loading`, and `error`.
- **Dependencies:** `useEffect`, `useNavigate`, `Card`, `Button`, `Badge`, `framer-motion`, and icons.
- **Dependents:** Dashboard CTA and manual comparison exploration.
- **Edge cases handled:** Less than two documents, server errors, and refresh retry.
- **Known limitations / TODOs:** The frontend sends all library IDs, but the backend currently compares only the first two valid papers.

#### `frontend/src/pages/AnalysisView.jsx`
- **File path:** [frontend/src/pages/AnalysisView.jsx](frontend/src/pages/AnalysisView.jsx)
- **Purpose:** Detailed per-paper analysis dashboard.
- **Inputs:** `paperData` passed through route state.
- **Outputs:** Tabbed summary, methodology, results, limitations, and a citation sidebar.
- **Internal logic:** It checks for missing paper state, creates a tab strip, and switches content based on the active tab.
- **State managed:** `activeTab`.
- **Dependencies:** `useLocation`, `useNavigate`, `Card`, `Button`, `Badge`, `cn`, `framer-motion`, and icons.
- **Dependents:** Dashboard paper cards and upload success navigation.
- **Edge cases handled:** Missing route state and absent gap data.
- **Known limitations / TODOs:** The contribution rendering expects newline-delimited text and the page assumes the backend analysis shape is stable.

#### `frontend/index.css`
- **File path:** [frontend/index.css](frontend/index.css)
- **Purpose:** Legacy stylesheet from the template.
- **Inputs:** None.
- **Outputs:** A simple slate background on `body`.
- **Internal logic:** It imports Tailwind and overrides the body background.
- **State managed:** None.
- **Dependencies:** Tailwind CSS.
- **Dependents:** None in the current runtime, because `main.jsx` imports `src/index.css` instead.
- **Known limitations / TODOs:** It is effectively dead styling code.

#### `frontend/src/index.css`
- **File path:** [frontend/src/index.css](frontend/src/index.css)
- **Purpose:** Global Tailwind theme and design-token stylesheet.
- **Inputs:** Browser root styles and Tailwind utility generation.
- **Outputs:** HSL-based CSS variables, font family, color tokens, and scrollbar styling.
- **Internal logic:** It imports Outfit from Google Fonts, maps theme variables, defines light and dark token sets, and applies body/base styles.
- **State managed:** CSS variables for colors, radius, and typography.
- **Dependencies:** Tailwind v4, browser CSS variables, and a remote Google Fonts import.
- **Dependents:** The entire React UI.
- **Edge cases handled:** Dark theme tokens are defined even though the UI is mostly light mode.
- **Known limitations / TODOs:** The page still uses a default-looking Tailwind palette rather than a fully custom branded design system.

#### `frontend/src/App.css`
- **File path:** [frontend/src/App.css](frontend/src/App.css)
- **Purpose:** Empty legacy stylesheet.
- **Inputs:** None.
- **Outputs:** None.
- **Internal logic:** The file contains only whitespace.
- **State managed:** None.
- **Dependencies:** None.
- **Dependents:** None.
- **Known limitations / TODOs:** Safe to delete if no build tool references remain.

---

## 8. FUNCTIONS & METHODS REFERENCE

### Backend functions
| Function | File | Signature | Purpose | Key behavior |
|---|---|---|---|---|
| `create_access_token` | [backend/app/api/auth.py](backend/app/api/auth.py) | `create_access_token(data: dict)` | Sign a JWT access token | Copies payload, adds `exp`, and encodes with HS256 |
| `login` | [backend/app/api/auth.py](backend/app/api/auth.py) | `async def login(form_data: OAuth2PasswordRequestForm = Depends())` | Authenticate the mock user | Validates hardcoded credentials and returns token JSON |
| `get_current_user` | [backend/app/api/auth.py](backend/app/api/auth.py) | `async def get_current_user(token: str = Depends(oauth2_scheme))` | Resolve a username from a bearer token | Decodes JWT and returns the `sub` claim |
| `_extract_year` | [backend/app/main.py](backend/app/main.py) | `def _extract_year(metadata: dict) -> str` | Derive a publication year | Reads PDF metadata and falls back to current year |
| `get_library` | [backend/app/main.py](backend/app/main.py) | `async def get_library()` | Return all stored papers | Serializes `db_papers.values()` |
| `upload_paper` | [backend/app/main.py](backend/app/main.py) | `async def upload_paper(file: UploadFile = File(...))` | Ingest and analyze a PDF | Validates extension, extracts text, calls Groq, stores paper record |
| `api_compare_papers` | [backend/app/main.py](backend/app/main.py) | `async def api_compare_papers(request: CompareRequest)` | Compare two papers | Uses first two valid IDs and delegates to `compare_papers` |
| `api_generate_review` | [backend/app/main.py](backend/app/main.py) | `async def api_generate_review(request: ReviewRequest)` | Generate a literature review | Validates topic and paper IDs, then calls `generate_literature_review` |
| `process_pdf` | [backend/app/services/pdf_service.py](backend/app/services/pdf_service.py) | `async def process_pdf(file: UploadFile)` | Extract text and metadata | Reads the upload into memory, opens it with PyMuPDF, and concatenates page text |
| `_parse_json_response` | [backend/app/services/ai_service.py](backend/app/services/ai_service.py) | `def _parse_json_response(response_text: str) -> dict` | Parse model JSON | Strips markdown fences and parses JSON |
| `_call_groq` | [backend/app/services/ai_service.py](backend/app/services/ai_service.py) | `def _call_groq(messages: list, max_tokens: int = 2048, primary_model: str = None) -> str` | Execute Groq chat completions | Tries the primary model and then a fallback model on size/rate errors |
| `analyze_paper` | [backend/app/services/ai_service.py](backend/app/services/ai_service.py) | `async def analyze_paper(text: str) -> dict` | Build structured paper analysis | Trims context, prompts the model, and returns analysis fields or fallback data |
| `compare_papers` | [backend/app/services/ai_service.py](backend/app/services/ai_service.py) | `async def compare_papers(text1: str, text2: str) -> dict` | Compare two paper summaries | Sends paired contexts to the model and falls back to heuristic text if parsing fails |
| `generate_literature_review` | [backend/app/services/ai_service.py](backend/app/services/ai_service.py) | `async def generate_literature_review(topic: str, papers_data: list) -> dict` | Write a review from multiple papers | Summarizes up to six papers and asks the model for a structured review |

### Frontend handlers and hooks
| Function / handler | File | Signature | Purpose | Key behavior |
|---|---|---|---|---|
| `LayoutWrapper` | [frontend/src/App.jsx](frontend/src/App.jsx) | `const LayoutWrapper = ({ children }) => { ... }` | Decide whether to render the app shell | Shows the shell on every route except `/` |
| `handleLogin` | [frontend/src/pages/Login.jsx](frontend/src/pages/Login.jsx) | `const handleLogin = async (e) => { ... }` | Submit login form | Posts FormData, stores JWT, and navigates to dashboard |
| `fetchLibrary` | [frontend/src/pages/Dashboard.jsx](frontend/src/pages/Dashboard.jsx) | `const fetchLibrary = async () => { ... }` | Load the paper list | Fetches `/api/library` and updates local state |
| `handleFileChange` | [frontend/src/pages/Upload.jsx](frontend/src/pages/Upload.jsx) | `const handleFileChange = (e) => { ... }` | Add selected PDFs to the upload queue | Filters for PDF files and appends them to state |
| `removeFile` | [frontend/src/pages/Upload.jsx](frontend/src/pages/Upload.jsx) | `const removeFile = (index) => { ... }` | Remove a queued file | Filters one entry out of the array |
| `handleDrag` | [frontend/src/pages/Upload.jsx](frontend/src/pages/Upload.jsx) | `const handleDrag = (e) => { ... }` | Control drag state | Toggles `dragActive` on drag events |
| `handleDrop` | [frontend/src/pages/Upload.jsx](frontend/src/pages/Upload.jsx) | `const handleDrop = (e) => { ... }` | Accept dropped PDFs | Filters dropped files and appends them to queue state |
| `submitUpload` | [frontend/src/pages/Upload.jsx](frontend/src/pages/Upload.jsx) | `const submitUpload = async () => { ... }` | Upload the first queued file | Posts one file to `/api/upload` and navigates to analysis |
| `handleSubmit` | [frontend/src/pages/TopicInput.jsx](frontend/src/pages/TopicInput.jsx) | `const handleSubmit = (e) => { ... }` | Save topic and paper IDs | Persists to `localStorage` and routes to the review page |
| `hydrateAndGenerate` | [frontend/src/pages/LiteratureReview.jsx](frontend/src/pages/LiteratureReview.jsx) | `const hydrateAndGenerate = async () => { ... }` | Resolve inputs and trigger synthesis | Reads route state, localStorage, or library fallback, then starts review generation |
| `generateReview` | [frontend/src/pages/LiteratureReview.jsx](frontend/src/pages/LiteratureReview.jsx) | `const generateReview = async (topic, paperIds) => { ... }` | Call the review endpoint | Posts JSON payload and stores generated review data |
| `handleExport` | [frontend/src/pages/LiteratureReview.jsx](frontend/src/pages/LiteratureReview.jsx) | `const handleExport = () => { ... }` | Export the generated report | Converts the review object to text and triggers a download |
| `fetchComparison` | [frontend/src/pages/ComparisonView.jsx](frontend/src/pages/ComparisonView.jsx) | `const fetchComparison = async () => { ... }` | Recompute the comparison matrix | Loads the library, posts paper IDs, and updates state |

---

## 9. API & ROUTES

### Backend HTTP routes
| Method | Path | Purpose | Request shape | Response shape | Auth |
|---|---|---|---|---|---|
| `POST` | `/api/v1/auth/login` | Mock login and JWT issue | OAuth2 password form with `username` and `password` | `{"access_token": "...", "token_type": "bearer"}` | None enforced beyond credentials check |
| `GET` | `/api/library` | Return all stored papers | None | Array of paper objects from in-memory store | None |
| `POST` | `/api/upload` | Upload and analyze a PDF | Multipart form with `file` | `{"status": "success", "data": paper}` | None |
| `POST` | `/api/compare` | Compare two stored papers | JSON body with `paper_ids: string[]` | `{"status": "success", "data": comparison}` | None |
| `POST` | `/api/generate-review` | Generate literature review | JSON body with `topic` and `paper_ids` | `{"status": "success", "data": review_payload}` | None |

### Legacy routes that exist but are not mounted
| Method | Path | File | Status | Notes |
|---|---|---|---|---|
| `POST` | `/upload` | [backend/app/api/papers.py](backend/app/api/papers.py) | Unused | References a missing `extract_text_from_pdf` function |
| `GET` | `/{paper_id}` | [backend/app/api/papers.py](backend/app/api/papers.py) | Unused | Reads from a separate in-memory dictionary |
| `POST` | `/generate` | [backend/app/api/review.py](backend/app/api/review.py) | Unused | Passes a JSON string where the service expects a paper list |

### Frontend route map
| Path | Page | Purpose |
|---|---|---|
| `/` | `Login` | Mock authentication screen |
| `/dashboard` | `Dashboard` | Repository overview and metrics |
| `/upload` | `Upload` | PDF staging and ingestion |
| `/analysis` | `AnalysisView` | Deep analysis of a selected paper |
| `/topic-input` | `TopicInput` | Capture review topic and seed papers |
| `/comparison` | `ComparisonView` | Cross-paper synthesis matrix |
| `/literature-review` | `LiteratureReview` | Generated review report |

### Middleware and auth chain
The backend installs CORS middleware before route registration so the frontend can call localhost APIs during development. JWT support is present, but only the login endpoint and the `get_current_user` dependency use it. The core upload, compare, and review routes in `main.py` do not require an authenticated token.

---

## 10. DATA LAYER & MODELS

### Database type and connection strategy
There is no database in this snapshot. Paper state is held in a process-local dictionary inside `backend/app/main.py`, and the legacy routers each define their own separate dictionaries. On restart, the library is lost. The only persistent data store is the filesystem, where uploaded PDFs and logs are written.

### File and object model
| Model / object | File | Fields | Notes |
|---|---|---|---|
| `PaperMetadata` | [backend/app/core/models.py](backend/app/core/models.py) | `title`, `authors`, `year`, `abstract` | Not aligned with current runtime responses |
| `DeepAnalysis` | [backend/app/core/models.py](backend/app/core/models.py) | `problem_statement`, `methodology`, `key_findings`, `limitations`, `future_work` | Not aligned with current runtime responses |
| `ExtractedPaper` | [backend/app/core/models.py](backend/app/core/models.py) | `id`, `metadata`, `deep_analysis`, `citations`, `keywords` | Currently unused |
| `LitReviewRequest` | [backend/app/core/models.py](backend/app/core/models.py) | `paper_ids`, `topic` | Used by `review.py` |
| `CompareRequest` | [backend/app/main.py](backend/app/main.py) | `paper_ids` | Used by the active compare route |
| `ReviewRequest` | [backend/app/main.py](backend/app/main.py) | `topic`, `paper_ids` | Used by the active review route |

### Stored paper shape in `main.py`
The active upload route persists a paper object with `id`, `title`, `authors`, `year`, `abstract_summary`, `deep_analysis`, and `gaps`. That shape is produced dynamically from the uploaded file metadata and the Groq analysis result. It is not validated by a dedicated Pydantic schema.

### Query and update patterns
The current pattern is read-all, append-on-upload, and read-by-ID in memory. There is no pagination, filtering, deletion, or update operation. The dashboard reads the entire library list, comparison reads the first two valid items, and the review flow collects paper IDs into a batch.

### Migrations and caching
No migrations exist. No cache layer exists beyond React state, route state, and browser `localStorage` for the review topic and paper ID list.

---

## 11. DATA FLOW & STATE MANAGEMENT

### End-to-end data flow diagram
```text
Login form
  -> POST /api/v1/auth/login
  -> JWT stored in localStorage
  -> navigate to /dashboard

Dashboard
  -> GET /api/library
  -> render library cards
  -> open /analysis with paperData in route state

Upload
  -> select or drop PDF
  -> POST /api/upload (multipart)
  -> backend extracts PDF text
  -> Groq analyzes text
  -> backend stores paper in memory
  -> navigate to /analysis

Comparison
  -> GET /api/library
  -> POST /api/compare
  -> render pairwise synthesis

Topic input
  -> GET /api/library
  -> store topic and IDs in localStorage
  -> navigate to /literature-review

Literature review
  -> resolve topic and IDs from route state/localStorage/library
  -> POST /api/generate-review
  -> render structured report
```

### State management boundaries
The frontend uses only local component state, route state, and `localStorage`. There is no Redux, Zustand, React Query, or context store. The backend uses only module-level process state and function-local data. This makes the app easy to reason about but fragile across refreshes and process restarts.

### Async handling
Each page with network work uses a loading flag and an error branch. The upload and review flows block user interaction while the request is in flight. The dashboard and comparison views use simple skeletons or loading copy. There is no retry queue, background task scheduler, or offline queue.

### State propagation notes
Route state is used for immediate handoff from dashboard/upload to analysis, while `localStorage` is used as a fallback for the review flow. That dual strategy helps the report page survive navigation churn, but it also makes state ownership ambiguous.

---

## 12. SECURITY IMPLEMENTATION

### Authentication mechanism
The project has a JWT-based login route, but the implementation is a mock. The frontend collects an email and password, sends them to `/api/v1/auth/login`, and stores the returned token in `localStorage`. The backend verifies the request against a hardcoded email and password, then signs a JWT with `HS256`. `get_current_user` can validate bearer tokens, but the core application routes do not require it.

### Authorization and RBAC
There is no real RBAC. The only authorization dependency is the JWT helper in `auth.py`, and it is only consumed by the unused legacy review router. In practice, the active document library, upload, compare, and review routes are open to any client that can reach the backend.

### Input validation and sanitization
The backend validates file type by extension, checks that review topics are non-empty, and verifies that enough valid IDs exist before comparison. The frontend also filters files by MIME type or `.pdf` suffix. There is no content security scan, no file size limit, no prompt-injection defense, and no deep semantic validation of uploaded text.

### Sensitive data handling
The repository contains a real-looking Groq API key in `.env`. That file should be treated as sensitive and rotated if it has ever been used outside local experimentation. The startup script exports environment variables by parsing `.env` with `xargs`, which is brittle and can leak or mis-handle special values.

### Security concerns observed
- Hardcoded login credentials in the backend.
- JWT token stored in browser `localStorage`.
- Core routes do not require authentication.
- In-memory storage means data is lost on restart.
- Uploaded PDFs are accepted by extension only.
- No rate limiting or CSRF protection is present.
- No prompt hardening or content moderation is applied to user-provided research text.
- Duplicate legacy routers increase the chance of drift and broken imports.

---

## 13. TESTING SUITE

### Testing frameworks and libraries
No automated test framework is committed in this workspace snapshot. There are no Pytest files, no frontend component tests, no Playwright E2E tests, and no backend integration test harness.

### Folder structure and naming
There is no `tests/` directory or test file naming convention present.

### What is tested
Nothing is currently tested through code. The closest validation artifacts are the npm scripts (`build`, `lint`, `preview`) and the FastAPI/Uvicorn startup path.

### Commands that exist today
| Area | Command | Purpose |
|---|---|---|
| Backend startup | `python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload` | Run the API server in dev mode |
| Frontend dev | `npm run dev` | Launch the Vite app |
| Frontend build | `npm run build` | Production bundle |
| Frontend lint | `npm run lint` | Static analysis of JS/JSX files |
| Frontend preview | `npm run preview` | Preview built assets |

### Coverage observations
The backend service logic is the most fragile area because it contains the critical model prompts and no tests. The frontend has multiple user flows and state transitions but no component or route tests to validate them.

### Mocking strategy
No formal mocking strategy exists. The backend uses hardcoded credentials and in-memory dictionaries as built-in test-like simplifications rather than explicit test doubles.

---

## 14. EXTERNAL INTEGRATIONS

### Groq API
Groq is the only true external API in the runtime path. `ai_service.py` instantiates a Groq client from `GROQ_API_KEY` and uses chat completions to analyze papers, compare papers, and generate review text. The code includes fallback model logic for request size and rate-limit errors.

### PyMuPDF
PyMuPDF is used to parse PDF uploads. It is a local library dependency, but it is the core technology that makes ingestion possible.

### Browser and frontend libraries
The frontend depends on `react-router-dom` for navigation, `framer-motion` for animation, and `lucide-react` for icons. These are packaged dependencies rather than remote services, but they define most of the client-side experience.

### Remote styling asset
`frontend/src/index.css` imports the Outfit font from Google Fonts. `LiteratureReview.jsx` also uses a background image URL from `transparenttextures.com`. Both are runtime external requests that should be considered part of the UI dependency surface.

### Error handling for external failures
Groq calls return fallback dictionaries when the API key is missing or the response cannot be parsed. Frontend fetch calls show loading and error states, but there is no structured retry policy. The startup scripts do not verify internet connectivity or service health before launching.

### Webhooks
No webhooks are configured.

---

## 15. DEVELOPER GUIDE

### Local setup
1. Ensure Python 3, Node.js, and npm are installed.
2. Run `./setup.sh` from the repo root.
3. Confirm that `.env` exists and contains a valid `GROQ_API_KEY`.
4. Start the app with `./start.sh`.

### Development mode commands
| Task | Command |
|---|---|
| Install backend and frontend dependencies | `./setup.sh` |
| Start both servers together | `./start.sh` |
| Backend only | `cd backend && python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload` |
| Frontend only | `cd frontend && npm run dev` |
| Frontend build | `cd frontend && npm run build` |
| Frontend lint | `cd frontend && npm run lint` |

### Production build notes
There is no production deploy script. A production setup would need a persistent database, a real authentication model, environment validation, and deployment manifests. The frontend can be built with `npm run build`, but the backend is still a development-style FastAPI app with in-memory state.

### Debugging tips
- Check `logs/backend.log` for FastAPI or Groq failures.
- Check `logs/frontend.log` for Vite startup or runtime issues.
- If upload or review fails, verify that `GROQ_API_KEY` is present and valid.
- If routes are blank after navigation, confirm the React Router path and route state.
- If imports fail in the backend, remember that `pydantic-settings` is missing from `requirements.txt`.

### How to add a new feature safely
1. Decide whether the feature belongs in the backend route layer, the service layer, or the React page layer.
2. Reuse the existing `Card`, `Button`, `Badge`, and `cn()` primitives on the frontend.
3. If the feature needs AI output, keep the backend response schema aligned with the UI before changing prompts.
4. Add a route only in `main.py` unless the legacy routers are being formally revived.
5. If persistent paper state is required, introduce a repository/database layer before expanding the feature.

---

## 16. KNOWN ISSUES, TODOS & TECH DEBT

### Explicit TODO / FIXME scan
No `TODO`, `FIXME`, `HACK`, or `XXX` comments were found in the scanned source files.

### Major technical debt items
- `backend/app/api/papers.py` and `backend/app/api/review.py` are legacy modules that are not wired into the running app.
- `backend/app/services/pdf_service.py` exposes `process_pdf`, while `papers.py` tries to import a nonexistent `extract_text_from_pdf` function.
- `backend/app/core/config.py` depends on `pydantic-settings`, but the package is absent from `requirements.txt`.
- The active paper store is in memory only and disappears on restart.
- The active routes in `main.py` do not require a bearer token.
- The frontend uses hardcoded localhost API URLs in some pages and environment-variable fallbacks in others.
- `frontend/index.css` and `frontend/src/App.css` are legacy or empty stylesheets.
- Template assets such as `react.svg` and `vite.svg` are unused.
- The login token is stored in `localStorage` but not enforced on subsequent API calls.
- `Upload.jsx` allows multiple files in the queue but uploads only the first one.
- `ComparisonView.jsx` sends all paper IDs while the backend compares only the first two valid ones.
- `Dashboard.jsx` uses dynamic Tailwind class names that may not be fully generated by static scanning.
- The shell scripts parse `.env` with `xargs`, which is brittle for complex values.

### Fragile areas
The backend AI prompt pipeline is the most fragile part of the system because it depends on exact response shapes from Groq. The second most fragile area is the duplicated route code in the legacy modules, because it can drift silently from the active application behavior.

### Suggested improvements
1. Introduce a real database or durable document store.
2. Centralize API responses and request schemas.
3. Add a proper auth flow and protect the core endpoints.
4. Add backend and frontend tests.
5. Replace hardcoded URLs with a single API client abstraction.
6. Remove or fix legacy routers and unused template assets.
7. Add dependency validation for the Python environment.

---

## 17. CODEBASE METRICS & OBSERVATIONS

### File counts from the workspace scan
The broad scan returned 61 workspace paths, including directories and generated artifacts. Of those, 55 are files discovered by extension-based inventory and 6 are directory entries or root-level container paths that appeared in the broader scan output.

### Breakdown by file type
| Type | Count | Notes |
|---|---|---|
| `.py` | 8 | Backend source files |
| `.jsx` | 14 | Frontend components and pages |
| `.js` | 4 | Vite, ESLint, PostCSS, and Tailwind config files |
| `.ts` | 1 | `frontend/src/lib/utils.ts` |
| `.css` | 3 | Global styles and legacy stylesheet files |
| `.json` | 5 | Package manifests, VS Code settings, and lock/config files |
| `.md` | 1 | Frontend README |
| `.sh` | 2 | Setup and startup scripts |
| `.svg` | 4 | Favicon and template/icon assets |
| `.pdf` | 3 | Sample documents and an uploaded paper artifact |
| `.log` | 2 | Backend and frontend runtime logs |
| `.pyc` | 8 | Python bytecode caches |
| `.ico` | 1 | Browser favicon |
| `.zip` | 1 | Repository snapshot archive |
| `.env` / `.env.example` | 2 | Local environment files |

### Largest complexity hotspots
| File | Why it is large | Risk |
|---|---|---|
| [frontend/src/pages/LiteratureReview.jsx](frontend/src/pages/LiteratureReview.jsx) | Highest route complexity and the most state transitions | High UI and data-flow coupling |
| [frontend/src/pages/AnalysisView.jsx](frontend/src/pages/AnalysisView.jsx) | Tabbed analysis view with multiple content branches | Assumes a stable backend analysis schema |
| [frontend/src/pages/Dashboard.jsx](frontend/src/pages/Dashboard.jsx) | Fetching, metrics, empty states, and navigation in one component | Dynamic Tailwind class risk |
| [backend/app/services/ai_service.py](backend/app/services/ai_service.py) | Prompt construction, JSON parsing, fallback behavior, and model selection | Most important backend logic and most fragile integration |
| [frontend/public/icons.svg](frontend/public/icons.svg) | Large icon sprite markup | Mostly static, but verbose |

### Most imported modules
The hottest dependencies are `react`, `react-router-dom`, `fastapi`, `groq`, `framer-motion`, `lucide-react`, `tailwindcss`, `PyMuPDF`, and `python-jose`. These define the runtime shape of the project more than any other packages.

### Consistency observations
The frontend component style is fairly consistent: Tailwind utility classes, shared card/button/badge primitives, and route-based pages. The backend is less consistent because the active app in `main.py` and the legacy routers in `api/papers.py` and `api/review.py` are not aligned. Schema names also drift between the service layer and `core/models.py`.

### Overall code quality assessment
This is a capable but prototype-level full-stack research tool. The frontend is the stronger half of the product from a UX and structure standpoint. The backend demonstrates a workable AI pipeline, but it needs dependency cleanup, persistence, auth enforcement, and route consolidation before it can be treated as production-ready.

---

## FINAL NOTE

The current repository behaves like a single-user local research assistant. Its best feature is the end-to-end flow from PDF upload to AI synthesis. Its biggest structural gap is that the backend state is ephemeral and the auth/persistence story is not yet real.