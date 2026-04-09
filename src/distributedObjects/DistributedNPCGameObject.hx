package distributedObjects
;
   import brain.gameObject.GameObject;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import gameMasterDictionary.StatVector;
   import generatedCode.AttackChoreography;
   import generatedCode.CombatResult;
   import generatedCode.DistributedNPCGameObjectNetworkComponent;
   import generatedCode.IDistributedNPCGameObject;
   import generatedCode.WeaponDetails;
   import flash.geom.Vector3D;
   
    class DistributedNPCGameObject extends GameObject implements IDistributedNPCGameObject
   {
      
      var mNPCGameObject:NPCGameObject;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         super(param1,(0 : UInt));
         mNPCGameObject = new NPCGameObject(param1,param2);
         MemoryTracker.track(mNPCGameObject,"NPCGameObject - created in DistributedNPCGameObject.constructor()");
      }
      
      override public function getTrueObject() : GameObject
      {
         return mNPCGameObject;
      }
      
      public function setNetworkComponentDistributedNPCGameObject(param1:DistributedNPCGameObjectNetworkComponent) 
      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.setNetworkComponentDistributedNPCGameObject(param1);
         }
      }
      
      @:isVar public var state(never,set):String;
public function  set_state(param1:String) :String      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.state = param1;
            if(param1 == "dead")
            {
               mNPCGameObject.hasOwnership = true;
               mNPCGameObject = null;
            }
         }
return param1;
      }
      
      public function postGenerate() 
      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.postGenerate();
         }
      }
      
      @:isVar public var type(never,set):UInt;
public function  set_type(param1:UInt) :UInt      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.type = param1;
         }
return param1;
      }
      
      @:isVar public var level(never,set):UInt;
public function  set_level(param1:UInt) :UInt      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.level = param1;
         }
return param1;
      }
      
      @:isVar public var position(never,set):Vector3D;
public function  set_position(param1:Vector3D) :Vector3D      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.position = param1;
         }
return param1;
      }
      
      @:isVar public var heading(never,set):Float;
public function  set_heading(param1:Float) :Float      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.heading = param1;
         }
return param1;
      }
      
      @:isVar public var scale(never,set):Float;
public function  set_scale(param1:Float) :Float      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.scale = param1;
         }
return param1;
      }
      
      @:isVar public var flip(never,set):UInt;
public function  set_flip(param1:UInt) :UInt      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.flip = param1;
         }
return param1;
      }
      
      @:isVar public var hitPoints(never,set):UInt;
public function  set_hitPoints(param1:UInt) :UInt      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.hitPoints = param1;
         }
return param1;
      }
      
      @:isVar public var weaponDetails(never,set):Vector<WeaponDetails>;
public function  set_weaponDetails(param1:Vector<WeaponDetails>) :Vector<WeaponDetails>      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.weaponDetails = param1;
         }
return param1;
      }
      
      @:isVar public var stats(never,set):StatVector;
public function  set_stats(param1:StatVector) :StatVector      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.stats = param1;
         }
return param1;
      }
      
      @:isVar public var masterId(never,set):UInt;
public function  set_masterId(param1:UInt) :UInt      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.masterId = param1;
         }
return param1;
      }
      
      public function ReceiveAttackChoreography(param1:AttackChoreography) 
      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.ReceiveAttackChoreography(param1);
         }
      }
      
      public function ReceiveTimelineAction(param1:String) 
      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.ReceiveTimelineAction(param1);
         }
      }
      
      public function ReceiveCombatResult(param1:CombatResult) 
      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.ReceiveCombatResult(param1);
         }
      }
      
      override public function destroy() 
      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.destroy();
            mNPCGameObject = null;
         }
         super.destroy();
      }
      
      @:isVar public var layer(never,set):Int;
public function  set_layer(param1:Int) :Int      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.layer = param1;
         }
return param1;
      }
      
      @:isVar public var team(never,set):Int;
public function  set_team(param1:Int) :Int      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.team = param1;
         }
return param1;
      }
      
      @:isVar public var remoteTriggerState(never,set):UInt;
public function  set_remoteTriggerState(param1:UInt) :UInt      {
         if(mNPCGameObject != null)
         {
            mNPCGameObject.remoteTriggerState = param1;
         }
return param1;
      }
   }


