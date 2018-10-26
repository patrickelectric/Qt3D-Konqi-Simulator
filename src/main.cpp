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
#include <QtDebug>
#include <QtPlugin>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlExtensionPlugin>
#include <QQuickStyle>
#include <QSurfaceFormat>
#include <QWindow>

#include "lines.h"

Q_IMPORT_PLUGIN(BulletQMLPlugin)
Q_IMPORT_PLUGIN(BulletToolsQMLPlugin)
Q_IMPORT_PLUGIN(RenderQMLPlugin)

int main(int argc, char* argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("Material"));

    QSurfaceFormat format = QSurfaceFormat::defaultFormat();
    format.setVersion(4, 3);
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    format.setSamples(4);
    format.setSwapBehavior(QSurfaceFormat::DefaultSwapBehavior);
    format.setSwapInterval(1);
    format.setColorSpace(QSurfaceFormat::DefaultColorSpace);
    format.setProfile(QSurfaceFormat::CoreProfile);
    QSurfaceFormat::setDefaultFormat(format);

    QQmlApplicationEngine engine;

    Q_INIT_RESOURCE(BulletQMLPlugin);
    Q_INIT_RESOURCE(BulletToolsQMLPlugin);
    Q_INIT_RESOURCE(RenderQMLPlugin);
    qobject_cast<QQmlExtensionPlugin*>(qt_static_plugin_BulletQMLPlugin().instance())->registerTypes("QBullet");
    qobject_cast<QQmlExtensionPlugin*>(qt_static_plugin_BulletToolsQMLPlugin().instance())->registerTypes("QBullet.Tools");
    qobject_cast<QQmlExtensionPlugin*>(qt_static_plugin_RenderQMLPlugin().instance())->registerTypes("QRender");

    qmlRegisterType<Line>("Line", 1, 0, "Line");

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
