module gui.HelpMenu;

import gdk.Event;

import gtk.AboutDialog;
import gtk.Dialog;
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
        about.setLicense("License is LGPL");
        about.setWebsite("http://singingbush.com");
        about.setWebsiteLabel("singingbush.com");

        string[] names;
        names ~= "Samael Bate";
        about.setAuthors(names);
        about.setDocumenters(names);
        about.setArtists(names);

        about.addOnResponse((int response, Dialog dlg) => dlg.destroy());
        about.run();
        return true;
    }
}