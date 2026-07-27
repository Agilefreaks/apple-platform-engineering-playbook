# Design Map — <DELIVERY-ID> <Title>

## Reviewed design identity

| Field | Value |
|---|---|
| Figma file URL/key | |
| Page / flow | |
| Named version or reviewed timestamp | |
| Design owner | |
| Engineering reviewer | |
| Last change check | |

## Acceptance → design mapping

| Acceptance ID | Screen/component | Node ID | State/variant | Interaction | Notes |
|---|---|---|---|---|---|
| AC-01 | | | | | |

## State matrix

| Screen | State | Node ID or rule | Device/layout | Appearance | Dynamic Type | Status |
|---|---|---|---|---|---|---|
| | loading | | | light/dark | | Pending |
| | loaded | | | light/dark | | Pending |
| | empty | | | light/dark | | Pending / N/A |
| | error | | | light/dark | | Pending / N/A |
| | offline | | | light/dark | | Pending / N/A |

## Layout fidelity

A frame states visual intent, not geometry. Record what the frame cannot show, so the
implementation uses native SwiftUI layout instead of canvas-derived numbers.

| Screen | Reference frame/canvas | Genuinely fixed (token) | Fluid/proportional | Wrap/reflow rule | Smallest device | Largest device |
|---|---|---|---|---|---|---|
| | | | | | | |

| Check | Status | Note |
|---|---|---|
| No reference-width scale factors, fixed text frames, or screen-bounds math | Pending | |
| Designed heights treated as minimum heights unless truly fixed | Pending | |
| System components used unless a custom control is approved below | Pending | |

## Design system mapping

| Figma component/variant | Apple component | Token set | Owning module | New/existing | Deviation |
|---|---|---|---|---|---|
| | | | | | |

## Interaction and navigation

| Trigger | Precondition | Transition/action | Loading/cancellation | Error/recovery | Route/deep link |
|---|---|---|---|---|---|
| | | | | | |

## Accessibility intent

| Area | Intent | Verification |
|---|---|---|
| VoiceOver semantics/order | | |
| Dynamic Type | | |
| Contrast/non-color cues | | |
| Focus/keyboard/tvOS | | |
| Reduce Motion | | |
| Touch targets/actions | | |

## Copy and assets

| Type | Figma source | Production mapping | Locale/license/alt behavior | Owner |
|---|---|---|---|---|
| Copy | | String Catalog key/context | | |
| Asset | | Asset Catalog/remote resource | | |

Asset export default: SVG when Figma exports the artwork faithfully as vector,
otherwise PNG at 3x; the Asset Catalog image set uses one universal Single Scale
variant, not 1x/2x/3x.

## Accepted deviations

| ID | Design expectation | Implemented behavior | Reason | Approver | Evidence |
|---|---|---|---|---|---|
| DEV-01 | | | | | |

## Change log after READY

| Date | Figma node/version change | Material? | Acceptance/plan impact | Decision/approver |
|---|---|---:|---|---|
| | | | | |
