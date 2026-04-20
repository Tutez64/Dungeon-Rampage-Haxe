package distributedObjects
;
   import actor.ActorGameObject;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.gameObject.GameObject;
   import brain.logger.Logger;
   import brain.sound.SoundHandle;
   import brain.utils.MemoryTracker;
   import doobers.DooberGameObject;
   import dungeon.DungeonFloorFactory;
   import dungeon.RectangleNavCollider;
   import dungeon.Tile;
   import dungeon.TileGrid;
   import effects.EffectManager;
   import events.ActorLifetimeEvent;
   import facade.DBFacade;
   import dr_floor.FloorMessageView;
   import dr_floor.FloorObject;
   import gameMasterDictionary.GMColiseumTier;
   import gameMasterDictionary.GMMapNode;
   import generatedCode.DistributedDungeonFloorNetworkComponent;
   import generatedCode.DungeonTileUsage;
   import generatedCode.IDistributedDungeonFloor;
   import pathfinding.Astar;
   import sound.DBSoundComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.net.URLRequest;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.IMapIterator;
   import org.as3commons.collections.framework.ISetIterator;
   
    class DistributedDungeonFloor extends Floor implements IDistributedDungeonFloor
   {
      
      static inline final MUSIC_BUFFER:Float = 1000;
      
      var mTileNetworkComponents:Vector<DungeonTileUsage>;
      
      var mTileLibraryPath:String = "uninitialized";
      
      var mDungeonFloorFactory:DungeonFloorFactory;
      
      var mTileGrid:TileGrid;
      
      public var astarGrids:Astar = new Astar();
      
      var mActiveOwnerAvatar:HeroGameObjectOwner;
      
      var mRemoteHeroes:Map;
      
      var mRemoteActors:Map;
      
      var mDoobers:ASDictionary<ASAny,ASAny>;
      
      var mBuildPropReady:Bool = false;
      
      var mPostGenerate:Bool = false;
      
      var mFloorObjectsAwaitingDungeonFloor:Set;
      
      var mColiseumTierConstant:String;
      
      var mCurrentMapNodeId:UInt = 0;
      
      var mMapNode:GMMapNode;
      
      var mEffectManager:EffectManager;
      
      var mBaseLining:UInt = 0;
      
      var mIntroMovieSwfFilePath:String;
      
      var mIntroMovieAssetClassName:String;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mCurrentFloorNum:UInt = 0;
      
      var mDBSoundComponent:DBSoundComponent;
      
      var mMusicTestSoundHandle:SoundHandle;
      
      var mBgMusic:Sound;
      
      public function new(param1:DBFacade, param2:UInt)
      {
         Logger.debug("New  DistributedDungeonFloor******************************");
         mPostGenerate = false;
         super(param1,param2);
         mRemoteHeroes = new Map();
         mRemoteActors = new Map();
         mDoobers = new ASDictionary<ASAny,ASAny>(true);
         mFloorObjectsAwaitingDungeonFloor = new Set();
         mEffectManager = new EffectManager(mDBFacade);
         MemoryTracker.track(mEffectManager,"EffectManager - created in DistributedDungeonFloor.constructor()");
         mBaseLining = (0 : UInt);
         mDBSoundComponent = new DBSoundComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
      }
      
      @:isVar public var coliseumTierConstant(never,set):String;
public function  set_coliseumTierConstant(param1:String) :String      {
         return mColiseumTierConstant = param1;
      }
      
      @:isVar public var mapNodeId(never,set):UInt;
public function  set_mapNodeId(param1:UInt) :UInt      {
         return mCurrentMapNodeId = param1;
      }
      
      override public function  get_isInfiniteDungeon() : Bool
      {
         return mMapNode.IsInfiniteDungeon;
      }
      
      public function getActor(param1:UInt) : ActorGameObject
      {
         if(mActiveOwnerAvatar != null && mActiveOwnerAvatar.id == param1)
         {
            return mActiveOwnerAvatar;
         }
         var _loc2_= ASCompat.dynamicAs(mRemoteActors.itemFor(param1), actor.ActorGameObject);
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         _loc2_ = ASCompat.dynamicAs(mRemoteHeroes.itemFor(param1), actor.ActorGameObject);
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         return null;
      }
      
      @:isVar public var effectManager(get,never):EffectManager;
public function  get_effectManager() : EffectManager
      {
         return mEffectManager;
      }
      
      @:isVar public var numHeroes(get,never):UInt;
public function  get_numHeroes() : UInt
      {
         return 1 + mRemoteHeroes.size;
      }
      
            
      @:isVar public var remoteHeroes(get,set):Map;
public function  get_remoteHeroes() : Map
      {
         return mRemoteHeroes;
      }
      
      @:isVar public var remoteActors(get,never):Map;
public function  get_remoteActors() : Map
      {
         return mRemoteActors;
      }
function  set_remoteHeroes(param1:Map) :Map      {
         return mRemoteHeroes = param1;
      }
      
            
      @:isVar public var activeOwnerAvatar(get,set):HeroGameObjectOwner;
public function  get_activeOwnerAvatar() : HeroGameObjectOwner
      {
         return mActiveOwnerAvatar;
      }
function  set_activeOwnerAvatar(param1:HeroGameObjectOwner) :HeroGameObjectOwner      {
         return mActiveOwnerAvatar = param1;
      }
      
      override public function getCurrentFloorNum() : UInt
      {
         return mCurrentFloorNum % 1000 + 1;
      }
      
      override public function getMaxFloorNum() : UInt
      {
         return (Std.int(mCurrentFloorNum / 1000) : UInt);
      }
      
      @:isVar public var tileGrid(get,never):TileGrid;
public function  get_tileGrid() : TileGrid
      {
         return mTileGrid;
      }
      
      public function setNetworkComponentDistributedDungeonFloor(param1:DistributedDungeonFloorNetworkComponent) 
      {
      }
      
      @:isVar public var dungeonFloorFactory(get,never):DungeonFloorFactory;
public function  get_dungeonFloorFactory() : DungeonFloorFactory
      {
         return mDungeonFloorFactory;
      }
      
      public function postGenerate() 
      {
         mPostGenerate = true;
         mDungeonFloorFactory = new DungeonFloorFactory(this,initGridCallback,mDBFacade,mTileLibraryPath);
         MemoryTracker.track(mDungeonFloorFactory,"DungeonFloorFactory - created in DistributedDungeonFloor.postGenerate()");
         astarGrids.Init(this);
         mDungeonFloorFactory.buildDungeonFloor(mTileNetworkComponents,finishedBuildingTiles);
         mMapNode = mDBFacade.gameMaster.getMapNode(mCurrentMapNodeId);
         this.playIntroMovie();
         this.playMusic();
         buildFloorEndingGui();
      }
      
      override public function victory() 
      {
         logDungeonCompletion();
         super.victory();
         if(mDBFacade.steamAchievementsManager != null)
         {
            mDBFacade.steamAchievementsManager.unlockFloorCompleted(mMapNode.Constant);
         }
      }
      
      override public function defeat() 
      {
         logDungeonCompletion();
         var _loc1_= getCurrentFloorNum();
         if(mDBFacade.steamAchievementsManager != null)
         {
            mDBFacade.steamAchievementsManager.setHighestFloorAchieved(mMapNode,_loc1_);
         }
         super.defeat();
      }
      
      function formatHeroInfo(param1:HeroGameObject) : String
      {
         return "\"" + param1.screenName + "\" AccountId=" + param1.playerID + " Avatar=\"" + param1.gMHero.Name + "\" Skin=\"" + param1.gmSkin.Name + "\"";
      }
      
      function formatFellowPlayers(param1:String) : String
      {
         if(mRemoteHeroes.size == 0)
         {
            return "";
         }
         var _loc2_= param1;
         var _loc3_= mRemoteHeroes.iterator();
         var _loc4_= true;
         while(ASCompat.toBool(_loc3_.hasNext()))
         {
            if(!_loc4_)
            {
               _loc2_ += ", ";
            }
            _loc2_ += formatHeroInfo(ASCompat.dynamicAs(_loc3_.next() , HeroGameObject));
            _loc4_ = false;
         }
         return _loc2_;
      }
      
      function getFloorString() : String
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mMapNode.TierRank), gameMasterDictionary.GMColiseumTier);
         return "floor " + getCurrentFloorNum() + "/" + _loc1_.TotalFloors;
      }
      
      function logWelcomeMessage() 
      {
         if(mActiveOwnerAvatar == null || mMapNode == null)
         {
            return;
         }
         Logger.debugch("PlayerInfo","Welcome (" + mActiveOwnerAvatar.playerID + ") to the dungeon \"" + mMapNode.Name + "\" (" + mCurrentMapNodeId + ") " + getFloorString() + " SessionId=" + mDBFacade.sessionInfoString);
      }
      
      function logPlayerJoined(param1:HeroGameObject) 
      {
         Logger.debugch("PlayerInfo",formatHeroInfo(param1) + " joined floor " + getCurrentFloorNum() + ".");
      }
      
      function logPlayerLeft(param1:HeroGameObject) 
      {
         if(!isAlive())
         {
            return;
         }
         Logger.debugch("PlayerInfo",formatHeroInfo(param1) + " left floor " + getCurrentFloorNum() + ".");
      }
      
      function logDungeonCompletion() 
      {
         if(mActiveOwnerAvatar == null || mMapNode == null)
         {
            return;
         }
         Logger.debugch("PlayerInfo","You (" + mActiveOwnerAvatar.playerID + ") finished the dungeon \"" + mMapNode.Name + "\" (" + mCurrentMapNodeId + ") " + getFloorString() + " SessionId=" + mDBFacade.sessionInfoString + formatFellowPlayers(", you were playing with "));
      }
      
      function playMusic() 
      {
         var _loc3_:URLRequest = null;
         var _loc2_:SoundLoaderContext = null;
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant), gameMasterDictionary.GMColiseumTier);
         if(_loc1_ != null && ASCompat.stringAsBool(_loc1_.MusicFilepath))
         {
            mBgMusic = new Sound();
            _loc3_ = new URLRequest(DBFacade.buildFullDownloadPath(_loc1_.MusicFilepath));
            _loc2_ = new SoundLoaderContext(1000,true);
            _loc2_.checkPolicyFile = true;
            mBgMusic.load(_loc3_,_loc2_);
            mBgMusic.addEventListener("complete",onBgMusicLoaded);
            mBgMusic.addEventListener("ioError",onBgMusicError);
            mBgMusic.addEventListener("securityError",onBgMusicError);
         }
      }
      
      function onBgMusicLoaded(param1:Event) 
      {
         if(mDBSoundComponent != null)
         {
            mDBSoundComponent.playStreamingMusic(mBgMusic);
         }
      }
      
      function onBgMusicError(param1:Event) 
      {
         Logger.error("BgMusic load error: " + param1.toString());
      }
      
      @:isVar public var coliseumTier(get,never):GMColiseumTier;
public function  get_coliseumTier() : GMColiseumTier
      {
         return ASCompat.dynamicAs(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant), gameMasterDictionary.GMColiseumTier);
      }
      
      @:isVar public var completionXp(get,never):UInt;
public function  get_completionXp() : UInt
      {
         return mMapNode.CompletionXPBonus;
      }
      
      function initGridCallback(param1:TileGrid) 
      {
         mTileGrid = param1;
      }
      
      public function tileLibrary(param1:String) 
      {
         mTileLibraryPath = param1;
      }
      
      @:isVar public var introMovieSwfFilePath(never,set):String;
public function  set_introMovieSwfFilePath(param1:String) :String      {
         Logger.debug("introMovie: swfFilePath: " + param1);
         return mIntroMovieSwfFilePath = param1;
      }
      
      @:isVar public var introMovieAssetClassName(never,set):String;
public function  set_introMovieAssetClassName(param1:String) :String      {
         Logger.debug("introMovie: assetClassName: " + param1);
         return mIntroMovieAssetClassName = param1;
      }
      
            
      @:isVar public var currentFloorNum(get,set):UInt;
public function  get_currentFloorNum() : UInt
      {
         return mCurrentFloorNum;
      }
function  set_currentFloorNum(param1:UInt) :UInt      {
         Logger.debug("introMovie: assetClassName: " + param1);
         return mCurrentFloorNum = param1;
      }
      
      function playIntroMovie() 
      {
         if(ASCompat.stringAsBool(mIntroMovieSwfFilePath) && ASCompat.stringAsBool(mIntroMovieAssetClassName))
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mIntroMovieSwfFilePath),function(param1:brain.assetRepository.SwfAsset)
            {
               var stopMovie:ASFunction = null;
               var onKeyDown:ASFunction = null;
               var asset= param1;
               var movieClass= asset.getClass(mIntroMovieAssetClassName);
               var movie= ASCompat.dynamicAs(ASCompat.createInstance(movieClass, []), flash.display.MovieClip);
               stopMovie = function(param1:Event = null)
               {
                  if(movie.currentFrame == movie.totalFrames || param1 == null)
                  {
                     mDBFacade.stageRef.removeEventListener("keyDown",onKeyDown);
                     mDBFacade.removeRootDisplayObject(movie);
                     movie.removeEventListener("enterFrame",stopMovie);
                     mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_HERO"));
                     movie.stop();
                     mDBFacade.assetRepository.removeFromCache(asset);
                     movie = null;
                  }
               };
               mDBFacade.addRootDisplayObject(movie);
               movie.addEventListener("enterFrame",stopMovie);
               movie.gotoAndPlay(1);
               movie.x = 972.5;
               movie.y = 320;
               onKeyDown = function(param1:flash.events.KeyboardEvent)
               {
                  if(param1.keyCode == 27)
                  {
                     stopMovie();
                  }
               };
               mDBFacade.stageRef.addEventListener("keyDown",onKeyDown);
            });
         }
         else
         {
            mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_HERO"));
         }
      }
      
      public function show_text(param1:String) 
      {
         var _loc2_= new FloorMessageView(mDBFacade,param1);
         MemoryTracker.track(_loc2_,"FloorMessageView - created in DistributedDungeonFloor.show_text()");
      }
      
      public function play_sound(param1:String) 
      {
         var sound= param1;
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),sound,function(param1:brain.sound.SoundAsset)
         {
            mDBSoundComponent.playOneShot(param1,"sfx");
         });
      }
      
      public function trigger_camera_zoom(param1:Float) 
      {
         mDBFacade.camera.tweenZoom(1,param1,true);
      }
      
      public function trigger_camera_shake(param1:Float, param2:Float, param3:UInt) 
      {
         mDBFacade.camera.shakeY(param1 / 24,param2,param3);
      }
      
      public function tiles(param1:Vector<DungeonTileUsage>) 
      {
         var _loc3_:Vector<DungeonTileUsage> = /*undefined*/null;
         var _loc4_= 0;
         var _loc2_= false;
         var _loc5_= 0;
         if(mPostGenerate)
         {
            _loc3_ = new Vector<DungeonTileUsage>();
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc2_ = false;
               _loc5_ = 0;
               while(_loc5_ < mTileNetworkComponents.length)
               {
                  if(param1[_loc4_].x == mTileNetworkComponents[_loc5_].x && param1[_loc4_].y == mTileNetworkComponents[_loc5_].y)
                  {
                     _loc2_ = true;
                  }
                  _loc5_ = ASCompat.toInt(_loc5_) + 1;
               }
               if(!_loc2_)
               {
                  _loc3_.push(param1[_loc4_]);
               }
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
            mDungeonFloorFactory.buildDungeonFloor(_loc3_,finishedBuildingTiles);
         }
         mTileNetworkComponents = param1;
      }
      
      function finishedBuildingTiles(param1:TileGrid) 
      {
         var _loc3_:FloorObject = null;
         mTileGrid = param1;
         mBuildPropReady = true;
         var _loc2_= ASCompat.reinterpretAs(mFloorObjectsAwaitingDungeonFloor.iterator() , ISetIterator);
         while(_loc2_.hasNext())
         {
            _loc3_ = ASCompat.dynamicAs(_loc2_.next() , FloorObject);
            _loc3_.distributedDungeonFloor = this;
         }
         mFloorObjectsAwaitingDungeonFloor.clear();
         fillInEmptyTilesWithCollisionVolumes();
      }
      
      function fillInEmptyTilesWithCollisionVolumes() 
      {
         var _loc9_= 0;
         var _loc5_= 0;
         var _loc6_:Tile = null;
         var _loc2_= Math.NaN;
         var _loc1_= Math.NaN;
         var _loc7_:Vector3D = null;
         var _loc11_= Math.NaN;
         var _loc3_= Math.NaN;
         var _loc4_:Vector3D = null;
         var _loc10_= Math.NaN;
         var _loc8_:RectangleNavCollider = null;
         _loc9_ = 0;
         while(_loc9_ < 12)
         {
            _loc5_ = 0;
            while(_loc5_ < 12)
            {
               _loc6_ = mTileGrid.getTileAtIndex((_loc5_ : UInt),(_loc9_ : UInt));
               if(_loc6_ == null)
               {
                  if(mTileGrid.getEmptyColliderAtIndex((_loc5_ : UInt),(_loc9_ : UInt)) == null)
                  {
                     _loc2_ = 0;
                     _loc1_ = 0;
                     _loc7_ = new Vector3D(_loc2_,_loc1_);
                     _loc11_ = ASCompat.toNumber(ASCompat.toNumber(900 * _loc5_) - 900 * 0.5);
                     _loc3_ = ASCompat.toNumber(ASCompat.toNumber(900 * _loc9_) - 900 * 0.5);
                     _loc4_ = new Vector3D(_loc11_,_loc3_);
                     _loc10_ = 0;
                     _loc8_ = new RectangleNavCollider(mDBFacade,_loc6_,_loc7_,_loc10_,mB2World,900 * 0.5,900 * 0.5);
                     _loc8_.position = _loc4_;
                     mTileGrid.SetEmptyColliderAtIndex((_loc5_ : UInt),(_loc9_ : UInt),_loc8_);
                  }
               }
               _loc5_ = ASCompat.toInt(_loc5_) + 1;
            }
            _loc9_ = ASCompat.toInt(_loc9_) + 1;
         }
      }
      
      override public function destroy() 
      {
         var _loc2_:DooberGameObject = null;
         Logger.debug("destroy DistributedDungeonFloor " + Std.string(id));
         mEventComponent.dispatchEvent(new Event("DUNGEON_FLOOR_DESTROY"));
         mActiveOwnerAvatar = null;
         if(mBgMusic != null)
         {
            mBgMusic.removeEventListener("complete",onBgMusicLoaded);
            mBgMusic.removeEventListener("ioError",onBgMusicError);
            mBgMusic.removeEventListener("securityError",onBgMusicError);
            try
            {
               mBgMusic.close();
            }
            catch(e:Dynamic)
            {
            }
            mBgMusic = null;
         }
         if(mDBSoundComponent != null)
         {
            mDBSoundComponent.destroy();
            mDBSoundComponent = null;
         }
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         mDungeonFloorFactory.destroy();
         mDungeonFloorFactory = null;
         var _loc6_:Array<ASAny> = [];
         var _loc3_= ASCompat.reinterpretAs(mRemoteHeroes.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc6_.push(_loc3_.next());
         }
         var _loc7_:ASAny;
         if (checkNullIteratee(_loc6_)) for (_tmp_ in _loc6_)
         {
            _loc7_ = _tmp_;
            if(ASCompat.toBool(_loc7_))
            {
               _loc7_.destroy();
            }
         }
         mRemoteHeroes.clear();
         mRemoteHeroes = null;
         var _loc5_:Array<ASAny> = [];
         var _loc4_= ASCompat.reinterpretAs(mRemoteActors.iterator() , IMapIterator);
         while(_loc4_.hasNext())
         {
            _loc5_.push(_loc4_.next());
         }
         var _loc1_:ASAny;
         if (checkNullIteratee(_loc5_)) for (_tmp_ in _loc5_)
         {
            _loc1_ = _tmp_;
            if(ASCompat.toBool(_loc1_))
            {
               _loc1_.destroy();
            }
         }
         mRemoteActors.clear();
         mRemoteActors = null;
         var _loc8_:ASAny;
         final __ax4_iter_223 = mDoobers;
         if (checkNullIteratee(__ax4_iter_223)) for(_tmp_ in __ax4_iter_223.keys())
         {
            _loc8_ = _tmp_;
            _loc2_ = ASCompat.dynamicAs(_loc8_ , DooberGameObject);
            if(_loc2_ != null && !_loc2_.isDestroyed)
            {
               _loc2_.destroy();
            }
         }
         mDoobers = null;
         mFloorObjectsAwaitingDungeonFloor.clear();
         mFloorObjectsAwaitingDungeonFloor = null;
         mTileGrid.destroy();
         mTileGrid = null;
         mEffectManager.destroy();
         mEffectManager = null;
         astarGrids.destroy();
         astarGrids = null;
         super.destroy();
      }
      
      public function isAlive() : Bool
      {
         return mTileGrid != null;
      }
      
      override public function newNetworkChild(param1:GameObject) 
      {
         var _loc2_:HeroGameObject = null;
         var _loc3_:FloorObject = null;
         if(Std.isOfType(param1 , HeroGameObjectOwner))
         {
            activeOwnerAvatar = ASCompat.reinterpretAs(param1 , HeroGameObjectOwner);
            logWelcomeMessage();
         }
         else if(Std.isOfType(param1 , HeroGameObject))
         {
            _loc2_ = ASCompat.reinterpretAs(param1 , HeroGameObject);
            remoteHeroes.add(param1.id,_loc2_);
            logPlayerJoined(_loc2_);
         }
         else if(Std.isOfType(param1 , ActorGameObject))
         {
            remoteActors.add(param1.id,ASCompat.reinterpretAs(param1 , ActorGameObject));
            mEventComponent.dispatchEvent(new ActorLifetimeEvent("ACTOR_CREATED",param1.id));
         }
         else if(Std.isOfType(param1 , DooberGameObject))
         {
            mDoobers[param1] = true;
         }
         if(Std.isOfType(param1 , FloorObject))
         {
            _loc3_ = ASCompat.reinterpretAs(param1 , FloorObject);
            if(mBuildPropReady)
            {
               _loc3_.distributedDungeonFloor = this;
            }
            else
            {
               mFloorObjectsAwaitingDungeonFloor.add(_loc3_);
            }
         }
      }
      
      public function RemoveNetworkChild(param1:GameObject) 
      {
         var _loc2_:HeroGameObject = null;
         var _loc3_:FloorObject = null;
         if(Std.isOfType(param1 , HeroGameObjectOwner))
         {
            activeOwnerAvatar = null;
         }
         else if(Std.isOfType(param1 , HeroGameObject))
         {
            _loc2_ = ASCompat.reinterpretAs(param1 , HeroGameObject);
            logPlayerLeft(_loc2_);
            remoteHeroes.removeKey(param1.id);
         }
         else if(Std.isOfType(param1 , ActorGameObject))
         {
            mRemoteActors.removeKey(param1.id);
            mEventComponent.dispatchEvent(new ActorLifetimeEvent("ACTOR_DESTROYED",param1.id));
         }
         if(Std.isOfType(param1 , FloorObject))
         {
            _loc3_ = ASCompat.reinterpretAs(param1 , FloorObject);
            _loc3_.distributedDungeonFloor = null;
         }
      }
      
      public function GetTilesAroundAvatar(param1:Float) : Vector<Tile>
      {
         var _loc2_:Rectangle = null;
         if(mActiveOwnerAvatar != null)
         {
            _loc2_ = new Rectangle(mActiveOwnerAvatar.position.x - param1,mActiveOwnerAvatar.position.y - param1,param1 * 2,param1 * 2);
            return mActiveOwnerAvatar.distributedDungeonFloor.tileGrid.getVisibleTiles(_loc2_);
         }
         return new Vector<Tile>();
      }
      
      public function GetTileIdWhichAvatarIsOn() : String
      {
         var _loc4_= 0;
         if(mTileNetworkComponents.length == 0)
         {
            Logger.error("Invalid tile location in getTileNetworkComponentAtLocation");
            return null;
         }
         var _loc2_= Std.int(mActiveOwnerAvatar.position.x);
         var _loc3_= Std.int(mActiveOwnerAvatar.position.y);
         var _loc5_= mTileNetworkComponents[0];
         var _loc1_= getDistanceFromTileUsage(_loc2_,_loc3_,_loc5_);
         var _loc6_= 0;
         _loc4_ = 1;
         while(_loc4_ < mTileNetworkComponents.length)
         {
            _loc6_ = getDistanceFromTileUsage(_loc2_,_loc3_,mTileNetworkComponents[_loc4_]);
            if(_loc6_ < _loc1_)
            {
               _loc1_ = _loc6_;
               _loc5_ = mTileNetworkComponents[_loc4_];
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         return _loc5_.tileId;
      }
      
      function getDistanceFromTileUsage(param1:Int, param2:Int, param3:DungeonTileUsage) : Int
      {
         var _loc4_= new Point(param1,param2);
         var _loc5_= new Point(param3.x + 450,param3.y + 450);
         return Std.int(Point.distance(_loc4_,_loc5_));
      }
      
            
      @:isVar public var baseLining(get,set):UInt;
public function  set_baseLining(param1:UInt) :UInt      {
         return mBaseLining = param1;
      }
function  get_baseLining() : UInt
      {
         return mBaseLining;
      }
      
      override public function  get_gmMapNode() : GMMapNode
      {
         return mMapNode;
      }
      
      public function isTavern() : Bool
      {
         return mMapNode.NodeType == "TAVERN";
      }
   }


