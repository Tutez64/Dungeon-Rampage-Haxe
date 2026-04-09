package gameMasterDictionary
;
    class GMStat extends GMItem
   {
      
      public var StatType:String;
      
      public var Bonus:Float = Math.NaN;
      
      public var MaxCap:Float = Math.NaN;
      
      public var IconName:String;
      
      public var Description:String;
      
      public function new(param1:ASObject)
      {
         super(param1);
         StatType = param1.StatType;
         Bonus = ASCompat.toNumberField(param1, "Bonus");
         MaxCap = ASCompat.toNumberField(param1, "MaxCap");
         IconName = param1.IconName;
         Description = param1.Description;
      }
   }


