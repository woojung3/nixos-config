# Bloom desktop design

## Direction

A quiet, cohesive desktop with deliberate proportions, a wallpaper-led palette
and discreet playfulness. The normal desktop prioritizes legibility and stable
interaction over decorative effects.

## Appearance

- `themes/bloom.nix` defines the shared colors and typography.
- Dark charcoal surfaces, warm neutral text and a restrained pink accent.
- IBM Plex Sans for UI text, with CJK and symbol fallback fonts.
- Workspace-aware wallpapers, restrained rounding and subtle surface borders.
- No persistent system-monitor dashboard or unsolicited fetch output.

## Waybar

The bar uses separate left, center and right groups, with a 34px target height
and a 10px top margin. Its height must remain 34px when typography changes;
Waybar can otherwise expand to accommodate a widget's natural height.

Workspace labels are `一 二 三 四 五 六 七 八 九 〇`. The last label represents
workspace 10; workspace IDs and number-row shortcuts are unchanged. Labels use
20px regular-weight text, with 1px vertical padding around the workspace group.
Font size is applied directly to the label, not inherited from the button.

The flower opens Rofi on left-click and toggles CRT mode on right-click.
Volume, brightness, battery, clock and power open their corresponding panels.
Hover-wheel volume and brightness changes are disabled.

## Panels

[Quickshell panels](home/jwlee/quickshell/README.md) share Bloom colors, surfaces,
controls, dismissal and keyboard-focus behavior. A single popup is shown 10px
below Waybar's reserved area, aligned to the right edge with a 14px margin.

- Mouse hover/press feedback is distinct from persistent state.
- Keyboard navigation has a thin focus ring; mouse clicks leave no focus ring.
- Output/player selection uses a check mark rather than a filled active button.
- Mute and power profiles retain explicit state emphasis.
- Escape, outside clicks and same-button toggles dismiss the popup.
- Closing a popup must not leave application keyboard input trapped.
- Avoid permanent instruction text and unnecessary close buttons.

## CRT easter egg

[CRT mode](home/jwlee/crt/README.md) is a temporary, screen-wide visual effect,
not an alternative application layout. It combines warm color grading, mild
curvature, fixed scanlines, static grain and edge shading. Bloom's normal colors
return when it is disabled; the mode starts off in a new session.

The effect does not change bar height, layout or font size. It has no blur,
animated noise, flicker or continuous redraw timer. Damage tracking stays enabled
for efficiency, with possible partial-redraw artifacts around changing content.

## References

Visual and implementation references, asset provenance and applicable licenses
are listed in [CREDITS.md](CREDITS.md). Referenced themes are not installed as
complete desktop configurations.
