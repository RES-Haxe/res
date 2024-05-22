package res;

import haxe.io.Bytes;
import res.Mth.lerp;
import res.Mth.param;
import res.Mth.wrap;

using res.tools.BytesTools;

typedef SpriteAnimation = {
	var name:String;
	var from:Int;
	var to:Int;
	var direction:Int;
}

typedef DrawSpriteOptions = {
	var ?x:Float;
	var ?y:Float;
	var ?width:Float;
	var ?height:Float;
	var ?anchorX:Int;
	var ?anchorY:Int;
	var ?pivotX:Float;
	var ?pivotY:Float;
	var ?scrollX:Float;
	var ?scrollY:Float;
	var ?frame:Int;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?wrap:Bool;
};

class SpriteFrame {
	public final data:Bytes;
	public final duration:Int;

	public function new(data:Bytes, duration:Int) {
		this.data = data;
		this.duration = duration;
	}
}

class Sprite {
	public final name:String;

	public final frames:Array<SpriteFrame>;
	public final animations:Map<String, SpriteAnimation>;

	public var x:Float = 0;
	public var y:Float = 0;

	public final width:Int;
	public final height:Int;

	public function new(?name:String = null, width:Int, height:Int, ?x:Int, ?y:Int, ?frames:Array<SpriteFrame>, ?animations:Map<String, SpriteAnimation>) {
		this.name = name;
		this.x = x ?? 0;
		this.y = y ?? 0;
		this.width = width;
		this.height = height;
		this.frames = frames != null ? frames : [];
		this.animations = animations != null ? animations : [];

		for (frame in frames) {
			if (frame.data.length != width * height) {
				throw "Invalid frame size";
			}
		}
	}

	public function add_animation(name:String, from:Int, to:Int, direction:Int) {
		animations[name] = {
			name: name,
			from: from,
			to: to,
			direction: direction
		};
	}

	public function add_frame(data:Bytes, duration:Int) {
		if (data.length != width * height)
			throw "Invalid frame size";

		frames.push(new SpriteFrame(data, duration));
	}

	/**
		Create a new entity from this Sprite
	**/
	public function entity(?x:Float = 0, ?y:Float = 0, ?colorMap:IndexMap):Entity {
		var obj = new Entity(this, colorMap);
		obj.x = x ?? this.x;
		obj.y = y ?? this.y;
		return obj;
	}

	/**
		Get a color index from a pixel of a frame

		@param frame Frame index
		@param x
		@param y
	**/
	public function get(frame:Int, x:Int, y:Int):Int {
		return frames[frame].data.getxy(width, x, y);
	}

	/**
		Draw a sprite

		@param surface
		@param sprite
		@param opts Draw sprite options:
		@param opts.x Sprite `x` position
		@param opts.y Sprite `y` position
		@param opts.width Width of the area to draw sprite to
		@param opts.height Height of the area to draw sprite to 
		@param opts.scrollX X Scrolling
		@param opts.scrollY Y Scrolling
		@param opts.frame Animation frame index
		@param opts.flipX
		@param opts.flipY
		@param opts.wrap
		@param colorMap
	 */
	public static function sprite(surface:Bitmap, sprite:Sprite, opts:DrawSpriteOptions, ?colorMap:IndexMap) {
		final frameIndex = opts.frame ?? 0;

		final frame:SpriteFrame = sprite.frames[frameIndex];

		final width:Float = opts.width ?? sprite.width;
		final height:Float = opts.height ?? sprite.height;

		final lines:Int = surface.round(height);
		final cols:Int = surface.round(width);

		final flipX:Bool = opts.flipX ?? false;
		final flipY:Bool = opts.flipY ?? false;

		final _wrap = opts.wrap == null ? false : opts.wrap;

		final scrollX = opts.scrollX ?? 0;
		final scrollY = opts.scrollY ?? 0;

		final fromX:Int = -(opts.anchorX ?? 0) + surface.round((opts.x ?? 0) - (opts.pivotX == null ? 0 : width * opts.pivotX));
		final fromY:Int = -(opts.anchorY ?? 0) + surface.round((opts.y ?? 0) - (opts.pivotY == null ? 0 : height * opts.pivotY));

		for (scanline in 0...lines) {
			if (!((!_wrap && (scanline < 0 || scanline >= surface.height)))) {
				for (col in 0...cols) {
					final spriteCol = wrap((flipX ? sprite.width - 1 - col : col) + surface.round(scrollX), sprite.width);
					final spriteLine = wrap((flipY ? sprite.height - 1 - scanline : scanline) + surface.round(scrollY), sprite.height);

					final sampleIndex:Int = frame.data.getxy(sprite.width, spriteCol, spriteLine);

					if (sampleIndex != 0) {
						final screenX:Int = _wrap ? wrap(fromX + col, surface.width) : fromX + col;
						final screenY:Int = _wrap ? wrap(fromY + scanline, surface.height) : fromY + scanline;

						if (_wrap || (screenX >= 0 && screenY >= 0 && screenX < surface.width && screenY < surface.height)) {
							final colorIndex = colorMap == null ? sampleIndex : colorMap.get(sampleIndex);
							surface.seti(screenX, screenY, colorIndex);
						}
					}
				}
			}
		}
		return surface;
	}

	/**
		Draw a sprite specifying the position by `x` and `y` coordinates

		@param surface
		@param sprite
		@param x
		@param y
		@param opts Draw sprite options:
		@param opts.width Width of the area to draw sprite to
		@param opts.height Height of the area to draw sprite to 
		@param opts.scrollX X Scrolling
		@param opts.scrollY Y Scrolling
		@param opts.frame Animation frame index
		@param opts.flipX
		@param opts.flipY
		@param opts.wrap
		@param colorMap
	 */
	public static function sprite_xy(surface:Bitmap, sprite:Sprite, ?x:Float = 0, ?y:Float = 0, ?opts:DrawSpriteOptions, ?colorMap:IndexMap) {
		opts = opts ?? {x: x, y: y};

		return Sprite.sprite(surface, sprite, opts, colorMap);
	}

	/**
		Draw a sprite into a rectangle with arbitrary width and height

		@param surface Surface to draw sprite to
		@param sprite Sprite to draw
		@param x X of the rectangle to draw to
		@param y Y of the rectangle to draw to
		@param width The width of the rectangle to draw to 
		@param height The height of the rectangle to draw to 
	**/
	public static function sprite_rect(surface:Bitmap, sprite:Sprite, x:Float, y:Float, width:Float, height:Float, ?frame:Int = 0) {
		for (line in 0...Math.floor(height)) {
			for (col in 0...Math.floor(width)) {
				final sprite_x = Math.floor(lerp(0, sprite.width, param(0, width, col)));
				final sprite_y = Math.floor(lerp(0, sprite.height, param(0, height, line)));
				final px = sprite.get(frame, sprite_x, sprite_y);
				surface.set(x + col, y + line, px);
			}
		}

		return surface;
	}

	/**
		Draw a part of a sprite

		@param surface Surface to draw the sprite to
		@param sprite Sprite to draw
		@param fx From X - position within the sprite
		@param fy From Y - position within the sprite
		@param width Width of the rectangle
		@param height Height of the rectangle
		@param atx X position to draw to
		@param aty Y position to draw to
		@param frame Frame number
		@param colorMap Color map
	**/
	public static function spriteRegion(surface:Bitmap, sprite:Sprite, fx:Int, fy:Int, width:Int, height:Int, atx:Int, aty:Int, ?frame:Int = 0,
			?colorMap:IndexMap) {
		final frameData = sprite.frames[frame].data;

		for (line in 0...height) {
			for (col in 0...width) {
				final oidx = frameData.getxy(sprite.width, fx + col, fy + line);
				final index = colorMap == null ? oidx : colorMap[oidx];
				surface.seti(atx + col, aty + line, index);
			}
		}

		return surface;
	}

	/**
		Draw a sprite using a pivot.

		Pivot is a point in the sprite's space to use as the origing.

		Pivot is defined by `px` and `py` arguments

		For example is the pivot is `px=0.0, py=0.0` the the sprite will be drawn as usual as the origin will be at the left top of the sprite.
		If both `px` and `py` equal to `0.5` (default values) the the origin will be in the center of the sprite


		```
		0,0 +--------+ 1,0
			|        |
			| Sprite |
			|        |
		0,1 +--------+ 1,1
		```

		@param surface Surface to draw the sprite on
		@param sprite Sprite to draw
		@param x Origin X position
		@param y Origin Y position
		@param px Relative X position of the pivot in the sprite's space
		@param py Relative Y position of the pivot in the sprite's space
		@param opts Draw sprite options:
		@param opts.width Width of the area to draw sprite to
		@param opts.height Height of the area to draw sprite to 
		@param opts.scrollX X Scrolling
		@param opts.scrollY Y Scrolling
		@param opts.frame Animation frame index
		@param opts.flipX
		@param opts.flipY
		@param opts.wrap
		@param colorMap
	 */
	public static function sprite_pivot(surface:Bitmap, sprite:Sprite, opts:DrawSpriteOptions, ?px:Float = 0.5, ?py:Float = 0.5, ?colorMap) {
		opts.pivotX = px;
		opts.pivotY = py;
		return Sprite.sprite(surface, sprite, opts, colorMap);
	}

	public static function sprite_pivot_xy(surface:Bitmap, sprite:Sprite, x:Float, y:Float, ?opts:DrawSpriteOptions, ?px:Float = 0.5, ?py:Float = 0.5,
			?colorMap) {
		opts = opts ?? {x: x, y: y};
		opts.x = x;
		opts.y = y;
		opts.pivotX = px;
		opts.pivotY = py;
		return Sprite.sprite(surface, sprite, opts, colorMap);
	}

	public static function sprite_pivot_v(surface:Bitmap, sprite:Sprite, v:{x:Float, y:Float}, ?opts:DrawSpriteOptions, ?px:Float = 0.5, ?py:Float = 0.5,
			?colorMap) {
		opts = opts ?? {x: v.x, y: v.y};
		opts.x = v.x;
		opts.y = v.y;
		opts.pivotX = px;
		opts.pivotY = py;
		return Sprite.sprite(surface, sprite, opts, colorMap);
	}

	/**
		Draw a sprite using an Anchor - a point inside the sprite to use as it's origin

		@param surface Surface to draw the sprite on
		@param sprite Sprite to draw
		@param x Origin X position
		@param y Origin Y position
		@param ax X position inside the sprite to use as it's origin
		@param ay Y position inside the sprite to use as it's origin
	 */
	public static function sprite_anchor(surface:Bitmap, sprite:Sprite, opts:DrawSpriteOptions, ?ax:Int = 0, ?ay:Int = 0, ?colorMap) {
		opts.anchorX = ax;
		opts.anchorY = ay;
		return Sprite.sprite(surface, sprite, opts, colorMap);
	}

	public static function sprite_anchor_xy(surface:Bitmap, sprite:Sprite, x:Float, y:Float, ?opts:DrawSpriteOptions, ?ax:Int = 0, ?ay:Int = 0, ?colorMap) {
		opts = opts ?? {x: x, y: y};
		opts.anchorX = ax;
		opts.anchorY = ay;
		return Sprite.sprite(surface, sprite, opts, colorMap);
	}
}
