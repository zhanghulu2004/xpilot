import QtQuick 2.15
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import AppConfig 1.0
import "../Controls"

Popup {
    id: popup
    width: 550
    height: 180
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    signal useInvalidTypeCode()

    Text {
        id: lblAskDisconnect
        text: "The aircraft type code you entered appears to be invalid. Using an invalid type code can make your aircraft render incorrectly for other users.\n\nAre you sure you want to connect using an invalid type code?"
        width: 500
        wrapMode: Text.Wrap
        font.pointSize: 10
        renderType: Text.NativeRendering
        x: 20
        y: 20
    }

    BlueButton {
        id: btnYes
        text: "Yes"
        width: 50
        height: 30
        font.pointSize: 10
        anchors.top: lblAskDisconnect.bottom
        anchors.left: lblAskDisconnect.left
        anchors.topMargin: 15
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                useInvalidTypeCode()
                popup.close()
            }
        }
    }

    GrayButton {
        id: btnNo
        text: "No"
        width: 50
        height: 30
        font.pointSize: 10
        anchors.top: lblAskDisconnect.bottom
        anchors.left: btnYes.right
        anchors.topMargin: 15
        anchors.leftMargin: 10
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                popup.close()
            }
        }
    }
}
