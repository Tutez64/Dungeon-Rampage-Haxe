package uI.leaderboard;

import account.FriendInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.render.MovieClipRenderController;
import brain.sceneGraph.SceneGraphComponent;
import brain.sceneGraph.SceneGraphManager;
import brain.uI.UIButton;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.jsonRPC.JSONRPCService;
import facade.DBFacade;
import facade.Locale;
import town.TownStateMachine;
import uI.popup.DBUITwoButtonPopup;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

class UILeaderboard {
	static var FRIEND_NAME_HIGHLIGHT_COLOR:UInt = (16764232 : UInt);

	public static inline final LEADERBOARD_INITIALIZED_EVENT_NAME = "LEADERBOARD_INITIALIZED_EVENT";

	public static inline final REFRESH_FRIENDS_EVENT_NAME = "REFRESH_FRIENDS_EVENT";

	public static inline final REVERSE_FRIEND_SLOT = false;

	public static inline final FRIEND_SLOTS_PER_TOWN_BUTTON = 3;

	public static inline final ONLINE_POPUP_TITLE_MAX_LINES = 2;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSceneGraphComponent:SceneGraphComponent;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mEventComponent:EventComponent;

	var mDBFacade:DBFacade;

	public var townSwf:SwfAsset;

	var mRootMovieClip:MovieClip;

	var mLeaderboard:MovieClip;

	var mOnlinePopup:MovieClip;

	var mOfflinePopup:MovieClip;

	var mOnlinePopupBg:DisplayObject;

	var mOnlinePopupBgScaleY:Float = Math.NaN;

	var mOnlinePopupBgY:Float = Math.NaN;

	var mOnlinePopupTitleY:Float = Math.NaN;

	var mOnlinePopupTitleHeight:Float = Math.NaN;

	var mMessageFriendButton:UIButton;

	var mRemoveOnlineFriendButton:UIButton;

	var mRemoveOfflineFriendButton:UIButton;

	var mGiftFriendButton:UIButton;

	var mScrollRightButton:UIButton;

	var mScrollLeftButton:UIButton;

	var mScrollPageRightButton:UIButton;

	var mScrollPageLeftButton:UIButton;

	var mDRRemoveFriendPopup:DBUITwoButtonPopup;

	var mFriendSlots:Vector<LeaderboardFriendSlot>;

	var mInviteFriendSlot:LeaderboardFriendSlot;

	var mInviteFriendButton:UIButton;

	var mOnlineFriends:Vector<FriendInfo>;

	var mOfflineFriends:Vector<FriendInfo>;

	var mFriendsLength:UInt = 0;

	var mCurrentPopupIndex:UInt = 0;

	var mScrollIndex:Int = 0;

	var mRefreshLeaderboard:Bool = false;

	var mCurrentStateName:String;

	var mStoreCallback:ASFunction;

	var mGetGiftsCallback:ASFunction;

	public var initialized:Bool = false;

	var mTownStateMachine:TownStateMachine;

	var mFriendManagementButton:UIButton;

	var mTownButtons:Array<ASAny>;

	var mAlert:MovieClip;

	var mAlertRenderer:MovieClipRenderController;

	public function new(dbFacade:DBFacade, rootSwf:SwfAsset, storeCallback:ASFunction, getGiftsCallback:ASFunction, townStateMachine:TownStateMachine) {
		mDBFacade = dbFacade;
		townSwf = rootSwf;
		mRootMovieClip = rootSwf.root;
		mStoreCallback = storeCallback;
		mGetGiftsCallback = getGiftsCallback;
		mFriendSlots = new Vector<LeaderboardFriendSlot>();
		mOnlineFriends = new Vector<FriendInfo>();
		mOfflineFriends = new Vector<FriendInfo>();
		mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
		mSceneGraphComponent = new SceneGraphComponent(dbFacade, "UILeaderboard");
		mLogicalWorkComponent = new LogicalWorkComponent(dbFacade, "UILeaderboard");
		mEventComponent = new EventComponent(mDBFacade);
		mTownStateMachine = townStateMachine;
	}

	public function preLoadSWF() {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_leaderboard.swf"), leaderboardLoaded);
	}

	public function loadRemoveFriendPopup(info:FriendInfo) {
		var tf:TextFormat;
		var mcClass = townSwf.getClass("popup");
		var colorizeStart = (Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_DESC_1").length : UInt);
		mDRRemoveFriendPopup = new DBUITwoButtonPopup(mDBFacade, "LEADERBOARD_REMOVE_FRIEND_POPUP",
			Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_TITLE"),
			Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_DESC_1") + info.name + Locale.getString("LEADERBOARD_DR_REMOVE_FRIEND_POPUP_DESC_2"),
			Locale.getString("REMOVE"), function() {
				var _loc2_:Array<ASAny> = [];
				_loc2_.push(info.id);
				var _loc1_ = JSONRPCService.getFunction("DRFriendRemove", mDBFacade.rpcRoot + "friendrequests");
				_loc1_(mDBFacade.accountId, _loc2_, mDBFacade.validationToken, mDBFacade.dbAccountInfo.removeFriendCallback);
				mDBFacade.metrics.log("DRFriendRemove", {"friendId": Std.string(info.id)});
		}, Locale.getString("CANCEL"), null);
		MemoryTracker.track(mDRRemoveFriendPopup, "DBUITwoButtonPopup - created in UILeaderboard.loadRemoveFriendPopup()");
		tf = new TextFormat();
		tf.color = FRIEND_NAME_HIGHLIGHT_COLOR;
		mDRRemoveFriendPopup.colorizeMessage(tf, (colorizeStart : Int), (colorizeStart + info.name.length : Int));
	}

	function leaderboardLoaded(swfAsset:SwfAsset) {
		if (swfAsset == null) {
			return;
		}
		loadOnlinePopup(swfAsset);
		loadOfflinePopup(swfAsset);
		loadLeaderboard(swfAsset);
		setInitialScrollBarStatus();
		initialized = true;
		mEventComponent.dispatchEvent(new Event("LEADERBOARD_INITIALIZED_EVENT"));
		getFriendData();
	}

	function loadOnlinePopup(swfAsset:SwfAsset) {
		var title:TextField;
		var i:Int;
		var child:DisplayObject;
		var mcClass = swfAsset.getClass("DR_leaderboard_online_tooltip");
		mOnlinePopup = ASCompat.coerce(ASCompat.createInstance(mcClass, []), flash.display.MovieClip);
		if (mOnlinePopup == null) {
			return;
		}
		mRootMovieClip.addChild(mOnlinePopup);
		mOnlinePopup.visible = false;
		mGiftFriendButton = new UIButton(mDBFacade, ASCompat.coerce((mOnlinePopup : ASAny).join_friend, flash.display.MovieClip));
		Locale.setText(mGiftFriendButton.label, "LEADERBOARD_GIFT_FRIEND_BUTTON");
		mGiftFriendButton.navigationSelectedInteraction = callStopOnPopupTimeToLiveTask;
		mGiftFriendButton.releaseCallback = function() {
			if (mStoreCallback != null) {
				mStoreCallback();
			}
		};
		mRemoveOnlineFriendButton = new UIButton(mDBFacade, ASCompat.coerce((mOnlinePopup : ASAny).remove_friend, flash.display.MovieClip));
		Locale.setText(mRemoveOnlineFriendButton.label, "LEADERBOARD_REMOVE_FRIEND_BUTTON");
		mRemoveOnlineFriendButton.navigationSelectedInteraction = callStopOnPopupTimeToLiveTask;
		mRemoveOnlineFriendButton.releaseCallback = removeFriends;
		title = ASCompat.coerce((mOnlinePopup : ASAny).title_label, flash.text.TextField);
		title.mouseEnabled = false;
		title.multiline = true;
		title.wordWrap = true;
		mOnlinePopupTitleY = title.y;
		mOnlinePopupTitleHeight = title.height;
		i = 0;
		while (i < mOnlinePopup.numChildren) {
			child = mOnlinePopup.getChildAt(i);
			if (child.name.indexOf("instance") == 0) {
				mOnlinePopupBg = child;
				break;
			}
			i = i + 1;
		}
		if (mOnlinePopupBg != null) {
			mOnlinePopupBgScaleY = mOnlinePopupBg.scaleY;
			mOnlinePopupBgY = mOnlinePopupBg.y;
		}
		ASCompat.setProperty((mOnlinePopup : ASAny).nextassist, "mouseEnabled", false);
		Locale.setText(ASCompat.coerce((mOnlinePopup : ASAny).nextassist, flash.text.TextField), "LEADERBOARD_NEXT_ASSIST");
		ASCompat.setProperty((mOnlinePopup : ASAny).nextassist, "visible", false);
		ASCompat.setProperty((mOnlinePopup : ASAny).assist_time, "visible", false);
		EventListeners.add(mOnlinePopup, "rollOver", callStopOnPopupTimeToLiveTask);
		EventListeners.add(mOnlinePopup, "rollOut", hidePopup);
	}

	function loadOfflinePopup(swfAsset:SwfAsset) {
		var _loc2_ = swfAsset.getClass("DR_leaderboard_offline_tooltip");
		mOfflinePopup = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
		if (mOfflinePopup == null) {
			return;
		}
		mRootMovieClip.addChild(mOfflinePopup);
		mOfflinePopup.visible = false;
		SceneGraphManager.setGrayScaleSaturation(ASCompat.coerce((mOfflinePopup : ASAny).join_friend, flash.display.DisplayObject), 10);
		ASCompat.setProperty((mOfflinePopup : ASAny).title_label, "mouseEnabled", false);
		Locale.setText(ASCompat.coerce((mOfflinePopup : ASAny).title_label, flash.text.TextField), "LEADERBOARD_OFFLINE_TEXT");
		ASCompat.setProperty((mOfflinePopup : ASAny).join_friend.label, "mouseEnabled", false);
		Locale.setText(ASCompat.coerce((mOfflinePopup : ASAny).join_friend.label, flash.text.TextField), "LEADERBOARD_JOIN_FRIEND_BUTTON");
		ASCompat.setProperty((mOfflinePopup : ASAny).nextassist, "mouseEnabled", false);
		Locale.setText(ASCompat.coerce((mOfflinePopup : ASAny).nextassist, flash.text.TextField), "LEADERBOARD_NEXT_ASSIST");
		mMessageFriendButton = new UIButton(mDBFacade, ASCompat.coerce((mOfflinePopup : ASAny).message_friend, flash.display.MovieClip));
		Locale.setText(mMessageFriendButton.label, "LEADERBOARD_MESSAGE_FRIEND_BUTTON");
		mMessageFriendButton.navigationSelectedInteraction = callStopOnPopupTimeToLiveTask;
		disableMessageFriendButton();
		mRemoveOfflineFriendButton = new UIButton(mDBFacade, ASCompat.coerce((mOfflinePopup : ASAny).remove_friend, flash.display.MovieClip));
		Locale.setText(mRemoveOfflineFriendButton.label, "LEADERBOARD_REMOVE_FRIEND_BUTTON");
		mRemoveOfflineFriendButton.navigationSelectedInteraction = callStopOnPopupTimeToLiveTask;
		mRemoveOfflineFriendButton.releaseCallback = removeFriends;
		ASCompat.setProperty((mOfflinePopup : ASAny).nextassist, "visible", false);
		ASCompat.setProperty((mOfflinePopup : ASAny).assist_time, "visible", false);
		EventListeners.add(mOfflinePopup, "rollOver", callStopOnPopupTimeToLiveTask);
		EventListeners.add(mOfflinePopup, "rollOut", hidePopup);
	}

	function loadLeaderboard(swfAsset:SwfAsset) {
		var leaderboard = swfAsset.getClass("DR_leaderboard");
		mLeaderboard = ASCompat.coerce(ASCompat.createInstance(leaderboard, []), flash.display.MovieClip);
		mLeaderboard.y = mDBFacade.viewHeight - mLeaderboard.height;
		mRootMovieClip.addChild(mLeaderboard);
		mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).slot_0, flash.display.MovieClip), this, 0));
		mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).slot_1, flash.display.MovieClip), this, 1));
		mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).slot_2, flash.display.MovieClip), this, 2));
		mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).slot_3, flash.display.MovieClip), this, 3));
		mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).slot_4, flash.display.MovieClip), this, 4));
		mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).slot_5, flash.display.MovieClip), this, 5));
		mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).slot_6, flash.display.MovieClip), this, 6));
		mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).slot_7, flash.display.MovieClip), this, 7));
		mFriendSlots.push(new LeaderboardFriendSlot(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).slot_8, flash.display.MovieClip), this, 8));
		mInviteFriendButton = new UIButton(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).invite_friend, flash.display.MovieClip));
		Locale.setText(mInviteFriendButton.label, "INVITE_POPUP_BUTTON");
		mInviteFriendButton.releaseCallback = inviteFriendDR;
		mScrollRightButton = new UIButton(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).scrollRight, flash.display.MovieClip));
		mScrollLeftButton = new UIButton(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).scrollLeft, flash.display.MovieClip));
		mScrollPageRightButton = new UIButton(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).scrollPageRight, flash.display.MovieClip));
		mScrollPageLeftButton = new UIButton(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).scrollPageLeft, flash.display.MovieClip));
		mScrollRightButton.releaseCallback = function() {
			scrollLeaderboard(-1);
		};
		mScrollLeftButton.releaseCallback = function() {
			scrollLeaderboard(1);
		};
		mScrollPageRightButton.releaseCallback = function() {
			scrollLeaderboard(-mFriendSlots.length);
		};
		mScrollPageLeftButton.releaseCallback = function() {
			scrollLeaderboard(mFriendSlots.length);
		};
		mDBFacade.dbAccountInfo.getIgnoredFriendData();
		mFriendManagementButton = new UIButton(mDBFacade, ASCompat.coerce((mLeaderboard : ASAny).block_button, flash.display.MovieClip));
		Locale.setText(mFriendManagementButton.label, "FRIEND_MANAGEMENT_HEADING_FRIENDS");
		mFriendManagementButton.releaseCallback = function() {
			mTownStateMachine.enterFriendManagementState();
		};
		mAlert = ASCompat.coerce((mLeaderboard : ASAny).block_button.alert_icon, flash.display.MovieClip);
		mAlertRenderer = new MovieClipRenderController(mDBFacade, mAlert);
		mAlertRenderer.play((0 : UInt), true);
		mAlert.visible = false;
	}

	public function inviteFriendDR() {
		hidePopup();
		mDBFacade.metrics.log("InviteLeaderboardClickedDR");
		showDRInvitePopup();
	}

	public function setupNavigationlinks() {
		var _loc5_ = 0;
		mFriendManagementButton.clearLeftNavigation();
		mFriendManagementButton.clearRightNavigation();
		mInviteFriendButton.clearLeftNavigation();
		mInviteFriendButton.clearRightNavigation();
		var _loc2_:Array<ASAny> = [
			mScrollLeftButton,
			mScrollPageLeftButton,
			mScrollRightButton,
			mScrollPageRightButton
		];
		var _loc6_:UIButton;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc6_ = ASCompat.coerce(_tmp_, brain.uI.UIButton);
				_loc6_.clearLeftNavigation();
				_loc6_.clearRightNavigation();
				_loc6_.clearUpNavigation();
				_loc6_.clearDownNavigation();
			}
		var _loc4_:LeaderboardFriendSlot;
		final __ax4_iter_145 = mFriendSlots;
		if (checkNullIteratee(__ax4_iter_145))
			for (_tmp_ in __ax4_iter_145) {
				_loc4_ = _tmp_;
				_loc4_.friendPicButton.clearLeftNavigation();
				_loc4_.friendPicButton.clearRightNavigation();
			}
		var _loc3_ = mFriendSlots[mFriendSlots.length - 1].friendPicButton;
		var _loc1_ = mFriendSlots[0].friendPicButton;
		mFriendManagementButton.isToTheLeftOf(mScrollLeftButton);
		mScrollLeftButton.isToTheLeftOf(_loc3_);
		mScrollLeftButton.isAbove(mScrollPageLeftButton);
		mScrollPageLeftButton.leftNavigation = mFriendManagementButton;
		mScrollPageLeftButton.rightNavigation = _loc3_;
		_loc5_ = mFriendSlots.length - 1;
		while (_loc5_ > 0) {
			mFriendSlots[_loc5_].friendPicButton.isToTheLeftOf(mFriendSlots[_loc5_ - 1].friendPicButton);
			_loc5_--;
		}
		_loc1_.isToTheLeftOf(mScrollRightButton);
		mScrollRightButton.isToTheLeftOf(mInviteFriendButton);
		mScrollRightButton.isAbove(mScrollPageRightButton);
		mScrollPageRightButton.leftNavigation = _loc1_;
		mScrollPageRightButton.rightNavigation = mInviteFriendButton;
		_loc3_.leftNavigationAdditionalInteraction = minimizeCurrentPopup;
		_loc1_.rightNavigationAdditionalInteraction = minimizeCurrentPopup;
	}

	public function focusPreviousFriendSlot() {
		focusAdjacentFriendSlot(1);
	}

	public function focusNextFriendSlot() {
		focusAdjacentFriendSlot(-1);
	}

	function focusAdjacentFriendSlot(direction:Int) {
		var _loc3_ = (0 : UInt);
		var _loc5_ = 0;
		if (mFriendSlots.length == 0) {
			return;
		}
		var _loc2_ = -1;
		_loc3_ = (0 : UInt);
		while (_loc3_ < (mFriendSlots.length:UInt)) {
			if (mFriendSlots[(_loc3_ : Int)].friendPicButton.isFocused()) {
				_loc2_ = _loc3_;
				break;
			}
			_loc3_++;
		}
		if (_loc2_ < 0
			&& (mGiftFriendButton.isFocused()
				|| mRemoveOnlineFriendButton.isFocused()
				|| mMessageFriendButton.isFocused()
				|| mRemoveOfflineFriendButton.isFocused())) {
			_loc2_ = mCurrentPopupIndex;
		}
		if (_loc2_ < 0) {
			_loc5_ = direction < 0 ? mFriendSlots.length - 1 : 0;
		} else if (mFriendsLength <= (mFriendSlots.length : UInt)) {
			_loc5_ = (_loc2_ + direction + mFriendSlots.length) % mFriendSlots.length;
		} else {
			_loc5_ = scrollFriendIntoView(_loc2_ + mScrollIndex + direction);
		}
		var _loc4_ = mFriendSlots[_loc5_].friendPicButton;
		mDBFacade.menuNavigationController.setFocusedUiObject(_loc4_);
		if (_loc4_.navigationSelectedInteraction != null) {
			_loc4_.navigationSelectedInteraction();
		}
	}

	function scrollFriendIntoView(friendIndex:Int):Int {
		var _loc5_ = 0;
		var _loc2_:Int = mFriendsLength;
		var _loc3_ = mFriendSlots.length;
		if (friendIndex < 0) {
			friendIndex = _loc2_ - 1;
		} else if (friendIndex >= _loc2_) {
			friendIndex = 0;
		}
		var _loc4_ = mScrollIndex;
		if (friendIndex < mScrollIndex) {
			_loc4_ = friendIndex;
		} else if (friendIndex > mScrollIndex + _loc3_ - 1) {
			_loc4_ = friendIndex - _loc3_ + 1;
		}
		if (_loc4_ != mScrollIndex) {
			_loc5_ = _loc4_ - mScrollIndex;
			scrollLeaderboard(_loc5_);
		}
		return friendIndex - mScrollIndex;
	}

	public function setupTooltipNavigation(friendPicButton:UIButton, firstButton:UIButton, secondButton:UIButton = null) {
		var _loc5_:LeaderboardFriendSlot;
		final __ax4_iter_146 = mFriendSlots;
		if (checkNullIteratee(__ax4_iter_146))
			for (_tmp_ in __ax4_iter_146) {
				_loc5_ = _tmp_;
				resetFriendSlotUpNavigation(_loc5_.friendPicButton);
			}
		var _loc6_:Array<ASAny> = [
			mGiftFriendButton,
			mRemoveOnlineFriendButton,
			mMessageFriendButton,
			mRemoveOfflineFriendButton
		];
		var _loc8_:UIButton;
		if (checkNullIteratee(_loc6_))
			for (_tmp_ in _loc6_) {
				_loc8_ = ASCompat.coerce(_tmp_, brain.uI.UIButton);
				_loc8_.clearLeftNavigation();
				_loc8_.clearRightNavigation();
				_loc8_.clearUpNavigation();
				_loc8_.clearDownNavigation();
			}
		friendPicButton.clearUpNavigation();
		friendPicButton.upNavigation = firstButton;
		firstButton.downNavigation = friendPicButton;
		if (secondButton != null) {
			secondButton.isAbove(firstButton);
		}
		var _loc4_ = secondButton != null ? secondButton : firstButton;
		var _loc7_ = townButtonAbove((mCurrentPopupIndex : Int));
		if (_loc7_ != null) {
			_loc4_.upNavigation = _loc7_;
			_loc4_.upNavigationAdditionalInteraction = minimizeCurrentPopup;
		}
	}

	public function linkTownButtons(townButtons:Array<ASAny>) {
		var _loc4_ = 0;
		var _loc3_:UIButton = null;
		mTownButtons = townButtons;
		_loc4_ = 0;
		while (_loc4_ < townButtons.length) {
			_loc3_ = ASCompat.coerce(townButtons[_loc4_], brain.uI.UIButton);
			_loc3_.clearDownNavigation();
			_loc3_.downNavigation = mFriendSlots[mFriendSlots.length - 1 - _loc4_ * 3].friendPicButton;
			_loc4_++;
		}
		var _loc2_:LeaderboardFriendSlot;
		final __ax4_iter_147 = mFriendSlots;
		if (checkNullIteratee(__ax4_iter_147))
			for (_tmp_ in __ax4_iter_147) {
				_loc2_ = _tmp_;
				resetFriendSlotUpNavigation(_loc2_.friendPicButton);
			}
		mFriendManagementButton.clearUpNavigation();
		mFriendManagementButton.upNavigation = ASCompat.coerce(townButtons[0], brain.uI.UIObject);
		mInviteFriendButton.clearUpNavigation();
		mInviteFriendButton.upNavigation = ASCompat.coerce(townButtons[townButtons.length - 1], brain.uI.UIObject);
	}

	function townButtonAbove(friendSlotIndex:Int):UIButton {
		if (mTownButtons == null || friendSlotIndex < 0) {
			return null;
		}
		var _loc2_ = mFriendSlots.length - 1 - friendSlotIndex;
		return ASCompat.coerce(mTownButtons[
			ASCompat.floatToInt(Math.min(ASCompat.floatToInt(_loc2_ / 3), mTownButtons.length - 1))
		], brain.uI.UIButton);
	}

	function minimizeCurrentPopup() {
		callStopOnPopupTimeToLiveTask();
		mFriendSlots[(mCurrentPopupIndex : Int)].minimizePopup();
	}

	public function resetFriendSlotUpNavigation(friendPicButton:UIButton) {
		friendPicButton.clearUpNavigation();
		var _loc2_ = townButtonAbove(friendSlotIndexOf(friendPicButton));
		if (_loc2_ != null) {
			friendPicButton.upNavigation = _loc2_;
		}
	}

	function friendSlotIndexOf(friendPicButton:UIButton):Int {
		var _loc2_ = 0;
		_loc2_ = 0;
		while (_loc2_ < mFriendSlots.length) {
			if (mFriendSlots[_loc2_].friendPicButton == friendPicButton) {
				return _loc2_;
			}
			_loc2_++;
		}
		return -1;
	}

	public function showDRInvitePopup() {
		townStateMachine.setFriendManagementTabCategory((4 : UInt));
		townStateMachine.enterFriendManagementState();
		townStateMachine.setFriendManagementTabCategory((1 : UInt));
	}

	function friendDataSuccessCallback() {
		if (mDBFacade != null) {
			loadFriends();
		}
		if (mEventComponent != null) {
			mEventComponent.addListener("REFRESH_FRIENDS_EVENT", checkToRefreshLeaderboard);
		}
		if (mGetGiftsCallback != null) {
			mGetGiftsCallback();
		}
	}

	public function getFriendData() {
		if (mDBFacade.dbAccountInfo.friendInfos.size > 0) {
			friendDataSuccessCallback();
			return;
		}
		mDBFacade.dbAccountInfo.getFriendData(friendDataSuccessCallback);
	}

	function populateFriendSlots() {
		var _loc1_ = (0 : UInt);
		var _loc2_ = (0 : UInt);
		var _loc4_ = (0 : UInt);
		var _loc3_ = (0 : UInt);
		_loc1_ = (0 : UInt);
		while (_loc1_ < (mFriendSlots.length:UInt)) {
			mFriendSlots[(_loc1_ : Int)].populateSlot(null);
			_loc2_ = _loc1_ + mScrollIndex;
			if (_loc2_ < (mOnlineFriends.length:UInt)) {
				mFriendSlots[(_loc1_ : Int)].populateSlot(mOnlineFriends[(_loc2_ : Int)]);
			} else if ((_loc2_ : Float) - mOnlineFriends.length < mOfflineFriends.length) {
				mFriendSlots[(_loc1_ : Int)].populateSlot(mOfflineFriends[(_loc2_ - mOnlineFriends.length : Int)]);
			}
			_loc1_++;
		}
	}

	function scrollLeaderboard(value:Int) {
		hidePopup();
		mScrollIndex += value;
		if (mScrollIndex > (mFriendsLength : Float) - mFriendSlots.length) {
			mScrollIndex = (mFriendsLength - mFriendSlots.length : Int);
		}
		if (mScrollIndex < 0 || mFriendsLength < (mFriendSlots.length:UInt)) {
			mScrollIndex = 0;
		}
		if (mScrollIndex == 0) {
			mScrollRightButton.enabled = false;
			mScrollPageRightButton.enabled = false;
		} else {
			mScrollRightButton.enabled = true;
			mScrollPageRightButton.enabled = true;
		}
		if (mScrollIndex == (mFriendsLength : Float) - mFriendSlots.length) {
			mScrollLeftButton.enabled = false;
			mScrollPageLeftButton.enabled = false;
		} else {
			mScrollLeftButton.enabled = true;
			mScrollPageLeftButton.enabled = true;
		}
		populateFriendSlots();
		moveFocusOffSpentScrollButton();
	}

	function moveFocusOffSpentScrollButton() {
		if (!mScrollLeftButton.enabled && (mScrollLeftButton.isFocused() || mScrollPageLeftButton.isFocused())) {
			mDBFacade.menuNavigationController.setFocusedUiObject(mFriendSlots[mFriendSlots.length - 1].friendPicButton);
		} else if (!mScrollRightButton.enabled && (mScrollRightButton.isFocused() || mScrollPageRightButton.isFocused())) {
			mDBFacade.menuNavigationController.setFocusedUiObject(mFriendSlots[0].friendPicButton);
		}
	}

	function loadFriends() {
		var _loc3_:FriendInfo = null;
		var _loc2_:FriendInfo = null;
		var _loc4_ = mDBFacade.dbAccountInfo.friendInfos;
		var _loc1_ = _loc4_.keysToArray();
		mOfflineFriends.splice(0, (mOfflineFriends.length : UInt));
		mOnlineFriends.splice(0, (mOnlineFriends.length : UInt));
		var _loc5_:UInt;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc5_ = (ASCompat.toInt(_tmp_) : UInt);
				_loc2_ = ASCompat.coerce(_loc4_.itemFor(_loc5_), account.FriendInfo);
				if (_loc2_.id == mDBFacade.accountId) {
					_loc3_ = _loc2_;
				} else if (_loc2_.isOnline()) {
					mOnlineFriends.push(_loc2_);
				} else {
					mOfflineFriends.push(_loc2_);
				}
			}
		sortFriends();
		mOnlineFriends.unshift(_loc3_);
		mFriendsLength = (mOnlineFriends.length + mOfflineFriends.length:UInt);
		if (mFriendsLength <= (mFriendSlots.length : UInt)) {
			mScrollLeftButton.enabled = false;
			mScrollPageLeftButton.enabled = false;
		}
		populateFriendSlots();
	}

	function removeFriends() {}

	function sortFriends() {
		ASCompat.ASVector.sort(mOnlineFriends, sortBasedOnFriendsHighestAvatarLevel);
		ASCompat.ASVector.sort(mOfflineFriends, sortBasedOnFriendsHighestAvatarLevel);
	}

	function sortBasedOnFriendsHighestAvatarLevel(friend1:FriendInfo, friend2:FriendInfo):Int {
		if (friend1.trophies < friend2.trophies) {
			return 1;
		}
		return -1;
	}

	public function hidePopup(event:MouseEvent = null) {
		releaseTooltipFocus();
		if (mRefreshLeaderboard) {
			refreshLeaderboard();
		}
		if (mOnlinePopup != null) {
			mOnlinePopup.visible = false;
		}
		if (mOfflinePopup != null) {
			mOfflinePopup.visible = false;
		}
	}

	public function releaseTooltipFocus() {
		if (mFriendSlots.length == 0) {
			return;
		}
		if (mGiftFriendButton.isFocused()
			|| mRemoveOnlineFriendButton.isFocused()
			|| mMessageFriendButton.isFocused()
			|| mRemoveOfflineFriendButton.isFocused()) {
			mDBFacade.menuNavigationController.setFocusedUiObject(mFriendSlots[(mCurrentPopupIndex : Int)].friendPicButton);
		}
		var _loc1_:LeaderboardFriendSlot;
		final __ax4_iter_148 = mFriendSlots;
		if (checkNullIteratee(__ax4_iter_148))
			for (_tmp_ in __ax4_iter_148) {
				_loc1_ = _tmp_;
				resetFriendSlotUpNavigation(_loc1_.friendPicButton);
			}
	}

	@:isVar public var alert(never, set):Bool;

	public function set_alert(val:Bool):Bool {
		return mAlert.visible = val;
	}

	@:isVar public var onlinePopup(get, never):MovieClip;

	public function get_onlinePopup():MovieClip {
		return mOnlinePopup;
	}

	public function setOnlinePopupTitle(text:String) {
		var _loc2_ = Math.NaN;
		var _loc3_ = ASCompat.coerce((mOnlinePopup : ASAny).title_label, flash.text.TextField);
		_loc3_.y = mOnlinePopupTitleY;
		_loc3_.height = mOnlinePopupTitleHeight * 2;
		if (mOnlinePopupBg != null) {
			mOnlinePopupBg.scaleY = mOnlinePopupBgScaleY;
			mOnlinePopupBg.y = mOnlinePopupBgY;
		}
		TextUtil.setText(_loc3_, text);
		var _loc4_ = ASCompat.floatToInt(Math.max(0, _loc3_.numLines - 1));
		var _loc5_ = _loc4_ > 0 ? _loc4_ * _loc3_.getLineMetrics(0).height * Math.abs(_loc3_.scaleY) : 0;
		_loc3_.height = mOnlinePopupTitleHeight + _loc5_;
		_loc3_.y -= _loc5_;
		if (mOnlinePopupBg != null && _loc5_ > 0) {
			_loc2_ = mOnlinePopupBg.getBounds(mOnlinePopup).bottom;
			mOnlinePopupBg.height += _loc5_;
			mOnlinePopupBg.y += _loc2_ - mOnlinePopupBg.getBounds(mOnlinePopup).bottom;
		}
	}

	@:isVar public var offlinePopup(get, never):MovieClip;

	public function get_offlinePopup():MovieClip {
		return mOfflinePopup;
	}

	@:isVar public var messageFriend(get, never):UIButton;

	public function get_messageFriend():UIButton {
		return mMessageFriendButton;
	}

	@:isVar public var removeOnlineFriend(get, never):UIButton;

	public function get_removeOnlineFriend():UIButton {
		return mRemoveOnlineFriendButton;
	}

	@:isVar public var removeOfflineFriend(get, never):UIButton;

	public function get_removeOfflineFriend():UIButton {
		return mRemoveOfflineFriendButton;
	}

	@:isVar public var giftFriend(get, never):UIButton;

	public function get_giftFriend():UIButton {
		return mGiftFriendButton;
	}

	public function setRootMovieClip(root:MovieClip) {
		mRootMovieClip = root;
		if (mOnlinePopup != null) {
			mRootMovieClip.addChild(mOnlinePopup);
		}
		if (mOfflinePopup != null) {
			mRootMovieClip.addChild(mOfflinePopup);
		}
		if (mLeaderboard != null) {
			mRootMovieClip.addChild(mLeaderboard);
		}
	}

	public function setInitialScrollBarStatus() {
		mScrollRightButton.enabled = false;
		mScrollPageRightButton.enabled = false;
	}

	function checkToRefreshLeaderboard(event:Event) {
		if (mOnlinePopup.visible || mOfflinePopup.visible) {
			mRefreshLeaderboard = true;
		} else {
			refreshLeaderboard();
		}
	}

	public function refreshLeaderboard() {
		mRefreshLeaderboard = false;
		hidePopup();
		loadFriends();
	}

	@:isVar public var currentPopupIndex(get, set):UInt;

	public function set_currentPopupIndex(value:UInt):UInt {
		return mCurrentPopupIndex = value;
	}

	function get_currentPopupIndex():UInt {
		return mCurrentPopupIndex;
	}

	@:isVar public var mustRefreshLeaderboard(get, never):Bool;

	public function get_mustRefreshLeaderboard():Bool {
		return mRefreshLeaderboard;
	}

	public function callStopOnPopupTimeToLiveTask(event:MouseEvent = null) {
		var _loc2_:LeaderboardFriendSlot;
		final __ax4_iter_149 = mFriendSlots;
		if (checkNullIteratee(__ax4_iter_149))
			for (_tmp_ in __ax4_iter_149) {
				_loc2_ = _tmp_;
				_loc2_.stopPopupTimeToLiveTask();
			}
	}

	public function destroy() {
		initialized = false;
		mDBFacade = null;
		var _loc2_:LeaderboardFriendSlot;
		final __ax4_iter_150 = mFriendSlots;
		if (checkNullIteratee(__ax4_iter_150))
			for (_tmp_ in __ax4_iter_150) {
				_loc2_ = _tmp_;
				_loc2_.destroy();
				_loc2_ = null;
			}
		if (mInviteFriendSlot != null) {
			mInviteFriendSlot.destroy();
		}
		mInviteFriendSlot = null;
		if (mInviteFriendButton != null) {
			mInviteFriendButton.destroy();
		}
		mInviteFriendButton = null;
		if (mAlertRenderer != null) {
			mAlertRenderer.destroy();
		}
		mAlertRenderer = null;
		var _loc3_:FriendInfo;
		final __ax4_iter_151 = mOnlineFriends;
		if (checkNullIteratee(__ax4_iter_151))
			for (_tmp_ in __ax4_iter_151) {
				_loc3_ = _tmp_;
				_loc3_ = null;
			}
		var _loc1_:FriendInfo;
		final __ax4_iter_152 = mOfflineFriends;
		if (checkNullIteratee(__ax4_iter_152))
			for (_tmp_ in __ax4_iter_152) {
				_loc1_ = _tmp_;
				_loc1_ = null;
			}
		if (mEventComponent != null) {
			mEventComponent.destroy();
		}
		mEventComponent = null;
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
		}
		mAssetLoadingComponent = null;
		if (mSceneGraphComponent != null) {
			mSceneGraphComponent.destroy();
		}
		mSceneGraphComponent = null;
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
		}
		mLogicalWorkComponent = null;
		if (mMessageFriendButton != null) {
			mMessageFriendButton.destroy();
		}
		mMessageFriendButton = null;
		if (mRemoveOnlineFriendButton != null) {
			mRemoveOnlineFriendButton.destroy();
		}
		mRemoveOnlineFriendButton = null;
		if (mRemoveOfflineFriendButton != null) {
			mRemoveOfflineFriendButton.destroy();
		}
		mRemoveOfflineFriendButton = null;
		if (mGiftFriendButton != null) {
			mGiftFriendButton.destroy();
		}
		mGiftFriendButton = null;
		if (mScrollRightButton != null) {
			mScrollRightButton.destroy();
		}
		mScrollRightButton = null;
		if (mScrollLeftButton != null) {
			mScrollLeftButton.destroy();
		}
		mScrollLeftButton = null;
		if (mScrollPageRightButton != null) {
			mScrollPageRightButton.destroy();
		}
		mScrollPageRightButton = null;
		if (mScrollPageLeftButton != null) {
			mScrollPageLeftButton.destroy();
		}
		mScrollPageLeftButton = null;
		mRootMovieClip = null;
		mLeaderboard = null;
		mOnlinePopupBg = null;
		mOnlinePopup = null;
		mOfflinePopup = null;
		mStoreCallback = null;
		mGetGiftsCallback = null;
	}

	@:isVar public var currentStateName(get, set):String;

	public function set_currentStateName(value:String):String {
		return mCurrentStateName = value;
	}

	function get_currentStateName():String {
		return mCurrentStateName;
	}

	@:isVar public var onlineFriends(get, never):Vector<FriendInfo>;

	public function get_onlineFriends():Vector<FriendInfo> {
		return mOnlineFriends;
	}

	@:isVar public var offlineFriends(get, never):Vector<FriendInfo>;

	public function get_offlineFriends():Vector<FriendInfo> {
		return mOfflineFriends;
	}

	@:isVar public var townStateMachine(get, never):TownStateMachine;

	public function get_townStateMachine():TownStateMachine {
		return mTownStateMachine;
	}

	@:isVar public var getManageFriendsButton(get, never):UIButton;

	public function get_getManageFriendsButton():UIButton {
		return mFriendManagementButton;
	}

	@:isVar public var getInviteFriendsButton(get, never):UIButton;

	public function get_getInviteFriendsButton():UIButton {
		return mInviteFriendButton;
	}

	public function enableMessageFriendButton() {
		SceneGraphManager.setGrayScaleSaturation(ASCompat.coerce((mOfflinePopup : ASAny).message_friend, flash.display.DisplayObject), 100);
		ASCompat.setProperty((mOfflinePopup : ASAny).message_friend.label, "mouseEnabled", true);
		mMessageFriendButton.enabled = true;
	}

	public function disableMessageFriendButton() {
		SceneGraphManager.setGrayScaleSaturation(ASCompat.coerce((mOfflinePopup : ASAny).message_friend, flash.display.DisplayObject), 10);
		ASCompat.setProperty((mOfflinePopup : ASAny).message_friend.label, "mouseEnabled", false);
		mMessageFriendButton.enabled = false;
	}
}
