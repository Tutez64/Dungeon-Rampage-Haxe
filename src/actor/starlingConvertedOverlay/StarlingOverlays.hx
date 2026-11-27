package actor.starlingConvertedOverlay;

import actor.ActorNametag;
import brain.clock.GameClock;
import brain.starling.StarlingLayer;
import brain.starling.swfConverter.BakeBudget;
import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedGlyphFont;
import brain.starling.swfConverter.BakedPages;
import brain.workLoop.LayerWorkComponent;
import facade.DBFacade;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.filters.BitmapFilter;
import flash.geom.Rectangle;
import flash.text.TextField;

class StarlingOverlays {
	@:allow(actor.starlingConvertedOverlay) static inline final CELL_READY = 0;

	@:allow(actor.starlingConvertedOverlay) static inline final CELL_BUSY = 1;

	@:allow(actor.starlingConvertedOverlay) static inline final CELL_REFUSED = 2;

	static inline final BAKES_PER_FRAME = 4;

	@:allow(actor.starlingConvertedOverlay) static inline final SCALE_TOLERANCE:Float = 0.005;

	static inline final ZOOM_EXACT:Float = 0.001;

	static inline final SETTLE_FRAMES = 30;

	static inline final SCALE_STEPS:Float = 1000;

	static inline final CULL_MARGIN:Float = 300;

	static inline final MAX_FLOATERS = 256;

	static inline final FONT_RETRY_FRAMES = 60;

	static inline final BIG_FONT_SCALE:Float = 1.8;

	static inline final BIG_FONT_FROM:Float = 1.25;

	static inline final FLOATER_CHARS = "0123456789+-!";

	static inline final MAX_BLUR:Float = 255;

	static var sInstance:StarlingOverlays;

	static final COMPARE_TAGS:ASFunction = TagSprite.compare;

	var mFacade:DBFacade;

	var mWork:LayerWorkComponent;

	var mPages:BakedPages;

	var mAboveFade:DisplayObject;

	var mLayer:StarlingLayer;

	var mRoot:StarlingOverlayRoot;

	var mOn:Bool = false;

	var mFrame:Int = 0;

	var mZoom:Float = 0;

	var mPendingZoom:Float = 0;

	var mPendingFrames:Int = 0;

	var mBakesLeft:Int = 0;

	var mLastCell:BakedCell;

	var mView:Rectangle;

	final mTags:Vector<StarlingNametag> = new Vector((0 : UInt));

	final mViewPool:Vector<TagView> = new Vector((0 : UInt));

	final mKept:Vector<BakedCell> = new Vector((0 : UInt));

	final mFloaters:Vector<StarlingDamageFloater> = new Vector((0 : UInt));

	final mFloaterPool:Vector<StarlingDamageFloater> = new Vector((0 : UInt));

	final mLayout:FloaterLayout = new FloaterLayout();

	var mGlow:BakedGlyphFont;

	var mFill:BakedGlyphFont;

	var mBigGlow:BakedGlyphFont;

	var mBigFill:BakedGlyphFont;

	var mFontZoom:Float = 0;

	var mCrit:BakedGlyphFont;

	var mBigCrit:BakedGlyphFont;

	var mFontRetry:Int = 0;

	var mLastTime:Int = 0;

	var mGlowKnockout:Bool = false;

	public function new(facade:DBFacade) {
		mFacade = facade;
		mPages = new BakedPages("world", 1024, 512);
		mAboveFade = facade.sceneGraphManager.getLayer(46);
		mWork = new LayerWorkComponent(facade, "StarlingOverlays");
		mWork.doEveryFrame(onFrame);
	}

	public static function wanted(facade:DBFacade):Bool {
		return facade != null && facade.featureFlags != null && facade.featureFlags.getFlagValue("starling-overlays");
	}

	public static function get(facade:DBFacade):StarlingOverlays {
		if (sInstance == null) {
			sInstance = new StarlingOverlays(facade);
		}
		return sInstance;
	}

	public static function drawsFloaters(facade:DBFacade):Bool {
		return wanted(facade) && get(facade).floatersReady;
	}

	static function scaledFilters(filters:Array<ASAny>, factor:Float):Array<ASAny> {
		var _loc5_:BitmapFilter = null;
		var _loc3_:Array<ASAny> = [];
		var _loc4_:BitmapFilter;
		if (checkNullIteratee(filters))
			for (_tmp_ in filters) {
				_loc4_ = ASCompat.coerce(_tmp_, flash.filters.BitmapFilter);
				_loc5_ = _loc4_.clone();
				if ((_loc5_ : ASAny).hasOwnProperty("blurX")) {
					(_loc5_ : ASAny)["blurX"] = Math.min(255, ASCompat.toNumber((_loc5_ : ASAny)["blurX"]) * factor);
				}
				if ((_loc5_ : ASAny).hasOwnProperty("blurY")) {
					(_loc5_ : ASAny)["blurY"] = Math.min(255, ASCompat.toNumber((_loc5_ : ASAny)["blurY"]) * factor);
				}
				if ((_loc5_ : ASAny).hasOwnProperty("distance")) {
					(_loc5_ : ASAny)["distance"] = ASCompat.toNumber((_loc5_ : ASAny)["distance"]) * factor;
				}
				_loc3_.push(_loc5_);
			}
		return _loc3_;
	}

	public function addTag(nametag:ActorNametag, top:DisplayObject, art:DisplayObjectContainer, name:TextField, afk:TextField, hp:DisplayObjectContainer,
			fill:DisplayObject):StarlingNametag {
		var _loc8_ = new StarlingNametag(this, nametag, top, art, name, afk, hp, fill);
		mTags.push(_loc8_);
		return _loc8_;
	}

	public function spawnFloater(style:FloaterStyle, rootX:Float, topY:Float, holdTicks:UInt, totalTicks:UInt, scaleDampening:Float, speed:Float,
			buff:Bool):Bool {
		if (!floatersReady || !hasGlyphs(style.text)) {
			return false;
		}
		if (mFloaters.length >= 256) {
			recycle(mFloaters.shift());
		}
		var _loc9_ = newFloater(style);
		var _loc10_ = mFacade.gameClock.tickLength;
		_loc9_.start(rootX - mLayout.bitmapWidth * style.scale * 0.5, topY, style.scale, style.rotation, style.directionX, style.directionY,
			holdTicks * _loc10_, totalTicks * _loc10_, scaleDampening, speed, buff);
		mRoot.floaters.addChild(_loc9_);
		mFloaters.push(_loc9_);
		return true;
	}

	function newFloater(style:FloaterStyle):StarlingDamageFloater {
		var _loc2_ = style.scale > 1.25;
		var _loc3_ = mFloaterPool.length > 0 ? mFloaterPool.pop() : new StarlingDamageFloater();
		_loc3_.visible = true;
		_loc3_.big = _loc2_;
		_loc3_.crit = style.crit;
		_loc3_.setFonts(_loc2_ ? mBigGlow : mGlow, _loc2_ ? mBigFill : mFill, critFont(_loc3_));
		mLayout.place(_loc3_.setText(style.text, style.color));
		_loc3_.placeRows(mLayout.inkX - mLayout.left, mLayout.inkY - mLayout.top, mLayout.labelScaleX, mLayout.labelScaleY);
		return _loc3_;
	}

	function hasGlyphs(text:String):Bool {
		var _loc2_ = 0;
		if (text == null) {
			return false;
		}
		_loc2_ = 0;
		while (_loc2_ < text.length) {
			if (!mFill.hasGlyph(text.charCodeAt(_loc2_))) {
				return false;
			}
			_loc2_++;
		}
		return true;
	}

	@:isVar var floatersReady(get, never):Bool;

	function get_floatersReady():Bool {
		return mOn && mFill != null && mRoot != null;
	}

	@:allow(actor.starlingConvertedOverlay) @:isVar var aboveFadeLayer(get, never):DisplayObject;

	function get_aboveFadeLayer():DisplayObject {
		return mAboveFade;
	}

	@:allow(actor.starlingConvertedOverlay) @:isVar var snapPixelsPerUnit(get, never):Float;

	function get_snapPixelsPerUnit():Float {
		if (mLayer == null || mZoom <= 0) {
			return 0;
		}
		var _loc2_ = mLayer.transformationMatrix;
		var _loc1_ = Math.sqrt(_loc2_.a * _loc2_.a + _loc2_.b * _loc2_.b) * mFacade.starlingLayerManager.starlingInstance._contentScaleFactor;
		return Math.isFinite(_loc1_) && Math.abs(_loc1_ / mZoom - 1) <= 0.005 ? _loc1_ : 0;
	}

	@:allow(actor.starlingConvertedOverlay) @:isVar var cameraOffsetX(get, never):Float;

	function get_cameraOffsetX():Float {
		return mFacade.starlingLayerManager.worldCameraOffsetX;
	}

	@:allow(actor.starlingConvertedOverlay) @:isVar var cameraOffsetY(get, never):Float;

	function get_cameraOffsetY():Float {
		return mFacade.starlingLayerManager.worldCameraOffsetY;
	}

	@:allow(actor.starlingConvertedOverlay) @:isVar var lastCell(get, never):BakedCell;

	function get_lastCell():BakedCell {
		return mLastCell;
	}

	@:allow(actor.starlingConvertedOverlay) function bakeScale(chainScale:Float):Float {
		return Math.max(1, Math.fround(mZoom * chainScale * 1000)) / 1000;
	}

	@:allow(actor.starlingConvertedOverlay) function cellFor(key:String, source:DisplayObject, scale:Float, hide:Vector<DisplayObject>, keep:Bool):Int {
		var _loc6_ = mPages.acquire(key);
		if (_loc6_ == null) {
			if (mBakesLeft <= 0) {
				return 1;
			}
			mBakesLeft = mBakesLeft - 1;
			_loc6_ = mPages.bake(key, source, scale, hide);
			if (_loc6_ == null) {
				return 2;
			}
			if (keep) {
				mKept.push(mPages.acquire(key));
			}
		}
		mLastCell = _loc6_;
		return 0;
	}

	@:allow(actor.starlingConvertedOverlay) function releaseCell(cell:BakedCell) {
		mPages.release(cell);
	}

	@:allow(actor.starlingConvertedOverlay) function isCulled(x:Float, y:Float):Bool {
		var _loc3_ = mView;
		return _loc3_ != null && (x < _loc3_.left - 300 || x > _loc3_.right + 300 || y < _loc3_.top - 300 || y > _loc3_.bottom + 300);
	}

	@:allow(actor.starlingConvertedOverlay) function takeView():TagView {
		var _loc1_ = mViewPool.length > 0 ? mViewPool.pop() : new TagView();
		_loc1_.tag.visible = false;
		mRoot.tags.addChild(_loc1_.tag);
		return _loc1_;
	}

	@:allow(actor.starlingConvertedOverlay) function returnView(view:TagView) {
		if (mRoot == null || view.tag.parent != mRoot.tags) {
			return;
		}
		view.tag.removeFromParent();
		view.tag.owner = null;
		mViewPool.push(view);
	}

	@:allow(actor.starlingConvertedOverlay) function removeTag(tag:StarlingNametag) {
		var _loc2_ = mTags.indexOf(tag);
		if (_loc2_ < 0) {
			return;
		}
		mTags[_loc2_] = mTags[mTags.length - 1];
		mTags.length--;
	}

	function onFrame(clock:GameClock) {
		var _loc5_ = 0;
		var _loc7_ = wanted(mFacade) && ensureRoot();
		if (_loc7_ != mOn) {
			mOn = _loc7_;
			if (!_loc7_) {
				switchToFlash();
			}
		}
		var _loc3_ = flash.Lib.getTimer();
		var _loc2_ = (_loc3_ - mLastTime) * 0.001 * mFacade.gameClock.timeScale;
		mLastTime = _loc3_;
		if (!_loc7_) {
			return;
		}
		mFrame = mFrame + 1;
		updateZoom();
		if (mZoom <= 0) {
			return;
		}
		if ((mFill == null || mFontZoom != mZoom) && mFrame >= mFontRetry && BakeBudget.mayAllocate) {
			buildFonts();
		}
		mBakesLeft = 4;
		var _loc6_ = mFacade.camera;
		var _loc4_ = _loc6_ != null && _loc6_.rotation == 0 && _loc6_._shakeRotation == 0;
		mView = _loc4_ && _loc6_.targetObject != null && _loc6_.targetObject.parent != null ? _loc6_.visibleRectangle : null;
		_loc5_ = 0;
		while (_loc5_ < mTags.length) {
			mTags[_loc5_].update(mFrame);
			_loc5_++;
		}
		if (!tagsInOrder()) {
			mRoot.tags.sortChildren(COMPARE_TAGS);
		}
		advanceFloaters(_loc2_);
	}

	function tagsInOrder():Bool {
		var _loc1_ = 0;
		var _loc2_ = mRoot.tags;
		_loc1_ = 1;
		while (_loc1_ < _loc2_.numChildren) {
			if (ASCompat.toNumber(COMPARE_TAGS(_loc2_.getChildAt(_loc1_ - 1), _loc2_.getChildAt(_loc1_))) > 0) {
				return false;
			}
			_loc1_++;
		}
		return true;
	}

	function ensureRoot():Bool {
		var _loc1_ = mFacade.starlingLayerManager;
		var _loc2_ = _loc1_ != null && _loc1_.isReady() ? _loc1_.starlingOverlayLayer : null;
		if (_loc2_ == null) {
			return false;
		}
		if (mLayer != _loc2_) {
			mLayer = _loc2_;
			return false;
		}
		if (mRoot == null) {
			mRoot = new StarlingOverlayRoot();
		}
		if (mRoot.parent != _loc2_) {
			_loc2_.addChild(mRoot);
		}
		return true;
	}

	function switchToFlash() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mTags.length) {
			mTags[_loc1_].switchToFlash();
			_loc1_++;
		}
		_loc1_ = 0;
		while (_loc1_ < mFloaters.length) {
			recycle(mFloaters[_loc1_]);
			_loc1_++;
		}
		mFloaters.length = 0;
	}

	function updateZoom() {
		var _loc2_ = mLayer.transformationMatrix;
		var _loc1_ = Math.sqrt(_loc2_.a * _loc2_.a + _loc2_.b * _loc2_.b) * mFacade.starlingLayerManager.starlingInstance._contentScaleFactor;
		if (_loc1_ <= 0 || !Math.isFinite(_loc1_)) {
			return;
		}
		if (mZoom > 0) {
			if (Math.abs(_loc1_ / mZoom - 1) <= 0.001) {
				mPendingFrames = 0;
				return;
			}
			if (mPendingFrames == 0 || Math.abs(_loc1_ / mPendingZoom - 1) > 0.001) {
				mPendingZoom = _loc1_;
				mPendingFrames = 0;
			}
			if (++mPendingFrames < 30) {
				return;
			}
			mPendingFrames = 0;
		}
		mZoom = _loc1_;
		rebakeAll();
	}

	function rebakeAll() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mKept.length) {
			mPages.release(mKept[_loc1_]);
			_loc1_++;
		}
		mKept.length = 0;
		_loc1_ = 0;
		while (_loc1_ < mTags.length) {
			mTags[_loc1_].rescale();
			_loc1_++;
		}
		mFontZoom = 0;
		mFontRetry = 0;
	}

	function advanceFloaters(seconds:Float) {
		var _loc4_ = 0;
		var _loc3_:StarlingDamageFloater = null;
		var _loc2_ = mFloaters.length;
		var _loc5_ = 0;
		_loc4_ = 0;
		while (_loc4_ < _loc2_) {
			_loc3_ = mFloaters[_loc4_];
			if (_loc3_.advance(seconds)) {
				mFloaters[_loc5_++] = _loc3_;
			} else {
				recycle(_loc3_);
			}
			_loc4_++;
		}
		mFloaters.length = _loc5_;
	}

	function recycle(floater:StarlingDamageFloater) {
		floater.removeFromParent();
		mFloaterPool.push(floater);
	}

	function buildFonts() {
		var _loc4_:BakedGlyphFont;
		var _loc6_:String = null;
		var _loc9_ = 0;
		var _loc16_:StarlingDamageFloater = null;
		mFontRetry = mFrame + 60;
		var _loc17_ = mFacade.hud != null ? mFacade.hud.floaterTextClass : null;
		var _loc19_ = _loc17_ != null ? ASCompat.dynamicAs(ASCompat.createInstance(_loc17_, []), MovieClip) : null;
		var _loc10_ = _loc19_ != null ? ASCompat.reinterpretAs(_loc19_.getChildByName("label"), TextField) : null;
		if (_loc10_ == null) {
			return;
		}
		mLayout.measure(_loc19_, _loc10_);
		var _loc11_ = Math.abs(mLayout.labelScaleY) > 0 ? Math.abs(mLayout.labelScaleY) : 1;
		var _loc8_ = mZoom * _loc11_;
		var _loc1_ = _loc10_.filters ?? [];
		var _loc13_ = glowOnly(_loc1_);
		var _loc12_ = BakedGlyphFont.build(mPages, "floater", _loc10_, _loc8_, "0123456789+-!", 1);
		var _loc21_ = BakedGlyphFont.build(mPages, "floater", _loc10_, _loc8_ * 1.8, "0123456789+-!", 1);
		var _loc18_:BakedGlyphFont = null;
		var _loc14_:BakedGlyphFont = null;
		if (_loc13_ != null) {
			_loc6_ = mGlowKnockout ? "floaterGlow" : "floaterFull";
			_loc10_.filters = cast(scaledFilters(_loc13_, mZoom));
			_loc18_ = BakedGlyphFont.build(mPages, _loc6_, _loc10_, _loc8_, "0123456789+-!", 0);
			_loc10_.filters = cast(scaledFilters(_loc13_, mZoom * 1.8));
			_loc14_ = BakedGlyphFont.build(mPages, _loc6_, _loc10_, _loc8_ * 1.8, "0123456789+-!", 0);
		}
		var _loc2_ = FloaterStyle.CRIT_GLOW.clone();
		(_loc2_ : ASAny)["knockout"] = true;
		_loc10_.filters = cast(scaledFilters(_loc1_.concat((cast [_loc2_])), mZoom));
		var _loc15_ = BakedGlyphFont.build(mPages, "floaterCrit", _loc10_, _loc8_, "0123456789+-!", 0);
		_loc10_.filters = cast(scaledFilters(_loc1_.concat((cast [_loc2_])), mZoom * 1.8));
		var _loc3_ = BakedGlyphFont.build(mPages, "floaterCrit", _loc10_, _loc8_ * 1.8, "0123456789+-!", 0);
		var _loc5_:Array<ASAny> = [_loc12_, _loc21_, _loc18_, _loc14_, _loc15_, _loc3_];
		if (_loc12_ == null || _loc21_ == null || _loc15_ == null || _loc3_ == null || _loc13_ != null && (_loc18_ == null || _loc14_ == null)) {
			if (checkNullIteratee(_loc5_))
				for (_tmp_ in _loc5_) {
					_loc4_ = ASCompat.coerce(_tmp_, brain.starling.swfConverter.BakedGlyphFont);
					if (_loc4_ != null) {
						_loc4_.release();
					}
				}
			return;
		}
		var _loc7_:Array<ASAny> = [mFill, mBigFill, mGlow, mBigGlow, mCrit, mBigCrit];
		mFill = _loc12_;
		mBigFill = _loc21_;
		mGlow = _loc18_;
		mBigGlow = _loc14_;
		mCrit = _loc15_;
		mBigCrit = _loc3_;
		mFontZoom = mZoom;
		_loc9_ = 0;
		while (_loc9_ < mFloaters.length) {
			_loc16_ = mFloaters[_loc9_];
			_loc16_.setFonts(_loc16_.big ? _loc14_ : _loc18_, _loc16_.big ? _loc21_ : _loc12_, critFont(_loc16_));
			_loc9_++;
		}
		var _loc20_:BakedGlyphFont;
		if (checkNullIteratee(_loc7_))
			for (_tmp_ in _loc7_) {
				_loc20_ = ASCompat.coerce(_tmp_, brain.starling.swfConverter.BakedGlyphFont);
				if (_loc20_ != null) {
					_loc20_.release();
				}
			}
	}

	function critFont(floater:StarlingDamageFloater):BakedGlyphFont {
		return floater.crit ? (floater.big ? mBigCrit : mCrit) : null;
	}

	function glowOnly(filters:Array<ASAny>):Array<ASAny> {
		var _loc2_:BitmapFilter = null;
		mGlowKnockout = false;
		if (filters == null || filters.length == 0) {
			return null;
		}
		if (filters.length == 1 && filters[0].hasOwnProperty("knockout")) {
			_loc2_ = cast(filters[0], BitmapFilter).clone();
			(_loc2_ : ASAny)["knockout"] = true;
			mGlowKnockout = true;
			return [_loc2_];
		}
		return filters;
	}
}
