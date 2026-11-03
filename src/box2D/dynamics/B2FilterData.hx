package box2D.dynamics;

import flash.Boot;

class B2FilterData {
	public var maskBits:Int = 0;

	public var groupIndex:Int = 0;

	public var categoryBits:Int = 0;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		categoryBits = 1;
		maskBits = 65535;
		groupIndex = 0;
	}

	public function copy():B2FilterData {
		return Copy();
	}

	public function Copy():B2FilterData {
		var _loc1_ = new B2FilterData();
		_loc1_.categoryBits = categoryBits;
		_loc1_.maskBits = maskBits;
		_loc1_.groupIndex = groupIndex;
		return _loc1_;
	}
}
