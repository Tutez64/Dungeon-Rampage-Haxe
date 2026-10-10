package account.iI;

import com.maccherone.json.JSON;
import org.as3commons.collections.Map;

class II_FriendChampionsboardInfo {
	public var nodeIdToScore:Map;

	public var nodeIdToActiveSkin:Map;

	var mNodeIdToFriendInfoJson:Map;

	public function new(friendLeaderboardJson:ASObject) {
		nodeIdToScore = new Map();
		nodeIdToActiveSkin = new Map();
		mNodeIdToFriendInfoJson = new Map();
		updateMapnodeScore(friendLeaderboardJson);
	}

	public function updateMapnodeScore(friendLeaderboardJson:ASObject) {
		var _loc2_:ASAny = null;
		nodeIdToScore.add(friendLeaderboardJson.mapnode_id, friendLeaderboardJson.score);
		nodeIdToActiveSkin.add(friendLeaderboardJson.mapnode_id, friendLeaderboardJson.active_skin);
		mNodeIdToFriendInfoJson.add(friendLeaderboardJson.mapnode_id, friendLeaderboardJson);
	}

	public function getWeaponsForNodeId(nodeId:UInt):Array<Dynamic> {
		var _loc3_:ASObject = null;
		var _loc2_ = new Array<Dynamic>();
		if (mNodeIdToFriendInfoJson.hasKey(nodeId)) {
			_loc3_ = mNodeIdToFriendInfoJson.itemFor(nodeId);
			_loc2_.push(com.maccherone.json.JSON.decode(_loc3_.weapon1));
			_loc2_.push(com.maccherone.json.JSON.decode(_loc3_.weapon2));
			_loc2_.push(com.maccherone.json.JSON.decode(_loc3_.weapon3));
		}
		return _loc2_;
	}
}
