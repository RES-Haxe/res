package res;

using Lambda;

class TimelineEvent {
	public var interval:Float;
	public var repeats:Int;
	public var callback:TimelineCallback;
	public var runAt:Float;

	@:allow(res.Timeline)
	private inline function new(interval:Float = 1, repeats:Int = 1, callback:TimelineCallback) {
		this.interval = interval;
		this.repeats = repeats;
		this.callback = callback;
	}
}

typedef TimelineCallback = Float->Void;

class Timeline {
	var totalTime:Float = 0;

	final events:Array<TimelineEvent> = [];

	final forWhileItems:Array<{
		totalTime:Float,
		time:Float,
		callback:(Float, Float) -> Void,
		?done:() -> Void
	}> = [];

	public function new() {}

	public function add(interval:Float, repeats:Int, callback:TimelineCallback):TimelineEvent {
		var event = new TimelineEvent(interval, repeats, callback);
		event.runAt = totalTime + interval;
		events.push(event);
		return event;
	}

	public function after(seconds:Float, callback:TimelineCallback) {
		var event = add(seconds, 1, callback);
		return event;
	}

	public function cancel(event:TimelineEvent) {
		events.remove(event);
	}

	public function every(time:Float, callback:TimelineCallback, ?repeats:Int = -1, ?startImmediately:Bool = false) {
		if (startImmediately) {
			callback(0);
			repeats--;
		}
		var event = add(time, repeats, callback);
		return event;
	}

	/**
		The callback will be executed on every update for the set period of time

		@param time
	 */
	public function forWhile(time:Float, callback:(time:Float, totalTime:Float) -> Void, ?done:() -> Void) {
		forWhileItems.push({
			totalTime: time,
			time: 0,
			callback: callback,
			done: done
		});
	}

	public function update(dt:Float) {
		for (event in events) {
			if (event.runAt <= totalTime) {
				final late = totalTime - event.runAt;
				event.callback(late);

				if (event.repeats < 0 || --event.repeats > 0) {
					event.runAt = totalTime + event.interval - late;
				} else {
					events.remove(event);
				}
			}
		}

		for (fwe in forWhileItems) {
			fwe.callback(fwe.time, fwe.totalTime);

			if (fwe.time >= fwe.totalTime) {
				if (fwe.done != null)
					fwe.done();
				forWhileItems.remove(fwe);
			} else {
				fwe.time = Math.min(fwe.totalTime, fwe.time + dt);
			}
		}

		totalTime += dt;
	}
}
