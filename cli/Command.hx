package cli;

import cli.CLI.Argument;

abstract class Command {
	final resCli:ResCli;

	public function new(resCli:ResCli) {
		this.resCli = resCli;
	}

	abstract public function description():String;

	abstract public function expectedArgs(resCli:ResCli):Array<Argument>;

	abstract public function run(args:Map<String, String>):Void;
}
