package com.facebook.graph.data;

import com.adobe.serialization.json.JSON;

class FQLMultiQuery {
	public var queries:ASObject;

	public function new() {
		this.queries = {};
	}

	public function add(query:String, name:String, values:ASObject = null) {
		var _loc4_:String = null;
		if (this.queries.hasOwnProperty(name)) {
			throw new Error("Query name already exists, there cannot be duplicate names");
		}
		if (checkNullIteratee(values))
			for (_tmp_ in values.___keys()) {
				_loc4_ = _tmp_;
				query = new compat.RegExp("\\{" + _loc4_ + "\\}", "g").replace(query, values[_loc4_]);
			}
		this.queries[name] = query;
	}

	public function toString():String {
		return com.adobe.serialization.json.JSON.encode(this.queries);
	}
}
