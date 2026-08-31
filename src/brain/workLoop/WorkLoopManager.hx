package brain.workLoop;

import brain.clock.GameClock;
import brain.utils.MemoryTracker;
import flash.display.Sprite;
import org.as3commons.collections.Set;
import org.as3commons.collections.framework.ISetIterator;

class WorkLoopManager extends Sprite {
	var mTasks:Set = new Set();

	var mCurrentGameClock:GameClock;

	var doLaterQueue:SimplePriorityQueue = new SimplePriorityQueue(1024);

	public function new(gameClock:GameClock) {
		super();
		mCurrentGameClock = gameClock;
		MemoryTracker.track(mTasks, "Set - frame tasks in WorkLoopManager()", "brain");
		MemoryTracker.track(doLaterQueue, "SimplePriorityQueue - doLater queue in WorkLoopManager()", "brain");
	}

	public function update(gameClock:GameClock) {
		mCurrentGameClock = gameClock;
		advance();
	}

	@:isVar public var gameClock(get, never):GameClock;

	public function get_gameClock():GameClock {
		return mCurrentGameClock;
	}

	public function doEveryFrame(callback:ASFunction, ownerLabel:String = null):Task {
		var _loc3_ = new Task();
		_loc3_.callback = callback;
		mTasks.add(_loc3_);
		var _loc4_ = ASCompat.stringAsBool(ownerLabel) ? "Task - " + ownerLabel + " every frame" : "Task - every frame task in WorkLoopManager.doEveryFrame()";
		MemoryTracker.track(_loc3_, _loc4_, "brain");
		return _loc3_;
	}

	public function doEverySeconds(delay:Float, callback:ASFunction, repeated:Bool = true, ownerLabel:String = null):DoLater {
		return doLater(delay, callback, repeated, ownerLabel);
	}

	public function CalculateCallbackTime(delay:Float):UInt {
		return (Std.int(mCurrentGameClock.gameTime + delay * 1000) : UInt);
	}

	public function doLater(delay:Float, callback:ASFunction, repeat:Bool = true, ownerLabel:String = null):DoLater {
		var _loc6_ = new DoLater(repeat);
		_loc6_.delay = delay;
		_loc6_.dueTime = (Std.int(mCurrentGameClock.gameTime + _loc6_.delay * 1000) : UInt);
		_loc6_.callback = callback;
		doLaterQueue.enqueue(_loc6_);
		var _loc5_ = ASCompat.stringAsBool(ownerLabel) ? "DoLater - " + ownerLabel + " delay=" + delay + "s repeat=" + repeat : "DoLater - delay="
			+ delay
			+ "s repeat="
			+ repeat
			+ " in WorkLoopManager.doLater()";
		MemoryTracker.track(_loc6_, _loc5_, "brain");
		return _loc6_;
	}

	function removeDoLater(doLaterTask:DoLater):Bool {
		doLaterTask.destroy();
		return doLaterQueue.remove(doLaterTask);
	}

	function removeTask(task:Task):Bool {
		task.destroy();
		return mTasks.remove(task);
	}

	function advance() {
		processTasks();
		processDoLaters();
	}

	function processTasks() {
		var _loc2_:Task = null;
		if (mTasks.size == 0) {
			return;
		}
		var _loc1_ = ASCompat.reinterpretAs(mTasks.iterator(), ISetIterator);
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.dynamicAs(_loc1_.next(), brain.workLoop.Task);
			if (_loc2_.isDestroyed()) {
				_loc1_.remove();
				removeTask(_loc2_);
			} else if (_loc2_.callback != null) {
				_loc2_.callback(mCurrentGameClock);
			}
		}
	}

	function processDoLaters() {
		var _loc1_:DoLater = null;
		if (doLaterQueue.size == 0) {
			return;
		}
		while (doLaterQueue.front != null && doLaterQueue.front.priority >= -mCurrentGameClock.gameTime) {
			_loc1_ = ASCompat.reinterpretAs(doLaterQueue.dequeue(), DoLater);
			if (_loc1_ != null && !_loc1_.isDestroyed()) {
				if (_loc1_.callback != null) {
					_loc1_.callback(mCurrentGameClock);
				}
				if (_loc1_.repeat) {
					_loc1_.dueTime += (Std.int(_loc1_.delay * 1000) : UInt);
					doLaterQueue.enqueue(_loc1_);
				}
			}
		}
	}
}
