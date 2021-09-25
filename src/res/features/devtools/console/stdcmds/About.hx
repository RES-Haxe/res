package res.features.devtools.console.stdcmds;

class About extends ConsoleCommand {
	public function new() {
		super('about', 'About RES');
	}

	override function run(args:Array<String>, res:RES, console:Console) {
		console.println('Version:');
		console.println(' ${RES.VERSION}');

		console.println('Platform:');
		console.println(' ${res.platform.name}');

		console.println('Resolution:');
		console.println(' ${res.frameBuffer.frameWidth}x${res.frameBuffer.frameHeight}');

		console.println('Palette:');
		console.println(' ${res.rom.palette.colors.length} colors');
	}
}
