package gameMasterDictionary;

import org.as3commons.collections.Map;

class GMInfiniteDungeon {
	public var Id:Int = 0;

	public var Constant:String;

	public var Name:String;

	public var DModFloorStart:Vector<UInt>;

	public var RewardFloors:Vector<UInt>;

	public var FloorRewardsMap:Map;

	public function new(json:ASObject) {
		Id = ASCompat.toInt(json.Id);
		Constant = json.Constant;
		Name = json.Name;
		DModFloorStart = new Vector<UInt>();
		DModFloorStart.push((ASCompat.toInt(json.DMod1FloorStart) : UInt));
		DModFloorStart.push((ASCompat.toInt(json.DMod2FloorStart) : UInt));
		DModFloorStart.push((ASCompat.toInt(json.DMod3FloorStart) : UInt));
		DModFloorStart.push((ASCompat.toInt(json.DMod4FloorStart) : UInt));
		RewardFloors = new Vector<UInt>();
		RewardFloors.push((ASCompat.toInt(json.Reward1Floor) : UInt));
		RewardFloors.push((ASCompat.toInt(json.Reward2Floor) : UInt));
		RewardFloors.push((ASCompat.toInt(json.Reward3Floor) : UInt));
		RewardFloors.push((ASCompat.toInt(json.Reward4Floor) : UInt));
		FloorRewardsMap = new Map();
		FloorRewardsMap.add(json.Reward1Floor, json.Reward1);
		FloorRewardsMap.add(json.Reward2Floor, json.Reward2);
		FloorRewardsMap.add(json.Reward3Floor, json.Reward3);
		FloorRewardsMap.add(json.Reward4Floor, json.Reward4);
	}
}
