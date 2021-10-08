package res.platforms.heaps;

import hxd.App;
import res.types.RESConfig;

class HeapsRESApp extends App {
	var config:RESConfig;

	public var res:RES;

	public function new(config:RESConfig) {
		super();
		this.config = config;
	}

	override function init() {
		res = RES.boot(new HeapsPlatform(s2d), config);
	}

	override function update(dt:Float) {
		res.update(dt);
		res.render();
	}
}
