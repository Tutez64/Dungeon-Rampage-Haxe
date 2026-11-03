package starling.errors;

class NotSupportedError extends Error {
	public function new(message:ASAny = "", id:ASAny = 0) {
		super(message, id);
	}
}
