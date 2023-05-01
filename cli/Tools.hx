package cli;

import Sys.println;
import cli.CLI.error;
import cli.common.CliConfig.getCliConfig;
import sys.io.Process;

using StringTools;

class Tool {
	public final available:Bool;

	public final name:String;
	public final version:Null<String>;

	public final cmdPath:String;
	public final which:String;

	final verboseVersionCheck:Bool;
	final versionArgs:Array<String>;

	public function getVersion():Null<String> {
		try {
			final proc = new Process(cmdPath, versionArgs);
			final output = proc.stdout.readAll().toString().trim();
			final errorOutput = proc.stderr.readAll().toString().trim();
			final exitCode = proc.exitCode(true);

			if (exitCode != 0) {
				if (verboseVersionCheck) {
					println('$name version check failed');
					println('Command: $cmdPath ${versionArgs.join(' ')}');
					println('stdout: $output');
					println('stderr: $errorOutput');
				}
				return null;
			}

			return output;
		} catch (error) {
			if (verboseVersionCheck) {
				println('$name version check failed with an exception:');
				println(error.message);
			}
			return null;
		}
	}

	public function run(args:Array<String>, ?onData:String->Void, ?onError:String->Void, ?printCmd:Bool) {
		if (!available)
			error('$name is not available!');
		return TermProcess.run(cmdPath, args, onData, onError, printCmd);
	}

	public function new(name:String, cmdPath:String, versionArgs:Array<String>, ?parseVersion:String->String, ?verboseVersionCheck:Bool = false) {
		this.name = name;
		this.cmdPath = cmdPath;
		this.versionArgs = versionArgs;
		this.verboseVersionCheck = verboseVersionCheck;
		final versionCheckResult = getVersion();
		this.version = versionCheckResult != null ? parseVersion != null ? parseVersion(versionCheckResult) : versionCheckResult : null;
		this.available = version != null;
		final whichCmd = Sys.systemName() == 'Windows' ? 'where' : 'which';
		this.which = new Process(whichCmd, [cmdPath]).stdout.readAll().toString().trim();
	}
}

class Tools {
	public final neko:Tool;
	public final haxe:Tool;
	public final haxelib:Tool;
	public final hl:Tool;
	public final node:Tool;
	public final npm:Tool;

	public function new(resCli:ResCli) {
		final cliConfig = getCliConfig(resCli);

		function cfgPath(toolName:String):String {
			final cfg_path:String = Reflect.field(cliConfig.tools, toolName);

			if (cfg_path != null)
				return cfg_path;

			return toolName;
		}

		neko = new Tool('Neko VM', cfgPath('neko'), ['-version'], true);
		haxe = new Tool('Haxe Compiler', cfgPath('haxe'), ['--version'], true);
		haxelib = new Tool('Haxelib', cfgPath('haxelib'), ['version'], true);
		hl = new Tool('HashLink VM', cfgPath('hl'), ['--version']);
		node = new Tool('Node.Js', cfgPath('node'), ['-v'], (v) -> v.substr(1));
		npm = new Tool('NPM', cfgPath('npm'), ['-v']);
	}
}
