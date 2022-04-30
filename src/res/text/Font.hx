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

	public function measure(text:String):{width:Int, height:Int} {
		var result = {width: 0, height: 0};

		for (line in text.split('\n')) {
			var lineWidth:Int = 0;
			for (n in 0...line.length) {
				final char = line.charCodeAt(n);
				final c = characters.exists(char) ? characters[char] : characters[' '.charCodeAt(0)];

				if (c != null)
					lineWidth += c.xadvance;
			}

			if (lineWidth > result.width)
				result.width = lineWidth;

			result.height += lineHeight;
		}

		return result;
	}

	public function draw(frameBuffer:FrameBuffer, text:String, x:Int, y:Int, ?colorMap:IndexMap) {
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
					Sprite.drawSpriteRegion(frameBuffer, sprite, c.x, c.y, c.width, c.height, tx + c.xoffset, ty + c.yoffset);
					tx += c.xadvance;
				}
			}
		}
	}

	public function drawPivot(frameBuffer:FrameBuffer, text:String, x:Int, y:Int, px:Float = 0.5, py:Float = 0.5, ?colorMap:IndexMap) {
		final m = measure(text);
		draw(frameBuffer, text, Std.int(x - m.width * px), Std.int(y - m.height * py), colorMap);
	}
}
