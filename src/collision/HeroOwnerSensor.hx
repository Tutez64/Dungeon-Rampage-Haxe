package collision
;
   import box2D.collision.shapes.B2Shape;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2BodyDef;
   import box2D.dynamics.B2FilterData;
   import box2D.dynamics.B2FixtureDef;
   import brain.logger.Logger;
   import dBGlobals.DBGlobal;
   import distributedObjects.Floor;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class HeroOwnerSensor implements IContactResolver
   {
      
      var mDBFacade:DBFacade;
      
      var mFloor:Floor;
      
      var mBody:B2Body;
      
      public function new(param1:DBFacade, param2:Floor, param3:B2Shape, param4:UInt)
      {
         
         mFloor = param2;
         mDBFacade = param1;
         var _loc5_= new B2FilterData();
         _loc5_.groupIndex = -1;
         _loc5_.maskBits = DBGlobal.b2dMaskForTeam(param4);
         var _loc7_= new B2FixtureDef();
         _loc7_.isSensor = true;
         _loc7_.shape = param3;
         _loc7_.userData = this;
         _loc7_.filter = _loc5_;
         var _loc6_= new B2BodyDef();
         _loc6_.allowSleep = false;
         mBody = param2.box2DWorld.CreateBody(_loc6_);
         mBody.CreateFixture(_loc7_);
      }
      
      @:isVar public var position(never,set):Vector3D;
public function  set_position(param1:Vector3D) :Vector3D      {
         mBody.SetPosition(NavCollider.convertToB2Vec2(param1));
return param1;
      }
      
      public function enterContact(param1:UInt) 
      {
         Logger.warn("enterContact was called on base class HeroOwnerSensor.  Sub classes should override this call.");
      }
      
      public function exitContact(param1:UInt) 
      {
         Logger.warn("exitContact was called on base class HeroOwnerSensor.  Sub classes should override this call.");
      }
      
      public function destroy() 
      {
         mFloor.box2DWorld.DestroyBody(mBody);
         mBody = null;
         mFloor = null;
         mDBFacade = null;
      }
   }


