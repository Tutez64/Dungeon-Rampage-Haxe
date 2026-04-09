package collision
;
   import box2D.collision.shapes.B2Shape;
   import distributedObjects.Floor;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class HeroReviveSensor extends HeroOwnerSensor
   {
      
      var mCallback:ASFunction;
      
      var mFinishedCallback:ASFunction;
      
      public function new(param1:DBFacade, param2:Floor, param3:B2Shape, param4:UInt)
      {
         super(param1,param2,param3,param4);
      }
      
      override public function destroy() 
      {
         mCallback = null;
         mFinishedCallback = null;
         super.destroy();
      }
      
      override public function enterContact(param1:UInt) 
      {
         var _loc2_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1) , HeroGameObjectOwner);
         if(_loc2_ != null && _loc2_.heroStateMachine != null && _loc2_.heroStateMachine.currentStateName != "ActorReviveState")
         {
            mCallback(_loc2_);
         }
      }
      
      override public function exitContact(param1:UInt) 
      {
         var _loc2_:HeroGameObjectOwner = null;
         if(mDBFacade != null)
         {
            _loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1) , HeroGameObjectOwner);
            if(_loc2_ != null)
            {
               if(mFinishedCallback != null)
               {
                  mFinishedCallback();
               }
            }
         }
      }
      
      @:isVar public var callback(never,set):ASFunction;
public function  set_callback(param1:ASFunction) :ASFunction      {
         return mCallback = param1;
      }
      
      @:isVar public var finishedCallback(never,set):ASFunction;
public function  set_finishedCallback(param1:ASFunction) :ASFunction      {
         return mFinishedCallback = param1;
      }
   }


