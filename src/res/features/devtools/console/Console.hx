package res.features.devtools.console;

using StringTools;

class Console {
	public final commands:Map<String, ConsoleCommand> = [];

	final res:RES;

	public function new(res:RES) {
		this.res = res;
	}

	public function addCommand(cmd:ConsoleCommand) {
		commands[cmd.command] = cmd;
	}

	public dynamic function println(s:String) {}

	public function run(cmdStr:String) {
		var args = cmdStr.split(' ').map(s -> s.trim()).filter(s -> s != '');

		var cmd = args.shift();

		if (commands[cmd] != null) {
			commands[cmd].run(args, res, this);
		} else {
			println('Unknown command \'$cmd\'');
		}
	}
}
