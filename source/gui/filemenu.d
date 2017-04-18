module gui.FileMenu;

import gdk.Event;

import gtk.Main;
import gtk.Menu;
import gtk.MenuBar;
import gtk.MenuItem;
import gtk.Widget;


class FileMenu : MenuItem {
    
    this() {
        super("File");
        
        auto menu = new Menu();
        
        auto exitMenuItem = new MenuItem("Exit");
        exitMenuItem.addOnButtonRelease(delegate(Event event, Widget widget) {
		        Main.quit();
		        return true;
		    });
        
        menu.append(new MenuItem("New"));
        menu.append(new MenuItem("Open"));
        menu.append(new MenuItem("Save"));

        menu.append(exitMenuItem);
        
        setSubmenu(menu);
    }
}