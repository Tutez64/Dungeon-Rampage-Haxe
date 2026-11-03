package gameMasterDictionary;

import flash.Boot;

class GMMapNode extends GMItem {
	public static var DUNGEON_NODE_TYPE:String = "DUNGEON";

	public static var BOSS_NODE_TYPE:String = "BOSS";

	public static var INFINITE_NODE_TYPE:String = "INFINITE";

	public static var TAVERN_NODE_TYPE:String = "TAVERN";

	public var TrophyRequirement:UInt = 0;

	public var TierRank:String;

	public var StorySwfPath:String;

	public var StoryPlayEverytime:Bool = false;

	public var StoryAssetClass:String;

	public var RevealNodes:Array<ASAny>;

	public var PremiumKeys:UInt = 0;

	public var PrefixupParentNode:String;

	public var PayEverytime:Bool = false;

	public var ParentNodes:Array<ASAny>;

	public var NodeType:String;

	public var NodeIcon:String;

	public var MinTreasure:UInt = 0;

	public var LevelRequirement:UInt = 0;

	public var IsWeeklyChallenge:Bool = false;

	public var IsInfiniteDungeon:Bool = false;

	public var InfiniteDungeon:String;

	public var GoalRoomTileset:String;

	public var GoalRoom:String;

	public var DifficultyName:String;

	public var CompletionXPBonus:UInt = 0;

	public var ColiseumType:UInt = 0;

	public var ChildNodes:Array<ASAny>;

	public var BitIndex:UInt = 0;

	public var BasicKeys:UInt = 0;

	public var AlwaysVisible:Bool = false;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
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
	}

	public function mapColiseumType(type:String):UInt {
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
