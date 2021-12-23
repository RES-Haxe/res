package res.tiles;

import res.ColorMap;

typedef TilePlace = {
	index:Int,
	?flipX:Bool,
	?flipY:Bool,
	?rot90cw:Bool,
	?colorMap:ColorMap,
	?data:Dynamic
}
