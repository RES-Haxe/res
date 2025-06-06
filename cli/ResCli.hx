package cli;

import cli.CLI.error;
import cli.CLI.getArguments;
import cli.OS.getHomeDir;
import cli.commands.Bootstrap;
import cli.commands.Build;
import cli.commands.Dist;
import cli.commands.Help;
import cli.commands.New;
import cli.commands.Run;
import cli.commands.Setup;
import cli.commands.Tools;
import cli.commands.Version;
import haxe.io.Path;

final CLI_CONFIG_FILENAME:String = '.res-cli.json';

class ResCli {
	public final commands:Map<String, Command>;
	public final command:Command;
	public final cmdArgs:Map<String, String>;
	public final tools:cli.Tools;
	public final baseDir:String;
	public final resHomeDir:String;

	public function new(args:Array<String>, baseDir:String) {
		resHomeDir = Path.join([getHomeDir(), '.res']);

		this.baseDir = baseDir;

		final osname = Sys.systemName().toLowerCase();
		final PATH = Sys.getEnv('PATH');
		final addPath = [PATH];

		addPath.push(Path.join([resHomeDir, 'bin', 'runtime', 'hl', cli.commands.Setup.HL_VERSION]));

		Sys.putEnv('PATH', addPath.join(osname == 'windows' ? ';' : ':'));

		tools = new cli.Tools(this);

		commands = [
			'bootstrap' => new Bootstrap(this),
			'build' => new Build(this),
			'dist' => new Dist(this),
			'help' => new Help(this),
			'new' => new New(this),
			'run' => new Run(this),
			'setup' => new Setup(this),
			'tools' => new Tools(this),
			'version' => new Version(this),
		];

		final cmdName = args.length > 0 ? args.shift().toLowerCase() : 'help';

		if (commands.exists(cmdName))
			command = commands[cmdName];
		else
			error('No such command: ${cmdName}');

		cmdArgs = getArguments(args, command.expectedArgs(this));
	}

	public function run() {
		command.run(cmdArgs);
	}
}
