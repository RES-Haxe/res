package res;

import res.types.ColorComponent;

/**
	Cathode Ray Tube
**/
abstract class CRT {
	public final pixelFormat:Array<ColorComponent>;

	public function new(pixelFormat:Array<ColorComponent>) {
		this.pixelFormat = pixelFormat;
	}

	abstract public function beam(x:Int, y:Int, index:Int, palette:Palette):Void;

	/**
		Before scanline

		@param lineNum
	**/
	function backPorch(lineNum:Int) {}

	/**
		After scanline

		@param lineNum
	**/
	function frontPorch(lineNum:Int) {}

	/**
		Vertical blanking
	**/
	function vblank() {}

	/**
		Vertical syncing.
		Called after the last line
	**/
	function vsync() {}

	/**
		Rester the image from a FrameBuffer

		@param frameBuffer
		@param palette
	**/
	public function raster(frameBuffer:FrameBuffer, palette:Palette):Void {
		vblank();

		for (line in 0...frameBuffer.height) {
			backPorch(line);

			for (col in 0...frameBuffer.width)
				beam(col, line, frameBuffer.get(col, line), palette);

			frontPorch(line);
		}

		vsync();
	}
}
