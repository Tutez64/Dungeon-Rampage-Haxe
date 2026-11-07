package starling.events;

import starling.errors.AbstractClassError;

final class TouchPhase {
	public static inline final HOVER = "hover";

	public static inline final BEGAN = "began";

	public static inline final MOVED = "moved";

	public static inline final STATIONARY = "stationary";

	public static inline final ENDED = "ended";

	public function new() {
		throw new AbstractClassError();
	}
}
