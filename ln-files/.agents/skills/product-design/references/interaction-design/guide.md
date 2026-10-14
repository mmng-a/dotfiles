# Interaction Design

Choose techniques by the user's task and the quality goals in `SKILL.md`. The groups below organize design decisions; they do not prescribe a fixed sequence or require every technique in every interface.

## A. Objects and Task Structure

- **OOUI (Object-Oriented User Interface)**: Identify the objects users recognize, their relationships, and the actions available on each. Organize navigation and actions around those objects where that supports the task. Use a guided sequence when the task has genuine dependencies.
- **Modeless**: Reduce unnecessary modes and forced sequences. Preserve selection and unfinished work when people move between related tasks. When a mode is necessary, make its scope, active state, and exit clear.

Check whether people can identify the current object, understand which actions affect it, and move between tasks without repeating setup or losing work.

## B. Meaning and Discoverability

- **Affordance**: Identify which actions the object or control actually permits for the available input methods.
- **Signifier**: Make those actions discoverable through labels, shape, handles, placement, and visible states. Do not rely on hover, color, or an undisclosed gesture alone.
- **Natural Mapping**: Align control position, direction, and movement with the expected result, accounting for locale and established platform behavior.
- **Consistency and Standards**: Reuse existing components and platform conventions. Keep the same meaning, action, and state recognizable across views.

Check whether a first-time user can predict both the available action and its effect. Distinguish an action that is possible from the cues that communicate it.

## C. Input and Manipulation

- **Direct Manipulation**: Let people act on the object itself when spatial or immediate feedback helps the task. Keep the effect visible while manipulating it. Provide equivalent controls for people who cannot use the gesture or drag.
- **Gesture Arbitration**: Define priority, simultaneous recognition, cancellation, and handoff for competing gestures. Cover scroll versus drag, nested scrolling, and system navigation when relevant. Once an interaction is recognized, avoid unexpected changes in which control receives input.
- **Magnetic Snapping**: Assist alignment when meaningful destinations exist. Make the destination apparent and allow correction or escape from an unintended snap. Do not sacrifice needed precision or introduce snapping without an alignment task.

Check behavior at boundaries, with ambiguous input, and when switching between gestures. Verify equivalent task completion with keyboard and assistive technology where applicable.

## D. Visual Change and Motion Control

- **Morphing**: Use continuous shape or layout changes when they clarify that the same object is changing state. Avoid implying identity between unrelated objects.
- **Interactive Transition**: Tie transition progress to input when that helps navigation or manipulation. Define how release position, direction, and velocity determine completion or cancellation.
- **Interruptible Animation**: Accept supported redirection during motion. Continue from the current presentation state rather than jumping to the old start or end state.
- **Velocity Continuity**: When joining input-driven movement and animation, preserve velocity, including direction, where appropriate. Avoid abrupt jumps or resets; do not override an intentional stop or reversal merely to maintain smoothness.

Maintain object constancy through stable identity cues, position, selection, focus, and return context as appropriate. Motion is one possible cue. Respect reduced-motion preferences and keep relationships understandable when motion is reduced.

Check reversal, repeated input, and interruption during transitions. Ensure animations do not delay otherwise available actions or prevent reading and operating content.

## E. Timing and Asynchronous Feedback

- **Optimistic UI**: Show a predicted result before confirmation only when failure consequences are acceptable and recovery is defined. Decide how pending state, confirmation, failure, and subsequent edits are represented. Avoid presenting an irreversible or externally dependent outcome as confirmed before it is known.
- **Immediate Feedback**: Acknowledge accepted input promptly even when the result must wait. Distinguish acknowledgement, processing, and completion; responsiveness does not require assuming success.
- **Progressive Availability**: Make useful content or independent work available as it becomes ready. Use loading placeholders only when they clarify expected structure, and preserve layout stability as content arrives.
- **Progress Feedback**: Match feedback to the wait and the user's need to act. Use determinate progress when it can be measured; otherwise communicate the current state without fabricated percentages. Avoid artificial delays introduced solely to display an animation.

Check slow responses, failure, repeated input, and responses arriving in a different order. Prevent duplicate consequential actions without unnecessarily blocking unrelated work. Failed optimistic changes must not silently discard newer edits or move focus unexpectedly.

## Attention, Control, and Recovery

Apply these decisions across the groups above:

- Match feedback to importance, urgency, and whether action is needed now. Routine success may need only a local state change. Keep unresolved failures discoverable even if a temporary notification disappears; reserve interruptions for situations that require immediate attention or a decision.
- Distinguish **undo** (reverse a completed change), **cancel** (stop pending work), and **leave** (exit a view or task). Define what actually stops, what continues, and what happens to unfinished work. Do not promise cancellation after the underlying operation can no longer be stopped.
- Prefer an understandable undo or recovery path for reversible changes. For consequential irreversible actions, communicate scope and consequences and use proportionate safeguards. Avoid confirmation dialogs on every routine action.
- Prevent likely errors through sensible defaults, clear scope, constraints, and validation near the relevant input. Preserve valid input when errors occur, explain what needs correction, and provide a concrete recovery action.
- Keep these choices consistent across touch, pointer, keyboard, and assistive technology. Reduced motion and alternative input must preserve task completion and understandable state changes.

## Verification and Handoff

For the interactions affected by the task, record the relevant trigger, immediate feedback, intermediate state, completion, interruption or reversal, and failure recovery. Use the existing design or implementation format; do not create a separate specification when the behavior is already clear.

Verify the behaviors that carry material risk: for example, a drag competing with scroll, a transition reversed halfway, an optimistic update failing after a newer edit, or leaving a view while work continues. Choose checks that exercise the actual behavior rather than merely confirming that a technique is present.

Static designs can establish hierarchy, signifiers, state coverage, and intended behavior. Use an interactive prototype or running implementation to assess latency, gesture competition, motion continuity, and recovery. Report anything that could not be verified without treating missing runtime evidence as a confirmed defect.

## References

- [Apple: Designing Fluid Interfaces](https://developer.apple.com/videos/play/wwdc2018/803/) — response, interruption, gestures, and motion.
- [Weiser and Brown: Designing Calm Technology](https://calmtech.com/papers/designing-calm-technology) — attention moving between the center and periphery.
- [W3C: Understanding Dragging Movements](https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements.html) — alternatives to dragging interactions.
