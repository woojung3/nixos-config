import QtQuick
import QtQuick.Controls

// options: [{key, label}]. Selection is owned by the caller; this component
// owns expansion, scrolling, keyboard navigation and selection-focus return.
FocusScope {
    id: picker
    required property var options
    property var selectedKey: null
    property string label: ""
    property bool expandable: options.length > 0
    property bool expanded: false
    signal chosen(var key)
    implicitHeight: content.implicitHeight

    function reset() {
        expanded = false;
    }
    function choose(index, reason) {
        chosen(options[index].key);
        expanded = false;
        header.focusFor(reason);
    }
    Column {
        id: content
        width: parent.width
        spacing: 12
        BloomButton {
            id: header
            width: parent.width
            text: picker.label + (picker.expandable ? (picker.expanded ? "  ‹" : "  ›") : "")
            leftAligned: true
            enabled: picker.options.length > 0
            onClicked: {
                if (picker.expandable)
                    picker.expanded = !picker.expanded;
            }
            Keys.onDownPressed: {
                if (picker.expandable && choices.count) {
                    picker.expanded = true;
                    choices.itemAt(0).focusFor(Qt.TabFocusReason);
                }
            }
        }
        Flickable {
            id: listViewport
            width: parent.width
            height: Math.min(144, list.implicitHeight)
            contentHeight: list.implicitHeight
            visible: picker.expanded && picker.expandable
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}
            Column {
                id: list
                width: parent.width
                spacing: 4
                Repeater {
                    id: choices
                    model: picker.options
                    BloomButton {
                        required property var modelData
                        required property int index
                        width: parent.width - 8
                        text: modelData.label
                        selected: modelData.key === picker.selectedKey
                        leftAligned: true
                        onClicked: picker.choose(index, focusReason)
                        Keys.onUpPressed: choices.itemAt((index + choices.count - 1) % choices.count).focusFor(Qt.TabFocusReason)
                        Keys.onDownPressed: choices.itemAt((index + 1) % choices.count).focusFor(Qt.TabFocusReason)
                        onActiveFocusChanged: {
                            if (activeFocus)
                                listViewport.contentY = Math.max(0, Math.min(y, list.height - listViewport.height));
                        }
                    }
                }
            }
        }
    }
}
