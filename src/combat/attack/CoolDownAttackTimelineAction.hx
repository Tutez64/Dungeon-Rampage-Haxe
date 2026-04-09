package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import combat.weapon.WeaponController;
   import facade.DBFacade;
   
    class CoolDownAttackTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "startCooldown";
      
      var mWeaponController:WeaponController;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:WeaponController, param5:ASObject)
      {
         super(param1,param2,param3);
         mWeaponController = param4;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:WeaponController, param5:ASObject) : CoolDownAttackTimelineAction
      {
         if(param1.isOwner)
         {
            return new CoolDownAttackTimelineAction(param1,param2,param3,param4,param5);
         }
         return null;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mWeaponController.startCooldown();
      }
      
      override public function destroy() 
      {
         mWeaponController = null;
         super.destroy();
      }
   }


