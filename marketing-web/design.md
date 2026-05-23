# Aegi Marketing Website Design Direction

## Overview

Build the marketing site as a minimal, modern, SEO-first experience that reflects the calm tone of the app. The site should be mostly a single landing page with two secondary legal pages linked from the footer:

- Privacy Policy
- Disclaimer

The landing page should feel quiet, intentional, and easy to scan. Avoid heavy navigation, crowded layouts, or decorative sections that do not help users understand the product.

## Product Positioning

Aegi is a tracking app for:

- expecting parents who want pregnancy tracking, contraction timing, and quick daily logs
- parents of newborns who want feed, diaper, sleep, trend, and memory tracking

The website should present the app as a calm companion for everyday parenting routines, not as a clinical or highly technical product.

## Design Direction

### Visual Style

- Minimal and modern
- Spacious layout with generous whitespace
- Soft, calm, parent-friendly tone
- Clean structure with light visual rhythm
- More editorial than promotional

### Color System

Base the palette on the app screenshots:

- Background: warm off-white
- Primary text: soft charcoal
- Secondary text: light gray
- Primary accent: muted peach
- Supporting accents: pale blue, sage green, soft yellow

Use color sparingly. Most of the page should remain light and quiet, with accents used to guide attention.

### Typography
- Use Google Fonts
- Use a clean "Urbanist" for headings, UI copy, buttons, labels, and metadata
- Use a refined serif ("Source Serif 4" or "Instrument Serif") selectively for emotional or journal-oriented moments
- Keep line lengths moderate for readability
- Maintain strong contrast and simple hierarchy

Typography should support clarity first. Avoid overly expressive display treatments.

### Logo

- Use `marketing-web/assets/logo.svg` as the main brand mark
- Present it small to medium size with plenty of surrounding space
- Keep logo placement simple in hero and footer
- Avoid dark or noisy backgrounds behind the logo since the SVG is white

## Information Architecture

The site should have:

- one main landing page
- one Privacy Policy page
- one Disclaimer page

Do not add a full navbar unless implementation requires a very minimal sticky header with only the logo and a CTA. There is not enough product content to justify multiple nav items.

## Landing Page Structure

### 1. Hero

Purpose: explain what the app is in one screen and establish trust quickly.

Include:

- One SEO-friendly H1
- Short supporting paragraph
- Primary CTA
- One strong product visual using a screenshot or composed phone mockup

Suggested message direction:

- pregnancy tracker, baby tracker, contraction timer, and memory journal in one calm app
- made for expecting parents and parents of newborns

Hero layout should prioritize text clarity and fast loading. Keep the content crawlable and do not rely on text embedded inside images.

### 2. Simple Product Summary

Explain the app in two short blocks:

- Expecting mode
- Arrived mode

Each block should describe the practical value in plain language. Keep this section compact.

### 3. Feature Highlights

Use a small set of focused feature cards or rows. Recommended features:

- Pregnancy overview
- Contraction timer and kick counter
- Feed, diaper, and sleep tracking
- Timeline and trend summaries
- Memory journal

Keep feature descriptions short and benefit-led.

### 4. Screenshot Story Section

Use screenshots to support the copy, not replace it. Show only the clearest product moments.

Recommended screenshot priorities:

- `IMG_4382.PNG` for baby overview/dashboard
- `IMG_4393.PNG` for trends/analytics
- `IMG_4384.PNG` and `IMG_4385.PNG` for journal list/detail
- `IMG_4387.PNG` and `IMG_4388.PNG` for pregnancy overview/timeline
- `IMG_4389.PNG` and `IMG_4390.PNG` for contraction timer and kick counter
- `IMG_4383.PNG` for activity timeline
- `IMG_4386.PNG` as a soft brand/mood visual if needed

Usage rules:

- Prefer portrait-oriented compositions
- Crop or zoom to highlight the most useful UI area
- Focus on cards, metrics, timeline entries, journal excerpts, and timer controls
- Avoid showing too many nearly identical phone frames
- If device frames are used, keep them subtle

### 5. Trust and Clarity Section

Keep this section simple and text-based. Cover:

- easy daily logging
- calm visual experience
- clear tracking across pregnancy and newborn stages
- non-medical positioning for contraction and pregnancy-related features

This is also a good place for a short line that the app supports tracking and organization, not diagnosis or treatment.

### 6. Final CTA

Repeat the main conversion action near the end of the page with short supporting copy.

### 7. Footer

Include:

- logo
- app name
- copyright
- link to Privacy Policy
- link to Disclaimer

The footer should be minimal and low-profile.

## Motion and Transitions

Animation should be subtle, calm, and performance-safe.

### Principles

- Motion should support clarity, not decoration
- Keep transitions soft and brief
- Avoid bouncy, loud, or playful effects
- Do not delay hero rendering or LCP-critical content

### Recommended Motion

- Hero text and hero visual can fade in with a slight upward movement on first load
- Feature cards can reveal with a small stagger as they enter the viewport
- Screenshot blocks can fade and slide into place on scroll
- CTA buttons can use a gentle hover transition on background, border, or shadow
- Cards can use a very small lift on hover for desktop
- Background gradients or shapes may drift slightly if the effect is extremely subtle
- Smooth scrolling is acceptable for any in-page anchor behavior

### Avoid

- autoplay carousels
- aggressive parallax
- looping motion on primary content
- long animation chains
- any animation that makes the page feel slower

### Accessibility

- Respect `prefers-reduced-motion`
- Ensure all key content is fully understandable without animation
- Motion should never be required to reveal essential information

## SEO Direction

The page should be optimized for fast rendering and strong text relevance.

### Core SEO Rules

- Use one clear H1
- Use semantic H2/H3 structure
- Keep primary product messaging in HTML text
- Avoid image-only sections with missing explanatory copy
- Use internal links only where needed, mainly for legal pages

### Keyword Direction

Naturally cover phrases such as:

- pregnancy tracker app
- baby tracker app
- contraction timer
- newborn feeding tracker
- baby sleep tracker
- baby journal

Do not stuff keywords. Keep the copy natural and readable.

### Metadata

Prepare the site for:

- concise title tag
- strong meta description
- Open Graph title and description
- Open Graph image
- descriptive alt text for screenshots

### Performance Guidance

- Keep hero content light and indexable
- Compress screenshots aggressively
- Lazy-load below-the-fold images
- Avoid heavy animation libraries if simple CSS or lightweight intersection-based animation is enough
- Preserve fast mobile performance since the site is screenshot-heavy

## Legal Pages

### Privacy Policy

Keep the privacy page plain and readable so it can later be reused in-app if needed.

Recommended sections:

- what the app stores
- whether data is stored locally on device
- whether analytics are used
- any third-party services in use
- how policy updates are handled
- contact information or support contact placeholder

The tone should be simple, direct, and non-technical where possible.

### Disclaimer

This page must clearly state:

- the app is not a medical device
- the app does not provide medical advice
- the app is not intended to diagnose, treat, cure, or prevent any medical condition
- contraction, pregnancy, and baby tracking features are informational and organizational only
- users should consult a qualified healthcare provider for medical concerns or urgent decisions

Keep the language plain and unambiguous.

## Writing Tone

- calm
- clear
- straightforward
- reassuring without sounding clinical
- simple enough to scan quickly

Avoid marketing fluff, exaggerated claims, or language that suggests medical authority.

## Implementation Notes

- Prioritize a text-first landing page supported by screenshots
- Keep the page mostly single-column in content structure, even if some sections split into two columns on desktop
- Design mobile first, since the product visuals are portrait app screens
- Keep the overall site compact rather than building many sections to fill space
- The best result is a single clear page with a strong hero, concise feature explanation, a few carefully used screenshots, and clean footer links to legal pages
