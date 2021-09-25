package res.platforms.heaps;

import hxd.App;
import res.types.RESConfig;

class HeapsRESApp extends App {
	var config:RESConfig;

	var res:RES;

	public function new(config:RESConfig) {
		super();
		this.config = config;
	}

	override function init() {
		config.platform = new HeapsPlatform(s2d);
		res = RES.boot(config);
	}

	override function update(dt:Float) {
		res.update(dt);
		res.render();
	}
}
