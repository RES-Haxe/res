import cli.ResCli;

class Run {
	static function main() {
		final args = Sys.args();
		new ResCli(args.slice(0, -1), args.pop()).run();
	}
}
