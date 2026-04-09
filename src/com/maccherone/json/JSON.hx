package com.maccherone.json
;
    class JSON
   {
      
      public function new()
      {
         
      }
      
      public static function decode(param1:String, param2:Bool = true) : ASAny
      {
         return new JSONDecoder(param1,param2).getValue();
      }
      
      public static function encode(param1:ASObject, param2:Bool = false, param3:Int = 60) : String
      {
         return new JSONEncoder(param1,param2,param3).getString();
      }
   }


