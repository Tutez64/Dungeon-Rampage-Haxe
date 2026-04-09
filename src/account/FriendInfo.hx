package account
;
   import account.iI.II_AvatarMapnodeScore;
   import account.iI.II_AvatarsScoresInfo;
   import account.iI.II_FriendChampionsboardInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import gameMasterDictionary.GMSkin;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
    class FriendInfo
   {
      
      public static var FRIEND_SCORES_PARSED:String = "FRIEND_SCORES_PARSED";
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mRoot:MovieClip;
      
      var mAccountId:UInt = 0;
      
      var mIsDRFriend:Bool = false;
      
      var mFacebookId:String;
      
      var mKongregateId:String;
      
      var mFriendName:String;
      
      var mTrophies:UInt = 0;
      
      var mGMSkin:GMSkin;
      
      var mIcon:MovieClip;
      
      var mDBFacade:DBFacade;
      
      var mResponseCallback:ASFunction;
      
      var mProfilePic:DisplayObject;
      
      var mProfilePicBitmap:Bitmap;
      
      var mIILeaderboardInfo:II_FriendChampionsboardInfo;
      
      var mIIAvatarScoresInfo:II_AvatarsScoresInfo;
      
      var mEventComponent:EventComponent;
      
      public function new(param1:DBFacade, param2:ASObject, param3:ASFunction = null)
      {
         
         mResponseCallback = param3;
         mDBFacade = param1;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         parseFriendJson(param2);
      }
      
      function loadHeroIcon() : DisplayObject
      {
         var swfPath= mGMSkin.UISwfFilepath;
         var iconName= mGMSkin.IconName;
         if(mIcon != null && mRoot != null && mRoot.contains(mIcon))
         {
            mRoot.removeChild(mIcon);
         }
         mIcon = new MovieClip();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc4_= param1.getClass(iconName);
            var _loc3_= ASCompat.dynamicAs(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
            var _loc2_= (50 : UInt);
            UIObject.scaleToFit(_loc3_,_loc2_);
            _loc3_.x = 25;
            _loc3_.y = 25;
            mIcon.addChild(_loc3_);
         });
         return mIcon;
      }
      
      public function parseFriendJson(param1:ASObject) 
      {
         var identifier:Array<ASAny>;
         var network:String = null;
         var key:String;
         var loader:Loader;
         var picUrl:String;
         var url:URLRequest;
         var skinId:UInt;
         var avatarInfo:AvatarInfo;
         var context:LoaderContext;
         var friendJson:ASObject = param1;
         if(friendJson == null)
         {
            return;
         }
         mAccountId = ASCompat.asUint(friendJson.account_id );
         mFriendName = ASCompat.asString(friendJson.name );
         mTrophies = ASCompat.asUint(friendJson.trophies );
         mFacebookId = ASCompat.asString(friendJson.facebook_id );
         mKongregateId = ASCompat.asString(friendJson.kongregate_id );
         if(ASCompat.toBool(friendJson.is_ingame_friend))
         {
            mIsDRFriend = ASCompat.asBool(friendJson.is_ingame_friend );
         }
         if(ASCompat.toBool(friendJson.identifier))
         {
            identifier = ASCompat.dynamicAs(friendJson.identifier.split("_"), Array);
            if(identifier.length > 1)
            {
               network = identifier[0];
               key = identifier[1];
            }
            else
            {
               key = identifier[0];
            }
            if(network == "1")
            {
               mFacebookId = key;
            }
            else if(network == "2")
            {
               mKongregateId = key;
            }
         }
         if(mProfilePic == null)
         {
            loader = new Loader();
            picUrl = "";
            if(!ASCompat.stringAsBool(this.facebookId) || this.facebookId == "" || mDBFacade.isDRPlayer)
            {
               avatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType);
               if(avatarInfo == null)
               {
                  mGMSkin = mDBFacade.gameMaster.getSkinByType((164 : UInt));
               }
               else
               {
                  if(friendJson.hasOwnProperty("active_skin"))
                  {
                     skinId = (ASCompat.toInt(friendJson.active_skin) : UInt);
                  }
                  else
                  {
                     skinId = avatarInfo.skinId;
                  }
                  mGMSkin = mDBFacade.gameMaster.getSkinByType(skinId);
               }
               mProfilePic = loadHeroIcon();
            }
            else if(mFacebookId != null || mFacebookId != "")
            {
               context = new LoaderContext();
               context.checkPolicyFile = true;
               context.applicationDomain = ApplicationDomain.currentDomain;
               picUrl = "https://graph.facebook.com/" + mFacebookId + "/picture";
               url = new URLRequest(picUrl);
               loader.contentLoaderInfo.addEventListener("ioError",ignoreError);
               loader.contentLoaderInfo.addEventListener("securityError",function(param1:flash.events.SecurityErrorEvent)
               {
                  Logger.error("parseFriendJson :" + param1.toString() + " Data:" + Std.string(url.data) + " URL:" + picUrl);
               });
               loader.contentLoaderInfo.addEventListener("complete",function(param1:Event)
               {
                  loader.cacheAsBitmap = true;
                  mProfilePicBitmap = ASCompat.reinterpretAs(loader.content , Bitmap);
               });
               loader.load(url,context);
               mProfilePic = loader;
            }
         }
         if(mResponseCallback != null)
         {
            mResponseCallback();
         }
      }
      
      public function parseChampionsboardData(param1:II_FriendChampionsboardInfo) 
      {
         mIILeaderboardInfo = param1;
      }
      
      public function parseIIAvatarScoresData(param1:ASObject) 
      {
         mIIAvatarScoresInfo = new II_AvatarsScoresInfo(param1);
         mEventComponent.dispatchEvent(new Event(FRIEND_SCORES_PARSED));
      }
      
      function ignoreError(param1:Event) 
      {
      }
      
      @:isVar public var pic(get,never):DisplayObject;
public function  get_pic() : DisplayObject
      {
         return mProfilePic;
      }
      
      public function clonePic() : DisplayObject
      {
         var loader:Loader;
         var picUrl:String;
         var url:URLRequest;
         var lc:LoaderContext;
         var clone:DisplayObject;
         if(this.facebookId == null || this.facebookId == "")
         {
            return loadHeroIcon();
         }
         if(mProfilePicBitmap == null)
         {
            loader = new Loader();
            picUrl = "https://graph.facebook.com/" + mFacebookId + "/picture";
            url = new URLRequest(picUrl);
            loader.contentLoaderInfo.addEventListener("ioError",ignoreError);
            loader.contentLoaderInfo.addEventListener("securityError",function(param1:flash.events.SecurityErrorEvent)
            {
               Logger.error("clonePic: " + param1.toString() + " Data:" + Std.string(url.data) + " URL:" + picUrl);
            });
            lc = new LoaderContext(true);
            lc.checkPolicyFile = true;
            loader.load(url,lc);
            return loader;
         }
         clone = new Bitmap(mProfilePicBitmap.bitmapData) ;
         return clone;
      }
      
      @:isVar public var id(get,never):UInt;
public function  get_id() : UInt
      {
         return mAccountId;
      }
      
      @:isVar public var isDRFriend(get,never):Bool;
public function  get_isDRFriend() : Bool
      {
         return mIsDRFriend;
      }
      
      @:isVar public var facebookId(get,never):String;
public function  get_facebookId() : String
      {
         return mFacebookId;
      }
      
      @:isVar public var kongregateId(get,never):String;
public function  get_kongregateId() : String
      {
         return mKongregateId;
      }
      
            
      @:isVar public var trophies(get,set):UInt;
public function  get_trophies() : UInt
      {
         return mTrophies;
      }
function  set_trophies(param1:UInt) :UInt      {
         return mTrophies = param1;
      }
      
      @:isVar public var lastMapNode(get,never):UInt;
public function  get_lastMapNode() : UInt
      {
         if(mDBFacade.mDistributedObjectManager != null && mDBFacade.mDistributedObjectManager.mPresenceManager != null)
         {
            return mDBFacade.mDistributedObjectManager.mPresenceManager.InDungeonId(mAccountId);
         }
         return (0 : UInt);
      }
      
      public function isOnline() : Bool
      {
         if(mAccountId == mDBFacade.dbAccountInfo.id)
         {
            return true;
         }
         if(mDBFacade.mDistributedObjectManager != null && mDBFacade.mDistributedObjectManager.mPresenceManager != null)
         {
            return mDBFacade.mDistributedObjectManager.mPresenceManager.isOnline(mAccountId);
         }
         return false;
      }
      
      public function isInDungeon() : Bool
      {
         if(mDBFacade.mDistributedObjectManager != null && mDBFacade.mDistributedObjectManager.mPresenceManager != null)
         {
            return mDBFacade.mDistributedObjectManager.mPresenceManager.isInDungeon(mAccountId);
         }
         return false;
      }
      
      @:isVar public var name(get,never):String;
public function  get_name() : String
      {
         return mFriendName;
      }
      
      @:isVar public var excludeId(get,never):String;
public function  get_excludeId() : String
      {
         if(mDBFacade.isDRPlayer || this.isDRFriend)
         {
            return Std.string(this.id);
         }
         if(mDBFacade.isFacebookPlayer && ASCompat.stringAsBool(this.facebookId))
         {
            return this.facebookId.toString();
         }
         if(mDBFacade.isKongregatePlayer && ASCompat.stringAsBool(this.kongregateId))
         {
            return this.kongregateId.toString();
         }
         return "not found";
      }
      
      public function getWeaponsUsedForNode(param1:UInt) : Array<Dynamic>
      {
         if(mIILeaderboardInfo != null)
         {
            return mIILeaderboardInfo.getWeaponsForNodeId(param1);
         }
         return new Array<Dynamic>();
      }
      
      public function getIILeaderboardScoreForNode(param1:Int) : Int
      {
         if(mIILeaderboardInfo != null && mIILeaderboardInfo.nodeIdToScore.hasKey(param1))
         {
            return ASCompat.toInt(mIILeaderboardInfo.nodeIdToScore.itemFor(param1));
         }
         return 0;
      }
      
      public function getIILeaderboardAvatarSkinForNode(param1:Int) : Int
      {
         if(mIILeaderboardInfo != null && mIILeaderboardInfo.nodeIdToActiveSkin.hasKey(param1))
         {
            return ASCompat.toInt(mIILeaderboardInfo.nodeIdToActiveSkin.itemFor(param1));
         }
         return 151;
      }
      
      public function getIIAvatarScoreForNode(param1:Int, param2:Int) : Int
      {
         var _loc3_= 0;
         if(mIIAvatarScoresInfo == null)
         {
            return 0;
         }
         var _loc4_= ASCompat.dynamicAs(mIIAvatarScoresInfo.avatarIdToAvatarScore.itemFor(param1), account.iI.II_AvatarMapnodeScore);
         if(_loc4_ != null)
         {
            _loc3_ = ASCompat.toInt(_loc4_.nodeIdToScore.itemFor(param2));
            if(_loc3_ != 0)
            {
               return _loc3_;
            }
         }
         return 0;
      }
   }


