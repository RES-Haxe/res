package cli.commands;

import Sys.print;
import Sys.println;
import cli.CLI.Argument;
import cli.CLI.error;
import cli.Command;
import cli.Hxml.writeHxmlFile;
import cli.common.ProjectConfig.getProjectConfig;
import cli.types.ResProjectConfig.PlatformId;

class Build extends Command {
	public function description()
		return "Build the project";

	public function expectedArgs(resCli):Array<Argument>
		return [
			{
				name: 'platform',
				desc: 'Platform to build the project',
				requred: true,
				defaultValue: (?prev) -> 'hl',
				type: ENUM(['hl', 'js']),
				interactive: true,
				example: 'hl'
			}
		];

	public function run(args:Map<String, String>) {
		if (['hl', 'js'].indexOf(args['platform']) == -1)
			error('Unsupported platform: "${args['platform']}" (available: hl, js)');
		final platform:PlatformId = cast args['platform'];
		final config = getProjectConfig(resCli);

		final hxmlFile = writeHxmlFile(resCli, config, platform);

		Sys.setCwd(resCli.workingDir);

		print('Build: ');
		final exitCode = resCli.tools.haxe.run([hxmlFile], (s) -> {}, (err) -> {
			Sys.stderr().writeString('$err\n');
		}, true);
		println('');

		if (exitCode != 0)
			return error('Build failed');
	}
}
