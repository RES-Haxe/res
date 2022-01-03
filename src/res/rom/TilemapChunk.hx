package res.rom;

import res.rom.converters.tilemaps.aseprite.Converter;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import res.rom.tools.AseTools;
import res.tiles.Tilemap;
import res.tiles.Tileset;

class TilemapChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(TILEMAP, name, data);
	}

	public function getTilemap(tileset:Tileset):Tilemap {
		final bytesInput = new BytesInput(data);

		final tilesetName = bytesInput.readString(bytesInput.readByte());

		final hTiles:Int = bytesInput.readInt32();
		final vTiles:Int = bytesInput.readInt32();
		final tilemap = new Tilemap(tileset, hTiles, vTiles);

		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				final tileIndex = bytesInput.readUInt16();
				final flipX = bytesInput.readByte() == 1;
				final flipY = bytesInput.readByte() == 1;
				final rot90cw = bytesInput.readByte() == 1;

				tilemap.set(col, line, tileIndex, flipX, flipY, rot90cw);
			}
		}

		return tilemap;
	}

	public static function fromAseprite(bytes:Bytes, name:String):{tilesetChunk:TilesetChunk, tilemapChunk:TilemapChunk} {
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
}
