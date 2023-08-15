package res.rom;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import res.Sprite;

class SpriteChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(SPRITE, name, data);
	}

	public function getSprite():Sprite {
		final bi = new BytesInput(data);

		final x = 0;
		final y = 0;

		final width = bi.readByte();
		final height = bi.readByte();

		final framesNum = bi.readInt32();

		final frames:Array<SpriteFrame> = [];

		for (_ in 0...framesNum) {
			final duration = bi.readInt32();
			final frameData = Bytes.alloc(width * height);
			bi.readBytes(frameData, 0, frameData.length);

			frames.push(new SpriteFrame(frameData, duration));
		}

		final numAnims = bi.readUInt16();

		final animations:Map<String, SpriteAnimation> = [];

		for (_ in 0...numAnims) {
			final name = bi.readString(bi.readUInt16());

			animations[name] = {
				name: name,
				from: bi.readInt32(),
				to: bi.readInt32(),
				direction: bi.readInt8(),
			};
		}

		return new Sprite(name, width, height, x, y, frames, animations);
	}
}
