package res;

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

	public function drawi(surface:Bitmap, text:String, x:Int, y:Int, ?colorMap:IndexMap) {
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
					Sprite.spriteRegion(surface, sprite, c.x, c.y, c.width, c.height, tx + c.xoffset, ty + c.yoffset, colorMap);
					tx += c.xadvance;
				}
			}
		}

		return surface;
	}

	public inline function draw(surface:Bitmap, text:String, x:Float, y:Float, ?colorMap:IndexMap) {
		return drawi(surface, text, surface.round(x), surface.round(y), colorMap);
	}

	/**
		Draw text around a given point

		@param surface Butmap do draw to 
		@param text Text to draw
		@param x Center position X
		@param y Center position Y
		@param px 
		@param py
		@param colorMap
	**/
	public function drawPivot(surface:Bitmap, text:String, x:Float, y:Float, px:Float = 0.5, py:Float = 0.5, ?colorMap:IndexMap) {
		final m = measure(text); // TODO: Doing this on each frame... not good. Should this only be allowed on Text class?
		draw(surface, text, x - m.width * px, y - m.height * py, colorMap);
	}

	public static inline function text(surface:Bitmap, font:Font, text:String, x:Float, y:Float, ?colorMap:IndexMap) {
		return font.draw(surface, text, x, y, colorMap);
	}

	public static inline function textPivot(surface:Bitmap, font:Font, text:String, x:Float, y:Float, px:Float = 0.5, py:Float = 0.5, ?colorMap:IndexMap) {
		return font.drawPivot(surface, text, x, y, px, py, colorMap);
	}
}
