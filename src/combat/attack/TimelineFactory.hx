package combat.attack;

import actor.ActorGameObject;
import brain.assetRepository.JsonAsset;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import org.as3commons.collections.Map;

class TimelineFactory {
	static inline final TIMELINE_FILE_PATH = "Resources/Combat/AttackTimeline.json";

	var mDBFacade:DBFacade;

	var mJsonAsset:JsonAsset;

	var mTimelines:Map;

	var mSecurityValue:Int = 0;

	public function new(dbFacade:DBFacade, jsonAsset:JsonAsset) {
		var _loc3_:String = null;

		mDBFacade = dbFacade;
		mJsonAsset = jsonAsset;
		mTimelines = new Map();
		var _loc5_ = 0;
		mSecurityValue = 0;
		var _loc4_:ASObject;
		final __ax4_iter_45:Array<ASAny> = jsonAsset.json.attacks;
		if (checkNullIteratee(__ax4_iter_45))
			for (_tmp_ in __ax4_iter_45) {
				_loc4_ = _tmp_;
				_loc3_ = _loc4_.attackName;
				mTimelines.add(_loc3_, _loc4_);
				_loc5_ += GetSecurityValue(_loc4_);
			}
		_loc5_ %= 1097;
		mSecurityValue += _loc5_;
		_loc5_ = 0;
	}

	public function GetSecurityValue(jsonAsset:ASObject):Int {
		var _loc2_ = 0;
		var _loc3_:ASObject;
		if (checkNullIteratee(jsonAsset))
			for (_tmp_ in iterateDynamicValues(jsonAsset)) {
				_loc3_ = _tmp_;
				if (ASCompat.getQualifiedClassName(_loc3_) == "int") {
					_loc2_ += Std.int(Math.abs(ASCompat.toInt(_loc3_)) % 17 + Math.abs(ASCompat.toInt(_loc3_)) / 19);
				}
			}
		return _loc2_ % 541;
	}

	public function destroy() {
		mDBFacade = null;
		mTimelines.clear();
		mTimelines = null;
		mJsonAsset = null;
	}

	@:isVar public var securityChecksum(get, never):Int;

	public function get_securityChecksum():Int {
		return mSecurityValue;
	}

	public function createAttackTimeline(timelineName:String, weapon:WeaponGameObject, actor:ActorGameObject, floor:DistributedDungeonFloor):AttackTimeline {
		var _loc6_:AttackTimeline = null;
		var _loc5_:ASObject = mTimelines.itemFor(timelineName);
		if (actor.isOwner) {
			_loc6_ = new OwnerAttackTimeline(weapon, ASCompat.reinterpretAs(actor, HeroGameObjectOwner), actor.actorView, _loc5_, mDBFacade, floor);
		} else {
			_loc6_ = new AttackTimeline(weapon, actor, actor.actorView, _loc5_, mDBFacade, floor);
		}
		return _loc6_;
	}

	public function createScriptTimeline(timelineName:String, actor:ActorGameObject, floor:DistributedDungeonFloor):ScriptTimeline {
		var _loc5_:ASAny = null;
		var _loc4_:ASObject = mTimelines.itemFor(timelineName);
		return new ScriptTimeline(actor, actor.actorView, _loc4_, mDBFacade, floor);
	}
}
