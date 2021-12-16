package res.rom.converters.palette;

import haxe.io.Bytes;
import haxe.io.BytesOutput;

class PaletteConverter extends Converter {
	public final colors:Array<Color>;

	public function new(?colors:Array<Color>) {
		super();

		this.colors = colors == null ? [0x0] : colors;
	}

	public function getBytes():Bytes {
		final bo = new BytesOutput();

		bo.writeByte(colors.length);

		for (color in colors)
			bo.writeUInt24(color);

		return bo.getBytes();
	}
}
