package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.workLoop.LogicalWorkComponent;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import generatedCode.CombatResult;
   
    class AttackTimelineAction
   {
      
      var mActorGameObject:ActorGameObject;
      
      var mActorView:ActorView;
      
      var mDBFacade:DBFacade;
      
      var mAttackType:UInt = 0;
      
      var mCombatResult:CombatResult;
      
      var mAttacker:ActorGameObject;
      
      var mGMAttack:GMAttack;
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mTimeline:ScriptTimeline;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         
         mActorGameObject = param1;
         mActorView = param2;
         mDBFacade = param3;
         mWorkComponent = new LogicalWorkComponent(mDBFacade);
      }
      
      @:isVar public var attackType(never,set):UInt;
public function  set_attackType(param1:UInt) :UInt      {
         if(mAttackType != param1)
         {
            mAttackType = param1;
            mGMAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(param1), gameMasterDictionary.GMAttack);
         }
return param1;
      }
      
      @:isVar public var combatResult(never,set):CombatResult;
public function  set_combatResult(param1:CombatResult) :CombatResult      {
         return mCombatResult = param1;
      }
      
      @:isVar public var attacker(never,set):ActorGameObject;
public function  set_attacker(param1:ActorGameObject) :ActorGameObject      {
         return mAttacker = param1;
      }
      
      public function execute(param1:ScriptTimeline) 
      {
         mTimeline = param1;
      }
      
      public function destroy() 
      {
         mActorGameObject = null;
         mActorView = null;
         mDBFacade = null;
         mCombatResult = null;
         mAttacker = null;
         mGMAttack = null;
         if(mWorkComponent != null)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
      }
      
      public function stop() 
      {
      }
   }


