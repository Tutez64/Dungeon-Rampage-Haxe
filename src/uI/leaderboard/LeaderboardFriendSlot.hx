package uI.leaderboard;

import account.FriendInfo;
import account.PlayerSpecialStatus;
import brain.assetRepository.AssetLoadingComponent;
import brain.clock.GameClock;
import brain.uI.UIButton;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import uI.portrait.PlayerPortraits;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.text.TextField;

class LeaderboardFriendSlot {
	public static inline final ONLINE_POPUP_TWEEN_DURATION:Float = 0.2;

	public static inline final OFFLINE_POPUP_TWEEN_DURATION:Float = 0.2;

	public static inline final ONLINE_POPUP_OFFSET:Float = 50;

	public static inline final OFFLINE_POPUP_OFFSET:Float = 60;

	public static inline final POPUP_TIME_TO_LIVE:Float = 1;

	var mPortraits:PlayerPortraits = new PlayerPortraits();

	var mDBFacade:DBFacade;

	var mFriendSlot:MovieClip;

	var mFriendName:TextField;

	var mFriendOnlineClip:MovieClip;

	var mFriendOfflineClip:MovieClip;

	var mMeOnlineClip:MovieClip;

	var mJoinOnlineClip:MovieClip;

	var mFriendInviteButton:UIButton;

	var mFriendPicButton:UIButton;

	var mFriendLevel:MovieClip;

	var mFriendAscension:MovieClip;

	var mOnlinePopup:MovieClip;

	var mOfflinePopup:MovieClip;

	var mMessageFriendButton:UIButton;

	var mJoinOnlineFriendButton:UIButton;

	var mRemoveOnlineFriendButton:UIButton;

	var mRemoveFriendButton:UIButton;

	var mFriendInfo:FriendInfo;

	var mLeaderboard:UILeaderboard;

	var mThisSlotIndex:UInt = 0;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mFriendSlotPosition:Point;

	var mPopupTimeToLiveTask:Task;

	public function new(dbFacade:DBFacade, friendSlot:MovieClip, leaderboard:UILeaderboard, slotIndex:Int) {
		mDBFacade = dbFacade;
		mFriendSlot = friendSlot;
		mLeaderboard = leaderboard;
		mThisSlotIndex = (slotIndex : UInt);
		mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(dbFacade);
		loadVariables();
		populateSlot(null);
	}

	function loadVariables() {
		mOnlinePopup = mLeaderboard.onlinePopup;
		mOfflinePopup = mLeaderboard.offlinePopup;
		mMessageFriendButton = mLeaderboard.messageFriend;
		mFriendName = ASCompat.coerce((mFriendSlot : ASAny).friend_name, flash.text.TextField);
		mFriendName.mouseEnabled = false;
		mFriendPicButton = new UIButton(mDBFacade, ASCompat.coerce((mFriendSlot : ASAny).friend_pic, flash.display.MovieClip));
		mFriendOnlineClip = ASCompat.coerce((mFriendSlot : ASAny).friend_pic.friend_online, flash.display.MovieClip);
		mFriendOfflineClip = ASCompat.coerce((mFriendSlot : ASAny).friend_pic.friend_offline, flash.display.MovieClip);
		mMeOnlineClip = ASCompat.coerce((mFriendSlot : ASAny).friend_pic.you_online, flash.display.MovieClip);
		mJoinOnlineClip = ASCompat.coerce((mFriendSlot : ASAny).friend_pic.join, flash.display.MovieClip);
		mJoinOnlineFriendButton = new UIButton(mDBFacade, ASCompat.coerce((mFriendSlot : ASAny).friend_pic.join.join, flash.display.MovieClip));
		Locale.setText(mJoinOnlineFriendButton.label, "LEADERBOARD_JOIN_FRIEND_BUTTON");
		mFriendLevel = ASCompat.coerce((mFriendSlot : ASAny).friend_level, flash.display.MovieClip);
		mFriendLevel.mouseEnabled = false;
		mFriendLevel.mouseChildren = false;
		mFriendAscension = ASCompat.coerce((mFriendSlot : ASAny).friend_ascension, flash.display.MovieClip);
		mFriendAscension.mouseEnabled = false;
		mFriendAscension.mouseChildren = false;
		mFriendInviteButton = new UIButton(mDBFacade, ASCompat.coerce((mFriendSlot : ASAny).invite_friend, flash.display.MovieClip));
		Locale.setText(mFriendInviteButton.label, "LEADERBOARD_INVITE_FRIEND");
		mFriendInviteButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mFriendPicButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mFriendPicButton.navigationSelectedInteraction = focusFriendDetails;
	}

	function focusFriendDetails() {
		if (mFriendInfo == null) {
			mLeaderboard.callStopOnPopupTimeToLiveTask();
			hidePopups();
			return;
		}
		if (mFriendInfo.id == mDBFacade.accountId) {
			mLeaderboard.callStopOnPopupTimeToLiveTask();
			minimizePopup();
			return;
		}
		if (mLeaderboard.currentPopupIndex == mThisSlotIndex && (mOnlinePopup.visible || mOfflinePopup.visible)) {
			mLeaderboard.callStopOnPopupTimeToLiveTask();
			return;
		}
		showFriendDetails();
	}

	function showFriendDetails() {
		if (mFriendInfo != null && mFriendInfo.id == mDBFacade.accountId) {
			stopPopupTimeToLiveTask();
			minimizePopup();
			return;
		}
		if (mLeaderboard.currentPopupIndex == mThisSlotIndex && (mOnlinePopup.visible || mOfflinePopup.visible)) {
			mLeaderboard.callStopOnPopupTimeToLiveTask();
			return;
		}
		hidePopups();
		if (mFriendInfo == null) {
			return;
		}
		mLeaderboard.callStopOnPopupTimeToLiveTask();
		mLeaderboard.currentPopupIndex = mThisSlotIndex;
		if (mFriendInfo.isOnline()) {
			populateOnlinePopup();
		} else {
			populateOfflinePopup();
		}
	}

	public function populateSlot(data:FriendInfo) {
		var joinFriendCallback:ASFunction;
		mPortraits.clear();
		mFriendInfo = data;
		if (!mFriendPicButton.isFocused()) {
			mFriendPicButton.root.filters = cast([]);
		}
		mLeaderboard.resetFriendSlotUpNavigation(mFriendPicButton);
		if (data != null) {
			mFriendInviteButton.visible = false;
			mFriendName.visible = true;
			mFriendLevel.visible = true;
			mFriendOnlineClip.visible = false;
			mJoinOnlineClip.visible = false;
			mFriendOfflineClip.visible = false;
			mMeOnlineClip.visible = false;
			mJoinOnlineFriendButton.root.visible = false;
			mJoinOnlineFriendButton.releaseCallback = null;
			mFriendPicButton.releaseCallback = null;
			mFriendName.text = data.name;
			applyFriendNameSize();
			mFriendName.textColor = PlayerSpecialStatus.getSpecialTextColor(data.name, mFriendName.textColor);
			TextUtil.setText(ASCompat.coerce((mFriendLevel : ASAny).level, flash.text.TextField), Std.string(data.trophies));
			mFriendAscension.visible = data.ascensionLevel > 0;
			TextUtil.setText(ASCompat.coerce((mFriendAscension : ASAny).level, flash.text.TextField), Std.string(data.ascensionLevel));
			if (data.isOnline() && data.isInDungeon()) {
				mJoinOnlineClip.visible = true;
				mJoinOnlineFriendButton.root.visible = true;
				joinFriendCallback = function() {
					var _loc1_ = false;
					if (mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length == 0) {
						mDBFacade.warningPopup("Warning", "Cannot enter dungeon with no weapons equipped.");
					} else {
						mDBFacade.metrics.log("JoinFriend", {"friendId": data.id});
						_loc1_ = false;
						if (mLeaderboard.currentStateName == "MapTownSubState") {
							_loc1_ = true;
						}
						mDBFacade.mainStateMachine.enterLoadingScreenState((0 : UInt), "", data.id, (0 : UInt), _loc1_);
					}
				};
				mJoinOnlineFriendButton.releaseCallback = joinFriendCallback;
				mFriendPicButton.releaseCallback = joinFriendCallback;
			} else if (data.isOnline()) {
				if (data.id != mDBFacade.accountId) {
					mFriendOnlineClip.visible = true;
				} else {
					mMeOnlineClip.visible = true;
				}
			} else {
				mFriendOfflineClip.visible = true;
			}
			if (ASCompat.toBool(cast((mFriendPicButton.root : ASAny).friend_pic, flash.display.DisplayObjectContainer).numChildren)) {
				(mFriendPicButton.root : ASAny).friend_pic.removeChildAt(0);
			}
			mPortraits.showFriend(ASCompat.coerce((mFriendPicButton.root : ASAny).friend_pic, flash.display.DisplayObjectContainer), mDBFacade, data);
			ASCompat.setProperty((mFriendPicButton.root : ASAny).default_pic, "visible", false);
			mFriendPicButton.rollOverCallback = showFriendDetails;
			mFriendPicButton.rollOutCallback = function() {
				if (mFriendInfo != null && mFriendInfo.id == mDBFacade.accountId) {
					return;
				}
				mPopupTimeToLiveTask = mLogicalWorkComponent.doLater(1, minimizePopup);
			};
		} else {
			mFriendInviteButton.visible = true;
			mFriendInviteButton.releaseCallback = mFriendPicButton.releaseCallback = mLeaderboard.inviteFriendDR;
			if (ASCompat.toBool(cast((mFriendPicButton.root : ASAny).friend_pic, flash.display.DisplayObjectContainer).numChildren)) {
				(mFriendPicButton.root : ASAny).friend_pic.removeChildAt(0);
			}
			ASCompat.setProperty((mFriendPicButton.root : ASAny).default_pic, "visible", true);
			mFriendName.visible = false;
			mJoinOnlineFriendButton.root.visible = false;
			mJoinOnlineFriendButton.releaseCallback = null;
			mFriendOnlineClip.visible = false;
			mMeOnlineClip.visible = false;
			mFriendLevel.visible = false;
			mFriendAscension.visible = false;
		}
	}

	function applyFriendNameSize() {
		var _loc2_ = 0;
		var _loc1_ = mFriendName.defaultTextFormat;
		if (!Locale.isLowRes) {
			_loc2_ = Math.ceil(9 / (0.846 * mDBFacade.viewScale));
			_loc1_.size = ASCompat.toInt(Math.max(12, _loc2_));
		}
		mFriendName.setTextFormat(_loc1_);
	}

	@:isVar var onlinePopupTitle(get, never):String;

	function get_onlinePopupTitle():String {
		if (!mFriendInfo.isInDungeon()) {
			return Locale.getString("LEADERBOARD_IN_TOWN_TEXT");
		}
		var _loc1_ = mFriendInfo.dungeonName;
		return ASCompat.stringAsBool(_loc1_) ? _loc1_.toUpperCase() : Locale.getString("LEADERBOARD_IN_DUNGEON_TEXT");
	}

	function populateOnlinePopup() {
		mDBFacade.mTween.killTweensOf(mOnlinePopup);
		mOnlinePopup.visible = true;
		mFriendSlotPosition = mDBFacade.designLocalToGlobal(mFriendSlot, new Point(0, 0));
		mOnlinePopup.y = mFriendSlotPosition.y;
		mOnlinePopup.x = mFriendSlotPosition.x;
		mLeaderboard.setOnlinePopupTitle(onlinePopupTitle);
		mDBFacade.mTween.tweenMaxTo(mOnlinePopup, 0.2, {"y": mOnlinePopup.y - 50});
		mRemoveFriendButton = mLeaderboard.removeOnlineFriend;
		mRemoveFriendButton.releaseCallback = function() {
			mLeaderboard.loadRemoveFriendPopup(mFriendInfo);
		};
		mLeaderboard.setupTooltipNavigation(mFriendPicButton, mRemoveFriendButton, mLeaderboard.giftFriend);
	}

	function populateOfflinePopup() {
		mDBFacade.mTween.killTweensOf(mOfflinePopup);
		mOfflinePopup.visible = true;
		mFriendSlotPosition = mDBFacade.designLocalToGlobal(mFriendSlot, new Point(0, 0));
		mOfflinePopup.y = mFriendSlotPosition.y;
		mOfflinePopup.x = mFriendSlotPosition.x;
		mDBFacade.mTween.tweenMaxTo(mOfflinePopup, 0.2, {"y": mOfflinePopup.y - 60});
		mLeaderboard.disableMessageFriendButton();
		mRemoveFriendButton = mLeaderboard.removeOfflineFriend;
		mRemoveFriendButton.releaseCallback = function() {
			mLeaderboard.loadRemoveFriendPopup(mFriendInfo);
		};
		mLeaderboard.setupTooltipNavigation(mFriendPicButton, mRemoveFriendButton);
	}

	public function hidePopups() {
		mLeaderboard.releaseTooltipFocus();
		checkToRefreshLeaderboard();
		if (mOnlinePopup != null) {
			mOnlinePopup.visible = false;
		}
		if (mOfflinePopup != null) {
			mOfflinePopup.visible = false;
		}
	}

	public function minimizePopup(gameClock:GameClock = null) {
		mLeaderboard.releaseTooltipFocus();
		if (mOnlinePopup.visible) {
			mDBFacade.mTween.killTweensOf(mOnlinePopup);
			mDBFacade.mTween.tweenMaxTo(mOnlinePopup, 0.2, {
				"y": mOnlinePopup.y + 50 + 10,
				"visible": false
			});
		}
		if (mOfflinePopup.visible) {
			mDBFacade.mTween.killTweensOf(mOfflinePopup);
			mDBFacade.mTween.tweenMaxTo(mOfflinePopup, 0.2, {
				"y": mOfflinePopup.y + 60 + 10,
				"visible": false
			});
		}
		checkToRefreshLeaderboard();
	}

	function checkToRefreshLeaderboard() {
		if (mLeaderboard.mustRefreshLeaderboard) {
			mLeaderboard.refreshLeaderboard();
		}
	}

	public function stopPopupTimeToLiveTask() {
		if (mPopupTimeToLiveTask != null) {
			mPopupTimeToLiveTask.destroy();
		}
		mPopupTimeToLiveTask = null;
	}

	@:isVar public var friendPicButton(get, never):UIButton;

	public function get_friendPicButton():UIButton {
		return mFriendPicButton;
	}

	public function destroy() {
		mPortraits.destroy();
		stopPopupTimeToLiveTask();
		if (mFriendInviteButton != null) {
			mFriendInviteButton.destroy();
		}
		mFriendInviteButton = null;
		if (mFriendPicButton != null) {
			mFriendPicButton.destroy();
		}
		mFriendPicButton = null;
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
		}
		mAssetLoadingComponent = null;
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
		}
		mLogicalWorkComponent = null;
		if (mJoinOnlineFriendButton != null) {
			mJoinOnlineFriendButton.destroy();
		}
		mJoinOnlineFriendButton = null;
		mMessageFriendButton = null;
		mDBFacade = null;
		mFriendSlot = null;
		mFriendName = null;
		mFriendOnlineClip = null;
		mJoinOnlineClip = null;
		mFriendOfflineClip = null;
		mMeOnlineClip = null;
		mFriendLevel = null;
		mFriendAscension = null;
		mOnlinePopup = null;
		mOfflinePopup = null;
		mFriendInfo = null;
		mLeaderboard = null;
	}
}
