package res.tiles;

import res.IndexMap;

typedef TilePlace = {
	index:Int,
	?flipX:Bool,
	?flipY:Bool,
	?rot90cw:Bool,
	?colorMap:IndexMap,
	?data:Dynamic
}
