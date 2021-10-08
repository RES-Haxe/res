package res.features.devtools;

import res.display.Renderable;
import res.input.Key;
import res.input.KeyboardEvent;

class PaletteRender extends Renderable {
	var palette:Palette;
	var res:RES;

	public inline function new(res:RES, palette:Palette) {
		this.res = res;
		this.palette = palette;
	}

	override public function render(frameBuffer:IFrameBuffer) {
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

		add(new PaletteRender(res, res.rom.palette));
	}

	override function keyboardEvent(event:KeyboardEvent) {
		switch (event) {
			case KEY_DOWN(keyCode):
				if (keyCode == Key.ESCAPE)
					res.popScene();
			case _:
		}
	}
}
