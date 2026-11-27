package brain.render;

import brain.utils.MemoryTracker;

class SortedLayer extends Layer {
	public function new(sortIndex:Int = 0) {
		super(sortIndex);
		MemoryTracker.track(this, "SortedLayer sortIndex=" + sortIndex + " - created in SortedLayer()", "brain");
	}

	override public function render() {
		this.sortLayer();
	}
}
