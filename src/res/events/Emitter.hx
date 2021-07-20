package res.events;

class Emitter<T> {
	public final listeners:Array<T->Void> = [];

	public function emit(e:T) {
		for (listener in listeners)
			listener(e);
	}

	public function listen(cb:T->Void) {
		listeners.push(cb);
	}
}
