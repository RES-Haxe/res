package res.features.fonts;

import res.data.KernalFontData;
import res.text.Font;

class KernalFont implements Feature {
	public var font:Font;

	public function enable(res:RES) {
		final tileset = res.createTileset(KernalFontData.H_TILES, KernalFontData.V_TILES, KernalFontData.TILE_SIZE);

		tileset.fromBytes(KernalFontData.DATA, KernalFontData.WIDTH, KernalFontData.HEIGHT);
		font = res.createFont('kernal', tileset, ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]↑_✓abcdefghijklmnopqrstuvwxyz£|←▒▓');
		res.defaultFont = font;
	}
}
