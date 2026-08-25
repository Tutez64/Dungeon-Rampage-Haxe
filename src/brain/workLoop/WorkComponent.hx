package brain.workLoop;

import brain.clock.GameClock;
import brain.component.Component;
import brain.facade.Facade;
import brain.utils.MemoryTracker;

class WorkComponent extends Component {
	var mWorkLoopManager:WorkLoopManager;

	var mTasks:ASDictionary<ASAny, ASAny>;

	var mOwnerName:String;

	var mTasksLabel:String;

	public function new(dbFacade:Facade, workLoopManager:WorkLoopManager, ownerName:String = null) {
		super(dbFacade);
		mOwnerName = ownerName;
		mTasksLabel = "Dictionary - tasks in " + (if (ASCompat.stringAsBool(ownerName)) ownerName else "WorkComponent") + "()";
		mTasks = new ASDictionary<ASAny, ASAny>(true);
		MemoryTracker.track(mTasks, mTasksLabel, "brain");
		mWorkLoopManager = workLoopManager;
	}

	@:isVar public var gameClock(get, never):GameClock;

	public function get_gameClock():GameClock {
		return mWorkLoopManager.gameClock;
	}

	public function doEveryFrame(callback:ASFunction):Task {
		var _loc2_ = mWorkLoopManager.doEveryFrame(callback, mOwnerName);
		mTasks[_loc2_] = 1;
		return _loc2_;
	}

	public function doLater(delay:Float, callback:ASFunction):Task {
		var _loc3_:Task = mWorkLoopManager.doLater(delay, callback, false, mOwnerName);
		mTasks[_loc3_] = 1;
		return _loc3_;
	}

	public function doEverySeconds(interval:Float, callback:ASFunction):Task {
		var _loc3_:Task = mWorkLoopManager.doEverySeconds(interval, callback, true, mOwnerName);
		mTasks[_loc3_] = 1;
		return _loc3_;
	}

	public function clear() {
		var _loc1_:ASObject;
		final __ax4_iter_228 = mTasks;
		if (checkNullIteratee(__ax4_iter_228))
			for (_tmp_ in __ax4_iter_228.keys()) {
				_loc1_ = _tmp_;
				cast(_loc1_, Task).destroy();
			}
		mTasks = new ASDictionary<ASAny, ASAny>(true);
		MemoryTracker.track(mTasks, mTasksLabel, "brain");
	}

	override public function destroy() {
		var _loc1_:ASObject;
		final __ax4_iter_229 = mTasks;
		if (checkNullIteratee(__ax4_iter_229))
			for (_tmp_ in __ax4_iter_229.keys()) {
				_loc1_ = _tmp_;
				cast(_loc1_, Task).destroy();
			}
		mTasks = null;
		mWorkLoopManager = null;
		super.destroy();
	}
}
