module core.Fractal;

import gdk.Color, gdk.Pixbuf, gtk.Image;

import std.complex, std.range, std.algorithm;

import std.stdio;
import std.datetime : StopWatch; // for logging render time

import core.HSV;

abstract class Fractal {

	private
	int _width, _height;
	cdouble c;
	cdouble z;

	public
	abstract Pixbuf render();
	abstract void zoom(int amount);
}

class Mandelbrot : Fractal {

	const int MAX_ITERATIONS = 256;

	double minRe = -2.025; // real is for X
    double maxRe = 0.6;
    double minIm = -1.125; // im is for Y
    double maxIm = 1.125;

    double xZoom = 1.0;
    double yZoom = 1.0;

	this(int width, int height) {
		_width = width;
		_height = height;

        //maxIm = minIm + (maxRe-minRe) * _height / _width; // not sure about this, seems to get a better aspect ratio

		xZoom = (maxRe-minRe) / cast(double) _width;
		yZoom = (maxIm-minIm) / cast(double) _height;
	}

	override Pixbuf render() {
		return drawMandelbrot();
	}

	override void zoom(int amount) {
	    if(amount > 0) {
	    	minRe /= amount; // real is for X
	        maxRe /= amount;
	        minIm /= amount; // im is for Y
	        maxIm /= amount;
        } else if(amount < 0) {
        	int positiveAmount = ~ amount +1;
        	minRe *= positiveAmount; // real is for X
	        maxRe *= positiveAmount;
	        minIm *= positiveAmount; // im is for Y
	        maxIm *= positiveAmount;
        }

	    xZoom = (maxRe-minRe) / cast(double) _width;
	    yZoom = (maxIm-minIm) / cast(double) _height;
	}

	Pixbuf drawMandelbrot() {
		auto pixBuffer = new Pixbuf(GdkColorspace.RGB, true, 8, _width, _height); // RGBA

		StopWatch timer;
		timer.start();

		foreach (immutable x; 0.._width) {
			foreach (immutable y; 0.._height) {

				// calculate the colour for the pixel, then set it on the Pixbuf

				double cImaginary = minRe + (cast(double) x * xZoom);
				double cReal = minIm + (cast(double) y * yZoom);

				// calculate how many iterations
				Complex!double c = complex(cImaginary, cReal);
				int iterations = calculateIterations(c);

				// use resulting number of iterations to decide colour
				Color color = getColor(iterations);

				// ubyte hue = cast(ubyte) (iterations * 255.0 / MAX_ITERATIONS);
				// HSV hsv = new HSV(hue); // this is actually HSB color
				// Color color = iterations < MAX_ITERATIONS? hsv.toRGBA() : new Color(0x00, 0x00, 0x00);
				// Color color = iterations < MAX_ITERATIONS? new Color(hue, hue, hue) : new Color(0x00, 0x00, 0x00); // bypass the whole HSV color class and create gdk.Color
				
				putPixel(pixBuffer, x, y, color);
			}
		}

		timer.stop();
		writefln("Mandelbrot render time: %s ms", timer.peek().msecs);
		
//		foreach (immutable y; iota(-1.2, 1.2, 0.05)) // std.range.iota(begin, end, step)
//			iota(-2.05, 0.55, 0.03)
//				.map!(x => 0.complex.recurrence!((a, n) => a[n - 1] ^^ 2 + complex(x, y)).drop(100).front.abs < 2 ? '#' : '.').writeln;

		return pixBuffer;
	}

	// returns value between 0 and MAX_ITERATIONS
	int calculateIterations(Complex!double c) {
		Complex!double z = 0.complex; // shorthand for: complex(0.0, 0.0);
		
		int iterations = 0;
		
		//for (; iterations < MAX_ITERATIONS; ++iterations) {
		//	z = z ^^ 2 + c;
		//	if (sqAbs(z) > 4) break;
		//}

		// could also be:
		do {
            z = z ^^ 2 + c;
            iterations++;
        } while (iterations < MAX_ITERATIONS && sqAbs(z) < 4); // sqAbs is part of std.complex

		return iterations;
	}

	// see: https://developer.gnome.org/gdk-pixbuf/unstable/gdk-pixbuf-The-GdkPixbuf-Structure.html
	void putPixel(Pixbuf buffer, int x, int y, Color rgb) {
		char* pixels = buffer.getPixels();
		int pb_width = buffer.getWidth();
		int rowstride = buffer.getRowstride();
		int n_channels = buffer.getNChannels();
		
		char* p = pixels + y * rowstride + x * n_channels;

		p[0] = cast(char) rgb.red();
		p[1] = cast(char) rgb.green();
		p[2] = cast(char) rgb.blue();
		p[3] = cast(char) 0xFF; // rgb.alpha();
	}

	Color getColor(int iterations) {
	    if(iterations >= MAX_ITERATIONS) {
	        return new Color(0x00, 0x00, 0x00);
	    }
	    int range = (iterations * 6) / MAX_ITERATIONS;
	    int remain = (iterations * 6) % MAX_ITERATIONS;

        Color c;

	    switch(range) {
	        case 0:
	            c = new Color(cast(ubyte)remain, 0x00, 0x00);
	            break;
	        case 1:
	            c = new Color(0xFF, cast(ubyte)remain, 0x00);
	            break;
	        case 2:
	            c = new Color(0x00, 0xFF, cast(ubyte)remain);
	            break;
	        case 3:
	            c = new Color(0x00, 0x00, cast(ubyte)remain);
	            break;
            case 4:
                c = new Color(cast(ubyte)remain, 0x00, 0xFF);
            	break;
            case 5:
                c = new Color(0xFF, 0x00, cast(ubyte)remain);
            	break;
            case 6:
                c = new Color(0xFF, cast(ubyte)remain, 0xFF);
                break;
            default:
                c = new Color(0xFF, 0xFF, 0xFF);
                break;
	    }
	    return c;
	}
}


unittest {
	import dunit.toolkit;

	Fractal fractal = new Mandelbrot(300, 200);
	Pixbuf pb = fractal.render();

	pb.getWidth().assertEqual(300, "Width should be 300 px");
	pb.getHeight().assertEqual(200, "Hight should be 200 px");
}