package res.rom.converters.tilemaps.aseprite;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import res.rom.tools.AseTools;
import sys.io.File;

class Converter extends res.rom.converters.Converter {
	var tilesetChunk:TilesetChunk;
	var tilemapChunk:TilemapChunk;

	public static function createChunks(bytes:Bytes, name:String) {
		final tilesetChunk = res.rom.converters.tilesets.aseprite.Converter.createChunk(name, bytes);
		final tileset = tilesetChunk.getTileset();

		final ase = ase.Ase.fromBytes(bytes);

		final tileWidth = ase.header.gridWidth;
		final tileHeight = ase.header.gridHeight;

		final hTiles = Math.floor(ase.width / tileWidth);
		final vTiles = Math.floor(ase.height / tileHeight);

		final merged = AseTools.merge(ase);

		final bytesOutput = new BytesOutput();
		bytesOutput.writeByte(name.length);
		bytesOutput.writeString(name);
		bytesOutput.writeInt32(hTiles);
		bytesOutput.writeInt32(vTiles);

		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				final tileData = Bytes.alloc(tileWidth * tileHeight);

				for (t_line in 0...tileHeight) {
					final srcPos = ((line * tileHeight) + t_line) * ase.width + (col * tileWidth);
					final dstPos = t_line * tileWidth;

					tileData.blit(dstPos, merged, srcPos, tileWidth);
				}

				var found:Null<Int> = null;

				for (n in 0...tileset.numTiles) {
					if (tileset.get(n).indecies.compare(tileData) == 0) {
						found = n + 1;
						break;
					}
				}

				if (found != null) {
					bytesOutput.writeUInt16(found);
				} else {
					bytesOutput.writeUInt16(0);
				}

				bytesOutput.writeByte(0); // flipX
				bytesOutput.writeByte(0); // flipY
				bytesOutput.writeByte(0); // rot90cw
			}
		}

		return {
			tilesetChunk: tilesetChunk,
			tilemapChunk: new TilemapChunk(name, bytesOutput.getBytes())
		};
	}

	override function process(fileName:String, palette:Palette) {
		final bytes = File.getBytes(fileName);

		final result = createChunks(bytes, makeName(fileName));

		tilesetChunk = result.tilesetChunk;
		tilemapChunk = result.tilemapChunk;

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [tilesetChunk, tilemapChunk];
	}
}
