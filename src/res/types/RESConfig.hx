package res.types;

import res.Resolution;
import res.features.Feature;
import res.rom.Rom;

typedef RESConfig = {
	resolution:Resolution,
	rom:Rom,
	?main:Void->Scene,
	?features:Array<Class<Feature>>
};
