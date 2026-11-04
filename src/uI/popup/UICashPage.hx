package uI.popup;

import brain.assetRepository.AssetLoadingComponent;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.Locale;
import flash.display.MovieClip;

class UICashPage extends DBUIPopup {
	var mContentMC:MovieClip;

	public function new(dbFacade:DBFacade) {
		mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc2_ = param1.getClass("popup_coming_soon_content");
				mContentMC = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
				Locale.setText(ASCompat.coerce((mContentMC : ASAny).message_label, flash.text.TextField), "HOW_TO_GEMS_CONTENT", null, 1.55);
				TextUtil.fitToField(ASCompat.coerce((mContentMC : ASAny).message_label, flash.text.TextField));
			});
		super(dbFacade, "GEMS_HEADER_POPUP", Locale.getString("HOW_TO_GEMS_TITLE"), mContentMC, true, true, destroyPopup, true);
	}

	function destroyPopup() {
		mContentMC = null;
		super.destroy();
	}
}
