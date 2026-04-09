package gameMasterDictionary
;
    class GMKey
   {
      
      public var OfferId:UInt = 0;
      
      public var ChestId:UInt = 0;
      
      public function new(param1:ASObject)
      {
         
         OfferId = (ASCompat.toInt(param1.OfferId) : UInt);
         ChestId = (ASCompat.toInt(param1.ChestId) : UInt);
      }
   }


