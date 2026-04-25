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

    class BackgroundFader
   {

      public static inline final TYPE= "fadebackground";

      var mFacade:Facade;

      var mExcludes:Array<ASAny>;

      var mRectSprite:Sprite;

      var mDuration:UInt = 0;

      var mTransitionDuration:Float = Math.NaN;

      var mColor:Vector3D;

      var mOffset:Float = Math.NaN;

      var mAlpha:Float = Math.NaN;

      var mWorkComponent:LogicalWorkComponent;

      var mFadeTask:Task;

      var mFramesElapsed:Float = 0;

      var mStartTop:Float = Math.NaN;

      var mStartLeft:Float = Math.NaN;

      static inline final mPadding:Float = 1300;

      public function new(param1:Facade)
      {

         mFramesElapsed = 0;
         mFacade = param1;
         mWorkComponent = new LogicalWorkComponent(param1,"BackgroundFader");
         MemoryTracker.track(mWorkComponent,"LogicalWorkComponent - created in BackgroundFader()","brain");
      }

      public function doFade(param1:Array<ASAny>, param2:UInt, param3:Float, param4:Vector3D, param5:Float)
      {
         var _loc6_= 0;
         if(mRectSprite == null)
         {
            mDuration = param2;
            mTransitionDuration = param3;
            mColor = new Vector3D(param4.x,param4.y,param4.z);
            mAlpha = param5;
            mOffset = param5 / param3;
            mExcludes = param1;
            execute();
         }
         else
         {
            _loc6_ = Std.int(mDuration - mFramesElapsed);
            mDuration = (ASCompat.toInt((_loc6_ : UInt) > param2 ? (_loc6_ : UInt) : param2) : UInt);
            mTransitionDuration = param3;
            mFramesElapsed = 0;
            mAlpha = mAlpha > param5 ? mAlpha : param5;
            mOffset = mAlpha / mTransitionDuration;
         }
      }

      function execute()
      {
         if(mFramesElapsed != 0)
         {
            ResetFade();
         }
         mFramesElapsed = 0;
         mRectSprite = new Sprite();
         MemoryTracker.track(mRectSprite,"Sprite - fade rect created in BackgroundFader.execute()","brain");
         mRectSprite.graphics.beginFill((Std.int(mColor.x) << 16 | Std.int(mColor.y) << 8 | Std.int(mColor.z) : UInt),1);
         mStartTop = mFacade.camera.visibleRectangle.top - 1300 * 0.5;
         mStartLeft = mFacade.camera.visibleRectangle.left - 1300 * 0.5;
         mRectSprite.graphics.drawRect(mStartLeft,mStartTop,mFacade.stageRef.fullScreenWidth + 1300,mFacade.stageRef.fullScreenHeight + 1300);
         mRectSprite.graphics.endFill();
         mRectSprite.cacheAsBitmap = true;
         mRectSprite.alpha = 0;
         mFacade.sceneGraphManager.addChild(mRectSprite,42);
         var _loc1_:ASAny;
         final __ax4_iter_203 = mExcludes;
         if (checkNullIteratee(__ax4_iter_203)) for (_tmp_ in __ax4_iter_203)
         {
            _loc1_ = _tmp_;
            mFacade.sceneGraphManager.addChild(ASCompat.dynamicAs(_loc1_, flash.display.DisplayObject),46);
         }
         mFadeTask = mWorkComponent.doEveryFrame(UpdateBackgroundFade);
      }

      public function UpdateBackgroundFade(param1:GameClock)
      {
         if(mRectSprite == null)
         {
            Logger.error("BackgroundFader with null RectSprite");
            return;
         }
         mRectSprite.x = mFacade.camera.visibleRectangle.left - mStartLeft - 1300 * 0.5;
         mRectSprite.y = mFacade.camera.visibleRectangle.top - mStartTop - 1300 * 0.5;
         var _loc2_= param1.tickLength / GameClock.ANIMATION_FRAME_DURATION;
         mFramesElapsed += _loc2_;
         if(mFramesElapsed <= mTransitionDuration)
         {
            mRectSprite.alpha += mOffset * _loc2_;
            mRectSprite.alpha = Math.min(mRectSprite.alpha,mAlpha);
         }
         else if(mFramesElapsed >= mDuration - mTransitionDuration)
         {
            mRectSprite.alpha -= mOffset * _loc2_;
            mRectSprite.alpha = Math.max(mRectSprite.alpha,0);
         }
         if(mFramesElapsed > mDuration)
         {
            ResetFade();
            return;
         }
      }

      function ResetFade()
      {
         mFramesElapsed = 0;
         mFacade.sceneGraphManager.removeChild(mRectSprite);
         var _loc1_:ASAny;
         final __ax4_iter_204 = mExcludes;
         if (checkNullIteratee(__ax4_iter_204)) for (_tmp_ in __ax4_iter_204)
         {
            _loc1_ = _tmp_;
            mFacade.sceneGraphManager.addChild(ASCompat.dynamicAs(_loc1_, flash.display.DisplayObject),20);
         }
         mExcludes = null;
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


