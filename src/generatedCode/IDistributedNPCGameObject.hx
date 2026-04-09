package generatedCode
;
   import brain.gameObject.GameObject;
   import flash.geom.Vector3D;
   
    interface IDistributedNPCGameObject
   {
      
      function setNetworkComponentDistributedNPCGameObject(param1:DistributedNPCGameObjectNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      @:isVar var type(never,set):UInt;
      
      @:isVar var level(never,set):UInt;
      
      @:isVar var position(never,set):Vector3D;
      
      @:isVar var heading(never,set):Float;
      
      @:isVar var scale(never,set):Float;
      
      @:isVar var flip(never,set):UInt;
      
      @:isVar var hitPoints(never,set):UInt;
      
      @:isVar var weaponDetails(never,set):Vector<WeaponDetails>;
      
      @:isVar var state(never,set):String;
      
      @:isVar var team(never,set):Int;
      
      @:isVar var layer(never,set):Int;
      
      @:isVar var remoteTriggerState(never,set):UInt;
      
      @:isVar var masterId(never,set):UInt;
      
      function ReceiveAttackChoreography(param1:AttackChoreography) : Void;
      
      function ReceiveCombatResult(param1:CombatResult) : Void;
      
      function ReceiveTimelineAction(param1:String) : Void;
   }


