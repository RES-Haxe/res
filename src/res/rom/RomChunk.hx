package res.rom;

import haxe.io.Input;
import haxe.io.Output;
import haxe.io.Bytes;
import res.rom.RomChunkType;

class RomChunk {
	public final chunkType:RomChunkType;
	public final name:String;
	public final data:Bytes;

	public function new(chunkType:RomChunkType, name:String, data:Bytes) {
		this.chunkType = chunkType;
		this.name = name;
		this.data = data;
	}

	public static function read(input:Input):RomChunk {
		final chunkType:RomChunkType = input.readByte();

		var name = input.readString(input.readByte());
		var dataLen = input.readInt32();
		var data = Bytes.alloc(dataLen);
		input.readBytes(data, 0, dataLen);

		switch (chunkType) {
			case SPRITE:
				return new SpriteChunk(name, data);
			case TILESET:
				return new TilesetChunk(name, data);
			case TILEMAP:
				return new TilemapChunk(name, data);
			case DATA:
				return new DataChunk(name, data);
			case _:
				trace('TODO ${chunkType}');
		}

		return null;
	}

	public function write(output:Output) {
		output.writeByte(chunkType);
		output.writeByte(name.length);
		output.writeString(name);
		output.writeInt32(data.length);
		output.writeBytes(data, 0, data.length);
	}
}