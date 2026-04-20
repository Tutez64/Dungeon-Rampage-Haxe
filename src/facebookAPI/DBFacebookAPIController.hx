package facebookAPI
;
   import brain.facebookAPI.FacebookAPIController;
   import brain.logger.Logger;
   import brain.utils.SplitTestRules;
   import facade.DBFacade;
   import gameMasterDictionary.GMAchievement;
   import gameMasterDictionary.GMFeedPosts;
   import metrics.PixelTracker;
   import com.adobe.serialization.json.JSON;
   import com.facebook.graph.Facebook;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
    class DBFacebookAPIController extends FacebookAPIController
   {
      
      public static inline final PURCHASE= "PURCHASE";
      
      public static inline final CHEST_UNLOCK= "CHEST_UNLOCK";
      
      public static inline final MAP_NODE_DEFEATED= "MAP_NODE_DEFEATED";
      
      public static inline final LEADERBOARD_OFFLINE_MESSAGE= "MESSAGE";
      
      public static inline final INVITE_FRIEND_REQUEST= "INVITE_REQUEST";
      
      public static inline final SEND_GIFT_REQUEST= "SEND_GIFT_REQUEST";
      
      public static inline final METRICS_PERSONAL_WALL_POST= "dbfbwp";
      
      public static inline final METRICS_FRIEND_WALL_POST= "dbfbwf";
      
      public static inline final COMPLETED_FIRST_DUNGEON_ACHIEVEMENT= (1 : UInt);
      
      public static inline final CHARACTER_LEVEL_ACHIEVEMENT_1= (2 : UInt);
      
      public static inline final MEDIC_ACHIEVEMENT= (3 : UInt);
      
      public static inline final SOCIALITE_ACHIEVEMENT= (4 : UInt);
      
      public static inline final BIG_BALLER_ACHIEVEMENT= (5 : UInt);
      
      public static inline final DEATH_ACHIEVEMENT= (6 : UInt);
      
      public static inline final LEVEL_ACHIEVEMENT_1= (5 : UInt);
      
      public static inline final DEATH_ACHIEVEMENT_1= (10 : UInt);
      
      var dbFacebook_script_js:compat.XML;
      
      var mDBFacade:DBFacade;
      
      var mLeaderBoardFeedPosts:Vector<GMFeedPosts>;
      
      var mFriendInvitePosts:Vector<GMFeedPosts>;
      
      var mGiftFriendPosts:Vector<GMFeedPosts>;
      
      var mLevelUpPostController:DBFacebookLevelUpPostController;
      
      var mAppURL:String;
      
      var mFeedLink:String;
      
      var mThirdPartyId:String = "";
      
      var mFriendsCallIsRunning:Bool = false;
      
      public function new(param1:DBFacade)
      {
         var _loc2_= 0;
         dbFacebook_script_js = /*<script>
				<![CDATA[
                function()
                {
                    DBFacebook =
                    {
                        debugResults : function(debugData)
                        {
                            console.log(debugData);
                        },
                        getAppURL : function()
                        {
                            return window.location.href;
                        }
                    };
                }
				]]>
			</script>*/ null;
         super(param1,param1.facebookId);
         mScope = "user_birthday,email,publish_actions";
         mDBFacade = param1;
         if(ExternalInterface.available)
         {
            ExternalInterface.call(dbFacebook_script_js.toString());
            mAppURL = ExternalInterface.call("DBFacebook.getAppURL");
         }
         else
         {
            mAppURL = "./";
         }
         Logger.debug("DBFacebookAPIController: " + mAppURL);
         if(mDBFacade.isFacebookPlayer)
         {
            _loc2_ = mAppURL.indexOf("facebook/");
         }
         else if(mDBFacade.isKongregatePlayer)
         {
            _loc2_ = mAppURL.indexOf("kongregate/");
         }
         else
         {
            _loc2_ = 0;
         }
         if(_loc2_ > 0)
         {
            mAppURL = mAppURL.substring(0,_loc2_);
         }
         Logger.debug("DBFacebookAPIController: " + mAppURL);
         mLeaderBoardFeedPosts = new Vector<GMFeedPosts>();
         mFriendInvitePosts = new Vector<GMFeedPosts>();
         mGiftFriendPosts = new Vector<GMFeedPosts>();
         mLevelUpPostController = new DBFacebookLevelUpPostController(mDBFacade,dbFeedPost);
         mFeedLink = "http://apps.facebook.com/" + mDBFacade.facebookApplication.toString();
      }
      
      public static function getFeedPosts(param1:DBFacade, param2:UInt, param3:String) : Vector<GMFeedPosts>
      {
         var _loc5_= new Vector<GMFeedPosts>();
         var _loc4_:GMFeedPosts;
         final __ax4_iter_188 = param1.gameMaster.FeedPosts;
         if (checkNullIteratee(__ax4_iter_188)) for (_tmp_ in __ax4_iter_188)
         {
            _loc4_ = _tmp_;
            if(_loc4_.Category == param3 && ASCompat.toNumberField(_loc4_, "IdTrigger") == param2)
            {
               _loc5_.push(_loc4_);
            }
         }
         return _loc5_;
      }
      
      public static function earnCredits(param1:DBFacade, param2:ASFunction) 
      {
         if(!param1.isFacebookPlayer)
         {
            return;
         }
         Logger.debug("earnCredits: " + Std.string(param1.dbAccountInfo.id));
         var _loc3_= param1.facebookController.appUrl + "currencyoffers/inappcurrencyoffers";
         var _loc4_:ASObject = {
            "action":"earn_currency",
            "product":_loc3_
         };
         if(param1.facebookThirdPartyId == "0")
         {
            param1.facebookController.queryThirdPartyId(callJSEarnCurrency);
         }
         else
         {
            callJSEarnCurrency(param1,param1.facebookThirdPartyId);
         }
      }
      
      static function callJSEarnCurrency(param1:DBFacade, param2:String) 
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("earnCredits",param2);
         }
      }
      
      public function queryThirdPartyId(param1:ASFunction = null) 
      {
         var loginCallback:ASFunction;
         var callback= param1;
         if(!mDBFacade.isFacebookPlayer)
         {
            return;
         }
         if(!ASCompat.stringAsBool(mAccessToken))
         {
            loginCallback = function()
            {
               getNewThirdPartyId(callback);
            };
            handleLogin(loginCallback);
         }
         else
         {
            getNewThirdPartyId(callback);
         }
      }
      
      function getNewThirdPartyId(param1:ASFunction = null) 
      {
         var callback= param1;
         if(!mDBFacade.isFacebookPlayer)
         {
            return;
         }
         Facebook.api("/me",function(param1:ASObject, param2:ASObject)
         {
            if(ASCompat.toBool(param1))
            {
               mThirdPartyId = param1.third_party_id;
               mDBFacade.facebookThirdPartyId = mThirdPartyId;
               if(callback != null)
               {
                  callback(mDBFacade,mThirdPartyId);
               }
            }
            if(ASCompat.toBool(param2))
            {
               Logger.debug("failed to get third party id");
            }
         },{"fields":"third_party_id"});
      }
      
      public function getFacebookFriendsHash() 
      {
         if(mDBFacade.isKongregatePlayer || mDBFacade.isDRPlayer)
         {
            return;
         }
         if(mFriendsCallIsRunning)
         {
            return;
         }
         friendsHash();
      }
      
      function friendsHash(param1:Bool = false) 
      {
         var isRetry= param1;
         mFriendsCallIsRunning = true;
         Facebook.api("/me/friends",function(param1:ASObject, param2:ASObject)
         {
            var fbIdArray:Array<ASAny>;
            var fbObject:ASObject;
            var fbIdString:String;
            var id:String;
            var currentFriendsHash:String;
            var newFriendHash:String;
            var cascade:Bool;
            var loginCallback:ASFunction;
            var response:ASObject = param1;
            var fail:ASObject = param2;
            Logger.debug("Obtained friends from facebook");
            mFriendsCallIsRunning = false;
            if(ASCompat.toBool(response))
            {
               fbIdArray = [];
               if (checkNullIteratee(response)) for (_tmp_ in iterateDynamicValues(response))
               {
                  fbObject  = _tmp_;
                  fbIdArray.push(fbObject.id);
               }
               fbIdArray.sort(Reflect.compare);
               fbIdString = "";
               if (checkNullIteratee(fbIdArray)) for (_tmp_ in fbIdArray)
               {
                  id  = _tmp_;
                  fbIdString = fbIdString + id + ",";
               }
               currentFriendsHash = mDBFacade.dbAccountInfo.currentFacebookFriendsHash;
               newFriendHash = SplitTestRules.getStringHash(fbIdString);
               if(newFriendHash != currentFriendsHash)
               {
                  cascade = false;
                  if(currentFriendsHash == "" || currentFriendsHash == null)
                  {
                     cascade = true;
                  }
                  if(mDBFacade.isFacebookPlayer)
                  {
                     mDBFacade.dbAccountInfo.updateFacebookFriendsRPC(fbIdArray,newFriendHash,cascade);
                  }
                  else if(mDBFacade.isDRPlayer)
                  {
                     mDBFacade.dbAccountInfo.updateDRFriendsRPC(fbIdArray,newFriendHash);
                  }
               }
            }
            else
            {
               Logger.debug("FB /me/friends call failed");
               if(!isRetry)
               {
                  loginCallback = function()
                  {
                     friendsHash(true);
                  };
                  handleLogin(loginCallback);
               }
            }
         });
      }
      
      public function getKongregateFriendsHash() 
      {
         var _loc1_:ASAny = mDBFacade.kongregateAPI;
         if(ASCompat.toBool(_loc1_.services.isGuest()))
         {
            return;
         }
         var _loc2_:Array<ASAny> = [];
         loadKongregateFriendRequest(1,_loc2_);
      }
      
      function loadKongregateFriendRequest(param1:Int, param2:Array<ASAny>) 
      {
         var urlReq:URLRequest;
         var context:LoaderContext;
         var urlLoader:URLLoader;
         var cb:ASFunction;
         var page= param1;
         var friendIdsArray= param2;
         var kongregateAPI:ASAny = mDBFacade.kongregateAPI;
         var urlVars= new URLVariables();
         var userId:String = kongregateAPI.services.getUserId();
         ASCompat.setProperty(urlVars, "user_id", userId);
         ASCompat.setProperty(urlVars, "page_num", page);
         ASCompat.setProperty(urlVars, "friends", true);
         urlReq = new URLRequest("http://api.kongregate.com/api/user_info.json");
         urlReq.data = urlVars;
         urlReq.method = "GET";
         context = new LoaderContext();
         context.checkPolicyFile = true;
         context.applicationDomain = ApplicationDomain.currentDomain;
         urlLoader = new URLLoader(urlReq);
         cb = function(param1:Event)
         {
            kongregateFriendResponse(param1,friendIdsArray);
         };
         urlLoader.addEventListener("ioError",ioErrorHandler);
         urlLoader.addEventListener("securityError",securityErrorHandler);
         urlLoader.addEventListener("complete",cb);
         urlLoader.load(urlReq);
      }
      
      function kongregateFriendResponse(param1:Event, param2:Array<ASAny>) 
      {
         var _loc3_:ASObject = com.adobe.serialization.json.JSON.decode(ASCompat.asString(param1.target.data ));
         var _loc4_:ASAny;
         final __ax4_iter_189:Array<ASAny> = _loc3_.friend_ids;
         if (checkNullIteratee(__ax4_iter_189)) for (_tmp_ in __ax4_iter_189)
         {
            _loc4_ = _tmp_;
            param2.push(Std.string(_loc4_));
         }
         if(_loc3_.page_num < _loc3_.num_pages)
         {
            loadKongregateFriendRequest(ASCompat.toInt(_loc3_.page_num + 1),param2);
         }
         else
         {
            buildKongregateFriendsHash(param2);
         }
      }
      
      function buildKongregateFriendsHash(param1:Array<ASAny>) 
      {
         var _loc3_= false;
         param1.sort(Reflect.compare);
         var _loc4_= "";
         var _loc5_:ASAny;
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc5_ = _tmp_;
            _loc4_ = _loc4_ + Std.string(_loc5_) + ",";
         }
         var _loc6_= mDBFacade.dbAccountInfo.currentKongregateFriendsHash;
         var _loc2_= SplitTestRules.getStringHash(_loc4_);
         if(_loc2_ != _loc6_)
         {
            _loc3_ = false;
            if(_loc6_ == "" || _loc6_ == null)
            {
               _loc3_ = true;
            }
            mDBFacade.dbAccountInfo.updateKongregateFriendsRPC(param1,_loc2_,_loc3_);
         }
      }
      
      function feedResponseCallback(param1:String, param2:ASObject) 
      {
         var _loc3_:String = null;
         if(ASCompat.toBool(param2))
         {
            _loc3_ = Std.string(param2.post_id);
            _loc3_ = _loc3_.split("_")[0];
            if(_loc3_ == mDBFacade.facebookPlayerId)
            {
               mDBFacade.metrics.log("WallPostSuccess",{"feed":param1});
            }
            else
            {
               mDBFacade.metrics.log("WallPostSuccess",{
                  "feed":param1,
                  "friendId":_loc3_
               });
            }
            PixelTracker.wallPost(mDBFacade);
         }
         else
         {
            mDBFacade.metrics.log("WallPostCancel",{"feed":param1});
         }
      }
      
      function giftCallback(param1:ASObject, param2:UInt) 
      {
         var _loc3_:ASAny;
         var _loc7_:String = null;
         var _loc9_:Array<ASAny> = null;
         var _loc8_:Array<ASAny> = null;
         var _loc5_:Array<ASAny> = null;
         var _loc4_:String = null;
         var _loc6_:Array<ASAny> = null;
         if(ASCompat.toBool(param1))
         {
            _loc7_ = Std.string(param1.request);
            _loc9_ = ASCompat.dynamicAs(param1.to , Array);
            _loc8_ = [];
            _loc5_ = [];
            if (checkNullIteratee(_loc9_)) for (_tmp_ in _loc9_)
            {
               _loc3_ = _tmp_;
               _loc4_ = mDBFacade.dbConfigManager.networkId + "_" + _loc7_ + "_" + Std.string(_loc3_);
               _loc5_.push(_loc4_);
               _loc8_.push(_loc3_);
               mDBFacade.metrics.log("GiftRequest",{
                  "requestId:":_loc4_,
                  "userId":mDBFacade.accountId,
                  "friendId":_loc3_
               });
               PixelTracker.invitedFriend(mDBFacade);
            }
            _loc6_ = mDBFacade.dbAccountInfo.giftExcludeIds;
            mDBFacade.dbAccountInfo.giftExcludeIds = _loc6_.concat(_loc8_);
            mDBFacade.dbAccountInfo.sendGiftData(param2,_loc5_,_loc8_);
            mDBFacade.dbAccountInfo.sendFacebookRequestData(_loc5_,_loc8_);
         }
      }
      
      function friendRequestCallback(param1:ASObject) 
      {
         var _loc2_:ASAny;
         var _loc5_:String = null;
         var _loc6_:Array<ASAny> = null;
         var _loc4_:Array<ASAny> = null;
         var _loc3_:String = null;
         if(ASCompat.toBool(param1))
         {
            _loc5_ = Std.string(param1.request);
            _loc6_ = ASCompat.dynamicAs(param1.to , Array);
            _loc4_ = [];
            if (checkNullIteratee(_loc6_)) for (_tmp_ in _loc6_)
            {
               _loc2_ = _tmp_;
               _loc3_ = mDBFacade.dbConfigManager.networkId + "_" + _loc5_ + "_" + Std.string(_loc2_);
               _loc4_.push(_loc3_);
               mDBFacade.metrics.log("FriendRequest",{
                  "requestId:":_loc3_,
                  "userId":mDBFacade.accountId,
                  "friendId":_loc2_
               });
               PixelTracker.invitedFriend(mDBFacade);
            }
            mDBFacade.dbAccountInfo.sendFacebookRequestData(_loc4_,_loc6_);
         }
      }
      
      public function genericFriendRequests(param1:Bool = false) 
      {
         var __ax4_iter_190:Vector<GMFeedPosts>;
         var loginCallback:ASFunction;
         var filters:Array<ASAny>;
         var feedPostData:GMFeedPosts;
         var randomPost:UInt;
         var isRetry= param1;
         if(!mDBFacade.isFacebookPlayer)
         {
            return;
         }
         Logger.debug("genericFriendRequests: start");
         if(!ASCompat.stringAsBool(mAccessToken) && !isRetry)
         {
            loginCallback = function()
            {
               Logger.debug("genericFriendRequests: retry = true");
               genericFriendRequests(true);
            };
            Logger.debug("genericFriendRequests: handleLogin");
            handleLogin(loginCallback);
            return;
         }
         if(mDBFacade.isDRPlayer)
         {
            friendsHash(true);
         }
         filters = ["app_non_users"];
         if(mFriendInvitePosts.length == 0)
         {
            __ax4_iter_190 = mDBFacade.gameMaster.FeedPosts;
            if (checkNullIteratee(__ax4_iter_190)) for (_tmp_ in __ax4_iter_190)
            {
               feedPostData  = _tmp_;
               if(feedPostData.Category == "INVITE_REQUEST")
               {
                  mFriendInvitePosts.push(feedPostData);
               }
            }
         }
         if(mFriendInvitePosts.length > 0)
         {
            randomPost = (Math.floor(Math.random() * mFriendInvitePosts.length) : UInt);
            friendRequests(mFriendInvitePosts[(randomPost : Int)].FeedCaption,mFriendInvitePosts[(randomPost : Int)].FeedName,"dialog",friendRequestCallback,filters);
         }
      }
      
      function dbFeedPost(param1:GMFeedPosts, param2:String = "", param3:String = "", param4:Bool = false, param5:ASObject = null) 
      {
         var loginCallback:ASFunction;
         var feedName:String;
         var key:String;
         var feedCaption:String;
         var feedDescription:String;
         var uriEncoded:String;
         var metricsCampaign:String;
         var metricsFeedLink:String;
         var propertiesObject:ASObject;
         var actionsObject:ASObject;
         var picUrl:String;
         var kStr:String;
         var gmFeedPost= param1;
         var receiverId= param2;
         var pic= param3;
         var isRetry= param4;
         var replaceDict:ASObject = param5;
         if(!mDBFacade.isKongregatePlayer && !ASCompat.stringAsBool(mAccessToken) && !isRetry)
         {
            loginCallback = function()
            {
               dbFeedPost(gmFeedPost,receiverId,pic,true);
            };
            handleLogin(loginCallback);
            return;
         }
         if(replaceDict == null)
         {
            replaceDict = {};
         }
         replaceDict["#NAME"] = mDBFacade.dbAccountInfo.name;
         replaceDict["#CHARACTER"] = mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Name;
         feedName = "";
         if(ASCompat.stringAsBool(gmFeedPost.FeedName))
         {
            feedName = gmFeedPost.FeedName;
            if (checkNullIteratee(replaceDict)) for(_tmp_ in replaceDict.___keys())
            {
               key  = _tmp_;
               feedName = StringTools.replace(feedName, key,Std.string(replaceDict[key]));
            }
         }
         feedCaption = "";
         if(ASCompat.stringAsBool(gmFeedPost.FeedCaption))
         {
            feedCaption = gmFeedPost.FeedCaption;
            if (checkNullIteratee(replaceDict)) for(_tmp_ in replaceDict.___keys())
            {
               key  = _tmp_;
               feedCaption = StringTools.replace(feedCaption, key,Std.string(replaceDict[key]));
            }
         }
         feedDescription = " ";
         if(ASCompat.stringAsBool(gmFeedPost.FeedDescriptions))
         {
            feedDescription = gmFeedPost.FeedDescriptions;
            if (checkNullIteratee(replaceDict)) for(_tmp_ in replaceDict.___keys())
            {
               key  = _tmp_;
               feedDescription = StringTools.replace(feedDescription, key,Std.string(replaceDict[key]));
            }
         }
         uriEncoded = ASCompat.escape(mFeedLink);
         metricsCampaign = "dbfbwp";
         metricsFeedLink = mAppURL + "track/?anxrc=" + metricsCampaign + "&anxrs=" + Std.string(mDBFacade.accountId) + "&redirect=" + uriEncoded;
         propertiesObject = null;
         actionsObject = null;
         if(ASCompat.stringAsBool(gmFeedPost.FeedActionsName))
         {
            actionsObject = [{
               "name":gmFeedPost.FeedActionsName,
               "link":metricsFeedLink
            }];
         }
         if(pic != "")
         {
            picUrl = mAppURL + pic;
         }
         else
         {
            picUrl = mAppURL + gmFeedPost.FeedImageLink;
         }
         mDBFacade.metrics.log("WallPostPrompt",{"feed":gmFeedPost.Constant});
         if(mDBFacade.isKongregatePlayer)
         {
            kStr = feedDescription;
            if(kStr == " ")
            {
               kStr = feedCaption;
            }
            if(kStr == "")
            {
               kStr = feedName;
            }
            Logger.debug("Calling Kongregate showFeedPostBox");
            mDBFacade.kongregateAPI.services.showFeedPostBox({
               "content":kStr,
               "image_uri":picUrl,
               "kv_params":{}
            });
         }
         else
         {
            Logger.debug("Calling Facebook feedPost");
            feedPost(feedName,feedCaption,feedDescription,metricsFeedLink,picUrl,"dialog",function(param1:ASObject)
            {
               feedResponseCallback(gmFeedPost.Constant,param1);
            },receiverId,propertiesObject,actionsObject);
         }
      }
      
      public function askForKeys(param1:String) 
      {
         if(!mDBFacade.isFacebookPlayer)
         {
            return;
         }
         var _loc2_= ASCompat.dynamicAs(mDBFacade.gameMaster.feedPostsByConstant.itemFor(param1), gameMasterDictionary.GMFeedPosts);
         if(_loc2_ != null)
         {
            this.dbFeedPost(_loc2_);
         }
      }
      
      public function purchaseFeedPost(param1:UInt) 
      {
         this.categoryFeedPost(param1,"PURCHASE");
      }
      
      public function chestUnlockFeedPost(param1:UInt, param2:String, param3:String, param4:String) 
      {
         this.categoryFeedPost(param1,"CHEST_UNLOCK",param4,{
            "#ITEM":param2,
            "#FULL_ITEM":param3
         });
      }
      
      public function mapNodeDefeatedFeedPost(param1:UInt, param2:String) 
      {
         this.categoryFeedPost(param1,"MAP_NODE_DEFEATED","",{"#NODE":param2});
      }
      
      function categoryFeedPost(param1:UInt, param2:String, param3:String = "", param4:ASObject = null) 
      {
         var _loc5_:Float = 0;
         if(param1 == 0 || param1 == 0)
         {
            return;
         }
         var _loc6_= getFeedPosts(mDBFacade,param1,param2);
         if(_loc6_.length > 0)
         {
            _loc5_ = Math.ffloor(Math.random() * _loc6_.length);
            this.dbFeedPost(_loc6_[Std.int(_loc5_)],"",param3,false,param4);
         }
      }
      
      public function leaderboardFeedPostToASingleUser(param1:String) 
      {
         var _loc2_:GMFeedPosts;
         var __ax4_iter_191:Vector<GMFeedPosts>;
         var _loc3_:Float = 0;
         if(mLeaderBoardFeedPosts.length == 0)
         {
            __ax4_iter_191 = mDBFacade.gameMaster.FeedPosts;
            if (checkNullIteratee(__ax4_iter_191)) for (_tmp_ in __ax4_iter_191)
            {
               _loc2_ = _tmp_;
               if(_loc2_.Category == "MESSAGE")
               {
                  mLeaderBoardFeedPosts.push(_loc2_);
               }
            }
         }
         if(mLeaderBoardFeedPosts.length > 0)
         {
            _loc3_ = Math.ffloor(Math.random() * mLeaderBoardFeedPosts.length);
            this.dbFeedPost(mLeaderBoardFeedPosts[Std.int(_loc3_)],param1);
         }
      }
      
      public function sendGiftRequests(param1:String, param2:UInt, param3:String = "") 
      {
         var __ax4_iter_192:Vector<GMFeedPosts>;
         var filters:Array<ASAny>;
         var feedCaption:String;
         var excludeIds:Array<ASAny>;
         var data:ASObject;
         var feedPostData:GMFeedPosts;
         var randomPost:UInt;
         var callback:ASFunction;
         var giftName= param1;
         var giftOfferID= param2;
         var facebookIds= param3;
         if(!mDBFacade.isFacebookPlayer)
         {
            return;
         }
         filters = ["all","app_non_users","app_users"];
         feedCaption = " ";
         excludeIds = mDBFacade.dbAccountInfo.giftExcludeIds;
         data = {"offerID":giftOfferID};
         if(mGiftFriendPosts.length == 0)
         {
            __ax4_iter_192 = mDBFacade.gameMaster.FeedPosts;
            if (checkNullIteratee(__ax4_iter_192)) for (_tmp_ in __ax4_iter_192)
            {
               feedPostData  = _tmp_;
               if(feedPostData.Category == "SEND_GIFT_REQUEST")
               {
                  mGiftFriendPosts.push(feedPostData);
               }
            }
         }
         Logger.debug("sendGiftRequests: giftFriendPosts count: " + mGiftFriendPosts.length);
         if(mGiftFriendPosts.length > 0)
         {
            randomPost = (Math.floor(Math.random() * mGiftFriendPosts.length) : UInt);
            callback = function(param1:ASObject)
            {
               Logger.debug("sendGiftRequests: facebook calling giftCallback.");
               giftCallback(param1,giftOfferID);
            };
            if(ASCompat.stringAsBool(mGiftFriendPosts[(randomPost : Int)].FeedCaption))
            {
               feedCaption = mGiftFriendPosts[(randomPost : Int)].FeedCaption;
               feedCaption = StringTools.replace(feedCaption, "#NAME",mDBFacade.dbAccountInfo.name);
            }
            friendRequests(feedCaption,mGiftFriendPosts[(randomPost : Int)].FeedName,"dialog",callback,filters,data,"50",facebookIds,excludeIds);
         }
      }
      
      public function updateGuestAchievement(param1:UInt) 
      {
         if(!mDBFacade.isFacebookPlayer)
         {
            return;
         }
         if(mDBFacade.dbAccountInfo.dbAccountParams.hasAchievement(param1))
         {
            return;
         }
         mDBFacade.dbAccountInfo.dbAccountParams.setAchievement(param1);
         var _loc2_= "";
         switch(param1 - 1)
         {
            case 0:
               _loc2_ = "ach1";
            
            case 1:
               _loc2_ = "ach2";
            
            case 2:
               _loc2_ = "ach3";
            
            case 3:
               _loc2_ = "ach4";
            
            case 4:
               _loc2_ = "ach5";
            
            case 5:
               _loc2_ = "ach6";
            
         }
         var _loc3_= mAppURL + "achievements?ach=" + _loc2_;
         mDBFacade.dbAccountInfo.addAchievement(_loc2_,_loc3_,achievementSuccessCallback);
      }
      
      function achievementSuccessCallback(param1:String) 
      {
         var _loc2_= ASCompat.dynamicAs(mDBFacade.gameMaster.achievementsById.itemFor(param1), gameMasterDictionary.GMAchievement);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:ASObject = {
            "accountId":mDBFacade.accountId,
            "facebookId":mDBFacade.facebookId,
            "achievementId":_loc2_.Id,
            "achievementName":_loc2_.Name,
            "achievementPoints":_loc2_.Points
         };
         mDBFacade.metrics.log("AchievementEarned",_loc3_);
      }
      
      function completeHandler(param1:Event) 
      {
         Logger.info("Player scores updated Successfully");
      }
      
      function securityErrorHandler(param1:Event) 
      {
         Logger.warn("SecurityError on scores logging: " + param1.toString());
      }
      
      function ioErrorHandler(param1:Event) 
      {
         Logger.warn("IOError on scores logging: " + param1.toString());
      }
      
      @:isVar var appUrl(get,never):String;
function  get_appUrl() : String
      {
         return mAppURL;
      }
      
      @:isVar public var thirdPartyId(get,never):String;
public function  get_thirdPartyId() : String
      {
         return mThirdPartyId;
      }
      
      public function destroy() 
      {
         mDBFacade = null;
      }
   }


