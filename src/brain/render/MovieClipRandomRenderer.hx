package brain.render
;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import flash.display.MovieClip;
   import org.as3commons.collections.Map;
   
    class MovieClipRandomRenderer extends MovieClipRenderer
   {
      
      static inline final RANDOM_SUBSTRING_LABEL= "random";
      
      var mRandomLabels:Map = new Map();
      
      var mCurrentRandomLabel:RandomLabelObject;
      
      public function new(param1:Facade, param2:MovieClip, param3:ASFunction = null)
      {
         super(param1,param2,param3);
      }
      
      override public function destroy() 
      {
         mRandomLabels.clear();
         mCurrentRandomLabel = null;
         super.destroy();
      }
      
      override public function onFrame(param1:GameClock) 
      {
         if(mClip == null)
         {
            return;
         }
         mIsPlaying = true;
         if(mClip.stage == null)
         {
            Logger.warn("Animating MovieClipRenderer that is not on stage");
         }
         if(!mIsPlaying)
         {
            return;
         }
         mPlayHead += mFrameRate * param1.tickLength * mPlayRate;
         if(mPlayHead >= mCurrentRandomLabel.endFrameNumber)
         {
            playNewRandomLabel();
         }
         this.updateClip(mClip);
      }
      
      function playNewRandomLabel() 
      {
         var _loc2_= mRandomLabels.keysToArray();
         var _loc1_= Math.ffloor(Math.random() * _loc2_.length);
         mCurrentRandomLabel = ASCompat.dynamicAs(mRandomLabels.itemFor(_loc2_[Std.int(_loc1_)]), RandomLabelObject);
         mPlayHead = mCurrentRandomLabel.startFrameNumber;
      }
      
      override function determineFrames(param1:MovieClip) 
      {
         var _loc2_:RandomLabelObject = null;
         var _loc3_= 0;
         if(param1.currentLabels.length > 0)
         {
            _loc3_ = 1;
            while(_loc3_ <= param1.totalFrames)
            {
               param1.gotoAndStop(_loc3_);
               if(ASCompat.stringAsBool(param1.currentFrameLabel) && param1.currentFrameLabel.indexOf("random") >= 0)
               {
                  if(_loc2_ != null && _loc2_.endFrameNumber == 0)
                  {
                     _loc2_.endFrameNumber = (ASCompat.toInt(_loc3_ - 1) : UInt);
                  }
                  _loc2_ = new RandomLabelObject();
                  _loc2_.startFrameNumber = (_loc3_ : UInt);
                  _loc2_.labelName = param1.currentFrameLabel;
                  mRandomLabels.add(param1.currentFrameLabel,_loc2_);
               }
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
            if(_loc2_ != null && _loc2_.endFrameNumber == 0)
            {
               _loc2_.endFrameNumber = (ASCompat.toInt(_loc3_ - 1) : UInt);
            }
         }
         playNewRandomLabel();
      }
   }


private class RandomLabelObject
{
   
   public var labelName:String;
   
   public var startFrameNumber:UInt = 0;
   
   public var endFrameNumber:UInt = 0;
   
   public function new()
   {
      
   }
}
