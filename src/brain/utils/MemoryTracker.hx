package brain.utils;

import flash.display.Stage;
import flash.events.Event;
import flash.sampler.*;

class MemoryTracker {
	public static inline final CATEGORY_POOL = "pool";

	static var m_count:Int = 0;

	static var m_stage:Stage = null;

	static var m_generation:Int = 0;

	static var m_checkpointGeneration:Int = 0;

	static var m_currentFilter:ASObject = null;

	static var m_gcInFlight:Bool = false;

	static var m_gcReport:Bool = false;

	public static var captureCreationStacks:Bool = false;

	static var m_tracking:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	static var m_gcCallbacks:Array<ASAny>;

	public function new() {}

	public static function registerWorkManagerForHuskCheck(mgr:ASAny) {}

	public static function clearWorkManagersForHuskCheck() {}

	@:isVar public static var gcInFlight(get, never):Bool;

	static public function get_gcInFlight():Bool {
		return m_gcInFlight;
	}

	@:isVar public static var stage(never, set):Stage;

	static public function set_stage(s:Stage):Stage {
		return m_stage = s;
	}

	public static function track(obj:ASAny, label:String, category:String = "default") {}

	public static function isTracked(obj:ASAny):Bool {
		return ASCompat.dictionaryLookupNeNull(m_tracking, obj);
	}

	static function captureCreationStack():String {
		return null;
	}

	public static function nextGeneration() {}

	static function parseFilter(filterString:String):ASObject {
		var _loc2_:String = null;
		if (!ASCompat.stringAsBool(filterString) || filterString.length == 0) {
			return null;
		}
		var _loc6_:Array<ASAny> = [];
		var _loc3_:Array<ASAny> = [];
		var _loc5_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(filterString));
		var _loc4_:String;
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_) {
				_loc4_ = _tmp_;
				if (_loc4_.length != 0) {
					if (_loc4_.charAt(0) == "!") {
						_loc2_ = _loc4_.substring(1);
						if (_loc2_.length > 0) {
							_loc3_.push(_loc2_);
						}
					} else {
						_loc6_.push(_loc4_);
					}
				}
			}
		if (_loc6_.length == 0 && _loc3_.length == 0) {
			return null;
		}
		return {
			"incl": _loc6_,
			"excl": _loc3_
		};
	}

	static function passesCategoryFilter(category:String, filter:ASObject):Bool {
		if (!ASCompat.toBool(filter)) {
			return true;
		}
		if (ASCompat.toNumberField(filter.excl, "length") > 0) {
			if (ASCompat.toNumber(filter.excl.indexOf(category)) >= 0) {
				return false;
			}
		}
		if (ASCompat.toNumberField(filter.incl, "length") > 0) {
			if (ASCompat.toNumber(filter.incl.indexOf(category)) < 0) {
				return false;
			}
		}
		return true;
	}

	static function getFilterDescription(filter:ASObject):String {
		if (!ASCompat.toBool(filter)) {
			return "";
		}
		var _loc2_:Array<ASAny> = [];
		if (ASCompat.toNumberField(filter.incl, "length") > 0) {
			_loc2_.push("include: " + Std.string(ASCompat.dynJoin(filter.incl, ", ")));
		}
		if (ASCompat.toNumberField(filter.excl, "length") > 0) {
			_loc2_.push("exclude: " + Std.string(ASCompat.dynJoin(filter.excl, ", ")));
		}
		return " (" + _loc2_.join("; ") + ")";
	}

	@:isVar public static var generation(get, never):Int;

	static public function get_generation():Int {
		return m_generation;
	}

	public static function memoryReport(filterString:String = null, onComplete:ASFunction = null) {}

	static function _startGC() {}

	static function _finishGC() {}

	public static function forceGC(onComplete:ASFunction = null) {}

	@:isVar public static var trackedCount(get, never):Int;

	static public function get_trackedCount():Int {
		var _loc1_ = 0;
		var _loc2_:ASObject;
		final __ax4_iter_37 = m_tracking;
		if (checkNullIteratee(__ax4_iter_37))
			for (_tmp_ in __ax4_iter_37.keys()) {
				_loc2_ = _tmp_;
				_loc1_++;
			}
		return _loc1_;
	}

	@:isVar public static var trackedCountSinceCheckpoint(get, never):Int;

	static public function get_trackedCountSinceCheckpoint():Int {
		var _loc3_:ASObject = null;
		var _loc1_ = 0;
		var _loc2_:ASObject;
		final __ax4_iter_38 = m_tracking;
		if (checkNullIteratee(__ax4_iter_38))
			for (_tmp_ in __ax4_iter_38.keys()) {
				_loc2_ = _tmp_;
				_loc3_ = m_tracking[_loc2_];
				if (ASCompat.toNumberField(_loc3_, "generation") >= m_checkpointGeneration) {
					_loc1_++;
				}
			}
		return _loc1_;
	}

	static function _forEachTracked(fn:ASFunction) {
		var _loc2_:ASObject;
		final __ax4_iter_39 = m_tracking;
		if (checkNullIteratee(__ax4_iter_39))
			for (_tmp_ in __ax4_iter_39.keys()) {
				_loc2_ = _tmp_;
				fn(_loc2_, m_tracking[_loc2_]);
			}
	}

	public static function getAllTracked():Array<ASAny> {
		return [];
	}

	public static function getGrowingLeaks():Array<ASAny> {
		return [];
	}

	public static function getPoolLeakCandidates():Array<ASAny> {
		return [];
	}

	public static function findTrackedByLabel(labelSubstring:String):Array<ASAny> {
		return [];
	}

	static function _gc(e:Event) {}

	static function _gcTail() {}

	static function _doLastGC() {}

	static function __init__() {
		m_gcCallbacks = [];
	}
}
