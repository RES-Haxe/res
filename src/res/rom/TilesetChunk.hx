package res.rom;

import ase.Ase;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import res.rom.tools.AseTools;
import res.tiles.Tileset;

class TilesetChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(TILESET, name, data);
	}

	public function getTileset():Tileset {
		final bi = new BytesInput(data);

		final tileWidth = bi.readByte();
		final tileHeight = bi.readByte();
		final numTiles = bi.readInt32();

		final tileset = new Tileset(tileWidth, 16, 16);

		for (_ in 0...numTiles) {
			final tileData = Bytes.alloc(tileWidth * tileHeight);
			bi.readBytes(tileData, 0, tileData.length);
			tileset.pushTile(tileData);
		}

		return tileset;
	}

	public static function fromAseprite(bytes:Bytes, name:String, ?reuseRepeated:Bool = true):TilesetChunk {
		final ase = Ase.fromBytes(bytes);

		if (ase.header.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are allowed';

		final merged = AseTools.merge(ase);

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
}
