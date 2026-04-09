package account
;
   import facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
    class GiftInfo
   {
      
      var mFromAccountId:UInt = 0;
      
      var mOfferId:UInt = 0;
      
      var mRequestId:String;
      
      var mProfilePic:DisplayObject;
      
      var mDBFacade:DBFacade;
      
      var mResponseCallback:ASFunction;
      
      public function new(param1:DBFacade, param2:ASObject, param3:ASFunction = null)
      {
         
         mDBFacade = param1;
         mResponseCallback = param3;
         parseJson(param2);
      }
      
      function parseJson(param1:ASObject) 
      {
         if(param1 == null)
         {
            return;
         }
         mFromAccountId = ASCompat.asUint(param1.from_account_id );
         mOfferId = ASCompat.asUint(param1.offer_id );
         mRequestId = ASCompat.asString(param1.request_id );
         if(mResponseCallback != null)
         {
            mResponseCallback();
         }
      }
      
      function ignoreIOError(param1:Event) 
      {
      }
      
            
      @:isVar public var pic(get,set):DisplayObject;
public function  get_pic() : DisplayObject
      {
         return mProfilePic;
      }
function  set_pic(param1:DisplayObject) :DisplayObject      {
         return mProfilePic = param1;
      }
      
      @:isVar public var fromAccountId(get,never):UInt;
public function  get_fromAccountId() : UInt
      {
         return mFromAccountId;
      }
      
      @:isVar public var requestId(get,never):String;
public function  get_requestId() : String
      {
         return mRequestId;
      }
      
      @:isVar public var offerId(get,never):UInt;
public function  get_offerId() : UInt
      {
         return mOfferId;
      }
   }


