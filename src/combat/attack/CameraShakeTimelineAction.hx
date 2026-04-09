package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.logger.Logger;
   import facade.DBFacade;
   
    class CameraShakeTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "shake";
      
      var mDuration:Float = 0;
      
      var mNumShakes:UInt = (0 : UInt);
      
      var mRotation:Float = 0;
      
      var mX:Float = 0;
      
      var mY:Float = 0;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject)
      {
         super(param1,param2,param3);
         if(param4.duration == null)
         {
            Logger.error("CameraShakeTimelineAction: Must specify duration");
         }
         if(param4.numShakes == null)
         {
            Logger.error("CameraShakeTimelineAction: Must specify numShakes");
         }
         if(param4.rotation == null && param4.x == null && param4.y == null)
         {
            Logger.error("CameraShakeTimelineAction: Must specify at least one of rotation, x, or y");
         }
         var _loc5_= (24 : UInt);
         mDuration = ASCompat.toNumberField(param4, "duration") / _loc5_;
         mNumShakes = (ASCompat.toInt(param4.numShakes) : UInt);
         mRotation = ASCompat.toNumberField(param4, "rotation");
         mX = ASCompat.toNumberField(param4, "x");
         mY = ASCompat.toNumberField(param4, "y");
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : CameraShakeTimelineAction
      {
         if(param1.isOwner || param1.actorData.gMActor.CanShakeCamera)
         {
            return new CameraShakeTimelineAction(param1,param2,param3,param4);
         }
         return null;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         if(mDBFacade.featureFlags.getFlagValue("want-zoom"))
         {
            if(ASCompat.floatAsBool(mRotation))
            {
               this.mDBFacade.camera.shakeRotation(mDuration,mRotation,mNumShakes);
            }
            if(ASCompat.floatAsBool(mX))
            {
               this.mDBFacade.camera.shakeX(mDuration,mX,mNumShakes);
            }
            if(ASCompat.floatAsBool(mY))
            {
               this.mDBFacade.camera.shakeY(mDuration,mY,mNumShakes);
            }
         }
      }
      
      override public function destroy() 
      {
         super.destroy();
      }
   }


