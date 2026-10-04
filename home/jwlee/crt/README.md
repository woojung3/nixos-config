# Bloom CRT easter egg

Right-click the Waybar flower to toggle a session-only warm-color CRT effect.
Left-click opens the application launcher. The effect changes neither bar
geometry nor application layout and starts disabled in a new Hyprland session.

## Appearance

| Parameter | Value | Role |
| --- | --- | --- |
| `curvature` | `0.016` | Mild barrel distortion |
| `sourceSaturation` | `0.80` | Source-color saturation before grading |
| `amberMix` | `0.40` | 60% source color mixed with 40% amber grading |
| `grainStrength` | `0.025` | At most ±2.5% multiplicative brightness variation |

The amber palette moves from red-brown shadows through orange midtones to pale
gold highlights. Two-pixel scanlines and screen-fixed grain are strongest in
midtones and softer on bright text. Grain preserves black and hue. A vignette
softly darkens the edges.

There is no bloom, animated noise, flicker, time uniform or redraw timer.
`bloom-crt.frag` is the source of truth for the parameters and color stops.

## Implementation

- `bloom-crt.frag`: GLSL ES 3.0 screen shader with one texture sample per pixel.
- `toggle.sh`: Hyprland IPC, serialized toggles and restoration of prior settings.
- `../crt.nix`: packaging, stable shader path, default-off configuration and
  Waybar binding. This module is independent of Quickshell.

While enabled, software cursors pass through the same transform as the desktop.
The prior shader and cursor mode are saved in
`$XDG_RUNTIME_DIR/bloom-crt/$HYPRLAND_INSTANCE_SIGNATURE/previous.json` and restored
when disabled. Runtime state and the toggle lock are scoped to a compositor
instance, not persisted across login sessions.

Hyprland reload may reset the effect; the next activation snapshots the current
settings afresh. Shader readability is required only when enabling: a missing
shader file must not prevent restoration when disabling. If the snapshot is
missing, the effect can still be disabled, but the previous cursor mode cannot
be recovered.

## Rendering constraints

Damage tracking remains unchanged. Curvature samples pixels outside their
original screen positions, while partial redraw tracks the original damaged
regions. Changing text or moving the cursor can therefore produce transient
stale fragments or uneven updates. These are rendering artifacts, not animated
noise. Full-frame redraw is not enabled to hide them.

The normal desktop is unaffected when CRT is off. Static effects avoid a
continuous animation timer but are not free: screen-wide processing and software
cursor rendering still cost GPU work. Performance on the LG Atom target is not
validated; measure there, including video playback, rather than extrapolating
from this laptop. Touch coordinates are not warped with the image.

## Verification

From the repository root:

```sh
nix flake check "path:$PWD" --print-build-logs
```

This includes the toggle tests and GLSL validation. See
[tests/README.md](../../../tests/README.md) for individual checks and direct shell
execution. The shell tests mock Hyprland and do not alter the real display. They
cover state restoration, reload, missing snapshots/shader files, IPC failure,
rapid clicks and session isolation. They do not assess visual quality or real-device GPU cost.

For live checks, verify two flower right-clicks restore the prior shader/cursor
behavior, Waybar stays 34px high, and `debug:damage_tracking` stays unchanged.
Also inspect input/scroll updates for partial-redraw artifacts. Restore the
user's original on/off state after testing.
