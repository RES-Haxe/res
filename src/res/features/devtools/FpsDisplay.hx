package res.features.devtools;

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

class FpsDisplay implements Feature {
	public var showFPS:Bool = false;

	var res:RES;

	public function new() {}

	public function enable(res:RES) {
		this.res = res;

		final text = res.createTextmap([res.rom.palette.darkestIndex, res.rom.palette.brightestIndex]);

		res.renderHooks.after.push((res, frameBuffer) -> {
			if (showFPS && res.lastFrameTime != 0) {
				final fpsValue:Float = Math.round((1 / res.lastFrameTime) * 100) / 100;
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
