package dungeon
;
   import box2D.collision.shapes.B2PolygonShape;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2BodyDef;
   import box2D.dynamics.B2FilterData;
   import box2D.dynamics.B2FixtureDef;
   import box2D.dynamics.B2World;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import flash.geom.Vector3D;
   
    class RectangleNavCollider extends NavCollider
   {
      
      var mHalfWidth:Float = Math.NaN;
      
      var mHalfHeight:Float = Math.NaN;
      
      var mFilter:B2FilterData;
      
      public function new(param1:DBFacade, param2:FloorObject, param3:Vector3D, param4:Float, param5:B2World, param6:Float, param7:Float, param8:B2FilterData = null)
      {
         mHalfWidth = param6 / 50;
         mHalfHeight = param7 / 50;
         mFilter = param8;
         super(param1,param2,param3,param5);
         this.angle = param4;
      }
      
            
      @:isVar public var angle(get,set):Float;
public function  set_angle(param1:Float) :Float      {
         mB2Body.SetAngle(param1);
return param1;
      }
function  get_angle() : Float
      {
         return mB2Body.GetAngle();
      }
      
      override function buildBody() : B2Body
      {
         var _loc1_= new B2BodyDef();
         var _loc3_= new B2FixtureDef();
         var _loc2_= new B2PolygonShape();
         _loc2_.SetAsBox(mHalfWidth,mHalfHeight);
         _loc3_.shape = _loc2_;
         if(mFilter != null)
         {
            _loc3_.filter = mFilter;
         }
         var _loc4_= mB2World.CreateBody(_loc1_);
         _loc4_.CreateFixture(_loc3_);
         return _loc4_;
      }
   }


