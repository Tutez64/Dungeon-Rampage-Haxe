package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class KnockbackImmunityTimeLineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "knockbackImmunity";
      
      var mHeroGameObjectOwner:HeroGameObjectOwner;
      
      var mCanBeKnockedBack:Bool = false;
      
      var mCanBeKnockedBack_original:Bool = false;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:Bool)
      {
         super(param1,param2,param3);
         mHeroGameObjectOwner = null;
         mCanBeKnockedBack = param4;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : KnockbackImmunityTimeLineAction
      {
         var _loc5_= ASCompat.toBool(param4.value);
         return new KnockbackImmunityTimeLineAction(param1,param2,param3,_loc5_);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mHeroGameObjectOwner = ASCompat.reinterpretAs(mActorGameObject , HeroGameObjectOwner);
         if(mHeroGameObjectOwner != null)
         {
            mCanBeKnockedBack_original = mHeroGameObjectOwner.canBeKnockedBack;
            mHeroGameObjectOwner.canBeKnockedBack = mCanBeKnockedBack;
         }
      }
      
      override public function stop() 
      {
         if(mHeroGameObjectOwner != null)
         {
            mHeroGameObjectOwner.canBeKnockedBack = mCanBeKnockedBack_original;
         }
         mHeroGameObjectOwner = null;
         super.stop();
      }
   }


