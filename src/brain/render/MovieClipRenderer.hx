package brain.render
;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   
    class MovieClipRenderer
   {
      
      static inline final LOOP_LABEL= "loop";
      
      static inline final NO_LOOP_LABEL= "noloop";
      
      var mFrameRate:Float = 24;
      
      var mPlayRate:Float = 1;
      
      var mLoop:Bool = true;
      
      var mPlayHead:Float = 1;
      
      var mStartFrame:UInt = (1 : UInt);
      
      var mMaxFrames:UInt = 0;
      
      var mClip:MovieClip;
      
      var mOnFrameTask:Task;
      
      var mFinishedCallback:ASFunction;
      
      var mIsPlaying:Bool = false;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      public function new(param1:Facade, param2:MovieClip, param3:ASFunction = null, param4:String = null)
      {
         
         this.clip = param2;
         mFinishedCallback = param3;
         if(mMaxFrames > 1)
         {
            mLogicalWorkComponent = new LogicalWorkComponent(param1,"MovieClipRenderer");
            if(mClip.stage != null)
            {
               onAdd();
            }
            mClip.addEventListener("addedToStage",onAdd);
            mClip.addEventListener("removedFromStage",onRemove);
         }
      }
      
      public function setFrame(param1:UInt) 
      {
         mPlayHead = param1;
         this.updateClip(mClip);
      }
      
      @:isVar public var currentFrame(get,never):UInt;
public function  get_currentFrame() : UInt
      {
         return (Std.int(Math.fround(mPlayHead % mMaxFrames) + 1) : UInt);
      }
      
      public function play(param1:UInt = (0 : UInt), param2:Bool = false, param3:ASFunction = null) 
      {
         if(param3 != null)
         {
            mFinishedCallback = param3;
         }
         if(mMaxFrames <= 1)
         {
            mClip.gotoAndStop(1);
         }
         else
         {
            mPlayHead = param1;
            mLoop = param2;
            mIsPlaying = true;
            mMaxFrames = initialize(mClip);
            this.updateClip(mClip);
            if(mClip.stage != null)
            {
               onAdd();
            }
         }
      }
      
      @:isVar public var finishedCallback(never,set):ASFunction;
public function  set_finishedCallback(param1:ASFunction) :ASFunction      {
         return mFinishedCallback = param1;
      }
      
      public function stop() 
      {
         mIsPlaying = false;
      }
      
      public function destroy() 
      {
         if(mClip != null)
         {
            mClip.removeEventListener("addedToStage",onAdd);
            mClip.removeEventListener("removedFromStage",onRemove);
         }
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
            mOnFrameTask = null;
         }
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
         mClip = null;
         mFinishedCallback = null;
      }
      
      function onAdd(param1:Event = null) 
      {
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
         }
         mOnFrameTask = mLogicalWorkComponent.doEveryFrame(onFrame);
      }
      
      function onRemove(param1:Event = null) 
      {
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
            mOnFrameTask = null;
         }
      }
      
            
      @:isVar public var playRate(get,set):Float;
public function  get_playRate() : Float
      {
         return mPlayRate;
      }
function  set_playRate(param1:Float) :Float      {
         return mPlayRate = param1;
      }
      
            
      @:isVar public var frameRate(get,set):Float;
public function  get_frameRate() : Float
      {
         return mFrameRate;
      }
function  set_frameRate(param1:Float) :Float      {
         mFrameRate = frameRate;
return param1;
      }
      
      @:isVar public var startFrame(never,set):UInt;
public function  set_startFrame(param1:UInt) :UInt      {
         return mStartFrame = param1;
      }
      
            
      @:isVar public var loop(get,set):Bool;
public function  get_loop() : Bool
      {
         return mLoop;
      }
function  set_loop(param1:Bool) :Bool      {
         return mLoop = param1;
      }
      
      public function onFrame(param1:GameClock) 
      {
         if(mClip == null)
         {
            return;
         }
         if(mClip.stage == null)
         {
            Logger.warn("Animating MovieClipRenderer that is not on stage");
         }
         if(!mIsPlaying)
         {
            return;
         }
         mPlayHead += mFrameRate * param1.tickLength * mPlayRate;
         if(mPlayHead > mMaxFrames - 1 && !mLoop)
         {
            mIsPlaying = false;
            mPlayHead = mMaxFrames - 1;
            this.updateClip(mClip);
            if(mOnFrameTask != null)
            {
               mOnFrameTask.destroy();
               mOnFrameTask = null;
            }
            mIsPlaying = false;
            if(mFinishedCallback != null)
            {
               mFinishedCallback();
            }
            return;
         }
         this.updateClip(mClip);
      }
      
            
      @:isVar public var clip(get,set):MovieClip;
public function  set_clip(param1:MovieClip) :MovieClip      {
         if(param1 == mClip)
         {
            return param1;
         }
         mClip = param1;
         mPlayHead = mStartFrame;
         mMaxFrames = initialize(mClip);
         this.updateClip(mClip);
return param1;
      }
function  get_clip() : MovieClip
      {
         return mClip;
      }
      
      @:isVar public var numFrames(get,never):UInt;
public function  get_numFrames() : UInt
      {
         if(mClip == null)
         {
            return (0 : UInt);
         }
         return mMaxFrames;
      }
      
      function updateClip(param1:DisplayObjectContainer) 
      {
         var _loc5_:MovieClip = null;
         var _loc4_:DisplayObject = null;
         var _loc7_:DisplayObjectContainer = null;
         var _loc2_:MovieClip = null;
         var _loc3_:Float = 0;
         var _loc6_:Float = 0;
         var _loc8_= 0;
         _loc5_ = ASCompat.reinterpretAs(param1 , MovieClip);
         if(_loc5_ != null && _loc5_.totalFrames > 1)
         {
            if(ASCompat.toNumberField((_loc5_ : ASAny), "MCR_firstLoopFrame") > 0)
            {
               if(ASCompat.toBool((_loc5_ : ASAny).MCR_playedIntro))
               {
                  _loc3_ = _loc5_.totalFrames - ASCompat.toNumberField((_loc5_ : ASAny), "MCR_firstLoopFrame") + 1;
                  _loc6_ = Math.fround(ASCompat.toNumber(ASCompat.toNumber(ASCompat.toNumber(mPlayHead - ASCompat.toNumberField((_loc5_ : ASAny), "MCR_firstLoopFrame")) - 1) % _loc3_)) + (_loc5_ : ASAny).MCR_firstLoopFrame;
               }
               else
               {
                  _loc6_ = Math.fround(mPlayHead % _loc5_.totalFrames) + 1;
                  if(mPlayHead >= _loc5_.totalFrames)
                  {
                     ASCompat.setProperty(_loc5_, "MCR_playedIntro", true);
                  }
               }
            }
            else
            {
               _loc6_ = Math.fround(mPlayHead % _loc5_.totalFrames) + 1;
            }
            _loc5_.gotoAndStop(_loc6_);
         }
         _loc8_ = 0;
         while(_loc8_ < param1.numChildren)
         {
            try
            {
               _loc4_ = param1.getChildAt(_loc8_);
               _loc7_ = ASCompat.reinterpretAs(_loc4_ , DisplayObjectContainer);
               if(_loc7_ != null && _loc7_.numChildren != 0)
               {
                  updateClip(_loc7_);
               }
               else
               {
                  _loc2_ = ASCompat.reinterpretAs(_loc4_ , MovieClip);
                  if(_loc2_ != null && _loc2_.totalFrames > 1)
                  {
                     updateClip(_loc2_);
                  }
               }
            }
            catch(error:Dynamic)
            {
            }
            _loc8_++;
         }
      }
      
      @:isVar public var duration(get,never):Float;
public function  get_duration() : Float
      {
         if(mClip == null)
         {
            return 0;
         }
         return mMaxFrames / this.frameRate / this.playRate;
      }
      
      @:isVar public var isPlaying(get,never):Bool;
public function  get_isPlaying() : Bool
      {
         return mIsPlaying;
      }
      
      function initialize(param1:DisplayObjectContainer, param2:UInt = (0 : UInt), param3:String = "") : UInt
      {
         var _loc7_:DisplayObject = null;
         var _loc4_:MovieClip = null;
         var _loc5_:DisplayObjectContainer = null;
         var _loc6_= 0;
         _loc4_ = ASCompat.reinterpretAs(param1 , MovieClip);
         if(_loc4_ != null)
         {
            param2 = (Std.int(Math.max(param2,_loc4_.totalFrames)) : UInt);
            this.determineFrames(_loc4_);
         }
         _loc6_ = 0;
         while(_loc6_ < param1.numChildren)
         {
            try
            {
               _loc7_ = param1.getChildAt(_loc6_);
               _loc5_ = ASCompat.reinterpretAs(_loc7_ , DisplayObjectContainer);
               if(_loc5_ != null && _loc5_.numChildren != 0)
               {
                  param2 = (Std.int(Math.max(param2,initialize(_loc5_,param2,param3 + "    "))) : UInt);
               }
               else if(Std.isOfType(_loc7_ , MovieClip))
               {
                  param2 = (Std.int(Math.max(param2,cast(_loc7_, MovieClip).totalFrames)) : UInt);
               }
            }
            catch(error:Dynamic)
            {
            }
            _loc6_++;
         }
         return param2;
      }
      
      function determineFrames(param1:MovieClip) 
      {
         var _loc2_= -1;
         var _loc3_:FrameLabel;
         final __ax4_iter_140 = param1.currentLabels;
         if (checkNullIteratee(__ax4_iter_140)) for (_tmp_ in __ax4_iter_140)
         {
            _loc3_ = _tmp_;
            if(_loc3_.name == "loop")
            {
               _loc2_ = ASCompat.toInt(_loc3_.frame);
               mLoop = true;
               break;
            }
            if(_loc3_.name == "noloop")
            {
               mLoop = false;
               break;
            }
         }
         ASCompat.setProperty(param1, "MCR_firstLoopFrame", _loc2_);
         ASCompat.setProperty(param1, "MCR_playedIntro", false);
      }
   }


