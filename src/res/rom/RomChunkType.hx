package res.rom;

enum abstract RomChunkType(Int) from Int to Int {
	var PALETTE = 0x00;
	var TILESET = 0x01;
	var TILEMAP = 0x02;
	var SPRITE = 0x03;
	var FONT = 0x04;
	var DATA = 0x05;
	var AUDIO = 0x06;
}
