package events
;
    class FacebookIdReceivedEvent extends GameObjectEvent
   {
      
      public static inline final NAME= "FACEBOOK_ID_RECEIVED_EVENT";
      
      var mFacebookId:String;
      
      public function new(param1:String, param2:UInt, param3:String, param4:Bool = false, param5:Bool = false)
      {
         mFacebookId = param3;
         super(param1,param2,param4,param5);
      }
      
      @:isVar public var facebookId(get,never):String;
public function  get_facebookId() : String
      {
         return mFacebookId;
      }
   }


