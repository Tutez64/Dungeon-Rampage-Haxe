package starling.errors;

class MissingContextError extends Error {
	public function new(message:ASAny = "Starling context is missing", id:ASAny = 0) {
		super(message, id);
	}
}
