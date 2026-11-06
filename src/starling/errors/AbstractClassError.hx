package starling.errors;

class AbstractClassError extends Error {
	public function new(message:ASAny = "Cannot instantiate abstract class", id:ASAny = 0) {
		super(message, id);
	}
}
