package res.features.devtools.console;

import res.features.Feature;
import res.features.devtools.console.stdcmds.About;
import res.features.devtools.console.stdcmds.Clear;
import res.features.devtools.console.stdcmds.Help;
import res.features.devtools.console.stdcmds.LSRom;
import res.features.devtools.console.stdcmds.Quit;

using String;
using StringTools;

class ConsoleFeature implements Feature {
	var shown:Bool = false;
	var res:RES;

	public var consoleScene:ConsoleScene;

	public var console:Console;

	public function toggle() {
		if (shown)
			res.popScene();
		else
			res.setScene(consoleScene);

		shown = !shown;
	}

	public function enable(res:RES) {
		this.res = res;

		console = new Console(res);
		consoleScene = new ConsoleScene(res, console);

		console.addCommand(new About());
		console.addCommand(new Clear(consoleScene));
		console.addCommand(new Help());
		console.addCommand(new Quit());
		console.addCommand(new LSRom());

		res.keyboard.listen((ev) -> {
			switch (ev) {
				case KEY_PRESS(charCode):
					if (String.fromCharCode(charCode) == '`') toggle();
				case _:
			}
		});
	}
}
