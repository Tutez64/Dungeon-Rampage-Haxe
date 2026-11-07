package gameMasterDictionary;

class GMInfiniteDungeon {
	public var RewardFloors:Vector<UInt>;

	public var Name:String;

	public var Id:Int = 0;

	public var FloorRewardsMap:GMMap;

	public var DModFloorStart:Vector<UInt>;

	public var Constant:String;

	public function new(json:ASObject = /*undefined*/ null) {
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
		FloorRewardsMap = new GMMap();
		FloorRewardsMap.add(ASCompat.toInt(json.Reward1Floor), json.Reward1);
		FloorRewardsMap.add(ASCompat.toInt(json.Reward2Floor), json.Reward2);
		FloorRewardsMap.add(ASCompat.toInt(json.Reward3Floor), json.Reward3);
		FloorRewardsMap.add(ASCompat.toInt(json.Reward4Floor), json.Reward4);
	}
}
