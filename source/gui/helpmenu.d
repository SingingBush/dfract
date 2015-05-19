module gui.HelpMenu;

import gdk.Event;

import gtk.AboutDialog;
import gtk.Menu;
import gtk.MenuItem;
import gtk.Widget;


class HelpMenu : MenuItem {
    this() {
        super("Help");

        auto menu = new Menu();
        auto aboutOption = new MenuItem("About");
        aboutOption.addOnButtonRelease(&showAbout);

        menu.append(aboutOption);

        setSubmenu(menu);
    }

    bool showAbout(Event event, Widget widget) {
        auto about = new AboutDialog();
        about.setProgramName("Dfract");
        about.setVersion("v1");
        about.setWebsite("http://singingbush.com");
        about.setWebsiteLabel("singingbush.com");
        about.run();
        return true;
    }
}