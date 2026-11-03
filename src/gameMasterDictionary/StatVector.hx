package gameMasterDictionary;

import brain.logger.Logger;
import dBGlobals.DBGlobal;
import flash.Boot;
import haxe.Log;

class StatVector {
	public static var slotCount:UInt = (14 : UInt);

	public var values:Vector<Float>;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		values = new Vector<Float>((14 : UInt), true);
	}

	public static function clone(s1:StatVector):StatVector {
		var _loc5_ = 0;
		var _loc2_ = new StatVector();
		var _loc3_ = 0;
		var _loc4_:Int = StatVector.slotCount;
		while (_loc3_ < _loc4_) {
			_loc5_ = _loc3_++;
			_loc2_.values[_loc5_] = s1.values[_loc5_];
		}
		return _loc2_;
	}

	public static function multiply(s1:StatVector, s2:StatVector):StatVector {
		var _loc6_ = 0;
		var _loc7_ = ASCompat.asVector(null, (_ : Float));
		var _loc3_ = StatVector.clone(s1);
		var _loc4_ = 0;
		var _loc5_:Int = StatVector.slotCount;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			_loc7_ = _loc3_.values;
			_loc7_[_loc6_] = ASCompat.toNumber(_loc7_[_loc6_]) * s2.values[_loc6_];
		}
		return _loc3_;
	}

	public static function multiplyScalar(s1:StatVector, s2:Float):StatVector {
		var _loc6_ = 0;
		var _loc7_ = ASCompat.asVector(null, (_ : Float));
		var _loc3_ = StatVector.clone(s1);
		var _loc4_ = 0;
		var _loc5_:Int = StatVector.slotCount;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			_loc7_ = _loc3_.values;
			_loc7_[_loc6_] = ASCompat.toNumber(_loc7_[_loc6_]) * s2;
		}
		return _loc3_;
	}

	public static function add(s1:StatVector, s2:StatVector):StatVector {
		var _loc6_ = 0;
		var _loc7_ = ASCompat.asVector(null, (_ : Float));
		var _loc3_ = StatVector.clone(s1);
		var _loc4_ = 0;
		var _loc5_:Int = StatVector.slotCount;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			_loc7_ = _loc3_.values;
			_loc7_[_loc6_] = _loc7_[_loc6_] + s2.values[_loc6_];
		}
		return _loc3_;
	}

	public function set_data(val:Vector<Float>):Vector<Float> {
		values = val;
		return val;
	}

	@:isVar public var data(never, set):Vector<Float>;

	public function set_data(value:Vector<Float>):Vector<Float> {
		set_data(value);
		return value;
	}

	public function setConstant(val:Int) {
		var _loc4_ = 0;
		var _loc2_ = 0;
		var _loc3_:Int = StatVector.slotCount;
		while (_loc2_ < _loc3_) {
			_loc4_ = _loc2_++;
			values[_loc4_] = val;
		}
	}

	public function get_movementSpeed():Float {
		return values[DBGlobal.MOVEMENT];
	}

	@:isVar public var movementSpeed(get, never):Float;

	public function get_movementSpeed():Float {
		return get_movementSpeed();
	}

	public function get_maxManaPoints():Float {
		return values[DBGlobal.MP_BOOST];
	}

	@:isVar public var maxManaPoints(get, never):Float;

	public function get_maxManaPoints():Float {
		return get_maxManaPoints();
	}

	public function get_maxHitPoints():Float {
		return values[DBGlobal.HP_BOOST];
	}

	@:isVar public var maxHitPoints(get, never):Float;

	public function get_maxHitPoints():Float {
		return get_maxHitPoints();
	}

	public function getSpeed(type:String):Float {
		if (type == "MELEE") {
			return values[DBGlobal.MELEE_SPD];
		}
		if (type == "SHOOT" || type == "SHOOTING") {
			return values[DBGlobal.SHOOT_SPD];
		}
		if (type == "MAGIC") {
			return values[DBGlobal.MAGIC_SPD];
		}
		return 1;
	}

	public function destroy() {
		values = null;
	}

	public function SetFromJSON(jsonAsset:ASAny, prefix:String = /*undefined*/ null) {
		var _loc5_ = 0;
		var _loc6_:ASAny = null;
		var _loc7_ = Math.NaN;
		if (prefix == null) {
			prefix = "";
		}
		var _loc3_ = 0;
		var _loc4_ = DBGlobal.StatNames.length;
		while (_loc3_ < _loc4_) {
			_loc5_ = _loc3_++;
			_loc6_ = Reflect.field(jsonAsset, prefix + DBGlobal.StatNames[_loc5_]);
			if (_loc6_ == null) {
				Logger.error("StatVector Reading JSON Value " + prefix + DBGlobal.StatNames[_loc5_] + "Not Found Continuing ?");
			}
			_loc7_ = ASCompat.toNumber(_loc6_);
			values[_loc5_] = _loc7_;
		}
	}

	public function DebugPrint() {
		var _loc3_ = 0;
		var _loc1_ = 0;
		var _loc2_:Int = StatVector.slotCount;
		while (_loc1_ < _loc2_) {
			_loc3_ = _loc1_++;
			Log.trace(DBGlobal.StatNames[_loc3_] + " " + values[_loc3_], {
				"fileName": "../DungeonBusters/Client/GameMasterProjectHaxe/src/gamemasterdictionary/StatVector.hx",
				"lineNumber": 107,
				"className": "gamemasterdictionary.StatVector",
				"methodName": "DebugPrint"
			});
		}
	}
}
