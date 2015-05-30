import gdk.Event, gdk.Color, gdk.Pixbuf;

import gtk.MainWindow;
import gtk.Box;
import gtk.Image;
import gtk.Main;
import gtk.MenuBar;

import gui.FileMenu;
import gui.HelpMenu;

import core.Fractal;

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

		auto fractal = new Mandelbrot(600, 400); // drawMandlebrot(600, 400);// creates a Pixbuf, does drawing then returns as Image
		
		Image img = fractal.render();

		box.add(img);

		add(box);
		showAll();
	}

	
}