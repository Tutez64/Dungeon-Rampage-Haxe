package uI.friendManager;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIRadioButton;
import brain.workLoop.LogicalWorkComponent;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import town.TownHeader;
import town.TownStateMachine;
import uI.friendManager.states.UIBlocked;
import uI.friendManager.states.UIFriends;
import uI.friendManager.states.UIInvite;
import uI.friendManager.states.UIPending;
import uI.uINewsFeed.UINewsFeedController;
import flash.display.MovieClip;
import flash.filters.ColorMatrixFilter;
import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IMapIterator;

class UIFriendManager {
	public static inline final ERROR_TOO_MANY_FRIENDS = -290;

	public static inline final STATE_FRIENDS = (1 : UInt);

	public static inline final STATE_PENDING = (2 : UInt);

	public static inline final STATE_BLOCKED = (3 : UInt);

	public static inline final STATE_INVITE = (4 : UInt);

	public static var FRIENDSHIP_MADE:String = "FRIENDSHIP_MADE";

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
				Locale.getString("DRINVITE_FAILED_TOO_MANY_FRIENDS_POPUP_DESC") + Std.string(e.message));
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
		mTabButtons.add(1, new UIRadioButton(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).tab_friends, flash.display.MovieClip), group));
		mTabButtons.add(4, new UIRadioButton(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).tab_invite, flash.display.MovieClip), group));
		mTabButtons.add(2, new UIRadioButton(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).tab_pending, flash.display.MovieClip), group));
		mTabButtons.add(3, new UIRadioButton(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).tab_blocked, flash.display.MovieClip), group));
		iter = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (iter.hasNext()) {
			tabButton = ASCompat.dynamicAs(iter.next(), brain.uI.UIRadioButton);
			tabInt = (ASCompat.toInt(iter.key) : UInt);
			tabButton.label.text = Locale.getString("FRIEND_MANAGEMENT_TAB_" + Std.string(tabInt));
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
		mAlert = ASCompat.dynamicAs((mRoot : ASAny).tab_pending.alert_icon, flash.display.MovieClip);
		mAlertRenderer = new MovieClipRenderController(mDBFacade, mAlert);
		mAlertRenderer.play((0 : UInt), true);
		mAlert.visible = false;
	}

	public function enableTabButton(state:UInt) {
		var _loc2_ = ASCompat.dynamicAs(mTabButtons.itemFor(state), brain.uI.UIRadioButton);
		_loc2_.root.filters = cast([new ColorMatrixFilter()]);
		if (state == 2) {}
	}

	public function disableTabButton(state:UInt) {
		var _loc2_ = ASCompat.dynamicAs(mTabButtons.itemFor(state), brain.uI.UIRadioButton);
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
		var wrappedCallBack:ASFunction = function() {
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
	}

	public function updateHeading(str:String) {
		ASCompat.setProperty((mRoot : ASAny).avatar_heading_text, "text", str);
	}

	public function updateDescription(str:String, selectable:Bool = false) {
		ASCompat.setProperty((mRoot : ASAny).avatar_description_text, "text", str);
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
		if (ASCompat.mapItemForNeNull(states, 2)) {
			ASCompat.setProperty(states.itemFor(2), "pendingFriendRequests", pending);
		}
	}

	public function destroy() {
		var _loc2_:UIRadioButton = null;
		var _loc1_ = ASCompat.reinterpretAs(mTabButtons.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.dynamicAs(_loc1_.next(), brain.uI.UIRadioButton);
			_loc2_.destroy();
		}
		mTabButtons.clear();
		mTabButtons = null;
		if (mAlertRenderer != null) {
			mAlertRenderer.destroy();
			mAlertRenderer = null;
		}
		cleanUp();
		states = null;
		mDBFacade = null;
		mSwfAsset = null;
		mTownHeader = null;
		mNewsFeedController.stopFeedTask();
		mSceneGraphComponent.destroy();
		mAssetLoadingComponent.destroy();
		mLogicalWorkComponent.destroy();
	}
}
