package gameMasterDictionary
;
    class GMColiseumTier extends GMItem
   {
      
      public var MusicFilepath:String;
      
      public var BonusGold:Float = Math.NaN;
      
      public var BonusExp:Float = Math.NaN;
      
      public var MinLevel:UInt = 0;
      
      public var TotalFloors:UInt = 0;
      
      public function new(param1:ASObject)
      {
         super(param1);
         MusicFilepath = param1.MusicFilepath;
         BonusGold = ASCompat.toNumberField(param1, "Gold");
         BonusExp = ASCompat.toNumberField(param1, "Exp");
         MinLevel = (ASCompat.toInt(param1.MinLevel) : UInt);
         TotalFloors = (ASCompat.toInt(param1.MinFloors) : UInt);
      }
   }


