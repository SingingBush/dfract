
import std.complex, std.range, std.algorithm;

abstract class Fractal {

	cdouble c;
	cdouble z;

	abstract void render();
}

class Mandelbrot : Fractal {

	this(int width, int height) {
		// auto c = complex(1.0, 2.0)
	}
}