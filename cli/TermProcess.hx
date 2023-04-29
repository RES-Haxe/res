package cli;

import sys.io.Process;
import sys.thread.Thread;

enum ProcEvent {
	Text(string:String);
	Error(string:String);
	Exit;
}

function run(cmd:String, args:Array<String>, ?onData:String->Void, ?onError:String->Void, ?printCmd:Bool = false) {
	if (printCmd)
		Sys.println('$cmd ${args.join(' ')}');

	final mainThread = Thread.current();

	onData = onData == null ?(s) -> Sys.stdout().writeString('$s\n') : onData;
	onError = onError == null ?(s) -> Sys.stderr().writeString('$s\n') : onError;

	final proc = new Process(cmd, args);

	Thread.create(() -> {
		try {
			while (true) {
				final line = proc.stdout.readLine();
				mainThread.sendMessage(ProcEvent.Text(line));
			}
		} catch (err) {
			mainThread.sendMessage(ProcEvent.Exit);
		}
	});

	Thread.create(() -> {
		try {
			while (true) {
				final line = proc.stderr.readLine();
				mainThread.sendMessage(ProcEvent.Error(line));
			}
		} catch (err) {}
	});

	while (true) {
		final msg:ProcEvent = cast Thread.readMessage(true);

		switch (msg) {
			case Text(string):
				if (onData != null)
					onData(string);
			case Error(string):
				if (onError != null)
					onError(string);
			case Exit:
				return proc.exitCode();
		}
	}

	return 0;
}
