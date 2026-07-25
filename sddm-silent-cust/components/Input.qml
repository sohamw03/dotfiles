import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: input

    signal accepted

    property string placeholder: ""
    property alias input: textField
    property bool isPassword: false
    property bool splitBorderRadius: false
    property alias text: textField.text
    property string icon: ""
    property bool enabled: true

    width: Config.passwordInputWidth * Config.generalScale
    height: Config.passwordInputHeight * Config.generalScale

    TextField {
        id: textField
        anchors.fill: parent
        color: Config.passwordInputContentColor
        enabled: input.enabled
        echoMode: input.isPassword ? TextInput.Password : TextInput.Normal
        passwordCharacter: Config.passwordInputMaskedCharacter
        activeFocusOnTab: true
        selectByMouse: true
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextField.AlignVCenter
        font.family: Config.passwordInputFontFamily
        font.pixelSize: Math.max(8, Config.passwordInputFontSize * Config.generalScale)
        font.weight: input.isPassword ? Font.Bold : Font.Normal
        background: Rectangle {
            anchors.fill: parent
            color: Config.passwordInputBackgroundColor
            opacity: Config.passwordInputBackgroundOpacity
            topLeftRadius: Config.passwordInputBorderRadiusLeft * Config.generalScale
            bottomLeftRadius: Config.passwordInputBorderRadiusLeft * Config.generalScale
            topRightRadius: input.splitBorderRadius ? Config.passwordInputBorderRadiusRight * Config.generalScale : Config.passwordInputBorderRadiusLeft * Config.generalScale
            bottomRightRadius: input.splitBorderRadius ? Config.passwordInputBorderRadiusRight * Config.generalScale : Config.passwordInputBorderRadiusLeft * Config.generalScale
        }
        leftPadding: Config.passwordInputDisplayIcon ? height : 12
        rightPadding: Config.passwordInputDisplayIcon ? height : 12
        onAccepted: input.accepted()

        Rectangle {
            anchors.fill: parent
            border.width: Config.passwordInputBorderSize * Config.generalScale
            border.color: Config.passwordInputBorderColor
            color: "transparent"
            topLeftRadius: Config.passwordInputBorderRadiusLeft * Config.generalScale
            bottomLeftRadius: Config.passwordInputBorderRadiusLeft * Config.generalScale
            topRightRadius: input.splitBorderRadius ? Config.passwordInputBorderRadiusRight * Config.generalScale : Config.passwordInputBorderRadiusLeft * Config.generalScale
            bottomRightRadius: input.splitBorderRadius ? Config.passwordInputBorderRadiusRight * Config.generalScale : Config.passwordInputBorderRadiusLeft * Config.generalScale
        }

        Item {
            anchors.fill: parent

            Rectangle {
                id: iconContainer
                color: "transparent"
                visible: Config.passwordInputDisplayIcon
                height: parent.height
                width: height
                anchors.left: parent.left

                Image {
                    id: icon
                    source: input.icon
                    anchors.centerIn: parent
                    width: Math.max(1, Config.passwordInputIconSize * Config.generalScale)
                    height: width
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                    opacity: input.enabled ? 1.0 : 0.3
                    Behavior on opacity {
                        enabled: Config.enableAnimations
                        NumberAnimation {
                            duration: 250
                        }
                    }

                    MultiEffect {
                        source: parent
                        anchors.fill: parent
                        colorization: 1
                        colorizationColor: textField.color
                    }
                }
            }

            Text {
                id: placeholderLabel
                anchors {
                    centerIn: parent
                }
                padding: 0
                visible: textField.text.length === 0 && (!textField.preeditText || textField.preeditText.length === 0)
                text: input.placeholder
                color: Qt.alpha(textField.color, 0.45)
                font.pixelSize: Math.max(8, textField.font.pixelSize || 12)
                font.family: textField.font.family || "sans-serif"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: textField.verticalAlignment
                font.italic: false
                font.weight: Font.Bold
            }
        }
    }
}
