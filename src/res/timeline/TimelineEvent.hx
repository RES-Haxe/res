package res.timeline;

class TimelineEvent {
	public var interval:Float;
	public var repeats:Int;
	public var callback:TimelineCallback;
	public var runAt:Float;

	@:allow(res.timeline.Timeline)
	private inline function new(interval:Float = 1, repeats:Int = 1, callback:TimelineCallback) {
		this.interval = interval;
		this.repeats = repeats;
		this.callback = callback;
	}
}
