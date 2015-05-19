import gdk.Event, gdk.Color, gdk.Pixbuf;

import gtk.MainWindow;
import gtk.Box;
import gtk.Image;
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

		auto fractal = drawMandlebrot(600, 400);// creates a Pixbuf, does drawing then returns as Image
		box.add(fractal);

		add(box);
		showAll();
	}


	Image drawMandlebrot(int width, int height) {
		auto pixBuffer = new Pixbuf(GdkColorspace.RGB, true, 8, width, height); // RGBA

		//putPixel(pixBuffer, 10 , 10, 0xFF, 0x00, 0x11);
		
		for (int i = 0; i < width; i++) {
			putPixel(pixBuffer, i, 0, 0x00, 0xFF, 0x00);
			
			putPixel(pixBuffer, i, 20, 0x00, 0xFF, 0xFF);
			
			putPixel(pixBuffer, i, 40, 0xFF, 0x00, 0xFF);
			
			putPixel(pixBuffer, i, 60, 0xFF, 0xFF, 0x00);
			
			putPixel(pixBuffer, i, 80, 0xFF, 0x00, 0x00);
		}

		for (int x = 0; x < width; x++) {
			for (int y = 0; y < height; y++) {

				// calculate the colour for the pixel, then set it on the Pixbuf
				const int MAX_ITERATIONS = 100;
				// calculate how many iterations
				//int iterations = 0;

				auto
					c_x = x * 1.0 / width - 0.5,
					c_y = y * 1.0 / height - 0.5,
					c = c_y * 2.0i + c_x * 3.0 - 1.0,
					z = 0.0i + 0.0,
					iterations = 0;
				for (; iterations < MAX_ITERATIONS; ++iterations) {
					z = z * z + c;
					if (lensqr(z) > 4) break;
				}

				//auto what = 0.complex.recurrence!((a, n) => a[n - 1] ^^ 2 + complex(x, y));

				// use resulting number of iterations to decide colour
				auto value = cast(ubyte) (iterations * 255.0 / MAX_ITERATIONS);
				//char redColor = iterations > MAX_ITERATIONS? 0x00 : 0xFF; // temp way to pick color - need better system

				putPixel(pixBuffer, x, y, value, 0x00, 0x00);
			}
		}
		
//		foreach (immutable y; iota(-1.2, 1.2, 0.05))
//			iota(-2.05, 0.55, 0.03)
//				.map!(x => 0.complex.recurrence!((a, n) => a[n - 1] ^^ 2 + complex(x, y)).drop(100).front.abs < 2 ? '#' : '.').writeln;

		return new Image(pixBuffer);
	}

	double lensqr(cdouble c) {
		return c.re * c.re + c.im * c.im;
	}

	// see: https://developer.gnome.org/gdk-pixbuf/unstable/gdk-pixbuf-The-GdkPixbuf-Structure.html
	void putPixel(Pixbuf buffer, int x, int y, char r, char g, char b) {
		char* pixels = buffer.getPixels();
		int pb_width = buffer.getWidth();
		int rowstride = buffer.getRowstride();
		int n_channels = buffer.getNChannels();
		
		char* p = pixels + y * rowstride + x * n_channels;

		p[0] = r;
		p[1] = g;
		p[2] = b;
		p[3] = 0xFF;
	}
}