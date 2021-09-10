package res.types;

import res.Resolution;
import res.features.Feature;
import res.platforms.Platform;
import res.rom.Rom;

typedef RESConfig = {
	platform:Platform,
	resolution:Resolution,
	rom:Rom,
	mainScene:Class<Scene>,
	?features:Array<Class<Feature>>
};
