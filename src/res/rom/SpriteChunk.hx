package res.rom;

import format.png.Reader;
import format.png.Tools;
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
}
