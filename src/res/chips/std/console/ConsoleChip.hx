package res.chips.std.console;

import res.chips.Chip;
import res.chips.std.console.stdcmds.About;
import res.chips.std.console.stdcmds.Clear;
import res.chips.std.console.stdcmds.Help;
import res.chips.std.console.stdcmds.LSRom;
import res.chips.std.console.stdcmds.Quit;

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
		consoleState = new ConsoleState(console);

		console.addCommand(new About());
		console.addCommand(new Clear(consoleState));
		console.addCommand(new Help());
		console.addCommand(new Quit());
		console.addCommand(new LSRom());

		res.keyboard.listen((ev) -> {
			switch (ev) {
				case INPUT(text):
					if (text == '`') toggle();
				case _:
			}
		});
	}
}
