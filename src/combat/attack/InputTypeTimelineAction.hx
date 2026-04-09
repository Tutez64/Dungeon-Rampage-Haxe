package combat.attack
;
   import actor.ActorView;
   import brain.logger.Logger;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class InputTypeTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "inputType";
      
      var mHeroGameObjectOwner:HeroGameObjectOwner;
      
      var mInputType:String;
      
      public function new(param1:HeroGameObjectOwner, param2:ActorView, param3:DBFacade, param4:String)
      {
         super(param1,param2,param3);
         mHeroGameObjectOwner = param1;
         mInputType = param4;
         if(mHeroGameObjectOwner == null)
         {
            Logger.error("ActorGameObject passed into InputTypeTimelineAction is not a HeroGameObjectOwner.");
         }
      }
      
      public static function buildFromJson(param1:HeroGameObjectOwner, param2:ActorView, param3:DBFacade, param4:ASObject) : InputTypeTimelineAction
      {
         var _loc5_:String = param4.inputType;
         return new InputTypeTimelineAction(param1,param2,param3,_loc5_);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mHeroGameObjectOwner.inputController.inputType = mInputType;
      }
      
      override public function stop() 
      {
         super.stop();
         if(mHeroGameObjectOwner != null && mHeroGameObjectOwner.inputController != null)
         {
            mHeroGameObjectOwner.inputController.inputType = "free";
         }
      }
      
      override public function destroy() 
      {
         super.destroy();
         if(mHeroGameObjectOwner != null && mHeroGameObjectOwner.inputController != null)
         {
            mHeroGameObjectOwner.inputController.inputType = "free";
         }
      }
   }


