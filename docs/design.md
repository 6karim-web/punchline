# Punchline — design system

The memory of the project. Read this before changing anything visual.

## Principle

Spend boldness in one place. The folded punchline card is the only object
that raises its voice; everything around it stays quiet and disciplined.
Cut any decoration that does not serve that.

## Colour

All values live in `lib/theme/tokens.dart`. Never write a raw hex anywhere else.

| Token | Value | Use |
|---|---|---|
| canvas | `#0E1014` | Page background |
| card | `#191C22` | In-flow card |
| sheet | `#232730` | Modal / bottom sheet |
| border | `#2C313B` | Hairlines |
| text | `#F2EFE9` | Body — never pure white, it haloes on near-black |
| textMuted | `#8E96A3` | Supporting copy |
| saffron | `#F5B324` | Punchline only |
| blue | `#5B9BE8` | News only |
| violet | `#9B8CFF` | Faith only |
| up / down | `#26C281` / `#E8503A` | Market direction — nothing else, ever |

In a dark UI elevation is encoded by lightness, not by shadow. Higher means
lighter. There are no shadows in this app.

## Type

| Role | Face |
|---|---|
| Punchlines | Bricolage Grotesque |
| Interface and body | Inter |
| Any number that changes | Inter, tabular figures |

Sizes: 11, 12, 14, 16, 19, 28, 40. Weights: 400 and 500. Nothing else.
Tabular figures are mandatory on prices — without them the ticker columns
jitter on every refresh.

## Spacing and shape

Spacing: 4, 8, 12, 16, 24, 32. Radii: 8 controls, 12 cards, 20 sheets,
99 pills. Borders always 0.5px.

## Motion

One animation in the entire app: the fold. 260ms, `Cubic(0.2, 0.8, 0.3, 1.1)`.
Tab changes, loads and appearances are instant and silent.

## The five cards

Framed cards are objects you keep — punchline, market pulse, streak.
Hairline rows are links you skim — news, ads. Never blur that line; it is
what stops the feed becoming a grid of identical rectangles.

Ads are deliberately second-class: no fill, dimmer text, always labelled.

## Copy

Sentence case. No exclamation marks. No emoji in content. Never explain a
joke. Errors say what happened and what to do. Empty states invite, they
don't apologise.

The daily notification carries the setup and never the punchline — the
fold already exists in the notification, and that is what earns the open.
