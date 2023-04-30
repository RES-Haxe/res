import cli.ResCli;
import haxe.io.Path;

class Run {
	static function main() {
		final args = Sys.args();
		final cmdArgs = args.slice(0, -1);
		final cwd = args.pop();
		final baseDir = Path.directory(Sys.programPath());
		Sys.setCwd(cwd);
		new ResCli(cmdArgs, baseDir).run();
	}
}
