import QtQuick
import QtTest
import "../components" as Bloom

Item {
    id: scene
    width: 640
    height: 480

    Component {
        id: fixtureComponent
        Item {
            id: fixture
            width: 640
            height: 480
            property alias session: session
            property alias compositor: fakeCompositor
            property alias app: app
            property alias otherApp: otherApp
            property alias otherWorkspace: otherWorkspace
            property alias input: input
            property alias otherInput: otherInput
            property alias panel: panel
            property alias otherPanel: otherPanel
            property int activations: 0
            property int resets: 0
            QtObject {
                id: workspace
            }
            QtObject {
                id: otherWorkspace
            }
            QtObject {
                id: fakeCompositor
                property var activeToplevel: app
                property var focusedWorkspace: workspace
            }
            QtObject {
                id: app
                property var workspace: fakeCompositor.focusedWorkspace
                property var wayland: QtObject {
                    function activate() {
                        fixture.activations++;
                        fakeCompositor.activeToplevel = app;
                        input.forceActiveFocus();
                    }
                }
            }
            QtObject {
                id: otherApp
                property var workspace: fakeCompositor.focusedWorkspace
            }
            TextInput {
                id: input
                x: 20
                y: 20
                width: 200
                height: 30
            }
            TextInput {
                id: otherInput
                x: 240
                y: 20
                width: 200
                height: 30
            }
            Bloom.PanelSession {
                id: session
                compositor: fakeCompositor
            }
            FocusScope {
                id: panel
                x: 20
                y: 80
                width: 200
                height: 100
                visible: session.opened && session.activePanel === panel
                function reset() {
                    fixture.resets++;
                    button.forceActiveFocus(Qt.TabFocusReason);
                }
                Keys.onEscapePressed: session.dismiss()
                Bloom.BloomButton {
                    id: button
                    width: 120
                    text: "Panel action"
                }
            }
            Item {
                id: otherPanel
                function reset() {
                    fixture.resets++;
                }
            }
            Component.onCompleted: {
                // Keep the app on its original workspace when the user switches.
                app.workspace = workspace;
                input.forceActiveFocus();
            }
        }
    }

    TestCase {
        name: "BloomPanelSession"
        when: windowShown
        property var fixture
        function init() {
            fixture = createTemporaryObject(fixtureComponent, scene);
            verify(fixture);
            verify(waitForRendering(fixture));
        }
        function open() {
            fixture.session.show(fixture.panel);
            fixture.compositor.activeToplevel = null;
            verify(fixture.session.opened);
            compare(fixture.resets, 1);
        }
        function restoredInputWorks() {
            tryCompare(fixture, "activations", 1);
            verify(!fixture.session.opened);
            verify(fixture.input.activeFocus);
            keyClick(Qt.Key_X);
            compare(fixture.input.text, "x");
        }
        function test_escape_restores_text_input() {
            open();
            keyClick(Qt.Key_Escape);
            restoredInputWorks();
        }
        function test_same_button_restores_text_input() {
            open();
            fixture.session.toggle(fixture.panel);
            restoredInputWorks();
        }
        function test_outside_click_ignores_duplicate_waybar_delivery() {
            open();
            fixture.session.dismissOutside();
            fixture.session.toggle(fixture.panel);
            verify(!fixture.session.opened);
            restoredInputWorks();
            tryCompare(fixture.session.dismissGuard, "running", false);
            fixture.session.toggle(fixture.panel);
            verify(fixture.session.opened);
            compare(fixture.resets, 2);
        }
        function test_outside_application_selection_is_not_overridden() {
            open();
            fixture.session.dismissOutside();
            fixture.compositor.activeToplevel = fixture.otherApp;
            fixture.otherInput.forceActiveFocus();
            tryCompare(fixture.session.restoreFocus, "running", false);
            compare(fixture.activations, 0);
            verify(fixture.otherInput.activeFocus);
            keyClick(Qt.Key_X);
            compare(fixture.otherInput.text, "x");
            compare(fixture.input.text, "");
        }
        function test_workspace_switch_is_not_overridden() {
            open();
            fixture.compositor.focusedWorkspace = fixture.otherWorkspace;
            fixture.session.dismiss();
            tryCompare(fixture.session.restoreFocus, "running", false);
            compare(fixture.activations, 0);
        }
        function test_unavailable_application_is_not_activated() {
            open();
            fixture.app.wayland = null;
            fixture.session.dismiss();
            tryCompare(fixture.session.restoreFocus, "running", false);
            compare(fixture.activations, 0);
        }
        function test_reopen_cancels_pending_focus_restore() {
            open();
            fixture.session.dismiss();
            verify(fixture.session.restoreFocus.running);
            fixture.session.show(fixture.otherPanel);
            verify(!fixture.session.restoreFocus.running);
            wait(120);
            compare(fixture.activations, 0);
            verify(fixture.session.opened);
            compare(fixture.session.activePanel, fixture.otherPanel);
        }
        function test_session_action_does_not_restore_focus() {
            open();
            fixture.session.dismiss(false);
            verify(!fixture.session.restoreFocus.running);
            wait(120);
            compare(fixture.activations, 0);
            // A failed action can reopen without losing the existing panel state.
            fixture.session.show(fixture.panel, false);
            compare(fixture.resets, 1);
            fixture.session.dismiss();
            restoredInputWorks();
        }
        function test_cached_application_survives_layer_focus() {
            fixture.compositor.activeToplevel = null;
            open();
            fixture.session.dismiss();
            restoredInputWorks();
        }
        function test_switching_panels_does_not_restore_application() {
            open();
            fixture.session.toggle(fixture.otherPanel);
            compare(fixture.session.activePanel, fixture.otherPanel);
            verify(fixture.session.opened);
            verify(!fixture.session.restoreFocus.running);
            fixture.session.dismiss();
            restoredInputWorks();
        }
    }
}
