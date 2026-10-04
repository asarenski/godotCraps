# 02: HUD visibility-toggling coding standard

**What to build:** A `CODING_STANDARDS.md` rule so the review agent enforces the Godot layout gotcha that cost several bug round-trips: `visible = false` removes a control from its container's layout, and `disabled` swaps in a different stylebox — both change size and cause layout jumps.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Create `CODING_STANDARDS.md` with a rule: to toggle a HUD control's visibility while keeping its layout space, set `modulate.a` plus `mouse_filter` (and `disabled` for buttons where needed); never use `visible = false` (or `disabled` alone) for that purpose.
- [ ] Rule states: for a greyed "disabled" look without a size change, define a `disabled` stylebox in the theme whose content/expand margins match the `normal` stylebox.
- [ ] Point at the existing pattern in `src/scenes/main/hud.gd` (`_set_reserved_visible`, `_animate_chip`) and the `Button/styles/disabled` entry in `src/themes/default_theme.tres` as reference.

## Notes

- This is a genuine judgement call (Godot-specific layout behavior), not a mechanical pattern, so it belongs in `CODING_STANDARDS.md`, not a deterministic check.
- The failure mode manifests as a ~1-2px vertical jump when elements appear/disappear; the fix (modulate + mouse_filter) has zero layout effect.
