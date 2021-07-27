package res.tween;

using Reflect;

class Tween implements Updateable {
	private final target:Dynamic;
	private final fromProps:Dynamic;
	private final toProps:Dynamic;
	private final totalTime:Float;

	var time:Float = 0;
	var props:Array<String>;
	var _done:Bool = false;
	var doneCb:Void->Void;

	public var done(get, never):Bool;

	function get_done():Bool {
		return _done;
	}

	@:allow(res.tween)
	private function new(target:Dynamic, fromProps:Dynamic, toProps:Dynamic, totalTime:Float) {
		this.target = target;
		this.fromProps = fromProps;
		this.toProps = toProps;
		this.totalTime = totalTime;

		this.props = Reflect.fields(fromProps);
	}

	public function then(cb:Void->Void) {
		doneCb = cb;
	}

	function setValues(t:Float) {
		for (prop in props) {
			final from = fromProps.field(prop);
			final to = toProps.field(prop);
			target.setProperty(prop, from + (to - from) * t);
		}
	}

	public function update(dt:Float) {
		if (!_done) {
			if (time >= totalTime) {
				setValues(1);
				_done = true;
				if (doneCb != null)
					doneCb();
			} else {
				setValues(time / totalTime);
				time += dt;
			}
		}
	}
}
