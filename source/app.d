import gdk.Event, gdk.Keysyms, gdk.Color, gdk.FrameClock, gdk.Pixbuf, cairo.Context, cairo.ImageSurface;

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

import core.fractal, core.mandelbrot;

void main(string[] args) {
	Main.init(args);

	new DfractWindow();

	Main.run();
}

struct Position { int x; int y; }

class DfractWindow : MainWindow {
	private bool mouseClicked = false; // so we can click and drag

	private Position mouseStart, mouseEnd;

	this() {
		super("Dfract GTK3 Fractal Program");

		setDefaultSize(800, 480);
		//setResizable(true);
		//setHasResizeGrip(true);
		//setBorderWidth(10);

		auto menuBar = new MenuBar();
   
	    menuBar.append(new FileMenu());
	    menuBar.append(new HelpMenu());

		auto box = new Box(Orientation.VERTICAL, 0);

		box.packStart(menuBar, false, false, 0);

		// add status bar at the bottom should be done with:
		// box.packEnd(Widget child, bool expand, bool fill, uint padding)

		auto fractal = new Mandelbrot(800, 480);
		
		//Image img = new Image(fractal.render());
		//box.add(img);
		
		auto pixBuffer = fractal.render();

		auto drawingArea = new DrawingArea(800, 480);


		drawingArea.addTickCallback(delegate(Widget widget, FrameClock clock) {
				if(this.mouseClicked) {
					widget.queueDraw(); // Redraw the Drawing Area Widget
        		}
        		return true;
			});

		drawingArea.addOnDraw(delegate(Scoped!Context ctx, Widget widget) {
				// can be used to handle resizing
				auto width = widget.getAllocatedWidth();
				auto height = widget.getAllocatedHeight();
				writefln("drawing area onDraw:  width %s, height %s", width, height);
				// todo: resize fractal

				auto rowStride = pixBuffer.getRowstride();
				auto bufferWidth = pixBuffer.getWidth();
				auto bufferHeight = pixBuffer.getHeight();

				ImageSurface surface = ImageSurface.createForData(
					cast(ubyte*)pixBuffer.getPixels(), 
					CairoFormat.ARGB32, bufferWidth, bufferHeight, rowStride);

				// Fill the Widget with the surface we are drawing on.
				if(surface !is null) {
					ctx.setSourceSurface(surface, 0, 0);
					ctx.paint();

					if(this.mouseClicked) {
						drawRectangle(ctx);
					}

					surface.finish();
					surface.destroy(); // or maybe flush() finish() destroy() 
				}

				return true;
			});

		drawingArea.setCanFocus(true); // needed for onKeyPress to work

		drawingArea.addOnKeyPress(delegate(GdkEventKey* event, widget) {
				switch(event.keyval) {
					case GdkKeysyms.GDK_p:
						writefln("change pallete");
						fractal.useHsv = !fractal.useHsv;
						pixBuffer = fractal.render();
						widget.queueDraw();
						break;

					//case GdkKeysyms.GDK_minus:
					case GdkKeysyms.GDK_KP_Subtract:
						writefln("zoom out");
						fractal.zoom(-2);
						pixBuffer = fractal.render();
						widget.queueDraw();
						break;

					//case GdkKeysyms.GDK_plus:
					case GdkKeysyms.GDK_KP_Add:
						writefln("zoom in");
						fractal.zoom(2);
						pixBuffer = fractal.render();
						widget.queueDraw();
						break;

					case GdkKeysyms.GDK_Left:
					    writefln("move left");
					    fractal.move(-0.3, 0);
                        pixBuffer = fractal.render();
                        widget.queueDraw();
					    break;

					case GdkKeysyms.GDK_Right:
					    writefln("move right");
					    fractal.move(0.3, 0);
					    pixBuffer = fractal.render();
					    widget.queueDraw();
                    	break;

                    case GdkKeysyms.GDK_Up:
                        writefln("move up");
                        fractal.move(0, -0.3);
                        pixBuffer = fractal.render();
                        widget.queueDraw();
                        break;

                    case GdkKeysyms.GDK_Down:
                        writefln("move down");
                        fractal.move(0, 0.3);
                        pixBuffer = fractal.render();
                        widget.queueDraw();
                        break;

					default:
						break;
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
        		fractal.zoom(2); // todo: create a new method on Fractal to select a region to zoom in on.
                pixBuffer = fractal.render();
                widget.queueDraw(); // Redraw the Drawing Area Widget

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

        		switch(event.direction) {
        			case GdkScrollDirection.UP:
        				writefln("zoom in");
						fractal.zoom(2);
						pixBuffer = fractal.render();
						widget.queueDraw();
        				break;
        			case GdkScrollDirection.DOWN:
        				writefln("zoom out");
						fractal.zoom(-2);
						pixBuffer = fractal.render();
						widget.queueDraw();
        				break;
        			default:
        				break; // default block is just to avoid compiler warning
        		}
        		return true;
        	});

		box.add(drawingArea);

		add(box);
		showAll();
	}

	private void drawRectangle(Context ctx) {
		ctx.setSourceRgb(0.9, 0.6, 0.2); // RGB 0.0 to 1.0
		ctx.setDash([4.0], 0);

		int startX = mouseStart.x < mouseEnd.x ? mouseStart.x : mouseEnd.x;
		int startY = mouseStart.y < mouseEnd.y ? mouseStart.y : mouseEnd.y;

		int squareWidth = abs(mouseStart.x - mouseEnd.x);
		int squareHeight = abs(mouseStart.y - mouseEnd.y);

		ctx.rectangle(startX, startY, squareWidth, squareHeight); // start top-left
		ctx.stroke();
	}

	
}