package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import combat.weapon.WeaponController;
   import facade.DBFacade;
   
    class QueueAttackTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "queueAttack";
      
      var mWeaponController:WeaponController;
      
      var mAttackToQueue:String;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:WeaponController, param5:ASObject)
      {
         super(param1,param2,param3);
         mWeaponController = param4;
         mAttackToQueue = param5.attackName;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:WeaponController, param5:ASObject) : QueueAttackTimelineAction
      {
         if(param1.isOwner)
         {
            return new QueueAttackTimelineAction(param1,param2,param3,param4,param5);
         }
         return null;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mWeaponController.queueAttack(mAttackToQueue);
      }
      
      override public function destroy() 
      {
         mWeaponController = null;
         super.destroy();
      }
   }


