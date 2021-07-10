package res.devtools;

import res.input.Key;

class PaletteRender implements Renderable {
	var palette:Palette;
	var res:Res;

	public inline function new(res:Res, palette:Palette) {
		this.res = res;
		this.palette = palette;
	}

	public function render(frameBuffer:FrameBuffer) {
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
	public function new(res:Res) {
		super(res);

		renderList.push(new PaletteRender(res, res.palette));
	}

	override function keyDown(keyCode:Int) {
		if (keyCode == Key.ESCAPE)
			res.popScene();
	}
}