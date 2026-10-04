# Desktop verification

## Automated checks

From the repository root:

```sh
nix flake check "path:$PWD" --print-build-logs
```

Nix supplies all dependencies. The GitHub Actions workflow runs the same flake
checks. None require a running desktop, real devices, media playback or a GPU.

| Flake check | Coverage |
| --- | --- |
| `desktop-logic` | Calendar, battery and audio policy; brightness/power helpers; CRT state restoration and error handling |
| `crt-shader` | GLSL ES syntax and shader validation with glslang |
| `desktop-ui` | Production QML controls and popup state machine under Qt Quick Test |

Run a single check with:

```sh
nix build --no-link --print-build-logs "path:$PWD#checks.x86_64-linux.desktop-ui"
```

Successful check derivations are cached by Nix. To inspect the UI test report:

```sh
nix build --no-link --print-out-paths "path:$PWD#checks.x86_64-linux.desktop-ui"
```

The returned store path is a text report. For quick logic/helper runs without
building a derivation, with Bash, Node.js, jq and flock on `PATH`:

```sh
bash tests/quickshell/run.sh
bash tests/crt/run.sh
```

## UI test design

`quickshell/ui/` imports a subset of production components staged by
`tests/default.nix`, with the production `Theme.qml` template. Qt uses its
offscreen platform, software rendering, a fixed test font configuration and
synthetic input; it does not connect to the user's compositor.

The control tests exercise:

- Mouse focus without a persistent ring or selection fill.
- Keyboard focus with a thin ring, including switching input methods on the
  same focused control.
- Enter, Return and Space producing exactly one activation; disabled actions
  remaining inert.
- Selected and emphasized states independent of focus.
- Mouse/keyboard list selection and the appropriate focus reason on return.
- Slider keyboard steps, bounds and disabled wheel input.

The session tests inject a compositor object into `PanelSession`, rather than
mocking its state machine. Escape, outside dismissal and same-button toggles
return focus to a text input that must accept subsequent typing. Other cases
cover duplicate click delivery, application/workspace changes, unavailable
activation targets, cached app focus, reopening, panel switching and power-action
focus suppression. No real power/session action is executed.

These tests check Qt behavior and application policy. They do not prove actual
Wayland grab delivery, hardware output switching, touch alignment or GPU cost.

## Live integration checklist

Use an ordinary text editor as the return-focus target. Record the initial
CRT, volume/output and brightness settings, and restore them after testing.

For each of brightness, power, calendar, battery and sound:

1. Open from Waybar and inspect size, placement and initial focus.
2. Dismiss separately with Escape, an outside click and the same Waybar button.
   Type in the editor after each dismissal to verify input is not trapped.
3. Click a different application or switch workspace while dismissing; the
   previous application must not steal focus back.
4. Test Tab/arrows/Enter and then pointer input on the same focused control.
   Only keyboard focus should have a ring; output/player selection has a check.
5. Switch directly between panels and repeat rapid open/close interactions.

Open power confirmations only to inspect Cancel as the initial target; cancel
without executing logout, reboot or shutdown. Keep brightness at or above 5%.
For audio routing use temporary virtual sinks rather than unexpectedly switching
real speakers. The MPRIS fixture is documented in the
[panel guide](../home/jwlee/quickshell/README.md).

For CRT, check shader compilation and restoration of the shader, cursor mode and
damage policy. Waybar stays 34px high. The default policy uses monitor damage
while active; the lightweight policy leaves the prior damage mode unchanged.
Check typing/scrolling for stale fragments under the default policy. Animated
noise and forced idle rendering are absent. Compare both policies on the actual
target device before deciding its performance/quality tradeoff.

## System build

Checks are distinct from building the complete configuration:

```sh
nix build --no-link "path:$PWD#nixosConfigurations.jwlaptop.config.system.build.toplevel"
```

Neither checks nor this build activate a generation or modify disks.
