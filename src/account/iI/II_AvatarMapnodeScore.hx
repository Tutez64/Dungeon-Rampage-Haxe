package account.iI;

import org.as3commons.collections.Map;

class II_AvatarMapnodeScore {
	public var nodeIdToScore:Map;

	public function new(mapnodeScoresJson:ASObject) {
		nodeIdToScore = new Map();
		updateMapnodeScore(mapnodeScoresJson);
	}

	public function updateMapnodeScore(mapnodeScoresJson:ASObject) {
		var _loc2_:ASAny = null;
		nodeIdToScore.add(ASCompat.toInt(mapnodeScoresJson.mapnode_id), ASCompat.toInt(mapnodeScoresJson.score));
	}
}
