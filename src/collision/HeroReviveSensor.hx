package collision;

import box2D.collision.shapes.B2Shape;
import distributedObjects.Floor;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class HeroReviveSensor extends HeroOwnerSensor {
	var mCallback:ASFunction;

	var mFinishedCallback:ASFunction;

	public function new(dbFacade:DBFacade, distributedFloor:Floor, shape:B2Shape, team:UInt) {
		super(dbFacade, distributedFloor, shape, team);
	}

	override public function destroy() {
		mCallback = null;
		mFinishedCallback = null;
		super.destroy();
	}

	override public function enterContact(actorId:UInt) {
		var _loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(actorId), HeroGameObjectOwner);
		if (_loc2_ != null && _loc2_.heroStateMachine != null && _loc2_.heroStateMachine.currentStateName != "ActorReviveState") {
			mCallback(_loc2_);
		}
	}

	override public function exitContact(actorId:UInt) {
		var _loc2_:HeroGameObjectOwner = null;
		if (mDBFacade != null) {
			_loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(actorId), HeroGameObjectOwner);
			if (_loc2_ != null) {
				if (mFinishedCallback != null) {
					mFinishedCallback();
				}
			}
		}
	}

	@:isVar public var callback(never, set):ASFunction;

	public function set_callback(value:ASFunction):ASFunction {
		return mCallback = value;
	}

	@:isVar public var finishedCallback(never, set):ASFunction;

	public function set_finishedCallback(value:ASFunction):ASFunction {
		return mFinishedCallback = value;
	}
}
