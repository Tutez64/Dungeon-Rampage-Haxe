package distributedObjects;

import actor.ActorGameObject;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.gameObject.GameObject;
import brain.logger.Logger;
import brain.sound.SoundHandle;
import brain.starling.swfConverter.BakeScheduler;
import brain.utils.MemoryTracker;
import brain.workLoop.DoLater;
import collections.IMapIterator;
import collections.ISetIterator;
import collections.Map;
import collections.Set;
import dBGlobals.DBGlobal;
import doobers.DooberGameObject;
import dungeon.DungeonFloorFactory;
import dungeon.RectangleNavCollider;
import dungeon.Tile;
import dungeon.TileGrid;
import effects.EffectManager;
import events.ActorLifetimeEvent;
import facade.DBFacade;
import facade.LoadingPrewarm;
import facade.TrickleCacheLoader;
import dr_floor.FloorMessageView;
import dr_floor.FloorObject;
import gameMasterDictionary.GMColiseumTier;
import gameMasterDictionary.GMMapNode;
import generatedCode.DistributedDungeonFloorNetworkComponent;
import generatedCode.DungeonTileUsage;
import generatedCode.IDistributedDungeonFloor;
import projectile.ProjectileGameObject;
import sound.DBSoundComponent;
import sound.DBSoundManager;
import stateMachine.mainStateMachine.LoadingScreenState;
import steamAchievements.SteamAPINames;
import uI.CutsceneOverlay;
import uI.CutsceneVideo;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.media.SoundTransform;
import flash.net.URLRequest;

class DistributedDungeonFloor extends Floor implements IDistributedDungeonFloor {
	static inline final MUSIC_BUFFER:Float = 1000;

	var mTileNetworkComponents:Vector<DungeonTileUsage>;

	var mTileLibraryPath:String = "uninitialized";

	var mDungeonFloorFactory:DungeonFloorFactory;

	var mTileGrid:TileGrid;

	var mActiveOwnerAvatar:HeroGameObjectOwner;

	var mRemoteHeroes:Map;

	var mRemoteActors:Map;

	var mDoobers:ASDictionary<ASAny, ASAny>;

	var mProjectiles:ASDictionary<ASAny, ASAny>;

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

	var mEntryAtlasesQueued:Bool = false;

	var mEntryPropAtlasesQueued:Bool = false;

	var mEntryGeneration:Int = 0;

	var mEntryReleaseChecked:Bool = false;

	var mPrewarm:LoadingPrewarm;

	var mEntryReleaseEvents:EventComponent;

	var mFloorTilesRequested:Bool = false;

	var mHeroEntryWanted:Bool = false;

	var mAwaitingStarlingAssets:Bool = false;

	var mEntryStarted:Bool = false;

	var mIntroMovieAsset:SwfAsset;

	var mIntroOverlay:CutsceneOverlay;

	var mIntroVideo:CutsceneVideo;

	var mViewHold:FloorViewHold;

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
		mProjectiles = new ASDictionary<ASAny, ASAny>(true);
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
		var _loc2_ = ASCompat.coerce(mRemoteActors.itemFor(id), actor.ActorGameObject);
		if (_loc2_ != null) {
			return _loc2_;
		}
		_loc2_ = ASCompat.coerce(mRemoteHeroes.itemFor(id), actor.ActorGameObject);
		if (_loc2_ != null) {
			return _loc2_;
		}
		return null;
	}

	@:isVar public var effectManager(get, never):EffectManager;

	public function get_effectManager():EffectManager {
		return mEffectManager;
	}

	public function registerProjectile(projectile:ProjectileGameObject) {
		if (mProjectiles != null) {
			mProjectiles[projectile] = true;
		}
	}

	public function unregisterProjectile(projectile:ProjectileGameObject) {
		if (mProjectiles != null) {
			mProjectiles.remove(projectile);
		}
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
		return (ASCompat.floatToInt(mCurrentFloorNum / 1000) : UInt);
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
		BakeScheduler.floorLoadStarted();
		mDungeonFloorFactory = new DungeonFloorFactory(this, initGridCallback, mDBFacade, mTileLibraryPath);
		MemoryTracker.track(mDungeonFloorFactory, "DungeonFloorFactory - created in DistributedDungeonFloor.postGenerate()");
		buildTiles(mTileNetworkComponents, true);
		mMapNode = mDBFacade.gameMaster.getMapNode(mCurrentMapNodeId);
		if (mMapNode != null && mMapNode.NodeType == GMMapNode.INFINITE_NODE_TYPE) {
			mDBFacade.steamAchievementsHelper.checkHighestUltimateRampageFloorAchieved(mMapNode, getCurrentFloorNum() - 1);
			mDBFacade.steamAchievementsHelper.updateMapsAtFloor25Stat();
		}
		buildFloorEndingGui();
		loadIntroMovie();
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.mainStateMachine.currentState, LoadingScreenState);
		if (_loc1_ != null && _loc1_.holdsHeroEntry) {
			mEventComponent.addListener("LOADING_SCREEN_HERO_ENTRY_RELEASED", onHeroEntryReleased);
		} else {
			if (_loc1_ == null) {
				holdViewForFloorChange();
			}
			startEntry();
		}
	}

	function holdViewForFloorChange() {
		mViewHold = new FloorViewHold(function(param1:Float, param2:ASFunction):ASObject {
			return mDBFacade.realClockWorkManager.doLater(param1, param2, false, "DistributedDungeonFloor.viewHold");
		}, function(param1:ASObject) {
			mDBFacade.realClockWorkManager.removeDoLater(ASCompat.dynamicAs(param1, DoLater));
		}, onViewHoldReleased);
		mViewHold.begin();
		mSceneGraphComponent.fadeOut(0);
	}

	function onViewHoldReleased(timedOut:Bool) {
		if (timedOut) {
			Logger.warn("DistributedDungeonFloor: floor change view hold timed out after 15 s (heroReady="
				+ mViewHold.heroIsReady
				+ " closure="
				+ mViewHold.closureHasArrived
				+ "); fading in anyway");
		}
		mSceneGraphComponent.fadeIn(1);
		revealFloor();
	}

	override function heroOwnerReady() {
		if (mViewHold != null && mViewHold.holding) {
			mViewHold.heroReady();
		} else {
			super.heroOwnerReady();
		}
	}

	override public function InterestClosure() {
		super.InterestClosure();
		if (mViewHold != null) {
			mViewHold.closureArrived();
		}
	}

	function onHeroEntryReleased(e:Event) {
		mEventComponent.removeListener("LOADING_SCREEN_HERO_ENTRY_RELEASED");
		startEntry();
	}

	function startEntry() {
		mEntryStarted = true;
		if (mViewHold == null || !mViewHold.holding) {
			mSceneGraphComponent.fadeIn(1);
		}
		playMusic();
		if (ASCompat.stringAsBool(mIntroMovieSwfFilePath) && ASCompat.stringAsBool(mIntroMovieAssetClassName)) {
			playIntroMovie();
		} else {
			requestEntryHero();
		}
	}

	override public function victory() {
		logDungeonCompletion();
		super.victory();
		var _loc1_ = mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Constant;
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id);
		mDBFacade.steamAchievementsHelper.unlockBossChallengeWithUncommonWeapon(mMapNode, _loc1_, _loc2_);
		mDBFacade.steamAchievementsHelper.unlockDarkBarrowsAsVampireHunter(_loc1_, mMapNode.Constant);
		if (mMapNode.NodeType == GMMapNode.BOSS_NODE_TYPE) {
			mDBFacade.steamAchievementsHelper.unlockAchievement(SteamAPINames.getUnlockFloorCompletedAPIName(mMapNode.Constant));
		} else if (mMapNode.NodeType == GMMapNode.INFINITE_NODE_TYPE) {
			mDBFacade.steamAchievementsHelper.checkHighestUltimateRampageFloorAchieved(mMapNode, getCurrentFloorNum());
			mDBFacade.steamAchievementsHelper.updateMapsAtFloor25Stat();
		}
		mDBFacade.steamAchievementsHelper.unlockFinishFloorWithThreeTeammatesDowned(mRemoteHeroes);
		mDBFacade.steamAchievementsHelper.addValueToStatInt(1, "DUNGEONS_COMPLETED");
		var _loc3_ = mDBFacade.dbAccountInfo.friendInfos;
		mDBFacade.steamAchievementsHelper.finishDungeonWithFriends(mRemoteHeroes, _loc3_);
	}

	override public function defeat() {
		logDungeonCompletion();
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
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mMapNode.TierRank), gameMasterDictionary.GMColiseumTier);
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
		var _loc1_ = ASCompat.coerce(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant), gameMasterDictionary.GMColiseumTier);
		if (_loc1_ != null && ASCompat.stringAsBool(_loc1_.MusicFilepath)) {
			mBgMusic = new Sound();
			_loc3_ = new URLRequest(DBFacade.buildFullDownloadPath(_loc1_.MusicFilepath));
			_loc2_ = new SoundLoaderContext(1000, true);
			_loc2_.checkPolicyFile = true;
			mBgMusic.load(_loc3_, _loc2_);
			EventListeners.add(mBgMusic, "complete", onBgMusicLoaded);
			EventListeners.add(mBgMusic, "ioError", onBgMusicError);
			EventListeners.add(mBgMusic, "securityError", onBgMusicError);
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
		return ASCompat.coerce(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant), gameMasterDictionary.GMColiseumTier);
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

	function loadIntroMovie() {
		if (ASCompat.stringAsBool(mIntroMovieSwfFilePath) && ASCompat.stringAsBool(mIntroMovieAssetClassName)) {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mIntroMovieSwfFilePath), function(param1:SwfAsset) {
				mIntroMovieAsset = param1;
				if (mEntryStarted) {
					playIntroMovie();
				}
			});
		}
	}

	function playIntroMovie() {
		var movieClass:Dynamic;
		var movie:MovieClip;
		var dbSoundManager:DBSoundManager;
		var volume:SoundTransform;
		var stopMovie:ASFunction = null;
		var onKeyDown:ASFunction = null;
		var asset = mIntroMovieAsset;
		if (asset == null) {
			return;
		}
		mIntroMovieAsset = null;
		movieClass = asset.getClass(mIntroMovieAssetClassName);
		movie = ASCompat.coerce(ASCompat.createInstance(movieClass, []), flash.display.MovieClip);
		dbSoundManager = ASCompat.reinterpretAs(mDBFacade.soundManager, DBSoundManager);
		dbSoundManager.applyStoredVolumeSettings();
		volume = new SoundTransform(dbSoundManager.getDampenedVolumeScaleForCategory("music"));
		stopMovie = function(param1:Event = null) {
			if (movie == null) {
				return;
			}
			if (movie.currentFrame == movie.totalFrames || param1 == null) {
				EventListeners.remove(mDBFacade.stageRef, "keyDown", onKeyDown);
				mDBFacade.removeRootDisplayObject(movie);
				EventListeners.remove(movie, "enterFrame", stopMovie);
				destroyIntroOverlay();
				destroyIntroVideo();
				if (mViewHold != null) {
					mViewHold.introEnded();
				}
				requestEntryHero();
				movie.stop();
				mDBFacade.assetRepository.removeFromCache(asset);
				movie = null;
			}
		};
		mIntroVideo = new CutsceneVideo(mDBFacade.stageRef, movie, asset.root.loaderInfo.frameRate,
			DBFacade.buildFullDownloadPath(new compat.RegExp("\\.swf$", "i").replace(mIntroMovieSwfFilePath, "_1920x1080.mp4")), volume);
		mDBFacade.addRootDisplayObject(mIntroVideo.display);
		mDBFacade.addRootDisplayObject(movie);
		if (mViewHold != null) {
			mViewHold.introStarted();
		}
		EventListeners.add(movie, "enterFrame", stopMovie);
		movie.x = 972.5;
		movie.y = 320;
		mIntroOverlay = new CutsceneOverlay(mDBFacade, stopMovie, false);
		mDBFacade.addRootDisplayObject(mIntroOverlay.skipButton.root);
		mDBFacade.menuNavigationController.pushNewLayer("BOSS_INTRO_CINEMATIC", stopMovie, mIntroOverlay.skipButton);
		onKeyDown = function(param1:flash.events.KeyboardEvent) {
			if (param1.keyCode == 27) {
				stopMovie();
			}
		};
		EventListeners.add(mDBFacade.stageRef, "keyDown", onKeyDown);
	}

	function destroyIntroOverlay() {
		if (mIntroOverlay == null) {
			return;
		}
		mDBFacade.menuNavigationController.removeLayer("BOSS_INTRO_CINEMATIC");
		mDBFacade.removeRootDisplayObject(mIntroOverlay.skipButton.root);
		mIntroOverlay.destroy();
		mIntroOverlay = null;
	}

	function destroyIntroVideo() {
		if (mIntroVideo == null) {
			return;
		}
		mDBFacade.removeRootDisplayObject(mIntroVideo.display);
		mIntroVideo.destroy();
		mIntroVideo = null;
	}

	function queueEntryAtlases() {
		var _loc2_ = mDBFacade.assetLoadingComponent;
		if (mEntryAtlasesQueued || _loc2_ == null) {
			return;
		}
		mEntryAtlasesQueued = true;
		mEntryGeneration = _loc2_.floorGeneration;
		var _loc1_ = ASCompat.reinterpretAs(parentArea, DistributedDungionArea);
		var _loc3_:String;
		final __ax4_iter_325 = TrickleCacheLoader.starlingAtlasPaths(mDBFacade, _loc1_ != null ? _loc1_.mCacheNpc : null);
		if (checkNullIteratee(__ax4_iter_325))
			for (_tmp_ in __ax4_iter_325) {
				_loc3_ = _tmp_;
				_loc2_.queueStarlingAssetsForPath(_loc3_);
			}
		TrickleCacheLoader.queueBossAtlases(mDBFacade, _loc1_ != null ? _loc1_.mCacheNpc : null);
		queueEntryPropAtlases();
	}

	function queueEntryPropAtlases() {
		var _loc3_ = mDBFacade.assetLoadingComponent;
		if (mEntryPropAtlasesQueued || !mEntryAtlasesQueued || !mFloorTilesRequested || _loc3_ == null) {
			return;
		}
		mEntryPropAtlasesQueued = true;
		var _loc1_ = ASCompat.reinterpretAs(parentArea, DistributedDungionArea);
		var _loc4_ = _loc3_.isEntryFloorPending ? null : _loc3_.requestedFloorBiome;
		var _loc2_:ASObject = TrickleCacheLoader.starlingPropAtlasClassNames(mDBFacade, _loc1_ != null ? _loc1_.mCacheNpc : null, _loc4_);
		var _loc5_:String;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_.___keys()) {
				_loc5_ = _tmp_;
				_loc3_.queueStarlingAssetsForProps(_loc5_, ASCompat.coerce(_loc2_[_loc5_], Array));
			}
		releaseLastDungeonAtlases();
	}

	function releaseLastDungeonAtlases() {
		var _loc1_:DistributedDungionArea = null;
		var _loc2_ = mDBFacade.assetLoadingComponent;
		if (mEntryReleaseChecked || !mEntryPropAtlasesQueued || _loc2_ == null) {
			return;
		}
		if (_loc2_.isStarlingLoadPending) {
			if (mEntryReleaseEvents == null) {
				mEntryReleaseEvents = new EventComponent(mDBFacade);
				mEntryReleaseEvents.addListener("StarlingAssetsReady", onEntryReleaseAssetsReady);
			}
			return;
		}
		mEntryReleaseChecked = true;
		stopEntryReleaseEvents();
		if (Std.isOfType(mDBFacade.mainStateMachine.currentState, LoadingScreenState)) {
			_loc1_ = ASCompat.reinterpretAs(parentArea, DistributedDungionArea);
			mPrewarm = LoadingPrewarm.startLoadingAndRelease(mDBFacade, _loc1_ != null ? _loc1_.mCacheNpc : null, mEntryGeneration);
		}
	}

	function onEntryReleaseAssetsReady(e:Event) {
		releaseLastDungeonAtlases();
	}

	function stopEntryReleaseEvents() {
		if (mEntryReleaseEvents != null) {
			mEntryReleaseEvents.destroy();
			mEntryReleaseEvents = null;
		}
	}

	function requestEntryHero() {
		mHeroEntryWanted = true;
		if (parentArea == null) {
			return;
		}
		if (!mFloorTilesRequested) {
			return;
		}
		var _loc1_ = mDBFacade.assetLoadingComponent;
		if (_loc1_ != null && _loc1_.isStarlingLoadPending) {
			if (!mAwaitingStarlingAssets) {
				mAwaitingStarlingAssets = true;
				mEventComponent.addListener("StarlingAssetsReady", onStarlingAssetsReady);
			}
			return;
		}
		releaseLastDungeonAtlases();
		if (mPrewarm != null && mPrewarm.running) {
			mPrewarm.hold(requestEntryHero);
			return;
		}
		mHeroEntryWanted = false;
		BakeScheduler.floorLoaded();
		mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_HERO"));
	}

	function onStarlingAssetsReady(e:Event) {
		mAwaitingStarlingAssets = false;
		mEventComponent.removeListener("StarlingAssetsReady");
		requestEntryHero();
	}

	override public function SetParentArea(area:Area) {
		super.SetParentArea(area);
		queueEntryAtlases();
		if (mHeroEntryWanted) {
			requestEntryHero();
		}
	}

	public function show_text(textkey:String) {
		var _loc2_ = new FloorMessageView(mDBFacade, textkey);
		MemoryTracker.track(_loc2_, "FloorMessageView - created in DistributedDungeonFloor.show_text()");
	}

	public function play_sound(sound:String) {
		mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), sound, function(param1:brain.sound.SoundAsset) {
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
		var _loc4_ = (0 : UInt);
		var _loc2_ = false;
		var _loc5_ = (0 : UInt);
		if (mPostGenerate) {
			_loc3_ = new Vector<DungeonTileUsage>();
			_loc4_ = (0 : UInt);
			while (_loc4_ < (tiles.length:UInt)) {
				_loc2_ = false;
				_loc5_ = (0 : UInt);
				while (_loc5_ < (mTileNetworkComponents.length:UInt)) {
					if (tiles[(_loc4_ : Int)].x == mTileNetworkComponents[(_loc5_ : Int)].x
						&& tiles[(_loc4_ : Int)].y == mTileNetworkComponents[(_loc5_ : Int)].y) {
						_loc2_ = true;
					}
					_loc5_++;
				}
				if (!_loc2_) {
					_loc3_.push(tiles[(_loc4_ : Int)]);
				}
				_loc4_++;
			}
			buildTiles(_loc3_, false);
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

	function buildTiles(tiles:Vector<DungeonTileUsage>, clearGroundLayer:Bool) {
		mDungeonFloorFactory.buildDungeonFloor(tiles, finishedBuildingTiles, clearGroundLayer);
		if (tiles != null && tiles.length > 0) {
			onFloorTilesRequested();
		}
	}

	function onFloorTilesRequested() {
		mFloorTilesRequested = true;
		queueEntryPropAtlases();
		if (mHeroEntryWanted) {
			requestEntryHero();
		}
	}

	function fillInEmptyTilesWithCollisionVolumes() {
		var _loc9_ = (0 : UInt);
		var _loc5_ = (0 : UInt);
		var _loc6_:Tile = null;
		var _loc2_ = Math.NaN;
		var _loc1_ = Math.NaN;
		var _loc7_:Vector3D = null;
		var _loc11_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc4_:Vector3D = null;
		var _loc10_ = Math.NaN;
		var _loc8_:RectangleNavCollider = null;
		_loc9_ = (0 : UInt);
		while (_loc9_ < 12) {
			_loc5_ = (0 : UInt);
			while (_loc5_ < 12) {
				_loc6_ = mTileGrid.getTileAtIndex(_loc5_, _loc9_);
				if (_loc6_ == null || _loc6_.isGeneratedFiller) {
					if (mTileGrid.getEmptyColliderAtIndex(_loc5_, _loc9_) == null) {
						_loc2_ = 0;
						_loc1_ = 0;
						_loc7_ = new Vector3D(_loc2_, _loc1_);
						_loc11_ = 900 * _loc5_ - 900 * 0.5;
						_loc3_ = 900 * _loc9_ - 900 * 0.5;
						_loc4_ = new Vector3D(_loc11_, _loc3_);
						_loc10_ = 0;
						_loc8_ = new RectangleNavCollider(mDBFacade, null, _loc7_, _loc10_, mB2World, 900 * 0.5, 900 * 0.5);
						_loc8_.position = _loc4_;
						mTileGrid.SetEmptyColliderAtIndex(_loc5_, _loc9_, _loc8_);
					}
				}
				_loc5_++;
			}
			_loc9_++;
		}
	}

	override public function destroy() {
		var _loc3_:DooberGameObject = null;
		Logger.debug("destroy DistributedDungeonFloor " + Std.string(id));
		if (mViewHold != null) {
			mViewHold.stop();
			mViewHold = null;
		}
		mEventComponent.dispatchEvent(new Event("DUNGEON_FLOOR_DESTROY"));
		BakeScheduler.floorPurged();
		stopEntryReleaseEvents();
		LoadingPrewarm.cancelLoading();
		mPrewarm = null;
		mActiveOwnerAvatar = null;
		if (mBgMusic != null) {
			EventListeners.remove(mBgMusic, "complete", onBgMusicLoaded);
			EventListeners.remove(mBgMusic, "ioError", onBgMusicError);
			EventListeners.remove(mBgMusic, "securityError", onBgMusicError);
			try {
				mBgMusic.close();
			} catch (e:Dynamic) {}
			mBgMusic = null;
		}
		if (mDBSoundComponent != null) {
			mDBSoundComponent.destroy();
			mDBSoundComponent = null;
		}
		if (mIntroMovieAsset != null) {
			mDBFacade.assetRepository.removeFromCache(mIntroMovieAsset);
			mIntroMovieAsset = null;
		}
		destroyIntroOverlay();
		destroyIntroVideo();
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		mDungeonFloorFactory.destroy();
		mDungeonFloorFactory = null;
		var _loc7_:Array<ASAny> = [];
		var _loc4_ = ASCompat.reinterpretAs(mRemoteHeroes.iterator(), IMapIterator);
		while (_loc4_.hasNext()) {
			_loc7_.push(_loc4_.next());
		}
		var _loc8_:HeroGameObject;
		if (checkNullIteratee(_loc7_))
			for (_tmp_ in _loc7_) {
				_loc8_ = ASCompat.coerce(_tmp_, distributedObjects.HeroGameObject);
				if (_loc8_ != null) {
					_loc8_.destroy();
				}
			}
		mRemoteHeroes.clear();
		mRemoteHeroes = null;
		var _loc6_:Array<ASAny> = [];
		var _loc5_ = ASCompat.reinterpretAs(mRemoteActors.iterator(), IMapIterator);
		while (_loc5_.hasNext()) {
			_loc6_.push(_loc5_.next());
		}
		var _loc1_:ActorGameObject;
		if (checkNullIteratee(_loc6_))
			for (_tmp_ in _loc6_) {
				_loc1_ = ASCompat.coerce(_tmp_, actor.ActorGameObject);
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
			}
		mRemoteActors.clear();
		mRemoteActors = null;
		var _loc11_:ASObject;
		final __ax4_iter_326 = mDoobers;
		if (checkNullIteratee(__ax4_iter_326))
			for (_tmp_ in __ax4_iter_326.keys()) {
				_loc11_ = _tmp_;
				_loc3_ = ASCompat.dynamicAs(_loc11_, DooberGameObject);
				if (_loc3_ != null && !_loc3_.isDestroyed) {
					_loc3_.destroy();
				}
			}
		mDoobers = null;
		var _loc2_:Array<ASAny> = [];
		var _loc9_:ASObject;
		final __ax4_iter_327 = mProjectiles;
		if (checkNullIteratee(__ax4_iter_327))
			for (_tmp_ in __ax4_iter_327.keys()) {
				_loc9_ = _tmp_;
				_loc2_.push(_loc9_);
			}
		var _loc10_:ProjectileGameObject;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc10_ = ASCompat.coerce(_tmp_, projectile.ProjectileGameObject);
				if (_loc10_ != null && !_loc10_.isDestroyed) {
					_loc10_.destroyForFloorShutdown();
				}
			}
		mProjectiles = null;
		mFloorObjectsAwaitingDungeonFloor.clear();
		mFloorObjectsAwaitingDungeonFloor = null;
		mTileGrid.destroy();
		mTileGrid = null;
		mEffectManager.destroy();
		mEffectManager = null;
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
		var _loc4_ = (0 : UInt);
		if (mTileNetworkComponents.length == 0) {
			Logger.error("Invalid tile location in getTileNetworkComponentAtLocation");
			return null;
		}
		var _loc2_ = ASCompat.floatToInt(mActiveOwnerAvatar.position.x);
		var _loc3_ = ASCompat.floatToInt(mActiveOwnerAvatar.position.y);
		var _loc5_ = mTileNetworkComponents[0];
		var _loc1_ = getDistanceFromTileUsage(_loc2_, _loc3_, _loc5_);
		var _loc6_ = 0;
		_loc4_ = (1 : UInt);
		while (_loc4_ < (mTileNetworkComponents.length:UInt)) {
			_loc6_ = getDistanceFromTileUsage(_loc2_, _loc3_, mTileNetworkComponents[(_loc4_ : Int)]);
			if (_loc6_ < _loc1_) {
				_loc1_ = _loc6_;
				_loc5_ = mTileNetworkComponents[(_loc4_ : Int)];
			}
			_loc4_++;
		}
		return _loc5_.tileId;
	}

	function getDistanceFromTileUsage(x:Int, y:Int, dtu:DungeonTileUsage):Int {
		var _loc4_ = new Point(x, y);
		var _loc5_ = new Point(dtu.x + 450, dtu.y + 450);
		return ASCompat.floatToInt(Point.distance(_loc4_, _loc5_));
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
		return mMapNode.NodeType == GMMapNode.TAVERN_NODE_TYPE;
	}
}
