package brain.uI
;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UIProgressBar extends UIObject
   {
      
      static inline final LERP_DELAY:Float = 2;
      
      static inline final LERP_SPEED:Float = 0.125;
      
      var mErrorMessage:MovieClip;
      
      var mErrorMessageLabel:TextField;
      
      var mMaximum:Float = 1;
      
      var mMinimum:Float = 0;
      
      var mValue:Float  = Math.NaN;
      
      var mDeltaValue:Float  = Math.NaN;
      
      var mTrueValue:Float  = Math.NaN;
      
      public var bar:MovieClip;
      
      var mDeltaBar:MovieClip;
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mLerpTask:Task;
      
      var mTimerTask:Task;
      
      public function new(param1:Facade, param2:MovieClip, param3:MovieClip = null)
      {
         super(param1,param2);
         mValue = mMinimum;
         mDeltaValue = mMinimum;
         mTrueValue = mMinimum;
         bar = ASCompat.dynamicAs(ASCompat.toBool((param2 : ASAny).bar) ? ASCompat.dynamicAs((param2 : ASAny).bar, flash.display.MovieClip) : param2, flash.display.MovieClip);
         if(param3 != null)
         {
            mDeltaBar = ASCompat.dynamicAs(ASCompat.toBool((param3 : ASAny).bar) ? ASCompat.dynamicAs((param3 : ASAny).bar, flash.display.MovieClip) : param3, flash.display.MovieClip);
            mDeltaBar.alpha = 0.3;
         }
         mWorkComponent = new LogicalWorkComponent(param1,"UIProgressBar");
         MemoryTracker.track(mWorkComponent,"LogicalWorkComponent - created in UIProgressBar()","brain");
         update();
      }
      
      function update() 
      {
         bar.scaleX = (mValue - mMinimum) / (mMaximum - mMinimum);
         if(mDeltaBar != null)
         {
            mDeltaBar.scaleX = (mDeltaValue - mMinimum) / (mMaximum - mMinimum);
         }
      }
      
            
      @:isVar public var maximum(get,set):Float;
public function  set_maximum(param1:Float) :Float      {
         mMaximum = param1;
         mValue = Math.min(mValue,mMaximum);
         update();
return param1;
      }
function  get_maximum() : Float
      {
         return mMaximum;
      }
      
      @:isVar public var minimum(never,set):Float;
public function  set_minimum(param1:Float) :Float      {
         mMinimum = param1;
         mValue = Math.max(mValue,mMinimum);
         update();
return param1;
      }
      
      @:isVar public var mimimum(get,never):Float;
public function  get_mimimum() : Float
      {
         return mMinimum;
      }
      
      function updateLerp(param1:GameClock) 
      {
         var _loc2_= Math.NaN;
         var _loc3_= false;
         if(mTrueValue > mValue)
         {
            _loc2_ = 1 - (mTrueValue - mValue) * 0.125;
            mValue += 1 - _loc2_ * _loc2_;
            if(mTrueValue - mValue < 0.05)
            {
               _loc3_ = true;
            }
         }
         if(mTrueValue < mDeltaValue)
         {
            _loc2_ = 1 - (mTrueValue - mDeltaValue) * 0.125;
            mDeltaValue += 1 - _loc2_ * _loc2_;
            if(mDeltaValue - mTrueValue >= 0.05)
            {
               _loc3_ = false;
            }
         }
         if(_loc3_)
         {
            mDeltaValue = mValue = mTrueValue;
            mLerpTask.destroy();
            mLerpTask = null;
         }
         update();
      }
      
      function startLerp(param1:GameClock) 
      {
         if(mLerpTask == null)
         {
            mLerpTask = mWorkComponent.doEveryFrame(updateLerp);
         }
         mTimerTask.destroy();
         mTimerTask = null;
      }
      
            
      @:isVar public var value(get,set):Float;
public function  set_value(param1:Float) :Float      {
         var _loc2_= Math.max(mMinimum,Math.min(param1,mMaximum));
         if(mDeltaBar != null)
         {
            mTrueValue = _loc2_;
            if(mTrueValue > mValue)
            {
               mDeltaValue = Math.max(mDeltaValue,mTrueValue);
            }
            else
            {
               mValue = mTrueValue;
            }
            if(mLerpTask == null)
            {
               if(mTimerTask == null)
               {
                  mTimerTask = mWorkComponent.doLater(2,startLerp);
               }
            }
         }
         else
         {
            mValue = _loc2_;
         }
         update();
return param1;
      }
function  get_value() : Float
      {
         return mValue;
      }
      
      override public function destroy() 
      {
         if(mWorkComponent != null)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         super.destroy();
      }
      
      public function displayErrorMessage(param1:String) 
      {
         mErrorMessage = new MovieClip();
         MemoryTracker.track(mErrorMessage,"MovieClip - error message container created in UIProgressBar.displayErrorMessage()","brain");
         mFacade.sceneGraphManager.addChild(mErrorMessage,Std.int(mTooltipLayer));
         mErrorMessageLabel = new TextField();
         MemoryTracker.track(mErrorMessageLabel,"TextField - error label created in UIProgressBar.displayErrorMessage()","brain");
         mErrorMessageLabel.x = 320;
         mErrorMessageLabel.y = 100;
         mErrorMessageLabel.text = param1;
         mErrorMessageLabel.autoSize = "center";
         mErrorMessageLabel.background = true;
         mErrorMessageLabel.backgroundColor = (16711680 : UInt);
         mErrorMessageLabel.textColor = (0 : UInt);
         mErrorMessage.addChild(mErrorMessageLabel);
      }
   }


