# Bloom panels

Waybar sends `quickshell -c bloom ipc call <target> toggle` to one Quickshell
instance started by Hyprland. Targets are `brightness`, `power`, `calendar`,
`battery` and `sound`. The `power-menu` command opens the same power panel.

## Structure

| File | Responsibility |
| --- | --- |
| `../quickshell.nix` | Packages, component registry, Home Manager deployment |
| `shell.qml` | IPC endpoints and panel composition |
| `PanelHost.qml` | Layer window, geometry, Hyprland focus grab and Escape adapter |
| `PanelSession.qml` | Popup state, dismissal guard, cached application and delayed focus restoration |
| `*Panel.qml` | Individual panel state and system-service integration |
| `NowPlaying.qml` | MPRIS player selection, artwork and transport controls |
| `BloomButton.qml`, `BloomSlider.qml`, `MediaIconButton.qml` | Shared visual and input behavior |
| `ChoicePicker.qml` | In-panel selection lists, scrolling and focus return |
| `BatteryInfo.js`, `CalendarMath.js`, `SoundLogic.js` | Pure, independently tested policy/calculation functions |
| `scripts/` | Validated hardware/session command helpers, packaged with their dependencies |

Nix generates `Theme.qml` through `theme.nix` from `themes/bloom.nix`, and
`Commands.qml` with absolute executable paths. UI tests use the same theme
template as deployment. Appearance and command wiring are separate singleton APIs.
The component registry generates both file deployment and `qmldir`; register a
new QML type once there. JavaScript files belong in the adjacent `files` list.

## Component contracts

- A panel is a `FocusScope` with `implicitWidth`, `implicitHeight` and `reset()`.
  `reset()` prepares a newly opened panel and sets its initial keyboard focus.
  It must not change hardware/session state merely by opening the panel.
- `PanelHost` owns the single visible popup and delegates state to `PanelSession`.
  Panels do not create layer windows, grab focus or implement their own
  outside-click handling. Margins are relative
  to Waybar's reserved area. Escape, outside clicks and same-button toggles close
  the popup; another application/workspace choice must not be overridden.
- Keep panels instantiated while hidden: asynchronous commands can finish after
  dismissal. Power actions dismiss without restoring app focus; failures reopen
  the existing panel state with `show(panel, false)`.
- `PanelSession` receives a compositor with `activeToplevel`, `focusedWorkspace`
  and the `activeToplevelChanged` signal. Application targets expose `workspace`
  and `wayland.activate()`. The last application is a cached value, not a live
  binding that becomes null with layer focus. Restoration waits 80ms and never
  overrides a different application/workspace. Outside dismissal guards duplicate
  button delivery for 200ms; reopening cancels pending restoration.
- `BloomButton` handles Enter and Return through `onClicked`; Space retains native
  press/release behavior. Arrow-key navigation uses `focusFor(Qt.TabFocusReason)`.
  This helper sets both focus and its reason, including on an already-focused
  button. Pointer presses use the mouse reason without taking the native button's
  grab. Mouse focus is not a selected state. `selected` draws a check; `emphasized` denotes
  persistent state or a primary action, never ordinary focus.
- `ChoicePicker` accepts `[{key, label}]`, a `selectedKey` and a header `label`.
  It emits `chosen(key)`. Callers own the selection; the picker owns expansion
  and focus return. Keys must be stable across model updates.
- `BloomSlider` disables wheel input and shares styling, but callers own write
  timing: brightness commits a drag on release, volume updates while dragging.

## Behavior and dependencies

Brightness has a 5% lower bound in both the UI and the hardware-key helper.
Power confirmation defaults to Cancel. The calendar uses local system time and
locale. Battery data comes from UPower; only supported power profiles are shown.
Sound controls the default PipeWire output and limits writes to 0–100%; muting
does not discard volume. Track metadata and transport capabilities come from
MPRIS. Empty players are hidden, paused tracks remain, missing artwork has a
font-independent fallback, and unsupported transport buttons are disabled.

Waybar volume/brightness scrolling is disabled. Volume right-click still opens
pavucontrol. Existing NixOS services provide PipeWire/WirePlumber, UPower and
power-profiles-daemon; no separate polling daemons are needed for those panels.

## Verification

From the repository root:

```sh
nix flake check "path:$PWD" --print-build-logs
nix build --no-link "path:$PWD#nixosConfigurations.jwlaptop.config.system.build.toplevel"
```

[Automated tests](../../../tests/README.md) never change real hardware/session
state. Shell helpers use mock executables; JavaScript tests cover calendar
boundaries/timezones, battery estimates, volume bounds and player selection.
Qt Quick Test runs the production controls and `PanelSession` offscreen with
synthetic pointer/keyboard events and a deterministic compositor. It covers
focus reasons, selection, activation, dismissal, focus return, workspace changes
and rapid reopen. It does not emulate Hyprland's layer-shell protocol.

For live UI changes, check mouse and keyboard operation independently: initial
focus, Tab/arrows/Enter, mouse-focus neutrality, selected-state rendering,
Escape/outside/same-button dismissal, and text input in the previous application
after dismissal. Check all five Waybar buttons when modifying `PanelHost` or
`PanelSession`. These live checks cover compositor integration, which the
isolated UI tests deliberately do not replace.

`tests/quickshell/mpris-fixture.py <temporary-log-path>` requires Python with
`dbus-next`. It exports two silent test players, records received commands and
removes its services when stopped. Use them to test artwork, capabilities,
selection and disconnection without controlling real playback. Use temporary
virtual sinks for audio-routing tests and restore the original output/volume.
Never execute real shutdown/logout commands as a test.
