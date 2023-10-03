package cli.commands;

import Sys.print;
import Sys.println;
import cli.CLI.Argument;
import cli.CLI.error;
import cli.CLI.printWrapped;
import haxe.SysTools;

using Lambda;
using StringTools;

class Help extends Command {
	function description():String
		return 'RES CLI help';

	function expectedArgs(resCli:ResCli):Array<Argument>
		return [
			{
				name: 'command',
				type: STRING,
				defaultValue: (?prev) -> null,
				requred: false,
				interactive: false,
				desc: 'Command to show help about. If not specified help for all the commands will be shown',
				example: 'help'
			}
		];

	function run(args:Map<String, String>) {
		final arg_command = args['command'];
		final show_only:String = if (arg_command != null) {
			if (!resCli.commands.exists(arg_command)) {
				error('Unknown command <${arg_command}>');
				null;
			}

			arg_command;
		} else null;

		println('${this.description()}:');
		println('');
		println('  Usage: res [command] [arguments]');
		println('');
		println('CONFIGURATION:');
		println('  RES Base : ${resCli.baseDir}');
		println('      Where RES code is located)');
		println('');
		println('  RES Home : ${resCli.resHomeDir}');
		println('      Where RES keeps the configuration and runtime files');
		println('');
		println('COMMANDS:');
		println('');

		var longest_param_name:Int = 0;
		for (cmd => command in resCli.commands)
			for (arg in command.expectedArgs(resCli))
				if (show_only == null || show_only == cmd)
					longest_param_name = Std.int(Math.max(longest_param_name, arg.name.length));
		final arg_desc_pad = longest_param_name + 7;

		for (cmd => command in resCli.commands) {
			if (show_only != null && cmd != show_only)
				continue;
			println('$cmd:');
			printWrapped(command.description(), 2);
			println('');

			if (command.expectedArgs(resCli).length > 0) {
				println('  ARGUMENTS:');

				if (command.expectedArgs(resCli).length > 0) {
					for (arg in command.expectedArgs(resCli)) {
						print('    ${arg.name.rpad(' ', longest_param_name)} : ');
						printWrapped('${arg.requred || arg.defaultValue == null ? '' : '[optional] '}${arg.desc}', arg_desc_pad, true);
						if (arg.defaultValue != null && arg.defaultValue() != null)
							printWrapped('Default: ${arg.defaultValue()}', arg_desc_pad);
					}
				}
			}

			println('  EXAMPLE:');
			println('    res $cmd ${command.expectedArgs(resCli).filter(a -> a.example != null).map(a -> a.example).map(a -> Sys.systemName() == 'Windows' ? SysTools.quoteWinArg(a, false) : SysTools.quoteUnixArg(a)).join(' ')}'.rtrim());
			println('');
		}
	}
}
