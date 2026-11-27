package brain.utils;

class Receipt {
	var mUnregisterFunction:ASFunction;

	public function new(unregisterDelegate:ASFunction) {
		mUnregisterFunction = unregisterDelegate;
	}

	public function exit() {
		mUnregisterFunction();
	}
}
