package uI
;
   import brain.clock.GameClock;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
    class CountdownTextTimer
   {
      
      public static inline final millisecondsPerMinute= 60000;
      
      public static inline final millisecondsPerHour= 3600000;
      
      public static inline final millisecondsPerDay= 86400000;
      
      var mCountdownText:TextField;
      
      var mDateToFinish:Date;
      
      var mGetDateFunction:ASFunction;
      
      var mOnFinishFunc:ASFunction;
      
      var mPostfixText:String;
      
      var mPrefixText:String;
      
      var mExpireText:String;
      
      var mTimer:Timer;
      
      public function new(param1:TextField, param2:Date, param3:ASFunction = null, param4:ASFunction = null, param5:String = "", param6:String = "", param7:String = "")
      {
         
         mCountdownText = param1;
         mDateToFinish = param2;
         mGetDateFunction = param3;
         mOnFinishFunc = param4;
         mPostfixText = param5;
         mPrefixText = param6;
         mExpireText = param7;
         if(mGetDateFunction == null)
         {
            mGetDateFunction = getNow;
         }
      }
      
      public function destroy() 
      {
         stop();
         mCountdownText = null;
         mDateToFinish = null;
         mGetDateFunction = null;
         mOnFinishFunc = null;
         mPostfixText = null;
         mPrefixText = null;
         mExpireText = null;
      }
      
      public function start() 
      {
         mTimer = new Timer(1000);
         mTimer.addEventListener("timer",onTick);
         mTimer.start();
         onTick(null);
      }
      
      public function stop() 
      {
         if(mTimer != null)
         {
            mTimer.removeEventListener("timer",onTick);
            mTimer.stop();
            mTimer = null;
         }
      }
      
      function getNow() : Date
      {
         return GameClock.getWebServerDate();
      }
      
      function getTimeLeft() : Int
      {
         var _loc1_= ASCompat.dynamicAs(mGetDateFunction(), Date);
         return Std.int(mDateToFinish.getTime()- _loc1_.getTime());
      }
      
      function onTick(param1:TimerEvent) 
      {
         var _loc5_= 0;
         var _loc2_= 0;
         var _loc4_= 0;
         var _loc3_= 0;
         if(getTimeLeft() <= 0)
         {
            mCountdownText.text = mExpireText;
            if(mOnFinishFunc != null)
            {
               mOnFinishFunc();
            }
         }
         else
         {
            _loc5_ = getTimeLeft();
            _loc2_ = Std.int(_loc5_ / 3600000);
            _loc5_ -= _loc2_ * 3600000;
            _loc4_ = Std.int(_loc5_ / 60000);
            _loc5_ -= _loc4_ * 60000;
            _loc3_ = Std.int(_loc5_ / 1000);
            mCountdownText.text = mPrefixText + Std.string(_loc2_) + ":" + zeroPad(_loc4_,2) + ":" + zeroPad(_loc3_,2) + mPostfixText;
         }
      }
      
      public function zeroPad(param1:Int, param2:Int) : String
      {
         var _loc3_= "" + param1;
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
   }


