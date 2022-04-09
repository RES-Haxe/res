package res.rom.converters.sprites.aseprite;

import ase.Ase;
import ase.chunks.SliceChunk;
import ase.chunks.TagsChunk;
import ase.types.ChunkType;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import res.rom.tools.AseTools;
import res.tools.BytesTools;
import sys.io.File;

using haxe.io.Path;

typedef Animation = {
	name:String,
	from:Int,
	to:Int,
	direction:Int
};

typedef SpriteDesc = {
	name:String,
	width:Int,
	height:Int,
	frames:Array<{
		duration:Int,
		data:Bytes
	}>,
	animations:Array<Animation>
}

class Converter extends res.rom.converters.Converter {
	var sprites:Array<SpriteDesc>;

	override function process(fileName:String, _):res.rom.converters.Converter {
		sprites = [];

		final aseprite = Ase.fromBytes(File.getBytes(fileName));

		if (aseprite.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are supported at the moment';

		final fullFrames:Array<Bytes> = [];

		for (num in 0...aseprite.frames.length) {
			fullFrames.push(AseTools.merge(aseprite, num));
		}

		final animations:Array<Animation> = [];

		final tagsChunks = aseprite.firstFrame.chunkTypes[ChunkType.TAGS];

		if (tagsChunks != null) {
			for (tagsChunk in tagsChunks.map(c -> cast(c, TagsChunk))) {
				if (tagsChunk != null) {
					for (tag in tagsChunk.tags) {
						animations.push({
							name: tag.tagName,
							from: tag.fromFrame,
							to: tag.toFrame,
							direction: tag.animDirection
						});
					}
				}
			}
		}

		final slices = aseprite.firstFrame.chunkTypes[ChunkType.SLICE];

		final spriteName = makeName(fileName);

		if (slices != null && slices.length > 0) {
			for (sliceChunk in slices.map(s -> cast(s, SliceChunk))) {
				for (key in sliceChunk.sliceKeys) {
					sprites.push({
						name: '${spriteName}_${sliceChunk.name}',
						width: key.width,
						height: key.height,
						frames: [
							for (num in 0...aseprite.frames.length)
								({
									duration:aseprite.frames[num].duration, data:BytesTools.copyRect(fullFrames[num], aseprite.width, key.xOrigin,
										key.yOrigin, key.width, key.height)
								})
						],
						animations: animations
					});
				}
			}
		} else {
			sprites.push({
				name: makeName(fileName),
				width: aseprite.width,
				height: aseprite.height,
				frames: [
					for (num in 0...aseprite.frames.length)
						({
							duration:aseprite.frames[num].duration, data:fullFrames[num]
						})
				],
				animations: animations
			});
		}

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return sprites.map(function(sprite) {
			var bytesOutput = new BytesOutput();

			bytesOutput.writeByte(sprite.width);
			bytesOutput.writeByte(sprite.height);
			bytesOutput.writeInt32(sprite.frames.length);

			for (frame_num in 0...sprite.frames.length) {
				var frame = sprite.frames[frame_num];
				bytesOutput.writeInt32(frame.duration); // frame duration
				bytesOutput.writeBytes(frame.data, 0, frame.data.length);
			}

			bytesOutput.writeUInt16(sprite.animations.length);

			for (anim in sprite.animations) {
				bytesOutput.writeUInt16(anim.name.length);
				bytesOutput.writeString(anim.name);
				bytesOutput.writeInt32(anim.from);
				bytesOutput.writeInt32(anim.to);
				bytesOutput.writeInt8(anim.direction);
			}

			final data = bytesOutput.getBytes();

			return cast new SpriteChunk(sprite.name, data);
		});
	}
}
