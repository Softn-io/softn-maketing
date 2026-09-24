# Handoff Claude Design → Claude Code — Softn.io Site v3

This document goes with the bundle exported from Claude Design (Export → Hand off to Claude Code → send to a local agent). Paste it into the handoff message, or place it in the repo before running `/ship`.

## Your mission

The bundle contains the design of the one-page site (HTML, styles, screenshots, design chat). Your job is to **re-implement it in the project's stack while preserving the design intent** — not to copy the bundle's HTML.

## Target stack

Next.js (App Router, `app/` at the root, no `src/`) · strict TypeScript · Tailwind v4 (CSS-only) · shadcn/ui · pnpm. Full rules: `CLAUDE.md` and `.claude/rules/`.

## Translation rules

1. **Tokens**: every color, radius, spacing, shadow and typographic style in the bundle is **mapped** to a `--softn-*` variable provided by `@softn/tokens` (via `@theme`). No raw value copied, no arbitrary Tailwind value, no variable redefined in the site. A missing token: report it with a proposed name and value, do not improvise.
2. **Components**: look for the shadcn/ui equivalent first; otherwise compose it from tokens. No inline CSS from the bundle.
3. **Copy**: the bundle's texts are **mockups**. Put them in `content/fr/` as-is **only as placeholders**, then flag them to `content-seo`: nothing is published without Mel's validation.
4. **Images and icons**: `next/image` and the project's icons; list missing assets.
5. **Interactions**: reproduce hover, focus, error and loading states and animations; respect `prefers-reduced-motion`.
6. **Responsive**: check 375, 768 and 1280 px; if the bundle diverges from these breakpoints, flag it.
7. **Chatbot**: reproduce only the visual shell (button, panel, bubbles). Behavior is `chatbot-dev`'s job.
8. **Accessibility**: WCAG 2.1 AA; whatever the design does not cover (visible focus, `aria-*`, contrast) is added and mentioned in the report.

## Expected report (in French)

- Mapping bundle token → `--softn-*` variable
- Components created and shadcn components used
- Deviations from the design, and why
- Missing assets, tokens or copy
- Dependency requests, if any (nothing is installed without validation)
