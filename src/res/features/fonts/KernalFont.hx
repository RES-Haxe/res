package res.features.fonts;

import res.data.KernalFontData;
import res.text.Font;

class KernalFont implements Feature {
	public var font:Font;

	public function enable(res:RES) {
		final tileset = res.createTileset(KernalFontData.H_TILES, KernalFontData.V_TILES, KernalFontData.TILE_SIZE);

		// TODO: Ad Hoc solution. Needs refactoring
		final c = res.rom.palette.brightestIndex;
		for (n in 0...KernalFontData.DATA.length) {
			final b = KernalFontData.DATA.get(n);

			if (b == 1)
				KernalFontData.DATA.set(n, c);
		}

		tileset.fromBytes(KernalFontData.DATA, KernalFontData.WIDTH, KernalFontData.HEIGHT);
		font = res.createFont('kernal', tileset, ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]↑_✓abcdefghijklmnopqrstuvwxyz£|←▒▓');
		res.defaultFont = font;
	}
}
