package res;

import res.Sprite.DrawSpriteOptions;
import res.Sprite.SpriteAnimation;
import res.Sprite.SpriteFrame;

using Math;
using res.tools.BytesTools;

enum abstract EntityAnimDirection(Int) from Int to Int {
	var Forward = 0;
	var Backwards = 1;
	var PingPong = 2;
}

enum PingPongCycle {
	F;
	B;
}

enum EntityOffsetMode {
	NONE;
	PIVOT(px:Float, py:Float);
	ANCHOR(ax:Int, ay:Int);
}

/**
	Stateful Entity based on a Sprite
 */
class Entity {
	public final sprite:Sprite;

	/** Animation speed scale */
	public var animationSpeed:Float = 1;

	/** Whether the animation should be playing */
	public var playing:Bool = false;

	/** Whether the animation should be looped or not (default `true`) */
	public var loop:Bool = true;

	public var colorMap:IndexMap;

	/** The width of the rectangle in which the sprite should be rendered (initial value is the width of the sprite) */
	public var width:Int;

	/** The height of the rectangle in which the sprite should be rendered (initial value is the height of the sprite) */
	public var height:Int;

	public var wrap:Bool = false;

	public var x:Float = 0;
	public var y:Float = 0;

	/** Whether the sprite should be flipped horizontally or not */
	public var flipX:Bool = false;

	/** Whether the sprite should be flipped vertically or not */
	public var flipY:Bool = false;

	public var scrollX:Int = 0;
	public var scrollY:Int = 0;

	public var offset:EntityOffsetMode = NONE;

	public var currentFrame(get, never):SpriteFrame;

	function get_currentFrame():SpriteFrame {
		return sprite.frames[currentFrameIndex];
	}

	public var currentFrameIndex:Int = 0;

	var _frameTime:Float = 0;
	var _pingPongCycle:PingPongCycle = F;
	var _animation:SpriteAnimation;
	var _currentAnimationName:String;

	public var currentAnimaionName(get, never):String;

	function get_currentAnimaionName() {
		return _currentAnimationName;
	}

	/** Total current animation time in seconds **/
	public var totalAnimationTime(get, never):Float;

	function get_totalAnimationTime() {
		var result:Float = 0;

		for (f in _animation.from..._animation.to + 1)
			result += (sprite.frames[f].duration / 1000);

		return result;
	}

	public function new(sprite:Sprite, ?play:Bool = false, ?colorMap:IndexMap) {
		this.sprite = sprite;
		this.colorMap = colorMap;

		width = sprite.width;
		height = sprite.height;

		playing = play;

		_animation = {
			name: '_all',
			direction: Forward,
			from: 0,
			to: sprite.frames.length - 1
		};
	}

	public function setAnimation(name:String, restart:Bool = false) {
		final anim = sprite.animations[name];

		if (anim != null) {
			if (_animation.name != anim.name || _animation.name == anim.name && restart) {
				_frameTime = 0;
				currentFrameIndex = anim.from;

				if (anim.direction == PingPong)
					_pingPongCycle = F;
			}

			_animation = anim;
			_currentAnimationName = name;
		} else
			trace('No animation named <$name>');
	}

	public function play(?name:String) {
		if (name != null)
			setAnimation(name);
		playing = true;
	}

	public dynamic function stopped() {};

	function nextFrame() {
		final inc = switch (_animation.direction) {
			case Forward:
				1;
			case Backwards:
				-1;
			case PingPong:
				switch (_pingPongCycle) {
					case F: 1;
					case B: -1;
				};
			case _:
				1;
		};

		currentFrameIndex += inc;

		var hitEnd = false;

		if (currentFrameIndex > _animation.to) {
			currentFrameIndex = _animation.to;
			hitEnd = true;
		}

		if (currentFrameIndex < _animation.from) {
			currentFrameIndex = _animation.from;
			hitEnd = true;
		}

		if (hitEnd) {
			if (_animation.direction == PingPong && _pingPongCycle == F)
				_pingPongCycle = B;
			else {
				if (loop) {
					if (_animation.direction == PingPong) {
						_pingPongCycle = F;
					} else {
						currentFrameIndex = _animation.from;
					}
				} else {
					playing = false;
					stopped();
				}
			}
		}
	}

	public function update(dt:Float) {
		if (sprite != null && playing) {
			final currentFrameDuration = (currentFrame.duration / 1000);

			while (_frameTime > currentFrameDuration) {
				_frameTime -= currentFrameDuration;

				nextFrame();
			}

			_frameTime += (dt * animationSpeed);
		}
	}

	/**
		Draw an Entity

		@param surface Frame buffer
		@param ety Entity
		@param x Override x
		@param y Override y
	 */
	public static function entity(surface:Bitmap, ety:Entity, ?x:Float, ?y:Float) {
		x = x ?? ety.x;
		y = y ?? ety.y;

		final opts:DrawSpriteOptions = {
			width: ety.width,
			height: ety.height,
			frame: ety.currentFrameIndex,
			flipX: ety.flipX,
			flipY: ety.flipY,
			scrollX: ety.scrollX,
			scrollY: ety.scrollY,
			wrap: ety.wrap
		};

		switch (ety.offset) {
			case NONE:
				Sprite.sprite(surface, ety.sprite, x, y, opts, ety.colorMap);
			case PIVOT(px, py):
				Sprite.spritePivot(surface, ety.sprite, x, y, px, py, opts, ety.colorMap);
			case ANCHOR(ax, ay):
				Sprite.spriteAnchor(surface, ety.sprite, x, y, ax, ay, opts, ety.colorMap);
		}
	}

	public function render(surface:FrameBuffer) {
		entity(surface, this);
	}
}
