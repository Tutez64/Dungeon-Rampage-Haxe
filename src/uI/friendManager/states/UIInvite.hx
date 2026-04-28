package uI.friendManager.states
;
   import account.SteamIdConverter;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import brain.uI.UIInputText;
   import brain.uI.UIObject;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.jsonRPC.JSONRPCService;
   import distributedObjects.PresenceManager;
   import events.FriendSummaryNewsFeedEvent;
   import events.FriendshipEvent;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMSkin;
   import town.TownStateMachine;
   import uI.friendManager.UIFriendManager;
   import uI.popup.DBUIOneButtonPopup;
   import flash.display.MovieClip;
   import flash.external.ExternalInterface;
   
    class UIInvite extends UIFMState
   {
      
      static inline final MAX_INVITE_STRING= (200 : UInt);
      
      static inline final TURN_OFF_WARNING_TIMER= (2 : UInt);
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mEventComponent:EventComponent;
      
      var mEmailText:String;
      
      var mInviteUIMC:MovieClip;
      
      var mInviteInputText:UIInputText;
      
      var mInviteViaEmailButton:UIButton;
      
      var mInviteViaFBConnectButton:UIButton;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      public function new(param1:UIFriendManager, param2:DBFacade, param3:TownStateMachine)
      {
         super(param2,param1,param3);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIInvite");
      }
      
      override public function enter() 
      {
         Logger.debug("Entered Invite State");
         mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_INVITE"));
         var _loc1_= SteamIdConverter.convertSteamID64ToSteamHex(mDBFacade.mSteamUserId);
         mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_INVITE") + _loc1_,true);
         setupUI();
      }
      
      public function setupUI() 
      {
         var steamHex:String;
         var inviteUIClass= mTownStateMachine.getTownAsset("popup_invite_B");
         mInviteUIMC = ASCompat.dynamicAs(ASCompat.createInstance(inviteUIClass, []) , MovieClip);
         mUIFriendManager.addToUI(mInviteUIMC);
         mInviteUIMC.x = 300;
         mInviteUIMC.y = 150;
         steamHex = SteamIdConverter.convertSteamID64ToSteamHex(mDBFacade.mSteamUserId);
         ASCompat.setProperty((mInviteUIMC : ASAny).search_label2, "text", Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_INVITE_2") + steamHex);
         ASCompat.setProperty((mInviteUIMC : ASAny).search_label2, "selectable", true);
         ASCompat.setProperty((mInviteUIMC : ASAny).search_label1, "visible", false);
         ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "textColor", 16711680);
         ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
         ASCompat.setProperty((mInviteUIMC : ASAny).message_label, "visible", false);
         mInviteInputText = new UIInputText(mDBFacade,ASCompat.dynamicAs((mInviteUIMC : ASAny).friend_enterEmailId, flash.display.MovieClip));
         mInviteInputText.defaultText = Locale.getString("DRINVITE_PROMPT");
         mInviteInputText.enterCallback = inviteViaEmail;
         mInviteInputText.textField.maxChars = 200;
         mInviteViaEmailButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mInviteUIMC : ASAny).send_button, flash.display.MovieClip));
         mInviteViaEmailButton.label.text = Locale.getString("DRINVITE_FRIEND_EMAIL_BUTTON");
         mInviteViaEmailButton.releaseCallback = function()
         {
            var _loc1_= new compat.RegExp("[\\s\\r\\n]*", "gim");
            ASCompat.setProperty((mInviteUIMC : ASAny).friend_enterEmailId.textField, "text", _loc1_.replace(Std.string((mInviteUIMC : ASAny).friend_enterEmailId.textField.text),""));
            inviteViaEmail((mInviteUIMC : ASAny).friend_enterEmailId.textField.text,inviteViaEmailSuccessCallback);
            ASCompat.setProperty((mInviteUIMC : ASAny).friend_enterEmailId.textField, "text", "");
         };
         ASCompat.setProperty((mInviteUIMC : ASAny).connect_button_kongregate, "visible", false);
         mInviteViaFBConnectButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mInviteUIMC : ASAny).connect_button_facebook, flash.display.MovieClip));
         mInviteViaFBConnectButton.releaseCallback = inviteViaFBConnect;
         if(!mDBFacade.isFacebookPlayer)
         {
            mInviteViaFBConnectButton.visible = false;
         }
      }
      
      function inviteViaEmail(param1:String, param2:ASFunction = null) 
      {
         var finalValue:String;
         var accountIdRegex:compat.RegExp;
         var steamID64:String;
         var rpcSuccessCallback:ASFunction;
         var value= param1;
         var successCallback= param2;
         var rpcFunc= JSONRPCService.getFunction("DRFriendRequest",mDBFacade.rpcRoot + "friendrequests");
         var rex= new compat.RegExp("[\\s\\r\\n]*", "gim");
         mInviteInputText.text = rex.replace(mInviteInputText.text,"");
         finalValue = mInviteInputText.text;
         accountIdRegex = new compat.RegExp("^1[0-9]{9}$");
         if(accountIdRegex.test(finalValue))
         {
            Logger.debug("Requested friend looks like an account ID, not a Steam ID, so not converting to email. Value: " + finalValue);
         }
         else
         {
            if(!SteamIdConverter.isValidSteamId(mInviteInputText.text))
            {
               mInviteInputText.text = "";
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "text", Locale.getString("DRINVITE_PROMPT_INVALID_EMAIL"));
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
               mLogicalWorkComponent.doLater(2,function(param1:brain.clock.GameClock)
               {
                  ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
               });
               return;
            }
            steamID64 = SteamIdConverter.normalizeSteamIdToSteamID64(mInviteInputText.text);
            if(steamID64 == "")
            {
               mInviteInputText.text = "";
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "text", Locale.getString("DRINVITE_PROMPT_INVALID_EMAIL"));
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
               mLogicalWorkComponent.doLater(2,function(param1:brain.clock.GameClock)
               {
                  ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
               });
               return;
            }
            finalValue = steamID64 + "@steam.dr.g17s.net";
            rex = new compat.RegExp("([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}");
            if(rex.test(finalValue) == false)
            {
               mInviteInputText.text = "";
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "text", Locale.getString("DRINVITE_PROMPT_INVALID_EMAIL"));
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
               mLogicalWorkComponent.doLater(2,function(param1:brain.clock.GameClock)
               {
                  ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
               });
               return;
            }
         }
         rpcSuccessCallback = function(param1:ASAny)
         {
            var popup:DBUIOneButtonPopup;
            var requestJson:ASObject;
            var iconContainer:MovieClip;
            var skin:GMSkin;
            var details:ASAny = param1;
            if(details == null)
            {
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "text", Locale.getString("DRINVITE_PROMPT_ALREADY_FRIEND"));
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
               mLogicalWorkComponent.doLater(2,function(param1:brain.clock.GameClock)
               {
                  ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
               });
               return;
            }
            if(ASCompat.getQualifiedClassName(details) == "Array" && ASCompat.toNumberField(details, "length") <= 0)
            {
               mEmailText = value;
               popup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("DRINVITE_FAILED_POPUP_TITLE"),Locale.getString("DRINVITE_FAILED_POPUP_DESC"),Locale.getString("OK"),invokeMailClient);
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in UIInvite.UIInvite()");
               return;
            }
            if(details == false)
            {
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "text", Locale.getString("DRINVITE_PROMPT_INVITE_SENT"));
               ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
               mLogicalWorkComponent.doLater(2,function(param1:brain.clock.GameClock)
               {
                  ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
               });
               return;
            }
            requestJson = parseJson(details);
            iconContainer = new MovieClip();
            skin = mDBFacade.gameMaster.getSkinByType((ASCompat.toInt(requestJson.active_skin) : UInt));
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(skin.UISwfFilepath),function(param1:brain.assetRepository.SwfAsset)
            {
               var _loc3_= param1.getClass(skin.IconName);
               var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
               UIObject.scaleToFit(_loc2_,65);
               iconContainer.addChild(_loc2_);
               mEventComponent.dispatchEvent(new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT",Locale.getString("Friend_Request_Sent_to_"),iconContainer,value));
               mDBFacade.metrics.log("DRFriendRequest",{"friendId":requestJson.to_account_id});
            });
            if(successCallback != null)
            {
               successCallback();
            }
         };
         rpcFunc(mDBFacade.dbAccountInfo.name,mDBFacade.dbAccountInfo.trophies,mDBFacade.dbAccountInfo.activeAvatarSkinId,mDBFacade.dbAccountInfo.facebookId,mDBFacade.dbAccountInfo.id,finalValue,mDBFacade.demographics,mDBFacade.validationToken,rpcSuccessCallback,UIFriendManager.createFriendRPCErrorCallback(mDBFacade,"InviteViaEmail"));
         mInviteInputText.text = "";
      }
      
      function inviteViaFBConnect() 
      {
         if(mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
         {
            mDBFacade.errorPopup("INVITE CURRENTLY DISABLED","Sorry for the inconvenience, we are looking into resolving the issue.");
            return;
         }
         if(mDBFacade.facebookController != null)
         {
            mDBFacade.facebookController.genericFriendRequests();
         }
      }
      
      function invokeMailClient() 
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("sendInviteEmail",mDBFacade.dbAccountInfo.id,mDBFacade.dbConfigManager.networkId,mDBFacade.dbAccountInfo.name,mEmailText);
         }
      }
      
      public function parseJson(param1:ASAny) : ASObject
      {
         var _loc2_:Array<ASAny> = null;
         var _loc4_:ASObject = null;
         var _loc3_:Vector<UInt> = /*undefined*/null;
         if(ASCompat.getQualifiedClassName(param1) == "Array")
         {
            _loc2_ = ASCompat.dynamicAs(param1[0], Array);
            _loc4_ = param1[1];
            _loc3_ = new Vector<UInt>();
            _loc3_.push(_loc4_.account_id);
            PresenceManager.instance().addFriends(_loc3_);
            mDBFacade.dbAccountInfo.addFriendCallback(_loc2_);
            mEventComponent.dispatchEvent(new FriendshipEvent(UIFriendManager.FRIENDSHIP_MADE,(ASCompat.toInt(_loc4_.id) : UInt)));
         }
         else
         {
            _loc4_ = (param1 : ASObject) ;
         }
         Logger.debug("friendRequest: id:" + Std.string(_loc4_.id) + " from:" + Std.string(_loc4_.account_id) + " to:" + Std.string(_loc4_.to_account_id) + " state:" + Std.string(_loc4_.curr_state));
         return _loc4_;
      }
      
      function inviteViaEmailSuccessCallback() 
      {
         mInviteInputText.defaultText = Locale.getString("DRINVITE_PROMPT");
      }
      
      override public function exit() 
      {
         Logger.debug("Exiting Invite State");
         mUIFriendManager.clearUI();
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         mLogicalWorkComponent.destroy();
         mAssetLoadingComponent.destroy();
         mEventComponent.destroy();
      }
   }


