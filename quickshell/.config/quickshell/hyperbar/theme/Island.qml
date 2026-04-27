import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "."

Item {
    id: root
    default property alias content: inner.data

    property real radius: 14
    property real paddingH: 12
    property real paddingV: 6
    property color bgColor: pal.surface_container
    property color borderColor: pal.outline_variant
    property real borderWidth: 1
    property bool hoverLift: true
    property real liftOffset: -2
    property int  liftDuration: 180
    property real shadowBlur: 10
    property real shadowOffsetY: 2
    property real shadowOpacity: 0.35

    implicitWidth:  inner.implicitWidth  + paddingH * 2
    implicitHeight: inner.implicitHeight + paddingV * 2

    Palette { id: pal }

    Item {
        id: liftWrapper
        width: parent.width
        height: parent.height
        y: (root.hoverLift && hh.hovered) ? root.liftOffset : 0

        Behavior on y {
            NumberAnimation { duration: root.liftDuration; easing.type: Easing.OutCubic }
        }

        RectangularShadow {
            anchors.fill: bg
            radius: root.radius
            blur: root.shadowBlur
            offset.y: root.shadowOffsetY
            color: Qt.rgba(0, 0, 0, root.shadowOpacity)
            spread: 0
        }

        Rectangle {
            id: bg
            anchors.fill: parent
            radius: root.radius
            color: root.bgColor
            border.color: root.borderColor
            border.width: root.borderWidth
            antialiasing: true
        }

        ColumnLayout {
            id: inner
            x: root.paddingH
            y: root.paddingV
            spacing: 0
        }
    }

    HoverHandler { id: hh }
}
