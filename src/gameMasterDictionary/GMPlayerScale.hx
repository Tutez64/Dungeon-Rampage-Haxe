package gameMasterDictionary
;
   import org.as3commons.collections.Map;
   
    class GMPlayerScale
   {
      
      public static var HPBoostByPlayers:Map = new Map();
      
      public var Players:UInt = 0;
      
      public var HPBoost:Float = Math.NaN;
      
      public function new(param1:ASObject)
      {
         
         Players = (ASCompat.toInt(param1.Players) : UInt);
         HPBoost = ASCompat.toNumberField(param1, "HP_BOOST");
         HPBoostByPlayers.add(Players,HPBoost);
      }
   }


