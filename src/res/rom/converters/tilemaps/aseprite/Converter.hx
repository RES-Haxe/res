package res.rom.converters.tilemaps.aseprite;

import ase.chunks.CelChunk;
import ase.types.ChunkType;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import res.rom.tools.AseTools;
import sys.io.File;

class Converter extends res.rom.converters.Converter {
	var chunks:Array<RomChunk> = [];

	public static function createChunks(bytes:Bytes, name:String):Array<RomChunk> {
		final result:Array<RomChunk> = [];
		final tilesetChunk = res.rom.converters.tilesets.aseprite.Converter.createChunk(name, bytes);

		result.push(tilesetChunk);

		final tileset = tilesetChunk.getTileset();

		final aseSprite = ase.Ase.fromBytes(bytes);

		final aseTilesetChunks = aseSprite.firstFrame.chunkTypes[ChunkType.TILESET];
		final hasTileset = aseTilesetChunks != null && aseTilesetChunks.length != 0;

		final tileWidth = aseSprite.header.gridWidth;
		final tileHeight = aseSprite.header.gridHeight;

		if (hasTileset) {
			for (chunk in aseSprite.firstFrame.chunkTypes[ChunkType.CEL]) {
				final celChunk:CelChunk = cast chunk;

				if (celChunk.celType == CompressedTilemap) {
					final tilemapName = name + '_' + aseSprite.layers[celChunk.layerIndex].name;

					final bo = new BytesOutput();
					bo.writeInt32(celChunk.width);
					bo.writeInt32(celChunk.height);

					final inp = new BytesInput(celChunk.tilemapData);

					for (_ in 0...celChunk.height) {
						for (_ in 0...celChunk.width) {
							final tileData = inp.readInt32();

							final tileId = tileData & celChunk.bitmaskTileId;

							bo.writeUInt16(tileId);
							bo.writeByte(tileData & celChunk.bitmaskXFlip); // flipX
							bo.writeByte(tileData & celChunk.bitmaskYFlip); // flipY
							bo.writeByte(tileData & celChunk.bitmask90CWRotation); // rot90cw
						}
					}

					result.push(new TilemapChunk(tilemapName, bo.getBytes()));
				}
			}
		} else {
			final hTiles = Math.floor(aseSprite.width / tileWidth);
			final vTiles = Math.floor(aseSprite.height / tileHeight);

			final merged = AseTools.merge(aseSprite);

			final bo = new BytesOutput();
			bo.writeInt32(hTiles);
			bo.writeInt32(vTiles);

			for (line in 0...vTiles) {
				for (col in 0...hTiles) {
					final tileData = Bytes.alloc(tileWidth * tileHeight);

					for (t_line in 0...tileHeight) {
						final srcPos = ((line * tileHeight) + t_line) * aseSprite.width + (col * tileWidth);
						final dstPos = t_line * tileWidth;

						tileData.blit(dstPos, merged, srcPos, tileWidth);
					}

					var found:Null<Int> = null;

					for (n in 0...tileset.numTiles) {
						if (tileset.getTileData(n).compare(tileData) == 0) {
							found = n + 1;
							break;
						}
					}

					if (found != null) {
						bo.writeUInt16(found);
					} else {
						bo.writeUInt16(0);
					}

					bo.writeByte(0); // flipX
					bo.writeByte(0); // flipY
					bo.writeByte(0); // rot90cw
				}
			}

			result.push(new TilemapChunk(name, bo.getBytes()));
		}

		return result;
	}

	override function process(fileName:String, palette:Palette) {
		final bytes = File.getBytes(fileName);

		chunks = createChunks(bytes, makeName(fileName));

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return chunks;
	}
}
