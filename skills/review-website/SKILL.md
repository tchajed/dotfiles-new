---
name: review-website
description: Create polished, self-contained review websites and interactive visual artifacts using Bun, Vite, Vue, TypeScript, and rough.js. Use this skill whenever the user asks for a “review website,” a small website to explore or explain something, a visual comparison/review tool, an interactive brief, or says “create a website to do X” with this stack—even if they do not explicitly name every technology.
compatibility: Requires Bun and a browser-capable environment for previewing the result.
---

# Review Website

Build a focused website that helps someone understand, compare, inspect, or decide something. Treat it as a real review tool rather than a generic landing page or a static memo with decorative cards.

## Default stack

Unless the user explicitly chooses otherwise, use:

- Bun for package management and scripts
- Vite
- Vue 3 with the Composition API and `<script setup lang="ts">`
- TypeScript with strict typing
- rough.js for the site’s hand-drawn visual language
- Plain CSS scoped or organized within the app; avoid adding a UI framework by default

Do not swap in React, npm, Tailwind, or a different drawing library merely from habit. Add other dependencies only when they clearly earn their cost.

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

If the current repository is already a suitable Vue/Vite app, modify it rather than nesting another project. Keep generated boilerplate only when it serves the result; remove demo assets and styles.

### 4. Build the complete experience

Use real content from the request and source material. Implement the important interactions rather than drawing inert controls. Keep state and components proportional to the app:

- define typed domain models
- separate substantial views or repeated concepts into components
- derive filtered and summarized state with `computed`
- keep source data in a clear module when it is more than a few inline items
- use semantic HTML before adding ARIA

Use rough.js as structural visual language, not random decoration. Suitable uses include outlines, connectors, underlines, callouts, diagrams, selected states, or emphasis marks. Keep rendering stable by using fixed seeds. For responsive SVG drawings, redraw from measured dimensions with a `ResizeObserver`; clean up observers and generated nodes on unmount. Preserve text as HTML or accessible SVG text rather than rendering essential labels only to canvas.

A typical rough.js Vue pattern is:

```ts
import { onBeforeUnmount, onMounted, ref } from 'vue'
import rough from 'roughjs'

const host = ref<SVGSVGElement | null>(null)
let observer: ResizeObserver | undefined

function draw() {
  const svg = host.value
  if (!svg) return
  svg.replaceChildren()
  const rc = rough.svg(svg)
  svg.append(rc.rectangle(4, 4, Math.max(0, svg.clientWidth - 8), 64, {
    seed: 17,
    roughness: 1.2,
    strokeWidth: 2,
  }))
}

onMounted(() => {
  observer = new ResizeObserver(draw)
  if (host.value) observer.observe(host.value)
  draw()
})

onBeforeUnmount(() => observer?.disconnect())
```

Adapt this pattern rather than copying it blindly; zero-sized first renders and repeated redraws must not leave stale nodes behind.

### 5. Meet the quality floor

The result should:

- work at narrow mobile and wide desktop sizes
- have clear hierarchy, concise labels, and readable line lengths
- provide visible hover and keyboard-focus states
- use actual buttons and links for actions
- respect `prefers-reduced-motion`
- maintain usable contrast
- handle empty, missing, and long-content states where relevant
- avoid horizontal page overflow
- avoid fake search, filters, toggles, export buttons, or links
- avoid placeholder copy, lorem ipsum, and unsupported claims

Use animation only when it clarifies change or orientation. The hand-drawn treatment should remain legible and disciplined rather than making every edge noisy.

### 6. Verify before handing off

At minimum run:

```bash
bun run build
```

Also run existing lint or test scripts when present. Fix warnings and TypeScript failures rather than merely reporting them. If browser or screenshot tools are available, inspect the page at desktop and mobile widths and correct clipping, overlap, broken interaction, and rough.js sizing issues.

Finish by telling the user:

- where the app was created
- what review workflow it supports
- which checks passed
- how to run it locally (`bun run dev`)

Do not claim to have visually inspected the page unless you actually did.
