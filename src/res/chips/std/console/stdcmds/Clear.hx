package res.chips.std.console.stdcmds;

class Clear extends ConsoleCommand {
	var consoleScene:ConsoleScene;

	public function new(consoleScene:ConsoleScene) {
		super('clear', 'Clear console');

		this.consoleScene = consoleScene;
	}

	override function run(args:Array<String>, res:RES, console:Console) {
		consoleScene.clear();
	}
}
