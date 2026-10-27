package dungeon;

import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import facade.DBFacade;
import dr_floor.FloorObject;
import flash.geom.Vector3D;

class CircleNavCollider extends NavCollider {
	var mRadius:Float = Math.NaN;

	var mFilter:B2FilterData;

	public function new(dbFacade:DBFacade, parentObject:FloorObject, offset:Vector3D, radius:Float, box2DWorld:B2World, filter:B2FilterData = null) {
		mRadius = radius / 50;
		mFilter = filter;
		super(dbFacade, parentObject, offset, box2DWorld);
	}

	override function buildBody():B2Body {
		var _loc1_ = new B2BodyDef();
		var _loc3_ = new B2FixtureDef();
		var _loc2_ = new B2CircleShape(mRadius);
		_loc3_.shape = _loc2_;
		if (mFilter != null) {
			_loc3_.filter = mFilter;
		}
		var _loc4_ = mB2World.CreateBody(_loc1_);
		_loc4_.CreateFixture(_loc3_);
		return _loc4_;
	}

	@:isVar public var radius(get, never):Float;

	public function get_radius():Float {
		return mRadius;
	}
}
