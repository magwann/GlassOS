cmake_minimum_required(VERSION 3.21)
project(glassos-shell VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Quick Qml Gui)

qt_add_executable(glassos-shell
    src/main.cpp
)

qt_add_qml_module(glassos-shell
    URI GlassOS
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"    # same path on Qt 6.2 (Ubuntu) and 6.5+ (FreeBSD)
    QML_FILES
        qml/Main.qml
        qml/Wallpaper.qml
        qml/GlassPanel.qml
        qml/AppTile.qml
        qml/Taskbar.qml
        qml/StartMenu.qml
    RESOURCES
        qml/glyphs/files.svg
        qml/glyphs/welcome.svg
        qml/glyphs/settings.svg
        qml/glyphs/browser.svg
        qml/glyphs/mail.svg
        qml/glyphs/music.svg
        qml/glyphs/photos.svg
        qml/glyphs/terminal.svg
        qml/glyphs/calc.svg
        qml/glyphs/wifi.svg
        qml/glyphs/volume.svg
        qml/glyphs/battery.svg
        qml/glyphs/power.svg
        qml/glyphs/search.svg
        qml/glyphs/grid.svg
        qml/glyphs/sprout.svg
        qml/glyphs/moon.svg
        qml/glyphs/sun.svg
)

target_link_libraries(glassos-shell PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
)

install(TARGETS glassos-shell RUNTIME DESTINATION bin)
