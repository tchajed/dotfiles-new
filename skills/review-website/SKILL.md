---
name: review-website
description: Create polished, self-contained review websites and interactive visual artifacts using bun. Use this skill whenever the user asks for a “review website,” a small website to explore or explain something, a visual comparison/review tool, an interactive brief, or a code walkthrough.
compatibility: Requires bun.
---

# Review Website

Build a focused website that helps someone understand, compare, inspect, or decide something. Treat it as a review tool rather than a public-facing product.

## Default stack

Unless the user explicitly chooses otherwise, use:

- Bun for package management and scripts
- Vite
- Vue 3 with the Composition API and `<script setup lang="ts">`
- TypeScript 7 with strict typing
- rough.js for diagrams and visuals
- Light mode styling
- Plain CSS scoped or organized within the app; avoid adding a UI framework by default

Do not swap in React, npm, Tailwind, or a different drawing library merely from habit. Add other dependencies only when they clearly earn their cost.

If any data is being presented, prefer to dynamically include it from a file (such as json) so that the data can be updated without deep website modifications.

If the site has any code, use shiki to syntax highlight it.

If the site has any math, use katex.

If you need to include a markdown file (such as a separate report that the user has already generated or requested), then render it from disk on the server.

## Workflow

### 1. Establish the review job

Infer from the request:

- **Subject:** what is being reviewed or explored?
- **Audience:** who needs to understand it?
- **Decision:** what should they know, compare, approve, reject, or do after using it?
- **Evidence:** which repository files, documents, screenshots, or data are authoritative?

Inspect available source material before inventing content. If a missing fact blocks a useful result, ask a targeted question; otherwise make a reasonable, visible assumption and proceed. Never present fabricated data as real.

### 2. Choose a useful information shape

Match the interface to the review task. Good patterns include:

- side-by-side comparison for alternatives
- annotated flow or architecture for a system
- filterable inventory for many items
- before/after views for changes
- timeline for a sequence
- scorecard with evidence for a decision
- guided sections for an explainer
- histograms and plots for data

Lead with the conclusion or primary review question. Make supporting evidence easy to scan and details available on demand. Prefer a small number of meaningful views over a dashboard full of arbitrary metrics.

Before coding, form a compact design plan: visual concept, palette, typography, page structure, and one signature rough.js element tied to the subject. Avoid interchangeable SaaS-dashboard styling.

### 3. Scaffold safely

First inspect the target directory. Preserve existing work and follow the repository’s own instructions.

For a new app, use the equivalent of:

```bash
bun create vite <target> --template vue-ts
cd <target>
bun install
bun add roughjs
```

Install playwright for automated visual inspection. Then upgrade the dependencies right away.

### 4. Build the complete experience

Use real content from the request and source material. Implement the important interactions rather than drawing inert controls. Keep state and components proportional to the app:

- define typed domain models
- separate substantial views or repeated concepts into components
- derive filtered and summarized state with `computed`
- keep source data in a clear module when it is more than a few inline items
- use semantic HTML before adding ARIA

Use rough.js as structural visual language, not random decoration. Suitable uses include outlines, connectors, underlines, callouts, diagrams, selected states, or emphasis marks. Keep rendering stable by using fixed seeds. For responsive SVG drawings, redraw from measured dimensions with a `ResizeObserver`; clean up observers and generated nodes on unmount. Preserve text as HTML or accessible SVG text rather than rendering essential labels only to canvas.

### 5. Verify before handing off

At minimum run:

```bash
bun run build
```

Also run existing lint or test scripts when present. Fix warnings and TypeScript failures rather than merely reporting them. Install playwright and use it to inspect the page at desktop width for styling issues.

Finish by telling the user:

- where the app was created
- what review workflow it supports
- how to run it locally (`bun run dev`)

Do not claim to have visually inspected the page unless you actually did.
