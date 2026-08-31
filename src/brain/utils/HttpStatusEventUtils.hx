package brain.utils;

import flash.events.HTTPStatusEvent;
import flash.net.URLRequestHeader;

class HttpStatusEventUtils {
	public function new() {}

	public static function getTraceId(e:HTTPStatusEvent):String {
		if (e == null || e.responseHeaders == null) {
			return null;
		}
		var _loc2_:URLRequestHeader;
		final __ax4_iter_63 = e.responseHeaders;
		if (checkNullIteratee(__ax4_iter_63))
			for (_tmp_ in __ax4_iter_63) {
				_loc2_ = _tmp_;
				if (_loc2_.name.toLowerCase() == "x-trace-id") {
					return _loc2_.value;
				}
			}
		return null;
	}
}
