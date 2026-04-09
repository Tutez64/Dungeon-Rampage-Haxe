package com.adobe.serialization.json
;
    final class JSON
   {
      
      public function new()
      {
         
      }
      
      public static function encode(param1:ASObject) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function decode(param1:String, param2:Bool = true) : ASAny
      {
         return new JSONDecoder(param1,param2).getValue();
      }
   }


