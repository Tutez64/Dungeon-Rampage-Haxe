package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import flash.geom.Vector3D;
   
    class KnockBackTimelineAction extends AutoMoveTimelineAction
   {
      
      public static inline final TYPE= "knockback";
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade) : KnockBackTimelineAction
      {
         if(param1.isOwner)
         {
            return new KnockBackTimelineAction(param1,param2,param3);
         }
         return null;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         var _loc2_:Vector3D = null;
         var _loc3_= ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(mAttackType), gameMasterDictionary.GMAttack);
         if(_loc3_ != null && mAttacker != null)
         {
            mDistance = _loc3_.Knockback;
            mDuration = _loc3_.KnockbackDur;
            _loc2_ = new Vector3D(mActorGameObject.worldCenter.x - mAttacker.worldCenter.x,mActorGameObject.worldCenter.y - mAttacker.worldCenter.y);
            mAngle = Math.atan2(_loc2_.y,_loc2_.x) * 180 / 3.141592653589793;
         }
         if(mDuration > 0)
         {
            super.execute(param1);
         }
      }
   }


