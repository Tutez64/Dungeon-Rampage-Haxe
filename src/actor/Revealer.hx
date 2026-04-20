package actor
;
   import brain.clock.GameClock;
   import brain.workLoop.LogicalWorkComponent;
   import facade.DBFacade;
   import flash.display.DisplayObject;
   
    class Revealer
   {
      
      public static inline final REVEAL_POP= (0 : UInt);
      
      public static inline final REVEAL_SMOOTH= (1 : UInt);
      
      var mDBFacade:DBFacade;
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mRoot:DisplayObject;
      
      var mFinishedCallback:ASFunction;
      
      var mStartFrame:UInt = 0;
      
      var mDuration:UInt = 0;
      
      var mTargetScale:Float = Math.NaN;
      
      var mRevealType:UInt = 0;
      
      public function new(param1:DisplayObject, param2:DBFacade, param3:UInt, param4:ASFunction = null, param5:UInt = (0 : UInt))
      {
         
         mDBFacade = param2;
         mRoot = param1;
         mFinishedCallback = param4;
         mDuration = param3;
         mStartFrame = param2.gameClock.frame;
         mTargetScale = param1.scaleX;
         mRevealType = param5;
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"Revealer");
         mWorkComponent.doEveryFrame(update);
      }
      
      function update(param1:GameClock) 
      {
         var _loc4_= Math.NaN;
         var _loc2_= Math.NaN;
         var _loc3_= Math.NaN;
         var _loc5_= (param1.frame - mStartFrame : UInt);
         if(_loc5_ > mDuration)
         {
            mRoot.alpha = 1;
            mRoot.scaleX = mRoot.scaleY = mTargetScale;
            mWorkComponent.destroy();
            if(mFinishedCallback != null)
            {
               mFinishedCallback();
               mFinishedCallback = null;
            }
         }
         else
         {
            _loc4_ = _loc5_ / mDuration;
            if(mRevealType == 0)
            {
               mRoot.alpha = 1 - Math.pow(_loc4_,2);
            }
            else
            {
               mRoot.alpha = Math.pow(_loc4_,4);
            }
            _loc2_ = mDuration;
            _loc3_ = mDuration;
            if(mRevealType == 0)
            {
               mRoot.scaleX = mRoot.scaleY = 1 - ((_loc5_ + _loc3_) / (_loc2_ + _loc3_) - _loc3_ / (_loc2_ + _loc3_));
            }
            else
            {
               mRoot.scaleX = mRoot.scaleY = ((_loc5_ + _loc3_) / (_loc2_ + _loc3_) - _loc3_ / (_loc2_ + _loc3_)) * mTargetScale;
            }
         }
      }
      
      public function destroy() 
      {
         if(mRoot != null)
         {
            mRoot.scaleX = mRoot.scaleY = mTargetScale;
         }
         mWorkComponent.destroy();
         if(mFinishedCallback != null)
         {
            mFinishedCallback();
            mFinishedCallback = null;
         }
         mDBFacade = null;
         mRoot = null;
      }
   }


