package collision;

import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2FixtureDef;
import distributedObjects.Floor;
import dungeon.NavCollider;
import facade.DBFacade;
import flash.geom.Vector3D;

class LocalHeroProximitySensor implements IContactResolver {
	var mDBFacade:DBFacade;

	var mFloor:Floor;

	var mBody:B2Body;

	var mCollisionCallback:ASFunction;

	var mTriggerOnce:Bool = false;

	var mHasCollidedFirstTime:Bool = false;

	public function new(dbFacade:DBFacade, distributedFloor:Floor, x:UInt, y:UInt, radius:UInt, triggerOnce:Bool, onCollisionCallback:ASFunction) {
		mFloor = distributedFloor;
		mDBFacade = dbFacade;
		mTriggerOnce = triggerOnce;
		mCollisionCallback = onCollisionCallback;
		mHasCollidedFirstTime = false;
		var _loc8_ = new B2FilterData();
		_loc8_.categoryBits = (2 : UInt);
		var _loc9_ = new B2CircleShape(radius / 50);
		var _loc11_ = new B2FixtureDef();
		_loc11_.isSensor = true;
		_loc11_.shape = _loc9_;
		_loc11_.userData = this;
		_loc11_.filter = _loc8_;
		var _loc10_ = new B2BodyDef();
		_loc10_.allowSleep = false;
		mBody = distributedFloor.box2DWorld.CreateBody(_loc10_);
		mBody.CreateFixture(_loc11_);
		mBody.SetPosition(NavCollider.convertToB2Vec2(new Vector3D(x, y)));
	}

	public function enterContact(actorId:UInt) {
		if (mTriggerOnce) {
			if (!mHasCollidedFirstTime) {
				mCollisionCallback();
			}
		} else {
			mCollisionCallback();
		}
		mHasCollidedFirstTime = true;
	}

	public function exitContact(actorId:UInt) {}

	public function destroy() {
		mFloor.box2DWorld.DestroyBody(mBody);
		mBody = null;
		mFloor = null;
		mDBFacade = null;
	}
}
