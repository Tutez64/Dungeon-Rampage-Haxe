package starling.errors;

class AbstractMethodError extends Error {
	public function new(message:ASAny = "Method needs to be implemented in subclass", id:ASAny = 0) {
		super(message, id);
	}
}
