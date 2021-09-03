package res.features.devtools;

import res.tiles.Tilemap;

class FpsDisplay implements Feature {
	public var showFPS:Bool = false;

	var res:RES;

	public function new() {}

	public function enable(res:RES) {
		this.res = res;

		final text = res.createTextmap();

		res.renderHooks.after.push((res, frameBuffer) -> {
			if (showFPS && res.lastFrameTime != 0) {
				text.textAt(0, 0, 'FPS: ${1 / res.lastFrameTime}');
				Tilemap.drawTilemap(text, frameBuffer);
			}
		});

		#if !hl
		if (res.hasFeature(Console)) {
			final console = res.feature(Console).console;
			console.addCommand('fps', (args) -> {
				if (args.length > 0)
					showFPS = ['true', '1'].indexOf(args[0].toLowerCase()) != -1;
				else
					showFPS = !showFPS;
			});
		}
		#else
		trace("For whatever reason fails on hl???");
		#end
	}
}
