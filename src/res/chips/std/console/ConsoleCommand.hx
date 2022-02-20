package res.chips.std.console;

class ConsoleCommand {
	public final command:String;
	public final info:String;

	public function new(command:String, info:String) {
		this.command = command;
		this.info = info;
	}

	public function run(args:Array<String>, res:RES, console:Console) {
		console.println('$command is not implemented');
	}
}
