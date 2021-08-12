package res.rom;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import res.display.Sprite;
import res.display.SpriteFrame;

class SpriteChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(SPRITE, name, data);
	}

	public function getSprite():Sprite {
		final bi = new BytesInput(data);
		final width = bi.readByte();
		final height = bi.readByte();

		final framesNum = bi.readInt32();

		final frames:Array<SpriteFrame> = [];

		for (n in 0...framesNum) {
			final duration = bi.readInt32();
			final frameData = Bytes.alloc(width * height);
			bi.readBytes(frameData, 0, frameData.length);

			frames.push(new SpriteFrame(frameData, duration));
		}

		return new Sprite(width, height, frames);
	}

	#if macro
	public static function fromAseprite(aseBytes:Bytes, name:String) {
		var spriteData = ase.Ase.fromBytes(aseBytes);

		if (spriteData.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are supported';

		var bytesOutput = new haxe.io.BytesOutput();

		bytesOutput.writeByte(spriteData.width);
		bytesOutput.writeByte(spriteData.height);
		bytesOutput.writeInt32(spriteData.frames.length);

		for (frame_num in 0...spriteData.frames.length) {
			var frame = spriteData.frames[frame_num];
			bytesOutput.writeInt32(frame.duration); // frame duration

			var frameData = res.rom.tools.AseTools.merge(spriteData, frame_num);

			bytesOutput.writeBytes(frameData, 0, frameData.length);
		}

		final data = bytesOutput.getBytes();

		return new RomChunk(SPRITE, name, data);
	}
	#end
}
