package res.features.fonts;

import res.text.Font;
import res.data.Pico8FontData;

class Pico8Font implements Feature {
	public var font:Font;

	public function enable(res:RES) {
		final tileset = res.createTileset(Pico8FontData.H_TILES, Pico8FontData.V_TILES, Pico8FontData.TILE_SIZE);

		tileset.fromBytes(Pico8FontData.DATA, Pico8FontData.WIDTH, Pico8FontData.HEIGHT);
		font = res.createFont('_pico8_font', tileset, ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~');
		res.defaultFont = font;
	}
}
