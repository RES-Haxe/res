package res.rom.converters.palette;

import haxe.io.Bytes;
import haxe.io.BytesOutput;

class PaletteConverter extends Converter {
	public final colors:Array<Color32>;

	public function new(?colors:Array<Color32>) {
		super();

		this.colors = colors == null ? [] : colors;
	}

	public function getBytes():Bytes {
		final bo = new BytesOutput();

		bo.writeByte(colors.length);

		for (color in colors)
			bo.writeUInt24(color.output);

		return bo.getBytes();
	}
}
