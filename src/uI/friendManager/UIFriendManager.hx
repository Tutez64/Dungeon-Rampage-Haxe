package uI.friendManager;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIObject;
import brain.uI.UIRadioButton;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import collections.IMapIterator;
import collections.Map;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import town.TownHeader;
import town.TownStateMachine;
import uI.friendManager.states.UIBlocked;
import uI.friendManager.states.UIFMState;
import uI.friendManager.states.UIFriends;
import uI.friendManager.states.UIInvite;
import uI.friendManager.states.UIPending;
import uI.uINewsFeed.UINewsFeedController;
import flash.display.MovieClip;
import flash.filters.ColorMatrixFilter;

class UIFriendManager {
	public static inline final ERROR_TOO_MANY_FRIENDS = -290;

	public static inline final STATE_FRIENDS = (1 : UInt);

	public static inline final STATE_PENDING = (2 : UInt);

	public static inline final STATE_BLOCKED = (3 : UInt);

	public static inline final STATE_INVITE = (4 : UInt);

	public static var FRIENDSHIP_MADE:String = "FRIENDSHIP_MADE";

	static final TAB_NAVIGATION_ORDER:Vector<UInt> = Vector.ofArray(([(1 : UInt), (4 : UInt), (2 : UInt), (3 : UInt)] : Array<UInt>));

	var mDBFacade:DBFacade;

	var mSceneGraphComponent:SceneGraphComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mRoot:MovieClip;

	var mTownHeader:TownHeader;

	var mSwfAsset:SwfAsset;

	public var states:Map;

	public var currentState:Int = -1;

	var mTabButtons:Map;

	var mStateLayer:MovieClip;

	var mAlert:MovieClip;

	var mAlertRenderer:MovieClipRenderController;

	var mNewsFeedController:UINewsFeedController;

	public function new(dbFacade:DBFacade, townStateMachine:TownStateMachine, rootClip:MovieClip) {
		mDBFacade = dbFacade;
		mSwfAsset = townStateMachine.townSwf;
		mTownHeader = townStateMachine.townHeader;
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "UIFriendManager");
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "UIFriendManager");
		states = new Map();
		states.add(1, new UIFriends(this, mDBFacade, townStateMachine));
		states.add(4, new UIInvite(this, mDBFacade, townStateMachine));
		states.add(2, new UIPending(this, mDBFacade, townStateMachine));
		states.add(3, new UIBlocked(this, mDBFacade, townStateMachine));
		if (mNewsFeedController == null) {
			mNewsFeedController = new UINewsFeedController(mDBFacade);
		}
		mNewsFeedController.startFeedTask();
		setupUI(rootClip);
	}

	public static function createFriendRPCErrorCallback(dbFacade:DBFacade, contextName:String):ASFunction {
		return function(param1:Error) {
			handleFriendError(param1, dbFacade, contextName);
		};
	}

	public static function handleFriendError(e:Error, dbFacade:DBFacade, contextName:String = null) {
		var _loc4_ = ASCompat.stringAsBool(contextName) ? contextName : "FriendRPC";
		if (e.errorID == -290) {
			Logger.warn(_loc4_ + " failed with too many friends: " + Std.string(e.message));
			dbFacade.errorPopup(Locale.getString("DRINVITE_FAILED_TOO_MANY_FRIENDS_POPUP_TITLE"),
				Locale.getString("DRINVITE_FAILED_TOO_MANY_FRIENDS_POPUP_DESC") + Std.string(e.message), "TOO_MANY_FRIENDS_POPUP");
		} else {
			Logger.error(_loc4_ + " failed with error code: " + e.errorID + " and message: " + Std.string(e.message), e);
		}
	}

	function setupUI(rootClip:MovieClip) {
		var tabButton:UIRadioButton;
		var tabInt:UInt;
		var iter:IMapIterator;
		mRoot = rootClip;
		mTabButtons = new Map();
		var group = "UIFriendsTabGroup";
		mTabButtons.add(1, new UIRadioButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).tab_friends, flash.display.MovieClip), group));
		mTabButtons.add(4, new UIRadioButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).tab_invite, flash.display.MovieClip), group));
		mTabButtons.add(2, new UIRadioButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).tab_pending, flash.display.MovieClip), group));
		mTabButtons.add(3, new UIRadioButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).tab_blocked, flash.display.MovieClip), group));
		iter = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (iter.hasNext()) {
			tabButton = ASCompat.coerce(iter.next(), brain.uI.UIRadioButton);
			tabInt = (ASCompat.toInt(iter.key) : UInt);
			Locale.setText(tabButton.label, "FRIEND_MANAGEMENT_TAB_" + Std.string(tabInt));
			ASCompat.setProperty(tabButton.root, "category", tabInt);
			ASCompat.setProperty((tabButton.root : ASAny).new_label, "visible", false);
			tabButton.releaseCallbackThis = function(param1:brain.uI.UIButton) {
				changeTab(ASCompat.reinterpretAs(param1, UIRadioButton));
			};
			tabButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			tabButton.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
		}
		mStateLayer = new MovieClip();
		mRoot.addChild(mStateLayer);
		mAlert = ASCompat.coerce((mRoot : ASAny).tab_pending.alert_icon, flash.display.MovieClip);
		mAlertRenderer = new MovieClipRenderController(mDBFacade, mAlert);
		mAlertRenderer.play((0 : UInt), true);
		mAlert.visible = false;
	}

	public function enableTabButton(state:UInt) {
		var _loc2_ = ASCompat.coerce(mTabButtons.itemFor(state), brain.uI.UIRadioButton);
		_loc2_.root.filters = cast([new ColorMatrixFilter()]);
		if (state == 2) {}
	}

	public function disableTabButton(state:UInt) {
		var _loc2_ = ASCompat.coerce(mTabButtons.itemFor(state), brain.uI.UIRadioButton);
		var _loc3_:Float = 0.212671;
		var _loc5_:Float = 0.71516;
		var _loc4_:Float = 0.072169;
		var _loc6_:Array<ASAny> = [];
		_loc6_ = _loc6_.concat([_loc3_, _loc5_, _loc4_, 0, 0]);
		_loc6_ = _loc6_.concat([_loc3_, _loc5_, _loc4_, 0, 0]);
		_loc6_ = _loc6_.concat([_loc3_, _loc5_, _loc4_, 0, 0]);
		_loc6_ = _loc6_.concat([0, 0, 0, 1, 0]);
		_loc2_.root.filters = cast([new ColorMatrixFilter(cast(_loc6_))]);
	}

	public function init(state:UInt) {
		ASCompat.setProperty(mTabButtons.itemFor(state), "selected", true);
		changeState(state);
	}

	public function animateEntry() {
		if (mDBFacade.featureFlags.getFlagValue("want-town-animations")) {
			mTownHeader.rootMovieClip.visible = false;
			mLogicalWorkComponent.doLater(0.20833333333333334, function(param1:brain.clock.GameClock) {
				mTownHeader.animateHeader();
			});
		}
	}

	public function changeTab(radioButton:UIRadioButton) {
		var wrappedCallBack:ASFunction;
		radioButton.selected = true;
		wrappedCallBack = function() {
			changeState((ASCompat.toInt((radioButton.root : ASAny).category) : UInt));
		};
		wrappedCallBack();
	}

	public function changeState(newState:UInt) {
		if ((currentState : UInt) == newState) {
			return;
		}
		if (currentState > -1) {
			states.itemFor(currentState).exit();
		}
		currentState = (newState : Int);
		states.itemFor(currentState).enter();
		linkTabsToCurrentState();
	}

	public function showPreviousTab() {
		showAdjacentTab(-1);
	}

	public function showNextTab() {
		showAdjacentTab(1);
	}

	function showAdjacentTab(direction:Int) {
		var _loc5_ = TAB_NAVIGATION_ORDER.indexOf((currentState : UInt));
		if (_loc5_ < 0) {
			return;
		}
		var _loc4_ = (_loc5_ + direction + TAB_NAVIGATION_ORDER.length) % TAB_NAVIGATION_ORDER.length;
		var _loc3_ = ASCompat.coerce(mTabButtons.itemFor(TAB_NAVIGATION_ORDER[_loc4_]), brain.uI.UIRadioButton);
		changeTab(_loc3_);
		var _loc2_ = ASCompat.dynamicAs(states.itemFor(currentState), UIFMState).getFirstNavigationUIObject();
		if (_loc2_ != null && _loc2_.canBeFocused()) {
			mDBFacade.menuNavigationController.setFocusedUiObject(_loc2_);
		} else if (_loc3_.canBeFocused()) {
			mDBFacade.menuNavigationController.setFocusedUiObject(_loc3_);
		}
	}

	public function setupMenuNavigation() {
		var _loc3_ = ASCompat.coerce(mTabButtons.itemFor(1), brain.uI.UIRadioButton);
		var _loc4_ = ASCompat.coerce(mTabButtons.itemFor(4), brain.uI.UIRadioButton);
		var _loc1_ = ASCompat.coerce(mTabButtons.itemFor(2), brain.uI.UIRadioButton);
		var _loc2_ = ASCompat.coerce(mTabButtons.itemFor(3), brain.uI.UIRadioButton);
		_loc3_.isToTheLeftOf(_loc4_);
		_loc4_.isToTheLeftOf(_loc1_);
		_loc1_.isToTheLeftOf(_loc2_);
		mTownHeader.addCoinButton.isAbove(_loc3_);
		_loc4_.upNavigation = mTownHeader.addCoinButton;
		mTownHeader.addGemButton.isAbove(_loc1_);
		mTownHeader.closeButton.isAbove(_loc2_);
		linkTabsToCurrentState();
	}

	public function resetMenuNavigation() {
		var _loc2_:UIRadioButton = null;
		var _loc1_ = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.coerce(_loc1_.next(), brain.uI.UIRadioButton);
			_loc2_.clearNavigationAndInteractions();
			_loc2_.setFocused(false);
		}
	}

	@:isVar public var currentTabButton(get, never):UIRadioButton;

	public function get_currentTabButton():UIRadioButton {
		if (currentState < 0) {
			return null;
		}
		return ASCompat.coerce(mTabButtons.itemFor(currentState), brain.uI.UIRadioButton);
	}

	public function linkTabsToCurrentState() {
		var _loc2_:UIRadioButton = null;
		var _loc3_ = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (_loc3_.hasNext()) {
			_loc2_ = ASCompat.coerce(_loc3_.next(), brain.uI.UIRadioButton);
			_loc2_.clearDownNavigation();
		}
		if (currentState < 0) {
			return;
		}
		var _loc1_ = ASCompat.dynamicAs(states.itemFor(currentState), UIFMState).getFirstNavigationUIObject();
		if (_loc1_ == null) {
			return;
		}
		_loc3_ = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (_loc3_.hasNext()) {
			_loc2_ = ASCompat.coerce(_loc3_.next(), brain.uI.UIRadioButton);
			_loc2_.downNavigation = _loc1_;
		}
		_loc1_.clearUpNavigation();
		_loc1_.upNavigation = ASCompat.coerce(mTabButtons.itemFor(currentState), brain.uI.UIObject);
	}

	public function updateHeading(str:String) {
		TextUtil.setText(ASCompat.coerce((mRoot : ASAny).avatar_heading_text, flash.text.TextField), str);
	}

	public function updateDescription(str:String, selectable:Bool = false) {
		TextUtil.setText(ASCompat.coerce((mRoot : ASAny).avatar_description_text, flash.text.TextField), str, 2.73);
		TextUtil.fitToField(ASCompat.coerce((mRoot : ASAny).avatar_description_text, flash.text.TextField));
		ASCompat.setProperty((mRoot : ASAny).avatar_description_text, "selectable", selectable);
	}

	public function cleanUp() {
		if (currentState > -1) {
			states.itemFor(currentState).exit();
			currentState = -1;
		}
	}

	@:isVar public var alert(never, set):Bool;

	public function set_alert(val:Bool):Bool {
		return mAlert.visible = val;
	}

	@:isVar public var root(get, never):MovieClip;

	public function get_root():MovieClip {
		return mRoot;
	}

	public function addToUI(mc:MovieClip) {
		mStateLayer.addChild(mc);
	}

	public function removeFromUI(mc:MovieClip) {
		mStateLayer.removeChild(mc);
	}

	public function clearUI() {
		while (mStateLayer.numChildren > 0) {
			mStateLayer.removeChild(mStateLayer.getChildAt(mStateLayer.numChildren - 1));
		}
	}

	public function setPendingList(pending:Array<ASAny>) {
		Logger.debug("setPending");
		if (states.itemFor(2) != null) {
			ASCompat.setProperty(states.itemFor(2), "pendingFriendRequests", pending);
		}
	}

	public function destroy() {
		var _loc2_:UIRadioButton = null;
		var _loc3_:UIFMState = null;
		var _loc1_ = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.coerce(_loc1_.next(), brain.uI.UIRadioButton);
			_loc2_.destroy();
		}
		mTabButtons.clear();
		mTabButtons = null;
		if (mAlertRenderer != null) {
			mAlertRenderer.destroy();
			mAlertRenderer = null;
		}
		cleanUp();
		var _loc4_ = ASCompat.reinterpretAs(states.iterator(), IMapIterator);
		while (_loc4_.hasNext()) {
			_loc3_ = ASCompat.dynamicAs(_loc4_.next(), UIFMState);
			if (_loc3_ != null) {
				_loc3_.destroy();
			}
		}
		states.clear();
		states = null;
		mDBFacade = null;
		mSwfAsset = null;
		mTownHeader = null;
		if (mNewsFeedController != null) {
			mNewsFeedController.destroy();
			mNewsFeedController = null;
		}
		mSceneGraphComponent.destroy();
		mAssetLoadingComponent.destroy();
		mLogicalWorkComponent.destroy();
	}
}
