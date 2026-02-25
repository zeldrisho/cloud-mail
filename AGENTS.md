# Repository Guidelines

## Project Structure & Module Organization
This repository has two main apps:
- `mail-vue/`: Vue 3 + Vite frontend. Main code is in `src/` (`views/`, `components/`, `store/`, `request/`, `router/`), with static assets in `public/`.
- `mail-worker/`: Cloudflare Worker backend using Hono. Core code is in `src/` (`api/`, `service/`, `entity/`, `dao/`, `utils/`, `security/`), with tests in `test/`.
- `doc/`: deployment notes and screenshots.
- `.github/workflows/deploy-cloudflare.yml`: CI/CD deployment pipeline.

## Build, Test, and Development Commands
Use `npm` in each subproject.

- Frontend:
  - `cd mail-vue && npm install`
  - `npm run dev` (local Vite dev server)
  - `npm run build` (release build)
  - `npm run preview` (serve built assets)
- Worker:
  - `cd mail-worker && npm install`
  - `npm run dev` (Wrangler dev using `wrangler-dev.toml`)
  - `npm run deploy` (deploy with default `wrangler.toml`)
  - `npm test` (deploy via `wrangler-test.toml`; use with care)
  - `npx vitest` (run unit/integration tests directly)

## Coding Style & Naming Conventions
- JavaScript/Vue ESM modules, semicolon-terminated statements.
- Use existing naming patterns:
  - Vue SFCs and views: lowercase directories with `index.vue` (example: `views/login/index.vue`).
  - Worker services/utilities: kebab-case files (example: `verify-record-service.js`).
  - Constants/enums: `*-enum.js` and `const/` modules.
- Match surrounding formatting in touched files; keep imports grouped and paths consistent (`@/` alias in frontend).

## Testing Guidelines
- Framework: `vitest` with Cloudflare test pool in `mail-worker/`.
- Location: `mail-worker/test/*.spec.js`.
- Naming: `*.spec.js`, descriptive `describe`/`it` blocks by API or service behavior.
- Run before PR: `cd mail-worker && npx vitest`.
- Add/update tests for any backend behavior change; include regression coverage for bug fixes.

## Commit & Pull Request Guidelines
- Follow repository commit style: short, imperative summaries (commonly Chinese), e.g., `修复登录鉴权异常` / `新增邮件转发`.
- Keep commits focused by module (`mail-vue` vs `mail-worker`).
- PRs should include:
  - clear scope and motivation,
  - linked issue (if available),
  - screenshots/GIFs for UI changes,
  - notes for config or schema-impacting changes (`wrangler*.toml`, env vars, D1/KV/R2 bindings).

## Security & Configuration Tips
- Never commit secrets; use Cloudflare/Wrangler secrets and CI variables.
- Validate required env values before deploy (see workflow checks for `JWT_SECRET`, domain JSON, and Cloudflare IDs).
- Treat `wrangler-action.toml` and binding changes as production-impacting and review carefully.
