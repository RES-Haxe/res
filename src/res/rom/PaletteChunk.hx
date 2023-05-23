package res.rom;

import haxe.io.Bytes;
import haxe.io.BytesInput;

class PaletteChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(PALETTE, name, data);
	}

	public function getPalette():Palette {
		final bi = new BytesInput(data);

		final nColors = bi.readByte();

		final colors = [for (_ in 0...nColors) Color32.ofRGB8(bi.readUInt24())];

		return new Palette(colors);
	}
}
