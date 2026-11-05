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

	@:allow(uI.hud.starlingConverted) var hitCell:BakedCell;

	public var frames:Vector<ArtFrame> = new Vector((0 : UInt));

	public var labels:ASObject = {};

	public var totalFrames:Int = 1;

	public var authoredFrames:Int = 1;

	public var loopFrame:Int = -1;

	public var labelLoop:Int = 0;

	public var stageRate:Bool = false;

	public var wantsSilhouette:Bool = false;

	public var masked:Bool = false;

	@:allow(uI.hud.starlingConverted) var parentClip:Rectangle;

	@:allow(uI.hud.starlingConverted) var filterStates:Vector<Array<ASAny>> = new Vector((0 : UInt));

	public var barFill:Bool = false;

	public var registrationWidth:Float = 0;

	public var model:TextField;

	@:allow(uI.hud.starlingConverted) var textBounds:Rectangle;

	@:allow(uI.hud.starlingConverted) var textFontKeys:Vector<String>;

	@:allow(uI.hud.starlingConverted) var grayFontKeys:Vector<String>;

	@:allow(uI.hud.starlingConverted) var textFontSize:Float = Math.NaN;

	public var textPages:BakedPages;

	public var pixelScale:Float = 1;

	public var initialText:String;

	public var alignment:String = "left";

	public var failures:Int = 0;

	@:allow(uI.hud.starlingConverted) var maximalBounds:Rectangle;

	var mCells:Vector<BakedCell> = new Vector((0 : UInt));

	var mOwners:Vector<BakedPages> = new Vector((0 : UInt));

	var mReleased:Bool = false;

	@:allow(uI.hud.starlingConverted) var lease:ASObject;

	@:allow(uI.hud.starlingConverted) var mCachePrevious:ArtNode;

	@:allow(uI.hud.starlingConverted) var mCacheNext:ArtNode;

	@:allow(uI.hud.starlingConverted) var mCacheKey:String;

	@:allow(uI.hud.starlingConverted) var mCacheArt:ASObject;

	@:allow(uI.hud.starlingConverted) var mCachePages:BakedPages;

	@:allow(uI.hud.starlingConverted) var mPinned:Bool = false;

	var mViews:Int = 0;

	@:allow(uI.hud.starlingConverted) var sweep:StarlingSweepArt;

	public function new() {}

	@:allow(uI.hud.starlingConverted) function retainView() {
		mViews = mViews + 1;
		pinCells(1);
		if (lease != null) {
			lease.views = ASCompat.toInt(lease.views) + 1;
		}
	}

	@:allow(uI.hud.starlingConverted) function releaseView() {
		mViews = mViews - 1;
		pinCells(-1);
		if (lease == null) {
			return;
		}
		lease.views = ASCompat.toInt(lease.views) - 1;
		if (ASCompat.toBool(lease.retired) && ASCompat.toNumberField(lease, "views") == 0) {
			lease.release(lease);
		}
	}

	function pinCells(delta:Int) {
		var _loc2_:BakedCell = null;
		var _loc3_:ArtNode = null;
		final __ax4_iter_227 = mCells;
		if (checkNullIteratee(__ax4_iter_227))
			for (_tmp_ in __ax4_iter_227) {
				_loc2_ = _tmp_;
				if (Std.isOfType(_loc2_, HudCell)) {
					cast(_loc2_, HudCell).mLiveViews = cast(_loc2_, HudCell).mLiveViews + delta;
				}
			}
		final __ax4_iter_228 = children;
		if (checkNullIteratee(__ax4_iter_228))
			for (_tmp_ in __ax4_iter_228) {
				_loc3_ = _tmp_;
				_loc3_.pinCells(delta);
			}
	}

	@:allow(uI.hud.starlingConverted) function canEvict():Bool {
		var __finallyReturn0:Bool;
		var __ax4_iter_229:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_230:ASDictionary<ASAny, ASAny>;
		var _loc6_:Int;
		var _loc5_:ASDictionary<ASAny, ASAny>;
		var __finallyReturn1:Bool;
		var __ax4_iter_231:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_232:ASDictionary<ASAny, ASAny>;
		var __finallyReturn2:Bool;
		var __ax4_iter_233:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_234:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_235:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_236:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_237:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_238:ASDictionary<ASAny, ASAny>;
		var _loc1_:ASObject = null;
		{
			var __finallyReturn0:Bool;
			var __ax4_iter_229:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_230:ASDictionary<ASAny, ASAny>;
			var __finallyReturn1:Bool;
			var __ax4_iter_231:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_232:ASDictionary<ASAny, ASAny>;
			var __finallyReturn2:Bool;
			var __ax4_iter_233:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_234:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_235:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_236:ASDictionary<ASAny, ASAny>;
			try {
				if (!countCachedCells(sEvictCells, sEvictNodes)) {
					{
						__finallyReturn0 = false;
						{
							__ax4_iter_229 = sEvictCells;
							if (checkNullIteratee(__ax4_iter_229))
								for (_tmp_ in __ax4_iter_229.keys()) {
									_loc1_ = _tmp_;
									sEvictCells.remove(_loc1_);
								}
							__ax4_iter_230 = sEvictNodes;
							if (checkNullIteratee(__ax4_iter_230))
								for (_tmp_ in __ax4_iter_230.keys()) {
									_loc1_ = _tmp_;
									sEvictNodes.remove(_loc1_);
								}
						};
						return __finallyReturn0;
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
									__finallyReturn1 = false;
									{
										__ax4_iter_231 = sEvictCells;
										if (checkNullIteratee(__ax4_iter_231))
											for (_tmp_ in __ax4_iter_231.keys()) {
												_loc1_ = _tmp_;
												sEvictCells.remove(_loc1_);
											}
										__ax4_iter_232 = sEvictNodes;
										if (checkNullIteratee(__ax4_iter_232))
											for (_tmp_ in __ax4_iter_232.keys()) {
												_loc1_ = _tmp_;
												sEvictNodes.remove(_loc1_);
											}
									};
									return __finallyReturn1;
								};
							}
						}
					{
						__finallyReturn2 = true;
						{
							__ax4_iter_233 = sEvictCells;
							if (checkNullIteratee(__ax4_iter_233))
								for (_tmp_ in __ax4_iter_233.keys()) {
									_loc1_ = _tmp_;
									sEvictCells.remove(_loc1_);
								}
							__ax4_iter_234 = sEvictNodes;
							if (checkNullIteratee(__ax4_iter_234))
								for (_tmp_ in __ax4_iter_234.keys()) {
									_loc1_ = _tmp_;
									sEvictNodes.remove(_loc1_);
								}
						};
						return __finallyReturn2;
					};
				}
			} catch (__finallyError3:Dynamic) {
				{
					__ax4_iter_235 = sEvictCells;
					if (checkNullIteratee(__ax4_iter_235))
						for (_tmp_ in __ax4_iter_235.keys()) {
							_loc1_ = _tmp_;
							sEvictCells.remove(_loc1_);
						}
					__ax4_iter_236 = sEvictNodes;
					if (checkNullIteratee(__ax4_iter_236))
						for (_tmp_ in __ax4_iter_236.keys()) {
							_loc1_ = _tmp_;
							sEvictNodes.remove(_loc1_);
						}
				};
				throw __finallyError3;
			};
			{
				__ax4_iter_237 = sEvictCells;
				if (checkNullIteratee(__ax4_iter_237))
					for (_tmp_ in __ax4_iter_237.keys()) {
						_loc1_ = _tmp_;
						sEvictCells.remove(_loc1_);
					}
				__ax4_iter_238 = sEvictNodes;
				if (checkNullIteratee(__ax4_iter_238))
					for (_tmp_ in __ax4_iter_238.keys()) {
						_loc1_ = _tmp_;
						sEvictNodes.remove(_loc1_);
					}
			};
		}
		return false;
	}

	@:allow(uI.hud.starlingConverted) function pinStartupTree() {
		var _loc1_:BakedCell = null;
		var _loc2_:ArtNode = null;
		mPinned = true;
		final __ax4_iter_239 = mCells;
		if (checkNullIteratee(__ax4_iter_239))
			for (_tmp_ in __ax4_iter_239) {
				_loc1_ = _tmp_;
				if (Std.isOfType(_loc1_, HudCell)) {
					cast(_loc1_, HudCell).mPinned = true;
				}
			}
		final __ax4_iter_240 = children;
		if (checkNullIteratee(__ax4_iter_240))
			for (_tmp_ in __ax4_iter_240) {
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
		final __ax4_iter_241 = mCells;
		if (checkNullIteratee(__ax4_iter_241))
			for (_tmp_ in __ax4_iter_241) {
				_loc3_ = _tmp_;
				if (Std.isOfType(_loc3_, HudCell)
					&& (cast(_loc3_, HudCell).mPinned
						|| cast(_loc3_, HudCell).mLiveViews > 0
							|| cast(_loc3_, HudCell).mSource != null && cast(_loc3_, HudCell).mSource.mLiveViews > 0)) {
					return false;
				}
				cells[_loc3_] = ASCompat.toInt(cells[_loc3_]) + 1;
			}
		final __ax4_iter_242 = children;
		if (checkNullIteratee(__ax4_iter_242))
			for (_tmp_ in __ax4_iter_242) {
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

	@:allow(uI.hud.starlingConverted) function hold(value:BakedCell, owner:BakedPages = null):BakedCell {
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
		final __ax4_iter_243 = children;
		if (checkNullIteratee(__ax4_iter_243))
			for (_tmp_ in __ax4_iter_243) {
				_loc5_ = _tmp_;
				_loc5_.releaseTree(pages, visited);
			}
	}
}
