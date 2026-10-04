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
| `scanlineStrength` | `2.0` | Scanline contrast multiplier |
| `scanlineBandHeight` | `2.0` | Two-pixel dark/light bands; four-pixel period |
| `grainStrength` | `0.025` | At most ±2.5% multiplicative brightness variation |

The amber palette moves from red-brown shadows through orange midtones to pale
gold highlights. Scanlines alternate two dark pixel rows with two light rows.
Scanline contrast and screen-fixed grain are strongest in midtones and softer
on bright text. Grain preserves black and hue. A vignette
softly darkens the edges.

There is no bloom, animated noise, flicker, time uniform or redraw timer.
`bloom-crt.frag` is the source of truth for the parameters and color stops.

## Implementation

- `bloom-crt.frag`: GLSL ES 3.0 screen shader with one texture sample per pixel.
- `toggle.sh`: Hyprland IPC, serialized toggles and restoration of prior settings.
- `../crt.nix`: packaging, stable shader path, default-off configuration and
  Waybar binding. This module is independent of Quickshell.

While enabled, software cursors pass through the same transform as the desktop.
The prior shader, cursor mode and `debug:damage_tracking` value are saved in
`$XDG_RUNTIME_DIR/bloom-crt/$HYPRLAND_INSTANCE_SIGNATURE/previous.json` and restored
when disabled. Runtime state and the toggle lock are scoped to a compositor
instance, not persisted across login sessions.

Hyprland reload may reset the effect; the next activation snapshots the current
settings afresh. Shader readability is required only when enabling: a missing
shader file must not prevent restoration when disabling. If the snapshot is
missing, the effect can still be disabled, but the previous cursor/redraw modes
cannot be recovered and their current values are retained.

## Rendering constraints

With `bloom.crt.fullRedraw = true` (the default), CRT temporarily sets
`debug:damage_tracking = 1` (monitor damage). Changed monitors are redrawn in full,
so curvature does not sample stale fragments outside a partial update region.
Mode 1 still skips unchanged frames; mode 0, which forces idle rendering, is not
used. The original policy is restored when CRT is disabled.

The policy follows Hyprland 0.55.4's
[renderer](https://github.com/hyprwm/Hyprland/blob/v0.55.4/src/render/Renderer.cpp)
and [damage modes](https://github.com/hyprwm/Hyprland/blob/v0.55.4/src/render/types.hpp).
Recheck these semantics when changing compositor versions.

The normal desktop is unaffected when CRT is off. Static effects avoid a
continuous animation timer but are not free: screen-wide processing and software
cursor rendering still cost GPU work. Performance on the LG Atom target is not
validated; measure there, including video playback, rather than extrapolating
from this laptop. Touch coordinates are not warped with the image.

## Low-power comparison

The Home Manager option `bloom.crt.fullRedraw = false;` preserves the existing
damage policy while CRT is enabled. For non-Nix deployment, supply
`BLOOM_CRT_FULL_REDRAW=0` to `toggle.sh` (default: `1`). This does not change the
shader, scanlines or curvature. With partial redraw, transient fragments around
changing text/cursors can reappear.

On the LG Atom target compare off, CRT with monitor damage, and CRT preserving
the original damage policy. Use the same brightness, power profile and workload:
idle with a stationary pointer, typing/scrolling, pointer movement and video.
Compare responsiveness, frame pacing and available GPU/power measurements. Disable
CRT before switching policies and record the original damage setting. Prefer the
lightweight policy if monitor-wide updates cause an unacceptable cost; this
repository does not assume a performance result for that device.

## Verification

From the repository root:

```sh
nix flake check "path:$PWD" --print-build-logs
```

This includes the toggle tests and GLSL validation. See
[tests/README.md](../../../tests/README.md) for individual checks and direct shell
execution. The shell tests mock Hyprland and do not alter the real display. They
cover restoration of all three settings, both redraw policies, reload, missing
snapshots/shader files, IPC failure, rapid clicks and session isolation. They do not assess visual quality or real-device GPU cost.

For live checks, verify two flower right-clicks restore all three settings and
Waybar stays 34px high. The default mode must use monitor damage while active;
inspect input/scroll updates for stale fragments. Test the lightweight policy
separately and restore the user's original on/off state after testing.
