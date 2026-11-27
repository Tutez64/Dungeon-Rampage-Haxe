package brain.clock;

class RenderClock extends GameClock {
	var mHasBaseline:Bool = false;

	public function new() {
		super(0);
	}

	override public function update():Float {
		if (!mHasBaseline) {
			initTime();
		}
		var _loc1_ = Math.max(0, super.update());
		mTickLength = _loc1_ / timeScale;
		return _loc1_;
	}

	override public function initTime() {
		super.initTime();
		mHasBaseline = true;
		mTickLength = 0;
	}
}
