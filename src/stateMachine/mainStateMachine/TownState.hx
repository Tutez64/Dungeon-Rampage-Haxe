package stateMachine.mainStateMachine;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.sceneGraph.SceneGraphComponent;
import brain.stateMachine.State;
import facade.DBFacade;
import facade.TrickleCacheLoader;
import town.TownStateMachine;
import uI.leaderboard.UILeaderboard;
import flash.display.MovieClip;
import flash.geom.Vector3D;

class TownState extends State {
	public static inline final TOWN_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	public static inline final MAP_PATH = "Resources/Art2D/UI/db_UI_map.swf";

	public static inline final NAME = "TownState";

	var mDBFacade:DBFacade;

	var mPlayGameCallback:ASFunction;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSceneGraphComponent:SceneGraphComponent;

	var mTownRoot:MovieClip;

	var mMapSwfAsset:SwfAsset;

	var mTownSwfAsset:SwfAsset;

	var mTownStateMachine:TownStateMachine;

	var mJumpToMapState:Bool = false;

	public function new(dbFacade:DBFacade) {
		super("TownState");
		mDBFacade = dbFacade;
	}

	public static function preLoadAssets(dbFacade:DBFacade) {
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"), dbFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_map.swf"), dbFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"), dbFacade);
	}

	override public function destroy() {
		mDBFacade = null;
		mMapSwfAsset = null;
		mTownSwfAsset = null;
		mPlayGameCallback = null;
		super.destroy();
	}

	@:isVar public var townStateMachine(get, never):TownStateMachine;

	public function get_townStateMachine():TownStateMachine {
		return mTownStateMachine;
	}

	override public function enterState() {
		Logger.debug("MAIN STATE MACHINE TRANSITION -- ENTERING TOWN STATE");
		super.enterState();
		mDBFacade.dbAccountInfo.setPresenceTask("TOWN");
		mTownStateMachine = new TownStateMachine(mDBFacade);
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "TownState");
		loadNecessarySwfs();
		mDBFacade.camera.centerCameraOnPoint(new Vector3D());
		mSceneGraphComponent.fadeIn(0.5);
	}

	override public function exitState() {
		mTownStateMachine.exit();
		mTownStateMachine.destroy();
		mTownStateMachine = null;
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mSceneGraphComponent.destroy();
		mSceneGraphComponent = null;
		super.exitState();
	}

	function loadNecessarySwfs() {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"), setTownSwf);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_map.swf"), setMapSwf);
		mAssetLoadingComponent.setTransitionToEmptyCallback(setUpTownScreen);
	}

	function setTownSwf(swfAsset:SwfAsset) {
		mTownSwfAsset = swfAsset;
	}

	function setMapSwf(swfAsset:SwfAsset) {
		mMapSwfAsset = swfAsset;
	}

	function setUpTownScreen() {
		mTownRoot = mTownSwfAsset.root;
		mTownStateMachine.setSwfs(mTownSwfAsset, mMapSwfAsset);
		startLazyLoading();
		if (mJumpToMapState) {
			mTownStateMachine.enterMapState();
		} else {
			mTownStateMachine.enterHomeState();
		}
		mJumpToMapState = false;
	}

	@:isVar public var leaderboard(get, never):UILeaderboard;

	public function get_leaderboard():UILeaderboard {
		return mTownStateMachine.leaderboard;
	}

	@:isVar public var jumpToMapState(never, set):Bool;

	public function set_jumpToMapState(value:Bool):Bool {
		return mJumpToMapState = value;
	}

	function startLazyLoading() {
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"), mDBFacade);
		TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_loading_screen.swf"), mDBFacade);
	}
}
