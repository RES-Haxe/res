package res.devtools;

import res.input.Key;

class PaletteRender extends Renderable {
	var palette:Palette;
	var res:RES;

	public inline function new(res:RES, palette:Palette) {
		this.res = res;
		this.palette = palette;
	}

	override public function render(frameBuffer:FrameBuffer) {
		final colSize:Int = Std.int(frameBuffer.frameWidth / palette.colors.length);

		for (scanline in 0...frameBuffer.frameHeight) {
			for (col in 0...frameBuffer.frameWidth) {
				final colIndex:Int = scanline < Std.int(frameBuffer.frameHeight / 2) ? Std.int(col / colSize)
					+ 1 : palette.byLuminance[Std.int(col / colSize)];

				frameBuffer.setIndex(col, scanline, colIndex);
			}
		}
	}
}

class PaletteView extends Scene {
	public function new(res:RES) {
		super(res);

		renderList.push(new PaletteRender(res, res.palette));
	}

	override function keyDown(keyCode:Int) {
		if (keyCode == Key.ESCAPE)
			res.popScene();
	}
}
