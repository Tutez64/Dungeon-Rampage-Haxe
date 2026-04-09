package account
;
   import account.iI.II_AccountTopScoreInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.utils.HttpStatusEventUtils;
   import brain.utils.MemoryTracker;
   import brain.utils.Utf8BitArray;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import brain.jsonRPC.JSONRPCService;
   import events.DBAccountLoadedEvent;
   import events.DBAccountResponseEvent;
   import events.FriendStatusEvent;
   import events.TrophiesUpdatedAccountEvent;
   import facade.DBFacade;
   import facade.Locale;
   import uI.DBUIPopup;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.system.System;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class DBAccountInfo
   {
      
      public static inline final SFX_ATTRIBUTE_KEY= "optionsSFXVolume";
      
      public static inline final MUSIC_ATTRIBUTE_KEY= "optionsMusicVolume";
      
      public static inline final GRAPHICS_QUALITY_ATTRIBUTE_KEY= "optionsGraphicsQuality";
      
      public static inline final HUD_STYLE_ATTRIBUTE_KEY= "optionsHudStyle";
      
      static inline final DB_ACCOUNT_INFO_SERVICE= "dbAccountInfo/accountdetails";
      
      static inline final ONLINE_PRESENCE_NORMAL_REFRESH_TIME:Float = 60;
      
      var mDBFacade:DBFacade;
      
      var mInventory:DBInventoryInfo;
      
      var mUpdateMessagePopup:DBUIPopup;
      
      var mActiveAvatar:AvatarInfo;
      
      var mAttributes:Map;
      
      var mBasicCurrency:UInt = 0;
      
      var mId:UInt = 0;
      
      var mAccountFlags:UInt = 0;
      
      var mPremiumKeys:UInt = 0;
      
      var mTrophyCount:UInt = 0;
      
      var mName:String;
      
      var mPremiumCurrency:UInt = 0;
      
      var mInventoryLimitOther:UInt = 0;
      
      var mInventoryLimitWeapons:UInt = 0;
      
      var mFriendsInfo:Map;
      
      var mGiftsInfo:Map;
      
      var mGiftExcludeIds:Array<ASAny>;
      
      var mLastFPSTime:UInt = 0;
      
      var mLastFPSFrame:UInt = 0;
      
      var mFPSLocation:String = "";
      
      var mCurrentFriendsHash:String;
      
      var mAccountCreatedDate:String;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mOnlinePresenceTask:Task;
      
      public var SocketPingMilsecs:Int = 0;
      
      var mErrorPopUp:DBUIPopup;
      
      var mIgnoredFriendsInfo:Vector<FriendInfo>;
      
      var mDBAccountParams:DBAccountParams;
      
      var mDungeonsCompleted:UInt = 0;
      
      var mCompletedMapnodeMask:Utf8BitArray;
      
      var mHudStyle:UInt = (0 : UInt);
      
      var mLocalFriendInfo:FriendInfo;
      
      public function new(param1:DBFacade)
      {
         
         SocketPingMilsecs = -1;
         mDBFacade = param1;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mAttributes = new Map();
         mFriendsInfo = new Map();
         mGiftsInfo = new Map();
         mInventory = new DBInventoryInfo(mDBFacade,parseResponse,parseError);
         mEventComponent = new EventComponent(mDBFacade);
         mIgnoredFriendsInfo = new Vector<FriendInfo>();
         mGiftExcludeIds = [];
         mCompletedMapnodeMask = new Utf8BitArray();
         mDBFacade.dbAccountInfo = this;
      }
      
      @:isVar public var unequippedWeaponCount(get,never):UInt;
public function  get_unequippedWeaponCount() : UInt
      {
         return mInventory.unequippedWeaponCount;
      }
      
      @:isVar public var activeAvatarId(get,never):UInt;
public function  get_activeAvatarId() : UInt
      {
         return mActiveAvatar.id;
      }
      
      @:isVar public var activeAvatarSkinId(get,never):UInt;
public function  get_activeAvatarSkinId() : UInt
      {
         return mActiveAvatar.skinId;
      }
      
      @:isVar public var stackableCount(get,never):UInt;
public function  get_stackableCount() : UInt
      {
         return mInventory.numStacks;
      }
      
      @:isVar public var inventoryLimitWeapons(get,never):UInt;
public function  get_inventoryLimitWeapons() : UInt
      {
         return mInventoryLimitWeapons;
      }
      
      @:isVar public var inventoryLimitOther(get,never):UInt;
public function  get_inventoryLimitOther() : UInt
      {
         return mInventoryLimitOther;
      }
      
      @:isVar public var name(get,never):String;
public function  get_name() : String
      {
         return mName;
      }
      
      @:isVar public var facebookId(get,never):String;
public function  get_facebookId() : String
      {
         return mDBFacade.facebookPlayerId;
      }
      
      @:isVar public var kongregateId(get,never):String;
public function  get_kongregateId() : String
      {
         return mDBFacade.kongregatePlayerId;
      }
      
      @:isVar public var inventoryInfo(get,never):DBInventoryInfo;
public function  get_inventoryInfo() : DBInventoryInfo
      {
         return mInventory;
      }
      
      @:isVar public var id(get,never):UInt;
public function  get_id() : UInt
      {
         return mId;
      }
      
      @:isVar public var currentFacebookFriendsHash(get,never):String;
public function  get_currentFacebookFriendsHash() : String
      {
         return mCurrentFriendsHash;
      }
      
      @:isVar public var currentKongregateFriendsHash(get,never):String;
public function  get_currentKongregateFriendsHash() : String
      {
         return mCurrentFriendsHash;
      }
      
      public function checkFriendsHash() 
      {
         if(mDBFacade.facebookController != null)
         {
            mDBFacade.facebookController.getFacebookFriendsHash();
         }
         if(mDBFacade.isKongregatePlayer)
         {
            mDBFacade.facebookController.getKongregateFriendsHash();
         }
      }
      
      public function getUsersFullAccountInfo() 
      {
         var onAccountInfoLoaded:Event->Void = null;
         var onAccountInfoError:Event->Void = null;
         var accountId:UInt;
         var validationToken:String;
         var getUrl:String;
         var req:URLRequest;
         var loader:URLLoader = null;
         var traceInfo:String;
         var responseStatusCode:Int;
         var _this:DBAccountInfo = null;
         var removeAllListeners= function()
         {
            loader.removeEventListener("httpResponseStatus",onAccountInfoLoaded);
            loader.removeEventListener("complete",onAccountInfoLoaded);
            loader.removeEventListener("securityError",onAccountInfoError);
            loader.removeEventListener("certificateError",onAccountInfoError);
            loader.removeEventListener("ioError",onAccountInfoError);
         };
         var onResponseStatus= function(param1:flash.events.HTTPStatusEvent)
         {
            responseStatusCode = param1.status;
            traceInfo = HttpStatusEventUtils.getTraceId(param1);
         };
         onAccountInfoLoaded = function(param1:Event)
         {
            var _loc2_:ASObject = null;
            if(responseStatusCode < 200 || responseStatusCode >= 400)
            {
               onAccountInfoError(param1);
               return;
            }
            removeAllListeners();
            var _loc3_= ASCompat.dynamicAs(param1.target , URLLoader);
            try
            {
               _loc2_ = haxe.Json.parse(_loc3_.data);
               parseResponse(_loc2_);
               mEventComponent.dispatchEvent(new DBAccountLoadedEvent(_this));
               if(!ASCompat.stringAsBool(mCurrentFriendsHash) || mCurrentFriendsHash == "")
               {
                  getUsersFriendInfo();
               }
            }
            catch(error:Dynamic)
            {
               Logger.error("Failed to parse account info JSON: " + Std.string(error.message));
               onAccountInfoError(param1);
            }
         };
         onAccountInfoError = function(param1:Event)
         {
            removeAllListeners();
            var _loc3_= "[" + responseStatusCode + "] Account info loading failed";
            var _loc2_= "";
            if(Std.isOfType(param1 , IOErrorEvent))
            {
               _loc2_ = "IOError: " + ASCompat.reinterpretAs(param1 , IOErrorEvent).text;
            }
            else if(Std.isOfType(param1 , SecurityErrorEvent))
            {
               _loc2_ = "SecurityError: " + ASCompat.reinterpretAs(param1 , SecurityErrorEvent).text;
            }
            else
            {
               _loc2_ = param1.toString();
            }
            if(param1 != null && ASCompat.toBool(param1.target) && ASCompat.toBool(param1.target.data))
            {
               _loc2_ += "; Response: " + Std.string(param1.target.data);
            }
            Logger.warn(_loc3_ + (ASCompat.stringAsBool(_loc2_) ? "; " + _loc2_ : "") + (ASCompat.stringAsBool(traceInfo) ? "; " + traceInfo : ""));
            mDBFacade.errorPopup(Locale.getString("ERROR"),Locale.getError(100) + "\n[" + responseStatusCode + "]");
         };
         Logger.debug("DBAccountInfo.getUsersFullAccountInfo");
         accountId = mDBFacade.accountId;
         validationToken = mDBFacade.validationToken;
         getUrl = mDBFacade.webServiceAPIRoot + "dbAccountInfo/accountdetails";
         req = new URLRequest(getUrl);
         req.method = "GET";
         req.requestHeaders = [];
         req.requestHeaders.push(new URLRequestHeader("X-Account-Id",Std.string(accountId)));
         req.requestHeaders.push(new URLRequestHeader("X-Validation-Token",validationToken));
         if(ASCompat.stringAsBool(mDBFacade.initialLoginTraceId))
         {
            req.requestHeaders.push(new URLRequestHeader("X-Session-Initial-Trace",JSONRPCService.initialLoginTraceId));
         }
         loader = new URLLoader();
         responseStatusCode = 0;
         loader.addEventListener("httpResponseStatus",onResponseStatus);
         loader.addEventListener("complete",onAccountInfoLoaded);
         loader.addEventListener("securityError",onAccountInfoError);
         loader.addEventListener("certificateError",onAccountInfoError);
         loader.addEventListener("ioError",onAccountInfoError);
         _this = this;
         loader.load(req);
      }
      
      public function getUsersFriendInfo() 
      {
         var rpcFunc:ASFunction;
         var rpcSuccessCallback:ASFunction;
         Logger.debug("DBAccountInfo.getUsersFriendInfo");
         rpcFunc = JSONRPCService.getFunction("getFriendRecord",mDBFacade.rpcRoot + "leaderboard");
         rpcSuccessCallback = function(param1:ASAny)
         {
            parseFriendResponse(param1);
         };
         rpcFunc(mDBFacade.accountId,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      public function alterAttribute(param1:String, param2:String) 
      {
         var rpcSuccessCallback:ASFunction;
         var name= param1;
         var value= param2;
         var rpcFunc= JSONRPCService.getFunction("AlterAttribute",mDBFacade.rpcRoot + "account");
         if(mAttributes.hasKey(name))
         {
            mAttributes.replaceFor(name,value);
         }
         else
         {
            mAttributes.add(name,value);
         }
         rpcSuccessCallback = function(param1:ASAny)
         {
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,name,value,rpcSuccessCallback,parseError);
      }
      
      public function hasAttribute(param1:String) : Bool
      {
         return mAttributes.hasKey(param1);
      }
      
      public function getAttribute(param1:String) : String
      {
         return mAttributes.itemFor(param1);
      }
      
            
      @:isVar public var hudStyle(get,set):UInt;
public function  get_hudStyle() : UInt
      {
         return mHudStyle;
      }
function  set_hudStyle(param1:UInt) :UInt      {
         return mHudStyle = param1;
      }
      
      public function acceptGift(param1:String, param2:ASFunction, param3:ASFunction = null) 
      {
         var requestId= param1;
         var clearGiftCallback= param2;
         var successCallback= param3;
         var rpcFunc= JSONRPCService.getFunction("AcceptGift",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:ASFunction = function(param1:ASAny)
         {
            if(ASCompat.toBool(param1))
            {
               parseResponse(param1);
            }
            if(successCallback != null)
            {
               successCallback();
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,requestId,mDBFacade.validationToken,mDBFacade.demographics,rpcSuccessCallback,parseError);
         mGiftsInfo.removeKey(requestId);
         if(clearGiftCallback != null)
         {
            clearGiftCallback();
         }
      }
      
      public function acceptAllGifts(param1:ASFunction, param2:ASFunction = null) 
      {
         var clearGiftCallback= param1;
         var successCallback= param2;
         var rpcFunc= JSONRPCService.getFunction("AcceptAllGifts",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:ASFunction = function(param1:ASAny)
         {
            if(ASCompat.toBool(param1))
            {
               parseResponse(param1);
            }
            if(successCallback != null)
            {
               successCallback();
            }
         };
         var requestIds= mGiftsInfo.keysToArray();
         if(requestIds.length > 0)
         {
            rpcFunc(mDBFacade.dbAccountInfo.id,requestIds,mDBFacade.validationToken,mDBFacade.demographics,rpcSuccessCallback,parseError);
            mGiftsInfo.clear();
            if(clearGiftCallback != null)
            {
               clearGiftCallback();
            }
         }
      }
      
      public function declineGift(param1:String, param2:ASFunction = null) 
      {
         var requestId= param1;
         var successCallback= param2;
         var rpcFunc= JSONRPCService.getFunction("DeclineGift",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:ASFunction = function()
         {
            mGiftsInfo.removeKey(requestId);
            if(successCallback != null)
            {
               successCallback();
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,requestId,mDBFacade.validationToken,mDBFacade.demographics,rpcSuccessCallback,parseError);
      }
      
      public function sendGiftData(param1:UInt, param2:Array<ASAny>, param3:Array<ASAny>, param4:ASFunction = null) 
      {
         var offerId= param1;
         var requestIds= param2;
         var toIds= param3;
         var successCallback= param4;
         var rpcFunc= JSONRPCService.getFunction("GiftOffer",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:ASFunction = function(param1:ASAny)
         {
            if(successCallback != null)
            {
               successCallback();
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,offerId,mDBFacade.dbConfigManager.networkId,requestIds,toIds,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      public function sendFacebookRequestData(param1:Array<ASAny>, param2:Array<ASAny>, param3:ASFunction = null) 
      {
         var _loc4_= JSONRPCService.getFunction("AppRequests",mDBFacade.rpcRoot + "facebookrequests");
         _loc4_(mDBFacade.dbAccountInfo.id,param1,param2,mDBFacade.validationToken);
      }
      
      public function getGiftData(param1:ASFunction = null) 
      {
         var successCallback= param1;
         var rpcFunc= JSONRPCService.getFunction("GetAllGifts",mDBFacade.rpcRoot + "store");
         var rpcSuccessCallback:ASFunction = function(param1:ASAny)
         {
            parseGiftData(param1);
            if(successCallback != null)
            {
               successCallback();
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      function parseGiftData(param1:ASAny) 
      {
         var _loc3_:Array<ASAny> = null;
         var _loc2_:GiftInfo = null;
         var _loc4_= 0;
         if(ASCompat.toBool(param1))
         {
            if(ASCompat.toBool(param1.excludeIds))
            {
               mGiftExcludeIds = ASCompat.dynamicAs(param1.excludeIds , Array);
            }
            if(!ASCompat.toBool(param1.gifts))
            {
               return;
            }
            _loc3_ = ASCompat.dynamicAs(param1.gifts , Array);
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc2_ = new GiftInfo(mDBFacade,_loc3_[_loc4_]);
               if(!mGiftsInfo.has(_loc2_.requestId))
               {
                  mGiftsInfo.add(_loc2_.requestId,_loc2_);
               }
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
         }
      }
      
      public function addFriendCallback(param1:ASAny) 
      {
         var _loc2_:Array<ASAny> = null;
         var _loc5_:FriendInfo = null;
         var _loc4_= 0;
         var _loc3_= 0;
         if(ASCompat.toBool(param1))
         {
            _loc2_ = ASCompat.dynamicAs(param1 , Array);
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc3_ = (ASCompat.asUint(_loc2_[_loc4_].account_id ) : Int);
               if(!mFriendsInfo.hasKey(_loc3_))
               {
                  _loc5_ = new FriendInfo(mDBFacade,_loc2_[_loc4_]);
                  mFriendsInfo.add(_loc5_.id,_loc5_);
               }
               else
               {
                  _loc5_ = ASCompat.dynamicAs(mFriendsInfo.itemFor(_loc3_), account.FriendInfo);
                  _loc5_.parseFriendJson(_loc2_[_loc4_]);
               }
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
         }
         mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
      }
      
      public function removeFriendCallback(param1:ASAny) 
      {
         var _loc2_:Array<ASAny> = null;
         var _loc5_:ASAny = null;
         var _loc4_= 0;
         var _loc3_= 0;
         if(ASCompat.toBool(param1))
         {
            _loc2_ = ASCompat.dynamicAs(param1 , Array);
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc3_ = (ASCompat.asUint(_loc2_[_loc4_].account_id ) : Int);
               if(mFriendsInfo.hasKey(_loc3_))
               {
                  mFriendsInfo.removeKey(_loc3_);
               }
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
         }
         mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
      }
      
      public function isFriend(param1:UInt) : Bool
      {
         if(param1 == 0)
         {
            return false;
         }
         return mFriendsInfo.hasKey(param1);
      }
      
      public function getFriendData(param1:ASFunction) 
      {
         var successCallback= param1;
         var rpcFunc= JSONRPCService.getFunction("getFriendData",mDBFacade.rpcRoot + "leaderboard");
         var rpcSuccessCallback:ASFunction = function(param1:ASAny)
         {
            parseFriendData(param1);
            if(successCallback != null)
            {
               successCallback();
            }
            if(mInventory.canShowInfiniteIsland())
            {
               getAllMapnodeScoresRPC(mDBFacade.dbAccountInfo.id);
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.demographics,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      public function refreshFriendData(param1:ASAny) 
      {
         parseFriendData(param1);
      }
      
      public function getIgnoredFriendData(param1:ASFunction = null) 
      {
         var rpcFunc:ASFunction;
         var rpcSuccessCallback:ASFunction;
         var successCallback= param1;
         if(mIgnoredFriendsInfo.length > 0)
         {
            return;
         }
         rpcFunc = JSONRPCService.getFunction("getIgnoreFriendData",mDBFacade.rpcRoot + "leaderboard");
         rpcSuccessCallback = function(param1:ASAny)
         {
            parseIgnoredFriendData(param1);
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      function parseIgnoredFriendData(param1:ASAny) 
      {
         var _loc2_:Array<ASAny> = null;
         var _loc5_:FriendInfo = null;
         var _loc4_= 0;
         var _loc3_= 0;
         if(ASCompat.toBool(param1))
         {
            _loc2_ = ASCompat.dynamicAs(param1 , Array);
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc3_ = (ASCompat.asUint(_loc2_[_loc4_].account_id ) : Int);
               if(!mFriendsInfo.hasKey(_loc3_))
               {
                  _loc5_ = new FriendInfo(mDBFacade,_loc2_[_loc4_]);
                  mIgnoredFriendsInfo.push(_loc5_);
               }
               else
               {
                  _loc5_ = mIgnoredFriendsInfo[_loc4_];
                  _loc5_.parseFriendJson(_loc2_[_loc4_]);
               }
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
         }
      }
      
      function friendlistUpdate(param1:FriendStatusEvent) 
      {
         var successCallback:ASFunction;
         var event= param1;
         if(event.status == false || mFriendsInfo.hasKey(event.friendId))
         {
            return;
         }
         successCallback = function()
         {
            mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
         };
         getFriendData(successCallback);
      }
      
      function parseFriendData(param1:ASAny, param2:Bool = false) 
      {
         var myself:FriendInfo;
         var friendsArray:Array<ASAny>;
         var friendInfo:FriendInfo;
         var i:UInt;
         var friendId:UInt;
         var friends:ASAny = param1;
         var purge= param2;
         var myObject:ASObject = {
            "account_id":this.mId,
            "name":this.mName,
            "trophies":this.trophies,
            "facebook_id":mDBFacade.facebookPlayerId,
            "kongregate_id":mDBFacade.kongregatePlayerId,
            "status_online":true,
            "in_dungeon":false
         };
         if(purge)
         {
            mFriendsInfo.clear();
         }
         if(!mFriendsInfo.hasKey(this.mId))
         {
            myself = new FriendInfo(mDBFacade,myObject);
            mFriendsInfo.add(myself.id,myself);
         }
         else
         {
            myself = ASCompat.dynamicAs(mFriendsInfo.itemFor(this.mId), account.FriendInfo);
            myself.parseFriendJson(myObject);
         }
         mEventComponent.addListener("TrophiesUpdatedAccountEvent",function(param1:TrophiesUpdatedAccountEvent)
         {
            myself = ASCompat.dynamicAs(mFriendsInfo.itemFor(mId), account.FriendInfo);
            myself.trophies = param1.trophyCount;
         });
         mLocalFriendInfo = myself;
         mEventComponent.addListener("FRIEND_STATUS_EVENT",friendlistUpdate);
         if(mDBFacade.facebookController != null && activeAvatarInfo.level >= 5)
         {
            mDBFacade.facebookController.updateGuestAchievement((2 : UInt));
         }
         if(ASCompat.toBool(friends))
         {
            friendsArray = ASCompat.dynamicAs(friends , Array);
            i = (0 : UInt);
            while(i < (friendsArray.length : UInt))
            {
               friendId = ASCompat.asUint(friendsArray[(i : Int)].account_id );
               if(!mFriendsInfo.hasKey(friendId))
               {
                  friendInfo = new FriendInfo(mDBFacade,friendsArray[(i : Int)]);
                  mFriendsInfo.add(friendInfo.id,friendInfo);
               }
               else
               {
                  friendInfo = ASCompat.dynamicAs(mFriendsInfo.itemFor(friendId), account.FriendInfo);
                  friendInfo.parseFriendJson(friendsArray[(i : Int)]);
               }
               i = i + 1;
            }
         }
      }
      
      public function addAchievement(param1:String, param2:String, param3:ASFunction) 
      {
         var achievementId= param1;
         var achievementURL= param2;
         var achievementCallback= param3;
         var rpcFunc= JSONRPCService.getFunction("AddAchievement",mDBFacade.rpcRoot + "achievement");
         var successCallback:ASFunction = function(param1:ASAny)
         {
            achievementCallback(achievementId);
            Logger.info("achievement success");
         };
         var failCallback:ASFunction = function(param1:ASAny)
         {
         };
         rpcFunc(mDBFacade.accountId,mDBFacade.validationToken,mDBFacade.facebookPlayerId,achievementURL,successCallback,failCallback);
      }
      
      public function setPresenceTask(param1:String) 
      {
         if(mOnlinePresenceTask != null)
         {
            mOnlinePresenceTask.destroy();
         }
         SocketPingMilsecs = -1;
         mLastFPSTime = (mDBFacade.gameClock.realTime : UInt);
         mLastFPSFrame = mDBFacade.gameClock.frame;
         mFPSLocation = param1;
         setOnlinePresence(mDBFacade.gameClock);
         mOnlinePresenceTask = mDBFacade.realClockWorkManager.doEverySeconds(60,setOnlinePresence);
      }
      
      function setOnlinePresence(param1:GameClock) 
      {
         var _loc6_= (param1.realTime : UInt);
         var _loc4_= param1.frame;
         var _loc2_= (_loc6_ - mLastFPSTime) / 1000;
         var _loc5_= Std.int(_loc2_ > 0 ? Math.round((_loc4_ - mLastFPSFrame) / _loc2_) : -1);
         mLastFPSTime = _loc6_;
         mLastFPSFrame = _loc4_;
         var _loc3_:ASObject = {};
         if(SocketPingMilsecs > 0)
         {
            _loc3_["socketPingMilsecs"] = SocketPingMilsecs;
         }
         _loc3_["memory"] = Math.fround(System.totalMemory / 1024 / 1024);
         if(_loc5_ >= 0)
         {
            _loc3_["fps"] = _loc5_;
            _loc3_["fpsLocation"] = mFPSLocation;
         }
         mDBFacade.metrics.log("Presence",_loc3_);
      }
      
      public function getFacebookIdRPC(param1:UInt, param2:ASFunction) 
      {
         var remoteId= param1;
         var successCallback= param2;
         var rpcFunc= JSONRPCService.getFunction("GetFacebookId",mDBFacade.rpcRoot + "account");
         var rpcSuccessCallback:ASFunction = function(param1:String)
         {
            successCallback(param1);
         };
         rpcFunc(remoteId,id,mDBFacade.validationToken,rpcSuccessCallback,parseError);
      }
      
      @:isVar public var basicCurrency(get,never):UInt;
public function  get_basicCurrency() : UInt
      {
         return mBasicCurrency;
      }
      
      @:isVar public var premiumCurrency(get,never):UInt;
public function  get_premiumCurrency() : UInt
      {
         return mPremiumCurrency;
      }
      
      @:isVar public var trophies(get,never):UInt;
public function  get_trophies() : UInt
      {
         return mTrophyCount;
      }
      
      public function hasAllTrophies() : Bool
      {
         if(mTrophyCount >= 106)
         {
            return true;
         }
         return false;
      }
      
      @:isVar public var activeAvatarInfo(get,never):AvatarInfo;
public function  get_activeAvatarInfo() : AvatarInfo
      {
         return mActiveAvatar;
      }
      
      @:isVar public var highestAvatarLevel(get,never):UInt;
public function  get_highestAvatarLevel() : UInt
      {
         return mInventory.highestAvatarLevel;
      }
      
      @:isVar public var friendInfos(get,never):Map;
public function  get_friendInfos() : Map
      {
         return mFriendsInfo;
      }
      
      @:isVar public var gifts(get,never):Map;
public function  get_gifts() : Map
      {
         return mGiftsInfo;
      }
      
      @:isVar public var ignoredFriends(get,never):Vector<FriendInfo>;
public function  get_ignoredFriends() : Vector<FriendInfo>
      {
         return mIgnoredFriendsInfo;
      }
      
            
      @:isVar public var giftExcludeIds(get,set):Array<ASAny>;
public function  get_giftExcludeIds() : Array<ASAny>
      {
         return mGiftExcludeIds;
      }
function  set_giftExcludeIds(param1:Array<ASAny>) :Array<ASAny>      {
         return mGiftExcludeIds = param1;
      }
      
      @:isVar public var accountCreatedDate(get,never):String;
public function  get_accountCreatedDate() : String
      {
         return mAccountCreatedDate;
      }
      
            
      @:isVar public var account_flags(get,set):UInt;
public function  set_account_flags(param1:UInt) :UInt      {
         return mAccountFlags = param1;
      }
function  get_account_flags() : UInt
      {
         return mAccountFlags;
      }
      
      function parseAttributes(param1:Array<ASAny>) 
      {
         mAttributes.clear();
         var _loc2_:ASAny;
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc2_ = _tmp_;
            mAttributes.add(_loc2_.name,_loc2_.value);
         }
      }
      
      function parseCurrency(param1:ASObject) 
      {
         mPremiumCurrency = (ASCompat.toInt(param1.premium_currency) : UInt);
         mBasicCurrency = (ASCompat.toInt(param1.basic_currency) : UInt);
         mTrophyCount = (ASCompat.toInt(param1.trophies) : UInt);
         mEventComponent.dispatchEvent(new CurrencyUpdatedAccountEvent(mBasicCurrency,mPremiumCurrency));
         mEventComponent.dispatchEvent(new TrophiesUpdatedAccountEvent(mTrophyCount));
      }
      
      public function changeActiveAvatarRPC(param1:UInt) 
      {
         var heroType= param1;
         var rpcFunc= JSONRPCService.getFunction("setActiveAvatar",mDBFacade.rpcRoot + "avatarrecord");
         var avatarInfo= mInventory.getAvatarInfoForHeroType(heroType);
         if(avatarInfo != null)
         {
            mActiveAvatar = avatarInfo;
            mUpdateMessagePopup = new DBUIPopup(mDBFacade,Locale.getString("SHOP_UPDATING"),null,false);
            MemoryTracker.track(mUpdateMessagePopup,"DBUIPopup - created in DBAccountInfo.changeActiveAvatarRPC()");
            rpcFunc(mDBFacade.validationToken,mDBFacade.dbAccountInfo.id,avatarInfo.id,avatarInfo.skinId,function(param1:ASAny)
            {
               mUpdateMessagePopup.destroy();
               parseResponse(param1);
            },parseError);
         }
      }
      
      public function getAllMapnodeScoresRPC(param1:UInt) 
      {
         var avatarArray:Array<ASAny>;
         var rpcFunc:ASFunction;
         var requestor= param1;
         if(requestor != mDBFacade.dbAccountInfo.id)
         {
            Logger.debug("getAllMapnodeScoresRPC: requestor not mDBFacade.dbAccountInfo.id...return");
            return;
         }
         if(friendInfos.size == 0)
         {
            Logger.debug("getAllMapnodeScoresRPC: friendInfo not set yet...return");
            return;
         }
         avatarArray = mDBFacade.dbAccountInfo.inventoryInfo.avatars.keysToArray();
         rpcFunc = JSONRPCService.getFunction("getAllMapnodeScores",mDBFacade.rpcRoot + "championsboard");
         rpcFunc(mDBFacade.dbAccountInfo.id,friendInfos.keysToArray(),avatarArray,mDBFacade.validationToken,function(param1:ASAny)
         {
            parseScoreResponse(param1);
         },parseError);
      }
      
      public function updateFacebookFriendsRPC(param1:Array<ASAny>, param2:String, param3:Bool) 
      {
         var friends= param1;
         var newFriendsHash= param2;
         var cascade= param3;
         var rpcFunc= JSONRPCService.getFunction("updateFBFriends",mDBFacade.rpcRoot + "leaderboard");
         var callback:ASFunction = function(param1:ASAny)
         {
            mCurrentFriendsHash = newFriendsHash;
            parseFriendData(param1);
            mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,friends,newFriendsHash,cascade,callback);
      }
      
      public function updateDRFriendsRPC(param1:Array<ASAny>, param2:String) 
      {
         var _loc3_= JSONRPCService.getFunction("inviteNewDRFriends",mDBFacade.rpcRoot + "leaderboard");
         mCurrentFriendsHash = param2;
         _loc3_(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,param1,param2,mDBFacade.dbAccountInfo.name,mDBFacade.dbAccountInfo.trophies,mDBFacade.dbAccountInfo.activeAvatarSkinId,mDBFacade.dbAccountInfo.facebookId);
      }
      
      public function updateKongregateFriendsRPC(param1:Array<ASAny>, param2:String, param3:Bool) 
      {
         var friends= param1;
         var newFriendsHash= param2;
         var cascade= param3;
         var rpcFunc= JSONRPCService.getFunction("updateKongregateFriends",mDBFacade.rpcRoot + "leaderboard");
         var callback:ASFunction = function(param1:ASAny)
         {
            mCurrentFriendsHash = newFriendsHash;
            parseFriendData(param1);
            mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
         };
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,friends,newFriendsHash,cascade,callback);
      }
      
      public function parseFriendResponse(param1:ASAny, param2:Bool = true) 
      {
         if(ASCompat.toBool(param1.friends_hash))
         {
            mCurrentFriendsHash = ASCompat.asString(param1.friends_hash );
         }
      }
      
      public function parseScoreResponse(param1:ASObject, param2:Bool = true) 
      {
         if(param1 == null)
         {
            Logger.error("Got empty array on parseScoreResponse");
            return;
         }
         var _loc4_= new II_AccountTopScoreInfo(param1.top_scores);
         var _loc3_= ASCompat.reinterpretAs(friendInfos.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc3_.next();
            _loc3_.current.parseChampionsboardData(_loc4_.accountIdToTopScoreMapnodeInfo.itemFor(_loc3_.current.id));
            if(ASCompat.toNumberField(_loc3_.current, "id") == mDBFacade.accountId)
            {
               _loc3_.current.parseIIAvatarScoresData(param1.avatar_scores);
            }
         }
      }
      
      public function parseResponse(param1:ASAny, param2:Bool = true) 
      {
         if(param1 == null || ASCompat.toNumberField(param1, "length") <= 0)
         {
            Logger.error("Got empty array on parseResponse");
            return;
         }
         mCompletedMapnodeMask.init(param1.completed_mapnode_mask);
         mAccountFlags = ASCompat.asUint(param1.account_flags );
         var _loc3_= ASCompat.toInt(param1.active_avatar);
         mInventory.parseJson(param1);
         mActiveAvatar = mInventory.getAvatarInfoForAvatarInstanceId((_loc3_ : UInt));
         mEventComponent.dispatchEvent(new Event("ACTIVE_AVATAR_CHANGED_EVENT"));
         parseCurrency(param1);
         if(ASCompat.toBool(param1.account_attributes))
         {
            parseAttributes(ASCompat.dynamicAs(param1.account_attributes, Array));
         }
         mId = (ASCompat.toInt(param1.id) : UInt);
         mName = param1.name;
         mInventoryLimitWeapons = (ASCompat.toInt(param1.buckets_weapon) : UInt);
         mInventoryLimitOther = (ASCompat.toInt(param1.buckets_other) : UInt);
         mAccountCreatedDate = ASCompat.asString(param1.created );
         mDungeonsCompleted = (ASCompat.toInt(param1.completed_dungeons) : UInt);
         mDBAccountParams = new DBAccountParams(mDBFacade,this);
         if(param2)
         {
            mEventComponent.dispatchEvent(new DBAccountResponseEvent(this));
         }
      }
      
      public function getCompletedMapnodeMask() : Utf8BitArray
      {
         return mCompletedMapnodeMask;
      }
      
      function parseError(param1:Error) 
      {
         if(mErrorPopUp != null)
         {
            return;
         }
         mErrorPopUp = new DBUIPopup(mDBFacade,"Error getting account info.");
         MemoryTracker.track(mErrorPopUp,"DBUIPopup - created in DBAccountInfo.parseError()");
         mLogicalWorkComponent.doLater(1.5,killErrorPopUp);
      }
      
      function killErrorPopUp(param1:GameClock) 
      {
         if(mErrorPopUp != null)
         {
            mErrorPopUp.destroy();
            mErrorPopUp = null;
         }
      }
      
      @:isVar public var dbAccountParams(get,never):DBAccountParams;
public function  get_dbAccountParams() : DBAccountParams
      {
         return mDBAccountParams;
      }
      
      public function incrementCompletedDungeons() 
      {
         mDungeonsCompleted = mDungeonsCompleted + 1;
      }
      
      public function getDungeonsCompleted() : UInt
      {
         return mDungeonsCompleted;
      }
      
      @:isVar public var localFriendInfo(get,never):FriendInfo;
public function  get_localFriendInfo() : FriendInfo
      {
         return mLocalFriendInfo;
      }
   }


