package res.platforms;

interface Platform {
	function connect(res:Res):Void;

	function render(res:Res):Void;
}
