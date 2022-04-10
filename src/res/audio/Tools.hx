package res.audio;

class Tools {
	public static function quantize(amp:Float, bps:Int):Int {
		switch (bps) {
			case 8:
				return Std.int(amp * 127);
			case 16:
				return Std.int(amp * 32767);
			case 32:
				return Std.int(amp * 2147483647);
		}

		throw 'Unknown BPS: $bps';
	}
}
