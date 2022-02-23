package res.types;

import res.RES;
import res.Resolution;
import res.chips.Chip;
import res.display.FrameBuffer;
import res.rom.Rom;

typedef RESConfig = {
	resolution:Resolution,
	rom:Rom,
	?main:RES -> {
		function render(fb:FrameBuffer):Void;
		function update(dt:Float):Void;
	},
	?chips:Array<Class<Chip>>
};
