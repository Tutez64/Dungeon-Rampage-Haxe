package dungeon;

import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import facade.DBFacade;
import dr_floor.FloorObject;
import flash.geom.Vector3D;

class RectangleNavCollider extends NavCollider {
	var mHalfWidth:Float = Math.NaN;

	var mHalfHeight:Float = Math.NaN;

	var mFilter:B2FilterData;

	public function new(dbFacade:DBFacade, parentObject:FloorObject, offset:Vector3D, angle:Float, box2DWorld:B2World, halfWidth:Float, halfHeight:Float,
			filter:B2FilterData = null) {
		mHalfWidth = halfWidth / 50;
		mHalfHeight = halfHeight / 50;
		mFilter = filter;
		super(dbFacade, parentObject, offset, box2DWorld);
		this.angle = angle;
	}

	@:isVar public var angle(get, set):Float;

	public function set_angle(value:Float):Float {
		mB2Body.SetAngle(value);
		return value;
	}

	function get_angle():Float {
		return mB2Body.GetAngle();
	}

	override function buildBody():B2Body {
		var _loc1_ = new B2BodyDef();
		var _loc3_ = new B2FixtureDef();
		var _loc2_ = new B2PolygonShape();
		_loc2_.SetAsBox(mHalfWidth, mHalfHeight);
		_loc3_.shape = _loc2_;
		if (mFilter != null) {
			_loc3_.filter = mFilter;
		}
		var _loc4_ = mB2World.CreateBody(_loc1_);
		_loc4_.CreateFixture(_loc3_);
		return _loc4_;
	}
}
