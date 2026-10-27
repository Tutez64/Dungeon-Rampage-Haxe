package town;

import account.FriendInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.event.EventComponent;
import brain.render.MovieClipRenderController;
import brain.uI.UIObject;
import brain.workLoop.LogicalWorkComponent;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMInventoryBase;
import uI.leaderboard.UILeaderboard;
import uI.map.UIMapWorldMap;
import flash.display.MovieClip;

class MapTownSubState extends TownSubState {
	public static inline final SCREENS_PATH = "Resources/Art2D/UI/db_UI_screens.swf";

	public static inline final NAME = "MapTownSubState";

	var mScreensMovieClip:MovieClip;

	var mWorkComponent:LogicalWorkComponent;

	var mEventComponent:EventComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mClipRenderController:MovieClipRenderController;

	var mWorldMap:UIMapWorldMap;

	var mUILeaderboard:UILeaderboard;

	public function new(dbFacade:DBFacade, townStateMachine:TownStateMachine) {
		super(dbFacade, townStateMachine, "MapTownSubState");
		mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
	}

	override function setupState() {
		super.setupState();
		mWorkComponent = new LogicalWorkComponent(mDBFacade, "MapTownSubState");
		mEventComponent = new EventComponent(mDBFacade);
		mWorldMap = new UIMapWorldMap(mDBFacade, mRootMovieClip, mTownStateMachine.townSwf, mTownStateMachine);
	}

	public function animateEntry() {
		if (mDBFacade.featureFlags.getFlagValue("want-town-animations")) {
			if (mTownStateMachine.townHeader.rootMovieClip != null) {
				mTownStateMachine.townHeader.rootMovieClip.visible = false;
				mWorkComponent.doLater(0.20833333333333334, function(param1:brain.clock.GameClock) {
					if (mTownStateMachine != null) {
						mTownStateMachine.townHeader.animateHeader();
					}
				});
			}
		}
	}

	function initMap() {
		var tavernCallback:ASFunction = function() {
			mTownStateMachine.enterTavernState(true);
		};
		var inventoryCallback:ASFunction = function() {
			mTownStateMachine.enterInventoryState(true, GMInventoryBase.POWERUP_CATEGORY);
		};
		var shopCallback:ASFunction = function() {
			mTownStateMachine.enterShopState(true, "STUFF");
		};
		mWorldMap.initialize(tavernCallback, inventoryCallback, shopCallback, mTownStateMachine.enterHomeState);
		mUILeaderboard = mDBFacade.mainStateMachine.leaderboard;
		mUILeaderboard.setRootMovieClip(mRootMovieClip);
		mUILeaderboard.currentStateName = "MapTownSubState";
		mUILeaderboard.hidePopup();
		animateEntry();
		mTownStateMachine.townHeader.showCloseButton(true);
		mTownStateMachine.townHeader.title = Locale.getString("WORLD_MAP_HEADER");
	}

	override public function enterState() {
		super.enterState();
		mEventComponent.addListener(FriendInfo.FRIEND_SCORES_PARSED, function(param1:flash.events.Event) {
			var currentNodeButton:UIObject;
			popBattlePopupLayer();
			mWorldMap.deinit();
			initMap();
			currentNodeButton = mWorldMap.getCurrentNodeButton();
			if (currentNodeButton != null) {
				mDBFacade.menuNavigationController.replaceLayerUIObjects("MAP_MENU", currentNodeButton, currentNodeButton);
			}
		});
		if (mWorkComponent == null) {
			mWorkComponent = new LogicalWorkComponent(mDBFacade, "MapTownSubState");
		}
		initMap();
		super.resetHeaderLinks();
		super.setupHeaderLinks();
		mDBFacade.menuNavigationController.pushNewLayer("MAP_MENU", mTownStateMachine.townHeader.determineCallback, mWorldMap.getCurrentNodeButton(),
			mWorldMap.getCurrentNodeButton(), mWorldMap.showPreviousLeague, mWorldMap.showNextLeague);
	}

	override public function exitState() {
		super.exitState();
		popBattlePopupLayer();
		mWorldMap.deinit();
		mDBFacade.menuNavigationController.popLayer("MAP_MENU");
		if (mWorkComponent != null) {
			mWorkComponent.destroy();
			mWorkComponent = null;
		}
		if (mClipRenderController != null) {
			mClipRenderController.destroy();
			mClipRenderController = null;
		}
		if (mEventComponent != null) {
			mEventComponent.removeAllListeners();
		}
	}

	/**
		An open battle popup's layer sits above MAP_MENU and holds the popup's buttons, which deinit destroys
		without popping it: MAP_MENU's popLayer was then refused, and the next layer popped focused a
		destroyed button.
	**/
	function popBattlePopupLayer() {
		if (mDBFacade.menuNavigationController.getTopUILayer() == "UI_MAP_BATTLE_POPUP") {
			mDBFacade.menuNavigationController.popLayer("UI_MAP_BATTLE_POPUP");
		}
	}

	override public function destroy() {
		if (mWorldMap != null) {
			mWorldMap.deinit();
			mWorldMap = null;
		}
		if (mEventComponent != null) {
			mEventComponent.destroy();
			mEventComponent = null;
		}
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		super.destroy();
	}
}
