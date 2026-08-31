package dungeon;

import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2World;
import brain.logger.Logger;
import facade.DBFacade;
import dr_floor.FloorObject;
import flash.geom.Vector3D;

class NavCollider {
	var mDBFacade:DBFacade;

	var mParentObject:FloorObject;

	var mWorldSpaceOffset:Vector3D;

	var mB2Body:B2Body;

	var mB2World:B2World;

	public function new(dbFacade:DBFacade, parentObject:FloorObject, offset:Vector3D, box2DWorld:B2World) {
		mDBFacade = dbFacade;
		mParentObject = parentObject;
		mWorldSpaceOffset = offset;
		mB2World = box2DWorld;
		mB2Body = buildBody();
		if (parentObject == null) {
			mB2Body.SetUserData(null);
		} else {
			mB2Body.SetUserData(parentObject.id);
		}
	}

	public static function buildNavColliderFromJson(dbFacade:DBFacade, collisionJson:ASObject, parentObject:FloorObject, offset:Vector3D, angle:Float,
			scale:Vector3D, box2DWorld:B2World, filter:B2FilterData = null):NavCollider {
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_:String = collisionJson.type;
		if (_loc11_ == "circle") {
			return new CircleNavCollider(dbFacade, parentObject, offset, ASCompat.toNumber(ASCompat.toNumberField(collisionJson, "radius") * scale.x),
				box2DWorld, filter);
		}
		if (_loc11_ == "rectangle") {
			_loc9_ = ASCompat.toNumber(ASCompat.toNumberField(collisionJson, "halfWidth") * scale.x);
			_loc10_ = ASCompat.toNumber(ASCompat.toNumberField(collisionJson, "halfHeight") * scale.y);
			return new RectangleNavCollider(dbFacade, parentObject, offset, angle, box2DWorld, _loc9_, _loc10_, filter);
		}
		Logger.error("Could not figure out collision type of json to build a b2Shape:" + Std.string(collisionJson));
		return null;
	}

	public static function convertToB2Vec2(vector3d:Vector3D):B2Vec2 {
		return new B2Vec2(vector3d.x / 50, vector3d.y / 50);
	}

	public static function convertToVector3D(b2dVec2:B2Vec2):Vector3D {
		return new Vector3D(b2dVec2.x * 50, b2dVec2.y * 50);
	}

	public function destroy() {
		mB2World.DestroyBody(mB2Body);
		mB2Body = null;
		mB2World = null;
		mParentObject = null;
		mDBFacade = null;
	}

	@:isVar public var active(get, set):Bool;

	public function set_active(value:Bool):Bool {
		mB2Body.SetActive(value);
		return value;
	}

	function get_active():Bool {
		return mB2Body.IsActive();
	}

	function buildBody():B2Body {
		Logger.error("Override build definition in sub classes.");
		return null;
	}

	@:isVar public var worldCenter(get, never):Vector3D;

	public function get_worldCenter():Vector3D {
		return convertToVector3D(mB2Body.GetWorldCenter());
	}

	@:isVar public var position(get, set):Vector3D;

	public function set_position(val:Vector3D):Vector3D {
		var _loc2_ = new Vector3D(val.x + mWorldSpaceOffset.x, val.y + mWorldSpaceOffset.y);
		mB2Body.SetPosition(convertToB2Vec2(_loc2_));
		return val;
	}

	function get_position():Vector3D {
		var _loc1_ = convertToVector3D(mB2Body.GetPosition());
		return _loc1_.subtract(mWorldSpaceOffset);
	}

	@:isVar public var velocity(never, set):Vector3D;

	public function set_velocity(vel:Vector3D):Vector3D {
		mB2Body.SetAwake(true);
		mB2Body.SetLinearVelocity(convertToB2Vec2(vel));
		return vel;
	}

	@:isVar public var offset(get, never):Vector3D;

	public function get_offset():Vector3D {
		return mWorldSpaceOffset;
	}

	@:isVar public var type(never, set):UInt;

	public function set_type(colliderType:UInt):UInt {
		mB2Body.SetType(B2Body.b2_dynamicBody);
		return colliderType;
	}

	@:isVar public var collisionRadius(get, never):Float;

	public function get_collisionRadius():Float {
		if (ASCompat.reinterpretAs(this, CircleNavCollider) != null) {
			return ASCompat.reinterpretAs(this, CircleNavCollider).radius;
		}
		return -1;
	}

	public function getBody():B2Body {
		return mB2Body;
	}

	public function getShape():B2Shape {
		var _loc1_ = mB2Body.GetFixtureList();
		return _loc1_.GetShape();
	}
}
