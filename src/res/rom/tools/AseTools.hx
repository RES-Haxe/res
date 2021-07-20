package res.rom.tools;

import haxe.io.Bytes;
import ase.Ase;

class AseTools {
	public static function merge(ase:Ase):Bytes {
		final merged = Bytes.alloc(ase.width * ase.height);

		for (index in 0...ase.layers.length) {
			if (ase.layers[index].visible) {
				final cel = ase.firstFrame.cel(index);

				if (cel != null) {
					for (line in 0...cel.height) {
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
}
