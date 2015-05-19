import gtk.MainWindow;
import gtk.Box;
import gtk.Main;
import gtk.MenuBar;

import gui.FileMenu;
import gui.HelpMenu;

void main(string[] args)
{
	Main.init(args);

	new DfractWindow();

	Main.run();
}

class DfractWindow : MainWindow {
	this() {
		super("Dfract GTK3 Fractal Program");

		setDefaultSize(600, 400);
		//setBorderWidth(10);

		auto menuBar = new MenuBar();
   
	    menuBar.append(new FileMenu());
	    menuBar.append(new HelpMenu());

		auto box = new Box(Orientation.VERTICAL, 20);

		box.packStart(menuBar, false, false, 0);

		add(box);
		showAll();
	}
}