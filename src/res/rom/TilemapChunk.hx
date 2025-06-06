package res.rom;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import res.Tilemap;
import res.Tileset;

class TilemapChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(TILEMAP, name, data);
	}

	public function getTilemap<D>(tilesets:Map<String, Tileset>):Tilemap<D> {
		final bytesInput = new BytesInput(data);

		final tilesetName = bytesInput.readString(bytesInput.readByte());

		final x:Int = bytesInput.readInt32();
		final y:Int = bytesInput.readInt32();
		final cols:Int = bytesInput.readInt32();
		final lines:Int = bytesInput.readInt32();
		final tilemap = new Tilemap<D>(tilesets[tilesetName], cols, lines);

		tilemap.x = x;
		tilemap.y = y;

		for (line in 0...lines) {
			for (col in 0...cols) {
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
