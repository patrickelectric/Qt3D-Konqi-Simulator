/* Atelier KDE Printer Host for 3D Printing
    Copyright (C) <2017-2018>
    Author: Patrick José Pereira - patrickjp@kde.org
            Kevin Ottens - ervin@kde.org

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

#pragma once

#include <QObject>
#include <QNode>
#include <QGeometryRenderer>
#include <QVector3D>

#include <Qt3DRender/QBuffer>
#include <Qt3DRender/QAttribute>

#define P_PROPERTY(TYPE, NAME) \
    Q_PROPERTY(TYPE NAME READ NAME WRITE NAME NOTIFY NAME##Changed) \
    public: \
    TYPE NAME() { return _##NAME; }; \
    void NAME(TYPE NAME) { if(NAME == _##NAME) return; _##NAME = NAME; emit NAME##Changed(); }; \
    Q_SIGNAL void NAME##Changed();\
private: \
    TYPE _##NAME;

class Line : public Qt3DRender::QGeometryRenderer
{
    Q_OBJECT
public:
    explicit Line(Qt3DCore::QNode* parent = nullptr);
    ~Line() = default;

    P_PROPERTY(QVector3D, startPoint)
    P_PROPERTY(QVector3D, endPoint)

    Qt3DRender::QGeometry* geometry;
    Qt3DRender::QBuffer* vertexBuffer;
    Qt3DRender::QAttribute* positionAttribute;
};
