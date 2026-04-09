package com.facebook.graph.data
;
    class FacebookSession
   {
      
      public var uid:String;
      
      public var user:ASObject;
      
      public var sessionKey:String;
      
      public var expireDate:Date;
      
      public var accessToken:String;
      
      public var secret:String;
      
      public var sig:String;
      
      public var availablePermissions:Array<ASAny>;
      
      public function new()
      {
         
      }
      
      public function fromJSON(param1:ASObject) 
      {
         if(param1 != null)
         {
            this.sessionKey = param1.session_key;
            this.expireDate = Date.fromTime(param1.expires);
            this.accessToken = param1.access_token;
            this.secret = param1.secret;
            this.sig = param1.sig;
            this.uid = param1.uid;
         }
      }
      
      public function toString() : String
      {
         return "[userId:" + this.uid + "]";
      }
   }


