package res.timeline;

using Lambda;

class Timeline implements Updateable {
	var totalTime:Float = 0;

	var events:Array<TimelineEvent> = [];

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

	public function every(time:Float, callback:TimelineCallback, ?repeats:Int = -1) {
		var event = add(time, repeats, callback);
		return event;
	}

	public function cancel(event:TimelineEvent) {
		events.remove(event);
	}

	public function update(dt:Float) {
		for (event in events) {
			if (event.runAt <= totalTime) {
				final late = totalTime - event.runAt;
				event.callback(late);

				if (event.repeats == -1 || --event.repeats > 0) {
					event.runAt = totalTime + event.interval - late;
				} else {
					events.remove(event);
				}
			}
		}

		totalTime += dt;
	}
}
