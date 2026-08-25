package uI.map;

class UIMapAvatarDropMover implements UIMapAvatarMover {
	var mUpdatePosition:ASFunction;

	public function new(updatePosition:ASFunction) {
		mUpdatePosition = updatePosition;
	}

	public function moveTo(x:Float, y:Float) {
		mUpdatePosition(x, y);
	}

	public function destroy() {}
}
