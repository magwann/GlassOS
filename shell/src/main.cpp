// GlassOS shell — entry point.
// Theme and Apps are exposed as C++ context properties (not QML singletons):
// QML-module singletons are miscompiled nondeterministically by qmlcachegen on
// Qt 6.2, which made Theme.* resolve to `undefined` and rendered panels black.
// Context properties are deterministic and need no imports.

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QProcess>
#include <QQuickWindow>
#include <QTimer>
#include <QImage>
#include <QColor>
#include <QVariantList>
#include <QAbstractListModel>
#include <QHash>

// ---- design tokens ----
class Theme : public QObject {
    Q_OBJECT
    Q_PROPERTY(QColor aqua          MEMBER aqua          CONSTANT)
    Q_PROPERTY(QColor aquaDeep      MEMBER aquaDeep      CONSTANT)
    Q_PROPERTY(QColor teal          MEMBER teal          CONSTANT)
    Q_PROPERTY(QColor sky           MEMBER sky           CONSTANT)
    Q_PROPERTY(QColor leaf          MEMBER leaf          CONSTANT)
    Q_PROPERTY(QColor warm          MEMBER warm          CONSTANT)
    Q_PROPERTY(QColor violet        MEMBER violet        CONSTANT)
    Q_PROPERTY(QColor ink           MEMBER ink           CONSTANT)
    Q_PROPERTY(QColor inkInv        MEMBER inkInv        CONSTANT)
    Q_PROPERTY(QColor inkSoft       MEMBER inkSoft       CONSTANT)
    Q_PROPERTY(QColor glassTint     MEMBER glassTint     CONSTANT)
    Q_PROPERTY(QColor glassSoft     MEMBER glassSoft     CONSTANT)
    Q_PROPERTY(QColor glassDeep     MEMBER glassDeep     CONSTANT)
    Q_PROPERTY(QColor glassBorder   MEMBER glassBorder   CONSTANT)
    Q_PROPERTY(QColor glassBorderLo MEMBER glassBorderLo CONSTANT)
    Q_PROPERTY(QColor glossTop      MEMBER glossTop      CONSTANT)
    Q_PROPERTY(QColor glossMid      MEMBER glossMid      CONSTANT)
    Q_PROPERTY(int rSm MEMBER rSm CONSTANT)
    Q_PROPERTY(int rMd MEMBER rMd CONSTANT)
    Q_PROPERTY(int rLg MEMBER rLg CONSTANT)
    Q_PROPERTY(int rXl MEMBER rXl CONSTANT)
    Q_PROPERTY(QString fontFamily MEMBER fontFamily CONSTANT)
public:
    using QObject::QObject;
    QColor aqua{"#3fbdf6"}, aquaDeep{"#0a84c9"}, teal{"#35e0c4"}, sky{"#bfeafe"},
           leaf{"#7be495"}, warm{"#fff6d8"}, violet{"#b4a0ff"},
           ink{"#08324f"}, inkInv{"#f5ffff"};
    QColor inkSoft       = QColor::fromRgbF(0.035, 0.18, 0.28, 0.72);
    QColor glassTint     = QColor::fromRgbF(1, 1, 1, 0.14);
    QColor glassSoft     = QColor::fromRgbF(1, 1, 1, 0.08);
    QColor glassDeep     = QColor::fromRgbF(0.10, 0.28, 0.42, 0.30);
    QColor glassBorder   = QColor::fromRgbF(1, 1, 1, 0.55);
    QColor glassBorderLo = QColor::fromRgbF(1, 1, 1, 0.22);
    QColor glossTop      = QColor::fromRgbF(1, 1, 1, 0.62);
    QColor glossMid      = QColor::fromRgbF(1, 1, 1, 0.06);
    int rSm = 10, rMd = 16, rLg = 22, rXl = 30;
    QString fontFamily = "Inter";

    Q_INVOKABLE QVariantList tileGradient(const QString &name) const {
        auto pair = [](QColor a, QColor b) { QVariantList l; l.append(a); l.append(b); return l; };
        if (name == "teal")   return pair(QColor::fromRgbF(0.21,0.88,0.77,0.60), QColor::fromRgbF(0.04,0.59,0.59,0.55));
        if (name == "leaf")   return pair(QColor::fromRgbF(0.48,0.89,0.58,0.60), QColor::fromRgbF(0.16,0.67,0.43,0.55));
        if (name == "warm")   return pair(QColor::fromRgbF(1.0,0.96,0.85,0.65),  QColor::fromRgbF(1.0,0.75,0.47,0.55));
        if (name == "violet") return pair(QColor::fromRgbF(0.71,0.63,1.0,0.60),  QColor::fromRgbF(0.47,0.35,0.86,0.55));
        return pair(QColor::fromRgbF(0.25,0.74,0.96,0.60), QColor::fromRgbF(0.04,0.52,0.79,0.55));
    }
};

// ---- app registry ----
class AppsModel : public QAbstractListModel {
    Q_OBJECT
public:
    struct App { QString appId, name, glyph, tint, exec; };
    enum Roles { AppIdRole = Qt::UserRole + 1, NameRole, GlyphRole, TintRole, ExecRole };

    explicit AppsModel(QObject *p = nullptr) : QAbstractListModel(p) {
        m = {
            {"welcome",  "Welcome",    "welcome",  "aqua",   ""},
            {"files",    "Files",      "files",    "teal",   "nautilus --new-window"},
            {"browser",  "Aqua Web",   "browser",  "aqua",   "epiphany-browser"},
            {"terminal", "Terminal",   "terminal", "leaf",   "gnome-terminal"},
            {"settings", "Settings",   "settings", "violet", "gnome-control-center"},
            {"mail",     "Mail",       "mail",     "teal",   ""},
            {"music",    "Music",      "music",    "violet", ""},
            {"photos",   "Photos",     "photos",   "warm",   "eog"},
            {"calc",     "Calculator", "calc",     "aqua",   "gnome-calculator"},
        };
    }
    int rowCount(const QModelIndex & = QModelIndex()) const override { return int(m.size()); }
    QVariant data(const QModelIndex &i, int role) const override {
        if (!i.isValid() || i.row() >= m.size()) return {};
        const App &a = m[i.row()];
        switch (role) {
        case AppIdRole: return a.appId;
        case NameRole:  return a.name;
        case GlyphRole: return a.glyph;
        case TintRole:  return a.tint;
        case ExecRole:  return a.exec;
        }
        return {};
    }
    QHash<int, QByteArray> roleNames() const override {
        return {{AppIdRole,"appId"},{NameRole,"name"},{GlyphRole,"glyph"},{TintRole,"tint"},{ExecRole,"exec"}};
    }
private:
    QList<App> m;
};

class Launcher : public QObject {
    Q_OBJECT
public:
    using QObject::QObject;
    Q_INVOKABLE void launch(const QString &command) {
        if (command.trimmed().isEmpty()) return;
        QProcess::startDetached(QStringLiteral("/bin/sh"),
                                {QStringLiteral("-c"), command});
    }
    Q_INVOKABLE void logout()   { QProcess::startDetached("/bin/sh", {"-c", "pkill -u \"$USER\" sway"}); }
    Q_INVOKABLE void poweroff() { QProcess::startDetached("/bin/sh", {"-c", "systemctl poweroff || doas shutdown -p now || sudo shutdown -p now"}); }
    Q_INVOKABLE void reboot()   { QProcess::startDetached("/bin/sh", {"-c", "systemctl reboot || doas shutdown -r now || sudo shutdown -r now"}); }
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("GlassOS");
    app.setOrganizationName("GlassOS");

    QQmlApplicationEngine engine;
    Theme theme;
    AppsModel apps;
    Launcher launcher;
    engine.rootContext()->setContextProperty("Theme", &theme);
    engine.rootContext()->setContextProperty("Apps", &apps);
    engine.rootContext()->setContextProperty("Launcher", &launcher);

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
