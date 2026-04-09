package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.workLoop.Task;
   import facade.DBFacade;
   
    class CameraZoomTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "zoom";
      
      var mTask:Task;
      
      var mDuration:Float = 0;
      
      var mZoomFactor:Float = 1;
      
      var mLerpInDuration:Float = 0;
      
      var mLerpOutDuration:Float = 0;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject)
      {
         super(param1,param2,param3);
         if(param4.duration == null)
         {
            Logger.error("CameraZoomTimelineAction: Must specify duration");
         }
         if(param4.zoomFactor == null)
         {
            Logger.error("CameraZoomTimelineAction: Must specify zoomFactor");
         }
         var _loc5_= (24 : UInt);
         mDuration = ASCompat.toNumberField(param4, "duration") / _loc5_;
         mZoomFactor = ASCompat.toNumberField(param4, "zoomFactor");
         mLerpInDuration = param4.lerpInDuration != null ? ASCompat.toNumberField(param4, "lerpInDuration") / _loc5_ : 0;
         mLerpOutDuration = param4.lerpOutDuration != null ? ASCompat.toNumberField(param4, "lerpOutDuration") / _loc5_ : 0;
         if(mDuration < mLerpInDuration + mLerpOutDuration)
         {
            Logger.error("CameraZoomTimelineAction: duration must be >= lerp in + lerp out");
            mDuration = mLerpInDuration + mLerpOutDuration;
         }
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : CameraZoomTimelineAction
      {
         if(param1.isOwner)
         {
            return new CameraZoomTimelineAction(param1,param2,param3,param4);
         }
         return null;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         if(mLerpInDuration > 0)
         {
            this.mDBFacade.camera.tweenZoom(mLerpInDuration,mZoomFactor);
         }
         else
         {
            this.mDBFacade.camera.zoom = mZoomFactor;
         }
         mTask = mWorkComponent.doLater(mDuration - mLerpOutDuration,resetZoom);
      }
      
      function resetZoom(param1:GameClock) 
      {
         if(mLerpOutDuration > 0)
         {
            this.mDBFacade.camera.tweenToDefaultZoom(mLerpOutDuration);
         }
         else
         {
            this.mDBFacade.camera.zoom = this.mDBFacade.camera.defaultZoom;
         }
      }
      
      override public function destroy() 
      {
         mWorkComponent.destroy();
         mWorkComponent = null;
         super.destroy();
      }
   }


