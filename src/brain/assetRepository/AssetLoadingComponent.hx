package brain.assetRepository;

import brain.component.Component;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import collections.ISetIterator;
import collections.Set;
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import starling.assets.AssetFactory;
import starling.assets.AssetReference;
import starling.core.Starling;
import starling.extensions.animate.AnimAssetManager;
import starling.extensions.animate.Animation;
import starling.extensions.animate.AnimationAtlas;
import starling.textures.Texture;
import starling.textures.TextureOptions;

class AssetLoadingComponent extends Component {
	public static inline final STARLING_ASSETS_QUEUED = "StarlingAssetsQueued";

	public static inline final STARLING_ASSETS_READY = "StarlingAssetsReady";

	public static inline final OUT_OF_GRAPHICS_RESOURCES = "Out of graphics resources. Please restart the game.";

	static inline final AIR32_TEXTURE_BUDGET_MIB = 1792;

	static inline final PROP_KEY_PREFIX = "prop:";

	static inline final MAX_CONCURRENT_BUNDLE_LOADS = 3;

	static inline final MAX_TOTAL_CONNECTIONS = 3;

	public static inline final TIER_BODY = 0;

	public static inline final TIER_WEAPON = 1;

	public static inline final TIER_EFFECT = 2;

	public static inline final TIER_UNCLASSIFIED = 3;

	public static inline final TIER_PET = 4;

	static var sRootClipLabels:ASObject;

	static var sFolderScales:ASObject;

	public var mPendingDownloads:Set;

	public var mStarlingAssetManager:AnimAssetManager;

	var mBundleManagers:ASObject = {};

	var mLoadedBiomeKeys:ASObject = {};

	var mPendingBiomeKeys:Vector<String> = new Vector();

	var mBiomeKeyCallbacks:ASObject = {};

	var mCallbackKeyOrder:Vector<String> = new Vector();

	var mLoadingBiomeKeys:Vector<String> = new Vector();

	var mBackgroundKeys:ASObject = {};

	var mBackgroundTiers:ASObject = {};

	var mLoadingAssetFiles:ASObject = {};

	var mIsStartingLoads:Bool = false;

	var mFloorRequestKeys:ASObject = {};

	var mKeptResidentKeys:ASObject = {};

	var mFloorKeysLoading:ASObject = {};

	var mCurrentFloorBiome:String;

	var mRequestedFloorBiome:String;

	var mFloorGeneration:Int = 1;

	var mEntryBegun:Bool = false;

	var mKeyLastUsed:ASObject = {};

	var mStarlingLoadActive:Bool = false;

	var mLoadingProgress:ASObject = {};

	var mStarlingBundlesLoaded:UInt = (0 : UInt);

	var mIsDrainingCompletion:Bool = false;

	var mPropManifests:ASObject = {};

	var mAnimationOwners:ASObject = {};

	var mBundleAnimationNames:ASObject = {};

	var mLabelOwners:ASObject = {};

	var mBundleLabelNames:ASObject = {};

	var mAtlasOwners:ASObject = {};

	var mBundleAtlasNames:ASObject = {};

	var mTransitionToEmptyFunction:ASFunction;

	var mAssetRepository:AssetRepository;

	var mStarlingPurgeCount:Int = 0;

	var mOverrideAssetFiles:ASObject = {};

	var mStartedBundles:Array<ASAny> = [];

	var mBundleConnections:ASObject = {};

	var mConnectionsInUse:Int = 0;

	var mBundleFactories:Array<ASAny> = [];

	public function new(facade:Facade) {
		super(facade);
		mAssetRepository = facade.assetRepository;
		mPendingDownloads = new Set();
	}

	static function getPropKey(libraryKey:String, assetClassName:String):String {
		return "prop:" + libraryKey + "/" + assetClassName;
	}

	static function rootClipLabels(folder:File):ASObject {
		var _loc8_:ASObject;
		var __ax4_iter_387:ASAny;
		var _loc11_:ASObject;
		var __ax4_iter_388:ASAny;
		var _loc9_:ASObject = null;
		var _loc5_:File = null;
		var _loc4_:FileStream = null;
		var _loc3_:ASObject = null;
		var _loc10_:ASObject = null;
		var _loc6_:ASObject = null;
		var _loc7_:String = null;
		var _loc2_ = folder.nativePath;
		if (!sRootClipLabels.hasOwnProperty(_loc2_)) {
			_loc9_ = {};
			_loc5_ = folder.resolvePath("Animation.json");
			if (_loc5_.exists) {
				try {
					_loc4_ = new FileStream();
					_loc4_.open(_loc5_, flash.filesystem.FileMode.READ);
					{
						try {
							_loc3_ = haxe.Json.parse(_loc4_.readUTFBytes(_loc4_.bytesAvailable));
						} catch (__finallyError0:Dynamic) {
							{
								_loc4_.close();
							};
							ASCompat.rethrowKeepingStack(__finallyError0);
							throw __finallyError0;
						};
						{
							_loc4_.close();
						};
					}
					_loc10_ = if (ASCompat.toBool(_loc3_.AN)) _loc3_.AN else _loc3_.ANIMATION;
					_loc6_ = _loc10_ != null ?if (ASCompat.toBool(_loc10_.TL))
						_loc10_.TL
					else
						_loc10_.TIMELINE:null;
					__ax4_iter_387 = _loc6_ != null ?if (ASCompat.toBool(_loc6_.L))
						_loc6_.L
					else
						_loc6_.LAYERS:null;
					if (checkNullIteratee(__ax4_iter_387))
						for (_tmp_ in __ax4_iter_387) {
							_loc8_ = _tmp_;
							__ax4_iter_388 = if (ASCompat.toBool(_loc8_.FR)) _loc8_.FR else _loc8_.Frames;
							if (checkNullIteratee(__ax4_iter_388))
								for (_tmp_ in __ax4_iter_388) {
									_loc11_ = _tmp_;
									_loc7_ = if (ASCompat.toBool(_loc11_.N)) _loc11_.N else _loc11_.name;
									if (ASCompat.stringAsBool(_loc7_)) {
										_loc9_[_loc7_] = true;
									}
								}
						}
				} catch (e:Dynamic) {
					Logger.error("AssetLoadingComponent.rootClipLabels: could not read " + _loc5_.nativePath + ": " + Std.string(e.message));
				}
			}
			sRootClipLabels[_loc2_] = _loc9_;
		}
		return sRootClipLabels[_loc2_];
	}

	static function scaleForFolder(folder:File):Float {
		var _loc3_:StarlingPropManifest = null;
		if (folder == null) {
			return 1;
		}
		var _loc2_ = folder.nativePath;
		if (!sFolderScales.hasOwnProperty(_loc2_)) {
			_loc3_ = new StarlingPropManifest();
			_loc3_.load(folder.resolvePath("flattened_registration.json"));
			sFolderScales[_loc2_] = _loc3_.scaleForFolder(folder);
		}
		return ASCompat.toNumber(sFolderScales[_loc2_]);
	}

	static function withThousands(value:Float):String {
		var _loc2_ = 0;
		var _loc3_ = Std.string(value);
		_loc2_ = _loc3_.length - 3;
		while (_loc2_ > 0) {
			_loc3_ = _loc3_.substr(0, _loc2_) + "," + _loc3_.substr(_loc2_);
			_loc2_ -= 3;
		}
		return _loc3_;
	}

	static function addOwner(owners:ASObject, names:Vector<String>, bundleKey:String) {
		var _loc4_:Vector<String> = /*undefined*/ null;
		var _loc5_:String;
		if (checkNullIteratee(names))
			for (_tmp_ in names) {
				_loc5_ = _tmp_;
				_loc4_ = (owners[_loc5_] : Vector<String>);
				if (_loc4_ == null) {
					_loc4_ = new Vector<String>();
					owners[_loc5_] = _loc4_;
				}
				if (_loc4_.indexOf(bundleKey) == -1) {
					_loc4_.push(bundleKey);
				}
			}
	}

	static function removeOwner(owners:ASObject, names:Vector<String>, bundleKey:String) {
		var _loc4_:Vector<String> = /*undefined*/ null;
		var _loc6_ = 0;
		var _loc5_:String;
		if (checkNullIteratee(names))
			for (_tmp_ in names) {
				_loc5_ = _tmp_;
				_loc4_ = (owners[_loc5_] : Vector<String>);
				_loc6_ = _loc4_ != null ? _loc4_.indexOf(bundleKey) : -1;
				if (_loc6_ != -1) {
					_loc4_.splice(_loc6_, (1 : UInt));
					if (_loc4_.length == 0) {
						ASCompat.deleteProperty(owners, _loc5_);
					}
				}
			}
	}

	static function findLibraryOwner(owners:Vector<String>, libraryKey:String):String {
		var _loc4_ = getPropKey(libraryKey, "");
		var _loc5_ = StarlingAssetMapper.getPropsOnlyKey(libraryKey);
		var _loc3_:String;
		if (checkNullIteratee(owners))
			for (_tmp_ in owners) {
				_loc3_ = _tmp_;
				if (_loc3_ == libraryKey || _loc3_ == _loc5_ || _loc3_.indexOf(_loc4_) == 0) {
					return _loc3_;
				}
			}
		return null;
	}

	@:isVar public var starlingPurgeCount(get, never):Int;

	public function get_starlingPurgeCount():Int {
		return mStarlingPurgeCount;
	}

	public function initializeStarlingAssetManager() {
		if (mStarlingAssetManager != null) {
			return;
		}
		mStarlingAssetManager = new AnimAssetManager();
		mStarlingAssetManager.verbose = false;
		registerStarlingFactory(new SafeAtfTextureFactory(), 1);
		registerStarlingFactory(new SafeXmlFactory(), 1);
	}

	public function registerStarlingFactory(factory:AssetFactory, priority:Int) {
		mStarlingAssetManager.registerFactory(factory, priority);
		mBundleFactories.push({
			"factory": factory,
			"priority": priority
		});
	}

	function newBundleManager():AnimAssetManager {
		var _loc2_ = new AnimAssetManager();
		_loc2_.verbose = false;
		var _loc1_:ASObject;
		final __ax4_iter_389 = mBundleFactories;
		if (checkNullIteratee(__ax4_iter_389))
			for (_tmp_ in __ax4_iter_389) {
				_loc1_ = _tmp_;
				_loc2_.registerFactory(ASCompat.coerce(_loc1_.factory, starling.assets.AssetFactory), ASCompat.toInt(_loc1_.priority));
			}
		return _loc2_;
	}

	@:isVar public var isStarlingReady(get, never):Bool;

	public function get_isStarlingReady():Bool {
		return mStarlingAssetManager != null;
	}

	@:isVar public var isStarlingLoadPending(get, never):Bool;

	public function get_isStarlingLoadPending():Bool {
		return mStarlingLoadActive;
	}

	@:isVar public var currentFloorBiome(get, never):String;

	public function get_currentFloorBiome():String {
		return mCurrentFloorBiome;
	}

	@:isVar public var requestedFloorBiome(get, never):String;

	public function get_requestedFloorBiome():String {
		return mRequestedFloorBiome;
	}

	public function isStarlingKeyResident(biomeKey:String):Bool {
		return mStarlingAssetManager != null && mLoadedBiomeKeys[biomeKey] == true;
	}

	public function queueStarlingAssetsForPath(assetPath:String, onComplete:ASFunction = null, isFloorRequest:Bool = false, isBackground:Bool = false,
			backgroundTier:Int = 3) {
		var _loc6_:String = null;
		var _loc7_ = StarlingAssetMapper.getActorAtlasFile(assetPath);
		if (_loc7_ != null) {
			_loc6_ = StarlingAssetMapper.getActorAtlasKeyFromPath(assetPath);
			queueStarlingAssets(_loc6_, onComplete, false, [_loc7_], isBackground, backgroundTier);
			return;
		}
		var _loc8_ = isFloorRequest ? StarlingAssetMapper.getBiomeKeyFromPath(assetPath) : StarlingAssetMapper.getPropLibraryKey(assetPath,
			mRequestedFloorBiome);
		queueStarlingAssets(_loc8_, onComplete, isFloorRequest, null, isBackground, backgroundTier);
	}

	public function queueStarlingAssetsForProps(assetPath:String, animatedClassNames:Array<ASAny>, onComplete:ASFunction = null, isBackground:Bool = false,
			backgroundTier:Int = 3) {
		if (mStarlingAssetManager == null || animatedClassNames == null || animatedClassNames.length == 0) {
			queueStarlingAssetsForPath(assetPath, onComplete, false, isBackground, backgroundTier);
			return;
		}
		queueStarlingAssetsForPath(assetPath, function() {
			var __ax4_iter_390:Array<ASAny>;
			var className:String;
			var libraryKey:String;
			var atlasFolder:File;
			var biomeKey = StarlingAssetMapper.getBiomeKeyFromPath(assetPath);
			var remaining = 1;
			var onPropComplete:ASFunction = function() {
				if (--remaining == 0 && onComplete != null) {
					onComplete();
				}
			};
			if (checkNullIteratee(animatedClassNames))
				for (_tmp_ in animatedClassNames) {
					className = _tmp_;
					__ax4_iter_390 = [biomeKey, "shared"];
					if (checkNullIteratee(__ax4_iter_390))
						for (_tmp_ in __ax4_iter_390) {
							libraryKey = _tmp_;
							atlasFolder = StarlingAssetMapper.getPropAtlasFile(libraryKey, className);
							if (atlasFolder != null) {
								remaining = remaining + 1;
								queueStarlingAssets(getPropKey(libraryKey, className), onPropComplete, false, [atlasFolder], isBackground, backgroundTier);
								break;
							}
						}
				}
			onPropComplete();
		}, false, isBackground, backgroundTier);
	}

	function isStalePropKey(biomeKey:String):Bool {
		return biomeKey.indexOf("prop:") == 0 && ASCompat.toNumber(mKeyLastUsed[biomeKey]) < mFloorGeneration;
	}

	function isSharedUnresolved():Bool {
		var _loc1_ = "shared";
		return mPendingBiomeKeys.indexOf(_loc1_) != -1 || mLoadingBiomeKeys.indexOf(_loc1_) != -1;
	}

	public function queueStarlingAssets(biomeKey:String, onComplete:ASFunction = null, isFloorRequest:Bool = false, assetFiles:Array<ASAny> = null,
			isBackground:Bool = false, backgroundTier:Int = 3) {
		var _loc12_:String;
		var __ax4_iter_391:Vector<String>;
		var _loc8_:Vector<ASFunction> = /*undefined*/ null;
		var _loc11_ = false;
		if (mStarlingAssetManager == null) {
			if (onComplete != null) {
				onComplete();
			}
			return;
		}
		isBackground = isBackground && !isFloorRequest && biomeKey != "shared";
		var _loc10_ = isFloorRequest && mCurrentFloorBiome != null && mCurrentFloorBiome != biomeKey;
		if (isFloorRequest) {
			mRequestedFloorBiome = biomeKey;
		}
		if (_loc10_ && !ASCompat.toBool(mFloorRequestKeys[biomeKey]) && !mEntryBegun) {
			mFloorGeneration = mFloorGeneration + 1;
		}
		if (isFloorRequest) {
			mEntryBegun = false;
		}
		mKeyLastUsed[biomeKey] = mFloorGeneration;
		var _loc9_ = biomeKey != "shared" && isSharedUnresolved();
		if (ASCompat.toBool(mLoadedBiomeKeys[biomeKey]) && !_loc9_) {
			if (!isFloorRequest || mCurrentFloorBiome == biomeKey) {
				if (onComplete != null) {
					onComplete();
				}
				return;
			}
			if (mCurrentFloorBiome == null) {
				mCurrentFloorBiome = biomeKey;
				if (onComplete != null) {
					onComplete();
				}
				return;
			}
		}
		if (isFloorRequest) {
			__ax4_iter_391 = mPendingBiomeKeys;
			if (checkNullIteratee(__ax4_iter_391))
				for (_tmp_ in __ax4_iter_391) {
					_loc12_ = _tmp_;
					if (_loc12_ != biomeKey && ASCompat.toBool(mFloorRequestKeys[_loc12_])) {
						ASCompat.deleteProperty(mFloorRequestKeys, _loc12_);
					}
				}
		}
		if (isFloorRequest && mCurrentFloorBiome != biomeKey) {
			mFloorRequestKeys[biomeKey] = mFloorGeneration;
		}
		if (onComplete != null) {
			_loc8_ = (mBiomeKeyCallbacks[biomeKey] : Vector<ASFunction>);
			if (_loc8_ == null) {
				_loc8_ = new Vector<ASFunction>();
				mBiomeKeyCallbacks[biomeKey] = _loc8_;
				mCallbackKeyOrder.push(biomeKey);
			}
			_loc8_.push(onComplete);
		}
		if (ASCompat.toBool(mLoadedBiomeKeys[biomeKey]) && !ASCompat.toBool(mFloorRequestKeys[biomeKey])) {
			return;
		}
		if (mLoadingBiomeKeys.indexOf(biomeKey) != -1) {
			if (!isBackground && ASCompat.toBool(mBackgroundKeys[biomeKey])) {
				dropBackground(biomeKey);
				startPendingLoads();
			}
			return;
		}
		var _loc13_ = mPendingBiomeKeys.indexOf(biomeKey);
		if (_loc13_ != -1) {
			_loc11_ = isFloorRequest && ASCompat.toBool(mFloorRequestKeys[biomeKey]);
			if (ASCompat.toBool(mBackgroundKeys[biomeKey]) && (!isBackground || isFloorRequest)) {
				dropBackground(biomeKey);
				_loc11_ = true;
			} else if (isBackground
				&& ASCompat.toBool(mBackgroundKeys[biomeKey])
				&& backgroundTier < ASCompat.toInt(mBackgroundTiers[biomeKey])) {
				mBackgroundTiers[biomeKey] = backgroundTier;
				_loc11_ = true;
			}
			if (_loc11_) {
				mPendingBiomeKeys.splice(_loc13_, (1 : UInt));
				enqueuePendingKey(biomeKey);
				startPendingLoads();
			}
			return;
		}
		if (assetFiles != null && assetFiles.length > 0) {
			mOverrideAssetFiles[biomeKey] = assetFiles;
		} else if (!StarlingAssetMapper.isKnownBiome(biomeKey)) {
			mLoadedBiomeKeys[biomeKey] = true;
			flushBiomeKeyCallbacks(biomeKey);
			return;
		}
		var _loc7_ = "shared";
		if ((assetFiles == null || assetFiles.length == 0)
			&& biomeKey != _loc7_
			&& !ASCompat.toBool(mLoadedBiomeKeys[_loc7_])
			&& mPendingBiomeKeys.indexOf(_loc7_) == -1
			&& mLoadingBiomeKeys.indexOf(_loc7_) == -1) {
			mKeyLastUsed[_loc7_] = mFloorGeneration;
			enqueuePendingKey(_loc7_);
		}
		if (isBackground) {
			mBackgroundKeys[biomeKey] = true;
			mBackgroundTiers[biomeKey] = backgroundTier;
		}
		enqueuePendingKey(biomeKey);
		startPendingLoads();
	}

	function enqueuePendingKey(biomeKey:String) {
		var _loc2_ = 0;
		if (ASCompat.toBool(mFloorRequestKeys[biomeKey])) {
			mPendingBiomeKeys.unshift(biomeKey);
			return;
		}
		if (biomeKey == "shared") {
			_loc2_ = 0;
			while (_loc2_ < mPendingBiomeKeys.length && ASCompat.toBool(mFloorRequestKeys[mPendingBiomeKeys[_loc2_]])) {
				_loc2_++;
			}
			ASCompat.vectorSplice(mPendingBiomeKeys, _loc2_, (0 : UInt), [biomeKey]);
			return;
		}
		_loc2_ = mPendingBiomeKeys.length;
		var _loc3_ = ASCompat.toBool(mBackgroundKeys[biomeKey]);
		while (_loc2_ > 0
			&& ASCompat.toBool(mBackgroundKeys[mPendingBiomeKeys[_loc2_ - 1]])
			&& (!_loc3_ || ASCompat.toInt(mBackgroundTiers[mPendingBiomeKeys[_loc2_ - 1]]) > ASCompat.toInt(mBackgroundTiers[biomeKey]))) {
			_loc2_--;
		}
		ASCompat.vectorSplice(mPendingBiomeKeys, _loc2_, (0 : UInt), [biomeKey]);
	}

	function dropBackground(biomeKey:String) {
		ASCompat.deleteProperty(mBackgroundKeys, biomeKey);
		ASCompat.deleteProperty(mBackgroundTiers, biomeKey);
	}

	@:isVar var isFloorSlotReserved(get, never):Bool;

	function get_isFloorSlotReserved():Bool {
		return mEntryBegun;
	}

	function startPendingLoads() {
		var _loc1_:String = null;
		var _loc2_:Array<ASAny> = null;
		if (mIsStartingLoads || mIsDrainingCompletion) {
			return;
		}
		mIsStartingLoads = true;
		{
			try {
				while (mPendingBiomeKeys.length > 0 && mLoadingBiomeKeys.length < 3) {
					_loc1_ = mPendingBiomeKeys[0];
					if (ASCompat.toBool(mBackgroundKeys[_loc1_]) && loadingBackgroundCount() > 0) {
						break;
					}
					if (isSwitchWaitingOnLoads(_loc1_)) {
						break;
					}
					if (!ASCompat.toBool(mFloorRequestKeys[_loc1_]) && isFloorSlotReserved && mLoadingBiomeKeys.length >= 3 - 1) {
						break;
					}
					_loc2_ = ASCompat.dynamicAs(mOverrideAssetFiles[_loc1_], Array);
					if (_loc2_ == null) {
						_loc2_ = StarlingAssetMapper.getAssetFilesForBiome(_loc1_, false);
					}
					if (overlapsActiveFiles(_loc2_)) {
						break;
					}
					startBiomeLoad(mPendingBiomeKeys.shift());
				}
			} catch (__finallyError0:Dynamic) {
				{
					mIsStartingLoads = false;
					loadStartedBundles();
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				mIsStartingLoads = false;
				loadStartedBundles();
			};
		}
		updateBlockingLoadState();
	}

	function updateBlockingLoadState() {
		if (mIsDrainingCompletion || mIsStartingLoads) {
			return;
		}
		var _loc1_ = loadingBlockingCount() > 0 || pendingBlockingCount() > 0;
		if (_loc1_ == mStarlingLoadActive) {
			return;
		}
		mStarlingLoadActive = _loc1_;
		mFacade.eventManager.dispatchEvent(new Event(_loc1_ ? "StarlingAssetsQueued" : "StarlingAssetsReady"));
	}

	function loadingBlockingCount():Int {
		var _loc1_ = 0;
		var _loc2_:String;
		final __ax4_iter_392 = mLoadingBiomeKeys;
		if (checkNullIteratee(__ax4_iter_392))
			for (_tmp_ in __ax4_iter_392) {
				_loc2_ = _tmp_;
				if (!ASCompat.toBool(mBackgroundKeys[_loc2_])) {
					_loc1_++;
				}
			}
		return _loc1_;
	}

	function pendingBlockingCount():Int {
		var _loc1_ = 0;
		var _loc2_:String;
		final __ax4_iter_393 = mPendingBiomeKeys;
		if (checkNullIteratee(__ax4_iter_393))
			for (_tmp_ in __ax4_iter_393) {
				_loc2_ = _tmp_;
				if (!ASCompat.toBool(mBackgroundKeys[_loc2_])) {
					_loc1_++;
				}
			}
		return _loc1_;
	}

	function loadingBackgroundCount():Int {
		return mLoadingBiomeKeys.length - loadingBlockingCount();
	}

	function isSwitchWaitingOnLoads(biomeKey:String):Bool {
		var _loc4_ = ASCompat.toInt(mFloorRequestKeys[biomeKey]);
		if (_loc4_ == 0) {
			return false;
		}
		var _loc2_:String;
		final __ax4_iter_394:ASObject = mFloorKeysLoading;
		if (checkNullIteratee(__ax4_iter_394))
			for (_tmp_ in __ax4_iter_394.___keys()) {
				_loc2_ = _tmp_;
				if (_loc2_ != biomeKey) {
					return true;
				}
			}
		if (mCurrentFloorBiome == null || mCurrentFloorBiome == biomeKey) {
			return false;
		}
		var _loc3_:String;
		final __ax4_iter_395 = mLoadingBiomeKeys;
		if (checkNullIteratee(__ax4_iter_395))
			for (_tmp_ in __ax4_iter_395) {
				_loc3_ = _tmp_;
				if (!ASCompat.toBool(mBackgroundKeys[_loc3_]) && isStaleAtSwitch(_loc3_, _loc4_)) {
					return true;
				}
			}
		return false;
	}

	function loadStartedBundles() {
		var _loc4_ = 0;
		var _loc5_ = 0;
		if (mStartedBundles.length == 0) {
			return;
		}
		var _loc2_ = mStartedBundles;
		mStartedBundles = [];
		var _loc6_ = ASCompat.floatToInt(Math.max(0, 3 - mConnectionsInUse));
		var _loc1_:Array<ASAny> = [];
		_loc4_ = 0;
		while (_loc4_ < _loc2_.length) {
			_loc1_.push(0);
			_loc4_++;
		}
		var _loc3_ = true;
		while (_loc6_ > 0 && _loc3_) {
			_loc3_ = false;
			_loc4_ = 0;
			while (_loc4_ < _loc2_.length && _loc6_ > 0) {
				if (ASCompat.toNumber(_loc1_[_loc4_]) < queuedAssetCount(ASCompat.coerce(_loc2_[_loc4_].bundle,
					starling.extensions.animate.AnimAssetManager))) {
					_loc1_[_loc4_] = ASCompat.toInt(_loc1_[_loc4_]) + 1;
					_loc6_--;
					_loc3_ = true;
				}
				_loc4_++;
			}
		}
		_loc4_ = 0;
		while (_loc4_ < _loc2_.length) {
			_loc5_ = ASCompat.floatToInt(Math.max(1, ASCompat.toNumber(_loc1_[_loc4_])));
			ASCompat.setProperty(_loc2_[_loc4_].bundle, "numConnections", _loc5_);
			mBundleConnections[_loc2_[_loc4_].key] = _loc5_;
			mConnectionsInUse += _loc5_;
			_loc4_++;
		}
		_loc4_ = 0;
		while (_loc4_ < _loc2_.length) {
			loadBundle(_loc2_[_loc4_].key, ASCompat.coerce(_loc2_[_loc4_].bundle, starling.extensions.animate.AnimAssetManager));
			_loc4_++;
		}
	}

	function overlapsActiveFiles(files:Array<ASAny>):Bool {
		var _loc3_:File;
		var _loc5_:File;
		var _loc4_:String = null;
		var _loc6_:String = null;
		var _loc2_:Array<ASAny>;
		final __ax4_iter_396:ASObject = mLoadingAssetFiles;
		if (checkNullIteratee(__ax4_iter_396))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_396)) {
				_loc2_ = ASCompat.coerce(_tmp_, Array);
				if (checkNullIteratee(files))
					for (_tmp_ in files) {
						_loc3_ = ASCompat.coerce(_tmp_, flash.filesystem.File);
						_loc4_ = new compat.RegExp("\\\\", "g").replace(_loc3_.nativePath, "/") + "/";
						if (checkNullIteratee(_loc2_))
							for (_tmp_ in _loc2_) {
								_loc5_ = ASCompat.coerce(_tmp_, flash.filesystem.File);
								_loc6_ = new compat.RegExp("\\\\", "g").replace(_loc5_.nativePath, "/") + "/";
								if (_loc4_.indexOf(_loc6_) == 0 || _loc6_.indexOf(_loc4_) == 0) {
									return true;
								}
							}
					}
			}
		return false;
	}

	function startBiomeLoad(biomeKey:String) {
		var _loc7_:File;
		var _loc9_:File;
		var _loc6_ = 0;
		var _loc2_:StarlingPropManifest = null;
		var _loc11_:Array<ASAny> = null;
		var _loc13_:Array<ASAny> = null;
		var _loc3_:ASObject = null;
		if (isStalePropKey(biomeKey)) {
			ASCompat.deleteProperty(mOverrideAssetFiles, biomeKey);
			ASCompat.deleteProperty(mKeyLastUsed, biomeKey);
			dropBackground(biomeKey);
			flushBiomeKeyCallbacks(biomeKey);
			return;
		}
		mLoadingBiomeKeys.push(biomeKey);
		if (ASCompat.toBool(mFloorRequestKeys[biomeKey])) {
			_loc6_ = ASCompat.toInt(mFloorRequestKeys[biomeKey]);
			ASCompat.deleteProperty(mFloorRequestKeys, biomeKey);
			if (mCurrentFloorBiome != null && mCurrentFloorBiome != biomeKey) {
				evictStaleBundles(biomeKey, _loc6_);
			}
			mCurrentFloorBiome = biomeKey;
			mFloorKeysLoading[biomeKey] = true;
		}
		if (ASCompat.toBool(mLoadedBiomeKeys[biomeKey]) || mStarlingAssetManager.getAssetManager(biomeKey) != null) {
			if (mBundleManagers[biomeKey] == null) {
				mBundleManagers[biomeKey] = ASCompat.reinterpretAs(mStarlingAssetManager.getAssetManager(biomeKey), AnimAssetManager);
			}
			ASCompat.deleteProperty(mOverrideAssetFiles, biomeKey);
			onBiomeLoadComplete(biomeKey);
			return;
		}
		if (Texture.asyncBitmapUploadEnabled) {
			reportLoadFailure(biomeKey, null, "async bitmap texture uploads are on; their failures would be reported as loaded textures");
		}
		var _loc4_:Array<ASAny> = ASCompat.dynamicAs(mOverrideAssetFiles[biomeKey], Array);
		var _loc10_ = _loc4_ != null;
		if (_loc10_) {
			ASCompat.deleteProperty(mOverrideAssetFiles, biomeKey);
		} else {
			_loc4_ = StarlingAssetMapper.getAssetFilesForBiome(biomeKey, false);
		}
		mLoadingAssetFiles[biomeKey] = _loc4_;
		var _loc12_ = newBundleManager();
		mBundleManagers[biomeKey] = _loc12_;
		var _loc5_ = StarlingAssetMapper.getPropManifestFilesForBiome(biomeKey, false);
		if (_loc5_.length > 0) {
			_loc2_ = new StarlingPropManifest();
			if (checkNullIteratee(_loc5_))
				for (_tmp_ in _loc5_) {
					_loc7_ = ASCompat.coerce(_tmp_, flash.filesystem.File);
					_loc2_.load(_loc7_);
				}
			mPropManifests[biomeKey] = _loc2_;
		}
		var _loc8_:File;
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc8_ = ASCompat.coerce(_tmp_, flash.filesystem.File);
				if (!_loc8_.exists) {
					reportLoadFailure(biomeKey, null, "missing file " + _loc8_.nativePath);
				} else if (_loc8_.isDirectory) {
					_loc11_ = _loc8_.getDirectoryListing();
					_loc13_ = [];
					_loc3_ = _loc10_ && skipsRootLabelledClipFolders ? rootClipLabels(_loc8_) : null;
					if (checkNullIteratee(_loc11_))
						for (_tmp_ in _loc11_) {
							_loc9_ = ASCompat.coerce(_tmp_, flash.filesystem.File);
							if (!(_loc3_ != null && _loc9_.isDirectory && ASCompat.toBool(_loc3_[_loc9_.name]))) {
								if (_loc9_.name != "flattened_registration.json" && (_loc10_ || !_loc9_.isDirectory)) {
									_loc13_.push(_loc9_);
								}
							}
						}
					if (_loc13_.length > 0) {
						enqueueAtScale(_loc13_, _loc10_ ? 1 : scaleForFolder(_loc8_), _loc12_);
					}
				} else {
					_loc12_.enqueue(_loc8_);
				}
			}
		mStartedBundles.push({
			"key": biomeKey,
			"bundle": _loc12_
		});
	}

	function queuedAssetCount(bundle:AnimAssetManager):Int {
		return bundle.numQueuedAssets;
	}

	function loadBundle(biomeKey:String, bundle:AnimAssetManager) {
		mLoadingProgress[biomeKey] = 0;
		bundle.loadQueue(function() {
			onBundleLoaded(biomeKey);
		}, function(param1:String, param2:AssetReference) {
			reportLoadFailure(biomeKey, param2, param1);
		}, function(param1:Float) {
			if (mLoadingProgress[biomeKey] != null) {
				mLoadingProgress[biomeKey] = param1;
			}
		});
	}

	@:isVar var skipsRootLabelledClipFolders(get, never):Bool;

	function get_skipsRootLabelledClipFolders():Bool {
		return mFacade.featureFlags != null && mFacade.featureFlags.getFlagValue("skip-root-labelled-clip-folders");
	}

	function reportLoadFailure(biomeKey:String, asset:AssetReference, error:String) {
		var _loc5_:Error = null;
		var _loc6_ = "Starling bundle " + biomeKey + " failed to load";
		if (asset == null
			&& error != null
			&& (error.indexOf(_loc6_) == 0 || error.indexOf("Out of graphics resources. Please restart the game.") == 0)) {
			_loc5_ = new Error(error);
			_loc5_.name = "LOGGED Error";
			throw _loc5_;
		}
		var _loc4_ = asset == null ? "" : " asset " + asset.name + (ASCompat.stringAsBool(asset.url) ? " (" + asset.url + ")" : "");
		var _loc7_ = _loc6_ + _loc4_ + ": " + error;
		if (error != null && error.indexOf("#3691") != -1) {
			Logger.warn(_loc7_);
			Logger.fatal("Out of graphics resources. Please restart the game." + describeGraphicsResources() + "\n" + _loc7_);
		} else {
			Logger.error(_loc7_);
		}
	}

	function describeGraphicsResources():String {
		var _loc4_ = Math.NaN;
		var _loc1_ = Math.NaN;
		var _loc2_ = Math.NaN;
		try {
			_loc4_ = Math.fround(videoMemoryBytes() / 1048576);
		} catch (e:ASAny) {}
		try {
			_loc1_ = textureBudgetMiB();
		} catch (e:ASAny) {}
		try {
			_loc2_ = loadedTextureCount();
		} catch (e:ASAny) {}
		var _loc3_:Array<ASAny> = [];
		if (_loc4_ > 0) {
			_loc3_.push("video memory: " + withThousands(_loc4_) + (_loc1_ > 0 ? " / " + withThousands(_loc1_) + " MiB" : " MiB in use"));
		}
		if (_loc2_ >= 0) {
			_loc3_.push("textures: " + withThousands(_loc2_) + " loaded");
		}
		return _loc3_.length > 0 ? " (" + _loc3_.join("; ") + ")" : "";
	}

	function videoMemoryBytes():Float {
		var _loc1_:ASObject = Starling.context;
		return _loc1_ != null && _loc1_.hasOwnProperty("totalGPUMemory") ? ASCompat.toNumber(_loc1_["totalGPUMemory"]) : Math.NaN;
	}

	function textureBudgetMiB():Float {
		return NativeApplication.nativeApplication.runtimeVersion.indexOf("32.") == 0 ? 1792 : Math.NaN;
	}

	function loadedTextureCount():Int {
		if (mStarlingAssetManager == null) {
			return -1;
		}
		var _loc1_ = mStarlingAssetManager.getAssetNames("texture", "", false).length;
		var _loc2_:AnimAssetManager;
		final __ax4_iter_397:ASObject = mBundleManagers;
		if (checkNullIteratee(__ax4_iter_397))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_397)) {
				_loc2_ = ASCompat.coerce(_tmp_, starling.extensions.animate.AnimAssetManager);
				_loc1_ += _loc2_.getAssetNames("texture", "", false).length;
			}
		return _loc1_;
	}

	function isStaleAtSwitch(key:String, switchGeneration:Int):Bool {
		if (isKeptResident(key)) {
			return false;
		}
		var _loc3_ = key == mCurrentFloorBiome || key.indexOf(getPropKey(mCurrentFloorBiome, "")) == 0;
		return ASCompat.toNumber(mKeyLastUsed[key]) < (_loc3_ ? switchGeneration : switchGeneration - 1);
	}

	function evictStaleBundles(newFloorBiome:String, switchGeneration:Int) {
		var _loc3_ = false;
		var _loc4_:Array<ASAny> = [];
		var _loc5_:String;
		final __ax4_iter_398:ASObject = mLoadedBiomeKeys;
		if (checkNullIteratee(__ax4_iter_398))
			for (_tmp_ in __ax4_iter_398.___keys()) {
				_loc5_ = _tmp_;
				_loc3_ = _loc5_ == StarlingAssetMapper.getPropsOnlyKey(newFloorBiome)
					&& ASCompat.toNumber(mKeyLastUsed[_loc5_]) < switchGeneration;
				if (_loc5_ != newFloorBiome
					&& mPendingBiomeKeys.indexOf(_loc5_) == -1
					&& (_loc3_ || isStaleAtSwitch(_loc5_, switchGeneration))) {
					_loc4_.push(_loc5_);
				}
			}
		disposeBundles(_loc4_);
	}

	public function queueResidentStarlingAssetsForPath(assetPath:String, onComplete:ASFunction = null) {
		var _loc3_ = StarlingAssetMapper.getActorAtlasFile(assetPath) != null ? StarlingAssetMapper.getActorAtlasKeyFromPath(assetPath) : StarlingAssetMapper.getPropLibraryKey(assetPath,
			mRequestedFloorBiome);
		keepStarlingKeyResident(_loc3_);
		queueStarlingAssetsForPath(assetPath, onComplete);
	}

	public function keepStarlingKeyResident(key:String) {
		mKeptResidentKeys[key] = true;
	}

	function isKeptResident(key:String):Bool {
		return key == "shared" || ASCompat.toBool(mKeptResidentKeys[key]);
	}

	public function markStarlingKeyUsed(key:String) {
		if (ASCompat.toBool(mLoadedBiomeKeys[key])) {
			mKeyLastUsed[key] = mFloorGeneration;
		}
	}

	public function beginEntry() {
		mFloorGeneration = mFloorGeneration + 1;
		mEntryBegun = true;
		var _loc2_:Array<ASAny> = [];
		var _loc3_:String;
		final __ax4_iter_399 = mPendingBiomeKeys;
		if (checkNullIteratee(__ax4_iter_399))
			for (_tmp_ in __ax4_iter_399) {
				_loc3_ = _tmp_;
				if (ASCompat.toBool(mBackgroundKeys[_loc3_]) && ASCompat.toNumber(mKeyLastUsed[_loc3_]) < mFloorGeneration) {
					_loc2_.push(_loc3_);
				}
			}
		var _loc1_:String;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc1_ = _tmp_;
				mPendingBiomeKeys.splice(mPendingBiomeKeys.indexOf(_loc1_), (1 : UInt));
				dropBackground(_loc1_);
				ASCompat.deleteProperty(mOverrideAssetFiles, _loc1_);
				ASCompat.deleteProperty(mKeyLastUsed, _loc1_);
				flushBiomeKeyCallbacks(_loc1_);
			}
	}

	public function endEntry() {
		mEntryBegun = false;
	}

	@:isVar public var isEntryFloorPending(get, never):Bool;

	public function get_isEntryFloorPending():Bool {
		return mEntryBegun;
	}

	@:isVar public var floorGeneration(get, never):Int;

	public function get_floorGeneration():Int {
		return mFloorGeneration;
	}

	public function releaseBundlesUnusedSince(generation:Int) {
		if (mRequestedFloorBiome != mCurrentFloorBiome) {
			return;
		}
		var _loc2_:Array<ASAny> = [];
		var _loc3_:String;
		final __ax4_iter_400:ASObject = mLoadedBiomeKeys;
		if (checkNullIteratee(__ax4_iter_400))
			for (_tmp_ in __ax4_iter_400.___keys()) {
				_loc3_ = _tmp_;
				if (_loc3_ != mCurrentFloorBiome
					&& !isKeptResident(_loc3_)
					&& mBundleManagers[_loc3_] != null
					&& mKeyLastUsed.hasOwnProperty(_loc3_)
					&& ASCompat.toNumber(mKeyLastUsed[_loc3_]) < generation
					&& !ASCompat.toBool(mFloorRequestKeys[_loc3_])
					&& mPendingBiomeKeys.indexOf(_loc3_) == -1
					&& mLoadingBiomeKeys.indexOf(_loc3_) == -1) {
					_loc2_.push(_loc3_);
				}
			}
		disposeBundles(_loc2_);
	}

	function disposeBundles(keys:Array<ASAny>) {
		var _loc2_:String;
		if (checkNullIteratee(keys))
			for (_tmp_ in keys) {
				_loc2_ = _tmp_;
				disposeBundle(_loc2_);
			}
		var _loc3_:String;
		final __ax4_iter_401 = mCallbackKeyOrder.concat();
		if (checkNullIteratee(__ax4_iter_401))
			for (_tmp_ in __ax4_iter_401) {
				_loc3_ = _tmp_;
				if (keys.indexOf(_loc3_) != -1) {
					flushBiomeKeyCallbacks(_loc3_);
				}
			}
	}

	function disposeBundle(biomeKey:String) {
		if (mBundleManagers[biomeKey] != null) {
			unindexBundleAnimations(biomeKey);
			mStarlingAssetManager.removeAssetManager(biomeKey);
			mStarlingPurgeCount = mStarlingPurgeCount + 1;
		}
		ASCompat.deleteProperty(mBundleManagers, biomeKey);
		ASCompat.deleteProperty(mLoadedBiomeKeys, biomeKey);
		ASCompat.deleteProperty(mPropManifests, biomeKey);
		ASCompat.deleteProperty(mKeyLastUsed, biomeKey);
	}

	function publishBundle(biomeKey:String) {
		var _loc2_ = ASCompat.coerce(mBundleManagers[biomeKey], starling.extensions.animate.AnimAssetManager);
		if (_loc2_ == null) {
			return;
		}
		mStarlingAssetManager.addAsset(biomeKey, _loc2_);
		indexBundleAnimations(biomeKey, _loc2_);
	}

	function indexBundleAnimations(bundleKey:String, bundle:AnimAssetManager) {
		var _loc5_:AnimationAtlas = null;
		var _loc6_ = bundle.getAnimationAtlasNames();
		var _loc4_ = new Vector<String>();
		var _loc7_ = new Vector<String>();
		var _loc3_:String;
		if (checkNullIteratee(_loc6_))
			for (_tmp_ in _loc6_) {
				_loc3_ = _tmp_;
				_loc5_ = bundle.getAnimationAtlas(_loc3_);
				_loc5_.getAnimationNames("", _loc4_);
				_loc5_.getClipLabels(_loc7_);
			}
		addOwner(mAnimationOwners, _loc4_, bundleKey);
		mBundleAnimationNames[bundleKey] = _loc4_;
		addOwner(mLabelOwners, _loc7_, bundleKey);
		mBundleLabelNames[bundleKey] = _loc7_;
		addOwner(mAtlasOwners, _loc6_, bundleKey);
		mBundleAtlasNames[bundleKey] = _loc6_;
	}

	function unindexBundleAnimations(bundleKey:String) {
		removeOwner(mAnimationOwners, (mBundleAnimationNames[bundleKey] : Vector<String>), bundleKey);
		ASCompat.deleteProperty(mBundleAnimationNames, bundleKey);
		removeOwner(mLabelOwners, (mBundleLabelNames[bundleKey] : Vector<String>), bundleKey);
		ASCompat.deleteProperty(mBundleLabelNames, bundleKey);
		removeOwner(mAtlasOwners, (mBundleAtlasNames[bundleKey] : Vector<String>), bundleKey);
		ASCompat.deleteProperty(mBundleAtlasNames, bundleKey);
	}

	function onBundleLoaded(biomeKey:String) {
		publishBundle(biomeKey);
		onBiomeLoadComplete(biomeKey);
	}

	function onBiomeLoadComplete(biomeKey:String) {
		var _loc6_ = 0;
		if (!ASCompat.toBool(mBackgroundKeys[biomeKey])) {
			mStarlingBundlesLoaded = mStarlingBundlesLoaded + 1;
		}
		dropBackground(biomeKey);
		ASCompat.deleteProperty(mLoadingProgress, biomeKey);
		ASCompat.deleteProperty(mFloorKeysLoading, biomeKey);
		if (mBundleConnections.hasOwnProperty(biomeKey)) {
			mConnectionsInUse -= ASCompat.toInt(mBundleConnections[biomeKey]);
			ASCompat.deleteProperty(mBundleConnections, biomeKey);
		}
		mLoadedBiomeKeys[biomeKey] = true;
		ASCompat.deleteProperty(mLoadingAssetFiles, biomeKey);
		var _loc4_ = mLoadingBiomeKeys.indexOf(biomeKey);
		if (_loc4_ != -1) {
			mLoadingBiomeKeys.splice(_loc4_, (1 : UInt));
		}
		if (ASCompat.toBool(mFloorRequestKeys[biomeKey]) && mPendingBiomeKeys.indexOf(biomeKey) == -1) {
			enqueuePendingKey(biomeKey);
		}
		mIsDrainingCompletion = true;
		var _loc2_ = "shared";
		var _loc7_ = isSharedUnresolved();
		var _loc5_:Array<ASAny> = [];
		var _loc8_:String;
		final __ax4_iter_402 = mCallbackKeyOrder;
		if (checkNullIteratee(__ax4_iter_402))
			for (_tmp_ in __ax4_iter_402) {
				_loc8_ = _tmp_;
				if (ASCompat.toBool(mLoadedBiomeKeys[_loc8_])
					&& !ASCompat.toBool(mFloorRequestKeys[_loc8_])
					&& (_loc8_ == _loc2_ || !_loc7_)) {
					_loc5_.push(_loc8_);
				}
			}
		var _loc3_:String;
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_) {
				_loc3_ = _tmp_;
				if (!ASCompat.toBool(mFloorRequestKeys[_loc3_])) {
					_loc6_ = mPendingBiomeKeys.indexOf(_loc3_);
					if (_loc6_ != -1) {
						mPendingBiomeKeys.splice(_loc6_, (1 : UInt));
					}
					flushBiomeKeyCallbacks(_loc3_);
				}
			}
		mIsDrainingCompletion = false;
		startPendingLoads();
	}

	function flushBiomeKeyCallbacks(biomeKey:String) {
		var _loc2_ = (mBiomeKeyCallbacks[biomeKey] : Vector<ASFunction>);
		if (_loc2_ == null) {
			return;
		}
		ASCompat.deleteProperty(mBiomeKeyCallbacks, biomeKey);
		mCallbackKeyOrder.splice(mCallbackKeyOrder.indexOf(biomeKey), (1 : UInt));
		var _loc3_:ASFunction;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc3_ = _tmp_;
				try {
					_loc3_();
				} catch (e:Dynamic) {
					Logger.error("AssetLoadingComponent.flushBiomeKeyCallbacks: ready callback threw: " + Std.string(e.message));
				}
			}
	}

	@:isVar public var starlingLoadProgress(get, never):Float;

	public function get_starlingLoadProgress():Float {
		var _loc1_:Float = 0;
		var _loc2_:String;
		final __ax4_iter_403:ASObject = mLoadingProgress;
		if (checkNullIteratee(__ax4_iter_403))
			for (_tmp_ in __ax4_iter_403.___keys()) {
				_loc2_ = _tmp_;
				if (!ASCompat.toBool(mBackgroundKeys[_loc2_])) {
					_loc1_ += ASCompat.toNumber(mLoadingProgress[_loc2_]);
				}
			}
		return _loc1_;
	}

	@:isVar public var activeStarlingBundleCount(get, never):UInt;

	public function get_activeStarlingBundleCount():UInt {
		return (loadingBlockingCount() : UInt);
	}

	@:isVar public var pendingStarlingBundleCount(get, never):UInt;

	public function get_pendingStarlingBundleCount():UInt {
		return (pendingBlockingCount() : UInt);
	}

	@:isVar public var starlingBundlesLoaded(get, never):UInt;

	public function get_starlingBundlesLoaded():UInt {
		return mStarlingBundlesLoaded;
	}

	public function getTextureFromAssetManager(textureName:String, libraryKey:String = null):Texture {
		if (mStarlingAssetManager == null) {
			return null;
		}
		var _loc3_:Texture = null;
		if (libraryKey != null) {
			_loc3_ = getBundleTexture(libraryKey, textureName);
			if (_loc3_ == null) {
				_loc3_ = getBundleTexture(StarlingAssetMapper.getPropsOnlyKey(libraryKey), textureName);
			}
			if (_loc3_ == null && libraryKey != "shared") {
				_loc3_ = getBundleTexture("shared", textureName);
			}
		}
		if (_loc3_ == null) {
			_loc3_ = getPublishedTexture(textureName);
		}
		if (_loc3_ != null && !MemoryTracker.isTracked(_loc3_)) {
			MemoryTracker.track(_loc3_, "AssetLoadingComponent - Texture: " + textureName, "starling");
		}
		return _loc3_;
	}

	function getBundleTexture(bundleKey:String, textureName:String):Texture {
		var _loc4_ = ASCompat.coerce(ASCompat.toBool(mLoadedBiomeKeys[bundleKey]) ? ASCompat.coerce(mBundleManagers[bundleKey],
			starling.extensions.animate.AnimAssetManager) : null,
			starling.extensions.animate.AnimAssetManager);
		var _loc3_ = _loc4_ != null ? _loc4_.getTexture(textureName) : null;
		if (_loc3_ != null) {
			markStarlingKeyUsed(bundleKey);
		}
		return _loc3_;
	}

	function getPublishedTexture(textureName:String):Texture {
		var _loc2_:Texture = null;
		var _loc3_:String;
		final __ax4_iter_404:ASObject = mBundleManagers;
		if (checkNullIteratee(__ax4_iter_404))
			for (_tmp_ in __ax4_iter_404.___keys()) {
				_loc3_ = _tmp_;
				_loc2_ = getBundleTexture(_loc3_, textureName);
				if (_loc2_ != null) {
					return _loc2_;
				}
			}
		return mStarlingAssetManager.getTexture(textureName);
	}

	function enqueueAtScale(files:Array<ASAny>, scale:Float, bundle:AnimAssetManager) {
		if (scale <= 0 || scale == 1) {
			bundle.enqueue(files);
			return;
		}
		var _loc4_:File;
		if (checkNullIteratee(files))
			for (_tmp_ in files) {
				_loc4_ = ASCompat.coerce(_tmp_, flash.filesystem.File);
				if (!_loc4_.isHidden) {
					if (_loc4_.isDirectory) {
						bundle.enqueue(_loc4_);
					} else {
						bundle.enqueueSingle(_loc4_, null, new TextureOptions(scale));
					}
				}
			}
	}

	public function getPropRecipeParts(assetClassName:String, libraryKey:String = null):Array<ASAny> {
		var _loc3_:Array<ASAny> = null;
		if (libraryKey != null) {
			_loc3_ = getManifestParts(libraryKey, assetClassName);
			if (_loc3_ == null) {
				_loc3_ = getManifestParts(StarlingAssetMapper.getPropsOnlyKey(libraryKey), assetClassName);
			}
			if (_loc3_ == null && libraryKey != "shared") {
				_loc3_ = getManifestParts("shared", assetClassName);
			}
		}
		var _loc4_:String;
		final __ax4_iter_405:ASObject = mPropManifests;
		if (checkNullIteratee(__ax4_iter_405))
			for (_tmp_ in __ax4_iter_405.___keys()) {
				_loc4_ = _tmp_;
				if (_loc3_ != null) {
					break;
				}
				_loc3_ = getManifestParts(_loc4_, assetClassName);
			}
		return _loc3_;
	}

	function getManifestParts(bundleKey:String, assetClassName:String):Array<ASAny> {
		var _loc3_ = ASCompat.coerce(ASCompat.toBool(mLoadedBiomeKeys[bundleKey]) ? ASCompat.coerce(mPropManifests[bundleKey],
			brain.assetRepository.StarlingPropManifest) : null,
			brain.assetRepository.StarlingPropManifest);
		return _loc3_ != null ? _loc3_.getParts(assetClassName) : null;
	}

	public function createAnimationFromAssetManager(animationName:String, libraryKey:String = null):Animation {
		var _loc3_ = findAnimationBundle(animationName, libraryKey, true);
		if (_loc3_ == null) {
			return null;
		}
		var _loc4_ = _loc3_.createAnimation(animationName);
		if (_loc4_ != null) {
			MemoryTracker.track(_loc4_, "AssetLoadingComponent - Animation: " + animationName, "starling");
		}
		return _loc4_;
	}

	function findAnimationBundle(animationName:String, libraryKey:String, binds:Bool = false):AnimAssetManager {
		var _loc8_:String;
		var __ax4_iter_406:Array<ASAny>;
		var _loc7_:Vector<String>;
		var _loc4_:String;
		if (mStarlingAssetManager == null) {
			return null;
		}
		var _loc6_:Array<ASAny> = [
			mAnimationOwners[animationName],
			mLabelOwners[animationName],
			mAtlasOwners[animationName]
		];
		var _loc9_ = (ASCompat.thisOrDefault((if (ASCompat.toBool(_loc6_[0])) (_loc6_[0] : Vector<String>) else (_loc6_[1] : Vector<String>) : Vector<String>),
			(_loc6_[2] : Vector<String>)) : Vector<String>);
		if (_loc9_ == null) {
			return null;
		}
		var _loc10_ = _loc9_[0];
		var _loc5_:String = null;
		if (libraryKey != null) {
			__ax4_iter_406 = [libraryKey, "shared"];
			if (checkNullIteratee(__ax4_iter_406))
				for (_tmp_ in __ax4_iter_406) {
					_loc8_ = _tmp_;
					if (checkNullIteratee(_loc6_))
						for (_tmp_ in _loc6_) {
							_loc7_ = (_tmp_ : Vector<String>);
							_loc5_ = _loc7_ != null ? findLibraryOwner(_loc7_, _loc8_) : null;
							if (_loc5_ != null) {
								break;
							}
						}
					if (_loc5_ != null) {
						_loc10_ = _loc5_;
						break;
					}
				}
		}
		if (_loc5_ == null) {
			if (checkNullIteratee(_loc9_))
				for (_tmp_ in _loc9_) {
					_loc4_ = _tmp_;
					if (mKeyLastUsed[_loc4_] > mKeyLastUsed[_loc10_]) {
						_loc10_ = _loc4_;
					}
				}
		}
		if (binds) {
			markStarlingKeyUsed(_loc10_);
		}
		return ASCompat.coerce(mBundleManagers[_loc10_], starling.extensions.animate.AnimAssetManager);
	}

	public function createAnimationFromAtlas(atlasName:String, animationName:String):Animation {
		var _loc3_ = findAtlasOwner(atlasName);
		var _loc4_ = _loc3_ != null ? cast(mBundleManagers[_loc3_], AnimAssetManager).createAnimationInAtlas(atlasName, animationName) : null;
		if (_loc4_ != null) {
			markStarlingKeyUsed(_loc3_);
			MemoryTracker.track(_loc4_, "AssetLoadingComponent - Animation: " + animationName + " @ " + atlasName, "starling");
		}
		return _loc4_;
	}

	function findAtlasOwner(atlasName:String):String {
		var _loc4_:AnimAssetManager = null;
		if (mStarlingAssetManager == null || atlasName == null) {
			return null;
		}
		var _loc3_:String = null;
		var _loc2_:String;
		final __ax4_iter_407:ASAny = mAtlasOwners[atlasName];
		if (checkNullIteratee(__ax4_iter_407))
			for (_tmp_ in __ax4_iter_407) {
				_loc2_ = _tmp_;
				_loc4_ = ASCompat.coerce(mBundleManagers[_loc2_], starling.extensions.animate.AnimAssetManager);
				if (_loc4_ != null
					&& _loc4_.getAnimationAtlas(atlasName) != null
					&& (_loc3_ == null || mKeyLastUsed[_loc2_] > mKeyLastUsed[_loc3_])) {
					_loc3_ = _loc2_;
				}
			}
		return _loc3_;
	}

	public function hasAnimationInAssetManager(animationName:String):Bool {
		return findAnimationBundle(animationName, null) != null;
	}

	public function isPackedAtlasInAssetManager(atlasName:String):Bool {
		var _loc2_ = findAtlasOwner(atlasName);
		return _loc2_ != null && cast(mBundleManagers[_loc2_], AnimAssetManager).isPackedAtlas(atlasName);
	}

	public function getAvailableAnimations():Vector<String> {
		var _loc1_ = new Vector<String>();
		if (mStarlingAssetManager != null) {
			mStarlingAssetManager.getAnimationAtlasNames("", _loc1_);
		}
		return _loc1_;
	}

	public function getJsonAsset(assetPath:String, loadedCallback:ASFunction, errorCallback:ASFunction, useCache:Bool = true) {
		var _loc5_ = new AssetLoaderInfo(assetPath, useCache);
		MemoryTracker.track(_loc5_, "AssetLoaderInfo - JSON asset: " + assetPath, "brain");
		if (useCache) {
			if (mAssetRepository.tryCache(_loc5_, loadedCallback)) {
				return;
			}
		}
		var _loc6_ = new AssetLoadingTracker(assetPath, this, loadedCallback, errorCallback);
		MemoryTracker.track(_loc6_, "AssetLoadingTracker - JSON asset: " + assetPath, "brain");
		mAssetRepository.getJsonAsset(_loc5_, _loc6_.successCallback, _loc6_.errorCallback);
	}

	public function getXMLAsset(assetPath:String, loadedCallback:ASFunction, errorCallback:ASFunction = null, useCache:Bool = true) {
		var _loc5_ = new AssetLoaderInfo(assetPath, useCache);
		MemoryTracker.track(_loc5_, "AssetLoaderInfo - XML asset: " + assetPath, "brain");
		if (useCache) {
			if (mAssetRepository.tryCache(_loc5_, loadedCallback)) {
				return;
			}
		}
		var _loc6_ = new AssetLoadingTracker(assetPath, this, loadedCallback, errorCallback);
		MemoryTracker.track(_loc6_, "AssetLoadingTracker - XML asset: " + assetPath, "brain");
		mAssetRepository.getXMLAsset(_loc5_, _loc6_.successCallback, _loc6_.errorCallback);
	}

	public function getByteArrayAsset(assetPath:String, loadedCallback:ASFunction, errorCallback:ASFunction = null, useCache:Bool = true) {
		var _loc5_ = new AssetLoaderInfo(assetPath, useCache);
		MemoryTracker.track(_loc5_, "AssetLoaderInfo - ByteArray asset: " + assetPath, "brain");
		if (useCache) {
			if (mAssetRepository.tryCache(_loc5_, loadedCallback)) {
				return;
			}
		}
		var _loc6_ = new AssetLoadingTracker(assetPath, this, loadedCallback, errorCallback);
		MemoryTracker.track(_loc6_, "AssetLoadingTracker - ByteArray asset: " + assetPath, "brain");
		mAssetRepository.getByteArrayAsset(_loc5_, _loc6_.successCallback, _loc6_.errorCallback);
	}

	public function getSwfAsset(assetPath:String, loadedCallback:ASFunction, errorCallback:ASFunction = null, useCache:Bool = true) {
		var _loc5_ = new AssetLoaderInfo(assetPath, useCache);
		MemoryTracker.track(_loc5_, "AssetLoaderInfo - SWF asset: " + assetPath, "brain");
		if (useCache) {
			if (mAssetRepository.tryCache(_loc5_, loadedCallback)) {
				return;
			}
		}
		var _loc6_ = new AssetLoadingTracker(assetPath, this, loadedCallback, errorCallback);
		MemoryTracker.track(_loc6_, "AssetLoadingTracker - SWF asset: " + assetPath, "brain");
		mAssetRepository.getSwfAsset(_loc5_, _loc6_.successCallback, _loc6_.errorCallback);
	}

	public function getSpriteSheetAsset(SwfPath:String, bitmapDataName:String, loadedCallback:ASFunction, errorCallback:ASFunction, useCache:Bool,
			trickelloadCallback:ASFunction, shClassName:String) {
		var _loc8_ = new SpriteSheetAssetLoaderInfo(SwfPath, bitmapDataName, shClassName, useCache);
		MemoryTracker.track(_loc8_, "SpriteSheetAssetLoaderInfo - " + bitmapDataName + " from: " + SwfPath, "brain");
		if (useCache) {
			if (mAssetRepository.tryCache(_loc8_, loadedCallback)) {
				return;
			}
		}
		var _loc9_ = new AssetLoadingTracker(_loc8_.getKey(), this, loadedCallback, errorCallback);
		MemoryTracker.track(_loc9_, "AssetLoadingTracker - SpriteSheet: " + bitmapDataName, "brain");
		mAssetRepository.getSpriteSheetAsset(mFacade, _loc8_, bitmapDataName, _loc9_.successCallback, _loc9_.errorCallback, trickelloadCallback, shClassName,
			this);
	}

	public function getSoundAsset(SwfPath:String, soundName:String, loadedCallback:ASFunction, errorCallback:ASFunction = null, useCache:Bool = true) {
		if (soundName == null) {
			return;
		}
		var _loc6_ = new SoundAssetLoaderInfo(SwfPath, soundName, useCache);
		MemoryTracker.track(_loc6_, "SoundAssetLoaderInfo - sound: " + soundName + " from: " + SwfPath, "brain");
		if (useCache) {
			if (mAssetRepository.tryCache(_loc6_, loadedCallback)) {
				return;
			}
		}
		var _loc7_ = new AssetLoadingTracker(SwfPath, this, loadedCallback, errorCallback);
		MemoryTracker.track(_loc7_, "AssetLoadingTracker - Sound: " + soundName, "brain");
		mAssetRepository.getSoundAsset(_loc6_, soundName, _loc7_.successCallback, _loc7_.errorCallback);
	}

	public function getURLSoundAsset(path:String, loadedCallback:ASFunction, errorCallback:ASFunction = null, useCache:Bool = true) {
		var _loc5_ = new SoundAssetLoaderInfo(path, "", useCache);
		MemoryTracker.track(_loc5_, "SoundAssetLoaderInfo - URL sound: " + path, "brain");
		if (useCache) {
			if (mAssetRepository.tryCache(_loc5_, loadedCallback)) {
				return;
			}
		}
		var _loc6_ = new AssetLoadingTracker(path, this, loadedCallback, errorCallback);
		MemoryTracker.track(_loc6_, "AssetLoadingTracker - URL Sound: " + path, "brain");
		mAssetRepository.getURLSoundAsset(_loc5_, _loc6_.successCallback, _loc6_.errorCallback);
	}

	public function getImageAsset(assetPath:String, loadedCallback:ASFunction, errorCallback:ASFunction = null, useCache:Bool = true) {
		var _loc5_ = new AssetLoaderInfo(assetPath, useCache);
		MemoryTracker.track(_loc5_, "AssetLoaderInfo - Image asset: " + assetPath, "brain");
		if (useCache) {
			if (mAssetRepository.tryCache(_loc5_, loadedCallback)) {
				return;
			}
		}
		var _loc6_ = new AssetLoadingTracker(assetPath, this, loadedCallback, errorCallback);
		MemoryTracker.track(_loc6_, "AssetLoadingTracker - Image: " + assetPath, "brain");
		mAssetRepository.getImageAsset(_loc5_, _loc6_.successCallback, _loc6_.errorCallback);
	}

	override public function destroy() {
		var _loc1_:ISetIterator = null;
		mTransitionToEmptyFunction = null;
		if (mPendingDownloads != null) {
			_loc1_ = ASCompat.reinterpretAs(mPendingDownloads.iterator(), ISetIterator);
			while (_loc1_.hasNext()) {
				removeLoader(ASCompat.dynamicAs(_loc1_.next(), AssetLoadingTracker));
				_loc1_ = ASCompat.reinterpretAs(mPendingDownloads.iterator(), ISetIterator);
			}
			mPendingDownloads = null;
		}
		super.destroy();
	}

	public function clearAllActive() {
		var _loc1_:ISetIterator = null;
		mTransitionToEmptyFunction = null;
		if (mPendingDownloads != null) {
			_loc1_ = ASCompat.reinterpretAs(mPendingDownloads.iterator(), ISetIterator);
			while (_loc1_.hasNext()) {
				removeLoader(ASCompat.dynamicAs(_loc1_.next(), AssetLoadingTracker));
				_loc1_ = ASCompat.reinterpretAs(mPendingDownloads.iterator(), ISetIterator);
			}
		}
	}

	public function removeLoader(assetLoadingTracker:AssetLoadingTracker) {
		mAssetRepository.removeCallbackFromPendingDownload(assetLoadingTracker.assetKey, assetLoadingTracker.successCallback);
		mAssetRepository.removeErrorCallbackFromPendingDownload(assetLoadingTracker.assetKey, assetLoadingTracker.errorCallback);
		assetLoadingTracker.destroy();
		var _loc2_ = mPendingDownloads.remove(assetLoadingTracker);
		if (_loc2_ && mPendingDownloads.size == 0 && mTransitionToEmptyFunction != null) {
			mTransitionToEmptyFunction();
			mTransitionToEmptyFunction = null;
		}
	}

	public function setTransitionToEmptyCallback(fun:ASFunction) {
		if (mPendingDownloads.size == 0 && fun != null) {
			fun();
			mTransitionToEmptyFunction = null;
		} else {
			mTransitionToEmptyFunction = fun;
		}
	}

	static function __init__() {
		sRootClipLabels = {};
		sFolderScales = {};
	}
}
