package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.logger.Logger;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import generatedCode.CombatResult;
   
    class CombatResultAttackTimelineAction extends AttackTimelineAction
   {
      
      var mDungeonFloor:DistributedDungeonFloor;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:CombatResult, param5:DistributedDungeonFloor)
      {
         super(param1,param2,param3);
         mCombatResult = param4;
         mDungeonFloor = param5;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         var _loc2_= mDungeonFloor.getActor(mCombatResult.attackee);
         if(_loc2_ == null)
         {
            Logger.warn("Tried to execute a combat result on an actor that is not on the dungeon floor.  Actor id: " + Std.string(mCombatResult.attackee));
            return;
         }
         _loc2_.ReceiveCombatResult(mCombatResult);
      }
   }


