package res.rom.converters.fonts.json;

import haxe.Json;
import haxe.io.BytesOutput;
import res.rom.FontChunk.FontType;
import sys.FileSystem;
import sys.io.File;

using haxe.io.Path;

typedef FontJson = {
	bitmap:String,
	tileWidth:Int,
	tileHeight:Int,
	?spacing:Int,
	characters:String
};

class Converter extends res.rom.converters.Converter {
	var spriteChunk:SpriteChunk;
	var fontChunk:FontChunk;

	override function process(fileName:String, palette:Palette):res.rom.converters.Converter {
		final json:FontJson = cast Json.parse(File.getContent(fileName));

		final bitmapFile = Path.join([fileName.directory(), json.bitmap]).normalize();

		if (!FileSystem.exists(bitmapFile))
			throw "Bitmap file <" + bitmapFile + "> doesn't exist";

		final ext = bitmapFile.extension().toLowerCase();

		final name = fileName.withoutDirectory().withoutExtension();

		switch (ext) {
			case 'png':
				spriteChunk = res.rom.converters.sprites.png.Converter.createChunk('font:$name', File.getBytes(bitmapFile), palette);
			case _:
				throw 'Unsupported tileset bitmap format: $ext';
		}

		var bo = new BytesOutput();

		bo.writeByte(FontType.FIXED);
		bo.writeByte(json.tileWidth);
		bo.writeByte(json.tileHeight);
		bo.writeByte(json.spacing ?? 0);

		final cbo = new BytesOutput();
		cbo.writeString(json.characters, UTF8);

		final characterBytes = cbo.getBytes();

		bo.writeUInt16(characterBytes.length);
		bo.writeBytes(characterBytes, 0, characterBytes.length);

		fontChunk = new FontChunk(name, bo.getBytes());

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [spriteChunk, fontChunk];
	}
}
