package dungeon
;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2BodyDef;
   import box2D.dynamics.B2FilterData;
   import box2D.dynamics.B2FixtureDef;
   import box2D.dynamics.B2World;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import flash.geom.Vector3D;
   
    class CircleNavCollider extends NavCollider
   {
      
      var mRadius:Float = Math.NaN;
      
      var mFilter:B2FilterData;
      
      public function new(param1:DBFacade, param2:FloorObject, param3:Vector3D, param4:Float, param5:B2World, param6:B2FilterData = null)
      {
         mRadius = param4 / 50;
         mFilter = param6;
         super(param1,param2,param3,param5);
      }
      
      override function buildBody() : B2Body
      {
         var _loc1_= new B2BodyDef();
         var _loc3_= new B2FixtureDef();
         var _loc2_= new B2CircleShape(mRadius);
         _loc3_.shape = _loc2_;
         if(mFilter != null)
         {
            _loc3_.filter = mFilter;
         }
         var _loc4_= mB2World.CreateBody(_loc1_);
         _loc4_.CreateFixture(_loc3_);
         return _loc4_;
      }
      
      @:isVar public var radius(get,never):Float;
public function  get_radius() : Float
      {
         return mRadius;
      }
   }


