package res.platforms;

interface Platform {
	public final pixelFormat:PixelFormat;

	function connect(res:Res):Void;

	function render(res:Res):Void;
}
