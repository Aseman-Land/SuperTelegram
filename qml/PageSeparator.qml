import QtQuick 2.0
import AsemanTools 1.0

Item {
    width: 100
    height: 62

    property real startLen: 20
    property real endLen: 200
    property color startFillColor: "#000000"
    property color endFillColor: "#0d80ec"

    property color startBackColor: "#ffffff"
    property color endBackColor: "#ffffff"

    onStartFillColorChanged: picker.requestPaint()
    onEndFillColorChanged: picker.requestPaint()
    onStartLenChanged: picker.requestPaint()
    onEndLenChanged: picker.requestPaint()

    Canvas {
        id: picker
        anchors.fill: parent
        transform: Scale { origin.x: width/2; origin.y: height/2; xScale: View.layoutDirection==Qt.RightToLeft?-1:1}

        onPaint: {
            var ctx = picker.getContext("2d");
            ctx.save();

            var backGrad = ctx.createLinearGradient(0, 0, width, 0);
            backGrad.addColorStop(0, startBackColor);
            backGrad.addColorStop(1, endBackColor);

            ctx.fillStyle = backGrad
            ctx.fillRect(0,0,width,height)


            var delta = endLen - startLen
            var midY = startLen + delta/2
            var midX = width/2

            ctx.beginPath();
            ctx.moveTo(0, startLen);
            ctx.quadraticCurveTo(midX*0.6, startLen, midX, midY);
            ctx.moveTo(midX, midY);
            ctx.quadraticCurveTo(midX*1.4, endLen, width, endLen);
            ctx.lineTo(width,0);
            ctx.lineTo(0,0);
            ctx.lineTo(0,startLen);

            var headerGrad = ctx.createLinearGradient(0, 0, width, 0);
            headerGrad.addColorStop(0, startFillColor);
            headerGrad.addColorStop(1, endFillColor);

            ctx.fillStyle = headerGrad
            ctx.lineWidth = 1*Devices.density
            ctx.fill()
        }
    }
}

