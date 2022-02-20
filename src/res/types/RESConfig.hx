package res.types;

import res.Resolution;
import res.chips.Chip;
import res.rom.Rom;

typedef RESConfig = {
	resolution:Resolution,
	rom:Rom,
	?main:Void->Scene,
	?chips:Array<Class<Chip>>
};
