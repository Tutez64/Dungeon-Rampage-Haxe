package brain.utils;

class Tuple {
	var mFirst:ASAny;

	var mSecond:ASAny;

	public function new(first:ASAny, second:ASAny) {
		mFirst = first;
		mSecond = second;
	}

	@:isVar public var first(get, never):ASAny;

	public function get_first():ASAny {
		return mFirst;
	}

	@:isVar public var second(get, never):ASAny;

	public function get_second():ASAny {
		return mSecond;
	}
}
