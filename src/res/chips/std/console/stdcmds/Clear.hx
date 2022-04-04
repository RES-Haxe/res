package res.chips.std.console.stdcmds;

class Clear extends ConsoleCommand {
	var consoleState:ConsoleState;

	public function new(consoleState:ConsoleState) {
		super('clear', 'Clear console');

		this.consoleState = consoleState;
	}

	override function run(args:Array<String>, res:RES, console:Console) {
		consoleState.clear();
	}
}
