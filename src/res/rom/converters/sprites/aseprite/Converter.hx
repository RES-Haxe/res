package res.rom.converters.sprites.aseprite;

import ase.Ase;
import ase.chunks.SliceChunk;
import ase.types.ChunkType;
import haxe.io.Bytes;
import res.rom.tools.AseTools;
import res.tools.BytesTools;
import sys.io.File;

using haxe.io.Path;

typedef SpriteDesc = {
	name:String,
	width:Int,
	height:Int,
	frames:Array<{
		duration:Int,
		data:Bytes
	}>
}

class Converter extends res.rom.converters.Converter {
	var sprites:Array<SpriteDesc> = [];

	override function process(fileName:String, _):res.rom.converters.Converter {
		final aseprite = Ase.fromBytes(File.getBytes(fileName));

		if (aseprite.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are supported at the moment';

		final fullFrames:Array<Bytes> = [];

		for (num in 0...aseprite.frames.length) {
			fullFrames.push(AseTools.merge(aseprite, num));
		}

		final slices = aseprite.firstFrame.chunkTypes[ChunkType.SLICE];

		if (slices != null && slices.length > 0) {
			for (sliceChunk in slices.map(s -> cast(s, SliceChunk))) {
				for (key in sliceChunk.sliceKeys) {
					sprites.push({
						name: sliceChunk.name,
						width: key.width,
						height: key.height,
						frames: [for (num in 0...aseprite.frames.length)
							({
								duration:aseprite.frames[num].duration, data:BytesTools.copyRect(fullFrames[num], aseprite.width, key.xOrigin, key.yOrigin,
									key.width, key.height)
							})]
					});
				}
			}
		} else {
			sprites.push({
				name: fileName.withoutDirectory().withoutExtension(),
				width: aseprite.width,
				height: aseprite.height,
				frames: [for (num in 0...aseprite.frames.length)
					({
						duration:aseprite.frames[num].duration, data:fullFrames[num]
					})]
			});
		}

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return sprites.map(function(sprite) {
			var bytesOutput = new haxe.io.BytesOutput();

			bytesOutput.writeByte(sprite.width);
			bytesOutput.writeByte(sprite.height);
			bytesOutput.writeInt32(sprite.frames.length);

			for (frame_num in 0...sprite.frames.length) {
				var frame = sprite.frames[frame_num];
				bytesOutput.writeInt32(frame.duration); // frame duration
				bytesOutput.writeBytes(frame.data, 0, frame.data.length);
			}

			final data = bytesOutput.getBytes();

			return cast new SpriteChunk(sprite.name, data);
		});
	}
}
