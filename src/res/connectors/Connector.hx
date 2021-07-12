package res.connectors;

interface Connector {
	function connect(res:Res):Void;

	function render(res:Res):Void;
}
