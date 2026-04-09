package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class SufferImmunityTimeLineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "sufferImmunity";
      
      var mHeroGameObjectOwner:HeroGameObjectOwner;
      
      var mCanSuffer:Bool = false;
      
      var mCanSuffer_original:Bool = false;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:Bool)
      {
         super(param1,param2,param3);
         mHeroGameObjectOwner = null;
         mCanSuffer = param4;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : SufferImmunityTimeLineAction
      {
         var _loc5_= ASCompat.toBool(param4.value);
         return new SufferImmunityTimeLineAction(param1,param2,param3,_loc5_);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mHeroGameObjectOwner = ASCompat.reinterpretAs(mActorGameObject , HeroGameObjectOwner);
         if(mHeroGameObjectOwner != null)
         {
            mCanSuffer_original = mHeroGameObjectOwner.canSuffer;
            mHeroGameObjectOwner.canSuffer = mCanSuffer;
         }
      }
      
      override public function stop() 
      {
         if(mHeroGameObjectOwner != null)
         {
            mHeroGameObjectOwner.canSuffer = mCanSuffer_original;
         }
         mHeroGameObjectOwner = null;
         super.stop();
      }
   }


