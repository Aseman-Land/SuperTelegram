import QtQuick 2.0

Rectangle {
    width: 100
    height: 62

    property real startLen: 20
    property real endLen: 200
    property color fillColor: "#000000"

    onFillColorChanged: picker.requestPaint()
    onStartLenChanged: picker.requestPaint()
    onEndLenChanged: picker.requestPaint()

    Canvas {
        id: picker
        anchors.fill: parent
        transform: Scale { origin.x: width/2; origin.y: height/2; xScale: View.layoutDirection==Qt.RightToLeft?-1:1}

        onPaint: {
            var ctx = picker.getContext("2d");
            ctx.save();

            ctx.fillStyle = fillColor
            ctx.lineWidth = 1*Devices.density
            ctx.beginPath();

            var delta = endLen - startLen
            var midY = startLen + delta/2
            var midX = width/2

            ctx.moveTo(0, startLen);
            ctx.quadraticCurveTo(midX*0.6, startLen, midX, midY);
            ctx.moveTo(midX, midY);
            ctx.quadraticCurveTo(midX*1.4, endLen, width, endLen);
            ctx.lineTo(width,0);
            ctx.lineTo(0,0);
            ctx.lineTo(0,startLen);

            ctx.fill()
        }
    }
}

