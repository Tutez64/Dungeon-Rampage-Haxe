package account
;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import uI.DBUIOneButtonPopup;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
    class FacebookAccountInfo
   {
      
      var mDBFacade:DBFacade;
      
      var mId:String;
      
      var mName:String;
      
      var mFirstName:String;
      
      var mLastName:String;
      
      var mGender:String;
      
      var mLocale:String;
      
      var mType:String;
      
      var mProfilePic:MovieClip = new MovieClip();
      
      var mFriends:Array<ASAny>;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
         loadBasicAccountInfo();
         loadProfilePic();
      }
      
      function loadedFacebookAccountInfo(param1:Event) 
      {
         var _loc3_= cast(param1.target, URLLoader);
         var _loc2_:ASObject = com.adobe.serialization.json.JSON.decode(_loc3_.data);
         mId = _loc2_["id"];
         mName = _loc2_["name"];
         mFirstName = _loc2_["first_name"];
         mLastName = _loc2_["last_name"];
         mGender = _loc2_["gender"];
         mLocale = _loc2_["locale"];
         mType = _loc2_["type"];
      }
      
      function popupError(param1:Event) 
      {
         Logger.warn("FacebookAccountInfo Error: " + param1.toString() + " " + Std.string(param1.target));
         var _loc2_= new DBUIOneButtonPopup(mDBFacade,"Error","Error getting Facebook information","OK",null);
         MemoryTracker.track(_loc2_,"DBUIOneButtonPopup - created in FacebookAccountInfo.popupError()");
      }
      
      function ignoreError(param1:Event) 
      {
      }
      
      public function cloneProfilePic() : DisplayObject
      {
         var _loc2_:Loader = null;
         var _loc1_:String = null;
         var _loc5_:URLRequest = null;
         var _loc3_:LoaderContext = null;
         var _loc4_:ASAny = null;
         if(ASCompat.stringAsBool(mDBFacade.facebookPlayerId))
         {
            _loc2_ = new Loader();
            _loc1_ = "https://graph.facebook.com/" + mDBFacade.facebookPlayerId + "/picture";
            _loc5_ = new URLRequest(_loc1_);
            _loc2_.contentLoaderInfo.addEventListener("ioError",ignoreError);
            _loc2_.contentLoaderInfo.addEventListener("securityError",ignoreError);
            _loc3_ = new LoaderContext(true);
            _loc3_.checkPolicyFile = true;
            _loc2_.load(_loc5_,_loc3_);
            return _loc2_;
         }
         return null;
      }
      
      function loadProfilePic() 
      {
         var _loc2_:Loader = null;
         var _loc1_:String = null;
         var _loc4_:URLRequest = null;
         var _loc3_:LoaderContext = null;
         if(ASCompat.stringAsBool(mDBFacade.facebookPlayerId))
         {
            _loc2_ = new Loader();
            _loc1_ = "https://graph.facebook.com/" + mDBFacade.facebookPlayerId + "/picture";
            _loc4_ = new URLRequest(_loc1_);
            _loc2_.contentLoaderInfo.addEventListener("ioError",ignoreError);
            _loc2_.contentLoaderInfo.addEventListener("securityError",ignoreError);
            _loc3_ = new LoaderContext(true);
            _loc3_.checkPolicyFile = true;
            _loc2_.load(_loc4_,_loc3_);
            mProfilePic.addChild(_loc2_);
         }
      }
      
      function loadBasicAccountInfo() 
      {
         var _loc2_:URLLoader = null;
         var _loc1_:String = null;
         var _loc3_:URLRequest = null;
         if(mDBFacade.facebookController != null && ASCompat.stringAsBool(mDBFacade.facebookController.accessToken))
         {
            _loc2_ = new URLLoader();
            _loc1_ = "https://graph.facebook.com/me?access_token=" + mDBFacade.facebookController.accessToken;
            _loc3_ = new URLRequest(_loc1_);
            _loc2_.addEventListener("ioError",popupError);
            _loc2_.addEventListener("securityError",popupError);
            _loc2_.addEventListener("complete",loadedFacebookAccountInfo);
            _loc2_.load(_loc3_);
         }
      }
      
      public function loadFriends(param1:ASFunction = null) 
      {
         var loader:URLLoader;
         var picUrl:String;
         var url:URLRequest;
         var callback= param1;
         Logger.debug("loadFriends");
         if(mFriends != null)
         {
            Logger.debug("loadFriends already created: " + Std.string(mFriends.length));
            if(callback != null)
            {
               callback(mFriends);
            }
            return;
         }
         if(mDBFacade.facebookController != null && ASCompat.stringAsBool(mDBFacade.facebookController.accessToken))
         {
            Logger.debug("loadFriends: calling graph api");
            loader = new URLLoader();
            picUrl = "https://graph.facebook.com/me/friends?access_token=" + mDBFacade.facebookController.accessToken;
            url = new URLRequest(picUrl);
            loader.addEventListener("ioError",popupError);
            loader.addEventListener("securityError",popupError);
            loader.addEventListener("complete",function(param1:Event)
            {
               Logger.debug("loadFriends: graph api COMPLETE");
               loadedFriends(param1);
               if(callback != null)
               {
                  callback(mFriends);
               }
            });
            loader.load(url);
         }
         else
         {
            Logger.warn("loadFriends: no facebookAccessToken");
         }
      }
      
      function loadedFriends(param1:Event) 
      {
         var _loc3_= cast(param1.target, URLLoader);
         var _loc2_:ASObject = com.adobe.serialization.json.JSON.decode(_loc3_.data);
         mFriends = ASCompat.dynamicAs(_loc2_.data , Array);
         Logger.debug("loadedFriends: " + Std.string(mFriends.length));
      }
      
      public function loadFriendProfilePic(param1:String, param2:String = "square") : DisplayObject
      {
         var _loc4_= new Loader();
         var _loc3_= "https://graph.facebook.com/" + param1 + "/picture?type=" + param2;
         var _loc6_= new URLRequest(_loc3_);
         _loc4_.contentLoaderInfo.addEventListener("ioError",ignoreError);
         _loc4_.contentLoaderInfo.addEventListener("securityError",ignoreError);
         var _loc5_= new LoaderContext(true);
         _loc5_.checkPolicyFile = true;
         _loc4_.load(_loc6_,_loc5_);
         return _loc4_;
      }
      
      @:isVar public var id(get,never):String;
public function  get_id() : String
      {
         return mId;
      }
      
      @:isVar public var name(get,never):String;
public function  get_name() : String
      {
         return mName;
      }
      
      @:isVar public var firstName(get,never):String;
public function  get_firstName() : String
      {
         return mFirstName;
      }
      
      @:isVar public var lastName(get,never):String;
public function  get_lastName() : String
      {
         return mLastName;
      }
      
      @:isVar public var gender(get,never):String;
public function  get_gender() : String
      {
         return mGender;
      }
      
      @:isVar public var locale(get,never):String;
public function  get_locale() : String
      {
         return mLocale;
      }
      
      @:isVar public var type(get,never):String;
public function  get_type() : String
      {
         return mType;
      }
      
      @:isVar public var profilePic(get,never):DisplayObject;
public function  get_profilePic() : DisplayObject
      {
         return mProfilePic;
      }
   }


