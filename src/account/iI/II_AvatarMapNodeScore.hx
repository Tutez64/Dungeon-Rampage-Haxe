package account.iI;

import collections.Map;

class II_AvatarMapNodeScore {
	public var nodeIdToScore:Map;

	public function new(mapNodeScoresJson:ASObject) {
		nodeIdToScore = new Map();
		updateMapNodeScore(mapNodeScoresJson);
	}

	public function updateMapNodeScore(mapNodeScoresJson:ASObject) {
		nodeIdToScore.add(ASCompat.toInt(mapNodeScoresJson.mapnode_id), ASCompat.toInt(mapNodeScoresJson.score));
	}
}
