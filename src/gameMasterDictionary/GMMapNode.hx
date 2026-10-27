package gameMasterDictionary;

class GMMapNode extends GMItem {
	public static inline final DUNGEON_NODE_TYPE = "DUNGEON";

	public static inline final BOSS_NODE_TYPE = "BOSS";

	public static inline final INFINITE_NODE_TYPE = "INFINITE";

	public static inline final TAVERN_NODE_TYPE = "TAVERN";

	public var DifficultyName:String;

	public var ColiseumType:UInt = 0;

	public var NodeType:String;

	public var TierRank:String;

	public var InfiniteDungeon:String;

	public var BasicKeys:UInt = 0;

	public var PremiumKeys:UInt = 0;

	public var PayEverytime:Bool = false;

	public var RevealNodes:Array<ASAny>;

	public var ChildNodes:Array<ASAny>;

	public var ParentNodes:Array<ASAny>;

	public var PrefixupParentNode:String;

	public var StorySwfPath:String;

	public var StoryAssetClass:String;

	public var StoryPlayEverytime:Bool = false;

	public var NodeIcon:String;

	public var GoalRoomTileset:String;

	public var GoalRoom:String;

	public var LevelRequirement:UInt = 0;

	public var TrophyRequirement:UInt = 0;

	public var CompletionXPBonus:UInt = 0;

	public var IsWeeklyChallenge:Bool = false;

	public var AlwaysVisible:Bool = false;

	public var MinTreasure:UInt = 0;

	public var BitIndex:UInt = 0;

	public var IsInfiniteDungeon:Bool = false;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		BitIndex = (ASCompat.toInt(jsonAsset.BitIndex) : UInt);
		DifficultyName = jsonAsset.DifficultyName;
		ColiseumType = mapColiseumType(jsonAsset.ColiseumType);
		NodeType = jsonAsset.NodeType;
		TierRank = jsonAsset.TierRank;
		InfiniteDungeon = jsonAsset.InfiniteDungeon;
		IsInfiniteDungeon = InfiniteDungeon != null;
		NodeIcon = jsonAsset.NodeIcon;
		GoalRoomTileset = jsonAsset.GoalRoomTileset;
		GoalRoom = jsonAsset.GoalRoom;
		LevelRequirement = (ASCompat.toInt(jsonAsset.LevelReq) : UInt);
		TrophyRequirement = (ASCompat.toInt(jsonAsset.TrophyReq) : UInt);
		BasicKeys = (ASCompat.toInt(jsonAsset.BasicKeys) : UInt);
		PremiumKeys = (ASCompat.toInt(jsonAsset.PremiumKeys) : UInt);
		PayEverytime = ASCompat.toBool(jsonAsset.PayEverytime);
		StorySwfPath = jsonAsset.StoryScene;
		StoryAssetClass = jsonAsset.AssetClassName;
		StoryPlayEverytime = ASCompat.toBool(jsonAsset.PlayEverytime);
		RevealNodes = [
			jsonAsset.RevealNode1,
			jsonAsset.RevealNode2,
			jsonAsset.RevealNode3,
			jsonAsset.RevealNode4,
			jsonAsset.RevealNode5,
			jsonAsset.RevealNode6,
			jsonAsset.RevealNode7,
			jsonAsset.RevealNode8,
			jsonAsset.RevealNode9,
			jsonAsset.RevealNode10
		];
		ChildNodes = [jsonAsset.ChildNode1, jsonAsset.ChildNode2, jsonAsset.ChildNode3];
		PrefixupParentNode = jsonAsset.ParentNode;
		ParentNodes = [];
		IsWeeklyChallenge = ASCompat.toBool(jsonAsset.IsWeeklyChallenge);
		AlwaysVisible = ASCompat.toBool(jsonAsset.AlwaysVisible);
		CompletionXPBonus = (ASCompat.toInt(jsonAsset.CompletionXPBonus) : UInt);
		MinTreasure = (ASCompat.toInt(jsonAsset.MinTreasure) : UInt);
	}

	function mapColiseumType(type:String):UInt {
		if (type == "DINO_JUNGLE") {
			return (2 : UInt);
		}
		if (type == "ICE_CAVES") {
			return (3 : UInt);
		}
		if (type == "SKY_PAGODA") {
			return (4 : UInt);
		}
		return (1 : UInt);
	}
}
