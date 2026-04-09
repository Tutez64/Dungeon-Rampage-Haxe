package collision
;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2BodyDef;
   import box2D.dynamics.B2FilterData;
   import box2D.dynamics.B2FixtureDef;
   import distributedObjects.Floor;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class LocalHeroProximitySensor implements IContactResolver
   {
      
      var mDBFacade:DBFacade;
      
      var mFloor:Floor;
      
      var mBody:B2Body;
      
      var mCollisionCallback:ASFunction;
      
      var mTriggerOnce:Bool = false;
      
      var mHasCollidedFirstTime:Bool = false;
      
      public function new(param1:DBFacade, param2:Floor, param3:UInt, param4:UInt, param5:UInt, param6:Bool, param7:ASFunction)
      {
         
         mFloor = param2;
         mDBFacade = param1;
         mTriggerOnce = param6;
         mCollisionCallback = param7;
         mHasCollidedFirstTime = false;
         var _loc8_= new B2FilterData();
         _loc8_.categoryBits = (2 : UInt);
         var _loc9_= new B2CircleShape(param5 / 50);
         var _loc11_= new B2FixtureDef();
         _loc11_.isSensor = true;
         _loc11_.shape = _loc9_;
         _loc11_.userData = this;
         _loc11_.filter = _loc8_;
         var _loc10_= new B2BodyDef();
         _loc10_.allowSleep = false;
         mBody = param2.box2DWorld.CreateBody(_loc10_);
         mBody.CreateFixture(_loc11_);
         mBody.SetPosition(NavCollider.convertToB2Vec2(new Vector3D(param3,param4)));
      }
      
      public function enterContact(param1:UInt) 
      {
         if(mTriggerOnce)
         {
            if(!mHasCollidedFirstTime)
            {
               mCollisionCallback();
            }
         }
         else
         {
            mCollisionCallback();
         }
         mHasCollidedFirstTime = true;
      }
      
      public function exitContact(param1:UInt) 
      {
      }
      
      public function destroy() 
      {
         mFloor.box2DWorld.DestroyBody(mBody);
         mBody = null;
         mFloor = null;
         mDBFacade = null;
      }
   }


