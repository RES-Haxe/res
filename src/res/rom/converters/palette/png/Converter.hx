package res.rom.converters.palette.png;

import format.png.Reader;
import haxe.io.BytesInput;
import sys.io.File;

using format.png.Tools;

class Converter extends PaletteConverter {
	override function process(fileName:String, _) {
		final pngData = new Reader(File.read(fileName)).read();

		final palette = pngData.getPalette();

		if (palette != null) {
			final bi = new BytesInput(palette);

			while (bi.position < bi.length) {
				final bgr24 = bi.readUInt24();
				colors.push(new Color32(bgr24, [A, B, G, R]));
			}
		} else {
			throw 'Only indexed PNGs are supported';
		}
		return this;
	}
}
