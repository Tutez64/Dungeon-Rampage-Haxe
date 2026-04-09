package gameMasterDictionary
;
   import org.as3commons.collections.Map;
   
    class GMInfiniteDungeon
   {
      
      public var Id:Int = 0;
      
      public var Constant:String;
      
      public var Name:String;
      
      public var DModFloorStart:Vector<UInt>;
      
      public var RewardFloors:Vector<UInt>;
      
      public var FloorRewardsMap:Map;
      
      public function new(param1:ASObject)
      {
         
         Id = ASCompat.toInt(param1.Id);
         Constant = param1.Constant;
         Name = param1.Name;
         DModFloorStart = new Vector<UInt>();
         DModFloorStart.push((ASCompat.toInt(param1.DMod1FloorStart) : UInt));
         DModFloorStart.push((ASCompat.toInt(param1.DMod2FloorStart) : UInt));
         DModFloorStart.push((ASCompat.toInt(param1.DMod3FloorStart) : UInt));
         DModFloorStart.push((ASCompat.toInt(param1.DMod4FloorStart) : UInt));
         RewardFloors = new Vector<UInt>();
         RewardFloors.push((ASCompat.toInt(param1.Reward1Floor) : UInt));
         RewardFloors.push((ASCompat.toInt(param1.Reward2Floor) : UInt));
         RewardFloors.push((ASCompat.toInt(param1.Reward3Floor) : UInt));
         RewardFloors.push((ASCompat.toInt(param1.Reward4Floor) : UInt));
         FloorRewardsMap = new Map();
         FloorRewardsMap.add(param1.Reward1Floor,param1.Reward1);
         FloorRewardsMap.add(param1.Reward2Floor,param1.Reward2);
         FloorRewardsMap.add(param1.Reward3Floor,param1.Reward3);
         FloorRewardsMap.add(param1.Reward4Floor,param1.Reward4);
      }
   }


