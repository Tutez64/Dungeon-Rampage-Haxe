package uI.gifting;

import account.FriendInfo;
import account.GiftInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMOffer;
import uI.portrait.PlayerPortraits;
import flash.display.MovieClip;
import flash.text.TextField;

class UIGiftMessage {
	var mPortraits:PlayerPortraits = new PlayerPortraits();

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

	public function new(dbFacade:DBFacade, giftMessageRoot:MovieClip, uiGift:UIGift) {
		mDBFacade = dbFacade;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mGiftMessage = giftMessageRoot;
		mUIGift = uiGift;
		loadInitialVariables();
	}

	function loadInitialVariables() {
		mGiftText = ASCompat.coerce((mGiftMessage : ASAny).message_label, flash.text.TextField);
		mGiftText.text = "";
		mAcceptAndSendButton = new UIButton(mDBFacade, ASCompat.coerce((mGiftMessage : ASAny).left_button, flash.display.MovieClip));
		Locale.setText(mAcceptAndSendButton.label, "GIFT_MESSAGE_ACCEPT");
		mDeclineButton = new UIButton(mDBFacade, ASCompat.coerce((mGiftMessage : ASAny).right_button, flash.display.MovieClip));
		mFriendPic = ASCompat.coerce((mGiftMessage : ASAny).friendPic, flash.display.MovieClip);
		mGiftIcon = ASCompat.coerce((mGiftMessage : ASAny).icon, flash.display.MovieClip);
	}

	public function populateGiftMessage(data:GiftInfo) {
		var giftText:String;
		var friendName:String;
		var friend:FriendInfo;
		var offer:GMOffer;
		var offerName:String;
		mPortraits.clear();
		if (data == null) {
			return;
		}
		mGiftInfo = data;
		giftText = Locale.getString("GIFT_MESSAGE_TEXT");
		friendName = "SOMEBODY";
		friend = ASCompat.coerce(mDBFacade.dbAccountInfo.friendInfos.itemFor(data.fromAccountId), account.FriendInfo);
		if (friend != null) {
			friendName = friend.name;
			mPortraits.showFriend(mFriendPic, mDBFacade, friend);
		}
		giftText = StringTools.replace(giftText, "#NAME", friendName);
		offer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(mGiftInfo.offerId), gameMasterDictionary.GMOffer);
		if (offer != null) {
			offerName = offer.getDisplayName(mDBFacade.gameMaster, Locale.getString("GIFT_UNKNOWN_NAME"));
			giftText = giftText + offerName;
			if (offer.BundleSwfFilepath != "" && offer.BundleIcon != "") {
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(offer.BundleSwfFilepath), function(param1:brain.assetRepository.SwfAsset) {
					var _loc4_ = 0;
					var _loc2_ = param1.getClass(offer.BundleIcon);
					var _loc3_ = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
					_loc3_.scaleX = _loc3_.scaleY = 0.8;
					if (mGiftIcon.numChildren > 0) {
						_loc4_ = mGiftIcon.numChildren - 1;
						while (_loc4_ >= 0) {
							mGiftIcon.removeChild(mGiftIcon.getChildAt(_loc4_));
							_loc4_--;
						}
					}
					mGiftIcon.addChild(_loc3_);
				});
			} else {
				Logger.error("OfferID" + Std.string(offer.Id) + " is missing a bundle swf path and/or bundle icon");
			}
		}
		mAcceptAndSendButton.enabled = true;
		mAcceptAndSendButton.releaseCallback = function() {
			var _loc1_:String = null;
			var _loc6_:Array<ASAny> = null;
			var _loc4_:Array<ASAny> = null;
			var _loc2_:String = null;
			var _loc3_:String = null;
			mAcceptAndSendButton.enabled = false;
			var _loc5_ = mDBFacade.dbAccountInfo.giftExcludeIds;
			if (friend != null && _loc5_.indexOf(friend.excludeId) < 0) {
				_loc6_ = [];
				_loc4_ = [];
				_loc3_ = Std.string(Date.now().getTime());
				_loc1_ = Std.string(friend.id);
				_loc2_ = "0_" + _loc3_ + "_" + _loc1_;
				_loc4_.push(_loc2_);
				_loc6_.push(_loc1_);
				mDBFacade.dbAccountInfo.giftExcludeIds = _loc5_.concat(_loc6_);
				mDBFacade.dbAccountInfo.sendGiftData(offer.Id, _loc4_, _loc6_);
			}
			mDBFacade.dbAccountInfo.acceptGift(data.requestId, refreshGiftPopup);
		};
		mDeclineButton.enabled = true;
		mDeclineButton.releaseCallback = function() {
			mDeclineButton.enabled = false;
			mDBFacade.dbAccountInfo.declineGift(data.requestId, refreshGiftPopup);
		};
		giftText = giftText.toUpperCase();
		TextUtil.setText(mGiftText, giftText);
	}

	function refreshGiftPopup() {
		mUIGift.refresh();
	}

	@:isVar public var root(get, never):MovieClip;

	public function get_root():MovieClip {
		return mGiftMessage;
	}

	@:isVar public var acceptAndSendButton(get, never):UIButton;

	public function get_acceptAndSendButton():UIButton {
		return mAcceptAndSendButton;
	}

	@:isVar public var declineButton(get, never):UIButton;

	public function get_declineButton():UIButton {
		return mDeclineButton;
	}

	@:isVar public var visible(never, set):Bool;

	public function set_visible(value:Bool):Bool {
		mGiftMessage.visible = value;
		mAcceptAndSendButton.visible = value;
		return mDeclineButton.visible = value;
	}

	public function destroy() {
		mPortraits.destroy();
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
		}
		mAssetLoadingComponent = null;
		mDBFacade = null;
		mUIGift = null;
		mGiftMessage = null;
		mGiftInfo = null;
		mFriendPic = null;
		mGiftIcon = null;
		if (mAcceptAndSendButton != null) {
			mAcceptAndSendButton.destroy();
		}
		mAcceptAndSendButton = null;
		if (mDeclineButton != null) {
			mDeclineButton.destroy();
		}
		mDeclineButton = null;
	}
}
