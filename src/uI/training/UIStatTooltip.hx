package uI.training;

import facade.DBFacade;
import facade.GameMasterLocale;
import gameMasterDictionary.GMStat;
import gameMasterDictionary.GMSuperStat;

class UIStatTooltip extends UIStatTooltipBox {
	var mDBFacade:DBFacade;

	var mGMStatItem:GMStat;

	var mGMSuperStatItem:GMSuperStat;

	public function new(dbFacade:DBFacade, templateClass:Dynamic) {
		super(templateClass);
		mDBFacade = dbFacade;
	}

	override public function destroy() {
		mDBFacade = null;
		super.destroy();
	}

	@:isVar public var statItem(never, set):GMStat;

	public function set_statItem(value:GMStat):GMStat {
		mGMStatItem = value;
		setTexts(GameMasterLocale.getGameMasterSubString("STATS_NAME", mGMStatItem.Constant).toUpperCase(),
			GameMasterLocale.getGameMasterSubString("STATS_DESCRIPTION", mGMStatItem.Constant), 1.55);
		return value;
	}

	@:isVar public var superStatItem(never, set):GMSuperStat;

	public function set_superStatItem(value:GMSuperStat):GMSuperStat {
		mGMSuperStatItem = value;
		setTexts(GameMasterLocale.getGameMasterSubString("STATS_NAME", mGMSuperStatItem.Constant).toUpperCase(),
			GameMasterLocale.getGameMasterSubString("STATS_DESCRIPTION", mGMSuperStatItem.Constant), 1.55);
		return value;
	}
}
