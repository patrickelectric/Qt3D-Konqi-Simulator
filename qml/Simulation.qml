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
import Qt3D.Core 2.0
import Qt3D.Render 2.9
import Qt3D.Input 2.0
import Qt3D.Extras 2.9
import Qt3D.Logic 2.0

import QtQml.Models 2.2
import QtQuick 2.10 as QQ2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Scene3D 2.0
import QBullet 1.0 as QB
import QBullet.Tools 1.0 as QBTools
import QRender 1.0 as QRender

import Line 1.0

QQ2.Item {
    id: root
    focus: true
    property bool showDebug: false
    property real pickingIndicatorSize: 0.2
    property bool followVehicle: false
    property real gamma: 1.8
    property alias exposure: viewCamera.exposure
    property var vehicleItem: vehicle
    property real sensorDist: 15
    property bool run: false

    property real angularFact: 0.3
    property real linearFact: 0.5

    property real s1: 0
    property real s2: 0
    property real s3: 0
    property real s4: 0
    property real s5: 0

    property real linearSpeed: 0
    property real angularAngle: 0

    function checkSensors() {
        rayTestL.hitTest()
        rayTestLF.hitTest()
        rayTestF.hitTest()
        rayTestRF.hitTest()
        rayTestR.hitTest()
    }

    QB.RayTest {
        id: rayTestL
        world: root.world
        rayFrom: vehicle.origin
        rayTo: vehicle.toWordPosition(Math.PI/2, sensorDist)
    }

    QB.RayTest {
        id: rayTestLF
        world: root.world
        rayFrom: vehicle.origin
        rayTo: vehicle.toWordPosition(Math.PI/4, sensorDist)
    }

    QB.RayTest {
        id: rayTestF
        world: root.world
        rayFrom: vehicle.origin
        rayTo: vehicle.toWordPosition(0, sensorDist)
    }

    QB.RayTest {
        id: rayTestRF
        world: root.world
        rayFrom: vehicle.origin
        rayTo: vehicle.toWordPosition(-Math.PI/4, sensorDist)
    }

    QB.RayTest {
        id: rayTestR
        world: root.world
        rayFrom: vehicle.origin
        rayTo: vehicle.toWordPosition(-Math.PI/2, sensorDist)
    }

    QQ2.Timer {
        id: timer
        running: root.run
        interval: 100; repeat: true
        property var lastAngular: 0
        property var lastLinear: 0
        onTriggered: {
            // Poor obstacle avoidance logic
            var linear = 0
            var angle = 0
            if(rayTestL.hitBody != null) {
                var r = sensorDist/rayTestL.hitPosition.minus(vehicle.origin).length()
                angle -= 1.0*r;
                linear += 1/r
                s1 = 1/r
            }
            if(rayTestLF.hitBody) {
                var r = sensorDist/rayTestLF.hitPosition.minus(vehicle.origin).length()
                angle -= 2*r
                linear += 1/r
                s2 = 1/r
            }
            if(rayTestRF.hitBody) {
                var r = sensorDist/rayTestRF.hitPosition.minus(vehicle.origin).length()
                angle += 2*r
                linear += 1/r
                s4 = 1/r
            }
            if(rayTestR.hitBody) {
                var r = sensorDist/rayTestR.hitPosition.minus(vehicle.origin).length()
                angle += 1.0*r
                linear += 1/r
                s5 = 1/r
            }
            if(!rayTestF.hitBody) {
                linear += 0.3
                s3 = rayTestF.hitPosition.minus(vehicle.origin).length()/sensorDist
            } else if(linear === 0) {
                linear += 1
            }
            lastAngular = 0.1*lastAngular + 0.9*angle
            lastLinear = 0.1*lastLinear + 0.9*linear
            linearSpeed = lastLinear*linearFact
            angularAngle = lastAngular*angularFact
            vehicle.acc(lastLinear*linearFact, lastAngular*angularFact);
        }
    }

    QQ2.Keys.onPressed: {
        if(event.key===Qt.Key_Up) {
            vehicle.forward();
        } else if(event.key===Qt.Key_Down) {
            vehicle.backward();
        } else if(event.key===Qt.Key_Left) {
            vehicle.turnLeft();
        } else if(event.key===Qt.Key_Right) {
            vehicle.turnRight();
        }
    }

    QQ2.Keys.onReleased: {

        if(event.key===Qt.Key_Up) {
            vehicle.stop();
        } else if(event.key===Qt.Key_Down) {
            vehicle.stop();
        } else if(event.key===Qt.Key_Left) {
            vehicle.stopTurning();
        } else if(event.key===Qt.Key_Right) {
            vehicle.stopTurning();
        }
    }

    property alias world: world

    Scene3D {
        id: scene3D
        anchors.fill: parent

        cameraAspectRatioMode: Scene3D.UserAspectRatio

        aspects: ["render", "input", "logic"]

        multisample: false // default
        antialiasing: false
        smooth: false

        Entity {
            id: sceneRoot

            Camera {
                id: viewCamera
                projectionType: CameraLens.PerspectiveProjection
                fieldOfView: 40
                aspectRatio: appWindow.width / appWindow.height
                nearPlane: 1
                farPlane: 200.0
                exposure: 0
                //                position: vehicle.origin.plus(Qt.vector3d(1, 1, 1).times(20))
                //                viewCenter: vehicle.origin
                position: Qt.vector3d(10, 10, 10)
                viewCenter: Qt.vector3d(0, 0, 0)
                upVector: Qt.vector3d(0, 1, 0)
                property vector3d lookAtVector: viewCenter.minus(position).normalized()
                property vector3d rightVector: lookAtVector.crossProduct(upVector).normalized()

                QQ2.Binding {
                    when: root.followVehicle
                    target: viewCamera; property: "position"; value: vehicle.origin.plus(Qt.vector3d(1, 1, 1).times(20))
                }

                QQ2.Binding {
                    when: root.followVehicle
                    target: viewCamera; property: "viewCenter"; value: vehicle.origin
                }
            }

            Camera {
                id: lightCamera

                property vector3d lightIntensity: Qt.vector3d(1,1,1)

                readonly property matrix4x4 shadowMatrix: Qt.matrix4x4(0.5, 0.0, 0.0, 0.5,
                                                                       0.0, 0.5, 0.0, 0.5,
                                                                       0.0, 0.0, 0.5, 0.5,
                                                                       0.0, 0.0, 0.0, 1.0)

                readonly property matrix4x4 shadowViewProjection: shadowMatrix.times(projectionMatrix.times(viewMatrix))

                position: vehicle.origin.plus(Qt.vector3d(30, 20, 30))
                viewCenter: vehicle.origin
                //                position: Qt.vector3d(30, 30, 30)
                //                viewCenter: Qt.vector3d(0, 0, 0)
                upVector: Qt.vector3d(0.0, 1.0, 0.0)


                //Use orthographic projection for direction light.
                projectionType: CameraLens.OrthographicProjection
                nearPlane: 1 // meters
                farPlane: 100 // meters
                fieldOfView: 180
                //left, right, top, bottom define shadow map region.
                left: -20
                right: 20
                top: 20
                bottom: -20
                aspectRatio: 1
            }

            OrbitCameraController {
                enabled: !root.followVehicle
                camera: viewCamera
                linearSpeed: 100
                lookSpeed: 200
            }

            components: [
                RenderSettings {
                    QRender.ShadowFrameGraph {
                        id: frameGraph
                        //clearColor: "#CC000000" // slightly transparent black
                        lightCamera: lightCamera
                        //shadowMapSize: 128
                        QRender.ShadowFrameGraphViewport {
                            camera: viewCamera
                            depthTexture: frameGraph.depthTexture
                            lightCamera: lightCamera
                            normalizedRect: Qt.rect(0, 0, 1, 1)
                        }
                    }
                },
                // Event Source will be set by the Qt3DQuickWindow
                InputSettings {}

            ]

            Entity {
                components: [
                    PhongMaterial { ambient: rayTestL.hitBody ? "red" : "darkGreen" },
                    Line {
                        startPoint: rayTestL.rayFrom
                        endPoint: rayTestL.hitBody ? rayTestL.hitPosition : rayTestL.rayFrom
                    }
                ]
            }

            Entity {
                components: [
                    PhongMaterial { ambient: rayTestLF.hitBody ? "red" : "darkGreen" },
                    Line {
                        startPoint: rayTestLF.rayFrom
                        endPoint: rayTestLF.hitBody ? rayTestLF.hitPosition : rayTestLF.rayFrom
                    }
                ]
            }

            Entity {
                components: [
                    PhongMaterial { ambient: rayTestF.hitBody ? "red" : "darkGreen" },
                    Line {
                        startPoint: rayTestF.rayFrom
                        endPoint: rayTestF.hitBody ? rayTestF.hitPosition : rayTestF.rayFrom
                    }
                ]
            }

            Entity {
                components: [
                    PhongMaterial { ambient: rayTestRF.hitBody ? "red" : "darkGreen" },
                    Line {
                        startPoint: rayTestRF.rayFrom
                        endPoint: rayTestRF.hitBody ? rayTestRF.hitPosition : rayTestRF.rayFrom
                    }
                ]
            }

            Entity {
                components: [
                    PhongMaterial { ambient: rayTestR.hitBody ? "red" : "darkGreen" },
                    Line {
                        startPoint: rayTestR.rayFrom
                        endPoint: rayTestR.hitBody ? rayTestR.hitPosition : rayTestR.rayFrom
                    }
                ]
            }

            Car {
                id: vehicle
                world: world
                showDebug: root.showDebug
                onOriginChanged: {
                    checkSensors()
                }
            }

            QBTools.Heightmap {
                id: heightmap
                world: world
                heightmap: "qrc:/resources/heightmap.png"
                scale: Qt.vector3d(0.1, 0.015, 0.1)
                friction: 0.9
                material: QRender.DiffusemapMaterial {
                    diffuseTexture: TextureLoader {
                        source: "qrc:/resources/heightmap_texture.png"
                    }
                }
            }

            QB.DiscreteDynamicsWorld {
                id: world
                gravity: Qt.vector3d(0, -9.8, 0)
                running: true
            }
        }//Entity: root entity

    }//Scene3D

    function getTanFromDegrees(degrees) {
        return Math.tan(degrees * Math.PI/180.0);
    }
}
