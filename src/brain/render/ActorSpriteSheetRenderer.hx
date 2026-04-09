package brain.render
;
   import brain.assetRepository.SpriteSheetAsset;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import brain.workLoop.WorkComponent;
   
    class ActorSpriteSheetRenderer extends SpriteSheetRenderer implements IRenderer
   {
      
      public static var SPRITE_SHEET_RENDERER_TYPE:String = "SpriteSheetRenderer";
      
      var mFrameRate:Float = 24;
      
      var mPlayRate:Float = 1;
      
      var mDuration:Float = 0;
      
      var mFrameTimes:Vector<Float>;
      
      var mLoop:Bool = true;
      
      var mIsPlaying:Bool = false;
      
      var mAnimationFrame:UInt = (0 : UInt);
      
      var mPlayHead:Float = 0;
      
      var mHeading:Float = 0;
      
      public function new(param1:WorkComponent, param2:SpriteSheetAsset, param3:String)
      {
         super(param1,param2);
         mBitmap.name = "ActorSpriteSheetRenderer_" + param3;
         mFrameTimes = param2.timingVector;
         if((mFrameTimes.length : UInt) != param2.numFramesX)
         {
            throw new Error("Warning: frameTimes vector length and sheet numFramesX must match");
         }
         mDuration = 0;
         var _loc4_:Float;
         final __ax4_iter_132 = mFrameTimes;
         if (checkNullIteratee(__ax4_iter_132)) for (_tmp_ in __ax4_iter_132)
         {
            _loc4_ = _tmp_;
            mDuration += _loc4_ / 1000;
         }
         MemoryTracker.track(this,"ActorSpriteSheetRenderer name=" + param3 + " - created in ActorSpriteSheetRenderer()","brain");
      }
      
            
      @:isVar public var playRate(get,set):Float;
public function  get_playRate() : Float
      {
         return mPlayRate;
      }
      
      @:isVar public var rendererType(get,never):String;
public function  get_rendererType() : String
      {
         return SPRITE_SHEET_RENDERER_TYPE;
      }
function  set_playRate(param1:Float) :Float      {
         return mPlayRate = param1;
      }
      
      override public function destroy() 
      {
         super.destroy();
      }
      
      @:isVar public var durationInSeconds(get,never):Float;
public function  get_durationInSeconds() : Float
      {
         return mDuration / mPlayRate;
      }
      
      @:isVar public var frameCount(get,never):Float;
public function  get_frameCount() : Float
      {
         return mFrameTimes.length;
      }
      
      override public function  get_loop() : Bool
      {
         return mLoop;
      }
      
      @:isVar public var frameRate(get,never):UInt;
public function  get_frameRate() : UInt
      {
         return (Std.int(mFrameRate) : UInt);
      }
      
      function getFrameFromTime(param1:Float) : UInt
      {
         var _loc3_= (0 : UInt);
         var _loc4_:Float = 0;
         var _loc2_:Float;
         final __ax4_iter_133 = mFrameTimes;
         if (checkNullIteratee(__ax4_iter_133)) for (_tmp_ in __ax4_iter_133)
         {
            _loc2_ = _tmp_;
            _loc4_ += _loc2_ / 1000 / mPlayRate;
            if(_loc4_ > param1)
            {
               break;
            }
            _loc3_++;
         }
         return _loc3_;
      }
      
      function getTimeFromFrame(param1:UInt) : Float
      {
         var _loc3_= 0;
         var _loc2_:Int = param1;
         if(param1 >= (mFrameTimes.length : UInt))
         {
            Logger.warn("Trying to set animation to frame: " + param1 + ", but mFrameTimes only has length of: " + mFrameTimes.length);
            _loc2_ = mFrameTimes.length;
         }
         var _loc4_:Float = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ += mFrameTimes[_loc3_] / 1000 / mPlayRate;
            _loc3_++;
         }
         return _loc4_;
      }
      
      function getAnimationIndexFromClock(param1:GameClock) : UInt
      {
         mPlayHead += param1.tickLength;
         if(!mLoop && mPlayHead >= this.durationInSeconds)
         {
            stop();
            return this.mSpriteSheet.numFramesX - 1;
         }
         mPlayHead %= this.durationInSeconds;
         mAnimationFrame = this.getFrameFromTime(mPlayHead);
         return mAnimationFrame;
      }
      
      @:isVar public var isPlaying(get,never):Bool;
public function  get_isPlaying() : Bool
      {
         return mIsPlaying;
      }
      
      override public function play(param1:UInt = (0 : UInt), param2:Bool = true, param3:ASFunction = null) 
      {
         mIsPlaying = true;
         mAnimationFrame = param1;
         mPlayHead = this.getTimeFromFrame(param1);
         mLoop = param2;
         super.play(param1,param2,param3);
         if(mIsPlaying && mBitmap.stage != null && mOnFrameTask == null)
         {
            this.onAdd();
         }
      }
      
      override public function stop() 
      {
         super.stop();
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
            mOnFrameTask = null;
         }
         mIsPlaying = false;
      }
      
      override function onFrame(param1:GameClock) 
      {
         var _loc3_= 0;
         var _loc5_= 0;
         var _loc4_= 0;
         var _loc2_= 0;
         if(mIsPlaying && mBitmap.stage != null)
         {
            _loc3_ = (getAnimationIndexFromClock(param1) : Int);
            _loc5_ = (getDirectionIndexFromHeading(mHeading) : Int);
            _loc4_ = (mXIndex : Int);
            _loc2_ = (mYIndex : Int);
            setFrameIndexes((_loc3_ : UInt),(_loc5_ : UInt));
            if(mXIndex != (_loc4_ : UInt) || mYIndex != (_loc2_ : UInt))
            {
               super.onFrame(param1);
            }
         }
      }
      
      override public function  set_heading(param1:Float) :Float      {
         while(param1 < -180)
         {
            param1 += 360;
         }
         while(param1 > 180)
         {
            param1 -= 360;
         }
         return mHeading = param1;
      }
      
      public override function  get_heading() : Float
      {
         return mHeading;
      }
      
      public function getDirectionIndexFromHeading(param1:Float) : UInt
      {
         if(param1 > 90)
         {
            param1 = -param1 + 180;
         }
         else if(param1 < -90)
         {
            param1 = -param1 - 180;
         }
         switch(mSpriteSheet.numFramesY - 1)
         {
            case 0:
               return (0 : UInt);
            case 1:
               if(180 >= param1 && param1 >= 0)
               {
                  return (1 : UInt);
               }
               if(0 >= param1 && param1 >= -180)
               {
                  return (0 : UInt);
               }
               throw new Error("unknown heading:",ASCompat.toInt(param1));
               
            case 2:
               if(90 >= param1 && param1 >= 60)
               {
                  return (0 : UInt);
               }
               if(60 >= param1 && param1 >= 0)
               {
                  return (2 : UInt);
               }
               if(0 >= param1 && param1 >= -90)
               {
                  return (1 : UInt);
               }
               throw new Error("unknown heading:",ASCompat.toInt(param1));
               
            case 4:
               if(120 >= param1 && param1 >= 60)
               {
                  return (4 : UInt);
               }
               if(60 >= param1 && param1 >= 30)
               {
                  return (3 : UInt);
               }
               if(30 >= param1 && param1 >= -30)
               {
                  return (2 : UInt);
               }
               if(-30 >= param1 && param1 >= -60)
               {
                  return (1 : UInt);
               }
               if(-60 >= param1 && param1 >= -120)
               {
                  return (0 : UInt);
               }
               throw new Error("unknown heading:",ASCompat.toInt(param1));
               
            default:
               throw new Error("unsupported numFramesY: " + Std.string(mSpriteSheet.numFramesY));
         }
return 0;
      }
      
      override public function setFrame(param1:UInt) 
      {
         var _loc2_:Int = getDirectionIndexFromHeading(this.heading);
         setFrameIndexes(param1,(_loc2_ : UInt));
         updateToCurrentFrame();
      }
   }


