package res.chips.std.console.stdcmds;

class Help extends ConsoleCommand {
	public function new() {
		super('help', 'Commands help');
	}

	override function run(args:Array<String>, res:RES, console:Console) {
		for (cmdName => cmd in console.commands) {
			console.println('$cmdName:');
			console.println(' ${cmd.info}');
		}
	}
}
