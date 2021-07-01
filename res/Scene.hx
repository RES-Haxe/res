package res;

class Scene {
	public final renderList:Array<Renderable> = [];

	public function new(?initialList:Array<Renderable>) {
		if (initialList != null)
			for (item in initialList)
				renderList.push(item);
	}

	public function update(dt:Float) {}
}
