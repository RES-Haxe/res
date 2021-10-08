package res.features.devtools;

import haxe.Timer;
import res.features.devtools.console.Console;
import res.features.devtools.console.ConsoleCommand;
import res.features.devtools.console.ConsoleFeature;
import res.tiles.Tilemap;

using Type;

class FpsDisplaCommand extends ConsoleCommand {
	final fpsDisplay:FpsDisplay;

	public function new(fpsDisplay:FpsDisplay) {
		super('fps', 'Toggle fps display');

		this.fpsDisplay = fpsDisplay;
	}

	override function run(args:Array<String>, res:RES, console:Console) {
		if (args.length > 0)
			fpsDisplay.showFPS = ['true', '1'].indexOf(args[0].toLowerCase()) != -1;
		else
			fpsDisplay.showFPS = !fpsDisplay.showFPS;
	}
}

enum FpsDisplayMethod {
	PER_SECOND;
	DELTA_EXTRAPOLATION;
}

class FpsDisplay implements Feature {
	public var showFPS:Bool = false;
	public var method:FpsDisplayMethod = PER_SECOND;

	var res:RES;

	var frameCount:Int = 0;
	var time:Float;
	var fpsValue:Float = 0;

	public function new() {}

	public function enable(res:RES) {
		this.res = res;

		time = Timer.stamp();

		final text = res.createTextmap();

		res.renderHooks.after.push((res, frameBuffer) -> {
			if (showFPS && res.lastFrameTime != 0) {
				switch (method) {
					case PER_SECOND:
						frameCount++;

						final currentTime = Timer.stamp();

						if (currentTime - time >= 1) {
							fpsValue = frameCount;
							frameCount = 0;
							time = currentTime;
						}
					case DELTA_EXTRAPOLATION:
						fpsValue = Math.round((1 / res.lastFrameTime) * 100) / 100;
				}

				text.textAt(0, 0, 'FPS: ${fpsValue}');
				Tilemap.drawTilemap(text, frameBuffer, 1, 1);
			}
		});

		if (res.hasFeature('res.features.devtools.console.ConsoleFeature')) {
			var console:Console = cast(res.getFeature('res.features.devtools.console.ConsoleFeature'), ConsoleFeature).console;
			console.addCommand(new FpsDisplaCommand(this));
		}
	}
}
