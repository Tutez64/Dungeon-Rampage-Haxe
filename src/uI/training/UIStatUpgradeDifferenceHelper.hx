package uI.training;

import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMStat;
import gameMasterDictionary.GMSuperStat;
import gameMasterDictionary.StatVector;

class UIStatUpgradeDifferenceHelper {
	static inline final FLAME_DPS = "FLAME_DPS";

	static inline final MASTER_DEFENSE = "MASTER_DEFENSE";

	static inline final BURNING_DPS_PER_POINT:Float = 3;

	static inline final MAX_TRAINING_POINTS = (75 : UInt);

	var mDBFacade:DBFacade;

	var mStatName:String;

	var mStatAmount:UInt = 0;

	var mStatUpgradeAmount:Float = Math.NaN;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
	}

	public function configure(statName:String, statUpgradeAmount:Float) {
		mStatName = statName;
		mStatUpgradeAmount = statUpgradeAmount;
	}

	@:isVar public var statAmount(never, set):UInt;

	public function set_statAmount(value:UInt):UInt {
		return mStatAmount = value;
	}

	@:isVar public var statName(get, never):String;

	public function get_statName():String {
		return mStatName;
	}

	@:isVar public var description(get, never):String;

	public function get_description():String {
		var _loc4_:String = null;
		var _loc5_ = 0;
		var _loc6_ = Math.NaN;
		var _loc3_ = mStatAmount >= 75;
		if (mStatName == "FLAME_DPS") {
			return formatSpecialUpgradeLine(Locale.getString("TRAINING_UPGRADE_BURNING_DAMAGE_PER_SECOND"), 3, false, _loc3_);
		}
		var _loc2_ = ASCompat.coerce(mDBFacade.gameMaster.superStatByConstant.itemFor(mStatName), gameMasterDictionary.GMSuperStat);
		if (_loc2_ != null) {
			if (_loc2_.CookingRarityMaxPerPoint > 0) {
				_loc4_ = Locale.getString("TRAINING_UPGRADE_COOKING_RARITY");
				if (_loc2_.CookingFoodOnHitPerPoint > 0) {
					return formatSpecialUpgradeLine(Locale.getString("TRAINING_UPGRADE_FOOD_ON_HIT_CHANCE_BONUS"), _loc2_.CookingFoodOnHitPerPoint / 100,
						true, _loc3_)
						+ "\n"
						+ _loc4_;
				}
				return _loc4_;
			}
			if (_loc2_.TrapPower > 0) {
				return formatSpecialUpgradeLine(Locale.getString("TRAINING_UPGRADE_TRAP_DAMAGE_BONUS"), _loc2_.TrapPower / 100, true, _loc3_);
			}
		}
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.statByConstant.itemFor(mStatName), gameMasterDictionary.GMStat);
		if (_loc1_ != null) {
			return formatUpgradeLine(_loc1_, mStatUpgradeAmount * _loc1_.Bonus, _loc3_);
		}
		var _loc7_:Array<ASAny> = [];
		if (_loc2_ != null) {
			_loc5_ = 0;
			while ((_loc5_ : UInt) < StatVector.slotCount) {
				if (_loc2_.BaseValues.values[_loc5_] != 0) {
					_loc1_ = ASCompat.coerce(mDBFacade.gameMaster.statByConstant.itemFor(DBGlobal.StatNames[_loc5_]), gameMasterDictionary.GMStat);
					if (_loc1_ != null) {
						_loc7_.push(formatUpgradeLine(_loc1_, _loc2_.BaseValues.values[_loc5_] * _loc1_.Bonus, _loc3_));
					}
				}
				_loc5_++;
			}
			if (!Math.isNaN(_loc2_.CooldownReduction) && _loc2_.CooldownReduction != 0) {
				_loc6_ = mStatUpgradeAmount * _loc2_.CooldownReduction * 0.01;
				_loc7_.push(formatSpecialUpgradeLine(Locale.getString("TRAINING_UPGRADE_COOLDOWN_BONUS"), _loc6_, true, _loc3_));
			}
		}
		if (_loc7_.length > 0) {
			return _loc7_.join("\n");
		}
		return _loc3_ ? Locale.getString("TRAINING_UPGRADE_MAXIMUM_LEVEL_REACHED") : "";
	}

	public function destroy() {
		mDBFacade = null;
	}

	function formatUpgradeLine(stat:GMStat, difference:Float, maximum:Bool):String {
		var _loc6_ = GameMasterLocale.getGameMasterSubString("STATS_NAME", stat.Constant);
		var _loc4_ = stat.Constant == "MELEE_SPD" || stat.Constant == "SHOOT_SPD" || stat.Constant == "MAGIC_SPD" || stat.Constant == "MOVEMENT"
			|| mStatName == "MASTER_DEFENSE";
		var _loc5_ = Locale.format("TRAINING_UPGRADE_STAT_BONUS", {"STAT": _loc6_});
		return formatSpecialUpgradeLine(_loc5_, difference, _loc4_, maximum);
	}

	function formatSpecialUpgradeLine(label:String, difference:Float, percentage:Bool, maximum:Bool):String {
		var _loc5_ = formatValue(mStatAmount * difference, percentage);
		if (maximum) {
			return Locale.format("TRAINING_UPGRADE_MAXIMUM_VALUE", {
				"LABEL": label,
				"CURRENT": _loc5_
			});
		}
		return Locale.format("TRAINING_UPGRADE_CURRENT_TO_NEXT", {
			"LABEL": label,
			"CURRENT": _loc5_,
			"NEXT": formatValue((mStatAmount + 1) * difference, percentage),
			"DIFFERENCE": formatDifference(difference, percentage)
		});
	}

	function formatDifference(value:Float, percentage:Bool):String {
		return "(" + formatValue(value, percentage, true) + ")";
	}

	function formatValue(value:Float, percentage:Bool, includePlus:Bool = false):String {
		if (percentage) {
			value *= 100;
		}
		var _loc5_ = Math.fround(value * 100) / 100;
		var _loc4_ = Std.string(_loc5_);
		if (includePlus && _loc5_ > 0) {
			_loc4_ = "+" + _loc4_;
		}
		if (percentage) {
			_loc4_ += "%";
		}
		return _loc4_;
	}
}
