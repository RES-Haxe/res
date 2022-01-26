package res.features.devtools.console.stdcmds;

class About extends ConsoleCommand {
	public function new() {
		super('about', 'About RES');
	}

	override function run(args:Array<String>, res:RES, console:Console) {
		console.println('Version:');
		console.println(' ${RES.VERSION}');

		console.println('BIOS:');
		console.println(' ${res.bios.name}');

		console.println('Resolution:');
		console.println(' ${res.frameBuffer.width}x${res.frameBuffer.height}');

		console.println('Palette:');
		console.println(' ${res.rom.palette.colors.length - 1} colors');
	}
}
