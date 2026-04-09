package gameMasterDictionary
;
    class GMStackable extends GMInventoryBase
   {
      
      public var StackLimit:UInt = 0;
      
      public var EquipLimit:UInt = 0;
      
      public var LevelReq:UInt = 0;
      
      public var ExpMult:Float = Math.NaN;
      
      public var GoldMult:Float = Math.NaN;
      
      public var AccountBooster:Bool = false;
      
      public var Buff:String;
      
      public var UsageAttack:String;
      
      public function new(param1:ASObject)
      {
         super(param1);
         StackLimit = (ASCompat.toInt(param1.StackLimit) : UInt);
         EquipLimit = (ASCompat.toInt(param1.EquipLimit) : UInt);
         LevelReq = (ASCompat.toInt(param1.LevelReq) : UInt);
         ExpMult = ASCompat.toNumberField(param1, "ExpMult");
         GoldMult = ASCompat.toNumberField(param1, "GoldMult");
         Buff = param1.BuffGiven;
         UsageAttack = param1.UsageAttack;
         AccountBooster = ASCompat.toBool(param1.AccountBooster);
      }
   }


