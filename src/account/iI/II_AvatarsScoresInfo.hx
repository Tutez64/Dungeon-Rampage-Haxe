package account.iI;

import collections.Map;

class II_AvatarsScoresInfo {
	public var avatarIdToAvatarScore:Map;

	public function new(avatarScoresInfoJson:ASObject) {
		var _loc3_:ASObject = null;
		var _loc2_ = 0;

		avatarIdToAvatarScore = new Map();
		if (checkNullIteratee(avatarScoresInfoJson))
			for (_tmp_ in iterateDynamicValues(avatarScoresInfoJson)) {
				_loc3_ = _tmp_;
				_loc2_ = ASCompat.toInt(_loc3_.avatar_id);
				if (avatarIdToAvatarScore.hasKey(_loc2_)) {
					avatarIdToAvatarScore.itemFor(_loc2_).updateMapNodeScore(_loc3_);
				} else {
					avatarIdToAvatarScore.add(_loc2_, new II_AvatarMapNodeScore(_loc3_));
				}
			}
	}
}
