package actor
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import brain.render.ActorSpriteSheetRenderer;
   import brain.render.IRenderer;
   import brain.workLoop.PreRenderWorkComponent;
   import distributedObjects.NPCGameObject;
   import facade.DBFacade;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class ActorRenderer extends Sprite
   {
      
      public static inline final IDLE_ANIM_NAME= "idle";
      
      public static inline final RUN_ANIM_NAME= "run";
      
      public static inline final SUFFER_ANIM_NAME= "suffer";
      
      public static inline final DEATH_ANIM_NAME= "death";
      
      public static final mStandardAnimList:Array<ASAny> = ["idle","death"];
      
      var mDBFacade:DBFacade;
      
      var mAnims:Map;
      
      var mLoadingAnims:Map;
      
      var mTriggerState:Bool = false;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      var mCurrentRenderer:IRenderer;
      
      var mActorGameObject:ActorGameObject;
      
      var mHeading:Float = 0;
      
      var mAnimName:String;
      
      var mLoop:Bool = false;
      
      var mPreloadSprites:Bool = false;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:Bool)
      {
         super();
         this.name = "ActorRenderer";
         mActorGameObject = param2;
         mDBFacade = param1;
         mTriggerState = param3;
         mAnims = new Map();
         mLoadingAnims = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade);
         mPreloadSprites = mDBFacade.dbConfigManager.getConfigBoolean("preload_sprites",false);
      }
      
      public static function cache_loadSpriteSheetAsset(param1:DBFacade, param2:String, param3:UInt, param4:UInt, param5:String, param6:Vector<String>) 
      {
         var dbFacade= param1;
         var spriteSheetSwfPath= param2;
         var spriteHeight= param3;
         var spriteWidth= param4;
         var assetType= param5;
         var weaponsNamesIn= param6;
         var trash_AssetLoadingComponent= new AssetLoadingComponent(dbFacade);
         if(ASCompat.stringAsBool(assetType))
         {
            trash_AssetLoadingComponent.getSwfAsset(spriteSheetSwfPath,function(param1:SwfAsset)
            {
            });
         }
         else
         {
            trash_AssetLoadingComponent.getSwfAsset(spriteSheetSwfPath,function(param1:SwfAsset)
            {
            });
         }
      }
      
      @:isVar public var rendererType(get,never):String;
public function  get_rendererType() : String
      {
         if(mCurrentRenderer == null)
         {
            return "null";
         }
         return mCurrentRenderer.rendererType;
      }
      
      public function destroy() 
      {
         var _loc1_:IRenderer = null;
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         var _loc2_= ASCompat.reinterpretAs(mAnims.iterator() , IMapIterator);
         while(_loc2_.hasNext())
         {
            _loc1_ = ASCompat.dynamicAs(_loc2_.next(), brain.render.IRenderer);
            _loc1_.destroy();
         }
         mAnims.clear();
         mAnims = null;
         mLoadingAnims.clear();
         mLoadingAnims = null;
         mAssetLoadingComponent.destroy();
         mPreRenderWorkComponent.destroy();
         mActorGameObject = null;
         mDBFacade = null;
         mCurrentRenderer = null;
      }
      
      @:isVar var swfFilePath(get,never):String;
function  get_swfFilePath() : String
      {
         return mActorGameObject.actorData.getSwfFilePath();
      }
      
      @:isVar var movieClipClassName(get,never):String;
function  get_movieClipClassName() : String
      {
         if(mTriggerState)
         {
            return mActorGameObject.actorData.getMovieClipClassName();
         }
         return mActorGameObject.actorData.getOffMovieClipClassName();
      }
      
      @:isVar var spriteWidth(get,never):Float;
function  get_spriteWidth() : Float
      {
         return mActorGameObject.actorData.spriteWidth;
      }
      
      @:isVar var spriteHeight(get,never):Float;
function  get_spriteHeight() : Float
      {
         return mActorGameObject.actorData.spriteHeight;
      }
      
      @:isVar var assetType(get,never):String;
function  get_assetType() : String
      {
         return mActorGameObject.actorData.assetType;
      }
      
      function getSpriteSheetClassName(param1:String) : String
      {
         if(mTriggerState || mActorGameObject.actorData.isMover)
         {
            return mActorGameObject.actorData.getSpriteSheetClassName(param1);
         }
         return mActorGameObject.actorData.getOffSpriteSheetClassName(param1);
      }
      
      function loadMovieClipAssets() 
      {
         var swfPath= this.swfFilePath;
         var className= movieClipClassName;
         this.mAssetLoadingComponent.getSwfAsset(swfPath,function(param1:SwfAsset)
         {
            movieClipSwfLoaded(className,param1);
         });
      }
      
      function movieClipSwfLoaded(param1:String, param2:SwfAsset) 
      {
         var _loc8_:ActorMovieClipRenderer = null;
         var _loc6_:MovieClip = null;
         if(!ASCompat.stringAsBool(param1))
         {
            return;
         }
         var _loc12_= param1;
         var _loc7_= param1 + "_" + "run";
         var _loc3_= param1 + "_" + "suffer";
         var _loc9_= param1 + "_" + "death";
         var _loc4_= param2.getClass(_loc12_,false);
         var _loc10_= param2.getClass(_loc7_,true);
         var _loc5_= param2.getClass(_loc3_,true);
         var _loc11_= param2.getClass(_loc9_,true);
         if(_loc4_ != null)
         {
            _loc6_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
            _loc8_ = new ActorMovieClipRenderer(mDBFacade,_loc6_);
            setAnimInDictionary("idle",_loc8_);
            movieClipRendererLoaded(_loc6_);
         }
         if(_loc10_ != null)
         {
            _loc8_ = new ActorMovieClipRenderer(mDBFacade,ASCompat.dynamicAs(ASCompat.createInstance(_loc10_, []), flash.display.MovieClip));
            setAnimInDictionary("run",_loc8_);
         }
         if(_loc5_ != null)
         {
            _loc8_ = new ActorMovieClipRenderer(mDBFacade,ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip));
            setAnimInDictionary("suffer",_loc8_);
         }
         if(_loc11_ != null)
         {
            _loc8_ = new ActorMovieClipRenderer(mDBFacade,ASCompat.dynamicAs(ASCompat.createInstance(_loc11_, []), flash.display.MovieClip));
            setAnimInDictionary("death",_loc8_);
         }
      }
      
      function movieClipRendererLoaded(param1:MovieClip) 
      {
      }
      
      function loadErrorCallback() 
      {
         Logger.error("loadAnimatedSpriteSheetRenderer error");
      }
      
      @:isVar public var currentAnimName(get,never):String;
public function  get_currentAnimName() : String
      {
         return mAnimName;
      }
      
      function setAnimInDictionary(param1:String, param2:IRenderer) 
      {
         mAnims.add(param1,param2);
         if(mAnimName == param1)
         {
            this.play(mAnimName,0,true,mLoop);
         }
      }
      
      public function hasAnim(param1:String) : Bool
      {
         var _loc2_= this.getRenderer(param1);
         return _loc2_ != null;
      }
      
      public function getAnimDurationInSeconds(param1:String) : Float
      {
         var _loc2_= ASCompat.dynamicAs(mAnims.itemFor(param1), brain.render.IRenderer);
         return _loc2_ != null ? _loc2_.durationInSeconds : 0;
      }
      
      public function getAnimFrameCount(param1:String) : Float
      {
         var _loc2_= ASCompat.dynamicAs(mAnims.itemFor(param1), brain.render.IRenderer);
         return _loc2_ != null ? _loc2_.frameCount : 0;
      }
      
      public function loadAssets() 
      {
         do {
                  switch(this.assetType)
         {
            case "SPRITE_SHEET":
               this.y = ActorView.BODY_Y_OFFSET;
               if(mPreloadSprites)
               {
                  loadSpriteSheetAssets();
                  break;
               }
               preloadStandardSpriteSheetAssets();
               
            case "MOVIE_CLIP":
               loadMovieClipAssets();
               
            default:
               Logger.error("Unknown assetType: " + this.assetType);
         }
         } while (false);
      }
      
      function loadSpriteSheetAsset(param1:String) 
      {
         var spriteSheetSwfPath:String;
         var shClassName:String;
         var animName= param1;
         if(mAnims.hasKey(animName))
         {
            return;
         }
         if(ASCompat.toBool(mLoadingAnims.itemFor(animName)))
         {
            return;
         }
         mLoadingAnims.add(animName,true);
         spriteSheetSwfPath = this.swfFilePath;
         shClassName = getSpriteSheetClassName(animName);
         mAssetLoadingComponent.getSpriteSheetAsset(spriteSheetSwfPath,shClassName,function(param1:brain.assetRepository.SpriteSheetAsset)
         {
            var _loc2_= new ActorSpriteSheetRenderer(mPreRenderWorkComponent,param1,mActorGameObject.actorData.constant);
            setAnimInDictionary(animName,_loc2_);
         },loadErrorCallback,true,null,shClassName);
      }
      
      function preloadStandardSpriteSheetAssets() 
      {
         var _loc1_:ASAny;
         final __ax4_iter_23 = mStandardAnimList;
         if (checkNullIteratee(__ax4_iter_23)) for (_tmp_ in __ax4_iter_23)
         {
            _loc1_ = _tmp_;
            loadSpriteSheetAsset(_loc1_);
         }
      }
      
      function loadSpriteSheetAssets() 
      {
         preloadStandardSpriteSheetAssets();
      }
      
      function getRenderer(param1:String) : IRenderer
      {
         var _loc2_= ASCompat.dynamicAs(mAnims.itemFor(param1), brain.render.IRenderer);
         if(_loc2_ == null && this.assetType == "SPRITE_SHEET")
         {
            loadSpriteSheetAsset(param1);
         }
         return _loc2_;
      }
      
      public function forceFrame(param1:Int) 
      {
         if(mCurrentRenderer != null)
         {
            mCurrentRenderer.setFrame((param1 : UInt));
         }
      }
      
      public function setFrame(param1:String, param2:Int) 
      {
         stop();
         var _loc3_= this.getRenderer(param1);
         if(_loc3_ != null)
         {
            mCurrentRenderer = _loc3_;
            this.heading = mHeading;
            this.addChild(mCurrentRenderer.displayObject);
            mCurrentRenderer.setFrame((param2 : UInt));
         }
      }
      
      public function play(param1:String, param2:Int = 0, param3:Bool = false, param4:Bool = true, param5:Float = 1) 
      {
         mAnimName = param1;
         mLoop = param4;
         var _loc6_= this.getRenderer(param1);
         if(_loc6_ != null)
         {
            _loc6_.playRate = param5;
            if(mCurrentRenderer == _loc6_)
            {
               if(param3)
               {
                  _loc6_.play((param2 : UInt),mLoop);
               }
            }
            else
            {
               stop();
               mAnimName = param1;
               mLoop = param4;
               mCurrentRenderer = _loc6_;
               this.heading = mHeading;
               _loc6_.play((param2 : UInt),mLoop);
               this.addChild(mCurrentRenderer.displayObject);
            }
         }
      }
      
      @:isVar public var heading(never,set):Float;
public function  set_heading(param1:Float) :Float      {
         var _loc2_:NPCGameObject = null;
         var _loc3_= false;
         mHeading = param1;
         if(mCurrentRenderer != null)
         {
            mCurrentRenderer.heading = param1;
            _loc2_ = ASCompat.reinterpretAs(mActorGameObject , NPCGameObject);
            if(_loc2_ != null && _loc2_.gmNpc.UseFlashRotation)
            {
               if(_loc2_.flip != 0)
               {
                  mCurrentRenderer.displayObject.rotation = -mHeading + 180;
               }
               else
               {
                  mCurrentRenderer.displayObject.rotation = mHeading;
               }
            }
            if(Std.isOfType(mCurrentRenderer , ActorSpriteSheetRenderer))
            {
               _loc3_ = 90 > mHeading && mHeading > -90;
               this.scaleX = _loc3_ ? 1 : -1;
            }
         }
return param1;
      }
      
      @:isVar public var currentFrame(get,never):Int;
public function  get_currentFrame() : Int
      {
         if(mCurrentRenderer != null)
         {
            return (mCurrentRenderer.currentFrame : Int);
         }
         return 0;
      }
      
      @:isVar public var loop(get,never):Bool;
public function  get_loop() : Bool
      {
         return mLoop;
      }
      
      public function stop() 
      {
         if(mCurrentRenderer != null)
         {
            mCurrentRenderer.stop();
            if(this.contains(mCurrentRenderer.displayObject))
            {
               this.removeChild(mCurrentRenderer.displayObject);
            }
            mCurrentRenderer = null;
            mLoop = false;
            mAnimName = null;
         }
      }
   }


