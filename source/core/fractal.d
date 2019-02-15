module core.fractal;

import gdk.Color, gdk.Pixbuf, gtk.Image;

import std.complex, std.range, std.algorithm;

import std.stdio;
import std.datetime : StopWatch; // for logging render time

import core.HSV;

abstract class Fractal {

	protected const int MAX_ITERATIONS = 256;

	protected int _width, _height;
	protected Complex!double min, max;
	protected double xZoom = 1.0;
	protected double yZoom = 1.0;

	public bool useHsv = true;

	public abstract Pixbuf render();
	public abstract void zoom(int amount);
}
