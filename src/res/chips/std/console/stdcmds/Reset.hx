package res.chips.std.console.stdcmds;

class Reset extends ConsoleCommand {
	public function new() {
		super('reset', 'Reset the current RES program');
	}

	override function run(args:Array<String>, res:RES, console:Console) {
		res.reset();
	}
}
