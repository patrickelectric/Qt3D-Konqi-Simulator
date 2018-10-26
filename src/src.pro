TARGET = konqi-simulator
TEMPLATE = app

QT += core qml quick quickcontrols2 gui

QT += \
    3dcore \
    3dextras \
    3dinput \
    3dlogic \
    3dquick \
    3dquickextras \
    3dquickinput \
    3dquickrender \
    3dquickscene2d \
    3drender

INCLUDEPATH += $$PWD

SOURCES = $$PWD/main.cpp

RESOURCES += $$PWD/../KonqiSimulator.qrc

include($$PWD/../lib/Lines/lines.pri)
include($$PWD/../lib/bullet-physics-qml-plugin/dependencies/bullet/bullet.pri)

#static link plugins
LIBS += \
    -L$$OUT_PWD/../lib/bullet-physics-qml-plugin/BulletQMLPlugin \
    -L$$OUT_PWD/../lib/bullet-physics-qml-plugin/BulletToolsQMLPlugin \
    -L$$OUT_PWD/../lib/bullet-physics-qml-plugin/RenderQMLPlugin \
    -lBulletQMLPlugin \
    -lRenderQMLPlugin \
    -lBulletToolsQMLPlugin \
