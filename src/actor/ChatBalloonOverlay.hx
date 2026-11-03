package actor;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

class ChatBalloonOverlay {
	static final sBalloons:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mWorld:DisplayObjectContainer;

	var mFadeLayer:DisplayObject;

	var mLayer:Sprite;

	final mActive:ASDictionary<ASAny, ASAny> = new ASDictionary();

	final mOrder:Vector<ChatBalloon> = new Vector((0 : UInt));

	final mMatrix:Matrix = new Matrix();

	final mInverse:Matrix = new Matrix();

	final mColor:ColorTransform = new ColorTransform();

	final mFilters:Array<ASAny> = [];

	var mFadeFilter:ColorMatrixFilter;

	var mFadeAlpha:Float = -1;

	var mFadeColor:UInt = 0;

	var mFrame:UInt = (0 : UInt);

	public function new(world:DisplayObjectContainer, designSpace:DisplayObjectContainer, fadeLayer:DisplayObject = null) {
		mWorld = world;
		mFadeLayer = fadeLayer;
		mLayer = new Sprite();
		mLayer.name = "ChatBalloonOverlay";
		mLayer.mouseEnabled = mLayer.mouseChildren = false;
		var _loc4_:DisplayObject = world;
		while (_loc4_.parent != null && _loc4_.parent != designSpace) {
			_loc4_ = _loc4_.parent;
		}
		designSpace.addChildAt(mLayer, _loc4_.parent == designSpace ? designSpace.getChildIndex(_loc4_) + 1 : 0);
	}

	@:allow(Actor) static function register(balloon:ChatBalloon) {
		balloon.cutRegistered = true;
		visibilityChanged(balloon);
	}

	@:allow(Actor) static function visibilityChanged(balloon:ChatBalloon) {
		if (balloon.visible) {
			sBalloons[balloon] = true;
		} else {
			sBalloons.remove(balloon);
			if (balloon.cutOverlay != null) {
				balloon.cutOverlay.restore(balloon);
			}
		}
	}

	@:allow(Actor) static function unregister(balloon:ChatBalloon) {
		if (balloon.cutOverlay != null) {
			balloon.cutOverlay.restore(balloon);
		}
		sBalloons.remove(balloon);
		balloon.cutRegistered = false;
	}

	static function compareBalloons(a:ChatBalloon, b:ChatBalloon):Float {
		return compareDisplayOrder(a, b);
	}

	static function compareDisplayOrder(a:DisplayObject, b:DisplayObject):Float {
		var _loc4_:DisplayObject = null;
		if (a == b) {
			return 0;
		}
		var _loc5_ = a;
		var _loc6_ = b;
		var _loc7_ = 0;
		var _loc3_ = 0;
		_loc4_ = _loc5_;
		while (_loc4_ != null) {
			_loc7_++;
			_loc4_ = _loc4_.parent;
		}
		_loc4_ = _loc6_;
		while (_loc4_ != null) {
			_loc3_++;
			_loc4_ = _loc4_.parent;
		}
		while (_loc7_ > _loc3_) {
			_loc5_ = _loc5_.parent;
			_loc7_--;
		}
		while (_loc3_ > _loc7_) {
			_loc6_ = _loc6_.parent;
			_loc3_--;
		}
		while (_loc5_.parent != _loc6_.parent) {
			_loc5_ = _loc5_.parent;
			_loc6_ = _loc6_.parent;
		}
		return _loc5_.parent.getChildIndex(_loc5_) - _loc6_.parent.getChildIndex(_loc6_);
	}

	public function update(enabled:Bool, fadeAlpha:Float = 0, fadeColor:UInt = (0 : UInt)) {
		var _loc9_:BitmapFilter;
		var __ax4_iter_8:Array<ASAny>;
		var _loc13_:Float;
		var _loc4_:ChatBalloon = null;
		var _loc12_ = false;
		var _loc5_:DisplayObject = null;
		var _loc8_:Sprite = null;
		var _loc11_ = Math.NaN;
		var _loc14_:ChatOverlayState = null;
		var _loc6_ = 0;
		if (mLayer == null) {
			return;
		}
		if (!enabled || mWorld.stage == null || mLayer.stage != mWorld.stage) {
			clear();
			return;
		}
		var _loc7_ = false;
		var _loc18_ = 0;
		var _loc17_ = sBalloons;
		var _loc10_:ASObject;
		if (checkNullIteratee(_loc17_))
			for (_tmp_ in _loc17_.keys()) {
				_loc10_ = _tmp_;
				_loc7_ = true;
			}
		if (!_loc7_) {
			clear();
			return;
		}
		mInverse.copyFrom(mLayer.transform.matrix);
		var _loc16_ = mInverse.a * mInverse.d - mInverse.b * mInverse.c;
		if (_loc16_ == 0 || !Math.isFinite(_loc16_)) {
			clear();
			return;
		}
		mInverse.invert();
		mFrame = mFrame + 1;
		mOrder.length = 0;
		var _loc15_:ASObject;
		final __ax4_iter_7 = sBalloons;
		if (checkNullIteratee(__ax4_iter_7))
			for (_tmp_ in __ax4_iter_7.keys()) {
				_loc15_ = _tmp_;
				_loc4_ = cast(_loc15_, ChatBalloon);
				if (!(!_loc4_.visible || !mWorld.contains(_loc4_))) {
					_loc12_ = true;
					mMatrix.identity();
					mColor.redMultiplier = mColor.greenMultiplier = mColor.blueMultiplier = mColor.alphaMultiplier = 1;
					mColor.redOffset = mColor.greenOffset = mColor.blueOffset = mColor.alphaOffset = 0;
					mFilters.resize(0);
					_loc5_ = _loc4_;
					while (_loc5_ != mLayer.parent) {
						if (_loc5_ == null
							|| !(Std.isOfType(_loc5_, ActorNametag) ? cast(_loc5_, ActorNametag).shownOnScreen : _loc5_.visible)
							|| _loc5_.alpha <= 0) {
							_loc12_ = false;
							break;
						}
						mMatrix.concat(_loc5_.transform.matrix);
						mColor.concat(_loc5_.transform.colorTransform);
						__ax4_iter_8 = _loc5_.filters;
						if (checkNullIteratee(__ax4_iter_8))
							for (_tmp_ in __ax4_iter_8) {
								_loc9_ = ASCompat.coerce(_tmp_, flash.filters.BitmapFilter);
								mFilters.push(_loc9_);
							}
						_loc5_ = _loc5_.parent;
					}
					if (_loc12_) {
						if (_loc4_.cutOverlay != null && _loc4_.cutOverlay != this) {
							_loc4_.cutOverlay.restore(_loc4_);
						}
						_loc8_ = _loc4_.renderContent;
						mMatrix.concat(mInverse);
						if (_loc8_.parent != mLayer) {
							mLayer.addChild(_loc8_);
						}
						if (fadeAlpha > 0
							&& mFadeLayer != null
							&& mWorld.contains(mFadeLayer)
							&& compareDisplayOrder(_loc4_, mFadeLayer) < 0) {
							if (mFadeFilter == null || fadeAlpha != mFadeAlpha || fadeColor != mFadeColor) {
								mFadeAlpha = fadeAlpha;
								mFadeColor = fadeColor;
								_loc11_ = Math.min(1, fadeAlpha);
								_loc13_ = 1 - _loc11_;
								mFadeFilter = new ColorMatrixFilter(cast([
									_loc13_,
									0,
									0,
									0,
									((fadeColor : Int) >> 16 & 0xFF) * _loc11_,
									0,
									_loc13_,
									0,
									0,
									((fadeColor : Int) >> 8 & 0xFF) * _loc11_,
									0,
									0,
									_loc13_,
									0,
									((fadeColor : Int) & 0xFF) * _loc11_,
									0,
									0,
									0,
									1,
									0
								]));
							}
							mFilters.push(mFadeFilter);
						}
						_loc14_ = ASCompat.dynamicAs(mActive[_loc4_], ChatOverlayState);
						if (_loc14_ == null) {
							mActive[_loc4_] = _loc14_ = new ChatOverlayState();
						}
						_loc14_.apply(_loc8_, mMatrix, mColor, mFilters);
						_loc14_.frame = mFrame;
						_loc4_.cutOverlay = this;
						mOrder.push(_loc4_);
					}
				}
			}
		final __ax4_iter_9 = mActive;
		if (checkNullIteratee(__ax4_iter_9))
			for (_tmp_ in __ax4_iter_9.keys()) {
				_loc15_ = _tmp_;
				if (cast(mActive[_loc15_], ChatOverlayState).frame != mFrame) {
					restore(cast(_loc15_, ChatBalloon));
				}
			}
		_loc6_ = 1;
		while (_loc6_ < mOrder.length) {
			if (compareBalloons(mOrder[_loc6_ - 1], mOrder[_loc6_]) > 0) {
				ASCompat.ASVector.sort(mOrder, compareBalloons);
				break;
			}
			_loc6_++;
		}
		_loc6_ = 0;
		while (_loc6_ < mOrder.length) {
			if (mLayer.getChildAt(_loc6_) != mOrder[_loc6_].renderContent) {
				mLayer.setChildIndex(mOrder[_loc6_].renderContent, _loc6_);
			}
			_loc6_++;
		}
		mOrder.length = 0;
	}

	function restore(balloon:ChatBalloon) {
		var _loc2_ = balloon.renderContent;
		balloon.addChild(_loc2_);
		_loc2_.transform.matrix = new Matrix();
		_loc2_.transform.colorTransform = new ColorTransform();
		_loc2_.filters = cast([]);
		balloon.cutOverlay = null;
		mActive.remove(balloon);
	}

	function clear() {
		var _loc1_:ASObject;
		final __ax4_iter_10 = mActive;
		if (checkNullIteratee(__ax4_iter_10))
			for (_tmp_ in __ax4_iter_10.keys()) {
				_loc1_ = _tmp_;
				restore(cast(_loc1_, ChatBalloon));
			}
	}

	public function dispose() {
		clear();
		if (mLayer != null && mLayer.parent != null) {
			mLayer.parent.removeChild(mLayer);
		}
		mLayer = null;
		mWorld = null;
		mFadeLayer = null;
		mFilters.resize(mOrder.length = 0);
		mFadeFilter = null;
	}
}
