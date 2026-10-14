---
name: product-design
description: Design or review product experiences, consumer apps, SaaS and admin interfaces, iOS applications, accessibility, and Figma-based implementation. Use for product UX decisions, iOS design, VoiceOver or Dynamic Type, or Figma files and node IDs.
---

# Product Design

Start from the target users and the primary task. Apply the quality goals below, then read the reference that matches the product surface. Use `frontend-development` when the request is primarily web or React implementation; carry the relevant interaction requirements into implementation.

- Consumer apps, onboarding, commerce, community, or content browsing: `references/consumer-app-design/guide.md`
- SaaS, admin tools, dashboards, or workflow-heavy interfaces: `references/product-interface-design/guide.md`
- Native iOS patterns or SwiftUI: `references/mobile-ios-design/guide.md`
- VoiceOver, Dynamic Type, keyboard access, or other iOS accessibility work: `references/ios-accessibility/guide.md`
- Figma URL, node ID, variables, screenshots, or assets: `references/figma/guide.md`
- Faithful Figma-to-code implementation: `references/figma-implement-design/guide.md`

## Shared Quality Goals

Use these goals to guide design and review across product surfaces:

- **Fluid Interface**: Respond promptly to input and allow redirection or interruption during interaction and transitions where the operation permits it.
- **Object Constancy**: Keep the same object recognizable through changes in appearance, position, and view; preserve relevant selection, focus, and task context.
- **Calm Technology**: Match demands on attention to importance and urgency. Keep routine updates unobtrusive while making actionable problems discoverable.
- **Perceived Performance**: Reduce perceived waiting through immediate feedback, useful progress, and continued access to available work. Keep processing and completion distinguishable.
- **Reversibility**: Let people undo or recover from consequential changes where feasible; make irreversible consequences clear before commitment.
- **User Control and Freedom**: Let people choose, redirect, cancel, and leave work without unnecessary constraints. Distinguish leaving a view from cancelling its underlying operation.
- **Error-Tolerant Design**: Prevent likely mistakes, limit their consequences, and support recovery without losing valid work.

These are quality goals, not a requirement to use every technique. Choose techniques for the task, input method, and consequences of failure. Preserve platform conventions, existing design context, accessibility, and accurate state communication.

When designing or reviewing interaction, transitions, asynchronous feedback, or recovery, read the relevant sections of [Interaction Design](references/interaction-design/guide.md) in addition to the surface reference.

For significant interactions, specify the relevant behavior on input, during operation, on completion, on interruption, and on failure. Carry these decisions into implementation. Review observed behavior; identify properties that static designs or screenshots cannot verify.
