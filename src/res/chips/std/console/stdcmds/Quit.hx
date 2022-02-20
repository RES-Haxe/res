package res.chips.std.console.stdcmds;

class Quit extends ConsoleCommand {
	public function new() {
		super('quit', 'Terminate the programm');
	}

	override function run(args:Array<String>, res:RES, console:Console) {
		res.poweroff();
	}
}
