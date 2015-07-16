module core.HSV;

import gdk.Color;

/// The fractal works out a hue, then this class can convert the HSV color to an RGB color
// http://stackoverflow.com/questions/3018313/algorithm-to-convert-rgb-to-hsv-and-hsv-to-rgb-in-range-0-255-for-both
public class HSV {
	
	ubyte h;
    ubyte s;
    ubyte v;	
	
	this(ubyte hue, ubyte saturation = 255, ubyte value = 255) {
		this.h = hue;
	    this.s = saturation;
	    this.v = value;	
	}
	
	/// Converts the HSV color to an RGBA color object from the GTK-D library
	Color toRGBA() {
		Color rgb;

	    if (this.s == 0) {
	        //rgb.r = hsv.v;
	        //rgb.g = hsv.v;
	        //rgb.b = hsv.v;
	        //return rgb;
			return new Color(this.v, this.v, this.v);
	    }
	
	    int region = this.h / 43;
	    int remainder = (this.h - (region * 43)) * 6; 
	
	    ubyte p = cast(ubyte) (this.v * (255 - this.s)) >> 8;
	    ubyte q = cast(ubyte) (this.v * (255 - ((this.s * remainder) >> 8))) >> 8;
	    ubyte t = cast(ubyte) (this.v * (255 - ((this.s * (255 - remainder)) >> 8))) >> 8;
	
	    switch (region) {
	        case 0:
	            //rgb.r = hsv.v; rgb.g = t; rgb.b = p;
				rgb = new Color(this.v, t, p);
	            break;
	        case 1:
	            //rgb.r = q; rgb.g = hsv.v; rgb.b = p;
				rgb = new Color(q, this.v, p);
	            break;
	        case 2:
	            //rgb.r = p; rgb.g = hsv.v; rgb.b = t;
				rgb = new Color(p, this.v, t);
	            break;
	        case 3:
	            //rgb.r = p; rgb.g = q; rgb.b = hsv.v;
				rgb = new Color(p, q, this.v);
	            break;
	        case 4:
	            //rgb.r = t; rgb.g = p; rgb.b = hsv.v;
				rgb = new Color(t, p, this.v);
	            break;
	        default:
	            //rgb.r = hsv.v; rgb.g = p; rgb.b = q;
				rgb = new Color(this.v, p, q);
	            break;
	    }
	
	    return rgb;
	}
}

// todo: need some working tests here 
// unittest {
    // auto red = new HSV(0x00, 0xFF, 0xFF);
    // Color result = red.toRGBA();

    // assert(result == new Color(255, 0, 0));
// }