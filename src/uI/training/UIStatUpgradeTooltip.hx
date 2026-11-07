package uI.training;

import facade.GameMasterLocale;
import flash.text.TextFormat;

class UIStatUpgradeTooltip extends UIStatTooltipBox {
	static inline final DIFFERENCE_COLOR = (65280 : UInt);

	public function new(templateClass:Dynamic) {
		super(templateClass);
	}

	public function update(statName:String, description:String) {
		var _loc3_ = 0;
		setTexts(GameMasterLocale.getGameMasterSubString("STATS_NAME", statName).toUpperCase(), description, 1.55);
		var _loc5_ = new TextFormat();
		_loc5_.color = 65280;
		var _loc4_ = description.indexOf("(+");
		while (_loc4_ >= 0) {
			_loc3_ = description.indexOf(")", _loc4_);
			if (_loc3_ < 0) {
				break;
			}
			mDescription.setTextFormat(_loc5_, _loc4_, _loc3_ + 1);
			_loc4_ = description.indexOf("(+", _loc3_ + 1);
		}
	}
}
