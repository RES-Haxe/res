package res;

import haxe.io.Bytes;
import res.types.ColorComponent;

/**
	32 bit Color
 */
class Color32 {
	var bytes:Bytes;

	public final inFormat:Array<ColorComponent>;

	public final input:Int;

	var _output:Int;

	public var output(get, never):Int;

	function get_output()
		return _output;

	public final r:Int;
	public final rf:Float;

	public final g:Int;
	public final gf:Float;

	public final b:Int;
	public final bf:Float;

	public final a:Int;
	public final af:Float;

	public final luminance:Float;

	public static function ofRGB8(rgb24:Int, ?outFormat:Array<ColorComponent>):Color32 {
		return new Color32(rgb24, [A, R, G, B], outFormat);
	}

	public function component(cmp:ColorComponent) {
		switch (cmp) {
			case R:
				return r;
			case G:
				return g;
			case B:
				return b;
			case A:
				return a;
		}
	}

	/**
		Calculate distance to the given color

		@param otherColor Color to compare to
	 */
	public function distance(otherColor:Color32):Float {
		return Math.pow(r - otherColor.r, 2) + Math.pow(g - otherColor.g, 2) + Math.pow(b - otherColor.b, 2);
	}

	public function setOutFormat(outFormat:Array<ColorComponent>) {
		if (outFormat.length != 4)
			throw 'Format must consist of exactly 4 components';

		for (n in 0...4)
			bytes.set(3 - n, component(outFormat[n]));

		_output = bytes.getInt32(0);
	}

	public function new(i:Int, ?inFormat:Array<ColorComponent>, ?outFormat:Array<ColorComponent>) {
		if (inFormat == null)
			inFormat = [R, G, B, A];

		if (outFormat == null)
			outFormat = inFormat;

		if (inFormat.length != 4 || outFormat.length != 4)
			throw 'Input and output formats must containt exactly 4 components';

		this.inFormat = inFormat;

		input = i;

		bytes = Bytes.alloc(4);
		bytes.setInt32(0, input);

		r = bytes.get(3 - inFormat.indexOf(R));
		rf = r / 255;

		g = bytes.get(3 - inFormat.indexOf(G));
		gf = g / 255;

		b = bytes.get(3 - inFormat.indexOf(B));
		bf = b / 255;

		a = bytes.get(3 - inFormat.indexOf(A));
		af = a / 255;

		/**
			Calculating Luminance:

			`L = 0.2126 * R + 0.7152 * G + 0.0722 * B` where R, G and B are defined as:

			```
			if RsRGB <= 0.03928 then R = RsRGB/12.92 else R = ((RsRGB+0.055)/1.055) ^ 2.4
			if GsRGB <= 0.03928 then G = GsRGB/12.92 else G = ((GsRGB+0.055)/1.055) ^ 2.4
			if BsRGB <= 0.03928 then B = BsRGB/12.92 else B = ((BsRGB+0.055)/1.055) ^ 2.4
			```

			and RsRGB, GsRGB, and BsRGB are defined as:

			```
			RsRGB = R8bit/255
			GsRGB = G8bit/255
			BsRGB = B8bit/255
			```

			@see https://www.w3.org/WAI/GL/wiki/Relative_luminance
		 */

		final lr:Float = rf <= 0.3928 ? rf / 12.92 : Math.pow((rf + 0.055) / 1.055, 2.4);

		final lg:Float = gf <= 0.3928 ? gf / 12.92 : Math.pow((gf + 0.055) / 1.055, 2.4);
		final lb:Float = bf <= 0.3928 ? bf / 12.92 : Math.pow((bf + 0.055) / 1.055, 2.4);

		luminance = 0.2126 * lr + 0.7152 * lg + 0.0722 * lb;

		setOutFormat(outFormat);
	}
}
