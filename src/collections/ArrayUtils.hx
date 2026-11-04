package collections;

class ArrayUtils {
	public function new() {}

	public static function insertionSort(array:Array<ASAny>, comparator:IComparator):Bool {
		var _loc6_ = 0;
		var _loc7_:ASAny = null;
		var _loc8_ = 0;
		if (array.length < 2) {
			return false;
		}
		var _loc3_ = array.length;
		var _loc4_ = 1;
		var _loc5_ = _loc3_;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			_loc7_ = array[_loc6_];
			_loc8_ = _loc6_;
			while (_loc8_ > 0 && comparator.compare(array[_loc8_ - 1], _loc7_) == 1) {
				array[_loc8_] = array[_loc8_ - 1];
				_loc8_--;
			}
			array[_loc8_] = _loc7_;
		}
		return true;
	}
}
