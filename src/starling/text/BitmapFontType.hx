package starling.text;

import starling.errors.AbstractClassError;

class BitmapFontType {
	public static inline final STANDARD = "standard";

	public static inline final DISTANCE_FIELD = "distanceField";

	public static inline final MULTI_CHANNEL_DISTANCE_FIELD = "multiChannelDistanceField";

	public function new() {
		throw new AbstractClassError();
	}
}
