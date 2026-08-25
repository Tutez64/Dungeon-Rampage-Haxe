package brain.utils;

class MemoryUtil {
	public function new() {}

	public static function pauseForGCWithLogging(logPrefix:String = "", collectionProbabilityThreshold:Float = 0.25) {
		ASCompat.pauseForGCIfCollectionImminent(collectionProbabilityThreshold);
	}
}
