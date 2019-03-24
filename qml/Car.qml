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
import Qt3D.Render 2.0
import QtQuick 2.10 as QQ2
import QBullet 1.0 as QB
import QRender 1.0 as QRender

Entity {
    id: root

    function acc(linear, angular) {
        body2steerWheel.angularServoTarget = Qt.vector3d(0, -45*angular/1.5, 0);
        carBody.applyCentralImpulse(carBody.xAxis.times(200*linear));
    }

    function forward() {
        engine.forward = true
        engine.backward = false
    }

    function backward() {
        engine.forward = false
        engine.backward = true
    }

    function stop() {
        engine.forward = false
        engine.backward = false
    }

    function turnLeft() {
        body2steerWheel.angularServoTarget = Qt.vector3d(0, -45, 0);
    }

    function turnRight() {
        body2steerWheel.angularServoTarget = Qt.vector3d(0, 45, 0);
    }

    function stopTurning() {
        body2steerWheel.angularServoTarget = Qt.vector3d(0, 0, 0);
    }

    function toWordPosition(angle, distance) {
        var finalAngle = vehicle.angle*Math.PI/180 + angle
        return origin.plus(Qt.vector3d(distance*Math.sin(finalAngle), 0, distance*Math.cos(finalAngle)))
    }

    property QB.DiscreteDynamicsWorld world: null
    property real suspensionHeight: -0.5
    property real wheelRollingFriction: 0.05
    property real wheelFriction: 0.95
    property real wheelLinearDamping: 0.5
    property real wheelAngularDamping: 0.5
    property real wheelRestitution: 0.1
    property real wheelMass: 5
    property real axisMass: 10
    property real bodyMass: 150
    property real steer: steerWheel.yaw - carBody.yaw
    property real initialHeight: 4
    property alias steerResetTorgue: body2steerWheel.maxAngularMotorForce
    readonly property alias origin: carBody.origin
    readonly property real angle: carBody.yaw + 90
    property bool showDebug: false
    property var initialPos: Qt.vector3d(47, 2, -3)

    //Wheels
    Wheel {
        id: wheelFrontRight
        world: root.world
        origin: initialPos.plus(Qt.vector3d(2, 0, 1))
        pitch: -90
        mass: root.wheelMass
        friction: root.wheelFriction
        rollingFriction: root.wheelRollingFriction
        linearDamping: root.wheelLinearDamping
        angularDamping: root.wheelAngularDamping
        restitution: root.wheelRestitution
        showDebug: root.showDebug
    }

    Wheel {
        id: wheelFrontLeft

        world: root.world
        origin: initialPos.plus(Qt.vector3d(2, 0, -1))
        pitch: 90
        mass: root.wheelMass
        friction: root.wheelFriction
        rollingFriction: root.wheelRollingFriction
        linearDamping: root.wheelLinearDamping
        angularDamping: root.wheelAngularDamping
        restitution: root.wheelRestitution
        showDebug: root.showDebug
    }

    Wheel {
        id: wheelRearRight

        world: root.world
        origin: initialPos.plus(Qt.vector3d(-2, 0, 1))
        pitch: -90
        mass: root.wheelMass
        friction: root.wheelFriction
        rollingFriction: root.wheelRollingFriction
        linearDamping: root.wheelLinearDamping
        angularDamping: root.wheelAngularDamping
        restitution: root.wheelRestitution
        showDebug: root.showDebug
    }


    Wheel {
        id: wheelBRearLeft

        world: root.world
        origin: initialPos.plus(Qt.vector3d(-2, 0, -1))
        pitch: 90
        mass: root.wheelMass
        friction: root.wheelFriction
        rollingFriction: root.wheelRollingFriction
        linearDamping: root.wheelLinearDamping
        angularDamping: root.wheelAngularDamping
        restitution: root.wheelRestitution
        showDebug: root.showDebug
    }

    //Axis
    QB.BoxShape {
        id: axisShape
        dimensions: Qt.vector3d(0.3, 0.3, 0.3)
    }

    QB.RigidBody {
        id: axisRight
        world: root.world
        collisionShape: axisShape
        origin: wheelFrontRight.origin
        mass: root.axisMass
    }

    QB.RigidBody {
        id: axisLeft
        world: root.world
        collisionShape: axisShape
        origin: wheelFrontLeft.origin
        mass: root.axisMass
    }

    //Body
    QB.BoxShape {
        id: carBodyShape
        dimensions: Qt.vector3d(3, 0.5, 1)
    }

    QB.RigidBody {
        id: carBody
        world: root.world
        collisionShape: carBodyShape
        origin: initialPos
        mass: root.bodyMass
        yaw: -20
        linearDamping: 0.5
    }

    //Steering wheel
    QB.RigidBody {
        id: steerWheel
        world: root.world
        collisionShape: axisShape
        origin: initialPos
        mass: 1
    }

    //Constraints

    //Steering wheel and body.
    QB.Generic6DofSpring2Constraint {
        id: body2steerWheel
        world: root.world
        rigidBodyA: carBody
        rigidBodyB: steerWheel
        pivotA: Qt.vector3d(0, 0.25, 0)
        pivotB: Qt.vector3d(0, -axisShape.dimensions.y/2, 0)
        angularLowerLimit: Qt.vector3d(0, -45, 0)
        angularUpperLimit: Qt.vector3d(0, 45, 0)

        angularMotorYEnabled: true
        angularServoYEnabled: true
        angularTargetVelocity: Qt.vector3d(0, 10, 0)
        angularServoTarget: Qt.vector3d(0, 0, 0)
        maxAngularMotorForce: Qt.vector3d(0, 10, 0)
    }

    //Front wheels and axes
    QB.HingeConstraint {
        world: root.world
        rigidBodyA: axisRight
        rigidBodyB: wheelFrontRight.body
        pivotA: Qt.vector3d(0, 0, 0.2)
        axisA: Qt.vector3d(0, 0, 1)
        axisB: Qt.vector3d(0, -1, 0)//mirror the right side wheel
    }

    QB.HingeConstraint {
        world: root.world
        rigidBodyA: axisLeft
        rigidBodyB: wheelFrontLeft.body
        pivotA: Qt.vector3d(0, 0, -0.2)
        axisA: Qt.vector3d(0, 0, 1)
        axisB: Qt.vector3d(0, 1, 0)
    }

    //Front axes and body
    QB.Generic6DofSpring2Constraint {
        world: root.world
        rigidBodyA: carBody
        rigidBodyB: axisRight
        pivotA: Qt.vector3d(2, suspensionHeight, 0.8)
        pivotB: Qt.vector3d(0, 0, 0)
        angularLowerLimit: Qt.vector3d(0, -root.steer, 0)
        angularUpperLimit: Qt.vector3d(0, -root.steer, 0)
        linearSpringYEnabled: true
        linearLowerLimit: Qt.vector3d(0, -0.5, 0)
        linearUpperLimit: Qt.vector3d(0, 0.5, 0)
        linearMotorYEnabled: true
        linearServoTarget: Qt.vector3d(0, 0, 0)
        linearServoYEnabled: true
        maxLinearMotorForce: Qt.vector3d(0, 500, 0)
        linearTargetVelocity: Qt.vector3d(0, 10, 0)
    }


    QB.Generic6DofSpring2Constraint {
        world: root.world
        rigidBodyA: carBody
        rigidBodyB: axisLeft
        pivotA: Qt.vector3d(2, suspensionHeight, -0.8)
        pivotB: Qt.vector3d(0, 0, 0)
        angularLowerLimit: Qt.vector3d(0, -root.steer, 0)
        angularUpperLimit: Qt.vector3d(0, -root.steer, 0)
        linearSpringYEnabled: true
        linearLowerLimit: Qt.vector3d(0, -0.5, 0)
        linearUpperLimit: Qt.vector3d(0, 0.5, 0)
        linearMotorYEnabled: true
        linearServoTarget: Qt.vector3d(0, 0, 0)
        linearServoYEnabled: true
        maxLinearMotorForce: Qt.vector3d(0, 500, 0)
        linearTargetVelocity: Qt.vector3d(0, 10, 0)
    }

    //Rear wheels and body
    QB.Generic6DofSpring2Constraint {
        world: root.world
        rigidBodyA: carBody
        rigidBodyB: wheelRearRight.body
        pivotA: Qt.vector3d(-2, suspensionHeight, 1)
        pivotB: Qt.vector3d(0, 0, 0)
        pitchB: 90
        angularLowerLimit: Qt.vector3d(0, 0, 0)
        angularUpperLimit: Qt.vector3d(0, 0, -1)
        linearSpringYEnabled: true
        linearLowerLimit: Qt.vector3d(0, -0.5, 0)
        linearUpperLimit: Qt.vector3d(0, 0.5, 0)
        linearMotorYEnabled: true
        linearServoTarget: Qt.vector3d(0, 0, 0)
        linearServoYEnabled: true
        maxLinearMotorForce: Qt.vector3d(0, 1500, 0)
        linearTargetVelocity: Qt.vector3d(0, 10, 0)
    }


    QB.Generic6DofSpring2Constraint {
        world: root.world
        rigidBodyA: carBody
        rigidBodyB: wheelBRearLeft.body
        pivotA: Qt.vector3d(-2, suspensionHeight, -1)
        pivotB: Qt.vector3d(0, 0, 0)
        pitchB: -90
        angularLowerLimit: Qt.vector3d(0, 0, 0)
        angularUpperLimit: Qt.vector3d(0, 0, -1)
        linearSpringYEnabled: true
        linearLowerLimit: Qt.vector3d(0, -0.5, 0)
        linearUpperLimit: Qt.vector3d(0, 0.5, 0)
        linearMotorYEnabled: true
        linearServoTarget: Qt.vector3d(0, 0, 0)
        linearServoYEnabled: true
        maxLinearMotorForce: Qt.vector3d(0, 1500, 0)
        linearTargetVelocity: Qt.vector3d(0, 10, 0)
    }

    //Engine
    QQ2.Timer {
        id: engine
        interval: 50
        running: true
        repeat: true
        property bool forward: false
        property bool backward: false

        onTriggered: {
            if(forward) {
                carBody.applyCentralImpulse(carBody.xAxis.times(500));

            } else if(backward) {
                carBody.applyCentralImpulse(carBody.xAxis.times(-500));
            }
        }
    }

    Entity {
        Mesh {
            id: mesh
            source: "qrc:/resources/kart.obj"
        }

        Transform {
            id: localTransform
            matrix: Qt.matrix4x4(carBody.matrix.m11*3, carBody.matrix.m12*3, carBody.matrix.m13*3, carBody.matrix.m14,
                                 carBody.matrix.m21*3, carBody.matrix.m22*3, carBody.matrix.m23*3, carBody.matrix.m24,
                                 carBody.matrix.m31*3, carBody.matrix.m32*3, carBody.matrix.m33*3, carBody.matrix.m34,
                                 carBody.matrix.m41, carBody.matrix.m42, carBody.matrix.m43, carBody.matrix.m44);
        }

        QRender.DiffusemapMaterial {
            id: material
            ambient: "#808080"
            shininess: 0
            alpha: 1
            textureScale: 1
            diffuse: "white"

            diffuseTexture: TextureLoader {
                source: "qrc:/resources/kart.jpg"
                generateMipMaps: true
                minificationFilter: Texture.LinearMipMapLinear
                magnificationFilter: Texture.Linear
                maximumAnisotropy: 16.0
                wrapMode {
                    x: WrapMode.Repeat
                    y: WrapMode.Repeat
                    z: WrapMode.Repeat
                }
            }

        }

        components: [
            mesh,
            material,
            localTransform
        ]
    }

    Entity {
        Mesh {
            id: kmesh
            source: "qrc:/resources/konqi.obj"
        }

        Transform {
            id: klocalTransform
            matrix: Qt.matrix4x4(carBody.matrix.m11*3, carBody.matrix.m12*3, carBody.matrix.m13*3, carBody.matrix.m14,
                                 carBody.matrix.m21*3, carBody.matrix.m22*3, carBody.matrix.m23*3, carBody.matrix.m24,
                                 carBody.matrix.m31*3, carBody.matrix.m32*3, carBody.matrix.m33*3, carBody.matrix.m34,
                                 carBody.matrix.m41, carBody.matrix.m42, carBody.matrix.m43, carBody.matrix.m44);
        }

        QRender.DiffusemapMaterial {
            id: kmaterial
            ambient: "#808080"
            shininess: 0
            alpha: 1
            textureScale: 1
            diffuse: "white"

            diffuseTexture: TextureLoader {
                source: "qrc:/resources/konqi.jpg"
                generateMipMaps: true
                minificationFilter: Texture.LinearMipMapLinear
                magnificationFilter: Texture.Linear
                maximumAnisotropy: 16.0
                wrapMode {
                    x: WrapMode.Repeat
                    y: WrapMode.Repeat
                    z: WrapMode.Repeat
                }
            }

        }

        components: [
            kmesh,
            kmaterial,
            klocalTransform
        ]
    }
}
