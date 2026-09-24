# Next.js — Softn.io (one-page site, standalone app)

> Next.js rules for the site. Universal TypeScript rules → `rules/typescript.md`.
> Loaded without `paths:`: in an empty repo, a path-scoped rule only loads when Claude reads a matching file, so it would not load when the first files are created.

---

## Stack

- **Next.js (latest stable)** — App Router only
- **Node.js**: version pinned in `package.json` (`engines`) and `.nvmrc`
- **pnpm** only (never npm / yarn / bun)
- **Turbopack** enabled by default — never disable it
- `app/` **at the root** — no `src/`, no `pages/`
- **Tailwind v4** — CSS-only configuration
- **shadcn/ui** as the component library
- **Standalone** project (no monorepo, no Nx)

## Tailwind v4 — CSS only

**Forbidden:** `tailwind.config.ts`, `tailwind.config.js`, `tailwind.config.mjs` (legacy v3 format).

Configuration lives in `app/globals.css`:

```css
@import "tailwindcss";
@import "@softn/tokens/tokens.css"; /* exact path defined by the package */

@theme inline {
  --color-brand-deep: var(--softn-brand-deep);
  --radius-md: var(--softn-radius-md);
  /* … */
}
```

Use `@theme inline` (not plain `@theme`) for every variable that references another variable: the generated utilities then point straight at `--softn-*` and follow the active theme, including on a nested element.

## Tokens — never hardcoded

Colors, radii, spacing, typography and z-index go through `--softn-*` CSS variables, mapped via `@theme inline`. Core primitives (`--softn-color-violet950`) are never used directly in components: use the theme-level tokens (`--softn-brand-deep`).

- **Single source: the public npm package `@softn/tokens`**, version pinned. No local copy of the tokens, no `--softn-*` variable redefined in the site.
- **Missing token**: do not create it locally. Report it (proposed name + value); it is added in the `softn-tokens` repo, published, then the version is bumped in the site (with Mel's validation, like any dependency).
- Tokens from the Claude Design bundle are **mapped** to these variables, never copied as raw values.
- Arbitrary values are forbidden: `bg-[#1a1a1a]`, `p-[13px]`.

## Forbidden files and directories

- `middleware.ts` → use **`proxy.ts`** (Next.js 16 rename); check the current docs via Context7
- `pages/`, `getServerSideProps`, `getStaticProps`, `getInitialProps`
- `tailwind.config.*`

## Content and i18n

- **No hardcoded text in components**: everything comes from `content/fr/*.ts` (typed objects).
- Structure ready for EN (`next-intl` considered later): no sentence concatenation, no hand-coded plurals or dates.
- `<html lang="fr">`.
- The site copy itself is written in French.

## Components

- **Server Components by default.** `"use client"` only for real interactivity (chatbot, cookie banner, mobile menu), as low in the tree as possible.
- The chatbot and the Fillout embed are **lazy-loaded** (`next/dynamic`): they must not weigh on the initial load.
- shadcn/ui only, added via `pnpm dlx shadcn@latest add <component>`; list the `package.json` diff in the report (shadcn can add dependencies).

## Caching

- **Cache Components**: `use cache` directive only — never the legacy implicit mechanisms (`fetch` extensions, `unstable_cache`).
- Never fetch the same data twice per render.
- Invalidate via `revalidateTag` / `revalidatePath`.

## SEO and metadata

- `metadata` / `generateMetadata` API: `title`, `description`, `openGraph`, `alternates.canonical`, `robots`.
- `app/sitemap.ts` and `app/robots.ts`.
- JSON-LD structured data (Organization / ProfessionalService) through a dedicated component.
- A single `<h1>`; h1 → h2 → h3 hierarchy with no skipped levels.
- Fonts via `next/font` (self-hosted) — never loaded from Google Fonts.

## Third parties and consent

- **No request to a third party before consent** (Umami, Fillout iframe, etc.), except strictly necessary resources.
- Every third party added is declared in `docs/rgpd/processors.md`.

## Performance

- **Lighthouse ≥ 90** on Performance, Accessibility, Best Practices and **SEO** (SEO is a goal of the site).
- Images via `next/image` with explicit `width` / `height`, lazy by default.
- No blocking work on the main thread.
- API call → timeout + loading state + retry on failure.
- Response > 3 s → skeleton UI.

## Accessibility — WCAG 2.1 AA

- Contrast ≥ 4.5:1 (body text), ≥ 3:1 (UI / large text).
- Keyboard navigable end to end — no mouse-only flows.
- Semantic HTML and landmark roles.
- `aria-label` on icon-only buttons; `aria-live` on dynamic regions (including the chatbot).
- Visible focus ring on every focusable element.
- Forms: `<label>` + `aria-describedby` for errors.
- Respect `prefers-reduced-motion`.

## Forbidden

- Client-side data fetching on the initial render path (use Server Components + `use cache`)
- Hardcoded color, spacing or radius
- Arbitrary values in Tailwind utilities
- Any secret in a `NEXT_PUBLIC_*` variable
