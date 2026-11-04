package account.iI;

import collections.Map;

class II_AccountTopScoreInfo {
	public var accountIdToTopScoreMapNodeInfo:Map;

	public function new(topScoreJson:ASObject) {
		var _loc3_:ASObject = null;
		var _loc2_ = 0;

		accountIdToTopScoreMapNodeInfo = new Map();
		if (checkNullIteratee(topScoreJson))
			for (_tmp_ in iterateDynamicValues(topScoreJson)) {
				_loc3_ = _tmp_;
				_loc2_ = ASCompat.toInt(_loc3_.account_id);
				if (accountIdToTopScoreMapNodeInfo.hasKey(_loc2_)) {
					accountIdToTopScoreMapNodeInfo.itemFor(_loc2_).updateMapNodeScore(_loc3_);
				} else {
					accountIdToTopScoreMapNodeInfo.add(_loc2_, new II_FriendChampionsboardInfo(_loc3_));
				}
			}
	}
}
