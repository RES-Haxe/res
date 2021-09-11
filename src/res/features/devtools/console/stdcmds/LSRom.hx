package res.features.devtools.console.stdcmds;

class LSRom extends ConsoleCommand {
	public function new() {
		super('lsrom', 'List contents of the ROM');
	}

	override function run(args:Array<String>, res:RES, console:Console) {
		for (field in ['audio', 'sprites', 'tilesets', 'tilemaps', 'fonts', 'data']) {
			final map:Map<String, Any> = cast Reflect.getProperty(res.rom, field);
			final cnt:Int = Lambda.count(map);

			if (cnt > 0) {
				console.println('$field ($cnt)');
				for (itemName => item in map) {
					console.println(' $itemName');
				}
			}
		}
	}
}
