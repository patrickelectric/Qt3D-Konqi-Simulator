/* Based on Atelier KDE Printer Host for 3D Printing
    Copyright (C) <2017-2018>
    Author: Patrick José Pereira - patrickjp@kde.org

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 3 of
    the License or any later version accepted by the membership of
    KDE e.V. (or its successor approved by the membership of KDE
    e.V.), which shall act as a proxy defined in Section 14 of
    version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <QGeometryRenderer>
#include <QSize>

#include "lines.h"

Line::Line(Qt3DCore::QNode *parent) : Qt3DRender::QGeometryRenderer(parent)
{
    setInstanceCount(1);
    setIndexOffset(0);
    setFirstInstance(0);
    setPrimitiveType(Qt3DRender::QGeometryRenderer::Lines);

    geometry = new Qt3DRender::QGeometry(this);
    vertexBuffer = new Qt3DRender::QBuffer(Qt3DRender::QBuffer::VertexBuffer, this);
    positionAttribute = new Qt3DRender::QAttribute(this);

    positionAttribute->setAttributeType(Qt3DRender::QAttribute::VertexAttribute);
    positionAttribute->setDataType(Qt3DRender::QAttribute::Float);
    positionAttribute->setName(Qt3DRender::QAttribute::defaultPositionAttributeName());
    positionAttribute->setDataSize(3);

    auto updateLine = [&]{
        if (_startPoint == _endPoint) {
            return;
        }

        QVector<QVector3D> vertices{_startPoint, _endPoint};

        QByteArray vertexBufferData;
        vertexBufferData.resize(vertices.size() * static_cast<int>(sizeof(QVector3D)));
        memcpy(vertexBufferData.data(), vertices.constData(), static_cast<size_t>(vertexBufferData.size()));
        vertexBuffer->setData(vertexBufferData);

        positionAttribute->setBuffer(vertexBuffer);
        geometry->addAttribute(positionAttribute);
        setVertexCount(vertexBuffer->data().size() / static_cast<int>(sizeof(QVector3D)));
        setGeometry(geometry);
    };

    connect(this, &Line::startPointChanged, this, updateLine);
    connect(this, &Line::endPointChanged, this, updateLine);
}
