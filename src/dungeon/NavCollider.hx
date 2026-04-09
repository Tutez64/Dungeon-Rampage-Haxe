package dungeon
;
   import box2D.collision.shapes.B2Shape;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2FilterData;
   import box2D.dynamics.B2World;
   import brain.logger.Logger;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import flash.geom.Vector3D;
   
    class NavCollider
   {
      
      var mDBFacade:DBFacade;
      
      var mParentObject:FloorObject;
      
      var mWorldSpaceOffset:Vector3D;
      
      var mB2Body:B2Body;
      
      var mB2World:B2World;
      
      public function new(param1:DBFacade, param2:FloorObject, param3:Vector3D, param4:B2World)
      {
         
         mDBFacade = param1;
         mParentObject = param2;
         mWorldSpaceOffset = param3;
         mB2World = param4;
         mB2Body = buildBody();
         if(param2 == null)
         {
            mB2Body.SetUserData(null);
         }
         else
         {
            mB2Body.SetUserData(param2.id);
         }
      }
      
      public static function buildNavColliderFromJson(param1:DBFacade, param2:ASObject, param3:FloorObject, param4:Vector3D, param5:Float, param6:Vector3D, param7:B2World, param8:B2FilterData = null) : NavCollider
      {
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_:String = param2.type;
         if(_loc11_ == "circle")
         {
            return new CircleNavCollider(param1,param3,param4,ASCompat.toNumber(ASCompat.toNumberField(param2, "radius") * param6.x),param7,param8);
         }
         if(_loc11_ == "rectangle")
         {
            _loc9_ = ASCompat.toNumber(ASCompat.toNumberField(param2, "halfWidth") * param6.x);
            _loc10_ = ASCompat.toNumber(ASCompat.toNumberField(param2, "halfHeight") * param6.y);
            return new RectangleNavCollider(param1,param3,param4,param5,param7,_loc9_,_loc10_,param8);
         }
         Logger.error("Could not figure out collision type of json to build a b2Shape:" + Std.string(param2));
         return null;
      }
      
      public static function convertToB2Vec2(param1:Vector3D) : B2Vec2
      {
         return new B2Vec2(param1.x / 50,param1.y / 50);
      }
      
      public static function convertToVector3D(param1:B2Vec2) : Vector3D
      {
         return new Vector3D(param1.x * 50,param1.y * 50);
      }
      
      public function destroy() 
      {
         mB2World.DestroyBody(mB2Body);
         mB2Body = null;
         mB2World = null;
         mParentObject = null;
         mDBFacade = null;
      }
      
            
      @:isVar public var active(get,set):Bool;
public function  set_active(param1:Bool) :Bool      {
         mB2Body.SetActive(param1);
return param1;
      }
function  get_active() : Bool
      {
         return mB2Body.IsActive();
      }
      
      function buildBody() : B2Body
      {
         Logger.error("Override build definition in sub classes.");
         return null;
      }
      
      @:isVar public var worldCenter(get,never):Vector3D;
public function  get_worldCenter() : Vector3D
      {
         return convertToVector3D(mB2Body.GetWorldCenter());
      }
      
            
      @:isVar public var position(get,set):Vector3D;
public function  set_position(param1:Vector3D) :Vector3D      {
         var _loc2_= new Vector3D(param1.x + mWorldSpaceOffset.x,param1.y + mWorldSpaceOffset.y);
         mB2Body.SetPosition(convertToB2Vec2(_loc2_));
return param1;
      }
function  get_position() : Vector3D
      {
         var _loc1_= convertToVector3D(mB2Body.GetPosition());
         return _loc1_.subtract(mWorldSpaceOffset);
      }
      
      @:isVar public var velocity(never,set):Vector3D;
public function  set_velocity(param1:Vector3D) :Vector3D      {
         mB2Body.SetAwake(true);
         mB2Body.SetLinearVelocity(convertToB2Vec2(param1));
return param1;
      }
      
      @:isVar public var offset(get,never):Vector3D;
public function  get_offset() : Vector3D
      {
         return mWorldSpaceOffset;
      }
      
      @:isVar public var type(never,set):UInt;
public function  set_type(param1:UInt) :UInt      {
         mB2Body.SetType(B2Body.b2_dynamicBody);
return param1;
      }
      
      @:isVar public var collisionRadius(get,never):Float;
public function  get_collisionRadius() : Float
      {
         if(ASCompat.reinterpretAs(this , CircleNavCollider) != null)
         {
            return ASCompat.reinterpretAs(this , CircleNavCollider).radius;
         }
         return -1;
      }
      
      public function getBody() : B2Body
      {
         return mB2Body;
      }
      
      public function getShape() : B2Shape
      {
         var _loc1_= mB2Body.GetFixtureList();
         return _loc1_.GetShape();
      }
   }


