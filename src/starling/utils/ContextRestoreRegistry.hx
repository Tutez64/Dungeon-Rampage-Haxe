package starling.utils;

import flash.display.Stage3D;
import flash.events.Event;

class ContextRestoreRegistry {
	var _priority:Int = 0;

	var _restore:ASFunction;

	var _lists:ASDictionary<ASAny, ASAny>;

	var _numAdded:Float = Math.NaN;

	public function new(priority:Int, restore:ASFunction) {
		_priority = priority;
		_restore = restore;
		_lists = new ASDictionary<ASAny, ASAny>(true);
		_numAdded = 0;
	}

	public function add(object:ASObject, stage3D:Stage3D):ASDictionary<ASAny, ASAny> {
		var _loc3_ = (_lists[stage3D] : ASDictionary<ASAny, ASAny>);
		if (_loc3_ == null) {
			_loc3_ = new ASDictionary<ASAny, ASAny>(true);
			_lists[stage3D] = _loc3_;
			stage3D.addEventListener("context3DCreate", onContextCreated, false, _priority);
		}
		_loc3_[object] = ++_numAdded;
		return _loc3_;
	}

	function onContextCreated(event:Event) {
		var object:ASObject;
		var firstError:ASAny;
		var list = (_lists[event.currentTarget] : ASDictionary<ASAny, ASAny>);
		var objects:Array<ASAny> = [];
		var failed = false;
		if (checkNullIteratee(list))
			for (_tmp_ in list.keys()) {
				object = _tmp_;
				if (ASCompat.toBool(object)) {
					objects[objects.length] = object;
				}
			}
		ASCompat.ASArray.sort(objects, function(param1:ASObject, param2:ASObject):Float {
			return ASCompat.toNumber(list[param1]) - ASCompat.toNumber(list[param2]);
		});
		if (checkNullIteratee(objects))
			for (_tmp_ in objects) {
				object = _tmp_;
				if (list.exists(object)) {
					try {
						_restore(object, event);
					} catch (e:ASAny) {
						if (!failed) {
							failed = true;
							firstError = e;
						}
					}
				}
			}
		if (failed) {
			throw firstError;
		}
	}
}
