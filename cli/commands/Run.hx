package cli.commands;

import Sys.command;
import Sys.println;
import cli.CLI.error;
import cli.Command;
import cli.commands.common.PlatformArg.platformArg;
import cli.common.ProjectConfig.getProjectConfig;
import cli.types.ResProjectConfig.PlatformId;

class Run extends Command {
	public function description()
		return "Run the project";

	public function expectedArgs(resCli)
		return [
			platformArg
		];

	function run(args:Map<String, String>) {
		resCli.commands['build'].run(args);

		final platform:PlatformId = cast args['platform'];
		final config = getProjectConfig(resCli);

		println('Run ${config.name}');

		switch (platform) {
			case hl:
				if (!resCli.tools.hl.available)
					return error('${resCli.tools.hl.name} is not available');

				final exitCode = command('hl', ['${config.build.path}/hl/hlboot.dat']);

				if (exitCode != 0)
					return error('Run failed');

			case js:
				if (!resCli.tools.node.available)
					return error('${resCli.tools.node.name} is not available');
				resCli.tools.npm.run(['start'], (s) -> println(s), (s) -> println(s), true);
			case _:
		}

		println('');
	}
}
