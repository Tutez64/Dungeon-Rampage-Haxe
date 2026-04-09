package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class LockAttackTimeLineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "lockAttack";
      
      var mHeroGameObjectOwner:HeroGameObjectOwner;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         super(param1,param2,param3);
         mHeroGameObjectOwner = null;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade) : LockAttackTimeLineAction
      {
         return new LockAttackTimeLineAction(param1,param2,param3);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mHeroGameObjectOwner = ASCompat.reinterpretAs(mActorGameObject , HeroGameObjectOwner);
         if(mHeroGameObjectOwner != null)
         {
            mHeroGameObjectOwner.canInitiateAnAttack = false;
         }
      }
      
      override public function stop() 
      {
         if(mHeroGameObjectOwner != null)
         {
            mHeroGameObjectOwner.canInitiateAnAttack = true;
         }
         super.stop();
      }
   }


