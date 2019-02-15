module core.fractal;

import gdk.Color, gdk.Pixbuf, gtk.Image;

import std.complex, std.range, std.algorithm;

import std.stdio;
import std.datetime : StopWatch; // for logging render time

import core.HSV;

abstract class Fractal {

	const int MAX_ITERATIONS = 256;

	int _width, _height;
	Complex!double min, max;
	double xZoom = 1.0;
	double yZoom = 1.0;
	bool useHsv = true;

	public
	abstract Pixbuf render();

	abstract void zoom(int amount);
}
