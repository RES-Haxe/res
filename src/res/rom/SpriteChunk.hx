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

	#if macro
	public static function fromAseprite(aseBytes:Bytes, name:String) {
		var spriteData = ase.Ase.fromBytes(aseBytes);

		if (spriteData.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are supported at the moment';

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

		return new SpriteChunk(name, data);
	}

	public static function fromPNG(pngBytes:Bytes, palette:Palette, name:String) {
		final pngReader = new Reader(new BytesInput(pngBytes));

		final pngData = pngReader.read();

		var width:Int = 0;
		var height:Int = 0;

		for (chunk in pngData) {
			switch (chunk) {
				case CHeader(h):
					width = h.width;
					height = h.height;
				case _:
			}
		}

		var pixelData:Bytes = Tools.extract32(pngData);

		var bytesOutput = new haxe.io.BytesOutput();

		bytesOutput.writeByte(width);
		bytesOutput.writeByte(height);
		bytesOutput.writeInt32(1);
		bytesOutput.writeInt32(0); // duration

		var frameData = Bytes.alloc(width * height);

		var colorMap:Map<Color, Int> = [];

		for (line in 0...height) {
			for (col in 0...width) {
				final origColor:Color = pixelData.getInt32((line * width + col) * 4);

				final color = Color.fromRGBA(origColor.g, origColor.b, origColor.a, origColor.r);

				var index:Int = 0;

				if (color.a != 0) {
					if (colorMap[color] != null) {
						index = colorMap[color];
					} else {
						index = palette.closest(color);
						colorMap[color] = index;
					}
				}

				frameData.set(line * width + col, index);
			}
		}

		bytesOutput.writeBytes(frameData, 0, frameData.length);

		return new SpriteChunk(name, bytesOutput.getBytes());
	}
	#end
}
