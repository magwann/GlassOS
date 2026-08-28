// GlassOS shell — entry point.
// Hosts the QML scene and exposes a small Launcher to run real programs.
// Set GLASSOS_CAPTURE=/path.png (with QT_QPA_PLATFORM=offscreen) to render one
// frame to a PNG and exit — used for headless visual verification.

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QProcess>
#include <QQuickWindow>
#include <QTimer>
#include <QImage>

class Launcher : public QObject {
    Q_OBJECT
public:
    using QObject::QObject;
    Q_INVOKABLE void launch(const QString &command) {
        if (command.trimmed().isEmpty()) return;
        QProcess::startDetached(QStringLiteral("/bin/sh"),
                                {QStringLiteral("-c"), command});
    }
    Q_INVOKABLE void logout()   { QProcess::startDetached("/bin/sh", {"-c", "pkill -u \"$USER\" labwc"}); }
    Q_INVOKABLE void poweroff() { QProcess::startDetached("/bin/sh", {"-c", "doas shutdown -p now || sudo shutdown -p now"}); }
    Q_INVOKABLE void reboot()   { QProcess::startDetached("/bin/sh", {"-c", "doas shutdown -r now || sudo shutdown -r now"}); }
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("GlassOS");
    app.setOrganizationName("GlassOS");

    QQmlApplicationEngine engine;
    Launcher launcher;
    engine.rootContext()->setContextProperty("Launcher", &launcher);
    // Qt 6.2-compatible load (loadFromModule is 6.5+).
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/GlassOS/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) return -1;

    // Headless capture mode: render one frame to PNG and exit.
    const QByteArray cap = qgetenv("GLASSOS_CAPTURE");
    if (!cap.isEmpty()) {
        auto *win = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
        if (win) {
            win->setVisibility(QWindow::Windowed);
            int w = qEnvironmentVariableIntValue("GLASSOS_W"); if (!w) w = 1360;
            int h = qEnvironmentVariableIntValue("GLASSOS_H"); if (!h) h = 768;
            win->resize(w, h);
            QTimer::singleShot(1500, [win, cap]() {
                QImage img = win->grabWindow();
                img.save(QString::fromLocal8Bit(cap));
                QCoreApplication::quit();
            });
        }
    }
    return app.exec();
}

#include "main.moc"
