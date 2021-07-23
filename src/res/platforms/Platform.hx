package res.platforms;

interface Platform {
	public final pixelFormat:PixelFormat;

	function connect(res:RES):Void;

	function render(res:RES):Void;
}
