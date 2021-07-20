package res.rom;

import haxe.io.BytesInput;
import haxe.io.Bytes;

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

	public static function fromAseprite(aseBytes:Bytes, name:String) {
		var spriteData = ase.Ase.fromBytes(aseBytes);

		if (spriteData.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are supported';

		var bytesOutput = new haxe.io.BytesOutput();

		bytesOutput.writeByte(spriteData.width);
		bytesOutput.writeByte(spriteData.height);
		bytesOutput.writeInt32(spriteData.frames.length);

		for (frame in spriteData.frames) {
			bytesOutput.writeInt32(frame.duration); // frame duration

			var frameData = haxe.io.Bytes.alloc(spriteData.width * spriteData.height);

			for (layer in 0...spriteData.layers.length) {
				var cel = frame.cel(layer);

				if (cel != null) {
					var lineWidth:Int = Std.int(Math.min(spriteData.width, cel.xPosition + cel.width));

					for (scanline in 0...cel.height) {
						var frameLine = cel.yPosition + scanline;

						var framePos = frameLine * spriteData.width + cel.xPosition;
						var celPos = scanline * cel.width;

						frameData.blit(framePos, cel.pixelData, celPos, lineWidth);
					}
				}
			}

			bytesOutput.writeBytes(frameData, 0, frameData.length);
		}

		final data = bytesOutput.getBytes();

		return new RomChunk(SPRITE, name, data);
	}
}
