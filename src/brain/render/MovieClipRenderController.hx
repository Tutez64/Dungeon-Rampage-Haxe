package brain.render
;
   import brain.facade.Facade;
   import brain.utils.IPoolable;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   
    class MovieClipRenderController implements IPoolable
   {
      
      var mClip:MovieClip;
      
      var mFacade:Facade;
      
      var mRenderer:MovieClipRenderer;
      
      var mStartScaleX:Float = Math.NaN;
      
      var mStartScaleY:Float = Math.NaN;
      
      public var swfPath:String = "";
      
      public var className:String = "";
      
      public function new(param1:Facade, param2:MovieClip, param3:ASFunction = null, param4:String = null)
      {
         
         mFacade = param1;
         mClip = param2;
         mStartScaleX = mClip.scaleX;
         mStartScaleY = mClip.scaleY;
         determineRenderer(param3,param4);
      }
      
      public function postCheckout(param1:Bool) 
      {
         if(!param1)
         {
            mClip.scaleX = mStartScaleX;
            mClip.scaleY = mStartScaleY;
         }
      }
      
      public function postCheckin() 
      {
         this.stop();
         if(mClip.parent != null)
         {
            mClip.parent.removeChild(mClip);
         }
      }
      
      public function getPoolKey() : String
      {
         return swfPath + ":" + className;
      }
      
      function determineRenderer(param1:ASFunction, param2:String = null) 
      {
         var _loc3_:FrameLabel;
         final __ax4_iter_143 = mClip.currentLabels;
         if (checkNullIteratee(__ax4_iter_143)) for (_tmp_ in __ax4_iter_143)
         {
            _loc3_ = _tmp_;
            if(ASCompat.toNumber(_loc3_.name.indexOf("random")) >= 0)
            {
               mRenderer = new MovieClipRandomRenderer(mFacade,mClip,param1,param2);
               return;
            }
            if(_loc3_.name == "pause")
            {
               mRenderer = new MovieClipCutsceneRenderer(mFacade,mClip,param1,param2);
               return;
            }
         }
         mRenderer = new MovieClipRenderer(mFacade,mClip,param1,param2);
      }
      
      public function destroy() 
      {
         if(mRenderer != null)
         {
            mRenderer.destroy();
         }
         mRenderer = null;
         mFacade = null;
         mClip = null;
      }
      
      public function stop() 
      {
         mRenderer.stop();
      }
      
      public function play(param1:UInt = (0 : UInt), param2:Bool = false, param3:ASFunction = null) 
      {
         mRenderer.play(param1,param2,param3);
      }
      
      @:isVar public var finishedCallback(never,set):ASFunction;
public function  set_finishedCallback(param1:ASFunction) :ASFunction      {
         return mRenderer.finishedCallback = param1;
      }
      
      public function setFrame(param1:UInt) 
      {
         mRenderer.setFrame(param1);
      }
      
      @:isVar public var currentFrame(get,never):UInt;
public function  get_currentFrame() : UInt
      {
         return mRenderer.currentFrame;
      }
      
      @:isVar public var clip(get,never):MovieClip;
public function  get_clip() : MovieClip
      {
         return mRenderer.clip;
      }
      
      @:isVar public var durationInSeconds(get,never):Float;
public function  get_durationInSeconds() : Float
      {
         return mRenderer.duration;
      }
      
      @:isVar public var frameCount(get,never):Float;
public function  get_frameCount() : Float
      {
         return mRenderer.numFrames;
      }
      
      @:isVar public var isPlaying(get,never):Bool;
public function  get_isPlaying() : Bool
      {
         return mRenderer.isPlaying;
      }
      
      @:isVar public var frameRate(never,set):Float;
public function  set_frameRate(param1:Float) :Float      {
         return mRenderer.frameRate = param1;
      }
      
      @:isVar public var startFrame(never,set):UInt;
public function  set_startFrame(param1:UInt) :UInt      {
         return mRenderer.startFrame = param1;
      }
      
            
      @:isVar public var loop(get,set):Bool;
public function  get_loop() : Bool
      {
         return mRenderer.loop;
      }
function  set_loop(param1:Bool) :Bool      {
         return mRenderer.loop = param1;
      }
      
            
      @:isVar public var playRate(get,set):Float;
public function  get_playRate() : Float
      {
         return mRenderer.playRate;
      }
function  set_playRate(param1:Float) :Float      {
         return mRenderer.playRate = param1;
      }
   }


