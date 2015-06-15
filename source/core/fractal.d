module core.Fractal;

import gdk.Color, gdk.Pixbuf, gtk.Image;

import std.complex, std.range, std.algorithm;

import std.stdio;

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

	this(int width, int height) {
		_width = width;
		_height = height;
		// auto c = complex(1.0, 2.0)
	}

	override Pixbuf render() {
		return drawMandlebrot(_width, _height);
	}

	Pixbuf drawMandlebrot(int width, int height) {
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

				// new Color(cast(ubyte)90, cast(ubyte)70, cast(ubyte)122) // todo: use gdk.Color object or gdk.RGBA
				// new Color(255, 255, 255);
				
				//writefln("hue color:  ubyte %s, double %s", value, hue);
				HSV hsv = new HSV(value, 0xDE, 0xCC);
				Color col = hsv.toRGBA();
				
				putPixel(pixBuffer, x, y, col);
				//putPixel(pixBuffer, x, y, value, 0x90, 0xFC);
			}
		}
		
//		foreach (immutable y; iota(-1.2, 1.2, 0.05))
//			iota(-2.05, 0.55, 0.03)
//				.map!(x => 0.complex.recurrence!((a, n) => a[n - 1] ^^ 2 + complex(x, y)).drop(100).front.abs < 2 ? '#' : '.').writeln;

		return pixBuffer;
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