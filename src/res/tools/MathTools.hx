package res.tools;

class MathTools {
	public static inline function clampi(x:Int, low:Int, high:Int):Int {
		return x <= low ? low : x >= high ? high : x;
	}
}
