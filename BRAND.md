---
name: design
description: Ybor design system standards — color tokens, typography, spacing, component patterns, status language, and layout rules. Use when building, reviewing, or modifying any UI in the platform.
user-invocable: false
---
# Ybor Design System

This guide explains how to apply the Ybor design system to any UI in the platform. Follow these rules closely — consistency across surfaces is what makes the system feel like a product rather than a collection of screens.

---

## Component library

Ybor uses **shadcn/ui v4** as its component foundation, themed with a zinc-based light palette. All components are available in the shared Figma library:

[Master-Ybor-shadcn_ui Library](https://www.figma.com/design/JhO3JDqDQepjRzLX7o0UfZ/Master-Ybor-shadcn_ui-Library)

Do not build custom components for anything that already exists in shadcn. Use the library component, then theme it.

---

## Color tokens

All colors come from the shadcn zinc light theme. Always reference the token name or Tailwind class in code — never hardcode hex values. The hex values below are **for reference only** to help identify swatches; do not copy them into code.

| Token | Tailwind class | Hex (reference only) | Use for |
| --- | --- | --- | --- |
| `background` | `bg-background` | #FFFFFF | Card and surface backgrounds |
| `foreground` | `text-foreground` | #09090B | Primary text |
| `muted` | `bg-muted` | #F4F4F5 | Stat block backgrounds, table headers |
| `muted-foreground` | `text-muted-foreground` | #71717A | Secondary / label text |
| `border` | `border-border` | #E4E4E7 | All borders and dividers |
| `primary` | `bg-primary` | #18181B | Primary buttons, active states |
| `primary-foreground` | `text-primary-foreground` | #FAFAFA | Text on primary buttons |
| Page background | use app shell bg token | #FAFAFA | App shell / page canvas |
| Success text | semantic success text token | #16A34A | Healthy, in sync, success states |
| Success bg | semantic success bg token | #DCFCE7 | Success badge fills |
| Warning text | semantic warning text token | #D97706 | Drift, degraded, missing states |
| Warning bg | semantic warning bg token | #FEF3C7 | Warning badge fills |
| Destructive text | `text-destructive` | #DC2626 | Errors, failures, mismatches |
| Destructive bg | semantic destructive bg token | #FEE2E2 | Error badge fills |
| Info text | semantic info text token | #2563EB | Links, config actions, info states |
| Info bg | semantic info bg token | #DBEAFE | Info badge fills |

---

## Typography

Main font stack: `'Nunito Sans', sans-serif`

Mono font: `'JetBrains Mono'` — use for version numbers, domain names, IDs, config values, log output

| Scale | Size | Weight | Use for |
| --- | --- | --- | --- |
| Page title | 22px | 500 | Screen/section headers |
| Card title | 13px | 500 | Card section headers |
| Body | 13–14px | 400 | All content text |
| Label / meta | 12px | 400 | Secondary labels, timestamps, hints |
| Badge | 11px | 500 | All badge text |
| Table header | 12px | 500 | `th` elements |
| Table body | 13px | 400 | `td` elements |

**Two weights only:** 400 regular and 500 medium. Never use 600 or 700 in UI text — it reads as heavy against the light palette.

---

## Spacing and sizing

| Element | Value |
| --- | --- |
| Card border radius | 12px (`rounded-xl`) |
| Component border radius | 6–8px (`rounded-md`) |
| Badge border radius | 999px (pill) |
| Card padding | 18–20px |
| Card border | `1px solid` using `border-border` token |
| Button height (default) | 36px (`h-9`) |
| Input height | 36px |
| Table row height | ~42px |
| Table header height | 36–40px |
| Section gap | 16px |
| Component gap | 12px |

---

## Core components

### Cards

All content lives inside cards. Cards sit on the page background (app shell bg token).

```
bg: background token
border: 1px solid border token
border-radius: 12px
padding: 18px 20px
```

Never nest a card inside a card. Use a divider line (`border-top` using border token) to subdivide within a card.

### Stat blocks

For summary numbers (counts, durations, version numbers). Use inside a card, typically in a 2–4 column grid.

```
bg: muted token
border-radius: 8px
padding: 12px 14px
label: 12px, muted-foreground token
value: 20–22px, font-weight 500, foreground token
sub-text: 12px, muted-foreground token
```

### Badges

All status indicators. Always `rounded-full`. Text is always 11px / 500 weight.

| Variant | Background | Text color |
| --- | --- | --- |
| Success | semantic success bg token | semantic success text token |
| Warning | semantic warning bg token | semantic warning text token |
| Destructive | semantic destructive bg token | semantic destructive text token |
| Info | semantic info bg token | semantic info text token |
| Gray / System | `muted` token | `muted-foreground` token |
| Release / Purple | purple-50 equivalent | purple-800 equivalent |

### Buttons

**Primary** — `bg-primary`, `text-primary-foreground`, `rounded-md`, `h-9`, `text-sm`, `font-medium`

**Outline** — `bg-background`, `border-border`, `text-foreground`, `rounded-md`, `h-9`

Use primary for the single most important action per section. Use outline for secondary actions.

### Tables

Table headers use the `muted` background token, `font-size: 12px`, `font-weight: 500`, `text-foreground`.

Table rows use `border-bottom` with the `border` token. Row hover uses the `muted` background token.

Use the mono font (`'JetBrains Mono'`, via the standard `font-mono` token/class) for domain names, IPs, version strings, IDs.

### Filter tabs / pill toggles

Active state: `bg-primary`, `text-primary-foreground`, `rounded-full`

Inactive state: `bg-background`, `border-border`, `text-muted-foreground`, `rounded-full`

---

## Status language

Use this exact vocabulary for status states. Do not invent new terms.

| Concept | Label | Color |
| --- | --- | --- |
| Everything working | `Healthy` / `In sync` / `Success` | Green |
| Something degraded | `Degraded` / `Warning` | Amber |
| Something failed | `Failed` / `Error` | Red |
| Record missing | `Missing` | Amber |
| Record extra | `Extra` | Amber |
| Value mismatch | `Mismatch` | Red |
| Neutral system event | `System` | Gray |
| Config applied | `Applied` | Blue |
| Release event | uses Purple badge | Purple |

---

## Layout patterns

### Two-column with sidebar

Used on detail pages (e.g. add-on management screens).

- Left sidebar: ~220–240px, stacks context cards (alerts, status, quick actions)
- - Right main column: fills remaining space, stacks primary content sections
  - - Gap between columns: 16px
    - - Both columns use the same card style — no visual distinction between sidebar and main
     
      - ### Full-width stacked
     
      - Used on summary and overview pages.
     
      - - Cards stack vertically, full width
        - - 16px gap between cards
          - - Wider cards can use internal 2, 3, or 4 column grids for stat blocks
           
            - ### Stat grid inside a card
           
            - Use `display: grid; grid-template-columns: repeat(N, 1fr); gap: 12px` for 2–4 stat blocks side by side inside a card.
           
            - ---

            ## What to avoid

            - **No gradients or shadows** on cards or buttons. Flat surfaces only.
            - - **No nesting cards** — one level of containment per section.
              - - **No ALL CAPS** labels. Use sentence case everywhere.
                - - **No hardcoded hex values** — always use the token name or Tailwind class in code.
                  - - **No custom status language** — use the approved vocabulary table above.
                    - - **No performance charts or metrics** on summary/snapshot screens — those belong in dedicated monitoring views.
                      - - **No duplicate content across tabs** — each tab owns its data. Cross-link, don't copy.
                       
                        - ---

                        ## Tab structure (for add-on / capability detail pages)

                        If you are building a detail view for a platform capability or add-on, it should follow this tab model:

                        | Tab | Purpose | One-line rule |
                        | --- | --- | --- |
                        | **Snapshot** | Executive summary | What is the current state? |
                        | **Config** | Configuration form | What do I want it to do? |
                        | **Runtime** | Live operational view | What is it doing right now? |
                        | **Release** | Version management | What version is running and what changed? |
                        | **Activity** | Audit timeline | What has happened across everything? |

                        Each tab links out to related tabs where relevant — it does not duplicate their content.

                        ---

                        ## Figma references

                        - **Main design file:** [Ybor Studio — Main](https://www.figma.com/design/imz2YKql7HoeFj6CAQXwxs/Ybor-Studio---Main)
                        - - **Component library:** [Master-Ybor-shadcn_ui Library](https://www.figma.com/design/JhO3JDqDQepjRzLX7o0UfZ/Master-Ybor-shadcn_ui-Library)
                          - - **Reference screens:** WF02-04 series in the main file shows ExternalDNS as a worked example across all five tabs
                           
                            - ---

                            ## Questions?

                            Tag Will in Slack or Notion. For component questions, check the shadcn/ui docs at https://ui.shadcn.com first — the Ybor library is a direct extension of that system.