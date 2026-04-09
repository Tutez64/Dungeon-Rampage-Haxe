package com.adobe.serialization.json
;
    final class JSONToken
   {
      
      @:allow(com.adobe.serialization.json) static final token:JSONToken = new JSONToken();
      
      public var type:Int = 0;
      
      public var value:ASObject;
      
      public function new(param1:Int = -1, param2:ASObject = null)
      {
         
         this.type = param1;
         this.value = param2;
      }
      
      @:allow(com.adobe.serialization.json) static function create(param1:Int = -1, param2:ASObject = null) : JSONToken
      {
         token.type = param1;
         token.value = param2;
         return token;
      }
   }


