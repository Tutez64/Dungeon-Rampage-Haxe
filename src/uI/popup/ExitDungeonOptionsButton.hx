package uI.popup;

import brain.assetRepository.AssetLoadingComponent;
import brain.uI.UIButton;
import brain.uI.UIObject;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import flash.display.MovieClip;
import flash.geom.Point;

class ExitDungeonOptionsButton {
	static inline final OPTIONS_BUTTON_CLASS_NAME = "options_panel_button";

	static inline final BUTTON_SCALE:Float = 0.45;

	var mButton:UIButton;

	public function new(dbFacade:DBFacade, assetLoadingComponent:AssetLoadingComponent, popup:MovieClip, position:Point, closeButton:UIButton,
			downTarget:UIObject, releaseCallback:ASFunction) {
		assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc2_ = param1.getClass("options_panel_button");
				var _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
				_loc3_.name = "options_panel_button";
				_loc3_.x = position.x;
				_loc3_.y = position.y;
				_loc3_.scaleX = _loc3_.scaleY = 0.45;
				popup.addChild(_loc3_);
				mButton = new UIButton(dbFacade, _loc3_);
				mButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
				mButton.releaseCallback = releaseCallback;
				if (closeButton != null) {
					mButton.isToTheLeftOf(closeButton);
				}
				if (downTarget != null) {
					mButton.downNavigation = downTarget;
				}
			});
	}

	public function destroy() {
		if (mButton != null) {
			mButton.destroy();
			mButton = null;
		}
	}
}
