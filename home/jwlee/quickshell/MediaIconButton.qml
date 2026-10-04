import QtQuick

BloomButton {
    id: button
    property string symbol: "play"
    property string label: ""
    implicitWidth: 36
    Accessible.name: label
    contentItem: Canvas {
        id: drawing
        readonly property color ink: button.emphasized ? Theme.background : Theme.foreground
        opacity: button.enabled ? 1 : 0.35
        onInkChanged: requestPaint()
        Connections {
            target: button
            function onSymbolChanged() {
                drawing.requestPaint();
            }
        }
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.translate(width / 2 - 9, height / 2 - 9);
            ctx.fillStyle = ink;
            ctx.strokeStyle = ink;
            ctx.lineWidth = 1.5;
            ctx.lineCap = "round";
            if (button.symbol === "play") {
                ctx.beginPath();
                ctx.moveTo(5, 2);
                ctx.lineTo(15, 9);
                ctx.lineTo(5, 16);
                ctx.closePath();
                ctx.fill();
            } else if (button.symbol === "pause") {
                ctx.fillRect(4, 3, 3, 12);
                ctx.fillRect(11, 3, 3, 12);
            } else if (button.symbol === "previous" || button.symbol === "next") {
                if (button.symbol === "previous") {
                    ctx.translate(18, 0);
                    ctx.scale(-1, 1);
                }
                ctx.fillRect(13, 3, 2, 12);
                ctx.beginPath();
                ctx.moveTo(3, 3);
                ctx.lineTo(12, 9);
                ctx.lineTo(3, 15);
                ctx.closePath();
                ctx.fill();
            } else {
                ctx.beginPath();
                ctx.moveTo(2, 6);
                ctx.lineTo(5, 6);
                ctx.lineTo(9, 3);
                ctx.lineTo(9, 15);
                ctx.lineTo(5, 12);
                ctx.lineTo(2, 12);
                ctx.closePath();
                ctx.stroke();
                ctx.beginPath();
                if (button.symbol === "muted") {
                    ctx.moveTo(12, 6);
                    ctx.lineTo(17, 12);
                    ctx.moveTo(17, 6);
                    ctx.lineTo(12, 12);
                } else {
                    ctx.arc(9, 9, 6, -0.9, 0.9);
                }
                ctx.stroke();
            }
        }
    }
}
