package combat.attack;

import actor.ActorGameObject;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import facade.DBFacade;

class RectangleCombatCollider extends CombatCollider {
	var mHalfWidth:Float = Math.NaN;

	var mHalfHeight:Float = Math.NaN;

	var mRotationOffset:Float = Math.NaN;

	var mHeadingAngle:Float = Math.NaN;

	public function new(dbFacade:DBFacade, parentObject:ActorGameObject, box2DWorld:B2World, halfWidth:Float, halfHeight:Float, heading:Float,
			rotationOffset:Float) {
		mHalfWidth = halfWidth / 50;
		mHalfHeight = halfHeight / 50;
		mRotationOffset = rotationOffset;
		mHeadingAngle = heading % 360;
		super(dbFacade, parentObject, box2DWorld);
	}

	override function buildShape() {
		var _loc2_ = new B2PolygonShape();
		var _loc1_ = mHeadingAngle;
		if (_loc1_ < 0) {
			_loc1_ += 360;
		}
		if (_loc1_ > 90 && _loc1_ < 270) {
			_loc1_ -= mRotationOffset;
		} else {
			_loc1_ += mRotationOffset;
		}
		var _loc3_ = _loc1_ / 180 * 3.141592653589793;
		mB2Shape = _loc2_;
		_loc2_.SetAsOrientedBox(mHalfWidth, mHalfHeight, new B2Vec2(0, 0), _loc3_);
		mB2Transform = new B2Transform();
		if (mParentGameObject.distributedDungeonFloor.debugVisualizer != null) {
			mParentGameObject.distributedDungeonFloor.debugVisualizer.reportPolyAttack(mB2Transform, _loc2_);
		}
	}
}
