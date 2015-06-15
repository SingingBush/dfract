import gdk.Event, gdk.Color, gdk.FrameClock, gdk.Pixbuf, cairo.Context, cairo.ImageSurface;

import gtk.MainWindow;
import gtk.Box;
import gtk.DrawingArea;
import gtk.Image;
import gtk.Main;
import gtk.MenuBar;
import gtk.Widget;

import gui.FileMenu;
import gui.HelpMenu;

import std.stdio, std.conv, std.math;

import core.Fractal;

void main(string[] args)
{
	Main.init(args);

	new DfractWindow();

	Main.run();
}

struct Position { int x; int y; }

class DfractWindow : MainWindow {
	bool mouseClicked = false; // so we can click and drag

	Position mouseStart, mouseEnd;

	this() {
		super("Dfract GTK3 Fractal Program");

		setDefaultSize(600, 400);
		//setBorderWidth(10);

		auto menuBar = new MenuBar();
   
	    menuBar.append(new FileMenu());
	    menuBar.append(new HelpMenu());

		auto box = new Box(Orientation.VERTICAL, 20);

		box.packStart(menuBar, false, false, 0);

		auto fractal = new Mandelbrot(600, 400);
		
		//Image img = new Image(fractal.render());
		//box.add(img);
		
		auto pixBuffer = fractal.render();
		auto rowStride = pixBuffer.getRowstride();

		auto drawingArea = new DrawingArea(600, 400);

		ImageSurface surface = ImageSurface.createForData(cast(ubyte*)pixBuffer.getPixels(), CairoFormat.ARGB32, 600, 400, rowStride);

		drawingArea.addTickCallback(delegate(Widget widget, FrameClock clock) {
				if(this.mouseClicked) {
        			//writefln("draw %s", widget);
        			// todo: draw box here

        			auto drawable = widget.getWindow();
        			auto width = widget.getAllocatedWidth();
					auto height = widget.getAllocatedHeight();

        			//surface = ImageSurface.create(CairoFormat.ARGB32, width, height);
        			//surface = ImageSurface.createForData(imgData, CairoFormat.ARGB32, width, height, 8);					
					//surface = ImageSurface.createForData(cast(ubyte*)pixBuffer.getPixels(), CairoFormat.ARGB32, width, height, rowStride);
        			Context ctx = Context.create(surface);
        			
        			ctx.setSourceRgb(0.9, 0.6, 0.2); // RGB 0.0 to 1.0
        			ctx.setDash([4.0], 0);

        			//ctx.moveTo(mouseStart.x, mouseStart.y);
					//ctx.lineTo(mouseEnd.x, mouseEnd.y);

					int startX = mouseStart.x < mouseEnd.x ? mouseStart.x : mouseEnd.x;
					int startY = mouseStart.y < mouseEnd.y ? mouseStart.y : mouseEnd.y;

					int squareWidth = abs(mouseStart.x - mouseEnd.x);
					int squareHeight = abs(mouseStart.y - mouseEnd.y);

					ctx.rectangle(startX, startY, squareWidth, squareHeight); // start top-left
					ctx.stroke();

					widget.queueDraw(); // Redraw the Drawing Area Widget
        		}
        		return true;
			});

		drawingArea.addOnDraw(delegate(Scoped!Context ctx, Widget widget) {
				// can be used to handle resizing
				auto width = widget.getAllocatedWidth();
				auto height = widget.getAllocatedHeight();
				writefln("drawing area resized:  width %s, height %s", width, height);
				// todo: resize fractal

				//Fill the Widget with the surface we are drawing on.
				if(surface !is null) {
					ctx.setSourceSurface(surface, 0, 0);
					ctx.paint();
				}

				return true;
			});

		drawingArea.addOnButtonPress(delegate(GdkEventButton* event, widget) {
        		this.mouseClicked = true;
        		int x = to!int(event.x) +1;
        		int y = to!int(event.y) +1;

        		mouseStart.x = x;
        		mouseStart.y = y;

        		// initialise the mouse end coordinates to the same position
        		mouseEnd.x = x;
        		mouseEnd.y = y;

        		//writefln("button press %s %s", x, y);
        		return true;
        	});

        drawingArea.addOnButtonRelease(delegate(GdkEventButton* event, widget) {
        		this.mouseClicked = false;
        		mouseEnd.x = to!int(event.x) +1; // the button x and y are double
        		mouseEnd.y = to!int(event.y) +1;

        		//writefln("button release %s %s", x, y);
        		return true;
        	});
        
        drawingArea.addOnMotionNotify(delegate(GdkEventMotion* event, widget) {
        		if(this.mouseClicked) {
        			mouseEnd.x = to!int(event.x) +1;
        			mouseEnd.y = to!int(event.y) +1;
        			writefln("mouse moved:  x %s, y %s", to!int(event.x) +1, to!int(event.y) +1);
        		}
        		return true;
        	});

		drawingArea.addOnScroll(delegate(GdkEventScroll* event, widget) {
        		// todo: zoom in or out
        		writefln("scroll %s", event.direction); // UP or DOWN
        		return true;
        	});

		box.add(drawingArea);

		add(box);
		showAll();
	}

	
}