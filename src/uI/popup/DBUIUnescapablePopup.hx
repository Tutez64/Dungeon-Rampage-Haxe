package uI.popup;

import facade.DBFacade;

class DBUIUnescapablePopup extends DBUIOneButtonPopup {
	public function new(dbFacade:DBFacade, uiLayerName:String, titleText:String, content:ASAny, centerText:String, centerCallback:ASFunction) {
		super(dbFacade, uiLayerName, titleText, content, centerText, centerCallback, false);
	}

	override function getNavigationExitCallback():ASFunction {
		return null;
	}
}
