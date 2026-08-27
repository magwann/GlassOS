// GlassOS shell — entry point.
// Hosts the QML scene and exposes a small Launcher to run real programs.

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QProcess>
#include <QIcon>

class Launcher : public QObject {
    Q_OBJECT
public:
    using QObject::QObject;

    // Launch a program detached so the shell keeps running.
    Q_INVOKABLE void launch(const QString &command) {
        if (command.trimmed().isEmpty())
            return;
        QProcess::startDetached(QStringLiteral("/bin/sh"),
                                {QStringLiteral("-c"), command});
    }

    // Session actions (wired to real commands later).
    Q_INVOKABLE void logout()   { QProcess::startDetached("/bin/sh", {"-c", "loginctl terminate-session self || pkill -u \"$USER\" labwc"}); }
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

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("GlassOS", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}

#include "main.moc"
