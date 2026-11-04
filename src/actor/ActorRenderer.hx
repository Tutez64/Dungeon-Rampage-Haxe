package actor;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.StarlingAssetMapper;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.render.ActorSpriteSheetRenderer;
import brain.render.IRenderer;
import brain.workLoop.LayerWorkComponent;
import brain.workLoop.PreRenderWorkComponent;
import collections.IMapIterator;
import collections.Map;
import combat.weapon.WeaponRenderer;
import distributedObjects.NPCGameObject;
import dungeon.Tile;
import facade.DBFacade;
import gameMasterDictionary.GMActor;
import starling.SwfFallbackDebug;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filesystem.File;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import starling.extensions.animate.Animation;
import starling.textures.Texture;

class ActorRenderer extends Sprite {
	public static inline final IDLE_ANIM_NAME = "idle";

	public static inline final RUN_ANIM_NAME = "run";

	public static inline final SUFFER_ANIM_NAME = "suffer";

	public static inline final DEATH_ANIM_NAME = "death";

	public static inline final IDLE_CLIP_KEY_SUFFIX = "_idle";

	static inline final PACKED_LIBRARY_SYMBOL_NAME = "__BTA_TEMP_SPRITEMAP_PACKED_SYMBOL";

	static inline final CULL_MARGIN:Float = 256;

	static inline final DEBUG_HEADING = false;

	public static var mStandardAnimList:Array<ASAny>;

	var mDBFacade:DBFacade;

	var mAnims:Map;

	var mLoadingAnims:Map;

	var mTriggerState:Bool = false;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mPreRenderWorkComponent:PreRenderWorkComponent;

	var mStarlingSyncComponent:LayerWorkComponent;

	var mLayerSyncedStarlingRenderer:StarlingActorRenderer;

	var mCurrentRenderer:IRenderer;

	var mStarlingRenderer:StarlingActorRenderer;

	var mHighlightColor:UInt = 0;

	var mHighlightAlpha:Float = 8;

	var mHighlightBlur:Float = 2;

	var mHighlightActive:Bool = false;

	var mPersistentGlowColor:UInt = 0;

	var mPersistentGlowAlpha:Float = 8;

	var mPersistentGlowBlur:Float = 2;

	var mPersistentGlowActive:Bool = false;

	var mColorFilterMatrix:Array<ASAny>;

	var mStatusTintColor:UInt = 0;

	var mStatusTintAmount:Float = 0;

	var mActorGameObject:ActorGameObject;

	var mHeading:Float = 0;

	var mAnimName:String;

	var mLoop:Bool = false;

	var mPendingLayer:Int = 0;

	var mPendingVisible:Bool = false;

	var mCulled:Bool = false;

	var mUnculledSinceLastFrame:Bool = false;

	var mSyncedRootX:Float = Math.NaN;

	var mSyncedRootY:Float = Math.NaN;

	var mSyncedRootRotation:Float = Math.NaN;

	var mSyncedRotation:Float = Math.NaN;

	var mSyncedRootScaleX:Float = Math.NaN;

	var mSyncedRootScaleY:Float = Math.NaN;

	var mSyncedRootAlpha:Float = Math.NaN;

	var mSyncedBodyScaleX:Float = Math.NaN;

	var mSyncedBodyScaleY:Float = Math.NaN;

	var mSyncedOffsetX:Float = Math.NaN;

	var mSyncedOffsetY:Float = Math.NaN;

	var mSyncedWorldX:Float = Math.NaN;

	var mSyncedWorldY:Float = Math.NaN;

	var mContentRadius:Float = 0;

	var mContentRadiusStale:Bool = true;

	var mTileStretchPending:Bool = false;

	var mTileStretchClip:MovieClip;

	var mTileStretchWork:LayerWorkComponent;

	var mPreloadSprites:Bool = false;

	var mIsStarlingBound:Bool = false;

	var mLoadCompleteCallbacks:Vector<ASFunction>;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject, triggerState:Bool) {
		super();
		this.name = "ActorRenderer";
		mActorGameObject = actorGameObject;
		mDBFacade = dbFacade;
		mTriggerState = triggerState;
		mAnims = new Map();
		mLoop = false;
		mColorFilterMatrix = null;
		mLoadingAnims = new Map();
		mLoadCompleteCallbacks = new Vector<ASFunction>();
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade, "ActorRenderer");
		mPreloadSprites = mDBFacade.dbConfigManager.getConfigBoolean("preload_sprites", false);
	}

	public static function npcAtlasClassNames(className:String):Array<ASAny> {
		if (!ASCompat.stringAsBool(className)) {
			return [];
		}
		return [
			className,
			className + "_" + "run",
			className + "_" + "suffer",
			className + "_" + "death"
		];
	}

	public static function propAtlasClassNames(gmActor:GMActor, triggerState:Bool):Array<ASAny> {
		var _loc6_ = gmActor.AssetClassName;
		var _loc3_ = ActorData.offMovieClipClassName(_loc6_);
		var _loc4_ = gmActor.Species;
		if (_loc4_ == "DOOR") {
			return [_loc3_];
		}
		if (_loc4_ == "TRIGGER") {
			return [triggerState ? _loc6_ : _loc3_];
		}
		var _loc5_ = _loc4_ == "TRAP" ? [_loc6_, _loc3_] : [_loc6_];
		if (gmActor.DefaultDestruct != null) {
			_loc5_.push(ActorData.deathMovieClipClassName(_loc6_));
		}
		return _loc5_;
	}

	public static function boundsThrough(local:Rectangle, matrix:Matrix):Rectangle {
		var _loc6_ = Math.NaN;
		var _loc3_ = Vector.ofArray([
			matrix.transformPoint(local.topLeft),
			matrix.transformPoint(new Point(local.right, local.top)),
			matrix.transformPoint(new Point(local.left, local.bottom)),
			matrix.transformPoint(local.bottomRight)
		]);
		var _loc8_ = _loc6_ = _loc3_[0].x;
		var _loc4_:Float;
		var _loc7_ = _loc4_ = _loc3_[0].y;
		var _loc5_:Point;
		if (checkNullIteratee(_loc3_))
			for (_tmp_ in _loc3_) {
				_loc5_ = _tmp_;
				_loc6_ = Math.min(_loc6_, _loc5_.x);
				_loc8_ = Math.max(_loc8_, _loc5_.x);
				_loc4_ = Math.min(_loc4_, _loc5_.y);
				_loc7_ = Math.max(_loc7_, _loc5_.y);
			}
		return new Rectangle(_loc6_, _loc4_, _loc8_ - _loc6_, _loc7_ - _loc4_);
	}

	@:isVar public var rendererType(get, never):String;

	public function get_rendererType():String {
		if (mStarlingRenderer != null) {
			return mStarlingRenderer.rendererType;
		}
		if (mCurrentRenderer == null) {
			return "null";
		}
		return mCurrentRenderer.rendererType;
	}

	public function destroy() {
		var _loc1_:IRenderer = null;
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
		if (mStarlingRenderer != null) {
			mStarlingRenderer.destroy();
			mStarlingRenderer = null;
		}
		var _loc2_ = ASCompat.reinterpretAs(mAnims.iterator(), IMapIterator);
		while (_loc2_.hasNext()) {
			_loc1_ = ASCompat.coerce(_loc2_.next(), brain.render.IRenderer);
			_loc1_.destroy();
		}
		mAnims.clear();
		mAnims = null;
		mLoadingAnims.clear();
		mLoadingAnims = null;
		if (mLoadCompleteCallbacks != null) {
			mLoadCompleteCallbacks.length = 0;
			mLoadCompleteCallbacks = null;
		}
		mAssetLoadingComponent.destroy();
		mPreRenderWorkComponent.destroy();
		stopTileStretchWork();
		if (mStarlingSyncComponent != null) {
			mStarlingSyncComponent.destroy();
			mStarlingSyncComponent = null;
		}
		mLayerSyncedStarlingRenderer = null;
		mActorGameObject = null;
		mDBFacade = null;
		mCurrentRenderer = null;
	}

	@:isVar public var isStarlingLoading(get, never):Bool;

	public function get_isStarlingLoading():Bool {
		return mIsStarlingBound && mStarlingRenderer == null;
	}

	public function addLoadCompleteCallback(callback:ASFunction) {
		if (mLoadCompleteCallbacks == null) {
			return;
		}
		mLoadCompleteCallbacks.push(callback);
	}

	public function removeLoadCompleteCallback(callback:ASFunction) {
		if (mLoadCompleteCallbacks == null) {
			return;
		}
		var _loc2_ = mLoadCompleteCallbacks.indexOf(callback);
		if (_loc2_ >= 0) {
			mLoadCompleteCallbacks.splice(_loc2_, (1 : UInt));
		}
	}

	function notifyLoadComplete() {
		if (mLoadCompleteCallbacks == null) {
			return;
		}
		var _loc1_ = mLoadCompleteCallbacks.concat();
		mLoadCompleteCallbacks.length = 0;
		var _loc2_:ASFunction;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc2_ = _tmp_;
				_loc2_();
			}
	}

	@:isVar var swfFilePath(get, never):String;

	function get_swfFilePath():String {
		return mActorGameObject.actorData.getSwfFilePath();
	}

	@:isVar var movieClipClassName(get, never):String;

	function get_movieClipClassName():String {
		if (mTriggerState) {
			return mActorGameObject.actorData.getMovieClipClassName();
		}
		return mActorGameObject.actorData.getOffMovieClipClassName();
	}

	@:isVar var spriteWidth(get, never):Float;

	function get_spriteWidth():Float {
		return mActorGameObject.actorData.spriteWidth;
	}

	@:isVar var spriteHeight(get, never):Float;

	function get_spriteHeight():Float {
		return mActorGameObject.actorData.spriteHeight;
	}

	@:isVar var assetType(get, never):String;

	function get_assetType():String {
		return mActorGameObject.actorData.assetType;
	}

	@:isVar var starlingAtlasName(get, never):String;

	function get_starlingAtlasName():String {
		return StarlingAssetMapper.getActorAtlasKeyFromPath(this.swfFilePath);
	}

	@:isVar var isStarlingActor(get, never):Bool;

	function get_isStarlingActor():Bool {
		return mActorGameObject != null
			&& mActorGameObject.actorData != null
			&& mActorGameObject.actorData.gMActor != null
			&& !mActorGameObject.isProp
			&& StarlingAssetMapper.getActorAtlasFile(this.swfFilePath) != null;
	}

	function getSpriteSheetClassName(animName:String):String {
		if (mTriggerState || mActorGameObject.actorData.isMover) {
			return mActorGameObject.actorData.getSpriteSheetClassName(animName);
		}
		return mActorGameObject.actorData.getOffSpriteSheetClassName(animName);
	}

	function loadMovieClipAssets() {
		var onStarlingAssets:ASFunction;
		var actorAtlasFile:File;
		var isBackground:Bool;
		var swfPath = this.swfFilePath;
		var className = movieClipClassName;
		if (mActorGameObject != null && mActorGameObject.forceFlash) {
			reportSwfFallback("per-instance forceFlash override (LE tile placement)", this.assetType == "SPRITE_SHEET");
			loadMovieClipSwfAssets(swfPath, className);
			return;
		}
		if (!ASCompat.stringAsBool(className) || mDBFacade.assetLoadingComponent == null || mDBFacade.starlingLayerManager == null) {
			reportSwfFallback(!ASCompat.stringAsBool(className) ? "no AssetClassName" : (mDBFacade.assetLoadingComponent == null ? "no asset loading component" : "no Starling layer manager (Stage3D not up)"),
				this.assetType == "SPRITE_SHEET");
			loadMovieClipSwfAssets(swfPath, className);
			return;
		}
		onStarlingAssets = function() {
			if (mAnims == null) {
				return;
			}
			var _loc1_:String = mActorGameObject.isProp ? null : starlingAtlasName;
			var _loc2_ = _loc1_ != null && _loc1_ != "" ? _loc1_ : className;
			if (_loc2_ != className && mDBFacade.assetLoadingComponent.isPackedAtlasInAssetManager(_loc2_)) {
				_loc2_ = className;
			} else if (_loc2_ != className
				&& !mDBFacade.assetLoadingComponent.hasAnimationInAssetManager(_loc2_)
				&& mDBFacade.assetLoadingComponent.hasAnimationInAssetManager(className)) {
				_loc2_ = className;
			}
			if (!loadStarlingAnimations(_loc2_)) {
				reportSwfFallback(!mDBFacade.assetLoadingComponent.isStarlingReady ? "Starling asset manager not initialized (Stage3D context failed?)" : "atlas \'"
					+ _loc2_
					+ "\' has no idle animation",
					assetType == "SPRITE_SHEET");
				loadMovieClipSwfAssets(swfPath, className);
			}
		};
		actorAtlasFile = ASCompat.coerce(!mActorGameObject.isProp ? StarlingAssetMapper.getActorAtlasFile(swfPath, true) : null, flash.filesystem.File);
		isBackground = mActorGameObject.belongsToRemotePlayer;
		if (actorAtlasFile != null) {
			queueActorAtlas(actorAtlasFile, className, onStarlingAssets, isBackground);
		} else if (mActorGameObject.isProp) {
			mDBFacade.assetLoadingComponent.queueStarlingAssetsForProps(swfPath, getPropAtlasClassNames(), onStarlingAssets);
		} else if (StarlingAssetMapper.isPropLibraryPath(swfPath)) {
			mDBFacade.assetLoadingComponent.queueStarlingAssetsForProps(swfPath, npcAtlasClassNames(className), onStarlingAssets, isBackground,
				backgroundLoadTier);
		} else {
			mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(swfPath, onStarlingAssets, false, isBackground, backgroundLoadTier);
		}
	}

	@:isVar var backgroundLoadTier(get, never):Int;

	function get_backgroundLoadTier():Int {
		return Std.isOfType(mActorGameObject, NPCGameObject) ? 4 : 0;
	}

	function getPropAtlasClassNames():Array<ASAny> {
		return propAtlasClassNames(mActorGameObject.actorData.gMActor, mTriggerState);
	}

	@:isVar var npcLibraryKey(get, never):String;

	function get_npcLibraryKey():String {
		var _loc1_ = this.swfFilePath;
		return StarlingAssetMapper.isPropLibraryPath(_loc1_) ? StarlingAssetMapper.getBiomeKeyFromPath(_loc1_) : null;
	}

	function queueActorAtlas(actorAtlasFile:File, className:String, onStarlingAssets:ASFunction, isBackground:Bool) {
		var __ax4_iter_19:Array<ASAny>;
		var idleClipFile:File;
		var restClipFiles:Array<ASAny>;
		var clipFile:File;
		var remainingClassName:String;
		var isMultiClip = !actorAtlasFile.resolvePath("Animation.json").exists;
		if (isMultiClip) {
			idleClipFile = null;
			restClipFiles = [];
			__ax4_iter_19 = actorAtlasFile.getDirectoryListing();
			if (checkNullIteratee(__ax4_iter_19))
				for (_tmp_ in __ax4_iter_19) {
					clipFile = ASCompat.coerce(_tmp_, flash.filesystem.File);
					if (clipFile.isDirectory && clipFile.name == className) {
						idleClipFile = clipFile;
					} else {
						restClipFiles.push(clipFile);
					}
				}
			if (idleClipFile != null && restClipFiles.length > 0) {
				remainingClassName = className;
				if (!mDBFacade.assetLoadingComponent.hasAnimationInAssetManager(className)) {
					mDBFacade.assetLoadingComponent.queueStarlingAssets(className + "_idle", onStarlingAssets, false, [idleClipFile], isBackground,
						backgroundLoadTier);
				} else {
					onStarlingAssets();
				}
				mDBFacade.assetLoadingComponent.queueStarlingAssets(starlingAtlasName, function() {
					onRemainingClipsLoaded(remainingClassName);
				}, false, restClipFiles, isBackground, backgroundLoadTier);
				return;
			}
		}
		mDBFacade.assetLoadingComponent.queueStarlingAssets(starlingAtlasName, onStarlingAssets, false, [actorAtlasFile], isBackground, backgroundLoadTier);
	}

	function onRemainingClipsLoaded(className:String) {
		if (mStarlingRenderer == null) {
			return;
		}
		addStarlingAnimation("run", className);
		addStarlingAnimation("suffer", className);
		addStarlingAnimation("death", className);
	}

	function loadMovieClipSwfAssets(swfPath:String, className:String) {
		mIsStarlingBound = false;
		if (StarlingAssetMapper.isArt3DPath(swfPath)) {
			reportSwfFallback("no usable ATF atlas - Art3D SWFs no longer ship, so this will not render. Pack its ATF atlas with TA_3DPipeline");
			notifyLoadComplete();
			return;
		}
		this.mAssetLoadingComponent.getSwfAsset(swfPath, function(param1:SwfAsset) {
			movieClipSwfLoaded(className, param1);
		});
	}

	function countResolvableRecipeParts(parts:Array<ASAny>, libraryKey:String):Int {
		var _loc4_ = 0;
		var _loc3_:ASObject;
		if (checkNullIteratee(parts))
			for (_tmp_ in parts) {
				_loc3_ = _tmp_;
				if (mDBFacade.assetLoadingComponent.getTextureFromAssetManager(ASCompat.asString(_loc3_.tex), libraryKey) != null) {
					_loc4_++;
				}
			}
		return _loc4_;
	}

	function clearFlashRenderer() {
		var _loc1_:IRenderer = null;
		if (mCurrentRenderer != null) {
			mCurrentRenderer.stop();
			if (this.contains(mCurrentRenderer.displayObject)) {
				this.removeChild(mCurrentRenderer.displayObject);
			}
			mCurrentRenderer = null;
		}
		var _loc2_ = ASCompat.reinterpretAs(mAnims.iterator(), IMapIterator);
		while (_loc2_ != null && _loc2_.hasNext()) {
			_loc1_ = ASCompat.dynamicAs(_loc2_.next(), IRenderer);
			if (_loc1_ != null) {
				_loc1_.destroy();
			}
		}
		mAnims.clear();
		mLoadingAnims.clear();
	}

	function loadStarlingAnimations(movieClipClassName:String):Bool {
		var _loc22_:String = null;
		var _loc25_:String = null;
		var _loc14_:String = null;
		var _loc4_ = false;
		var _loc20_:String = null;
		var _loc7_:Animation = null;
		var _loc21_:String = null;
		var _loc28_:Array<ASAny> = null;
		var _loc26_:String = null;
		var _loc16_:Array<ASAny> = null;
		var _loc11_ = false;
		var _loc9_:Animation = null;
		var _loc3_:Animation = null;
		var _loc10_:Animation = null;
		var _loc19_:Texture = null;
		var _loc8_:Texture = null;
		var _loc15_ = false;
		var _loc24_ = 0;
		var _loc27_:String = null;
		var _loc5_:Animation = null;
		var _loc17_ = Math.NaN;
		var _loc23_ = Math.NaN;
		var _loc13_:ActorData = null;
		var _loc6_ = mActorGameObject.actorData != null
			&& mActorGameObject.actorData.gMActor != null
			&& mActorGameObject.actorData.gMActor.CharType == "PROP";
		if (_loc6_) {
			_loc22_ = StarlingAssetMapper.getBiomeKeyFromPath(this.swfFilePath);
			_loc25_ = mActorGameObject.actorData.gMActor.Species;
			_loc14_ = mActorGameObject.actorData.getMovieClipClassName();
			_loc4_ = !mTriggerState;
			_loc7_ = null;
			if (_loc25_ == "DOOR") {
				_loc21_ = _loc14_;
				_loc28_ = mDBFacade.assetLoadingComponent.getPropRecipeParts(_loc21_, _loc22_);
				if (_loc4_ && mActorGameObject.actorData.gMActor.DefaultDestruct != null) {
					_loc26_ = _loc14_ + "_off";
					_loc16_ = mDBFacade.assetLoadingComponent.getPropRecipeParts(_loc26_, _loc22_);
					if (_loc16_ != null && countResolvableRecipeParts(_loc16_, _loc22_) > 0) {
						_loc21_ = _loc26_;
						_loc28_ = _loc16_;
					} else {
						_loc21_ = _loc26_;
						_loc28_ = null;
					}
				}
			} else if (_loc25_ == "TRAP" || _loc25_ == "TRIGGER") {
				_loc21_ = _loc4_ ? _loc14_ + "_off" : _loc14_;
				_loc28_ = mDBFacade.assetLoadingComponent.getPropRecipeParts(_loc21_, _loc22_);
			} else {
				_loc21_ = movieClipClassName;
				_loc28_ = mDBFacade.assetLoadingComponent.getPropRecipeParts(_loc21_, _loc22_);
			}
			if (_loc28_ != null && countResolvableRecipeParts(_loc28_, _loc22_) == 0) {
				Logger.warnch("Starling",
					"Prop manifest recipe \'" + _loc21_ + "\' names no sprite present in the atlas; falling back to name-derived lookups");
				_loc28_ = null;
			}
			_loc11_ = _loc25_ == "TRIGGER" || _loc25_ == "TRAP" && _loc28_ != null;
			if (_loc11_) {
				_loc20_ = _loc4_ ? _loc14_ + "_off" : _loc14_;
			} else if (_loc25_ == "DOOR") {
				_loc20_ = _loc14_ + "_off";
			} else if (_loc25_ == "TRAP") {
				_loc9_ = resolveActorClip(_loc14_, _loc22_);
				_loc3_ = resolveActorClip(_loc14_ + "_off", _loc22_);
				if (_loc9_ != null || _loc3_ == null) {
					_loc20_ = _loc4_ ? _loc14_ + "_off" : _loc14_;
					_loc7_ = _loc4_ ? _loc3_ : _loc9_;
					_loc10_ = _loc4_ ? _loc9_ : _loc3_;
					if (_loc10_ != null) {
						_loc10_.dispose();
					}
				} else {
					_loc20_ = _loc14_ + "_off";
					_loc7_ = _loc3_;
				}
			} else {
				_loc20_ = _loc14_;
			}
			_loc15_ = false;
			if (_loc28_ == null) {
				if (_loc25_ == "DOOR") {
					_loc8_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc14_ + "_frame", _loc22_);
					_loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc14_ + "_door", _loc22_);
					if (_loc8_ != null && _loc19_ != null) {
						_loc15_ = true;
					} else {
						_loc8_ = null;
						_loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(movieClipClassName, _loc22_);
						if (_loc19_ == null) {
							_loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc20_, _loc22_);
						}
					}
				} else if (_loc11_) {
					_loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc20_, _loc22_);
				} else if (_loc25_ == "TRAP" && _loc4_) {
					_loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc20_, _loc22_);
				} else {
					_loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(movieClipClassName, _loc22_);
					if (_loc19_ == null) {
						_loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc14_, _loc22_);
					}
					if (_loc19_ == null && _loc25_ == "TRAP") {
						_loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc20_, _loc22_);
					}
				}
			}
			if (_loc7_ == null) {
				_loc7_ = resolveActorClip(_loc20_, _loc22_);
			}
			if (_loc7_ != null && (mAnimName == null || mAnimName == "idle")) {
				mLoop = !_loc7_.hasFrameLabelNoClamp("noloop");
			}
			if (_loc28_ == null && _loc19_ == null && _loc7_ == null) {
				Logger.warn("No Starling asset for: " + movieClipClassName + " - BASE ASSET missing - no manifest recipe for \'" + _loc21_
					+ "\', no atlas texture named \'" + movieClipClassName + "\' and no animation named \'" + _loc20_ + "\'; falling back to SWF");
				return false;
			}
			if (_loc7_ == null && !_loc11_ && !_loc4_ && _loc19_ == null && _loc28_ == null) {
				Logger.warn("No Starling asset for: " + movieClipClassName + " - ANIMATION missing - no animation named \'" + _loc20_
					+ "\' for the active state; falling back to SWF");
				return false;
			}
			clearFlashRenderer();
			mIsStarlingBound = false;
			mStarlingRenderer = new StarlingActorRenderer(mDBFacade, movieClipClassName, 20);
			resetContentRadius();
			if (_loc28_ != null) {
				_loc24_ = mStarlingRenderer.setStaticEnsemble(_loc28_, _loc22_);
				if (_loc24_ == 0) {
					Logger.warn("No Starling asset for: "
						+ movieClipClassName
						+ " - RECIPE UNRESOLVED - manifest recipe \'"
						+ _loc21_
						+ "\' names no sprite present in the atlas; falling back to SWF");
					mStarlingRenderer.destroy();
					mStarlingRenderer = null;
					return false;
				}
			} else {
				if (_loc15_) {
					mStarlingRenderer.setFrameImage(_loc8_);
				}
				mStarlingRenderer.setOffImage(_loc19_);
			}
			if (_loc11_) {
				if (_loc7_ != null) {
					mStarlingRenderer.alignStaticImagesToAnimation(_loc7_);
				}
				if (_loc28_ == null && _loc19_ == null && _loc7_ != null) {
					mStarlingRenderer.addAnimation("idle", _loc7_);
					if (mAnimName == null) {
						mAnimName = "idle";
					}
				}
			} else {
				if (_loc25_ == "DOOR") {
					if (!mTriggerState) {
						mStarlingRenderer.addAnimation("idle", _loc7_);
					}
					mStarlingRenderer.addAnimation("death", _loc7_);
				} else if (mActorGameObject.actorData.gMActor.DefaultDestruct != null) {
					mStarlingRenderer.addAnimation("idle", _loc7_);
					_loc27_ = mActorGameObject.actorData.getDeathMovieClipClassName();
					_loc5_ = resolveActorClip(_loc27_, _loc22_);
					mStarlingRenderer.addAnimation("death", _loc5_);
				} else {
					mStarlingRenderer.addAnimation("death", _loc7_);
					mStarlingRenderer.addAnimation("idle", _loc7_);
				}
				if (_loc15_) {
					mStarlingRenderer.alignStaticImagesToAnimation(_loc7_);
				}
			}
			syncStarlingTransform();
			mStarlingRenderer.showOffImage(true);
			updateStarlingHitArea();
			this.visible = mPendingVisible;
			mStarlingRenderer.setLayer(mPendingLayer);
			if (mAnimName != null) {
				this.play(mAnimName, 0, true, mLoop);
			} else if (_loc28_ == null && _loc19_ == null && mStarlingRenderer.hasAnim("idle")) {
				mAnimName = "idle";
				this.play(mAnimName, 0, true, mLoop);
			}
			if (mHighlightActive) {
				mStarlingRenderer.setHighlightFilter(mHighlightColor, mHighlightAlpha, mHighlightBlur);
			}
			if (mPersistentGlowActive) {
				mStarlingRenderer.setPersistentGlowFilter(mPersistentGlowColor, mPersistentGlowAlpha, mPersistentGlowBlur);
			}
			if (mColorFilterMatrix != null) {
				mStarlingRenderer.setColorFilter(mColorFilterMatrix);
			}
			if (mStatusTintAmount > 0) {
				mStarlingRenderer.setStatusTint(mStatusTintColor, mStatusTintAmount);
			}
			mTileStretchPending = stretchesTile;
			startStarlingSync();
			return true;
		}
		var _loc18_ = resolveActorClip(movieClipClassName, npcLibraryKey);
		if (_loc18_ == null) {
			Logger.warnch("Starling",
				"No Starling asset for: "
				+ movieClipClassName
				+ " - ANIMATION missing - no idle animation named \'"
				+ movieClipClassName
				+ "\'; falling back to SWF");
			return false;
		}
		if (isStarlingMultiDirectionAnim(_loc18_)) {
			clearFlashRenderer();
			mIsStarlingBound = false;
			mStarlingRenderer = new StarlingActorRenderer(mDBFacade, movieClipClassName, 20);
			resetContentRadius();
			mStarlingRenderer.enableMultiDirectionMode(_loc18_);
			_loc17_ = _loc18_.sourceWidth;
			_loc23_ = _loc18_.sourceHeight;
			_loc13_ = mActorGameObject.actorData;
			if (_loc17_ > 0 && _loc23_ > 0 && _loc13_.spriteWidth > 0 && _loc13_.spriteHeight > 0) {
				mStarlingRenderer.setContentScale(_loc13_.spriteWidth / _loc17_, _loc13_.spriteHeight / _loc23_);
			}
			syncStarlingTransform();
			if (mAnimName != null) {
				this.play(mAnimName, 0, true, mLoop);
			} else {
				this.stop();
			}
			updateStarlingHitArea();
			this.visible = mPendingVisible;
			mStarlingRenderer.setLayer(mPendingLayer);
			if (mHighlightActive) {
				mStarlingRenderer.setHighlightFilter(mHighlightColor, mHighlightAlpha, mHighlightBlur);
			}
			if (mPersistentGlowActive) {
				mStarlingRenderer.setPersistentGlowFilter(mPersistentGlowColor, mPersistentGlowAlpha, mPersistentGlowBlur);
			}
			if (mColorFilterMatrix != null) {
				mStarlingRenderer.setColorFilter(mColorFilterMatrix);
			}
			if (mStatusTintAmount > 0) {
				mStarlingRenderer.setStatusTint(mStatusTintColor, mStatusTintAmount);
			}
			startStarlingSync();
			notifyLoadComplete();
			return true;
		}
		clearFlashRenderer();
		mIsStarlingBound = false;
		mStarlingRenderer = new StarlingActorRenderer(mDBFacade, movieClipClassName, 20);
		resetContentRadius();
		mStarlingRenderer.addAnimation("idle", _loc18_);
		var _loc2_ = _loc18_.sourceWidth;
		var _loc12_ = _loc18_.sourceHeight;
		if (_loc2_ > 0 && _loc12_ > 0 && mActorGameObject.actorData.spriteWidth > 0 && mActorGameObject.actorData.spriteHeight > 0) {
			mStarlingRenderer.setContentScale(mActorGameObject.actorData.spriteWidth / _loc2_, mActorGameObject.actorData.spriteHeight / _loc12_);
		}
		addStarlingAnimation("run", movieClipClassName);
		addStarlingAnimation("suffer", movieClipClassName);
		addStarlingAnimation("death", movieClipClassName);
		syncStarlingTransform();
		if (mAnimName != null) {
			this.play(mAnimName, 0, true, mLoop);
		} else {
			this.stop();
		}
		updateStarlingHitArea();
		this.visible = mPendingVisible;
		mStarlingRenderer.setLayer(mPendingLayer);
		if (mHighlightActive) {
			mStarlingRenderer.setHighlightFilter(mHighlightColor, mHighlightAlpha, mHighlightBlur);
		}
		if (mPersistentGlowActive) {
			mStarlingRenderer.setPersistentGlowFilter(mPersistentGlowColor, mPersistentGlowAlpha, mPersistentGlowBlur);
		}
		if (mColorFilterMatrix != null) {
			mStarlingRenderer.setColorFilter(mColorFilterMatrix);
		}
		if (mStatusTintAmount > 0) {
			mStarlingRenderer.setStatusTint(mStatusTintColor, mStatusTintAmount);
		}
		startStarlingSync();
		notifyLoadComplete();
		return true;
	}

	function resolveActorClip(className:String, libraryKey:String = null):Animation {
		if (className == null) {
			return null;
		}
		var _loc3_ = mDBFacade.assetLoadingComponent.createAnimationFromAtlas(starlingAtlasName, className);
		if (_loc3_ == null) {
			_loc3_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(className, libraryKey);
		}
		if (_loc3_ != null && _loc3_.symbolName == "__BTA_TEMP_SPRITEMAP_PACKED_SYMBOL") {
			_loc3_.dispose();
			_loc3_ = null;
		}
		return _loc3_;
	}

	function isStarlingMultiDirectionAnim(animation:Animation):Bool {
		return animation.getFrame("idle_angE") >= 0 || animation.getFrame("idle_angB") >= 0 || animation.getFrame("idle_angD") >= 0;
	}

	function addStarlingAnimation(animName:String, movieClipClassName:String) {
		var _loc3_ = resolveActorClip(movieClipClassName + "_" + animName, npcLibraryKey);
		if (_loc3_ != null) {
			mStarlingRenderer.addAnimation(animName, _loc3_);
		}
	}

	function updateStarlingHitArea() {
		if (mStarlingRenderer == null || mActorGameObject == null) {
			return;
		}
		var _loc1_ = mActorGameObject.actorView;
		if (_loc1_ == null || _loc1_.fixedMouseHitRect != null) {
			return;
		}
		_loc1_.setStarlingHitArea(mStarlingRenderer.getLocalBounds());
	}

	function startStarlingSync() {
		if (mStarlingSyncComponent != null) {
			return;
		}
		mStarlingSyncComponent = new LayerWorkComponent(mDBFacade, "ActorRenderer");
		mStarlingSyncComponent.doEveryFrame(onStarlingSyncFrame);
	}

	function onStarlingSyncFrame(clock:GameClock) {
		var _loc2_:ActorView = null;
		syncStarlingTransform(true);
		mLayerSyncedStarlingRenderer = mStarlingRenderer;
		if (mTileStretchPending) {
			stretchTileToStarlingArt();
		}
		if (mUnculledSinceLastFrame) {
			mUnculledSinceLastFrame = false;
			_loc2_ = ASCompat.coerce(mActorGameObject != null ? mActorGameObject.actorView : null, actor.ActorView);
			if (_loc2_ != null && _loc2_.bodyAnimRenderer == this) {
				mActorGameObject.refreshRunIdleAnim();
			}
		}
	}

	function syncStarlingTransformUntilLayerSynced() {
		if (mLayerSyncedStarlingRenderer != mStarlingRenderer) {
			syncStarlingTransform();
		}
	}

	function syncStarlingTransform(updateCulling:Bool = false) {
		var _loc19_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc22_ = Math.NaN;
		var _loc23_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc2_ = false;
		var _loc26_ = false;
		if (mStarlingRenderer == null || mActorGameObject == null) {
			return;
		}
		var _loc14_ = mActorGameObject.actorView;
		if (_loc14_ == null || _loc14_.root == null) {
			return;
		}
		var _loc24_ = _loc14_.root;
		var _loc8_ = _loc24_.x;
		var _loc10_ = _loc24_.y;
		var _loc12_ = _loc24_.rotation;
		var _loc6_ = _loc24_.scaleX;
		var _loc7_ = _loc24_.scaleY;
		var _loc25_ = _loc24_.alpha;
		var _loc20_ = _loc24_.visible;
		var _loc16_ = _loc12_;
		var _loc21_ = ASCompat.reinterpretAs(mActorGameObject, NPCGameObject);
		if (_loc21_ != null && _loc21_.gmNpc.UseFlashRotation) {
			_loc16_ += _loc21_.flip != 0 ? -mHeading + 180 : mHeading;
		}
		var _loc9_ = _loc14_.body;
		var _loc3_ = _loc9_ != null ? _loc9_.scaleX : _loc6_;
		var _loc4_ = _loc9_ != null ? _loc9_.scaleY : _loc7_;
		var _loc11_ = this.x;
		var _loc13_ = this.y;
		if (mStarlingRenderer.transformStale || _loc25_ > 1 || _loc25_ < 0 || _loc8_ != mSyncedRootX || _loc10_ != mSyncedRootY
			|| _loc12_ != mSyncedRootRotation || _loc16_ != mSyncedRotation || _loc6_ != mSyncedRootScaleX || _loc7_ != mSyncedRootScaleY
			|| _loc25_ != mSyncedRootAlpha || _loc3_ != mSyncedBodyScaleX || _loc4_ != mSyncedBodyScaleY || _loc11_ != mSyncedOffsetX
			|| _loc13_ != mSyncedOffsetY) {
			_loc19_ = _loc11_ * _loc3_ * _loc6_;
			_loc17_ = _loc13_ * _loc4_ * _loc7_;
			if (_loc12_ == 0 && Math.isFinite(_loc19_) && Math.isFinite(_loc17_)) {
				_loc22_ = _loc8_ + _loc19_;
				_loc23_ = _loc10_ + _loc17_;
			} else {
				_loc15_ = _loc12_ * 3.141592653589793 / 180;
				_loc5_ = Math.cos(_loc15_);
				_loc18_ = Math.sin(_loc15_);
				_loc22_ = _loc8_ + _loc19_ * _loc5_ - _loc17_ * _loc18_;
				_loc23_ = _loc10_ + _loc19_ * _loc18_ + _loc17_ * _loc5_;
			}
			mStarlingRenderer.setTransform(_loc22_, _loc23_, _loc16_ * 3.141592653589793 / 180, _loc6_ * _loc3_, _loc7_ * _loc4_, _loc25_, _loc8_, _loc10_);
			mSyncedRootX = _loc8_;
			mSyncedRootY = _loc10_;
			mSyncedRootRotation = _loc12_;
			mSyncedRotation = _loc16_;
			mSyncedRootScaleX = _loc6_;
			mSyncedRootScaleY = _loc7_;
			mSyncedRootAlpha = _loc25_;
			mSyncedBodyScaleX = _loc3_;
			mSyncedBodyScaleY = _loc4_;
			mSyncedOffsetX = _loc11_;
			mSyncedOffsetY = _loc13_;
			mSyncedWorldX = _loc22_;
			mSyncedWorldY = _loc23_;
		} else {
			mStarlingRenderer.markLayerDirty();
		}
		if (updateCulling) {
			_loc2_ = _loc20_ && testCulled(mSyncedWorldX, mSyncedWorldY, Math.max(Math.abs(_loc6_ * _loc3_), Math.abs(_loc7_ * _loc4_)));
			if (mCulled && !_loc2_) {
				mUnculledSinceLastFrame = true;
			}
			_loc26_ = mCulled != _loc2_;
			mCulled = _loc2_;
			if (_loc26_ && _loc9_ != null && _loc14_.bodyAnimRenderer == this) {
				updateWeaponCulling(_loc9_);
			}
		}
		mStarlingRenderer.setVisibility(_loc20_, mCulled);
		mPendingVisible = _loc20_;
	}

	function testCulled(drawX:Float, drawY:Float, scale:Float):Bool {
		return isOffScreen(drawX, drawY, scale);
	}

	function updateWeaponCulling(body:Sprite) {
		var _loc3_ = 0;
		var _loc2_:WeaponRenderer = null;
		_loc3_ = 0;
		while (_loc3_ < body.numChildren) {
			_loc2_ = ASCompat.reinterpretAs(body.getChildAt(_loc3_), WeaponRenderer);
			if (_loc2_ != null) {
				_loc2_.followWielderCulling(mCulled);
			}
			_loc3_++;
		}
	}

	@:isVar public var isCulled(get, never):Bool;

	public function get_isCulled():Bool {
		return mCulled;
	}

	@:isVar public var hasStarlingArt(get, never):Bool;

	public function get_hasStarlingArt():Bool {
		return mStarlingRenderer != null;
	}

	function isOffScreen(drawX:Float, drawY:Float, scale:Float):Bool {
		if (mActorGameObject.isOwner || mDBFacade.camera == null) {
			return false;
		}
		var _loc4_ = mStarlingRenderer.canvasReach;
		var _loc5_ = mActorGameObject.actorData;
		var _loc6_ = _loc5_ != null ? Math.max(_loc5_.spriteWidth, _loc5_.spriteHeight) : Math.NaN;
		if (_loc6_ > 0) {
			_loc4_ = Math.max(_loc4_, _loc6_);
		} else {
			if (mContentRadiusStale) {
				mContentRadius = Math.max(mContentRadius, mStarlingRenderer.getContentRadius());
				mContentRadiusStale = false;
			}
			_loc4_ = Math.max(_loc4_, mContentRadius);
		}
		return !mDBFacade.camera.isInCullView(drawX, drawY, 256 + _loc4_ * scale);
	}

	function resetContentRadius() {
		mContentRadius = 0;
		mContentRadiusStale = true;
	}

	@:isVar var stretchesTile(get, never):Bool;

	function get_stretchesTile():Bool {
		return mTriggerState
			&& Std.isOfType(mActorGameObject, NPCGameObject)
			&& mActorGameObject.actorData != null
			&& mActorGameObject.actorData.gMActor != null
			&& mActorGameObject.isProp
			&& !mActorGameObject.actorData.isMover;
	}

	function stretchTileToStarlingArt() {
		var _loc1_ = ASCompat.coerce(mActorGameObject != null ? mActorGameObject.tile : null, dungeon.Tile);
		if (_loc1_ == null || mStarlingRenderer == null || Math.isNaN(mSyncedWorldX)) {
			return;
		}
		mTileStretchPending = false;
		if (mAnimName == "death") {
			return;
		}
		var _loc2_ = mStarlingRenderer.getWorldBounds();
		if (!_loc2_.isEmpty()) {
			_loc1_.expandBoundsRect(_loc2_);
		}
	}

	function onTileStretchFrame(clock:GameClock) {
		if (stretchTileToFlashArt(mTileStretchClip)) {
			stopTileStretchWork();
		}
	}

	function stopTileStretchWork() {
		if (mTileStretchWork != null) {
			mTileStretchWork.destroy();
		}
		mTileStretchWork = null;
		mTileStretchClip = null;
	}

	function stretchTileToFlashArt(idleClip:MovieClip):Bool {
		var _loc2_:DisplayObject = null;
		var _loc4_ = ASCompat.coerce(mActorGameObject != null ? mActorGameObject.tile : null, dungeon.Tile);
		var _loc3_ = ASCompat.coerce(mActorGameObject != null ? mActorGameObject.actorView : null, actor.ActorView);
		if (_loc4_ == null || _loc3_ == null || _loc3_.root == null) {
			return false;
		}
		var _loc6_ = idleClip.transform.matrix;
		_loc2_ = this;
		while (_loc2_ != _loc3_.root) {
			if (_loc2_ == null) {
				return false;
			}
			_loc6_.concat(_loc2_.transform.matrix);
			_loc2_ = _loc2_.parent;
		}
		if (mAnimName == "death") {
			return true;
		}
		_loc6_.concat(_loc3_.root.transform.matrix);
		var _loc5_ = boundsThrough(idleClip.getBounds(idleClip), _loc6_);
		if (!_loc5_.isEmpty()) {
			_loc4_.expandBoundsRect(_loc5_);
		}
		return true;
	}

	function movieClipSwfLoaded(movieClipClassName:String, swfAsset:SwfAsset) {
		var _loc9_:ActorMovieClipRenderer = null;
		var _loc7_:MovieClip = null;
		var _loc6_:MovieClip = null;
		var _loc10_:MovieClip = null;
		var _loc16_:MovieClip = null;
		if (!ASCompat.stringAsBool(movieClipClassName)) {
			notifyLoadComplete();
			return;
		}
		var _loc15_ = movieClipClassName;
		var _loc12_ = movieClipClassName + "_" + "run";
		var _loc3_ = movieClipClassName + "_" + "suffer";
		var _loc13_ = movieClipClassName + "_" + "death";
		var _loc4_ = swfAsset.getClass(_loc15_, false);
		var _loc14_ = swfAsset.getClass(_loc12_, true);
		var _loc5_ = swfAsset.getClass(_loc3_, true);
		var _loc11_ = swfAsset.getClass(_loc13_, true);
		var _loc8_ = isSwfFallbackDebug();
		if (_loc4_ != null) {
			_loc7_ = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
			if (_loc8_) {
				SwfFallbackDebug.applyOutline(mDBFacade, _loc7_);
			}
			_loc9_ = new ActorMovieClipRenderer(mDBFacade, _loc7_);
			setAnimInDictionary("idle", _loc9_);
			movieClipRendererLoaded(_loc7_);
			if (stretchesTile && mTileStretchWork == null) {
				mTileStretchClip = _loc7_;
				mTileStretchWork = new LayerWorkComponent(mDBFacade, "ActorRenderer.tileStretch");
				mTileStretchWork.doEveryFrame(onTileStretchFrame);
			}
		}
		if (_loc14_ != null) {
			_loc6_ = ASCompat.coerce(ASCompat.createInstance(_loc14_, []), flash.display.MovieClip);
			if (_loc8_) {
				SwfFallbackDebug.applyOutline(mDBFacade, _loc6_);
			}
			_loc9_ = new ActorMovieClipRenderer(mDBFacade, _loc6_);
			setAnimInDictionary("run", _loc9_);
		}
		if (_loc5_ != null) {
			_loc10_ = ASCompat.coerce(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip);
			if (_loc8_) {
				SwfFallbackDebug.applyOutline(mDBFacade, _loc10_);
			}
			_loc9_ = new ActorMovieClipRenderer(mDBFacade, _loc10_);
			setAnimInDictionary("suffer", _loc9_);
		}
		if (_loc11_ != null) {
			_loc16_ = ASCompat.coerce(ASCompat.createInstance(_loc11_, []), flash.display.MovieClip);
			if (_loc8_) {
				SwfFallbackDebug.applyOutline(mDBFacade, _loc16_);
			}
			_loc9_ = new ActorMovieClipRenderer(mDBFacade, _loc16_);
			setAnimInDictionary("death", _loc9_);
		}
		notifyLoadComplete();
	}

	function movieClipRendererLoaded(asset:MovieClip) {}

	function reportSwfFallback(reason:String, asError:Bool = true) {
		var _loc6_ = mActorGameObject != null && mActorGameObject.actorData != null;
		var _loc4_ = _loc6_ ? mActorGameObject.actorData.constant : "?";
		var _loc5_:String = _loc6_ ? movieClipClassName : null;
		var _loc3_:String = _loc6_ ? this.swfFilePath : null;
		SwfFallbackDebug.report(mDBFacade, fallbackCategory, _loc4_ + " (" + _loc5_ + ")", _loc3_, reason, asError);
	}

	@:isVar var fallbackCategory(get, never):String;

	function get_fallbackCategory():String {
		if (mActorGameObject == null || mActorGameObject.actorData == null || mActorGameObject.actorData.gMActor == null) {
			return "ACTOR";
		}
		var _loc1_:ASObject = mActorGameObject.actorData.gMActor;
		return "ACTOR:" + Std.string(_loc1_.CharType) + "/" + Std.string(_loc1_.Species);
	}

	function isSwfFallbackDebug():Bool {
		return SwfFallbackDebug.isEnabled(mDBFacade, fallbackCategory);
	}

	function loadErrorCallback() {
		Logger.error("loadAnimatedSpriteSheetRenderer error");
	}

	@:isVar public var currentAnimName(get, never):String;

	public function get_currentAnimName():String {
		return mAnimName;
	}

	public function setLayer(layerIndex:Int) {
		mPendingLayer = layerIndex;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setLayer(layerIndex);
		}
	}

	public function setHighlightFilter(color:UInt, alpha:Float = 8, blur:Float = 2) {
		mHighlightActive = true;
		mHighlightColor = color;
		mHighlightAlpha = alpha;
		mHighlightBlur = blur;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setHighlightFilter(color, alpha, blur);
		}
	}

	public function clearHighlightFilter() {
		mHighlightActive = false;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.clearHighlightFilter();
		}
	}

	public function setPersistentGlowFilter(color:UInt, alpha:Float = 8, blur:Float = 2) {
		mPersistentGlowActive = true;
		mPersistentGlowColor = color;
		mPersistentGlowAlpha = alpha;
		mPersistentGlowBlur = blur;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setPersistentGlowFilter(color, alpha, blur);
		}
	}

	public function clearPersistentGlowFilter() {
		mPersistentGlowActive = false;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.clearPersistentGlowFilter();
		}
	}

	public function applyColorFilter(matrix:Array<ASAny>) {
		mColorFilterMatrix = matrix;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setColorFilter(matrix);
		}
	}

	public function clearColorFilter() {
		mColorFilterMatrix = null;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.clearColorFilter();
		}
	}

	public function applyStatusTint(color:UInt, amount:Float) {
		mStatusTintColor = color;
		mStatusTintAmount = amount;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setStatusTint(color, amount);
		}
	}

	public function clearStatusTint() {
		mStatusTintAmount = 0;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.clearStatusTint();
		}
	}

	function setAnimInDictionary(animName:String, renderer:IRenderer) {
		if (mIsStarlingBound || mStarlingRenderer != null) {
			renderer.destroy();
			return;
		}
		mAnims.add(animName, renderer);
		if (mAnimName == animName) {
			this.play(mAnimName, 0, true, mLoop);
		}
	}

	public function hasAnim(animName:String):Bool {
		if (mStarlingRenderer != null) {
			return mStarlingRenderer.hasAnim(animName);
		}
		if (mIsStarlingBound && (animName == "idle" || animName == "run" || animName == "suffer")) {
			return true;
		}
		var _loc2_ = this.getRenderer(animName);
		return _loc2_ != null;
	}

	public function getAnimDurationInSeconds(animName:String):Float {
		if (mStarlingRenderer != null) {
			return mStarlingRenderer.getAnimDurationInSeconds(animName);
		}
		var _loc2_ = ASCompat.coerce(mAnims.itemFor(animName), brain.render.IRenderer);
		return _loc2_ != null ? _loc2_.durationInSeconds : 0;
	}

	public function getAnimFrameCount(animName:String):Float {
		if (mStarlingRenderer != null) {
			return mStarlingRenderer.getAnimFrameCount(animName);
		}
		var _loc2_ = ASCompat.coerce(mAnims.itemFor(animName), brain.render.IRenderer);
		return _loc2_ != null ? _loc2_.frameCount : 0;
	}

	public function loadAssets() {
		switch (this.assetType) {
			case "SPRITE_SHEET":
				if (isStarlingActor && !mActorGameObject.forceFlash) {
					this.y = ActorView.BODY_Y_OFFSET;
					mIsStarlingBound = true;
					loadMovieClipAssets();
				} else {
					reportSwfFallback(mActorGameObject != null
						&& mActorGameObject.forceFlash ? "forceFlash is set" : (StarlingAssetMapper.getActorAtlasFile(swfFilePath) == null ? "no ATF atlas folder with Animation.json at "
							+ swfFilePath.substring(0, swfFilePath.lastIndexOf(".")) : "actor is a prop or has no GameMaster actor row"));
					this.y = ActorView.BODY_Y_OFFSET;
					if (mPreloadSprites) {
						loadSpriteSheetAssets();
					} else {
						preloadStandardSpriteSheetAssets();
					}
				}

			case "MOVIE_CLIP":
				loadMovieClipAssets();

			default:
				Logger.error("Unknown assetType: " + this.assetType);
		}
	}

	function loadSpriteSheetAsset(animName:String) {
		var spriteSheetSwfPath:String;
		var shClassName:String;
		if (mAnims.hasKey(animName)) {
			return;
		}
		if (ASCompat.toBool(mLoadingAnims.itemFor(animName))) {
			return;
		}
		mLoadingAnims.add(animName, true);
		spriteSheetSwfPath = this.swfFilePath;
		if (StarlingAssetMapper.isArt3DPath(spriteSheetSwfPath)) {
			return;
		}
		shClassName = getSpriteSheetClassName(animName);
		mAssetLoadingComponent.getSpriteSheetAsset(spriteSheetSwfPath, shClassName, function(param1:brain.assetRepository.SpriteSheetAsset) {
			var _loc2_ = new ActorSpriteSheetRenderer(mPreRenderWorkComponent, param1, mActorGameObject.actorData.constant);
			if (isSwfFallbackDebug()) {
				SwfFallbackDebug.applyOutline(mDBFacade, _loc2_.displayObject);
			}
			setAnimInDictionary(animName, _loc2_);
		}, loadErrorCallback, true, null, shClassName);
	}

	function preloadStandardSpriteSheetAssets() {
		var _loc1_:String;
		final __ax4_iter_20 = mStandardAnimList;
		if (checkNullIteratee(__ax4_iter_20))
			for (_tmp_ in __ax4_iter_20) {
				_loc1_ = _tmp_;
				loadSpriteSheetAsset(_loc1_);
			}
	}

	function loadSpriteSheetAssets() {
		preloadStandardSpriteSheetAssets();
	}

	function getRenderer(animName:String):IRenderer {
		var _loc2_ = ASCompat.coerce(mAnims.itemFor(animName), brain.render.IRenderer);
		if (_loc2_ == null && this.assetType == "SPRITE_SHEET" && !mIsStarlingBound) {
			loadSpriteSheetAsset(animName);
		}
		return _loc2_;
	}

	public function forceFrame(frameNumber:Int) {
		if (mStarlingRenderer != null) {
			mStarlingRenderer.forceFrame(frameNumber);
			return;
		}
		if (mCurrentRenderer != null) {
			mCurrentRenderer.setFrame((frameNumber : UInt));
		}
	}

	public function setFrame(animName:String, frameNumber:Int) {
		if (mStarlingRenderer != null) {
			mAnimName = animName;
			if (mStarlingRenderer.heading != mHeading) {
				mStarlingRenderer.heading = mHeading;
			}
			if (false && mActorGameObject != null) {
				Logger.debugch("heading",
					"ActorRenderer setFrame id="
					+ mActorGameObject.id
					+ " const="
					+ (mActorGameObject.actorData != null ? mActorGameObject.actorData.constant : "?")
					+ " anim="
					+ animName
					+ " heading="
					+ mHeading
					+ " starlingLabel="
					+ mStarlingRenderer.currentDirectionLabel);
			}
			syncStarlingTransformUntilLayerSynced();
			mStarlingRenderer.setFrame(animName, frameNumber);
			updateStarlingHitArea();
			mContentRadiusStale = true;
			return;
		}
		stop();
		var _loc3_ = this.getRenderer(animName);
		if (_loc3_ != null) {
			mCurrentRenderer = _loc3_;
			this.heading = mHeading;
			this.addChild(mCurrentRenderer.displayObject);
			mCurrentRenderer.setFrame((frameNumber : UInt));
		}
	}

	public function play(animName:String, startingFrame:Int = 0, restart:Bool = false, loop:Bool = true, playRate:Float = 1) {
		mAnimName = animName;
		mLoop = loop;
		if (mStarlingRenderer != null) {
			if (mStarlingRenderer.heading != mHeading) {
				mStarlingRenderer.heading = mHeading;
			}
			if (restart || mStarlingRenderer.currentAnimName != animName) {
				mStarlingRenderer.play(animName, startingFrame, mLoop, playRate);
				updateStarlingHitArea();
				mContentRadiusStale = true;
			} else {
				mStarlingRenderer.playRate = playRate;
				mStarlingRenderer.loop = loop;
			}
			if (false && mActorGameObject != null) {
				Logger.debugch("heading",
					"ActorRenderer play id="
					+ mActorGameObject.id
					+ " const="
					+ (mActorGameObject.actorData != null ? mActorGameObject.actorData.constant : "?")
					+ " anim="
					+ animName
					+ " heading="
					+ mHeading
					+ " starlingAnim="
					+ mStarlingRenderer.currentAnimName
					+ " starlingLabel="
					+ mStarlingRenderer.currentDirectionLabel);
			}
			syncStarlingTransformUntilLayerSynced();
			return;
		}
		var _loc6_ = this.getRenderer(animName);
		if (_loc6_ != null) {
			_loc6_.playRate = playRate;
			if (mCurrentRenderer == _loc6_) {
				if (restart) {
					_loc6_.play((startingFrame : UInt), mLoop);
				}
			} else {
				stop();
				mAnimName = animName;
				mLoop = loop;
				mCurrentRenderer = _loc6_;
				this.heading = mHeading;
				_loc6_.play((startingFrame : UInt), mLoop);
				this.addChild(mCurrentRenderer.displayObject);
			}
		}
	}

	@:isVar public var heading(never, set):Float;

	public function set_heading(value:Float):Float {
		var _loc4_:String = null;
		var _loc2_:NPCGameObject = null;
		var _loc3_ = false;
		mHeading = value;
		if (false && mActorGameObject != null) {
			_loc4_ = mStarlingRenderer != null ? mStarlingRenderer.rendererType : (mCurrentRenderer != null ? mCurrentRenderer.rendererType : "null");
			Logger.debugch("heading",
				"ActorRenderer set heading id="
				+ mActorGameObject.id
				+ " const="
				+ (mActorGameObject.actorData != null ? mActorGameObject.actorData.constant : "?")
				+ " heading="
				+ mHeading
				+ " renderer="
				+ _loc4_
				+ " anim="
				+ mAnimName);
		}
		if (mStarlingRenderer != null) {
			mStarlingRenderer.heading = value;
			syncStarlingTransformUntilLayerSynced();
			return value;
		}
		if (mCurrentRenderer != null) {
			mCurrentRenderer.heading = value;
			_loc2_ = ASCompat.reinterpretAs(mActorGameObject, NPCGameObject);
			if (_loc2_ != null && _loc2_.gmNpc.UseFlashRotation) {
				if (_loc2_.flip != 0) {
					mCurrentRenderer.displayObject.rotation = -mHeading + 180;
				} else {
					mCurrentRenderer.displayObject.rotation = mHeading;
				}
			}
			if (Std.isOfType(mCurrentRenderer, ActorSpriteSheetRenderer)) {
				_loc3_ = 90 > mHeading && mHeading > -90;
				this.scaleX = _loc3_ ? 1 : -1;
			}
		}
		return value;
	}

	@:isVar public var currentFrame(get, never):Int;

	public function get_currentFrame():Int {
		if (mStarlingRenderer != null) {
			return mStarlingRenderer.currentFrame;
		}
		if (mCurrentRenderer != null) {
			return (mCurrentRenderer.currentFrame : Int);
		}
		return 0;
	}

	@:isVar public var loop(get, never):Bool;

	public function get_loop():Bool {
		return mLoop;
	}

	override public function set_visible(value:Bool) {
		mPendingVisible = value;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.visible = value;
			super.visible = false;
		} else {
			super.visible = value;
		}
		return value;
	}

	public function stop() {
		if (mStarlingRenderer != null) {
			mStarlingRenderer.stop();
			mAnimName = null;
			return;
		}
		if (mCurrentRenderer != null) {
			mCurrentRenderer.stop();
			if (this.contains(mCurrentRenderer.displayObject)) {
				this.removeChild(mCurrentRenderer.displayObject);
			}
			mCurrentRenderer = null;
			mAnimName = null;
		}
	}

	static function __init__() {
		mStandardAnimList = ["idle", "death"];
	}
}
