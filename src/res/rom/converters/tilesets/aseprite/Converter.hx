package res.rom.converters.tilesets.aseprite;

import ase.types.ChunkType;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import sys.io.File;

using haxe.io.Path;

class Converter extends res.rom.converters.Converter {
	var tilesetChunks:Array<TilesetChunk>;
	var reuseRepeated:Bool;

	public function new(?reuseRepeated:Bool = true) {
		super();

		this.reuseRepeated = reuseRepeated;
	}

	public static function createTilesetChunk(name:String, tilesetChunk:ase.chunks.TilesetChunk) {
		final tileWidth = tilesetChunk.width;
		final tileHeight = tilesetChunk.height;

		if (tileWidth > 256 || tileHeight > 256)
			throw 'Tile size cannot exceed 256px';

		final bytesOutput = new BytesOutput();

		bytesOutput.writeByte(tileWidth);
		bytesOutput.writeByte(tileHeight);
		bytesOutput.writeInt32(tilesetChunk.numTiles);

		bytesOutput.writeBytes(tilesetChunk.uncompressedTilesetImage, 0, tilesetChunk.uncompressedTilesetImage.length);

		return new TilesetChunk(name, bytesOutput.getBytes());
	}

	public static function createChunks(name:String, bytes:Bytes, ?reuseRepeated = true):Array<TilesetChunk> {
		final result:Array<TilesetChunk> = [];
		final ase = ase.Ase.fromBytes(bytes);

		if (ase.header.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are allowed';

		final tilesets:Array<ase.chunks.TilesetChunk> = cast ase.firstFrame.chunkTypes[ChunkType.TILESET];

		if (tilesets != null) {
			for (aseTilesetChunk in tilesets)
				result.push(createTilesetChunk(name, aseTilesetChunk));
		} else
			trace('No tilesets in $name');

		return result;
	}

	override function process(fileName:String, palette:Palette) {
		final bytes = File.getBytes(fileName);
		final name = fileName.withoutDirectory().withoutExtension();

		tilesetChunks = createChunks(name, bytes, reuseRepeated);

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return cast tilesetChunks;
	}
}
