package starling.display;

final class MaskRole {
	public function new() {}

	public static function isMask(object:DisplayObject):Bool {
		return object.isMask;
	}
}
