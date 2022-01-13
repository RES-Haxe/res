package res.tools;

class RndTools {
	public static function oneof<T>(arr:Array<T>):T {
		return arr[Math.floor(Math.random() * arr.length)];
	}
}
