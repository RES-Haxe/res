package res.rom.converters.fonts.json;

import haxe.Json;
import haxe.io.Bytes;
import sys.FileSystem;
import sys.io.File;

using haxe.io.Path;

typedef FontJson = {
	bitmap:String,
	tileSize:Int,
	characters:String
};

class Converter extends res.rom.converters.Converter {
	var tilesetChunk:TilesetChunk;
	var fontChunk:FontChunk;

	override function process(fileName:String, palette):res.rom.converters.Converter {
		final json:FontJson = cast Json.parse(File.getContent(fileName));

		final bitmapFile = Path.join([fileName.directory(), json.bitmap]).normalize();

		if (!FileSystem.exists(bitmapFile))
			throw "Bitmap file <" + bitmapFile + "> doesn't exist";

		final ext = bitmapFile.extension().toLowerCase();

		final name = fileName.withoutDirectory().withoutExtension();

		switch (ext) {
			case 'png':
				tilesetChunk = res.rom.converters.tilesets.png.Converter.createChunk(bitmapFile, 'font:$name', json.tileSize, palette, true);
			case _:
				throw 'Unsupported tileset bitmap format: $ext';
		}

		fontChunk = new FontChunk(name, Bytes.ofString(json.characters, UTF8));

		return super.process(fileName, palette);
	}

	override function getChunks():Array<RomChunk> {
		return [tilesetChunk, fontChunk];
	}
}
