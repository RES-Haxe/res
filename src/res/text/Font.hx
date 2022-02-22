package res.text;

import res.display.FrameBuffer;
import res.display.Sprite;

typedef Char = {
	x:Int,
	y:Int,
	width:Int,
	height:Int,
	xoffset:Int,
	yoffset:Int,
	xadvance:Int
};

class Font {
	public final sprite:Sprite;
	public final base:Int;
	public final lineHeight:Int;
	public final characters:Map<Int, Char>;

	public inline function new(sprite:Sprite, base:Int, lineHeight:Int, characters:Map<Int, Char>) {
		this.base = base;
		this.lineHeight = lineHeight;
		this.sprite = sprite;
		this.characters = characters;
	}

	public function draw(frameBuffer:FrameBuffer, text:String, x:Int, y:Int, ?colorMap:ColorMap) {
		var tx = x;
		var ty = y;
		for (cn in 0...text.length) {
			final char = text.charCodeAt(cn);

			if (char == '\n'.charCodeAt(0)) {
				tx = x;
				ty += lineHeight;
			} else {
				final c = characters.exists(char) ? characters[char] : characters[' '.charCodeAt(0)];

				if (c != null) {
					Sprite.drawRegion(frameBuffer, sprite, c.x, c.y, c.width, c.height, tx + c.xoffset, ty + c.yoffset);
					tx += c.xadvance;
				}
			}
		}
	}
}
