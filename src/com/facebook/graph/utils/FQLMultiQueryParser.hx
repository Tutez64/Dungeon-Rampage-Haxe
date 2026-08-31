package com.facebook.graph.utils;

class FQLMultiQueryParser implements IResultParser {
	public function new() {}

	public function parse(data:ASObject):ASObject {
		var _loc3_:String = null;
		var _loc2_:ASObject = {};
		if (checkNullIteratee(data))
			for (_tmp_ in data.___keys()) {
				_loc3_ = _tmp_;
				_loc2_[data[_loc3_].name] = data[_loc3_].fql_result_set;
			}
		return _loc2_;
	}
}
