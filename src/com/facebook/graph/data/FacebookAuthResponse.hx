package com.facebook.graph.data
;
    class FacebookAuthResponse
   {
      
      public var uid:String;
      
      public var expireDate:Date;
      
      public var accessToken:String;
      
      public var signedRequest:String;
      
      public function new()
      {
         
      }
      
      public function fromJSON(param1:ASObject) 
      {
         if(param1 != null)
         {
            this.expireDate = Date.now();
            ASCompat.ASDate.setTime(this.expireDate, this.expireDate.getTime() + ASCompat.toNumberField(param1, "expiresIn") * 1000);
            this.accessToken = if (ASCompat.toBool(param1.access_token)) param1.access_token else param1.accessToken;
            this.signedRequest = param1.signedRequest;
            this.uid = param1.userID;
         }
      }
      
      public function toString() : String
      {
         return "[userId:" + this.uid + "]";
      }
   }


