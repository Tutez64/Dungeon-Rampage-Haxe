package actor
;
   import facade.DBFacade;
   import com.greensock.TimelineMax;
   import com.greensock.TweenMax;
   import com.greensock.easing.Quint;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Vector3D;
   
    class FloatingMessage
   {
      
      public static inline final DAMAGE_MOVEMENT_TYPE= "DAMAGE_MOVEMENT_TYPE";
      
      public static inline final BUFF_DAMAGE_MOVEMENT_TYPE= "BUFF_DAMAGE_MOVEMENT_TYPE";
      
      static final DEFAULT_DIRECTION:Vector3D = new Vector3D(0,-1,0);
      
      var mDBFacade:DBFacade;
      
      var mRoot:DisplayObject;
      
      var mScaleDampening:Float = Math.NaN;
      
      var mFinishedCallback:ASFunction;
      
      var mFloatSpeed:Float = Math.NaN;
      
      var mFloatDirection:Vector3D;
      
      var mTotalDuration:UInt = 0;
      
      var mHoldDuration:UInt = 0;
      
      var mTimelineMax:TimelineMax;
      
      var mStartPosition:Vector3D;
      
      var mResetPositionAtEnd:Bool = false;
      
      public function new(param1:DisplayObject, param2:DBFacade, param3:UInt, param4:UInt, param5:Float, param6:Float, param7:Vector3D = null, param8:ASFunction = null, param9:String = "DAMAGE_MOVEMENT_TYPE", param10:Bool = false)
      {
         
         mDBFacade = param2;
         mRoot = param1;
         if(Std.isOfType(mRoot , DisplayObjectContainer))
         {
            cast(mRoot, DisplayObjectContainer).mouseChildren = false;
            cast(mRoot, DisplayObjectContainer).mouseEnabled = false;
         }
         mFinishedCallback = param8;
         mHoldDuration = param3;
         mTotalDuration = param4;
         mScaleDampening = param5;
         mFloatSpeed = param6;
         mFloatDirection = param7 != null ? param7 : DEFAULT_DIRECTION;
         mResetPositionAtEnd = param10;
         if(mResetPositionAtEnd)
         {
            mStartPosition = new Vector3D(param1.x,param1.y);
         }
         if(param9 == "BUFF_DAMAGE_MOVEMENT_TYPE")
         {
            buffFloaterTween();
         }
         else
         {
            damageFloaterTween();
         }
      }
      
      function damageFloaterTween() 
      {
         var dt= brain.clock.GameClock.ANIMATION_FRAME_DURATION;
         var distance= mFloatSpeed * mTotalDuration * dt;
         var toX= mRoot.x + mFloatDirection.x * distance;
         var toY= mRoot.y + mFloatDirection.y * distance;
         var toScaleX= mRoot.scaleX * mScaleDampening;
         var toScaleY= mRoot.scaleY * mScaleDampening;
         mTimelineMax = new TimelineMax({
            "tweens":[TweenMax.to(mRoot,mTotalDuration * 0.8 * dt,{
               "delay":mHoldDuration * dt,
               "x":toX,
               "y":toY,
               "scaleX":toScaleX,
               "scaleY":toScaleY,
               "ease":Quint.easeOut
            }),TweenMax.to(mRoot,mTotalDuration * 0.2 * dt,{"alpha":0})],
            "align":"sequence",
            "onComplete":function()
            {
               if(mFinishedCallback != null)
               {
                  mFinishedCallback();
                  mFinishedCallback = null;
               }
               destroy();
            }
         });
      }
      
      function buffFloaterTween() 
      {
         var dt= brain.clock.GameClock.ANIMATION_FRAME_DURATION;
         var distance= mFloatSpeed * mTotalDuration * dt * 2;
         var toX= mRoot.x + mFloatDirection.x * distance;
         var maxY= mRoot.y + mFloatDirection.y * distance * 0.5;
         var minY= maxY - mFloatDirection.y * distance * 0.7;
         var toScaleX= mRoot.scaleX * mScaleDampening;
         var toScaleY= mRoot.scaleY * mScaleDampening;
         var maxYTime= mTotalDuration * dt * 0.1;
         var minYTime= mTotalDuration * dt * 0.7;
         mTimelineMax = new TimelineMax({
            "tweens":[TweenMax.to(mRoot,mTotalDuration * dt,{
               "x":toX,
               "scaleX":toScaleX,
               "scaleY":toScaleY
            }),TweenMax.to(mRoot,mTotalDuration * 0.3 * dt,{
               "delay":mTotalDuration * 0.7 * dt,
               "alpha":0
            }),TweenMax.to(mRoot,maxYTime,{
               "y":maxY,
               "ease":Quint.easeOut
            }),TweenMax.to(mRoot,minYTime,{
               "delay":maxYTime,
               "y":minY,
               "ease":Quint.easeIn
            })],
            "align":"normal",
            "onComplete":function()
            {
               if(mFinishedCallback != null)
               {
                  mFinishedCallback();
                  mFinishedCallback = null;
               }
               destroy();
            }
         });
      }
      
      public function destroy() 
      {
         if(mResetPositionAtEnd && mRoot != null)
         {
            mRoot.x = mStartPosition.x;
            mRoot.y = mStartPosition.y;
         }
         if(mFinishedCallback != null)
         {
            mFinishedCallback();
            mFinishedCallback = null;
         }
         mRoot = null;
         mDBFacade = null;
         if(mTimelineMax != null)
         {
            mTimelineMax.kill();
            mTimelineMax = null;
         }
      }
   }


