package gameMasterDictionary
;
    class GMHints
   {
      
      public var Constant:String;
      
      public var MinLevel:UInt = 0;
      
      public var MaxLevel:UInt = 0;
      
      public var Type:String;
      
      public var HintText:String;
      
      public function new(param1:ASObject)
      {
         
         Constant = param1.Constant;
         MinLevel = (ASCompat.toInt(param1.MinLevel) : UInt);
         MaxLevel = (ASCompat.toInt(param1.MaxLevel) : UInt);
         Type = param1.Type;
         HintText = param1.HintText;
      }
   }


