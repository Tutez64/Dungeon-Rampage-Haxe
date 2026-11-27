package starling.utils;

final class Execute {
	public static function execute(func:ASFunction, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc4_ = 0;
		var _loc3_ = 0;
		if (func != null) {
			_loc3_ = (func.length : Int);
			_loc4_ = rest.length;
			while (_loc4_ < _loc3_) {
				rest[_loc4_] = null;
				_loc4_++;
			}
			switch (_loc3_) {
				case 0:
					func();

				case 1:
					func(rest[0]);

				case 2:
					func(rest[0], rest[1]);

				case 3:
					func(rest[0], rest[1], rest[2]);

				case 4:
					func(rest[0], rest[1], rest[2], rest[3]);

				case 5:
					func(rest[0], rest[1], rest[2], rest[3], rest[4]);

				case 6:
					func(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5]);

				case 7:
					func(rest[0], rest[1], rest[2], rest[3], rest[4], rest[5], rest[6]);

				default:
					ASCompatMacro.applyClosure(func, rest.slice(0, _loc3_));
			}
		}
	}
}
