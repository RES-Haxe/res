package res.helpers;

class Funcs {
	public static inline function wrapi(x:Int, w:Int):Int {
		if (x < 0)
			x = w + (x % w);

		if (x >= w)
			x = x % w;

		return x;
	}
}
