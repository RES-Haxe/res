package res.rom.converters.tilemaps.aseprite;

import sys.io.File;

using haxe.io.Path;

class Converter extends res.rom.converters.Converter {
	var tilesetChunk:TilesetChunk;
	var tilemapChunk:TilemapChunk;

	override function process(fileName:String, palette:Palette) {
		final bytes = File.getBytes(fileName);

		final result = TilemapChunk.fromAseprite(bytes, fileName.withoutDirectory().withoutExtension());

		tilesetChunk = result.tilesetChunk;
		tilemapChunk = result.tilemapChunk;

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [tilesetChunk, tilemapChunk];
	}
}
