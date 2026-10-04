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
            property alias button: action
            property alias nextButton: next
            property alias icon: iconButton
            property alias picker: picker
            property alias slider: slider
            property int activations: 0
            property int selectedKey: 1
            property int lastChoice: -1
            Bloom.BloomButton {
                id: action
                x: 20
                y: 20
                width: 120
                text: "Today"
                KeyNavigation.tab: next
                onClicked: fixture.activations++
            }
            Bloom.BloomButton {
                id: next
                x: 160
                y: 20
                width: 120
                text: "Next"
            }
            Bloom.MediaIconButton {
                id: iconButton
                x: 300
                y: 20
                width: 40
                symbol: "next"
                label: "Next track"
            }
            Bloom.ChoicePicker {
                id: picker
                x: 20
                y: 100
                width: 260
                options: [
                    {
                        key: 1,
                        label: "First output"
                    },
                    {
                        key: 2,
                        label: "Second output"
                    }
                ]
                label: "Outputs"
                selectedKey: fixture.selectedKey
                onChosen: key => {
                    fixture.lastChoice = key;
                    fixture.selectedKey = key;
                }
            }
            Bloom.BloomSlider {
                id: slider
                x: 320
                y: 100
                width: 200
                value: 50
            }
        }
    }

    TestCase {
        name: "BloomControls"
        when: windowShown
        property var fixture
        function init() {
            fixture = createTemporaryObject(fixtureComponent, scene);
            verify(fixture);
            verify(waitForRendering(fixture));
        }
        function buttonNamed(item, text) {
            if (item.text === text && item.activateFromKeyboard !== undefined)
                return item;
            for (const child of item.children || []) {
                const found = buttonNamed(child, text);
                if (found)
                    return found;
            }
            return null;
        }
        function test_mouse_focus_is_not_selection() {
            mouseClick(fixture.button);
            compare(fixture.activations, 1);
            verify(fixture.button.activeFocus);
            verify(!fixture.button.visualFocus);
            mouseMove(scene, 600, 450);
            tryCompare(fixture.button, "hovered", false);
            compare(fixture.button.background.border.width, 0);
            tryCompare(fixture.button.background, "color", Qt.rgba(0, 0, 0, 0));
        }
        function test_keyboard_ring_then_mouse_clears_it() {
            fixture.button.forceActiveFocus(Qt.TabFocusReason);
            verify(fixture.button.visualFocus);
            compare(fixture.button.background.border.width, 1);
            keyClick(Qt.Key_Tab);
            tryCompare(fixture.nextButton, "activeFocus", true);
            verify(fixture.nextButton.visualFocus);
            mouseClick(fixture.nextButton);
            verify(!fixture.nextButton.visualFocus);
            compare(fixture.nextButton.background.border.width, 0);
        }
        function test_enter_return_space_activate_once() {
            fixture.button.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Return);
            compare(fixture.activations, 1);
            keyClick(Qt.Key_Enter);
            compare(fixture.activations, 2);
            keyClick(Qt.Key_Space);
            compare(fixture.activations, 3);
            fixture.button.enabled = false;
            fixture.button.activateFromKeyboard();
            mouseClick(fixture.button);
            compare(fixture.activations, 3);
        }
        function test_keyboard_activation_after_mouse_focus_data() {
            return [
                {
                    tag: "return",
                    key: Qt.Key_Return
                },
                {
                    tag: "enter",
                    key: Qt.Key_Enter
                },
                {
                    tag: "space",
                    key: Qt.Key_Space
                }
            ];
        }
        function test_keyboard_activation_after_mouse_focus(data) {
            mouseClick(fixture.button);
            verify(!fixture.button.visualFocus);
            keyClick(data.key);
            compare(fixture.activations, 2);
            verify(fixture.button.visualFocus);
            compare(fixture.button.background.border.width, 1);
        }
        function test_persistent_state_is_independent_of_focus() {
            fixture.button.selected = true;
            verify(!fixture.button.emphasized);
            compare(fixture.button.background.border.width, 0);
            fixture.button.emphasized = true;
            tryCompare(fixture.button.background, "color", Bloom.Theme.accent);
            mouseClick(fixture.icon);
            verify(!fixture.icon.visualFocus);
            compare(fixture.icon.contentItem.ink, Bloom.Theme.foreground);
        }
        function test_picker_mouse_selection_returns_neutral_focus() {
            const header = buttonNamed(fixture.picker, "Outputs  ›");
            verify(header);
            mouseClick(header);
            verify(fixture.picker.expanded);
            verify(waitForRendering(fixture.picker));
            const first = buttonNamed(fixture.picker, "First output");
            verify(first.selected);
            verify(!first.emphasized);
            mouseClick(buttonNamed(fixture.picker, "Second output"));
            compare(fixture.lastChoice, 2);
            verify(!fixture.picker.expanded);
            verify(header.activeFocus);
            verify(!header.visualFocus);
            compare(header.background.border.width, 0);
        }
        function test_picker_keyboard_selection_keeps_ring() {
            const header = buttonNamed(fixture.picker, "Outputs  ›");
            header.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Down);
            verify(fixture.picker.expanded);
            const first = buttonNamed(fixture.picker, "First output");
            verify(first.activeFocus && first.visualFocus);
            keyClick(Qt.Key_Down);
            verify(buttonNamed(fixture.picker, "Second output").activeFocus);
            keyClick(Qt.Key_Return);
            compare(fixture.lastChoice, 2);
            verify(!fixture.picker.expanded);
            verify(header.activeFocus && header.visualFocus);
            compare(header.background.border.width, 1);
        }
        function test_slider_keyboard_step_and_wheel_policy() {
            fixture.slider.forceActiveFocus();
            keyClick(Qt.Key_Right);
            compare(fixture.slider.value, 51);
            keyClick(Qt.Key_Left);
            compare(fixture.slider.value, 50);
            verify(!fixture.slider.wheelEnabled);
            fixture.slider.value = 100;
            keyClick(Qt.Key_Right);
            compare(fixture.slider.value, 100);
            fixture.slider.value = 0;
            keyClick(Qt.Key_Left);
            compare(fixture.slider.value, 0);
        }
    }
}
