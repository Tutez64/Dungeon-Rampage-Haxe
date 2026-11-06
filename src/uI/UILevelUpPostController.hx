package uI;

import brain.assetRepository.AssetLoadingComponent;
import brain.event.EventComponent;
import brain.sceneGraph.SceneGraphComponent;
import events.LevelUpPostEvent;
import facade.DBFacade;
import uI.popup.UIDungeonSummaryLevelUpPopup;
import flash.display.Sprite;
import flash.events.Event;

class UILevelUpPostController {
	public static inline final TIME_TO_SHARE_LEVEL_UP_EVENT = "TIME_TO_SHARE_LEVEL_UP_EVENT";

	var mDBFacade:DBFacade;

	var mSceneGraphComponent:SceneGraphComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mEventComponent:EventComponent;

	var mCurtain:Sprite;

	var mSelectedLevel:UInt = 0;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mEventComponent = new EventComponent(mDBFacade);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "UILevelUpPostController");
		mEventComponent.addListener("LevelUpPostEvent", setlevelUpPost);
		mEventComponent.addListener("TIME_TO_SHARE_LEVEL_UP_EVENT", checkToSharePopup);
	}

	public static function makeCurtain(dbFacade:DBFacade, sceneGraphComponent:SceneGraphComponent):Sprite {
		if (dbFacade == null || sceneGraphComponent == null) {
			return null;
		}
		var _loc3_ = new Sprite();
		_loc3_.alpha = 0.75;
		_loc3_.x = 0;
		_loc3_.y = 0;
		_loc3_.graphics.clear();
		_loc3_.graphics.beginFill((0 : UInt));
		_loc3_.graphics.drawRect(0, 0, dbFacade.viewWidth, dbFacade.viewHeight);
		_loc3_.graphics.endFill();
		sceneGraphComponent.addChild(_loc3_, (105 : UInt));
		return _loc3_;
	}

	public static function removeCurtain(curtain:Sprite, sceneGraphComponent:SceneGraphComponent) {
		if (curtain == null || sceneGraphComponent == null) {
			return;
		}
		if (sceneGraphComponent.contains(curtain, (105 : UInt))) {
			sceneGraphComponent.removeChild(curtain);
		}
		curtain = null;
	}

	function showPopup(level:UInt) {
		var gmSkin = mDBFacade.gameMaster.getSkinByType(mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName), function(param1:brain.assetRepository.SwfAsset) {
			var _loc3_ = param1.getClass(gmSkin.PortraitClassName);
			var _loc2_ = new UIDungeonSummaryLevelUpPopup(mDBFacade, null, gmSkin, level, _loc3_);
		});
	}

	function checkToSharePopup(event:Event) {
		if (mSelectedLevel > 0) {
			showPopup(mSelectedLevel);
			mSelectedLevel = (0 : UInt);
		}
	}

	function setlevelUpPost(event:LevelUpPostEvent) {
		if (UIDungeonSummaryLevelUpPopup.LEVELS.indexOf(event.level) >= 0) {
			mSelectedLevel = event.level;
		}
	}

	public function destroy() {
		if (mEventComponent != null) {
			mEventComponent.destroy();
			mEventComponent = null;
		}
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		if (mSceneGraphComponent != null) {
			mSceneGraphComponent.destroy();
			mSceneGraphComponent = null;
		}
		mDBFacade = null;
		mSelectedLevel = (0 : UInt);
	}
}
