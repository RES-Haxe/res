package res.rom.converters.tilesets.aseprite;

import sys.io.File;

using haxe.io.Path;

class Converter extends res.rom.converters.Converter {
	var tilesetChunk:TilesetChunk;
	var tilemapChunk:TilemapChunk;

	override function process(fileName:String, palette:Palette) {
	}

	override function getChunks():Array<RomChunk> {
		return [tilesetChunk, tilemapChunk];
	}
}
