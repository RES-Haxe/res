package res.chips.std;

import haxe.Timer;
import res.chips.Chip;
import res.chips.std.console.Console;
import res.chips.std.console.ConsoleChip;
import res.chips.std.console.ConsoleCommand;
import res.text.Text;

using Type;

class FpsDisplaCommand extends ConsoleCommand {
	final fpsDisplay:FpsDisplayChip;

	public function new(fpsDisplay:FpsDisplayChip) {
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

enum FpsDisplayPosition {
	TOP_LEFT;
	TOP_RIGHT;
	BOTTOM_LEFT;
	BOTTOM_RIGHT;
}

class FpsDisplayChip extends Chip {
	public var showFPS:Bool = true;
	public var method:FpsDisplayMethod;
	public var position:FpsDisplayPosition;

	var res:RES;

	var frameCount:Int = 0;
	var time:Float;
	var fpsValue:Float = 0;

	var text:Text;

	public function new(?position:FpsDisplayPosition = TOP_LEFT, ?method:FpsDisplayMethod = PER_SECOND) {
		this.position = position;
		this.method = method;
	}

	public function enable(res:RES) {
		this.res = res;

		text = new Text(res.defaultFont, '');

		time = Timer.stamp();

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

				text.text = 'FPS: ${fpsValue}';

				switch (position) {
					case TOP_LEFT:
						text.x = text.y = 0;
					case TOP_RIGHT:
						text.x = frameBuffer.width - text.width;
						text.y = 0;
					case BOTTOM_LEFT:
						text.x = 0;
						text.y = frameBuffer.height - text.height;
					case BOTTOM_RIGHT:
						text.x = frameBuffer.width - text.width;
						text.y = frameBuffer.height - text.height;
				}

				text.render(frameBuffer);
			}
		});

		if (res.hasChip('res.chips.std.console.ConsoleChip')) {
			var console:Console = cast(res.getChip('res.chips.std.console.ConsoleChip'), ConsoleChip).console;
			console.addCommand(new FpsDisplaCommand(this));
		}
	}
}
