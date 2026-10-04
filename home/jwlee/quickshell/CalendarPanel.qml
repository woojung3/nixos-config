import QtQuick
import Quickshell
import "CalendarMath.js" as CalendarMath

FocusScope {
    id: calendar
    implicitWidth: 280
    implicitHeight: 334
    property int year: clock.date.getFullYear()
    property int month: clock.date.getMonth()
    readonly property int firstWeekday: Qt.locale().firstDayOfWeek % 7
    readonly property var cells: CalendarMath.monthCells(year, month, firstWeekday)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function reset() {
        year = clock.date.getFullYear();
        month = clock.date.getMonth();
        forceActiveFocus();
    }
    function moveMonth(delta) {
        const next = CalendarMath.shiftMonth(year, month, delta);
        year = next.year;
        month = next.month;
    }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Left || event.key === Qt.Key_PageUp) {
            moveMonth(-1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_PageDown) {
            moveMonth(1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Home) {
            reset();
            event.accepted = true;
        }
    }

    Text {
        x: 18
        y: 21
        width: parent.width - 104
        text: Qt.formatDate(new Date(calendar.year, calendar.month, 1, 12), "MMMM yyyy")
        elide: Text.ElideRight
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.Medium
    }
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 10
        y: 10
        spacing: 2
        BloomButton {
            width: 32
            text: "‹"
            Accessible.name: "Previous month"
            onClicked: calendar.moveMonth(-1)
        }
        BloomButton {
            width: 32
            text: "›"
            Accessible.name: "Next month"
            onClicked: calendar.moveMonth(1)
        }
    }

    Row {
        x: 14
        y: 58
        Repeater {
            model: 7
            Text {
                required property int index
                width: (calendar.width - 28) / 7
                height: 24
                text: Qt.formatDate(new Date(2024, 0, 7 + (calendar.firstWeekday + index) % 7, 12), "ddd")
                horizontalAlignment: Text.AlignHCenter
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: 10
            }
        }
    }
    Grid {
        x: 14
        y: 82
        columns: 7
        Repeater {
            model: calendar.cells
            Item {
                required property var modelData
                width: (calendar.width - 28) / 7
                height: 32
                readonly property bool today: modelData.year === clock.date.getFullYear() && modelData.month === clock.date.getMonth() && modelData.day === clock.date.getDate()
                Rectangle {
                    anchors.centerIn: parent
                    width: 28
                    height: 28
                    radius: 7
                    color: parent.today ? Theme.accent : "transparent"
                }
                Text {
                    anchors.centerIn: parent
                    text: parent.modelData.day
                    color: parent.today ? Theme.background : parent.modelData.inMonth ? Theme.foreground : Theme.muted
                    opacity: parent.modelData.inMonth || parent.today ? 1 : 0.5
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: parent.today ? Font.DemiBold : Font.Normal
                }
            }
        }
    }
    BloomButton {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 282
        width: 92
        text: "Today"
        onClicked: calendar.reset()
    }
}
