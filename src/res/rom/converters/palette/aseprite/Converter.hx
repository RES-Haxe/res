package res.rom.converters.palette.aseprite;

import ase.Ase;
import sys.io.File;

class Converter extends PaletteConverter {
	override function process(fileName:String, palette:Palette):res.rom.converters.Converter {
		final sprite = Ase.fromBytes(File.getBytes(fileName));

		for (index in sprite.palette.firstIndex + 1...sprite.palette.lastIndex + 1) {
			final color = new Color32(sprite.palette.getRGBA(index), [R, G, B, A]);
			colors.push(color);
		}

		return super.process(fileName, palette);
	}
}
