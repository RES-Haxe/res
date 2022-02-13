package res.display;

import res.display.Sprite.SpriteAnimation;
import res.display.Sprite.SpriteFrame;

using Math;
using res.tools.BytesTools;

@:enum abstract ObjectAnimDirection(Int) from Int to Int {
	var Forward = 0;
	var Backwards = 1;
	var PingPong = 2;
}

enum PingPongCycle {
	F;
	B;
}

/**
	Stateful Sprite Object
 */
class SpriteObject extends Object {
	public var flipX:Bool = false;
	public var flipY:Bool = false;

	public var playing:Bool = false;

	public var loop:Bool = true;

	public var priority:Null<Int> = null;

	public final sprite:Sprite;

	public var wrap:Bool = false;

	public var currentFrame(get, never):SpriteFrame;

	function get_currentFrame():SpriteFrame
		return sprite.frames[currentFrameIndex];

	var frameTime:Float = 0;

	public var currentFrameIndex:Int = 0;

	var _pingPongCycle:PingPongCycle = F;

	var _animation:SpriteAnimation;
	var _currentAnimationName:String;

	public var currentAnimaionName(get, never):String;

	function get_currentAnimaionName()
		return _currentAnimationName;

	/** Total current animation time in seconds **/
	public var totalAnimationTime(get, never):Float;

	function get_totalAnimationTime() {
		var result:Float = 0;

		for (f in _animation.from..._animation.to + 1)
			result += (sprite.frames[f].duration / 1000);

		return result;
	}

	public function new(sprite:Sprite, ?colorMap:ColorMap) {
		this.sprite = sprite;
		this.colorMap = colorMap;

		width = sprite.width;
		height = sprite.height;

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
				frameTime = 0;
				currentFrameIndex = anim.from;

				if (anim.direction == PingPong)
					_pingPongCycle = F;
			}

			_animation = anim;
			_currentAnimationName = name;
		} else
			trace('No animation named <$name>');
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

	override public function update(dt:Float) {
		super.update(dt);

		if (sprite != null && playing) {
			final currentFrameDuration = (currentFrame.duration / 1000);

			while (frameTime > currentFrameDuration) {
				frameTime -= currentFrameDuration;

				nextFrame();
			}

			frameTime += dt;
		}
	}

	override function selfRender(frameBuffer:FrameBuffer, atx:Float, aty:Float)
		drawSpriteObject(frameBuffer, this, atx, aty);

	public static function drawSpriteObject(frameBuffer:FrameBuffer, spriteObject:SpriteObject, ?x:Float, ?y:Float) {
		Sprite.drawSprite(frameBuffer, spriteObject.sprite, x != null ? x.floor() : spriteObject.x.floor(), y != null ? y.floor() : spriteObject.y.floor(), {
			width: spriteObject.width.floor(),
			height: spriteObject.height.floor(),
			frame: spriteObject.currentFrameIndex,
			flipX: spriteObject.flipX,
			flipY: spriteObject.flipY,
			wrap: spriteObject.wrap
		});
	}
}
