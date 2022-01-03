package res.rom.converters.sprites.png;

import format.png.Reader;
import format.png.Tools;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import sys.io.File;

using haxe.io.Path;

class Converter extends res.rom.converters.Converter {
	var spriteChunk:SpriteChunk;

	public static function createChunk(name:String, pngBytes:Bytes, palette:Palette):SpriteChunk {
		final pngReader = new Reader(new BytesInput(pngBytes));

		final pngData = pngReader.read();

		var width:Int = 0;
		var height:Int = 0;

		for (chunk in pngData) {
			switch (chunk) {
				case CHeader(h):
					width = h.width;
					height = h.height;
				case _:
			}
		}

		var pixelData:Bytes = Tools.extract32(pngData);

		var bytesOutput = new haxe.io.BytesOutput();

		bytesOutput.writeByte(width);
		bytesOutput.writeByte(height);
		bytesOutput.writeInt32(1);
		bytesOutput.writeInt32(0); // duration

		var frameData = Bytes.alloc(width * height);

		var colorMap:Map<Color, Int> = [];

		for (line in 0...height) {
			for (col in 0...width) {
				final origColor:Color = pixelData.getInt32((line * width + col) * 4);

				final color = Color.fromRGBA(origColor.g, origColor.b, origColor.a, origColor.r);

				var index:Int = 0;

				if (color.a != 0) {
					if (colorMap[color] != null) {
						index = colorMap[color];
					} else {
						index = palette.closest(color);
						colorMap[color] = index;
					}
				}

				frameData.set(line * width + col, index);
			}
		}

		bytesOutput.writeBytes(frameData, 0, frameData.length);

		return new SpriteChunk(name, bytesOutput.getBytes());
	}

	override function process(fileName:String, palette:Palette) {
		final name = fileName.withoutDirectory().withoutExtension();

		final pngBytes = File.getBytes(fileName);

		spriteChunk = createChunk(name, pngBytes, palette);

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [spriteChunk];
	}
}
