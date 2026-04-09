package doobers
;
   import brain.gameObject.GameObject;
   import brain.utils.MemoryTracker;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import generatedCode.DistributedDooberGameObjectNetworkComponent;
   import generatedCode.IDistributedDooberGameObject;
   import flash.geom.Vector3D;
   
    class DistributedDooberGameObject extends GameObject implements IDistributedDooberGameObject
   {
      
      var mDooberGameObject:DooberGameObject;
      
      var localFacade:DBFacade;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         localFacade = param1;
         super(param1,(0 : UInt));
         mDooberGameObject = new DooberGameObject(param1,param2);
         MemoryTracker.track(mDooberGameObject,"DooberGameObject - created in DistributedDooberGameObject.constructor()");
      }
      
      override public function getTrueObject() : GameObject
      {
         return mDooberGameObject;
      }
      
      public function setNetworkComponentDistributedDooberGameObject(param1:DistributedDooberGameObjectNetworkComponent) 
      {
         mDooberGameObject.setNetworkComponentDistributedDooberGameObject(param1);
      }
      
      public function postGenerate() 
      {
         if(mDooberGameObject != null)
         {
            mDooberGameObject.postGenerate();
         }
      }
      
      @:isVar public var type(never,set):UInt;
public function  set_type(param1:UInt) :UInt      {
         if(mDooberGameObject != null)
         {
            mDooberGameObject.type = param1;
         }
return param1;
      }
      
      @:isVar public var position(never,set):Vector3D;
public function  set_position(param1:Vector3D) :Vector3D      {
         if(mDooberGameObject != null)
         {
            mDooberGameObject.position = param1;
         }
return param1;
      }
      
      public function collectedBy(param1:UInt) 
      {
         if(mDooberGameObject != null)
         {
            mDooberGameObject.takeOwnership(param1 == HeroGameObjectOwner.currentHeroOwnerId,param1);
            mDooberGameObject = null;
         }
      }
      
      public function spawnFrom(param1:Vector3D) 
      {
         if(mDooberGameObject != null)
         {
            mDooberGameObject.spawnFrom(param1);
         }
      }
      
      @:isVar public var layer(never,set):Int;
public function  set_layer(param1:Int) :Int      {
         if(mDooberGameObject != null)
         {
            mDooberGameObject.layer = param1;
         }
return param1;
      }
      
      override public function destroy() 
      {
         if(mDooberGameObject != null)
         {
            mDooberGameObject.destroy();
            mDooberGameObject = null;
         }
         super.destroy();
      }
   }


