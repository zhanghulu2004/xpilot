import QtQuick 2.15
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2
import "../Components"
import "../Controls"

import AppConfig 1.0

Window {
    id: formSettings
    title: "Settings"
    width: 650
    height: 590
    minimumHeight: height
    minimumWidth: width
    maximumHeight: height
    maximumWidth: width
    flags: Qt.Dialog
    modality: Qt.ApplicationModal

    property var serverListLoaded: false
    property var apiListLoaded: false
    property var inputDeviceListLoaded: false
    property var outputDeviceListLoaded: false
    property var initialized: false

    signal closeWindow()

    // @disable-check M16
    onClosing: {
        AppConfig.saveConfig();
        closeWindow()
    }

    Connections {
        target: audio

        function onInputDevicesChanged() {
            if(inputDeviceListLoaded) {
                inputDeviceList.model = audio.InputDevices;
                inputDeviceList.currentIndex = -1;
            }
        }

        function onOutputDevicesChanged() {
            if(outputDeviceListLoaded) {
                outputDeviceList.model = audio.OutputDevices;
                outputDeviceList.currentIndex = -1;
            }
        }

        function onInputVuChanged(vu) {
            peakLevel.value = vu
        }
    }

    Component.onCompleted: {
        txtVatsimId.text = AppConfig.VatsimId;
        txtVatsimPassword.text = AppConfig.VatsimPasswordDecrypted;
        txtYourName.text = AppConfig.Name;
        txtHomeAirport.text = AppConfig.HomeAirport;
        networkServerCombobox.model = AppConfig.CachedServers;
        outputDeviceList.model = audio.OutputDevices;
        inputDeviceList.model = audio.InputDevices;
        audioApiList.model = audio.AudioApis;
        com1Slider.volume = AppConfig.Com1Volume;
        com2Slider.volume = AppConfig.Com2Volume;
        switchEnableHfSquelch.checked = AppConfig.HFSquelchEnabled;
        switchDisableRadioEffects.checked = AppConfig.AudioEffectsDisabled;
        switchAutoModeC.checked = AppConfig.AutoModeC;
        switchDisableSounds.checked = AppConfig.DisableNotificationSounds;
        switchAlertDirectRadioMessage.checked = AppConfig.AlertDirectRadioMessage;
        switchAlertPrivateMessage.checked = AppConfig.AlertPrivateMessage;
        switchAlertSelcal.checked = AppConfig.AlertSelcal;
        switchAlertDisconnect.checked = AppConfig.AlertDisconnect;
    }

    onAfterRendering: {
        if(!initialized) {
            // prevent window from opening outside of screen bounds
            if((y - 50) < screen.virtualY) {
                y = screen.virtualY + 50
            }
            initialized = true
        }
    }

    GridLayout {
        id: gridLayout
        anchors.fill: parent
        anchors.rightMargin: 15
        anchors.leftMargin: 15
        anchors.bottomMargin: 15
        anchors.topMargin: 15
        columnSpacing: 15
        rowSpacing: 10
        rows: 8
        columns: 2

        Item {
            id: vatsimId
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.column: 0
            Layout.row: 0
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Label {
                color: "#333333"
                text: qsTr("VATSIM ID")
                font.pixelSize: 13
                renderType: Text.NativeRendering
            }
            CustomTextField {
                id: txtVatsimId
                onTextChanged: {
                    AppConfig.VatsimId = txtVatsimId.text;
                }
                validator: RegularExpressionValidator {
                    regularExpression: /[0-9]+/
                }
                y: 20
            }
        }

        Item {
            id: vatsimPassword
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.column: 0
            Layout.row: 1
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Label {
                color: "#333333"
                text: qsTr("VATSIM Password")
                font.pixelSize: 13
                renderType: Text.NativeRendering
            }
            CustomTextField {
                id: txtVatsimPassword
                echoMode: TextInput.Password
                y: 20
                onTextChanged: {
                    AppConfig.VatsimPasswordDecrypted = txtVatsimPassword.text.trim()
                }
            }
        }

        Item {
            id: yourName
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.column: 0
            Layout.row: 2
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Label {
                color: "#333333"
                text: qsTr("Your Name")
                renderType: Text.NativeRendering
                font.pixelSize: 13
            }

            CustomTextField {
                id: txtYourName
                y: 20
                onTextChanged: {
                    AppConfig.Name = txtYourName.text;
                }
            }
        }


        Item {
            id: homeAirport
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.column: 0
            Layout.row: 3
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50
            Label {
                color: "#333333"
                text: qsTr("Home Airport")
                renderType: Text.NativeRendering
                font.pixelSize: 13
            }
            CustomTextField {
                id: txtHomeAirport
                y: 20
                onTextChanged: {
                    txtHomeAirport.text = txtHomeAirport.text.toUpperCase()
                    AppConfig.HomeAirport = txtHomeAirport.text;
                }
                validator: RegularExpressionValidator {
                    regularExpression: /[a-zA-Z0-9]{4}/
                }
            }
        }

        Item {
            id: networkServer
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredWidth: 50
            Layout.column: 0
            Layout.row: 4
            Label {
                id: networkServerLabel
                color: "#333333"
                text: qsTr("VATSIM Server")
                font.pixelSize: 13
                renderType: Text.NativeRendering
            }
            CustomComboBox {
                id: networkServerCombobox
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: networkServerLabel.bottom
                anchors.topMargin: 5
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                textRole: "name"
                valueRole: "address"
                onModelChanged: {
                    currentIndex = find(AppConfig.ServerName);
                    serverListLoaded = true;
                }
                onCurrentIndexChanged: {
                    if(serverListLoaded) {
                        AppConfig.ServerName = networkServerCombobox.textAt(currentIndex)
                    }
                }
            }
        }

        Item {
            id: clientOptions
            Layout.fillHeight: true
            Layout.column: 1
            Layout.row: 0
            Layout.rowSpan: 5
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            Layout.fillWidth: true

            ColumnLayout {
                id: columnLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                spacing: 0

                CustomSwitch {
                    id: switchAutoModeC
                    text: "Automatically set transponder to Mode C on takeoff"
                    font.pixelSize: 13
                    clip: false
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 287
                    onCheckedChanged: {
                        AppConfig.AutoModeC = switchAutoModeC.checked
                    }
                }

                CustomSwitch {
                    id: switchAlertPrivateMessage
                    text: "Alert when new private message received"
                    font.pixelSize: 13
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 287
                    onCheckedChanged: {
                        AppConfig.AlertPrivateMessage = switchAlertPrivateMessage.checked
                    }
                }

                CustomSwitch {
                    id: switchAlertDirectRadioMessage
                    text: "Alert when direct radio message received"
                    font.pixelSize: 13
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 287
                    onCheckedChanged: {
                        AppConfig.AlertDirectRadioMessage = switchAlertDirectRadioMessage.checked
                    }
                }

                CustomSwitch {
                    id: switchAlertSelcal
                    text: "Alert when SELCAL notification received"
                    font.pixelSize: 13
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 287
                    onCheckedChanged: {
                        AppConfig.AlertSelcal = switchAlertSelcal.checked
                    }
                }

                CustomSwitch {
                    id: switchAlertDisconnect
                    text: "Alert when disconnected from the network"
                    font.pixelSize: 13
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 287
                    onCheckedChanged: {
                        AppConfig.AlertDisconnect = switchAlertDisconnect.checked
                    }
                }

                CustomSwitch {
                    id: switchDisableSounds
                    text: "Disable notification sounds"
                    font.pixelSize: 13
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 287
                    onCheckedChanged: {
                        AppConfig.DisableNotificationSounds = switchDisableSounds.checked
                    }
                }
            }
        }

        Item {
            id: audioApi
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.column: 0
            Layout.columnSpan: 2
            Layout.preferredWidth: 50
            Layout.row: 6
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Text {
                id: audioApiLabel
                color: "#333333"
                text: qsTr("Audio API")
                renderType: Text.NativeRendering
                font.pixelSize: 13
            }

            CustomComboBox {
                id: audioApiList
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: audioApiLabel.bottom
                anchors.topMargin: 5
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                textRole: "name"
                valueRole: "id"
                onModelChanged: {
                    currentIndex = audioApiList.find(AppConfig.AudioApi)
                    apiListLoaded = true
                }
                onCurrentIndexChanged: {
                    if(apiListLoaded) {
                        AppConfig.AudioApi = audioApiList.textAt(currentIndex)
                        var api = audioApiList.valueAt(currentIndex)
                        audio.setAudioApi(api)
                    }
                }
            }
        }

        Item {
            id: microphoneDevice
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.column: 0
            Layout.preferredWidth: 50
            Layout.row: 7
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Text {
                id: text7
                color: "#333333"
                text: qsTr("Microphone Device")
                renderType: Text.NativeRendering
                font.pixelSize: 13
            }

            CustomComboBox {
                id: inputDeviceList
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: text7.bottom
                anchors.topMargin: 5
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                textRole: "name"
                valueRole: "name"
                onModelChanged: {
                    currentIndex = inputDeviceList.indexOfValue(AppConfig.InputDevice)
                    inputDeviceListLoaded = true
                }
                onCurrentIndexChanged: {
                    if(inputDeviceListLoaded) {
                        var device = inputDeviceList.textAt(currentIndex)
                        AppConfig.InputDevice = device
                        audio.setInputDevice(device)
                    }
                }
            }
        }


        Item {
            id: listenDevice
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.column: 1
            Layout.row: 7
            Layout.preferredWidth: 50
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Text {
                id: text9
                color: "#333333"
                text: qsTr("Listen Device")
                renderType: Text.NativeRendering
                font.pixelSize: 13
            }

            CustomComboBox {
                id: outputDeviceList
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: text9.bottom
                anchors.topMargin: 5
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                textRole: "name"
                valueRole: "name"
                onModelChanged: {
                    currentIndex = outputDeviceList.indexOfValue(AppConfig.OutputDevice)
                    outputDeviceListLoaded = true
                }
                onCurrentIndexChanged: {
                    if(outputDeviceListLoaded) {
                        var device = outputDeviceList.textAt(currentIndex)
                        AppConfig.OutputDevice = device
                        audio.setOutputDevice(device)
                    }
                }
            }
        }


        Item {
            id: microphoneLevel
            height: 130
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.column: 0
            Layout.row: 8
            Layout.fillWidth: true

            ColumnLayout {
                id: columnLayout2
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.rightMargin: 0
                anchors.leftMargin: 0

                PeakLevelControl {
                    id: peakLevel
                    width: 300
                    height: 13
                }

                Text {
                    id: text10
                    color: "#333333"
                    text: qsTr("Adjust your system's microphone level so the volume peak indicator remains green when speaking normally.")
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    renderType: Text.NativeRendering
                }
            }

            ColumnLayout {
                id: columnLayout3
                height: 65
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 75
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                spacing: 0

                CustomSwitch {
                    id: switchEnableHfSquelch
                    text: "Enable HF Squelch"
                    font.pixelSize: 13
                    leftPadding: 0
                    onCheckedChanged: {
                        audio.enableHfSquelch(switchEnableHfSquelch.checked)
                    }
                }

                CustomSwitch {
                    id: switchDisableRadioEffects
                    text: "Disable Radio Effects"
                    font.pixelSize: 13
                    leftPadding: 0
                    onCheckedChanged: {
                        audio.disableAudioEffects(switchDisableRadioEffects.checked)
                    }
                }
            }
        }


        Item {
            id: volumeLevels
            height: 130
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillWidth: true
            Layout.column: 1
            Layout.row: 8
            ColumnLayout {
                id: columnLayout4
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 0
                anchors.topMargin: 0
                anchors.rightMargin: 0
                anchors.leftMargin: 0

                VolumeSlider {
                    id: com1Slider
                    comLabel: "COM1"
                    onVolumeValueChanged: {
                        audio.setCom1Volume(volume)
                    }
                }

                VolumeSlider {
                    id: com2Slider
                    comLabel: "COM2"
                    onVolumeValueChanged: {
                        audio.setCom2Volume(volume)
                    }
                }
            }
        }
    }
}
