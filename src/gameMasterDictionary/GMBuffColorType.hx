package gameMasterDictionary
;
    class GMBuffColorType
   {
      
      public var Id:UInt = 0;
      
      public var ColorHex:UInt = 0;
      
      public function new(param1:ASObject)
      {
         
         Id = (ASCompat.toInt(param1.Id) : UInt);
         ColorHex = (ASCompat.toInt(param1.TextColor) : UInt);
      }
   }


