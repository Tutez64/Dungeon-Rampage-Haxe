package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import distributedObjects.HeroGameObject;
   import facade.DBFacade;
   
    class AttackAutoMoveTimelineAction extends AutoMoveTimelineAction
   {
      
      public static inline final TYPE= "attackautomove";
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade) : AttackAutoMoveTimelineAction
      {
         if(param1.isOwner)
         {
            return new AttackAutoMoveTimelineAction(param1,param2,param3);
         }
         return null;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         var _loc2_:AttackTimeline = null;
         mAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(mAttackType), gameMasterDictionary.GMAttack);
         mDuration = mAttack.MoveDuration;
         mDistance = mAttack.MoveAmount;
         mAngle = mAttack.MoveAngle + mActorGameObject.heading;
         if(Std.isOfType(param1 , AttackTimeline))
         {
            _loc2_ = ASCompat.reinterpretAs(param1 , AttackTimeline);
            if(Std.isOfType(mActorGameObject , HeroGameObject))
            {
               mDuration = _loc2_.distanceScalingTime > 0 ? _loc2_.distanceScalingTime : mDuration;
               mDistance = _loc2_.distanceScalingHero > 0 ? _loc2_.distanceScalingHero : mDistance;
            }
         }
         if(mDuration > 0 && mDistance > 0)
         {
            super.execute(param1);
         }
      }
   }


