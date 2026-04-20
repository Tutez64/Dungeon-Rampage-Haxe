package brain.camera
;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   
    class LetterboxEffect
   {
      
      var mFacade:Facade;
      
      var mRectSprite:Sprite;
      
      var mDuration:UInt = 0;
      
      var mTransitionDuration:Float = Math.NaN;
      
      var mColor:Vector3D;
      
      var mOffset:Float = Math.NaN;
      
      var mAlpha:Float = Math.NaN;
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mFadeTask:Task;
      
      var mFramesElapsed:UInt = 0;
      
      static inline final mPadding:Float = 512;
      
      public function new(param1:Facade)
      {
         
         mFramesElapsed = (0 : UInt);
         mFacade = param1;
         mWorkComponent = new LogicalWorkComponent(param1,"LetterboxEffect");
         MemoryTracker.track(mWorkComponent,"LogicalWorkComponent - created in LetterboxEffect()","brain");
      }
      
      public function doFade(param1:UInt, param2:Float, param3:Vector3D, param4:Float) 
      {
         var _loc5_= 0;
         if(mRectSprite == null)
         {
            mDuration = param1;
            mTransitionDuration = param2;
            mColor = new Vector3D(param3.x,param3.y,param3.z);
            mAlpha = param4;
            mOffset = param4 / param2;
            execute();
         }
         else
         {
            _loc5_ = (mDuration - mFramesElapsed : Int);
            mDuration = (ASCompat.toInt((_loc5_ : UInt) > param1 ? (_loc5_ : UInt) : param1) : UInt);
            mTransitionDuration = param2;
            mFramesElapsed = (0 : UInt);
            mAlpha = mAlpha > param4 ? mAlpha : param4;
            mOffset = mAlpha / mTransitionDuration;
         }
      }
      
      function execute() 
      {
         if(mFramesElapsed != 0)
         {
            ResetFade();
         }
         mFramesElapsed = (0 : UInt);
         mRectSprite = new Sprite();
         MemoryTracker.track(mRectSprite,"Sprite - letterbox rect created in LetterboxEffect.execute()","brain");
         mRectSprite.graphics.beginFill((Std.int(mColor.x) << 16 | Std.int(mColor.y) << 8 | Std.int(mColor.z) : UInt),1);
         mRectSprite.graphics.drawRect(0,0,mFacade.stageRef.fullScreenWidth + 512,75);
         mRectSprite.graphics.drawRect(0,mFacade.stageRef.fullScreenHeight - 550,mFacade.stageRef.fullScreenWidth + 512,375);
         mRectSprite.graphics.endFill();
         mRectSprite.cacheAsBitmap = true;
         mRectSprite.alpha = 0;
         mFacade.sceneGraphManager.addChild(mRectSprite,100);
         mFadeTask = mWorkComponent.doEveryFrame(UpdateBackgroundFade);
      }
      
      public function UpdateBackgroundFade(param1:GameClock) 
      {
         if(mRectSprite == null)
         {
            Logger.warn("LetterboxEffect with null RectSprite");
            return;
         }
         mFramesElapsed = mFramesElapsed + 1;
         if(mFramesElapsed <= mTransitionDuration)
         {
            mRectSprite.alpha += mOffset;
            mRectSprite.alpha = Math.min(mRectSprite.alpha,mAlpha);
         }
         else if(mFramesElapsed >= mDuration - mTransitionDuration)
         {
            mRectSprite.alpha -= mOffset;
            mRectSprite.alpha = Math.max(mRectSprite.alpha,0);
         }
         else if(mFramesElapsed > mTransitionDuration)
         {
            mRectSprite.alpha = mAlpha;
         }
         if(mFramesElapsed > mDuration)
         {
            ResetFade();
            return;
         }
      }
      
      function ResetFade() 
      {
         mFramesElapsed = (0 : UInt);
         mFacade.sceneGraphManager.removeChild(mRectSprite);
         mRectSprite = null;
         mFadeTask.destroy();
         mFadeTask = null;
      }
      
      public function forceStop() 
      {
         if(mFadeTask != null && mRectSprite != null)
         {
            ResetFade();
         }
      }
      
      public function destroy() 
      {
         if(mFadeTask != null)
         {
            mFadeTask.destroy();
            mFadeTask = null;
         }
         if(mWorkComponent != null)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
      }
   }


