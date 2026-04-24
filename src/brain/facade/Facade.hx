package brain.facade
;
   import brain.assetRepository.AssetRepository;
   import brain.camera.BackgroundFader;
   import brain.camera.Camera;
   import brain.camera.LetterboxEffect;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.event.EventManager;
   import brain.gameObject.GameObjectManager;
   import brain.input.InputManager;
   import brain.logger.Logger;
   import brain.mouseCursor.MouseCursorManager;
   import brain.sceneGraph.SceneGraphManager;
   import brain.sound.SoundManager;
   import brain.utils.FeatureFlags;
   import brain.workLoop.WorkLoopManager;
   import brain.jsonRPC.JSONRPCService;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import org.as3commons.collections.Map;
   
    class Facade
   {
      
      public static inline final MAX_TICKS_PER_FRAME= 5;
      
      public static inline final FPS= (120 : UInt);
      
      var mElapsedTime:Float = 0;
      
      var mStageRef:Stage;
      
      var mSwfWidth:Float = Math.NaN;
      
      var mSwfHeight:Float = Math.NaN;
      
      var mSceneGraphManager:SceneGraphManager;
      
      var mInputManager:InputManager;
      
      var mRealClockWorkManager:WorkLoopManager;
      
      var mLogicalWorkManager:WorkLoopManager;
      
      var mPhysicsWorkManager:WorkLoopManager;
      
      var mPreRenderWorkManager:WorkLoopManager;
      
      var mLayerRenderWorkManager:WorkLoopManager;
      
      var mGameObjectManager:GameObjectManager;
      
      var mEventManager:EventManager;
      
      var mSoundManager:SoundManager;
      
      var mCamera:Camera;
      
      var mAssetRepository:AssetRepository;
      
      var mMouseCursorManager:MouseCursorManager;
      
      var mGameClock:GameClock;
      
      var mRealClock:GameClock;
      
      public var featureFlags:FeatureFlags;
      
      var mEventComponent:EventComponent;
      
      public var cacheVersion:String = "";
      
      public var versions:ASObject = null;
      
      public var environmentPrefix:String = "u";
      
      var mAssetRepositoryClass:Dynamic = AssetRepository;
      
      var mWantConsole:Bool = false;
      
      var mWantFramerateEnforcement:Bool = false;
      
      var mFrameTimes:Vector<Int>;
      
      var mCurrentTime:Float = 0;
      
      var mSkippingFrame:Bool = false;
      
      var mSkippedFrames:Int = 0;
      
      var mCheaterLogMap:Map;
      
      var mWallClockTimeElapsed:Float = 0;
      
      var mGameClockTimeElapsed:Float = 0;
      
      var mTickCounter:Int = 0;
      
      var mCheatCount:Int = 0;
      
      var mTickLength:Float = -1;
      
      var mInitialLoginTraceId:String;
      
      var mSessionInfoString:String = "Loading...";
      
      var mChildLayer:ASDictionary<ASAny,ASAny> = new ASDictionary(true);
      
      public function new()
      {
         
         mFrameTimes = new Vector<Int>();
         mCheaterLogMap = new Map();
      }
      
      public function fileVersion(param1:String) : String
      {
         if(versions == null)
         {
            return cacheVersion;
         }
         var _loc2_= param1.indexOf("../../..") == 0 ? param1.substr(8) : param1;
         return versions[_loc2_] == null ? cacheVersion : versions[_loc2_];
      }
      
      @:isVar public var stageRef(get,never):Stage;
public function  get_stageRef() : Stage
      {
         return mStageRef;
      }
      
      @:isVar public var viewWidth(get,never):Float;
public function  get_viewWidth() : Float
      {
         return mStageRef.scaleMode == "noScale" ? mStageRef.stageWidth : mSwfWidth;
      }
      
      @:isVar public var viewHeight(get,never):Float;
public function  get_viewHeight() : Float
      {
         return mStageRef.scaleMode == "noScale" ? mStageRef.stageHeight : mSwfHeight;
      }
      
      public function addRootDisplayObject(param1:DisplayObject, param2:Float = 0) : DisplayObject
      {
         var _loc3_:DisplayObject = null;
         var _loc4_= Math.NaN;
         var _loc5_:Float = mStageRef.numChildren - 1;
         while(_loc5_ >= 0)
         {
            _loc3_ = mStageRef.getChildAt(Std.int(_loc5_));
            _loc4_ = ASCompat.toNumber(mChildLayer.exists(_loc3_ ) ? mChildLayer[_loc3_] : 0);
            if(param2 >= _loc4_)
            {
               break;
            }
            _loc5_--;
         }
         mChildLayer[param1] = param2;
         return mStageRef.addChildAt(param1,Std.int(_loc5_ + 1));
      }
      
      public function removeRootDisplayObject(param1:DisplayObject) : DisplayObject
      {
         mChildLayer.remove(param1);
         return mStageRef.removeChild(param1);
      }
      
      @:isVar public var camera(get,never):Camera;
public function  get_camera() : Camera
      {
         return mCamera;
      }
      
      @:isVar public var popupCurtainBlockMouse(get,never):Bool;
public function  get_popupCurtainBlockMouse() : Bool
      {
         return true;
      }
      
      public function buildEngines() 
      {
         mSceneGraphManager = new SceneGraphManager(this);
         mGameObjectManager = new GameObjectManager(this);
         mInputManager = new InputManager(this);
         mSoundManager = new SoundManager(this);
         mMouseCursorManager = new MouseCursorManager(this);
      }
      
      public function mainLoop(param1:Event) 
      {
         var _loc6_= Math.NaN;
         var _loc7_= Math.NaN;
         if(mTickLength == -1)
         {
            mTickLength = mGameClock.tickLength;
         }
         var _loc9_= mGameClock.update();
         mElapsedTime += _loc9_;
         var _loc3_= (0 : UInt);
         mRealClock.update();
         mRealClock.gameTime = mRealClock.realTime;
         mRealClockWorkManager.update(mRealClock);
         var _loc5_= false;
         mSkippingFrame = false;
         var _loc2_= mCurrentTime;
         mCurrentTime = Date.now().getTime();
         var _loc4_= Std.int(mCurrentTime - _loc2_);
         _loc4_ = Std.int(Math.max(0,_loc4_));
         mWallClockTimeElapsed += _loc4_;
         mGameClockTimeElapsed += _loc9_;
         if(mWallClockTimeElapsed > 1000)
         {
            _loc6_ = mGameClockTimeElapsed * 1000;
            _loc7_ = _loc6_ / mWallClockTimeElapsed;
            if(_loc7_ > 1.1)
            {
               mTickLength = mGameClock.tickLength * _loc7_;
               mCheatCount = mCheatCount + 1;
               if(mCheatCount > 60)
               {
                  iamaCheater("testing_speed_hack_definite");
               }
               else if(mCheatCount > 3)
               {
                  iamaCheater("testing_speed_hack_probable");
               }
            }
            else
            {
               mTickLength = mGameClock.tickLength;
               mCheatCount = 0;
            }
            mGameClockTimeElapsed = 0;
            mWallClockTimeElapsed = 0;
         }
         var _loc8_:Float = -1;
         while(mElapsedTime >= mTickLength && _loc3_ < 5)
         {
            mTickCounter = mTickCounter + 1;
            mLogicalWorkManager.update(mGameClock);
            mPhysicsWorkManager.update(mGameClock);
            mPreRenderWorkManager.update(mGameClock);
            flushInputs();
            mElapsedTime -= mTickLength;
            mGameClock.gameTime += Std.int(mTickLength * 1000);
            _loc3_++;
         }
         mLayerRenderWorkManager.update(mRealClock);
         if(_loc3_ >= 5)
         {
            mElapsedTime = 0;
         }
      }
      
      function flushInputs() 
      {
         mInputManager.flush();
      }
      
      public function iamaCheater(param1:String) 
      {
         if(!mCheaterLogMap.hasKey(param1))
         {
            mCheaterLogMap.add(param1,true);
            logCheater(param1);
         }
      }
      
      public function logCheater(param1:String) 
      {
      }
      
      @:isVar public var skippingFrame(get,never):Bool;
public function  get_skippingFrame() : Bool
      {
         return mSkippingFrame;
      }
      
      public function init(param1:Stage) 
      {
         mStageRef = param1;
         mSwfWidth = mStageRef.stageWidth;
         mSwfHeight = mStageRef.stageHeight;
         Logger.init(mStageRef,true);
         mGameClock = new GameClock(1 / FPS);
         mRealClock = new GameClock(1 / param1.frameRate);
         mEventManager = new EventManager(this);
         mAssetRepository = ASCompat.dynamicAs(ASCompat.createInstance(mAssetRepositoryClass, [this]), brain.assetRepository.AssetRepository);
         featureFlags = new FeatureFlags();
         mRealClockWorkManager = new WorkLoopManager(mRealClock);
         mLogicalWorkManager = new WorkLoopManager(mGameClock);
         mPhysicsWorkManager = new WorkLoopManager(mGameClock);
         mPreRenderWorkManager = new WorkLoopManager(mGameClock);
         mLayerRenderWorkManager = new WorkLoopManager(mGameClock);
         mCamera = new Camera(this,new BackgroundFader(this),new LetterboxEffect(this));
         mEventComponent = new EventComponent(this);
      }
      
      public function run() 
      {
         mEventComponent.addListener("enterFrame",this.mainLoop);
      }
      
      @:isVar public var inputManager(get,never):InputManager;
public function  get_inputManager() : InputManager
      {
         return mInputManager;
      }
      
      @:isVar public var gameClock(get,never):GameClock;
public function  get_gameClock() : GameClock
      {
         return mGameClock;
      }
      
      @:isVar public var realClock(get,never):GameClock;
public function  get_realClock() : GameClock
      {
         return mRealClock;
      }
      
            
      @:isVar public var initialLoginTraceId(get,set):String;
public function  get_initialLoginTraceId() : String
      {
         return mInitialLoginTraceId;
      }
function  set_initialLoginTraceId(param1:String) :String      {
         mInitialLoginTraceId = param1;
         JSONRPCService.initialLoginTraceId = param1;
         displaySessionId();
return param1;
      }
      
      @:isVar public var sessionInfoString(get,never):String;
public function  get_sessionInfoString() : String
      {
         return mSessionInfoString;
      }
      
      public function displaySessionId() 
      {
         var _loc2_:Array<ASAny> = null;
         var _loc4_= "";
         if(mInitialLoginTraceId == null || mInitialLoginTraceId == "")
         {
            _loc4_ = "Loading...";
         }
         else
         {
            _loc2_ = (cast mInitialLoginTraceId.split("-"));
            if(_loc2_.length >= 2)
            {
               _loc4_ = Std.string(_loc2_[1]).substr(-16);
            }
            else
            {
               _loc4_ = mInitialLoginTraceId;
            }
         }
         mSessionInfoString = environmentPrefix + ":" + _loc4_;
         var _loc1_= new TextField();
         _loc1_.text = mSessionInfoString;
         _loc1_.selectable = false;
         _loc1_.autoSize = "left";
         _loc1_.y = -2;
         var _loc3_= new TextFormat();
         _loc3_.bold = true;
         _loc3_.font = "Verdana";
         _loc3_.color = 15660015;
         _loc3_.size = 18;
         _loc1_.setTextFormat(_loc3_);
         _loc1_.alpha = 0.65;
         _loc1_.cacheAsBitmap = true;
         _loc1_.name = "SessionIdTextField";
         addRootDisplayObject(_loc1_,1002);
      }
      
      @:isVar public var eventManager(get,never):EventManager;
public function  get_eventManager() : EventManager
      {
         return mEventManager;
      }
      
      @:isVar public var gameObjectManager(get,never):GameObjectManager;
public function  get_gameObjectManager() : GameObjectManager
      {
         return mGameObjectManager;
      }
      
      @:isVar public var sceneGraphManager(get,never):SceneGraphManager;
public function  get_sceneGraphManager() : SceneGraphManager
      {
         return mSceneGraphManager;
      }
      
      @:isVar public var logicalWorkManager(get,never):WorkLoopManager;
public function  get_logicalWorkManager() : WorkLoopManager
      {
         return mLogicalWorkManager;
      }
      
      @:isVar public var realClockWorkManager(get,never):WorkLoopManager;
public function  get_realClockWorkManager() : WorkLoopManager
      {
         return mRealClockWorkManager;
      }
      
      @:isVar public var preRenderWorkManager(get,never):WorkLoopManager;
public function  get_preRenderWorkManager() : WorkLoopManager
      {
         return mPreRenderWorkManager;
      }
      
      @:isVar public var physicsWorkManager(get,never):WorkLoopManager;
public function  get_physicsWorkManager() : WorkLoopManager
      {
         return mPhysicsWorkManager;
      }
      
      @:isVar public var layerRenderWorkManager(get,never):WorkLoopManager;
public function  get_layerRenderWorkManager() : WorkLoopManager
      {
         return mLayerRenderWorkManager;
      }
      
      @:isVar public var assetRepository(get,never):AssetRepository;
public function  get_assetRepository() : AssetRepository
      {
         return mAssetRepository;
      }
      
      @:isVar public var soundManager(get,never):SoundManager;
public function  get_soundManager() : SoundManager
      {
         return mSoundManager;
      }
      
      @:isVar public var mouseCursorManager(get,never):MouseCursorManager;
public function  get_mouseCursorManager() : MouseCursorManager
      {
         return mMouseCursorManager;
      }
      
      public function getWorldCoordinateFromMouse() : Vector3D
      {
         return camera.getWorldCoordinateFromMouse(inputManager.mouseX,inputManager.mouseY);
      }
   }


