package res.rom.converters.tilesets.aseprite;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import sys.io.File;

using haxe.io.Path;

class Converter extends res.rom.converters.Converter {
	var tilesetChunk:TilesetChunk;
	var reuseRepeated:Bool;

	public function new(?reuseRepeated:Bool = true) {
		super();

		this.reuseRepeated = reuseRepeated;
	}

	public static function createChunk(name:String, bytes:Bytes, ?reuseRepeated = true):TilesetChunk {
		final ase = ase.Ase.fromBytes(bytes);

		if (ase.header.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are allowed';

		final merged = res.rom.tools.AseTools.merge(ase);

		final tiles:Array<Bytes> = [];

		final tileWidth = ase.header.gridWidth;
		final tileHeight = ase.header.gridHeight;

		if (tileWidth > 256 || tileHeight > 256)
			throw 'Tile cannot be larger than 256px for any dimension';

		final hTiles:Int = Math.floor(ase.width / tileWidth);
		final vTiles:Int = Math.floor(ase.height / tileHeight);

		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				final tileData = Bytes.alloc(tileWidth * tileHeight);

				for (t_line in 0...tileHeight) {
					final srcPos = ((line * tileHeight) + t_line) * ase.width + (col * tileWidth);
					final dstPos = t_line * tileWidth;

					tileData.blit(dstPos, merged, srcPos, tileWidth);
				}

				var empty:Bool = true;

				for (n in 0...tileData.length) {
					if (tileData.get(n) != 0) {
						empty = false;
						break;
					}
				}

				if (!empty) {
					var exists:Bool = false;

					if (reuseRepeated) {
						for (exTile in tiles) {
							if (exTile.compare(tileData) == 0) {
								exists = true;
								break;
							}
						}

						if (!exists)
							tiles.push(tileData);
					} else
						tiles.push(tileData);
				}
			}
		}

		final bytesOutput = new BytesOutput();

		bytesOutput.writeByte(tileWidth);
		bytesOutput.writeByte(tileHeight);
		bytesOutput.writeInt32(tiles.length);

		for (tileData in tiles) {
			bytesOutput.writeBytes(tileData, 0, tileData.length);
		}

		return new TilesetChunk(name, bytesOutput.getBytes());
	}

	override function process(fileName:String, palette:Palette) {
		final bytes = File.getBytes(fileName);
		final name = fileName.withoutDirectory().withoutExtension();

		tilesetChunk = createChunk(name, bytes, reuseRepeated);

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [tilesetChunk];
	}
}
