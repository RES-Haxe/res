package res.features.fonts;

import res.data.CommodorKernalFontData;
import res.text.Font;

class CommodorKernalFont implements Feature {
	public var font:Font;

	public function enable(res:RES) {
		final tileset = res.createTileset(CommodorKernalFontData.H_TILES, CommodorKernalFontData.V_TILES, CommodorKernalFontData.TILE_SIZE);

		tileset.fromBytes(CommodorKernalFontData.DATA, CommodorKernalFontData.WIDTH, CommodorKernalFontData.HEIGHT);
		font = res.createFont('_commodor_kernal', tileset,
			' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]↑_✓abcdefghijklmnopqrstuvwxyz£|←▒▓');
		res.defaultFont = font;
	}
}
