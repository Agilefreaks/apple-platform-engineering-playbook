# Figma Definition of Ready Checklist

Complete this for every delivery item with UI. For an item without UI, check only the
`UI not required` declaration, with a reason and Product + Engineering approval.

## Identity

| Field | Value |
|---|---|
| Delivery ID | |
| Design owner | |
| Engineering owner | |
| Figma file URL/key | |
| Page / flow | |
| Exact node IDs | |
| Named version or reviewed timestamp | |
| Last check after changes | |

## 1. The source is unambiguous

- [ ] The file URL/key, page, and exact node IDs are in `delivery.yml`.
- [ ] The named version or reviewed timestamp is recorded.
- [ ] Exploratory, deprecated, or out-of-scope frames are clearly marked.
- [ ] The navigation/prototype flow that defines behavior is linked.
- [ ] The design owner and the person who approves parity are identified.
- [ ] The team has actual access to the required file, components, variables, and assets.

## 2. State coverage

For each state, mark `designed`, `rule-defined`, or `not applicable` in
`design-map.md`. A rule-defined state has an unambiguous rule and component/tokens, even
if it has no separate frame.

- [ ] Initial/idle.
- [ ] Loading and/or skeleton.
- [ ] Loaded/happy path.
- [ ] Empty/no results.
- [ ] Partial or stale data.
- [ ] Recoverable error + retry.
- [ ] Blocking error.
- [ ] Offline/degraded mode.
- [ ] Permission denied/restricted.
- [ ] Inline and summary validation, if there is input.
- [ ] Submitted/in progress and duplicate-action protection.
- [ ] Success/confirmation.
- [ ] Destructive confirmation and undo, if applicable.
- [ ] Cancellation/background/resume, if applicable.

## 3. Interaction states

- [ ] Default.
- [ ] Pressed/highlighted.
- [ ] Disabled, and the reason for unavailability.
- [ ] Focused, and keyboard behavior.
- [ ] Selected/unselected.
- [ ] Hover/pointer for iPadOS, if applicable.
- [ ] tvOS focus, parallax, and remote behavior, if applicable.
- [ ] Gestures have an accessible alternative and do not hide critical actions.
- [ ] Transitions and motion have intent and a Reduce Motion fallback.

## 4. Layout and platforms

- [ ] Supported device classes are declared.
- [ ] Compact/regular width behavior is explained.
- [ ] Supported orientations are explicit.
- [ ] Safe areas, keyboard, and scroll behavior are defined.
- [ ] Split view/multitasking on iPadOS is covered, if applicable.
- [ ] tvOS overscan/focus and viewing distance are covered, if applicable.
- [ ] Light mode and dark mode are covered.
- [ ] Dynamic/long content has wrapping, truncation, and expansion rules.
- [ ] The adaptive layout is not inferred from a single screenshot.
- [ ] The canvas/device each frame was drawn at is stated, and the frame is understood
      as visual intent rather than fixed geometry.
- [ ] For each screen it is explicit which dimensions are genuinely fixed (icons,
      hairlines, touch targets, fixed imagery) and which are fluid, proportional, or
      content-driven.
- [ ] Behavior on the smallest and the largest supported device is defined: what
      scales, what wraps, what reflows, what stays fixed.
- [ ] Designed row/card heights are declared as minimum heights unless the design
      genuinely requires a fixed one.
- [ ] Custom controls that replace a system component are listed, justified, and
      approved; otherwise native components and behaviors apply.
- [ ] No acceptance criterion requires canvas-derived geometry (reference-width scale
      factors, fixed text frames, hardcoded point sizes, screen-bounds math).

## 5. Design system and tokens

- [ ] Every reusable component points to the canonical component/variant.
- [ ] Colors use semantic variables/tokens, not unexplained local values.
- [ ] Typography, spacing, radius, borders, elevation, and motion use tokens.
- [ ] Component states are defined in the component set or in rules.
- [ ] Every new component has an owner and a DesignSystem promotion decision.
- [ ] Intentional deviations from the DesignSystem are listed and approved.

## 6. Accessibility intent

- [ ] The VoiceOver reading order is clear.
- [ ] Elements have intentional role, label, value, hint, and grouping.
- [ ] Custom actions have an accessible alternative.
- [ ] Dynamic Type is supported up to the declared sizes, including accessibility sizes.
- [ ] Text and control contrast has been assessed.
- [ ] Information is not conveyed only through color, position, or motion.
- [ ] The focus order for keyboard/tvOS is clear.
- [ ] Reduce Motion and Increase Contrast are considered where relevant.
- [ ] Touch targets and spacing allow safe interaction.

## 7. Copy and localization

- [ ] The copy is final or has an owner and a completion date before READY.
- [ ] Titles, labels, errors, empty states, and confirmations are covered.
- [ ] Texts with legal/privacy impact are approved by the appropriate owner.
- [ ] Plurals, dates, times, numbers, currencies, and units have localizable context.
- [ ] Ambiguous strings have context for the translator.
- [ ] Text expansion and RTL are defined for the supported locales.
- [ ] The copy in Figma and the requirements do not contradict each other.

## 8. Assets

- [ ] Every asset has a source, an owner, and a license/usage right.
- [ ] Export follows the default rule: SVG whenever Figma exports the artwork
      faithfully as vector; otherwise PNG at 3x only.
- [ ] Every image set is one universal Single Scale variant in the Asset Catalog —
      no 1x/2x/3x triplets — and views size images explicitly.
- [ ] SVG image sets enable Preserve Vector Data when the artwork renders at more
      than one size (Dynamic Type, multiple placements).
- [ ] Gamut and dark variants are declared where the design requires them.
- [ ] Names and variants are mapped to the Asset Catalog.
- [ ] Decorative versus informative images are identified for accessibility.
- [ ] There are no secrets, real data, or PII in assets/mockups.
- [ ] Remote assets have defined placeholder, error, and caching behavior.

## 9. Mapping and verification

- [ ] Every acceptance ID with UI is mapped to node/state IDs.
- [ ] Every in-scope node/state is mapped to behavior or acceptance.
- [ ] The screenshot/parity matrix includes the relevant device, appearance, and Dynamic Type.
- [ ] Parity is defined as native adaptive fidelity — the design's hierarchy,
      proportion, and tokens reproduced with SwiftUI layout — not a pixel overlay of
      one frame.
- [ ] The parity matrix covers the reference device plus the smallest and largest
      supported device, both appearances, and the largest declared Dynamic Type size.
- [ ] Accepted tolerances or deviations have a reason and an approver.
- [ ] The verification method is established: screenshot, video, runtime, or design review.
- [ ] Material changes after READY trigger a revision + impact review.

## Gate decision

| Role | Decision | Actor | Date | Evidence/link |
|---|---|---|---|---|
| Design | Pending / Approved / Rejected / Conditional | | | |
| Product | Pending / Approved / Rejected / Conditional | | | |
| Engineering | Pending / Approved / Rejected / Conditional | | | |

**Figma Ready:** `YES / NO`

**Conditions, gaps, or deviations:**

---
