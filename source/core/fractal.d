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
}

class Mandelbrot : Fractal {

	const int MAX_ITERATIONS = 100;

	this(int width, int height) {
		_width = width;
		_height = height;
		// auto c = complex(1.0, 2.0)
	}

	override Pixbuf render() {
		return drawMandlebrot();
	}

	Pixbuf drawMandlebrot() {
		auto pixBuffer = new Pixbuf(GdkColorspace.RGB, true, 8, _width, _height); // RGBA

		StopWatch timer;
		timer.start();

		foreach (immutable x; 0.._width) {
			foreach (immutable y; 0.._height) {

				// calculate the colour for the pixel, then set it on the Pixbuf
				
				// calculate how many iterations
				int iterations = calculateIterations(x, y);

				//auto what = 0.complex.recurrence!((a, n) => a[n - 1] ^^ 2 + complex(x, y));

				// use resulting number of iterations to decide colour
				auto value = cast(ubyte) (iterations * 255.0 / MAX_ITERATIONS);
				//char redColor = iterations > MAX_ITERATIONS? 0x00 : 0xFF; // temp way to pick color - need better system

				// new Color(cast(ubyte)90, cast(ubyte)70, cast(ubyte)122) // todo: use gdk.Color object or gdk.RGBA
				// new Color(255, 255, 255);
				
				//writefln("hue color:  ubyte %s, double %s", value, hue);
				HSV hsv = new HSV(value, 0xDE, 0xCC);
				Color col = hsv.toRGBA();
				
				putPixel(pixBuffer, x, y, col);
				//putPixel(pixBuffer, x, y, value, 0x90, 0xFC);
			}
		}

		timer.stop();
		writefln("took %s ms", timer.peek().msecs);
		
//		foreach (immutable y; iota(-1.2, 1.2, 0.05)) // std.range.iota(begin, end, step)
//			iota(-2.05, 0.55, 0.03)
//				.map!(x => 0.complex.recurrence!((a, n) => a[n - 1] ^^ 2 + complex(x, y)).drop(100).front.abs < 2 ? '#' : '.').writeln;

		return pixBuffer;
	}

	int calculateIterations(int x, int y) {
		auto
			c_x = x * 1.0 / _width - 0.5,
			c_y = y * 1.0 / _height - 0.5,
			c = c_y * 2.0i + c_x * 3.0 - 1.0,
			z = 0.0i + 0.0,
			iterations = 0;
		for (; iterations < MAX_ITERATIONS; ++iterations) {
			z = z * z + c;
			if (lensqr(z) > 4) break;
		}
		return iterations;
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
	
	void putPixel(Pixbuf buffer, int x, int y, Color rgb) {
		char* pixels = buffer.getPixels();
		int pb_width = buffer.getWidth();
		int rowstride = buffer.getRowstride();
		int n_channels = buffer.getNChannels();
		
		char* p = pixels + y * rowstride + x * n_channels;

		p[0] = cast(char) rgb.red();
		p[1] = cast(char) rgb.green();
		p[2] = cast(char) rgb.blue();
		p[3] = cast(char) 0xFF;
	}
}


unittest {
	import dunit.toolkit;

	Fractal fractal = new Mandelbrot(300, 200);
	Pixbuf pb = fractal.render();

	pb.getWidth().assertEqual(300, "Width should be 300 px");
	pb.getHeight().assertEqual(200, "Hight should be 200 px");
}