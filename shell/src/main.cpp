// GlassOS shell — entry point.
// Theme and Apps are C++ context properties (QML-module singletons miscompile on
// Qt 6.2's qmlcachegen). Theme supports a dark ("night glass") mode.

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

class Theme : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool dark READ dark WRITE setDark NOTIFY changed)
    // constant tokens
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
    Q_PROPERTY(QColor glassBorder   MEMBER glassBorder   CONSTANT)
    Q_PROPERTY(QColor glassBorderLo MEMBER glassBorderLo CONSTANT)
    Q_PROPERTY(QColor glossTop      MEMBER glossTop      CONSTANT)
    Q_PROPERTY(QColor glossMid      MEMBER glossMid      CONSTANT)
    Q_PROPERTY(int rSm MEMBER rSm CONSTANT)
    Q_PROPERTY(int rMd MEMBER rMd CONSTANT)
    Q_PROPERTY(int rLg MEMBER rLg CONSTANT)
    Q_PROPERTY(int rXl MEMBER rXl CONSTANT)
    Q_PROPERTY(QString fontFamily MEMBER fontFamily CONSTANT)
    // dark-aware tokens
    Q_PROPERTY(QColor glassDeep  READ glassDeep  NOTIFY changed)
    Q_PROPERTY(QColor wallTop    READ wallTop    NOTIFY changed)
    Q_PROPERTY(QColor wallMid1   READ wallMid1   NOTIFY changed)
    Q_PROPERTY(QColor wallMid2   READ wallMid2   NOTIFY changed)
    Q_PROPERTY(QColor wallBottom READ wallBottom NOTIFY changed)
    Q_PROPERTY(qreal  blobOpacity READ blobOpacity NOTIFY changed)
public:
    using QObject::QObject;
    QColor aqua{"#3fbdf6"}, aquaDeep{"#0a84c9"}, teal{"#35e0c4"}, sky{"#bfeafe"},
           leaf{"#7be495"}, warm{"#fff6d8"}, violet{"#b4a0ff"},
           ink{"#08324f"}, inkInv{"#f5ffff"};
    QColor inkSoft       = QColor::fromRgbF(0.035, 0.18, 0.28, 0.72);
    QColor glassTint     = QColor::fromRgbF(1, 1, 1, 0.14);
    QColor glassSoft     = QColor::fromRgbF(1, 1, 1, 0.08);
    QColor glassBorder   = QColor::fromRgbF(1, 1, 1, 0.55);
    QColor glassBorderLo = QColor::fromRgbF(1, 1, 1, 0.22);
    QColor glossTop      = QColor::fromRgbF(1, 1, 1, 0.62);
    QColor glossMid      = QColor::fromRgbF(1, 1, 1, 0.06);
    int rSm = 10, rMd = 16, rLg = 22, rXl = 30;
    QString fontFamily = "Inter";

    bool m_dark = false;
    bool dark() const { return m_dark; }
    void setDark(bool d) { if (m_dark != d) { m_dark = d; emit changed(); } }

    QColor glassDeep()  const { return m_dark ? QColor::fromRgbF(0.03,0.09,0.15,0.48) : QColor::fromRgbF(0.10,0.28,0.42,0.30); }
    QColor wallTop()    const { return m_dark ? QColor("#123f57") : QColor("#a6ecff"); }
    QColor wallMid1()   const { return m_dark ? QColor("#0d3850") : QColor("#4fb8f0"); }
    QColor wallMid2()   const { return m_dark ? QColor("#07273a") : QColor("#1f7fc9"); }
    QColor wallBottom() const { return m_dark ? QColor("#03121d") : QColor("#0a4f8f"); }
    qreal  blobOpacity() const { return m_dark ? 0.42 : 0.85; }

    Q_INVOKABLE QVariantList tileGradient(const QString &name) const {
        auto pair = [](QColor a, QColor b) { QVariantList l; l.append(a); l.append(b); return l; };
        if (name == "teal")   return pair(QColor::fromRgbF(0.21,0.88,0.77,0.60), QColor::fromRgbF(0.04,0.59,0.59,0.55));
        if (name == "leaf")   return pair(QColor::fromRgbF(0.48,0.89,0.58,0.60), QColor::fromRgbF(0.16,0.67,0.43,0.55));
        if (name == "warm")   return pair(QColor::fromRgbF(1.0,0.96,0.85,0.65),  QColor::fromRgbF(1.0,0.75,0.47,0.55));
        if (name == "violet") return pair(QColor::fromRgbF(0.71,0.63,1.0,0.60),  QColor::fromRgbF(0.47,0.35,0.86,0.55));
        return pair(QColor::fromRgbF(0.25,0.74,0.96,0.60), QColor::fromRgbF(0.04,0.52,0.79,0.55));
    }
signals:
    void changed();
};

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
        case AppIdRole: return a.appId; case NameRole: return a.name;
        case GlyphRole: return a.glyph; case TintRole: return a.tint; case ExecRole: return a.exec;
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
        QProcess::startDetached(QStringLiteral("/bin/sh"), {QStringLiteral("-c"), command});
    }
    // Swap the GTK theme + libadwaita color-scheme for launched apps.
    Q_INVOKABLE void setGtkDark(bool d) {
        const QString v = d ? "dark" : "light";
        const QString scheme = d ? "prefer-dark" : "default";
        const QString cmd =
            "cp ~/.config/glassos/gtk-" + v + ".css ~/.config/gtk-3.0/gtk.css 2>/dev/null; "
            "cp ~/.config/glassos/gtk-" + v + ".css ~/.config/gtk-4.0/gtk.css 2>/dev/null; "
            "gsettings set org.gnome.desktop.interface color-scheme " + scheme + " 2>/dev/null";
        QProcess::startDetached("/bin/sh", {"-c", cmd});
    }
    Q_INVOKABLE void poweroff() { QProcess::startDetached("/bin/sh", {"-c", "systemctl poweroff"}); }
    Q_INVOKABLE void reboot()   { QProcess::startDetached("/bin/sh", {"-c", "systemctl reboot"}); }
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("GlassOS");
    app.setOrganizationName("GlassOS");

    QQmlApplicationEngine engine;
    Theme theme;
    AppsModel apps;
    Launcher launcher;
    theme.setDark(qEnvironmentVariableIntValue("GLASSOS_DARK") != 0);  // for headless testing
    engine.rootContext()->setContextProperty("Theme", &theme);
    engine.rootContext()->setContextProperty("Apps", &apps);
    engine.rootContext()->setContextProperty("Launcher", &launcher);

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/GlassOS/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) return -1;

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
