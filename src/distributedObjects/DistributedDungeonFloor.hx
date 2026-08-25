package distributedObjects;

import actor.ActorGameObject;
import brain.assetRepository.AssetLoadingComponent;
import brain.gameObject.GameObject;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
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

class DistributedDungeonFloor extends Floor implements IDistributedDungeonFloor {
	static inline final MUSIC_BUFFER:Float = 1000;

	var mTileNetworkComponents:Vector<DungeonTileUsage>;

	var mTileLibraryPath:String = "uninitialized";

	var mDungeonFloorFactory:DungeonFloorFactory;

	var mTileGrid:TileGrid;

	public var astarGrids:Astar = new Astar();

	var mActiveOwnerAvatar:HeroGameObjectOwner;

	var mRemoteHeroes:Map;

	var mRemoteActors:Map;

	var mDoobers:ASDictionary<ASAny, ASAny>;

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

	public function new(dbFacade:DBFacade, remoteId:UInt) {
		Logger.debug("New  DistributedDungeonFloor******************************");
		mPostGenerate = false;
		super(dbFacade, remoteId);
		mRemoteHeroes = new Map();
		mRemoteActors = new Map();
		mDoobers = new ASDictionary<ASAny, ASAny>(true);
		mFloorObjectsAwaitingDungeonFloor = new Set();
		mEffectManager = new EffectManager(mDBFacade);
		MemoryTracker.track(mEffectManager, "EffectManager - created in DistributedDungeonFloor.constructor()");
		mBaseLining = (0 : UInt);
		mDBSoundComponent = new DBSoundComponent(mDBFacade);
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
	}

	@:isVar public var coliseumTierConstant(never, set):String;

	public function set_coliseumTierConstant(val:String):String {
		return mColiseumTierConstant = val;
	}

	@:isVar public var mapNodeId(never, set):UInt;

	public function set_mapNodeId(val:UInt):UInt {
		return mCurrentMapNodeId = val;
	}

	override public function get_isInfiniteDungeon():Bool {
		return mMapNode.IsInfiniteDungeon;
	}

	public function getActor(id:UInt):ActorGameObject {
		if (mActiveOwnerAvatar != null && mActiveOwnerAvatar.id == id) {
			return mActiveOwnerAvatar;
		}
		var _loc2_ = ASCompat.dynamicAs(mRemoteActors.itemFor(id), actor.ActorGameObject);
		if (_loc2_ != null) {
			return _loc2_;
		}
		_loc2_ = ASCompat.dynamicAs(mRemoteHeroes.itemFor(id), actor.ActorGameObject);
		if (_loc2_ != null) {
			return _loc2_;
		}
		return null;
	}

	@:isVar public var effectManager(get, never):EffectManager;

	public function get_effectManager():EffectManager {
		return mEffectManager;
	}

	@:isVar public var numHeroes(get, never):UInt;

	public function get_numHeroes():UInt {
		return 1 + mRemoteHeroes.size;
	}

	@:isVar public var remoteHeroes(get, set):Map;

	public function get_remoteHeroes():Map {
		return mRemoteHeroes;
	}

	@:isVar public var remoteActors(get, never):Map;

	public function get_remoteActors():Map {
		return mRemoteActors;
	}

	function set_remoteHeroes(value:Map):Map {
		return mRemoteHeroes = value;
	}

	@:isVar public var activeOwnerAvatar(get, set):HeroGameObjectOwner;

	public function get_activeOwnerAvatar():HeroGameObjectOwner {
		return mActiveOwnerAvatar;
	}

	function set_activeOwnerAvatar(value:HeroGameObjectOwner):HeroGameObjectOwner {
		return mActiveOwnerAvatar = value;
	}

	override public function getCurrentFloorNum():UInt {
		return mCurrentFloorNum % 1000 + 1;
	}

	override public function getMaxFloorNum():UInt {
		return (Std.int(mCurrentFloorNum / 1000) : UInt);
	}

	@:isVar public var tileGrid(get, never):TileGrid;

	public function get_tileGrid():TileGrid {
		return mTileGrid;
	}

	public function setNetworkComponentDistributedDungeonFloor(iface:DistributedDungeonFloorNetworkComponent) {}

	@:isVar public var dungeonFloorFactory(get, never):DungeonFloorFactory;

	public function get_dungeonFloorFactory():DungeonFloorFactory {
		return mDungeonFloorFactory;
	}

	public function postGenerate() {
		mPostGenerate = true;
		mDungeonFloorFactory = new DungeonFloorFactory(this, initGridCallback, mDBFacade, mTileLibraryPath);
		MemoryTracker.track(mDungeonFloorFactory, "DungeonFloorFactory - created in DistributedDungeonFloor.postGenerate()");
		astarGrids.Init(this);
		mDungeonFloorFactory.buildDungeonFloor(mTileNetworkComponents, finishedBuildingTiles);
		mMapNode = mDBFacade.gameMaster.getMapNode(mCurrentMapNodeId);
		this.playIntroMovie();
		this.playMusic();
		buildFloorEndingGui();
	}

	override public function victory() {
		logDungeonCompletion();
		super.victory();
		if (mDBFacade.steamAchievementsManager != null) {
			mDBFacade.steamAchievementsManager.unlockFloorCompleted(mMapNode.Constant);
		}
	}

	override public function defeat() {
		logDungeonCompletion();
		var _loc1_ = getCurrentFloorNum();
		if (mDBFacade.steamAchievementsManager != null) {
			mDBFacade.steamAchievementsManager.setHighestFloorAchieved(mMapNode, _loc1_);
		}
		super.defeat();
	}

	function formatHeroInfo(hero:HeroGameObject):String {
		return "\""
			+ hero.screenName
			+ "\" AccountId="
			+ hero.playerID
			+ " Avatar=\""
			+ hero.gMHero.Name
			+ "\" Skin=\""
			+ hero.gmSkin.Name
			+ "\"";
	}

	function formatFellowPlayers(prefix:String):String {
		if (mRemoteHeroes.size == 0) {
			return "";
		}
		var _loc2_ = prefix;
		var _loc3_ = mRemoteHeroes.iterator();
		var _loc4_ = true;
		while (_loc3_.hasNext()) {
			if (!_loc4_) {
				_loc2_ += ", ";
			}
			_loc2_ += formatHeroInfo(ASCompat.dynamicAs(_loc3_.next(), HeroGameObject));
			_loc4_ = false;
		}
		return _loc2_;
	}

	function getFloorString():String {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mMapNode.TierRank), gameMasterDictionary.GMColiseumTier);
		return "floor " + getCurrentFloorNum() + "/" + _loc1_.TotalFloors;
	}

	function logWelcomeMessage() {
		if (mActiveOwnerAvatar == null || mMapNode == null) {
			return;
		}
		Logger.debugch("PlayerInfo",
			"Welcome ("
			+ mActiveOwnerAvatar.playerID
			+ ") to the dungeon \""
			+ mMapNode.Name
			+ "\" ("
			+ mCurrentMapNodeId
			+ ") "
			+ getFloorString()
			+ " SessionId="
			+ mDBFacade.sessionInfoString);
	}

	function logPlayerJoined(hero:HeroGameObject) {
		Logger.debugch("PlayerInfo", formatHeroInfo(hero) + " joined floor " + getCurrentFloorNum() + ".");
	}

	function logPlayerLeft(hero:HeroGameObject) {
		if (!isAlive()) {
			return;
		}
		Logger.debugch("PlayerInfo", formatHeroInfo(hero) + " left floor " + getCurrentFloorNum() + ".");
	}

	function logDungeonCompletion() {
		if (mActiveOwnerAvatar == null || mMapNode == null) {
			return;
		}
		Logger.debugch("PlayerInfo",
			"You ("
			+ mActiveOwnerAvatar.playerID
			+ ") finished the dungeon \""
			+ mMapNode.Name
			+ "\" ("
			+ mCurrentMapNodeId
			+ ") "
			+ getFloorString()
			+ " SessionId="
			+ mDBFacade.sessionInfoString
			+ formatFellowPlayers(", you were playing with "));
	}

	function playMusic() {
		var _loc3_:URLRequest = null;
		var _loc2_:SoundLoaderContext = null;
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant), gameMasterDictionary.GMColiseumTier);
		if (_loc1_ != null && ASCompat.stringAsBool(_loc1_.MusicFilepath)) {
			mBgMusic = new Sound();
			_loc3_ = new URLRequest(DBFacade.buildFullDownloadPath(_loc1_.MusicFilepath));
			_loc2_ = new SoundLoaderContext(1000, true);
			_loc2_.checkPolicyFile = true;
			mBgMusic.load(_loc3_, _loc2_);
			mBgMusic.addEventListener("complete", onBgMusicLoaded);
			mBgMusic.addEventListener("ioError", onBgMusicError);
			mBgMusic.addEventListener("securityError", onBgMusicError);
		}
	}

	function onBgMusicLoaded(e:Event) {
		if (mDBSoundComponent != null) {
			mDBSoundComponent.playStreamingMusic(mBgMusic);
		}
	}

	function onBgMusicError(evt:Event) {
		Logger.error("BgMusic load error: " + evt.toString());
	}

	@:isVar public var coliseumTier(get, never):GMColiseumTier;

	public function get_coliseumTier():GMColiseumTier {
		return ASCompat.dynamicAs(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant), gameMasterDictionary.GMColiseumTier);
	}

	@:isVar public var completionXp(get, never):UInt;

	public function get_completionXp():UInt {
		return mMapNode.CompletionXPBonus;
	}

	function initGridCallback(tileGrid:TileGrid) {
		mTileGrid = tileGrid;
	}

	public function tileLibrary(tilegrp:String) {
		mTileLibraryPath = tilegrp;
	}

	@:isVar public var introMovieSwfFilePath(never, set):String;

	public function set_introMovieSwfFilePath(value:String):String {
		Logger.debug("introMovie: swfFilePath: " + value);
		return mIntroMovieSwfFilePath = value;
	}

	@:isVar public var introMovieAssetClassName(never, set):String;

	public function set_introMovieAssetClassName(value:String):String {
		Logger.debug("introMovie: assetClassName: " + value);
		return mIntroMovieAssetClassName = value;
	}

	@:isVar public var currentFloorNum(get, set):UInt;

	public function get_currentFloorNum():UInt {
		return mCurrentFloorNum;
	}

	function set_currentFloorNum(value:UInt):UInt {
		Logger.debug("introMovie: assetClassName: " + value);
		return mCurrentFloorNum = value;
	}

	function playIntroMovie() {
		if (ASCompat.stringAsBool(mIntroMovieSwfFilePath) && ASCompat.stringAsBool(mIntroMovieAssetClassName)) {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mIntroMovieSwfFilePath), function(param1:brain.assetRepository.SwfAsset) {
				var stopMovie:ASFunction = null;
				var onKeyDown:ASFunction = null;
				var movieRenderer:MovieClipRenderController = null;
				var asset = param1;
				var movieClass = asset.getClass(mIntroMovieAssetClassName);
				var movie = ASCompat.dynamicAs(ASCompat.createInstance(movieClass, []), flash.display.MovieClip);
				stopMovie = function() {
					mDBFacade.stageRef.removeEventListener("keyDown", onKeyDown);
					mDBFacade.removeRootDisplayObject(movie);
					if (movieRenderer != null) {
						movieRenderer.destroy();
						movieRenderer = null;
					}
					mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_HERO"));
					mDBFacade.assetRepository.removeFromCache(asset);
					movie = null;
				};
				mDBFacade.addRootDisplayObject(movie);
				movieRenderer = new MovieClipRenderController(mDBFacade, movie, stopMovie);
				movieRenderer.play((0 : UInt), false);
				movie.x = 972.5;
				movie.y = 320;
				onKeyDown = function(param1:flash.events.KeyboardEvent) {
					if (param1.keyCode == 27) {
						stopMovie();
					}
				};
				mDBFacade.stageRef.addEventListener("keyDown", onKeyDown);
			});
		} else {
			mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_HERO"));
		}
	}

	public function show_text(textkey:String) {
		var _loc2_ = new FloorMessageView(mDBFacade, textkey);
		MemoryTracker.track(_loc2_, "FloorMessageView - created in DistributedDungeonFloor.show_text()");
	}

	public function play_sound(sound:String) {
		mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"), sound,
			function(param1:brain.sound.SoundAsset) {
				mDBSoundComponent.playOneShot(param1, "sfx");
			});
	}

	public function trigger_camera_zoom(zoom:Float) {
		mDBFacade.camera.tweenZoom(1, zoom, true);
	}

	public function trigger_camera_shake(shakeDuration:Float, shakeStrength:Float, shakeCount:UInt) {
		mDBFacade.camera.shakeY(shakeDuration / 24, shakeStrength, shakeCount);
	}

	public function tiles(tiles:Vector<DungeonTileUsage>) {
		var _loc3_:Vector<DungeonTileUsage> = /*undefined*/ null;
		var _loc4_ = 0;
		var _loc2_ = false;
		var _loc5_ = 0;
		if (mPostGenerate) {
			_loc3_ = new Vector<DungeonTileUsage>();
			_loc4_ = 0;
			while (_loc4_ < tiles.length) {
				_loc2_ = false;
				_loc5_ = 0;
				while (_loc5_ < mTileNetworkComponents.length) {
					if (tiles[_loc4_].x == mTileNetworkComponents[_loc5_].x && tiles[_loc4_].y == mTileNetworkComponents[_loc5_].y) {
						_loc2_ = true;
					}
					_loc5_ = ASCompat.toInt(_loc5_) + 1;
				}
				if (!_loc2_) {
					_loc3_.push(tiles[_loc4_]);
				}
				_loc4_ = ASCompat.toInt(_loc4_) + 1;
			}
			mDungeonFloorFactory.buildDungeonFloor(_loc3_, finishedBuildingTiles);
		}
		mTileNetworkComponents = tiles;
	}

	function finishedBuildingTiles(tileGrid:TileGrid) {
		var _loc3_:FloorObject = null;
		mTileGrid = tileGrid;
		mBuildPropReady = true;
		var _loc2_ = ASCompat.reinterpretAs(mFloorObjectsAwaitingDungeonFloor.iterator(), ISetIterator);
		while (_loc2_.hasNext()) {
			_loc3_ = ASCompat.dynamicAs(_loc2_.next(), FloorObject);
			_loc3_.distributedDungeonFloor = this;
		}
		mFloorObjectsAwaitingDungeonFloor.clear();
		fillInEmptyTilesWithCollisionVolumes();
	}

	function fillInEmptyTilesWithCollisionVolumes() {
		var _loc9_ = 0;
		var _loc5_ = 0;
		var _loc6_:Tile = null;
		var _loc2_ = Math.NaN;
		var _loc1_ = Math.NaN;
		var _loc7_:Vector3D = null;
		var _loc11_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc4_:Vector3D = null;
		var _loc10_ = Math.NaN;
		var _loc8_:RectangleNavCollider = null;
		_loc9_ = 0;
		while (_loc9_ < 12) {
			_loc5_ = 0;
			while (_loc5_ < 12) {
				_loc6_ = mTileGrid.getTileAtIndex((_loc5_ : UInt), (_loc9_ : UInt));
				if (_loc6_ == null) {
					if (mTileGrid.getEmptyColliderAtIndex((_loc5_ : UInt), (_loc9_ : UInt)) == null) {
						_loc2_ = 0;
						_loc1_ = 0;
						_loc7_ = new Vector3D(_loc2_, _loc1_);
						_loc11_ = ASCompat.toNumber(ASCompat.toNumber(900 * _loc5_) - 900 * 0.5);
						_loc3_ = ASCompat.toNumber(ASCompat.toNumber(900 * _loc9_) - 900 * 0.5);
						_loc4_ = new Vector3D(_loc11_, _loc3_);
						_loc10_ = 0;
						_loc8_ = new RectangleNavCollider(mDBFacade, _loc6_, _loc7_, _loc10_, mB2World, 900 * 0.5, 900 * 0.5);
						_loc8_.position = _loc4_;
						mTileGrid.SetEmptyColliderAtIndex((_loc5_ : UInt), (_loc9_ : UInt), _loc8_);
					}
				}
				_loc5_ = ASCompat.toInt(_loc5_) + 1;
			}
			_loc9_ = ASCompat.toInt(_loc9_) + 1;
		}
	}

	override public function destroy() {
		var _loc2_:DooberGameObject = null;
		Logger.debug("destroy DistributedDungeonFloor " + Std.string(id));
		mEventComponent.dispatchEvent(new Event("DUNGEON_FLOOR_DESTROY"));
		mActiveOwnerAvatar = null;
		if (mBgMusic != null) {
			mBgMusic.removeEventListener("complete", onBgMusicLoaded);
			mBgMusic.removeEventListener("ioError", onBgMusicError);
			mBgMusic.removeEventListener("securityError", onBgMusicError);
			try {
				mBgMusic.close();
			} catch (e:Dynamic) {}
			mBgMusic = null;
		}
		if (mDBSoundComponent != null) {
			mDBSoundComponent.destroy();
			mDBSoundComponent = null;
		}
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		mDungeonFloorFactory.destroy();
		mDungeonFloorFactory = null;
		var _loc6_:Array<ASAny> = [];
		var _loc3_ = ASCompat.reinterpretAs(mRemoteHeroes.iterator(), IMapIterator);
		while (_loc3_.hasNext()) {
			_loc6_.push(_loc3_.next());
		}
		var _loc7_:HeroGameObject;
		if (checkNullIteratee(_loc6_))
			for (_tmp_ in _loc6_) {
				_loc7_ = ASCompat.dynamicAs(_tmp_, distributedObjects.HeroGameObject);
				if (_loc7_ != null) {
					_loc7_.destroy();
				}
			}
		mRemoteHeroes.clear();
		mRemoteHeroes = null;
		var _loc5_:Array<ASAny> = [];
		var _loc4_ = ASCompat.reinterpretAs(mRemoteActors.iterator(), IMapIterator);
		while (_loc4_.hasNext()) {
			_loc5_.push(_loc4_.next());
		}
		var _loc1_:ActorGameObject;
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_) {
				_loc1_ = ASCompat.dynamicAs(_tmp_, actor.ActorGameObject);
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
			}
		mRemoteActors.clear();
		mRemoteActors = null;
		var _loc8_:ASObject;
		final __ax4_iter_228 = mDoobers;
		if (checkNullIteratee(__ax4_iter_228))
			for (_tmp_ in __ax4_iter_228.keys()) {
				_loc8_ = _tmp_;
				_loc2_ = ASCompat.dynamicAs(_loc8_, DooberGameObject);
				if (_loc2_ != null && !_loc2_.isDestroyed) {
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

	public function isAlive():Bool {
		return mTileGrid != null;
	}

	override public function newNetworkChild(child:GameObject) {
		var _loc2_:HeroGameObject = null;
		var _loc3_:FloorObject = null;
		if (Std.isOfType(child, HeroGameObjectOwner)) {
			activeOwnerAvatar = ASCompat.reinterpretAs(child, HeroGameObjectOwner);
			logWelcomeMessage();
		} else if (Std.isOfType(child, HeroGameObject)) {
			_loc2_ = ASCompat.reinterpretAs(child, HeroGameObject);
			remoteHeroes.add(child.id, _loc2_);
			logPlayerJoined(_loc2_);
		} else if (Std.isOfType(child, ActorGameObject)) {
			remoteActors.add(child.id, ASCompat.reinterpretAs(child, ActorGameObject));
			mEventComponent.dispatchEvent(new ActorLifetimeEvent("ACTOR_CREATED", child.id));
		} else if (Std.isOfType(child, DooberGameObject)) {
			mDoobers[child] = true;
		}
		if (Std.isOfType(child, FloorObject)) {
			_loc3_ = ASCompat.reinterpretAs(child, FloorObject);
			if (mBuildPropReady) {
				_loc3_.distributedDungeonFloor = this;
			} else {
				mFloorObjectsAwaitingDungeonFloor.add(_loc3_);
			}
		}
	}

	public function RemoveNetworkChild(child:GameObject) {
		var _loc2_:HeroGameObject = null;
		var _loc3_:FloorObject = null;
		if (Std.isOfType(child, HeroGameObjectOwner)) {
			activeOwnerAvatar = null;
		} else if (Std.isOfType(child, HeroGameObject)) {
			_loc2_ = ASCompat.reinterpretAs(child, HeroGameObject);
			logPlayerLeft(_loc2_);
			remoteHeroes.removeKey(child.id);
		} else if (Std.isOfType(child, ActorGameObject)) {
			mRemoteActors.removeKey(child.id);
			mEventComponent.dispatchEvent(new ActorLifetimeEvent("ACTOR_DESTROYED", child.id));
		}
		if (Std.isOfType(child, FloorObject)) {
			_loc3_ = ASCompat.reinterpretAs(child, FloorObject);
			_loc3_.distributedDungeonFloor = null;
		}
	}

	public function GetTilesAroundAvatar(range:Float):Vector<Tile> {
		var _loc2_:Rectangle = null;
		if (mActiveOwnerAvatar != null) {
			_loc2_ = new Rectangle(mActiveOwnerAvatar.position.x - range, mActiveOwnerAvatar.position.y - range, range * 2, range * 2);
			return mActiveOwnerAvatar.distributedDungeonFloor.tileGrid.getVisibleTiles(_loc2_);
		}
		return new Vector<Tile>();
	}

	public function GetTileIdWhichAvatarIsOn():String {
		var _loc4_ = 0;
		if (mTileNetworkComponents.length == 0) {
			Logger.error("Invalid tile location in getTileNetworkComponentAtLocation");
			return null;
		}
		var _loc2_ = Std.int(mActiveOwnerAvatar.position.x);
		var _loc3_ = Std.int(mActiveOwnerAvatar.position.y);
		var _loc5_ = mTileNetworkComponents[0];
		var _loc1_ = getDistanceFromTileUsage(_loc2_, _loc3_, _loc5_);
		var _loc6_ = 0;
		_loc4_ = 1;
		while (_loc4_ < mTileNetworkComponents.length) {
			_loc6_ = getDistanceFromTileUsage(_loc2_, _loc3_, mTileNetworkComponents[_loc4_]);
			if (_loc6_ < _loc1_) {
				_loc1_ = _loc6_;
				_loc5_ = mTileNetworkComponents[_loc4_];
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		return _loc5_.tileId;
	}

	function getDistanceFromTileUsage(x:Int, y:Int, dtu:DungeonTileUsage):Int {
		var _loc4_ = new Point(x, y);
		var _loc5_ = new Point(dtu.x + 450, dtu.y + 450);
		return Std.int(Point.distance(_loc4_, _loc5_));
	}

	@:isVar public var baseLining(get, set):UInt;

	public function set_baseLining(val:UInt):UInt {
		return mBaseLining = val;
	}

	function get_baseLining():UInt {
		return mBaseLining;
	}

	override public function get_gmMapNode():GMMapNode {
		return mMapNode;
	}

	public function isTavern():Bool {
		return mMapNode.NodeType == "TAVERN";
	}
}
