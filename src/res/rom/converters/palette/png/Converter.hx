package res.rom.converters.palette.png;

import format.png.Reader;
import haxe.io.BytesInput;
import sys.io.File;

using format.png.Tools;

class Converter extends PaletteConverter {
	override function process(fileName:String) {
		final pngData = new Reader(File.read(fileName)).read();
		final header = pngData.getHeader();

		final palette = pngData.getPalette();

		if (palette != null) {
			final bi = new BytesInput(palette);

			while (bi.position < bi.length) {
				final color:Color = bi.readUInt24();
				colors.push(color.arrange([B, G, R]));
			}
		} else {
			final pixels = pngData.extract32();
			for (line in 0...header.height) {
				for (col in 0...header.width) {
					if (colors.length < 256) {
						final pixel:Color = pixels.getInt32((line * header.width + col) * 4);

						final rgb = pixel.arrange([B, G, R]);

						if (colors.indexOf(rgb) == -1) {
							colors.push(rgb);
						}
					} else
						return this;
				}
			}
		}
		return this;
	}
}
