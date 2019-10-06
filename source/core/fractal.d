module core.fractal;

public import gdk.Pixbuf;
public import std.complex;

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
