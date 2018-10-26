/*!
Copyright (c) 2018

Patrick José Pereira
Based on Bin Chen work

This software is provided 'as-is', without any express or implied warranty. In
no event will the authors be held liable for any damages arising from the use
of this software. Permission is granted to anyone to use this software for any
purpose, including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim
that you wrote the original software. If you use this software in a product, an
acknowledgment in the product documentation would be appreciated but is not
required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
*/
import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import QRender 1.0 as QRender

import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1280
    height: 768
    Material.accent: Material.Red

    Image {
        z: 50
        height: 200
        width: height
        source: "/resources/heightmap.png"
        opacity: 0.3

        Rectangle {
            height: 6
            width: height
            radius: height
            color: 'red'
            x: parent.height*(sceneRoot.vehicleItem.origin.x/60)/2 + parent.height/2
            y: parent.height*(sceneRoot.vehicleItem.origin.z/60)/2 + parent.height/2
        }
    }

    Item {
        id: bars
        z: 50
        x: 0
        y: appWindow.height - 50
        RowLayout {
            anchors.fill: parent
            Rectangle {
                y: -height
                height: 100*sceneRoot.s1
                width: 10
                color: "green"
            }
            Rectangle {
                y: -height
                height: 100*sceneRoot.s2
                width: 10
                color: "green"
            }
            Rectangle {
                y: -height
                height: 100*sceneRoot.s3
                width: 10
                color: "green"
            }
            Rectangle {
                y: -height
                height: 100*sceneRoot.s4
                width: 10
                color: "green"
            }
            Rectangle {
                y: -height
                height: 100*sceneRoot.s5
                width: 10
                color: "green"
            }
        }
    }

    Simulation {
        id: sceneRoot
        anchors.fill: parent
        followVehicle: followVehicle.checked
        run: runCB.checked
        linearFact: linearSlider.value
        angularFact: angularSlider.value
    }

    CircularGauge {
        id: gauge
        z: 50
        opacity: 0.8
        maximumValue: 100
        minimumValue: 0
        value: sceneRoot.linearSpeed*100
        tickmarksVisible: true
        stepSize: 1

        anchors {
            bottom: parent.bottom
            right: parent.right
        }

        Behavior on value {
            NumberAnimation {
                duration: 1000
            }
        }
    }

    Image {
        id: part
        z: 50
        height: gauge.height*0.8
        width: height*1.2
        source: "/resources/kart_part.png"
        opacity: 0.8

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }

        transform: Rotation {
            origin.x: part.width/2
            origin.y: part.height/2
            axis { x: 0; y: 0; z: 1 }
            angle: -10*sceneRoot.angularAngle
        }
    }

    QRender.FpsText {
        anchors {
            top: parent.top
            right: parent.right
        }
    }

    // can we have the application header only when there is no project page?
    header: ToolBar {
        id: toolBar
        onFocusChanged: {
            sceneRoot.focus = true;
        }

        RowLayout {
            spacing: 5 //default

            ToolButton {
                text: "Reset"
                onClicked: {
                }
            }

            CheckBox {
                id: runCB
                text: qsTr("Run")
                checked: false
            }

            CheckBox {
                id: followVehicle
                text: qsTr("Follow")
                checked: true
            }
            ToolButton {
                text: sceneRoot.world.running ? qsTr("Stop"):qsTr("Start")
                onClicked: {
                    sceneRoot.world.running = !sceneRoot.world.running;
                }
            }
            Text {
                text: "Linear factor: " + linearSlider.value.toFixed(2)
                color: "white"
            }
            Slider {
                id: linearSlider
                Layout.fillWidth: true
                from: 0.0
                to: 0.8
                value: 0.2
            }
            Text {
                text: "Angular factor: " + angularSlider.value.toFixed(2)
                color: "white"
            }
            Slider {
                id: angularSlider
                Layout.fillWidth: true
                from: 0.0
                to: 0.5
                value: 0.15
            }
        }
    }
}
