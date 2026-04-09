package gameMasterDictionary
;
    class GMMapNode extends GMItem
   {
      
      public static inline final DUNGEON_NODE_TYPE= "DUNGEON";
      
      public static inline final BOSS_NODE_TYPE= "BOSS";
      
      public static inline final INFINITE_NODE_TYPE= "INFINITE";
      
      public static inline final TAVERN_NODE_TYPE= "TAVERN";
      
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
      
      public function new(param1:ASObject)
      {
         super(param1);
         BitIndex = (ASCompat.toInt(param1.BitIndex) : UInt);
         DifficultyName = param1.DifficultyName;
         ColiseumType = mapColiseumType(param1.ColiseumType);
         NodeType = param1.NodeType;
         TierRank = param1.TierRank;
         InfiniteDungeon = param1.InfiniteDungeon;
         IsInfiniteDungeon = InfiniteDungeon != null;
         NodeIcon = param1.NodeIcon;
         GoalRoomTileset = param1.GoalRoomTileset;
         GoalRoom = param1.GoalRoom;
         LevelRequirement = (ASCompat.toInt(param1.LevelReq) : UInt);
         TrophyRequirement = (ASCompat.toInt(param1.TrophyReq) : UInt);
         BasicKeys = (ASCompat.toInt(param1.BasicKeys) : UInt);
         PremiumKeys = (ASCompat.toInt(param1.PremiumKeys) : UInt);
         PayEverytime = ASCompat.toBool(param1.PayEverytime);
         StorySwfPath = param1.StoryScene;
         StoryAssetClass = param1.AssetClassName;
         StoryPlayEverytime = ASCompat.toBool(param1.PlayEverytime);
         RevealNodes = [param1.RevealNode1,param1.RevealNode2,param1.RevealNode3,param1.RevealNode4,param1.RevealNode5,param1.RevealNode6,param1.RevealNode7,param1.RevealNode8,param1.RevealNode9,param1.RevealNode10];
         ChildNodes = [param1.ChildNode1,param1.ChildNode2,param1.ChildNode3];
         PrefixupParentNode = param1.ParentNode;
         ParentNodes = [];
         IsWeeklyChallenge = ASCompat.toBool(param1.IsWeeklyChallenge);
         AlwaysVisible = ASCompat.toBool(param1.AlwaysVisible);
         CompletionXPBonus = (ASCompat.toInt(param1.CompletionXPBonus) : UInt);
         MinTreasure = (ASCompat.toInt(param1.MinTreasure) : UInt);
      }
      
      function mapColiseumType(param1:String) : UInt
      {
         if(param1 == "DINO_JUNGLE")
         {
            return (2 : UInt);
         }
         if(param1 == "ICE_CAVES")
         {
            return (3 : UInt);
         }
         if(param1 == "SKY_PAGODA")
         {
            return (4 : UInt);
         }
         return (1 : UInt);
      }
   }


