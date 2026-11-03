package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedPages;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;

class ArtNode {
	public static inline final CONTAINER = "container";

	public static inline final STATIC = "static";

	public static inline final TEXT = "text";

	public static inline final STATES = "states";

	public static inline final TIMELINE = "timeline";

	public static inline final FLIPBOOK = "flipbook";

	static var sEvictCells:ASDictionary<ASAny, ASAny> = new ASDictionary();

	static var sEvictNodes:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public var name:String;

	public var kind:String = "container";

	public var key:String;

	public var matrix:Matrix = new Matrix();

	public var alpha:Float = 1;

	public var visible:Bool = true;

	public var blendMode:String = "normal";

	public var colorTransform:ColorTransform = new ColorTransform();

	public var children:Vector<ArtNode> = new Vector((0 : UInt));

	public var cell:BakedCell;

	@:allow(UI.Hud.StarlingConverted) var hitCell:BakedCell;

	public var frames:Vector<ArtFrame> = new Vector((0 : UInt));

	public var labels:ASObject = {};

	public var totalFrames:Int = 1;

	public var authoredFrames:Int = 1;

	public var loopFrame:Int = -1;

	public var labelLoop:Int = 0;

	public var stageRate:Bool = false;

	public var wantsSilhouette:Bool = false;

	public var masked:Bool = false;

	@:allow(UI.Hud.StarlingConverted) var parentClip:Rectangle;

	@:allow(UI.Hud.StarlingConverted) var filterStates:Vector<Array<ASAny>> = new Vector((0 : UInt));

	public var barFill:Bool = false;

	public var registrationWidth:Float = 0;

	public var model:TextField;

	@:allow(UI.Hud.StarlingConverted) var textBounds:Rectangle;

	@:allow(UI.Hud.StarlingConverted) var textFontKeys:Vector<String>;

	@:allow(UI.Hud.StarlingConverted) var grayFontKeys:Vector<String>;

	@:allow(UI.Hud.StarlingConverted) var textFontSize:Float = Math.NaN;

	public var textPages:BakedPages;

	public var pixelScale:Float = 1;

	public var initialText:String;

	public var alignment:String = "left";

	public var failures:Int = 0;

	@:allow(UI.Hud.StarlingConverted) var maximalBounds:Rectangle;

	var mCells:Vector<BakedCell> = new Vector((0 : UInt));

	var mOwners:Vector<BakedPages> = new Vector((0 : UInt));

	var mReleased:Bool = false;

	@:allow(UI.Hud.StarlingConverted) var lease:ASObject;

	@:allow(UI.Hud.StarlingConverted) var mCachePrevious:ArtNode;

	@:allow(UI.Hud.StarlingConverted) var mCacheNext:ArtNode;

	@:allow(UI.Hud.StarlingConverted) var mCacheKey:String;

	@:allow(UI.Hud.StarlingConverted) var mCacheArt:ASObject;

	@:allow(UI.Hud.StarlingConverted) var mCachePages:BakedPages;

	@:allow(UI.Hud.StarlingConverted) var mPinned:Bool = false;

	var mViews:Int = 0;

	@:allow(UI.Hud.StarlingConverted) var sweep:StarlingSweepArt;

	public function new() {}

	@:allow(UI.Hud.StarlingConverted) function retainView() {
		mViews = mViews + 1;
		pinCells(1);
		if (lease != null) {
			lease.views++;
		}
	}

	@:allow(UI.Hud.StarlingConverted) function releaseView() {
		mViews = mViews - 1;
		pinCells(-1);
		if (lease == null) {
			return;
		}
		lease.views--;
		if (ASCompat.toBool(lease.retired) && ASCompat.toNumberField(lease, "views") == 0) {
			lease.release(lease);
		}
	}

	function pinCells(delta:Int) {
		var _loc2_:BakedCell = null;
		var _loc3_:ArtNode = null;
		final __ax4_iter_224 = mCells;
		if (checkNullIteratee(__ax4_iter_224))
			for (_tmp_ in __ax4_iter_224) {
				_loc2_ = _tmp_;
				if (Std.isOfType(_loc2_, HudCell)) {
					cast(_loc2_, HudCell).mLiveViews = cast(_loc2_, HudCell).mLiveViews + delta;
				}
			}
		final __ax4_iter_225 = children;
		if (checkNullIteratee(__ax4_iter_225))
			for (_tmp_ in __ax4_iter_225) {
				_loc3_ = _tmp_;
				_loc3_.pinCells(delta);
			}
	}

	@:allow(UI.Hud.StarlingConverted) function canEvict():Bool {
		var __finallyReturn29:Bool;
		var __ax4_iter_226:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_227:ASDictionary<ASAny, ASAny>;
		var _loc6_:Int;
		var _loc5_:ASDictionary<ASAny, ASAny>;
		var __finallyReturn30:Bool;
		var __ax4_iter_228:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_229:ASDictionary<ASAny, ASAny>;
		var __finallyReturn31:Bool;
		var __ax4_iter_230:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_231:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_232:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_233:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_234:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_235:ASDictionary<ASAny, ASAny>;
		var _loc1_:ASObject = null;
		{
			var __finallyReturn29:Bool;
			var __ax4_iter_226:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_227:ASDictionary<ASAny, ASAny>;
			var __finallyReturn30:Bool;
			var __ax4_iter_228:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_229:ASDictionary<ASAny, ASAny>;
			var __finallyReturn31:Bool;
			var __ax4_iter_230:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_231:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_232:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_233:ASDictionary<ASAny, ASAny>;
			try {
				if (!countCachedCells(sEvictCells, sEvictNodes)) {
					{
						__finallyReturn29 = false;
						{
							__ax4_iter_226 = sEvictCells;
							if (checkNullIteratee(__ax4_iter_226))
								for (_tmp_ in __ax4_iter_226.keys()) {
									_loc1_ = _tmp_;
									sEvictCells.remove(_loc1_);
								}
							__ax4_iter_227 = sEvictNodes;
							if (checkNullIteratee(__ax4_iter_227))
								for (_tmp_ in __ax4_iter_227.keys()) {
									_loc1_ = _tmp_;
									sEvictNodes.remove(_loc1_);
								}
						};
						return __finallyReturn29;
					};
				}
				_loc6_ = 0;
				_loc5_ = sEvictCells;
				while (true) {
					if (checkNullIteratee(_loc5_))
						for (_tmp_ in _loc5_.keys()) {
							_loc1_ = _tmp_;
							if (cast(_loc1_, BakedCell).refCount > ASCompat.toInt(sEvictCells[_loc1_])) {
								{
									__finallyReturn30 = false;
									{
										__ax4_iter_228 = sEvictCells;
										if (checkNullIteratee(__ax4_iter_228))
											for (_tmp_ in __ax4_iter_228.keys()) {
												_loc1_ = _tmp_;
												sEvictCells.remove(_loc1_);
											}
										__ax4_iter_229 = sEvictNodes;
										if (checkNullIteratee(__ax4_iter_229))
											for (_tmp_ in __ax4_iter_229.keys()) {
												_loc1_ = _tmp_;
												sEvictNodes.remove(_loc1_);
											}
									};
									return __finallyReturn30;
								};
							}
						}
					{
						__finallyReturn31 = true;
						{
							__ax4_iter_230 = sEvictCells;
							if (checkNullIteratee(__ax4_iter_230))
								for (_tmp_ in __ax4_iter_230.keys()) {
									_loc1_ = _tmp_;
									sEvictCells.remove(_loc1_);
								}
							__ax4_iter_231 = sEvictNodes;
							if (checkNullIteratee(__ax4_iter_231))
								for (_tmp_ in __ax4_iter_231.keys()) {
									_loc1_ = _tmp_;
									sEvictNodes.remove(_loc1_);
								}
						};
						return __finallyReturn31;
					};
				}
			} catch (__finallyError32:Dynamic) {
				{
					__ax4_iter_232 = sEvictCells;
					if (checkNullIteratee(__ax4_iter_232))
						for (_tmp_ in __ax4_iter_232.keys()) {
							_loc1_ = _tmp_;
							sEvictCells.remove(_loc1_);
						}
					__ax4_iter_233 = sEvictNodes;
					if (checkNullIteratee(__ax4_iter_233))
						for (_tmp_ in __ax4_iter_233.keys()) {
							_loc1_ = _tmp_;
							sEvictNodes.remove(_loc1_);
						}
				};
				throw __finallyError32;
			};
			{
				__ax4_iter_234 = sEvictCells;
				if (checkNullIteratee(__ax4_iter_234))
					for (_tmp_ in __ax4_iter_234.keys()) {
						_loc1_ = _tmp_;
						sEvictCells.remove(_loc1_);
					}
				__ax4_iter_235 = sEvictNodes;
				if (checkNullIteratee(__ax4_iter_235))
					for (_tmp_ in __ax4_iter_235.keys()) {
						_loc1_ = _tmp_;
						sEvictNodes.remove(_loc1_);
					}
			};
		}
		return false;
	}

	@:allow(UI.Hud.StarlingConverted) function pinStartupTree() {
		var _loc1_:BakedCell = null;
		var _loc2_:ArtNode = null;
		mPinned = true;
		final __ax4_iter_236 = mCells;
		if (checkNullIteratee(__ax4_iter_236))
			for (_tmp_ in __ax4_iter_236) {
				_loc1_ = _tmp_;
				if (Std.isOfType(_loc1_, HudCell)) {
					cast(_loc1_, HudCell).mPinned = true;
				}
			}
		final __ax4_iter_237 = children;
		if (checkNullIteratee(__ax4_iter_237))
			for (_tmp_ in __ax4_iter_237) {
				_loc2_ = _tmp_;
				_loc2_.pinStartupTree();
			}
	}

	function countCachedCells(cells:ASDictionary<ASAny, ASAny>, seen:ASDictionary<ASAny, ASAny>):Bool {
		var _loc3_:BakedCell = null;
		var _loc4_:ArtNode = null;
		if (ASCompat.toBool(seen[this])) {
			return true;
		}
		seen[this] = true;
		if (mPinned || mViews > 0) {
			return false;
		}
		final __ax4_iter_238 = mCells;
		if (checkNullIteratee(__ax4_iter_238))
			for (_tmp_ in __ax4_iter_238) {
				_loc3_ = _tmp_;
				if (Std.isOfType(_loc3_, HudCell)
					&& (cast(_loc3_, HudCell).mPinned
						|| cast(_loc3_, HudCell).mLiveViews > 0
							|| cast(_loc3_, HudCell).mSource != null && cast(_loc3_, HudCell).mSource.mLiveViews > 0)) {
					return false;
				}
				cells[_loc3_] = ASCompat.toInt(cells[_loc3_]) + 1;
			}
		final __ax4_iter_239 = children;
		if (checkNullIteratee(__ax4_iter_239))
			for (_tmp_ in __ax4_iter_239) {
				_loc4_ = _tmp_;
				if (!_loc4_.countCachedCells(cells, seen)) {
					return false;
				}
			}
		return true;
	}

	public function find(path:String):ArtNode {
		var _loc2_:ArtNode = null;
		var _loc6_ = 0;
		if (path == null || path.length == 0 || path == name) {
			return this;
		}
		var _loc4_:Array<ASAny> = (cast path.split("."));
		var _loc3_ = this;
		var _loc5_ = _loc4_[0] == name ? 1 : 0;
		while (_loc5_ < _loc4_.length) {
			_loc2_ = null;
			_loc6_ = 0;
			while (_loc6_ < ASCompat.toNumberField(_loc3_.children, "length")) {
				if (_loc3_.children[_loc6_].name == _loc4_[_loc5_]) {
					_loc2_ = ASCompat.coerce(_loc3_.children[_loc6_], ArtNode);
					break;
				}
				_loc6_++;
			}
			if (_loc2_ == null) {
				return null;
			}
			_loc3_ = _loc2_;
			_loc5_++;
		}
		return _loc3_;
	}

	@:allow(UI.Hud.StarlingConverted) function hold(value:BakedCell, owner:BakedPages = null):BakedCell {
		if (value != null) {
			mCells.push(value);
			mOwners.push(owner);
		}
		return value;
	}

	public function release(pages:BakedPages) {
		releaseTree(pages, new ASDictionary<ASAny, ASAny>());
	}

	function releaseTree(pages:BakedPages, visited:ASDictionary<ASAny, ASAny>) {
		var _loc5_:ArtNode = null;
		var _loc3_:BakedCell = null;
		var _loc4_ = 0;
		if (mReleased || ASCompat.toBool(visited[this])) {
			return;
		}
		visited[this] = true;
		mReleased = true;
		HudArt.removeCached(this);
		mCacheArt = null;
		mCachePages = null;
		_loc4_ = 0;
		while (_loc4_ < mCells.length) {
			_loc3_ = mCells[_loc4_];
			(mOwners[_loc4_] ?? pages).release(_loc3_);
			if (!_loc3_.alive) {
				HudArtConverter.forgetPixels(_loc3_);
			}
			_loc4_++;
		}
		mCells.length = 0;
		mOwners.length = 0;
		final __ax4_iter_240 = children;
		if (checkNullIteratee(__ax4_iter_240))
			for (_tmp_ in __ax4_iter_240) {
				_loc5_ = _tmp_;
				_loc5_.releaseTree(pages, visited);
			}
	}
}
