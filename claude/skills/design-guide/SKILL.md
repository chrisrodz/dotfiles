---
name: design-guide
description: Modern UI design principles for building clean, professional interfaces. Use when creating any UI components, web pages, React components, HTML/CSS, or visual interfaces. Ensures consistent, minimal design with proper spacing, typography, colors, and interactive states.
---

# Design Guide

Apply these principles to every UI component created.

## Foundation

**Clean & Minimal**

- Generous whitespace between elements
- Avoid clutter - remove unnecessary decorations
- Focus attention on content and key actions

**Color Palette**

- Follow existing project color palette. If no palette has been defined, STOP and help the user.
- 1-2 accent colors used sparingly (primary action, links, highlights)
- NO gradients

**Spacing (8px Grid)**

- Use: 8px, 16px, 24px, 32px, 48px, 64px
- Padding and margins must align to grid
- Consistent spacing creates visual rhythm

## Typography

- **Body text**: 16px minimum
- **Max 2 fonts**: one for headings, one for body (or same for both)
- **Clear hierarchy**: headings significantly larger than body
- **Line height**: 1.5-1.6 for body text
- **Font weight**: use weight (400, 600, 700) for hierarchy, not just size

## Visual Elements

**Shadows**

- Subtle only: `box-shadow: 0 1px 3px rgba(0,0,0,0.1)`
- Elevated cards: `box-shadow: 0 4px 6px rgba(0,0,0,0.1)`
- Never heavy or multiple shadows

**Borders & Corners**

- Borders: 1px, light gray (#DEE2E6)
- Rounded corners: 4px, 6px, or 8px
- Not everything needs rounding - use strategically

**Cards**

- Border OR subtle shadow, not both
- Padding: 24px or 32px
- Clear separation between cards (16px or 24px gap)

## Interactive Elements

**Buttons**

- Padding: 12px 24px (or 8px 16px for small)
- Subtle shadow on default state
- Hover: slightly darker background, lift shadow
- Active: pressed appearance (darker, shadow reduced)
- Disabled: reduced opacity (0.5), cursor not-allowed
- No gradients

**Forms**

- Label above or beside input, never inside as placeholder
- Input padding: 12px 16px
- Border: 1px solid light gray
- Focus: accent color border, subtle shadow
- Error: red border + error message below in red
- Field spacing: 24px between fields

**Links**

- Accent color text
- Underline on hover
- Visited state if relevant

## Layout

**Mobile-First**

- Design for mobile, enhance for desktop
- Stack elements vertically on mobile
- Use CSS Grid/Flexbox for responsive layouts
- Breakpoints: 640px, 768px, 1024px

**Container Width**

- Max content width: 1200px-1400px
- Padding on sides: 16px mobile, 24px+ desktop

## Anti-Patterns (Never Do)

- Rainbow gradients
- Text smaller than 16px
- Inconsistent spacing (13px, 19px, etc.)
- Every element different color
- Heavy shadows or drop shadows
- Both borders and shadows on same element
- Overly rounded (border-radius: 50%)
- Cluttered layouts with no whitespace

## Quick Checklist

Before finalizing any UI:

- [ ] All spacing uses 8px grid
- [ ] Text is 16px minimum
- [ ] Using max 2 fonts
- [ ] Neutral palette + 1-2 accents
- [ ] No gradients
- [ ] Shadows are subtle
- [ ] Interactive states defined
- [ ] Mobile responsive
- [ ] Generous whitespace
