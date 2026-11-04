package effects;

import brain.utils.IPoolable;
import brain.utils.MemoryTracker;
import brain.utils.ObjectPool;
import facade.DBFacade;

class EffectPool extends ObjectPool {
	public function new() {
		super();
	}

	override function getPoolKey(parameters:Array<ASAny>):String {
		var _loc3_ = ASCompat.coerce(parameters[0], facade.DBFacade);
		var _loc2_:String = parameters[1];
		var _loc4_:String = parameters[2];
		return _loc2_ + ":" + _loc4_;
	}

	override function reset(poolable:IPoolable, parameters:Array<ASAny>) {
		var _loc3_ = ASCompat.reinterpretAs(poolable, EffectGameObject);
		_loc3_.setAssetLoadedCallback(ASCompat.coerceFunction(parameters[3]));
		_loc3_.setIconInsert(ASCompat.coerce(parameters[4], effects.EffectIconInsert));
		var _loc4_ = ASCompat.toNumber(parameters.length > 5 ? parameters[5] : 1);
		cast(_loc3_.view, EffectView).setPlayRate(_loc4_);
	}

	override function construct(parameters:Array<ASAny>):IPoolable {
		var _loc4_ = ASCompat.coerce(parameters[0], facade.DBFacade);
		var _loc3_:String = parameters[1];
		var _loc6_:String = parameters[2];
		var _loc7_ = ASCompat.coerceFunction(parameters[3]);
		var _loc5_ = ASCompat.coerce(parameters[4], effects.EffectIconInsert);
		var _loc8_ = ASCompat.toNumber(parameters.length > 5 ? parameters[5] : 1);
		var _loc2_ = new EffectGameObject(_loc4_, _loc3_, _loc6_, _loc8_, (0 : UInt), _loc7_, _loc5_);
		MemoryTracker.track(_loc2_, "EffectGameObject \'" + _loc3_ + ":" + _loc6_ + "\' - created in EffectPool.construct()", "pool");
		return _loc2_;
	}
}
