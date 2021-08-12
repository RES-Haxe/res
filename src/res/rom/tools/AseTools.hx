package res.rom.tools;

import haxe.io.Bytes;

class AseTools {
	#if macro
	public static function merge(ase:ase.Ase, ?frame:Int = 0):Bytes {
		final merged = Bytes.alloc(ase.width * ase.height);

		for (index in 0...ase.layers.length) {
			if (ase.layers[index].visible) {
				final cel = ase.frames[frame].cel(index);

				if (cel != null) {
					for (line in 0...Std.int(Math.min(ase.height, cel.height))) {
						final srcPos = line * cel.width;
						final srcLen = cel.width;

						final dstPos = (cel.yPosition + line) * ase.width + cel.xPosition;

						merged.blit(dstPos, cel.pixelData, srcPos, srcLen);
					}
				}
			}
		}

		return merged;
	}
	#end
}
