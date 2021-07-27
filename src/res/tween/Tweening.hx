package res.tween;

using Reflect;

class Tweening implements Updateable {
	private final tweens:Array<Tween> = [];

	public function new() {}

	public function to(target:Dynamic, toProps:Dynamic, time:Float):Tween {
		var fromProps:Dynamic = {};

		for (prop in toProps.fields()) {
			fromProps.setField(prop, target.getProperty(prop));
		}

		final tween = new Tween(target, fromProps, toProps, time);

		tweens.push(tween);

		return tween;
	}

	public function update(dt:Float) {
		for (tween in tweens) {
			if (tween.done) {
				tweens.remove(tween);
			} else
				tween.update(dt);
		}
	}
}
