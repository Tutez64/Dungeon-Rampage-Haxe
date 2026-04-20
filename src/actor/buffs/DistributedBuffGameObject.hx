package actor.buffs
;
   import actor.ActorGameObject;
   import brain.facade.Facade;
   import brain.gameObject.GameObject;
   import generatedCode.DistributedBuffGameObjectNetworkComponent;
   import generatedCode.IDistributedBuffGameObject;
   
    class DistributedBuffGameObject extends GameObject implements IDistributedBuffGameObject
   {
      
      var mType:UInt = 0;
      
      var mEffectedActor:UInt = 0;
      
      var mAttackerActor:UInt = 0;
      
      public var buffHandler:BuffHandler;
      
      public function new(param1:Facade, param2:UInt = (0 : UInt))
      {
         super(param1,param2);
      }
      
      public function setNetworkComponentDistributedBuffGameObject(param1:DistributedBuffGameObjectNetworkComponent) 
      {
      }
      
      public function postGenerate() 
      {
         var _loc2_= mFacade.gameObjectManager.getReferenceFromId(mEffectedActor);
         var _loc1_= ASCompat.reinterpretAs(_loc2_ , ActorGameObject);
         if(_loc1_ != null)
         {
            _loc1_.buffHandler.addBuff(this);
            _loc1_.ponderBuffChanges();
         }
      }
      
      override public function destroy() 
      {
         if(buffHandler != null)
         {
            buffHandler.removeBuff(this);
            super.destroy();
         }
      }
      
            
      @:isVar public var type(get,set):UInt;
public function  get_type() : UInt
      {
         return this.mType;
      }
      
      @:isVar public var effectedActor(never,set):UInt;
public function  set_effectedActor(param1:UInt) :UInt      {
         return mEffectedActor = param1;
      }
      
            
      @:isVar public var attackerActor(get,set):UInt;
public function  set_attackerActor(param1:UInt) :UInt      {
         return mAttackerActor = param1;
      }
function  get_attackerActor() : UInt
      {
         return mAttackerActor;
      }
function  set_type(param1:UInt) :UInt      {
         return mType = param1;
      }
   }


