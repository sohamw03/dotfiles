import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: iconButton

    signal clicked

    property bool active: false
    readonly property bool isActive: active || focus || mouseArea.pressed || mouseArea.containsMouse
    property string icon: ""
    property int iconSize: 16
    property color contentColor: "#FFFFFF"
    property color activeContentColor: "#FFFFFF"
    property string label: ""
    property bool showLabel: true
    property string fontFamily: "RedHatDisplay"
    property int fontWeight: 400
    property int fontSize: 12
    property color backgroundColor: "#FFFFFF"
    property double backgroundOpacity: 0.0
    property color activeBackgroundColor: "#FFFFFF"
    property double activeBackgroundOpacity: 0.15
    property string tooltipText: ""
    property int borderRadius: 10
    property int borderRadiusLeft: borderRadius
    property int borderRadiusRight: borderRadius
    property int borderSize: 0
    property color borderColor: isActive ? iconButton.activeContentColor : iconButton.contentColor
    property int preferredWidth: -1
    property real rippleX: width / 2
    property real rippleY: height / 2

    width: preferredWidth !== -1 ? (preferredWidth * Config.generalScale) : buttonContentRow.width // childrenRect doesn't update for some reason
    height: iconSize * 2 * Config.generalScale

    Rectangle {
        id: buttonBackground
        anchors.fill: parent
        color: iconButton.isActive ? iconButton.activeBackgroundColor : iconButton.backgroundColor
        opacity: iconButton.isActive ? iconButton.activeBackgroundOpacity : iconButton.backgroundOpacity
        topLeftRadius: iconButton.borderRadiusLeft * Config.generalScale
        topRightRadius: iconButton.borderRadiusRight * Config.generalScale
        bottomLeftRadius: iconButton.borderRadiusLeft * Config.generalScale
        bottomRightRadius: iconButton.borderRadiusRight * Config.generalScale

        Behavior on opacity {
            enabled: Config.enableAnimations
            NumberAnimation {
                duration: 250
            }
        }
    }

    Item {
        id: rippleLayer
        anchors.fill: parent
        clip: true

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            topLeftRadius: iconButton.borderRadiusLeft * Config.generalScale
            topRightRadius: iconButton.borderRadiusRight * Config.generalScale
            bottomLeftRadius: iconButton.borderRadiusLeft * Config.generalScale
            bottomRightRadius: iconButton.borderRadiusRight * Config.generalScale

            Rectangle {
                id: ripple
                property real diameter: Math.max(iconButton.width, iconButton.height) * 2.2
                width: 0
                height: width
                radius: width / 2
                x: iconButton.rippleX - width / 2
                y: iconButton.rippleY - height / 2
                color: iconButton.isActive ? iconButton.activeContentColor : iconButton.contentColor
                opacity: 0
                antialiasing: true
            }
        }
    }

    ParallelAnimation {
        id: rippleAnimation
        NumberAnimation {
            target: ripple
            property: "width"
            from: 0
            to: ripple.diameter
            duration: 420
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: ripple
            property: "opacity"
            from: 0.22
            to: 0
            duration: 520
            easing.type: Easing.OutQuad
        }
    }

    Rectangle {
        id: buttonBorder
        color: "transparent"
        topLeftRadius: iconButton.borderRadiusLeft * Config.generalScale
        topRightRadius: iconButton.borderRadiusRight * Config.generalScale
        bottomLeftRadius: iconButton.borderRadiusLeft * Config.generalScale
        bottomRightRadius: iconButton.borderRadiusRight * Config.generalScale
        anchors.fill: parent
        visible: iconButton.borderSize > 0 || iconButton.focus
        border {
            color: iconButton.borderColor
            width: iconButton.focus ? (iconButton.borderSize * Config.generalScale) || 2 : (iconButton.borderSize > 0 ? (iconButton.borderSize * Config.generalScale) : 0)
        }
    }

    RowLayout {
        id: buttonContentRow
        height: parent.height
        spacing: 0

        Rectangle {
            id: iconContainer
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Image {
                id: buttonIcon
                source: iconButton.icon
                anchors.centerIn: parent
                width: iconButton.iconSize * Config.generalScale
                height: width
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                visible: false // Apparently `MultiEffect.colorization` replaces the Image
            }

            MultiEffect {
                id: iconEffect
                source: buttonIcon
                anchors.fill: buttonIcon
                colorization: 1
                colorizationColor: iconButton.isActive ? iconButton.activeContentColor : iconButton.contentColor
                antialiasing: true
                opacity: iconButton.enabled ? 1.0 : 0.5

                Behavior on opacity {
                    enabled: Config.enableAnimations
                    NumberAnimation {
                        duration: 250
                    }
                }

                Behavior on colorizationColor {
                    enabled: Config.enableAnimations
                    ColorAnimation {
                        duration: 250
                    }
                }
            }
        }

        Text {
            id: buttonLabel
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: iconButton.label
            visible: iconButton.showLabel && text !== ""
            font.family: iconButton.fontFamily
            font.pixelSize: iconButton.fontSize * Config.generalScale
            font.weight: iconButton.fontWeight
            rightPadding: 10
            color: iconButton.isActive ? iconButton.activeContentColor : iconButton.contentColor
            opacity: iconButton.enabled ? 1.0 : 0.5
            Behavior on opacity {
                enabled: Config.enableAnimations
                NumberAnimation {
                    duration: 250
                }
            }
            Component.onCompleted: {
                if (iconButton.preferredWidth !== -1) {
                    Layout.preferredWidth = iconButton.width - iconContainer.width;
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: parent.enabled
        onPressed: function (mouse) {
            if (!iconButton.enabled)
                return;

            iconButton.rippleX = mouse.x;
            iconButton.rippleY = mouse.y;
            rippleAnimation.restart();
        }
        onClicked: iconButton.clicked()
        cursorShape: Qt.PointingHandCursor

        ToolTip {
            parent: mouseArea
            enabled: Config.tooltipsEnable
            property bool shouldShow: enabled && mouseArea.containsMouse && iconButton.tooltipText !== "" || enabled && iconButton.focus && iconButton.tooltipText !== ""
            visible: shouldShow
            delay: 300

            contentItem: Text {
                font.family: Config.tooltipsFontFamily
                font.pixelSize: Config.tooltipsFontSize * Config.generalScale
                text: iconButton.tooltipText
                color: Config.tooltipsContentColor
            }

            background: Rectangle {
                color: Config.tooltipsBackgroundColor
                opacity: Config.tooltipsBackgroundOpacity
                border.width: 0
                radius: Config.tooltipsBorderRadius * Config.generalScale
            }
        }
    }

    Keys.onPressed: function (event) {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter || event.key === Qt.Key_Space) {
            iconButton.clicked();
        }
    }
}
