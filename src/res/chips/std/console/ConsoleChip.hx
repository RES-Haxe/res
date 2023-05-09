package res.chips.std.console;

import res.chips.Chip;
import res.chips.std.console.stdcmds.About;
import res.chips.std.console.stdcmds.Clear;
import res.chips.std.console.stdcmds.Help;
import res.chips.std.console.stdcmds.LSRom;
import res.chips.std.console.stdcmds.Quit;
import res.chips.std.console.stdcmds.Reset;

using String;
using StringTools;

class ConsoleChip extends Chip {
	var res:RES;

	public var consoleState:ConsoleState;

	public var console:Console;

	public function toggle() {
		if (consoleState.isActive())
			consoleState.rollUp();
		else {
			consoleState.rollDown(res.state);
			res.setState(consoleState);
		}
	}

	public function new() {}

	public function enable(res:RES) {
		this.res = res;

		console = new Console(res);

		console.addCommand(new About());
		console.addCommand(new Help());
		console.addCommand(new LSRom());
		console.addCommand(new Quit());
		console.addCommand(new Reset());

		res.keyboard.listen((ev) -> {
			switch (ev) {
				case INPUT(text):
					if (text == '`') toggle();
				case _:
			}
		});

		reset();
	}

	override function reset() {
		consoleState = new ConsoleState(res, console);
		console.addCommand(new Clear(consoleState));
	}
}
