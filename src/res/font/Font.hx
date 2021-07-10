package res.font;

class Font {
	public final name:String;
	public final tileset:Tileset;
	public final characters:String;

	@:allow(res)
	private inline function new(res:Res, name:String, tileset:Tileset, characters:String) {
		this.name = name;
		this.tileset = tileset;
		this.characters = characters;
	}
}
