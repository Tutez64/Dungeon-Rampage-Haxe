package uI.gifting
;
   import account.FriendInfo;
   import account.GiftInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMOffer;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UIGiftMessage
   {
      
      var mDBFacade:DBFacade;
      
      var mGiftMessage:MovieClip;
      
      var mUIGift:UIGift;
      
      var mGiftText:TextField;
      
      var mAcceptAndSendButton:UIButton;
      
      var mDeclineButton:UIButton;
      
      var mFriendPic:MovieClip;
      
      var mGiftIcon:MovieClip;
      
      var mGiftInfo:GiftInfo;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:UIGift)
      {
         
         mDBFacade = param1;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mGiftMessage = param2;
         mUIGift = param3;
         loadInitialVariables();
      }
      
      function loadInitialVariables() 
      {
         mGiftText = ASCompat.dynamicAs((mGiftMessage : ASAny).message_label, flash.text.TextField);
         mGiftText.text = "";
         mAcceptAndSendButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mGiftMessage : ASAny).left_button, flash.display.MovieClip));
         mAcceptAndSendButton.label.text = Locale.getString("GIFT_MESSAGE_ACCEPT");
         mDeclineButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mGiftMessage : ASAny).right_button, flash.display.MovieClip));
         mFriendPic = ASCompat.dynamicAs((mGiftMessage : ASAny).friendPic, flash.display.MovieClip);
         mGiftIcon = ASCompat.dynamicAs((mGiftMessage : ASAny).icon, flash.display.MovieClip);
      }
      
      public function populateGiftMessage(param1:GiftInfo) 
      {
         var giftText:String;
         var friendName:String;
         var friend:FriendInfo;
         var offer:GMOffer;
         var offerName:String = null;
         var data= param1;
         if(data == null)
         {
            return;
         }
         mGiftInfo = data;
         giftText = Locale.getString("GIFT_MESSAGE_TEXT");
         friendName = "SOMEBODY";
         friend = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.friendInfos.itemFor(data.fromAccountId), account.FriendInfo);
         if(friend != null)
         {
            friendName = friend.name;
            if(mFriendPic.numChildren > 0)
            {
               mFriendPic.removeChildAt(0);
            }
            if(data.pic != null)
            {
               mFriendPic.addChildAt(data.pic,0);
            }
            else
            {
               data.pic = friend.clonePic();
               mFriendPic.addChildAt(data.pic,0);
            }
         }
         giftText = StringTools.replace(giftText, "#NAME",friendName);
         offer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(mGiftInfo.offerId), gameMasterDictionary.GMOffer);
         if(offer != null)
         {
            offerName = offer.getDisplayName(mDBFacade.gameMaster,Locale.getString("GIFT_UNKNOWN_NAME"));
            giftText = giftText + offerName;
            if(offer.BundleSwfFilepath != "" && offer.BundleIcon != "")
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(offer.BundleSwfFilepath),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc4_= 0;
                  var _loc2_= param1.getClass(offer.BundleIcon);
                  var _loc3_= ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
                  _loc3_.scaleX = _loc3_.scaleY = 0.8;
                  if(mGiftIcon.numChildren > 0)
                  {
                     _loc4_ = mGiftIcon.numChildren - 1;
                     while(_loc4_ >= 0)
                     {
                        mGiftIcon.removeChild(mGiftIcon.getChildAt(_loc4_));
                        _loc4_--;
                     }
                  }
                  mGiftIcon.addChild(_loc3_);
               });
            }
            else
            {
               Logger.error("OfferID" + Std.string(offer.Id) + " is missing a bunble swf path and/or buncle icon");
            }
         }
         mAcceptAndSendButton.enabled = true;
         mAcceptAndSendButton.releaseCallback = function()
         {
            var _loc1_:String = null;
            var _loc6_:Array<ASAny> = null;
            var _loc4_:Array<ASAny> = null;
            var _loc2_:String = null;
            var _loc3_:String = null;
            mAcceptAndSendButton.enabled = false;
            var _loc5_= mDBFacade.dbAccountInfo.giftExcludeIds;
            if(friend != null && _loc5_.indexOf(friend.excludeId) < 0)
            {
               if(!friend.isDRFriend && ASCompat.stringAsBool(friend.facebookId) && friend.facebookId != "" && ASCompat.stringAsBool(mDBFacade.facebookController.accessToken))
               {
                  mDBFacade.facebookController.sendGiftRequests(offerName,mGiftInfo.offerId,friend.facebookId);
               }
               else
               {
                  _loc6_ = [];
                  _loc4_ = [];
                  _loc3_ = Std.string(Date.now().getTime());
                  if(friend.isDRFriend)
                  {
                     _loc1_ = Std.string(friend.id);
                  }
                  else
                  {
                     _loc1_ = friend.kongregateId.toString();
                  }
                  _loc2_ = "0_" + _loc3_ + "_" + _loc1_;
                  _loc4_.push(_loc2_);
                  _loc6_.push(_loc1_);
                  mDBFacade.dbAccountInfo.giftExcludeIds = _loc5_.concat(_loc6_);
                  mDBFacade.dbAccountInfo.sendGiftData(offer.Id,_loc4_,_loc6_);
               }
            }
            mDBFacade.dbAccountInfo.acceptGift(data.requestId,refreshGiftPopup);
         };
         mDeclineButton.enabled = true;
         mDeclineButton.releaseCallback = function()
         {
            mDeclineButton.enabled = false;
            mDBFacade.dbAccountInfo.declineGift(data.requestId,refreshGiftPopup);
         };
         giftText = giftText.toUpperCase();
         mGiftText.text = giftText;
      }
      
      function refreshGiftPopup() 
      {
         mUIGift.refresh();
      }
      
      @:isVar public var root(get,never):MovieClip;
public function  get_root() : MovieClip
      {
         return mGiftMessage;
      }
      
      public function destroy() 
      {
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         mDBFacade = null;
         mUIGift = null;
         mGiftMessage = null;
         mGiftInfo = null;
         mFriendPic = null;
         mGiftIcon = null;
         if(mAcceptAndSendButton != null)
         {
            mAcceptAndSendButton.destroy();
         }
         mAcceptAndSendButton = null;
         if(mDeclineButton != null)
         {
            mDeclineButton.destroy();
         }
         mDeclineButton = null;
      }
   }


