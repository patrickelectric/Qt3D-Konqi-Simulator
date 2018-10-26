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
import QBullet 1.0 as QB
import QRender 1.0 as QRender


Entity {
    id: root

    property alias matrix: transform.matrix
    property alias origin: wheelBody.origin
    property alias rotation: wheelBody.rotation
    property alias body: wheelBody
    property alias pitch: wheelBody.pitch
    property alias yaw: wheelBody.yaw
    property alias roll: wheelBody.roll
    property alias mass: wheelBody.mass
    property alias rollingFriction: wheelBody.rollingFriction
    property alias friction: wheelBody.friction
    property alias linearDamping: wheelBody.linearDamping
    property alias angularDamping: wheelBody.angularDamping
    property alias restitution: wheelBody.restitution

    property alias radius: shape.radius
    property alias length: shape.length

    property QB.DiscreteDynamicsWorld world: null
    property bool showDebug: true

    QB.CylinderShape {
        id: shape
        radius: 0.5
        length: 0.4
    }

    QB.RigidBody {
        id: wheelBody
        collisionShape: shape
        world: root.world
    }

    Transform {
        id: transform
        matrix: wheelBody.matrix
    }

    components: [transform]

    Entity {
        Mesh {
            id: mesh
            source: "qrc:/resources/wheel.obj"
        }
        QRender.DiffusemapMaterial {
            id: wheelMaterial
            ambient: "#808080"
            shininess: 0
            alpha: 1
            textureScale: 1
            diffuse: "white"

            diffuseTexture: TextureLoader {
                source: "qrc:/resources/wheel.png"
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

        Transform {
            id: localTransform
            rotationZ: 90
            translation: Qt.vector3d(0, root.length/2, 0)
            scale3D: Qt.vector3d(root.length*2, root.radius*2, root.radius*2)
        }

        components: [
            mesh,
            wheelMaterial,
            localTransform
        ]
    }

    //Debug render
    QRender.Cylinder {
        enabled: root.showDebug
        length: shape.length
        radius: shape.radius
        slices: 32
        material: QRender.DiffusemapMaterial {
            ambient: "#808080"
            alpha: 0.5
            diffuse: "blue"
        }
    }

}
