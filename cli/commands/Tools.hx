package cli.commands;

import cli.CLI.Argument;
import cli.CLI.printTable;

class Tools extends Command {
	public function description():String
		return "Tools Information";

	public function expectedArgs(resCli):Array<Argument>
		return [];

	public function run(args:Map<String, String>) {
		final allTools = [
			resCli.tools.res,
			resCli.tools.haxe,
			resCli.tools.haxelib,
			resCli.tools.hl,
			resCli.tools.node,
			resCli.tools.npm,
			resCli.tools.neko,
		];

		printTable([['Tool', 'Command', 'Version', 'Which']].concat([
			for (tl in allTools) {
				final version = tl.getVersion();
				[tl.name, tl.cmdPath, version != null ? version : 'N/A', tl.which()];
			}
		]), 1, ' |', true);
	}
}
