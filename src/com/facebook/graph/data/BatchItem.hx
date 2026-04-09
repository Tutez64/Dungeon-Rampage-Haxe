package com.facebook.graph.data
;
    class BatchItem
   {
      
      public var relativeURL:String;
      
      public var callback:ASFunction;
      
      public var params:ASAny;
      
      public var requestMethod:String;
      
      public function new(param1:String, param2:ASFunction = null, param3:ASAny = null, param4:String = "GET")
      {
         
         this.relativeURL = param1;
         this.callback = param2;
         this.params = param3;
         this.requestMethod = param4;
      }
   }


