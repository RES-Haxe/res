package res.rom;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import res.tiles.Tilemap;
import res.tiles.Tileset;

class TilemapChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(TILEMAP, name, data);
	}

	public function getTilemap(tileset:Tileset):Tilemap {
		final bytesInput = new BytesInput(data);

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
}
