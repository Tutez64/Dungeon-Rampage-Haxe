package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedPages;
import brain.starling.swfConverter.BakedPicture;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.FrameLabel;
import flash.display.GraphicsGradientFill;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;
import flash.display.IGraphicsFill;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import starling.core.Starling;

class HudArtConverter {
	static var sPixels:ASDictionary<ASAny, ASAny>;

	static var sGrays:ASDictionary<ASAny, ASAny>;

	static var sAnonymous:ASDictionary<ASAny, ASAny>;

	static var sNextAnonymous:Int = 0;

	static var sWorkDepth:Int = 0;

	var mPages:BakedPages;

	var mFramePages:BakedPages;

	var mOriginal:ASObject;

	var mTouched:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mError:String;

	var mScale:Float = Math.NaN;

	var mOptions:ASObject;

	var mJobs:Vector<ASFunction> = new Vector((0 : UInt));

	var mDriver:Shape;

	var mWorking:Bool = false;

	var mWaitingForFrame:Bool = false;

	var mCapture:ASFunction;

	var mFinished:Bool = false;

	var mDone:ASFunction;

	var mBudget:Float = Math.NaN;

	var mRoot:ArtNode;

	var mSymbol:String;

	var mContexts:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mMasks:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mMaskProbed:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mSamples:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mSampleCounts:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mSampleBakes:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mFailures:Int = 0;

	var mSource:DisplayObject;

	var mDrawParents:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mDrawMatrices:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mHudScale:Float = Math.NaN;

	public function new() {}

	public static function convert(source:DisplayObject, pages:BakedPages, scale:Float, options:ASObject = null):ArtNode {
		var _loc5_ = new HudArtConverter();
		_loc5_.mWorking = true;
		sWorkDepth = sWorkDepth + 1;
		{
			try {
				try {
					_loc5_.initialize(source, pages, scale, options);
					if (_loc5_.mError == null) {
						_loc5_.run(1.7976931348623157e+308);
					}
				} catch (error:ASAny) {
					_loc5_.recordError(error);
				};
			} catch (__finallyError0:Dynamic) {
				{
					_loc5_.finishSafely();
					_loc5_.mWorking = false;
					sWorkDepth = sWorkDepth - 1;
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				_loc5_.finishSafely();
				_loc5_.mWorking = false;
				sWorkDepth = sWorkDepth - 1;
			};
		}
		return _loc5_.mRoot;
	}

	public static function convertAsync(source:DisplayObject, pages:BakedPages, scale:Float, options:ASObject, onDone:ASFunction,
			budgetMs:Float = 8):HudArtConverter {
		var _loc7_ = new HudArtConverter();
		_loc7_.mDone = onDone;
		_loc7_.mBudget = Math.max(1, budgetMs);
		_loc7_.mDriver = new Shape();
		_loc7_.mWorking = true;
		sWorkDepth = sWorkDepth + 1;
		{
			try {
				try {
					_loc7_.initialize(source, pages, scale, options);
				} catch (error:ASAny) {
					_loc7_.recordError(error);
				};
			} catch (__finallyError0:Dynamic) {
				{
					_loc7_.mWorking = false;
					sWorkDepth = sWorkDepth - 1;
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				_loc7_.mWorking = false;
				sWorkDepth = sWorkDepth - 1;
			};
		}
		_loc7_.mDriver.addEventListener("exitFrame", _loc7_.onFrame);
		return _loc7_;
	}

	@:allow(uI.hud.starlingConverted) static function grayscaleFilter():ColorMatrixFilter {
		return new ColorMatrixFilter(cast([
			0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0
		]));
	}

	@:allow(uI.hud.starlingConverted) @:isVar static var busy(get, never):Bool;

	static function get_busy():Bool {
		return sWorkDepth > 0;
	}

	@:allow(uI.hud.starlingConverted) static function beginWork() {
		sWorkDepth = sWorkDepth + 1;
	}

	@:allow(uI.hud.starlingConverted) static function endWork() {
		sWorkDepth = sWorkDepth - 1;
	}

	static function buildBounds(node:ArtNode):Rectangle {
		var __ax4_iter_246:Vector<ArtChildState>;
		var __ax4_iter_247:Vector<ArtNode>;
		var _loc4_:ArtNode = null;
		var _loc5_:ArtFrame = null;
		var _loc3_:ArtChildState = null;
		var _loc2_ = new Rectangle();
		final __ax4_iter_244 = node.children;
		if (checkNullIteratee(__ax4_iter_244))
			for (_tmp_ in __ax4_iter_244) {
				_loc4_ = _tmp_;
				buildBounds(_loc4_);
			}
		addCellBounds(_loc2_, node.cell);
		if (node.model != null) {
			_loc2_ = node.model.getBounds(node.model);
		}
		final __ax4_iter_245 = node.frames;
		if (checkNullIteratee(__ax4_iter_245))
			for (_tmp_ in __ax4_iter_245) {
				_loc5_ = _tmp_;
				if (_loc5_ != null) {
					addCellBounds(_loc2_, _loc5_.cell);
					__ax4_iter_246 = _loc5_.children;
					if (checkNullIteratee(__ax4_iter_246))
						for (_tmp_ in __ax4_iter_246) {
							_loc3_ = _tmp_;
							if (_loc3_.visible && _loc3_.alpha > 0) {
								addTransformed(_loc2_, node.children[_loc3_.child].maximalBounds, _loc3_.matrix, _loc3_.parentClip);
							}
						}
				}
			}
		if (node.frames.length == 0) {
			__ax4_iter_247 = node.children;
			if (checkNullIteratee(__ax4_iter_247))
				for (_tmp_ in __ax4_iter_247) {
					_loc4_ = _tmp_;
					addTransformed(_loc2_, _loc4_.maximalBounds, _loc4_.matrix, _loc4_.parentClip);
				}
		}
		node.maximalBounds = _loc2_;
		return _loc2_;
	}

	static function addCellBounds(bounds:Rectangle, cell:BakedCell) {
		if (cell == null || cell.isEmpty) {
			return;
		}
		var _loc3_ = new Rectangle(-cell.pivotX, -cell.pivotY, cell.pixelWidth / cell.pixelScale, cell.pixelHeight / cell.pixelScale);
		if (bounds.isEmpty()) {
			bounds.copyFrom(_loc3_);
		} else {
			bounds.copyFrom(bounds.union(_loc3_));
		}
	}

	static function addTransformed(bounds:Rectangle, rect:Rectangle, matrix:Matrix, clip:Rectangle = null) {
		if (rect == null || rect.isEmpty()) {
			return;
		}
		var _loc5_ = matrix.transformPoint(rect.topLeft);
		var _loc6_ = matrix.transformPoint(new Point(rect.right, rect.top));
		var _loc7_ = matrix.transformPoint(rect.bottomRight);
		var _loc8_ = matrix.transformPoint(new Point(rect.left, rect.bottom));
		var _loc9_ = Math.min(_loc5_.x, Math.min(Math.min(_loc6_.x, _loc7_.x), _loc8_.x));
		var _loc10_ = Math.min(_loc5_.y, Math.min(Math.min(_loc6_.y, _loc7_.y), _loc8_.y));
		var _loc11_ = new Rectangle(_loc9_, _loc10_, Math.max(_loc5_.x, Math.max(Math.max(_loc6_.x, _loc7_.x), _loc8_.x)) - _loc9_,
			Math.max(_loc5_.y, Math.max(Math.max(_loc6_.y, _loc7_.y), _loc8_.y)) - _loc10_);
		if (clip != null) {
			_loc11_ = _loc11_.intersection(clip);
		}
		if (_loc11_.isEmpty()) {
			return;
		}
		if (bounds.isEmpty()) {
			bounds.copyFrom(_loc11_);
		} else {
			bounds.copyFrom(bounds.union(_loc11_));
		}
	}

	static function excluded(source:DisplayObject):Bool {
		return source.name == "tooltip"
			|| source.name.indexOf("tooltip_modifier0") == 0
			|| source.name == "consumable_tooltip01"
			|| source.name == "consumable_tooltip02"
			|| source.name == "UI_chat"
			|| source.name == "chatLogContainer";
	}

	static function containsText(source:DisplayObjectContainer):Bool {
		var _loc2_ = 0;
		var _loc3_:DisplayObject = null;
		_loc2_ = 0;
		while (_loc2_ < source.numChildren) {
			_loc3_ = source.getChildAt(_loc2_);
			if (!excluded(_loc3_)) {
				if (Std.isOfType(_loc3_, TextField)
					|| Std.isOfType(_loc3_, DisplayObjectContainer)
					&& containsText(cast(_loc3_, DisplayObjectContainer))) {
					return true;
				}
			}
			_loc2_++;
		}
		return false;
	}

	static function collectExcluded(source:DisplayObjectContainer, hidden:Vector<DisplayObject>) {
		var _loc3_ = 0;
		var _loc4_:DisplayObject = null;
		_loc3_ = 0;
		while (_loc3_ < source.numChildren) {
			_loc4_ = source.getChildAt(_loc3_);
			if (Std.isOfType(_loc4_, TextField) || excluded(_loc4_)) {
				hidden.push(_loc4_);
			} else if (Std.isOfType(_loc4_, DisplayObjectContainer)) {
				collectExcluded(cast(_loc4_, DisplayObjectContainer), hidden);
			}
			_loc3_++;
		}
	}

	static function requiresSamples(source:DisplayObject):Bool {
		return Std.isOfType(source, Shape) || Std.isOfType(source, Bitmap) || source.filters.length > 0 || source.mask != null;
	}

	static function opaqueFill(fill:IGraphicsFill) {
		var _loc3_ = 0;
		var _loc2_ = ASCompat.reinterpretAs(fill, GraphicsGradientFill);
		if (Std.isOfType(fill, GraphicsSolidFill)) {
			cast(fill, GraphicsSolidFill).alpha = 1;
		} else if (_loc2_ != null) {
			_loc3_ = 0;
			while (_loc3_ < _loc2_.alphas.length) {
				_loc2_.alphas[_loc3_] = 1;
				_loc3_++;
			}
		}
	}

	static function copyBake(source:BakedPicture):BakedPicture {
		var _loc2_ = new BakedPicture();
		_loc2_.bitmap = source.bitmap.clone();
		_loc2_.originX = source.originX;
		_loc2_.originY = source.originY;
		_loc2_.pixelScale = source.pixelScale;
		_loc2_.empty = source.empty;
		StarlingRaster.limit(_loc2_, StarlingRaster.requestedScale(source));
		return _loc2_;
	}

	@:allow(uI.hud.starlingConverted) static function forgetPixels(cell:BakedCell) {
		var _loc2_ = ASCompat.dynamicAs(sPixels[cell], BakedPicture);
		if (_loc2_ != null) {
			_loc2_.dispose();
		}
		sPixels.remove(cell);
	}

	@:allow(uI.hud.starlingConverted) static function grayscale(cell:BakedCell, pages:BakedPages):BakedCell {
		if (cell == null) {
			return null;
		}
		var _loc6_ = ASCompat.dynamicAs(sGrays[cell], BakedCell);
		if (_loc6_ != null && _loc6_.alive) {
			return _loc6_;
		}
		var _loc8_ = cell.key + "|gray";
		var _loc3_ = HudArt.content(_loc8_);
		if (_loc3_ != null) {
			sGrays[cell] = _loc3_.cell;
			return _loc3_.cell;
		}
		var _loc4_ = ASCompat.dynamicAs(sPixels[cell], BakedPicture);
		if (_loc4_ == null) {
			return null;
		}
		var _loc7_ = copyBake(_loc4_);
		_loc7_.bitmap.applyFilter(_loc7_.bitmap, _loc7_.bitmap.rect, new Point(), HudArtConverter.grayscaleFilter());
		var _loc5_ = pages.add(_loc8_, _loc7_, true);
		if (_loc5_ == null) {
			return null;
		}
		if (Std.isOfType(_loc5_, HudCell)) {
			cast(_loc5_, HudCell).mSource = ASCompat.reinterpretAs(cell, HudCell);
		}
		_loc3_ = new ArtNode();
		_loc3_.cell = _loc3_.hold(_loc5_, pages);
		HudArt.storeContent(_loc8_, _loc3_);
		sGrays[cell] = _loc5_;
		return _loc5_;
	}

	@:allow(uI.hud.starlingConverted) static function grayCell(cell:BakedCell):BakedCell {
		if (cell == null) {
			return null;
		}
		return ASCompat.thisOrDefault(ASCompat.dynamicAs(sGrays[cell], BakedCell), cell);
	}

	static function localBounds(bake:BakedPicture, matrix:Matrix):Rectangle {
		var _loc8_ = -bake.originX / bake.pixelScale;
		var _loc6_ = -bake.originY / bake.pixelScale;
		var _loc12_ = _loc8_ + bake.bitmap.width / bake.pixelScale;
		var _loc9_ = _loc6_ + bake.bitmap.height / bake.pixelScale;
		var _loc3_ = matrix.transformPoint(new Point(_loc8_, _loc6_));
		var _loc4_ = matrix.transformPoint(new Point(_loc12_, _loc6_));
		var _loc5_ = matrix.transformPoint(new Point(_loc8_, _loc9_));
		var _loc7_ = matrix.transformPoint(new Point(_loc12_, _loc9_));
		var _loc10_ = Math.min(_loc3_.x, Math.min(Math.min(_loc4_.x, _loc5_.x), _loc7_.x));
		var _loc11_ = Math.min(_loc3_.y, Math.min(Math.min(_loc4_.y, _loc5_.y), _loc7_.y));
		return new Rectangle(_loc10_, _loc11_, Math.max(_loc3_.x, Math.max(Math.max(_loc4_.x, _loc5_.x), _loc7_.x)) - _loc10_,
			Math.max(_loc3_.y, Math.max(Math.max(_loc4_.y, _loc5_.y), _loc7_.y)) - _loc11_);
	}

	static function positive(color:ColorTransform):Bool {
		return color.redOffset > 0 || color.greenOffset > 0 || color.blueOffset > 0;
	}

	static function isButton(source:DisplayObject):Bool {
		var _loc2_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		return _loc2_ != null && _loc2_.getChildByName("up") != null;
	}

	static function isButtonState(source:DisplayObject):Bool {
		return source.parent != null
			&& isButton(source.parent)
			&& (source.name == "up" || source.name == "over" || source.name == "down" || source.name == "disabled" || source.name == "selected");
	}

	static function rendererTree(source:DisplayObject):Bool {
		var _loc2_ = source;
		while (_loc2_ != null) {
			if (isButtonState(_loc2_) || _loc2_.name == "cooldown" || _loc2_.name == "UI_buster_glow" || _loc2_.name == "buster_activated_glow") {
				return true;
			}
			_loc2_ = _loc2_.parent;
		}
		return false;
	}

	static function rememberTree(source:DisplayObject, descendants:Bool = true):ASObject {
		var _loc5_ = 0;
		var _loc6_ = ASCompat.reinterpretAs(source, MovieClip);
		var _loc3_:ASObject = {
			"className": ASCompat.getQualifiedClassName(source),
			"frame": (_loc6_ != null ? _loc6_.currentFrame : 0),
			"playing": _loc6_ != null && _loc6_.isPlaying,
			"children": [],
			"matrix": source.transform.matrix.clone(),
			"color": source.transform.colorTransform,
			"visible": source.visible,
			"filters": source.filters,
			"blendMode": source.blendMode,
			"scrollRect": source.scrollRect
		};
		var _loc4_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		if (descendants && _loc4_ != null) {
			_loc5_ = 0;
			while (_loc5_ < _loc4_.numChildren) {
				ASCompat.dynPush(_loc3_.children, rememberTree(_loc4_.getChildAt(_loc5_)));
				_loc5_++;
			}
		}
		return _loc3_;
	}

	static function restoreTree(source:DisplayObject, state:ASObject) {
		var _loc4_ = 0;
		if (source == null || state == null || ASCompat.getQualifiedClassName(source) != state.className) {
			return;
		}
		var _loc5_ = ASCompat.reinterpretAs(source, MovieClip);
		if (_loc5_ != null) {
			if (_loc5_.currentFrame != ASCompat.toNumberField(state, "frame")) {
				if (ASCompat.toBool(state.playing)) {
					_loc5_.gotoAndPlay(state.frame);
				} else {
					_loc5_.gotoAndStop(state.frame);
				}
			} else if (ASCompat.toBool(state.playing)) {
				_loc5_.play();
			} else {
				_loc5_.stop();
			}
		}
		var _loc3_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		if (_loc3_ != null) {
			_loc4_ = 0;
			while (_loc4_ < _loc3_.numChildren && _loc4_ < ASCompat.toNumberField(state.children, "length")) {
				restoreTree(_loc3_.getChildAt(_loc4_), state.children[_loc4_]);
				_loc4_++;
			}
		}
		restoreProperties(source, state);
	}

	static function restoreProperties(source:DisplayObject, state:ASObject) {
		source.transform.matrix = ASCompat.coerce(state.matrix, flash.geom.Matrix);
		source.transform.colorTransform = ASCompat.coerce(state.color, flash.geom.ColorTransform);
		source.visible = ASCompat.toBool(state.visible);
		source.filters = cast(ASCompat.coerce(state.filters, Array));
		source.blendMode = state.blendMode;
		source.scrollRect = ASCompat.coerce(state.scrollRect, flash.geom.Rectangle);
	}

	static function filterState(node:ArtNode, filters:Array<ASAny>):Int {
		var _loc4_ = 0;
		var _loc3_ = filterSignature(filters);
		_loc4_ = 0;
		while (_loc4_ < node.filterStates.length) {
			if (filterSignature(node.filterStates[_loc4_]) == _loc3_) {
				return _loc4_;
			}
			_loc4_++;
		}
		node.filterStates.push(filters);
		return node.filterStates.length - 1;
	}

	@:allow(uI.hud.starlingConverted) static function filterSignature(filters:Array<ASAny>):String {
		var _loc3_:ASObject = null;
		var _loc4_:String = null;
		var _loc2_ = "";
		var _loc5_:Array<ASAny> = [
			"color",
			"alpha",
			"blurX",
			"blurY",
			"strength",
			"quality",
			"inner",
			"knockout",
			"hideObject",
			"distance",
			"angle",
			"matrix"
		];
		if (checkNullIteratee(filters))
			for (_tmp_ in filters) {
				_loc3_ = _tmp_;
				_loc2_ += ASCompat.getQualifiedClassName(_loc3_);
				if (checkNullIteratee(_loc5_))
					for (_tmp_ in _loc5_) {
						_loc4_ = _tmp_;
						if (_loc3_.hasOwnProperty(_loc4_)) {
							_loc2_ += "|" + _loc4_ + ":" + Std.string(_loc3_[_loc4_]);
						}
					}
				_loc2_ += ";";
			}
		return _loc2_;
	}

	public static function maxFrames(source:DisplayObject):Int {
		var _loc4_ = 0;
		var _loc5_ = ASCompat.reinterpretAs(source, MovieClip);
		var _loc3_ = _loc5_ != null ? _loc5_.totalFrames : 1;
		var _loc2_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		if (_loc2_ != null) {
			_loc4_ = 0;
			while (_loc4_ < _loc2_.numChildren) {
				_loc3_ = ASCompat.floatToInt(Math.max(_loc3_, maxFrames(_loc2_.getChildAt(_loc4_))));
				_loc4_++;
			}
		}
		return _loc3_;
	}

	public static function stopTree(source:DisplayObject) {
		var _loc3_ = 0;
		var _loc4_ = ASCompat.reinterpretAs(source, MovieClip);
		if (_loc4_ != null) {
			_loc4_.stop();
		}
		var _loc2_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		if (_loc2_ != null) {
			_loc3_ = 0;
			while (_loc3_ < _loc2_.numChildren) {
				stopTree(_loc2_.getChildAt(_loc3_));
				_loc3_++;
			}
		}
	}

	static function readLabels(node:ArtNode, clip:MovieClip) {
		var _loc3_:FrameLabel = null;
		final __ax4_iter_248 = clip.currentLabels;
		if (checkNullIteratee(__ax4_iter_248))
			for (_tmp_ in __ax4_iter_248) {
				_loc3_ = _tmp_;
				node.labels[_loc3_.name] = _loc3_.frame - 1;
				if (node.labelLoop == 0 && _loc3_.name == "loop") {
					node.labelLoop = 1;
					node.loopFrame = _loc3_.frame - 1;
				} else if (node.labelLoop == 0 && _loc3_.name == "noloop") {
					node.labelLoop = -1;
				}
			}
	}

	function initialize(source:DisplayObject, pages:BakedPages, scale:Float, options:ASObject) {
		if (sPixels == null) {
			sPixels = new ASDictionary<ASAny, ASAny>(true);
		}
		if (sGrays == null) {
			sGrays = new ASDictionary<ASAny, ASAny>(true);
		}
		if (sAnonymous == null) {
			sAnonymous = new ASDictionary<ASAny, ASAny>(true);
		}
		mPages = pages;
		mFramePages = options != null ? ASCompat.dynamicAs(options.framePages, BakedPages) : null;
		mScale = scale;
		mHudScale = options != null
			&& ASCompat.toNumberField(options, "hudScale") > 0 ? ASCompat.toNumber(options.hudScale) : HudArt.pixelScale;
		mOptions = options;
		mSymbol = ASCompat.getQualifiedClassName(source);
		mSource = source;
		mDrawParents[source] = new Matrix(scale / mHudScale, 0, 0, scale / mHudScale);
		captureMatrix(source);
		mOriginal = rememberTree(source);
		rememberTouched(source);
		stopTree(source);
		mJobs.push(function() {
			constructTree(source);
			mRoot = makeNode(source, "", true);
		});
	}

	function run(budget:Float) {
		var _loc3_:ASFunction = null;
		var _loc2_ = flash.Lib.getTimer();
		while (!(mJobs.length == 0 || mWaitingForFrame)) {
			_loc3_ = mJobs.pop();
			_loc3_();
			if (mError != null) {
				break;
			}
			if (flash.Lib.getTimer() - _loc2_ >= budget) {
				break;
			}
		}
	}

	function onFrame(event:Event) {
		var _loc3_:ASFunction = null;
		var _loc5_ = Math.NaN;
		var _loc4_:ASFunction = null;
		if (HudArt.fatalFailure) {
			cancel();
			return;
		}
		if (Starling.current == null || !Starling.current.contextValid) {
			return;
		}
		if (mWorking || busy || mDriver == null || mFinished) {
			return;
		}
		mWorking = true;
		sWorkDepth = sWorkDepth + 1;
		mDriver.removeEventListener("exitFrame", onFrame);
		var _loc2_ = flash.Lib.getTimer();
		{
			try {
				try {
					if (mError == null && mCapture != null) {
						_loc3_ = mCapture;
						mCapture = null;
						mWaitingForFrame = false;
						_loc3_();
					}
					_loc5_ = mBudget - (flash.Lib.getTimer() - _loc2_);
					if (mError == null && _loc5_ > 0) {
						run(_loc5_);
					}
				} catch (error:ASAny) {
					recordError(error);
				}
				if (mError == null && (mJobs.length > 0 || mWaitingForFrame)) {
					{
						{
							mWorking = false;
							sWorkDepth = sWorkDepth - 1;
							if (mDriver != null) {
								mDriver.addEventListener("exitFrame", onFrame);
							}
						};
						return;
					};
				}
				mJobs.length = 0;
				mCapture = null;
				mDriver = null;
				finishSafely();
				_loc4_ = mDone;
				mDone = null;
				try {
					if (_loc4_ != null) {
						_loc4_(mRoot);
					}
				} catch (callbackError:ASAny) {
					HudArt.fail("HUD conversion callback: " + mSymbol + " " + ASCompat.toString(callbackError), ASCompat.dynamicAs(callbackError, Error));
				}
			} catch (__finallyError0:Dynamic) {
				{
					mWorking = false;
					sWorkDepth = sWorkDepth - 1;
					if (mDriver != null) {
						mDriver.addEventListener("exitFrame", onFrame);
					}
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				mWorking = false;
				sWorkDepth = sWorkDepth - 1;
				if (mDriver != null) {
					mDriver.addEventListener("exitFrame", onFrame);
				}
			};
		}
	}

	@:allow(uI.hud.starlingConverted) function cancel() {
		if (mDriver != null) {
			mDriver.removeEventListener("exitFrame", onFrame);
		}
		mDriver = null;
		mDone = null;
		mCapture = null;
		mWaitingForFrame = false;
		mJobs.length = 0;
		mWorking = true;
		sWorkDepth = sWorkDepth + 1;
		{
			try {
				try {
					finishSafely(false);
					if (mRoot != null) {
						mRoot.release(mPages);
						mRoot = null;
					}
				} catch (error:ASAny) {
					recordError(error);
				};
			} catch (__finallyError0:Dynamic) {
				{
					mWorking = false;
					sWorkDepth = sWorkDepth - 1;
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				mWorking = false;
				sWorkDepth = sWorkDepth - 1;
			};
		}
	}

	function recordError(error:ASAny) {
		if (Std.isOfType(error, HudFatalError)) {
			HudArt.fatal(cast(error, Error).message);
		}
		StarlingHud.reportError(Std.isOfType(error, Error) ? ASCompat.dynamicAs(error, Error) : new Error(ASCompat.toString(error)));
		if (mError == null) {
			mError = Std.isOfType(error,
				Error) ? cast(error, Error).errorID + " " + Std.string(cast(error, Error).message) : (Std.isOfType(error,
					ErrorEvent) ? cast(error, ErrorEvent).text : ASCompat.toString(error));
		}
		mFailures = mFailures + 1;
		if (mRoot != null) {
			mRoot.failures++;
		}
	}

	function finishSafely(silhouettes:Bool = true) {
		if (mFinished) {
			return;
		}
		mFinished = true;
		{
			try {
				try {
					finish(silhouettes);
				} catch (error:ASAny) {
					recordError(error);
				};
			} catch (__finallyError0:Dynamic) {
				{
					if (mRoot != null) {
						mRoot.failures = mFailures;
					}
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				if (mRoot != null) {
					mRoot.failures = mFailures;
				}
			};
		}
	}

	function finish(silhouettes:Bool = true) {
		var _loc2_:ASObject;
		var __ax4_iter_249:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_250:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_251:ASDictionary<ASAny, ASAny>;
		var __ax4_iter_252:ASDictionary<ASAny, ASAny>;
		var _loc3_:DisplayObject = null;
		{
			var _loc2_:ASObject;
			var __ax4_iter_249:ASDictionary<ASAny, ASAny>;
			var __ax4_iter_250:ASDictionary<ASAny, ASAny>;
			try {
				try {
					if (silhouettes && mRoot != null && mError == null) {
						inheritSilhouettes(mRoot, false);
					}
				} catch (error:ASAny) {
					recordError(error);
				};
			} catch (__finallyError0:Dynamic) {
				{
					__ax4_iter_249 = mTouched;
					if (checkNullIteratee(__ax4_iter_249))
						for (_tmp_ in __ax4_iter_249.keys()) {
							_loc2_ = _tmp_;
							_loc3_ = ASCompat.dynamicAs(_loc2_, DisplayObject);
							try {
								restoreTree(_loc3_, mTouched[_loc2_]);
							} catch (propertyError:ASAny) {
								recordError(propertyError);
							}
						}
					try {
						restoreTree(mSource, mOriginal);
					} catch (restoreError:ASAny) {
						recordError(restoreError);
					}
					__ax4_iter_250 = mTouched;
					if (checkNullIteratee(__ax4_iter_250))
						for (_tmp_ in __ax4_iter_250.keys()) {
							_loc2_ = _tmp_;
							try {
								restoreProperties(ASCompat.dynamicAs(_loc2_, DisplayObject), mTouched[_loc2_]);
							} catch (overrideError:ASAny) {
								recordError(overrideError);
							}
						}
					mSource = null;
					mOriginal = null;
					mTouched = new ASDictionary<ASAny, ASAny>();
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				__ax4_iter_251 = mTouched;
				if (checkNullIteratee(__ax4_iter_251))
					for (_tmp_ in __ax4_iter_251.keys()) {
						_loc2_ = _tmp_;
						_loc3_ = ASCompat.dynamicAs(_loc2_, DisplayObject);
						try {
							restoreTree(_loc3_, mTouched[_loc2_]);
						} catch (propertyError:ASAny) {
							recordError(propertyError);
						}
					}
				try {
					restoreTree(mSource, mOriginal);
				} catch (restoreError:ASAny) {
					recordError(restoreError);
				}
				__ax4_iter_252 = mTouched;
				if (checkNullIteratee(__ax4_iter_252))
					for (_tmp_ in __ax4_iter_252.keys()) {
						_loc2_ = _tmp_;
						try {
							restoreProperties(ASCompat.dynamicAs(_loc2_, DisplayObject), mTouched[_loc2_]);
						} catch (overrideError:ASAny) {
							recordError(overrideError);
						}
					}
				mSource = null;
				mOriginal = null;
				mTouched = new ASDictionary<ASAny, ASAny>();
			};
		}
		try {
			if (mRoot != null) {
				labelBehaviour(mRoot);
			}
		} catch (labelError:ASAny) {
			recordError(labelError);
		}
		if (mRoot != null) {
			buildBounds(mRoot);
		}
		if (mRoot != null) {
			mRoot.failures = mFailures;
		}
	}

	function labelBehaviour(node:ArtNode):Int {
		var _loc3_:ArtNode = null;
		var _loc2_ = 0;
		final __ax4_iter_253 = node.children;
		if (checkNullIteratee(__ax4_iter_253))
			for (_tmp_ in __ax4_iter_253) {
				_loc3_ = _tmp_;
				_loc2_ = labelBehaviour(_loc3_);
				if (_loc2_ != 0) {
					node.labelLoop = _loc2_;
				}
			}
		return node.labelLoop;
	}

	@:allow(uI.hud.starlingConverted) @:isVar var failures(get, never):Int;

	function get_failures():Int {
		return mFailures;
	}

	@:allow(uI.hud.starlingConverted) @:isVar var error(get, never):String;

	function get_error():String {
		return mError;
	}

	function option(name:String, path:String):Bool {
		var _loc3_:ASAny = mOptions != null ? mOptions[name] : null;
		return Reflect.isFunction(_loc3_) ? ASCompat.toBool(_loc3_(path)) : _loc3_ == true;
	}

	function keep(source:DisplayObject, path:String):Bool {
		var _loc4_ = 0;
		var _loc5_:DisplayObject = null;
		if (option("flatten", path)) {
			return false;
		}
		if (Std.isOfType(source, TextField) || source.name != null && source.name.indexOf("instance") != 0) {
			return true;
		}
		if (maxFrames(source) > 1) {
			return true;
		}
		var _loc3_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		if (_loc3_ != null) {
			_loc4_ = 0;
			while (_loc4_ < _loc3_.numChildren) {
				_loc5_ = _loc3_.getChildAt(_loc4_);
				if (keep(_loc5_, childPath(path, _loc5_, _loc4_))) {
					return true;
				}
				_loc4_++;
			}
		}
		return false;
	}

	function childPath(path:String, child:DisplayObject, depth:Int):String {
		return (path.length > 0 ? path + "." : "") + (child.name != null
			&& child.name.indexOf("instance") != 0 ? child.name : "@" + depth);
	}

	function makeNode(source:DisplayObject, path:String, root:Bool = false, sampled:Bool = false):ArtNode {
		var node:ArtNode;
		var fillRoot:DisplayObject;
		var container:DisplayObjectContainer;
		var clip:MovieClip;
		var field:TextField;
		var forced:String;
		var count:Int;
		var format:TextFormat;
		constructTree(source);
		node = new ArtNode();
		captureMatrix(source);
		node.filterStates.push(source.filters);
		if (source.parent != null && option("clipMasks", path)) {
			node.parentClip = TimelineMasks.clip(source.parent, source);
		}
		node.name = path.length == 0 ? (source.name != null
			&& source.name.length > 0
			&& source.name.indexOf("instance") != 0 ? source.name : mSymbol) : path.substr(path.lastIndexOf(".") + 1);
		node.masked = source.mask != null;
		node.barFill = isBar(source, path);
		if (node.barFill) {
			fillRoot = ASCompat.coerce(source.name == "bar" ? source.parent : source, flash.display.DisplayObject);
			node.masked = node.masked || fillRoot.mask != null || hasMasks(source.parent) || hasMasks(fillRoot.parent);
		}
		if (node.barFill) {
			node.registrationWidth = source.getBounds(source).right;
		}
		node.wantsSilhouette = positive(source.transform.colorTransform);
		node.matrix = source.transform.matrix.clone();
		node.alpha = source.alpha;
		node.visible = source.visible;
		node.blendMode = source.blendMode;
		node.colorTransform = source.transform.colorTransform;
		container = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		clip = ASCompat.reinterpretAs(source, MovieClip);
		field = ASCompat.reinterpretAs(source, TextField);
		forced = mOptions != null && Reflect.isFunction(mOptions.kind) ? mOptions.kind(path) : null;
		count = maxFrames(source);
		assignContext(source, path);
		node.key = contentKey(source, path, 0);
		if (field != null) {
			node.kind = "text";
			node.model = field;
			node.textBounds = field.getBounds(field);
			node.textPages = mPages;
			node.pixelScale = scaleOf(source);
			node.initialText = field.text;
			format = field.length > 0 ? field.getTextFormat() : field.defaultTextFormat;
			node.alignment = field.autoSize == "center" || field.autoSize == "right" ? field.autoSize : format.align;
			return node;
		}
		if (clip != null) {
			readLabels(node, clip);
		}
		if (clip != null && source.name == "cooldown") {
			node.kind = "timeline";
			node.totalFrames = node.authoredFrames = clip.totalFrames;
			node.frames.length = clip.totalFrames;
			mJobs.push(function() {
				buildSweep(node, clip, path);
			});
			return node;
		}
		if (forced == "flipbook" || forced == "states" || forced == "timeline") {
			node.kind = forced;
		} else if (clip != null
			&& (clip.totalFrames > 1
				|| isButtonState(source)
				|| count > 1
				&& (source.name == "UI_buster_glow" || source.name == "buster_activated_glow" || mSymbol.indexOf("UI_teamloot_") == 0))
			&& !option("flatten", path)) {
			node.kind = "timeline";
		} else if ((root || keep(source, path)) && container != null && (root || container.numChildren > 0) && !option("flatten", path)) {
			node.kind = "container";
		} else {
			node.kind = "static";
		}
		if (!node.barFill && (source.mask != null && node.parentClip == null || container != null && container.scrollRect != null)) {
			node.kind = count > 1 ? "flipbook" : "static";
		}
		if (container != null && source.filters.length > 0 && node.kind != "static") {
			node.kind = count > 1 ? "flipbook" : "static";
		}
		if (isButton(source)) {
			node.kind = "container";
			scheduleButtonHit(node, container, path);
		}
		if (container != null && containsText(container)) {
			if (node.kind == "static") {
				node.kind = "container";
			} else if (node.kind == "flipbook") {
				node.kind = "timeline";
			}
		}
		if (!node.barFill
			&& !barRoot(source, path)
			&& container != null
			&& !containsText(container)
			&& (hasMasks(container) && !option("clipMasks", path) || isButtonState(source) && count == 1)) {
			node.kind = count > 1 ? "flipbook" : "static";
		}
		node.stageRate = (node.kind == "timeline" || node.kind == "flipbook")
			&& !rendererTree(source)
			&& mSymbol.indexOf("UI_teamloot_") != 0;
		if (option("stageRate", path)) {
			node.stageRate = true;
		}
		if (node.barFill) {
			node.kind = "static";
		}
		if (option("flatten", path) && !(container != null && containsText(container))) {
			node.kind = "static";
		}
		if (sampled && !(container != null && containsText(container))) {
			node.kind = "static";
		}
		if (node.kind == "static") {
			scheduleBake(node, source, path, 0, null);
		} else if (node.kind == "container") {
			mJobs.push(function() {
				buildContainer(node, container, path);
			});
		} else {
			node.totalFrames = count;
			node.authoredFrames = clip != null ? clip.totalFrames : count;
			node.frames.length = node.kind == "flipbook" ? count : node.authoredFrames;
			mJobs.push(function() {
				record(node, source, path, 0, new ASDictionary<ASAny, ASAny>(), {});
			});
		}
		return node;
	}

	function scheduleButtonHit(node:ArtNode, source:DisplayObjectContainer, path:String) {
		if (source.getChildByName("hit") != null) {
			return;
		}
		mJobs.push(function() {
			var _loc2_:Sprite = null;
			var _loc1_:BakedPicture = null;
			var _loc4_ = contentKey(source, path, 0) + "|buttonHit";
			var _loc3_ = mPages.acquire(_loc4_);
			if (_loc3_ == null) {
				_loc2_ = new Sprite();
				_loc2_.addChild(hitGeometry(source.getChildByName("up"), false, true));
				_loc1_ = StarlingRaster.bake(_loc2_, scaleOf(source));
				if (_loc1_ != null) {
					_loc3_ = mPages.add(_loc4_, _loc1_, true);
				}
			}
			node.hitCell = node.hold(_loc3_, mPages);
			if (_loc3_ == null) {
				mFailures = mFailures + 1;
				node.failures++;
			}
		});
	}

	function buildSweep(node:ArtNode, clip:MovieClip, path:String) {
		var _loc6_:BakedCell = null;
		var _loc5_:BakedPicture = null;
		var _loc7_:String = null;
		var _loc4_:BakedPicture = null;
		rememberTouched(clip);
		node.sweep = StarlingSweepArt.of(clip, rememberTouched);
		if (node.sweep != null) {
			_loc7_ = contentKey(clip, path, 0) + "|disc";
			_loc6_ = mPages.acquire(_loc7_);
			if (_loc6_ == null) {
				_loc5_ = node.sweep.bakeDisc(clip, scaleOf(clip), rememberTouched);
				if (_loc5_ != null) {
					_loc4_ = copyBake(_loc5_);
					_loc6_ = mPages.add(_loc7_, _loc5_, true);
					if (_loc6_ != null) {
						sPixels[_loc6_] = _loc4_;
					} else {
						_loc4_.dispose();
					}
				}
			}
		}
		node.cell = node.hold(_loc6_, mPages);
		if (_loc6_ == null) {
			mFailures = mFailures + 1;
			node.failures++;
			mError = "Cooldown sweep: " + path + " " + StarlingSweepArt.lastRefusal;
		}
	}

	function buildContainer(node:ArtNode, source:DisplayObjectContainer, path:String) {
		var _loc6_ = 0;
		var _loc8_:DisplayObject = null;
		var _loc7_:ArtNode = null;
		var _loc5_:Vector<DisplayObject> = /*undefined*/ null;
		constructTree(source);
		discoverMasks(source);
		var _loc4_ = ASCompat.reinterpretAs(source, Sprite);
		if (_loc4_ != null && _loc4_.graphics.readGraphicsData(false).length > 0) {
			_loc7_ = new ArtNode();
			_loc7_.name = "@graphics";
			_loc7_.kind = "static";
			_loc5_ = new Vector<DisplayObject>((0 : UInt));
			_loc6_ = 0;
			while (_loc6_ < source.numChildren) {
				_loc5_.push(source.getChildAt(_loc6_));
				_loc6_++;
			}
			scheduleBake(_loc7_, source, path + ".@graphics", 0, null, _loc5_);
			node.children.push(_loc7_);
		}
		_loc6_ = 0;
		while (_loc6_ < source.numChildren) {
			_loc8_ = source.getChildAt(_loc6_);
			if (!(isMask(source, _loc8_) || excluded(_loc8_))) {
				node.children.push(makeNode(_loc8_, childPath(path, _loc8_, _loc6_)));
			}
			_loc6_++;
		}
	}

	function record(node:ArtNode, source:DisplayObject, path:String, index:Int, identities:ASDictionary<ASAny, ASAny>, depths:ASObject) {
		var target:Int;
		var clip = ASCompat.reinterpretAs(source, MovieClip);
		var constructed = true;
		if (node.kind == "flipbook") {
			constructed = seekTree(source, index);
		} else {
			rememberTouched(source);
			target = clip != null ? index % clip.totalFrames + 1 : 1;
			if (clip != null) {
				clip.gotoAndStop(target);
				constructed = clip.currentFrame == target;
			}
			constructed = constructChildren(source) && constructed;
			rememberTouched(source);
		}
		stopTree(source);
		if (mDriver != null && !constructed) {
			mWaitingForFrame = true;
			mCapture = function() {
				captureRecord(node, source, path, index, identities, depths);
			};
		} else {
			captureRecord(node, source, path, index, identities, depths);
		}
	}

	function captureRecord(node:ArtNode, source:DisplayObject, path:String, index:Int, identities:ASDictionary<ASAny, ASAny>, depths:ASObject) {
		var frame:ArtFrame;
		var container:DisplayObjectContainer;
		var i:Int;
		var child:DisplayObject;
		var childNode:ArtNode;
		var id:Int;
		var depthKey:String;
		var state:ArtChildState;
		var signature:String;
		var samples:ASObject;
		var sample:ArtFrame;
		var next:ASFunction;
		constructChildren(source);
		stopTree(source);
		frame = new ArtFrame();
		frame.filterState = filterState(node, source.filters);
		node.frames[index] = frame;
		if (node.kind == "flipbook" || node.kind == "states" && option("flatten", path)) {
			scheduleBake(node, source, path, index, frame);
		} else {
			container = ASCompat.reinterpretAs(source, DisplayObjectContainer);
			recordGraphics(node, source, path, index, frame, identities);
			if (container != null) {
				discoverMasks(container);
				i = 0;
				while (i < container.numChildren) {
					child = container.getChildAt(i);
					if (!(isMask(container, child) || excluded(child))) {
						mDrawParents[child] = cast(mDrawMatrices[source], Matrix).clone();
						captureMatrix(child);
						depthKey = ASCompat.getQualifiedClassName(child)
							+ "|"
							+ (child.name != null && child.name.length > 0 && child.name.indexOf("instance") != 0 ? child.name : "@" + i);
						if (identities.exists(child)) {
							id = ASCompat.toInt(identities[child]);
						} else if (ASCompat.hasProperty(depths, depthKey)) {
							id = ASCompat.toInt(depths[depthKey]);
						} else {
							id = node.children.length;
							childNode = makeNode(child, childPath(path, child, i), false, requiresSamples(child) && !(option("clipMasks", path)
								&& TimelineMasks.clip(container, child) != null));
							node.children.push(childNode);
						}
						identities[child] = id;
						depths[depthKey] = id;
						childNode = node.children[id];
						assignContext(child, childPath(path, child, i));
						state = new ArtChildState();
						state.child = id;
						state.matrix = child.transform.matrix.clone();
						state.alpha = child.alpha;
						state.visible = child.visible;
						state.blendMode = child.blendMode;
						state.colorTransform = child.transform.colorTransform;
						state.frame = index % childNode.totalFrames;
						state.filterState = filterState(childNode, child.filters);
						if (option("clipMasks", path)) {
							state.parentClip = TimelineMasks.clip(container, child);
						}
						frame.children.push(state);
						if (positive(state.colorTransform)) {
							childNode.wantsSilhouette = true;
						}
						if ((requiresSamples(child) || childNode.kind == "static" || ASCompat.dictionaryLookupNeNull(mSamples, childNode))
							&& !childNode.barFill
							&& childNode.kind != "text"
							&& !(option("stillChildren", path)
								&& (Std.isOfType(child, DisplayObjectContainer) || Std.isOfType(child, Shape))
								&& maxFrames(child) == 1
								&& child.filters.length == 0
								&& child.mask == null)
							&& !(Std.isOfType(child, DisplayObjectContainer) && containsText(cast(child, DisplayObjectContainer)))) {
							if (childNode.kind == "static") {
								childNode.kind = "flipbook";
								childNode.totalFrames = node.frames.length;
								childNode.authoredFrames = node.frames.length;
								childNode.frames.length = node.frames.length;
								mSamples[childNode] = {};
								mSampleCounts[childNode] = 0;
							}
							if (childNode.kind == "flipbook" && ASCompat.dictionaryLookupNeNull(mSamples, childNode)) {
								state.frame = index;
								signature = pixelsSignature(child, index);
								samples = mSamples[childNode];
								sample = ASCompat.coerce(samples[signature], uI.hud.starlingConverted.ArtFrame);
								if (sample == null) {
									sample = new ArtFrame();
									samples[signature] = sample;
									mSampleCounts[childNode] = ASCompat.toInt(mSampleCounts[childNode]) + 1;
									rememberSample(childNode, sample, source, child, childPath(path, child, i), index, i);
								}
								ASCompat.dynPush(mSampleBakes[sample].scales, scaleOf(child));
								childNode.frames[index] = sample;
							}
						}
					}
					i = i + 1;
				}
			}
		}
		if (index + 1 < node.frames.length) {
			next = function() {
				record(node, source, path, index + 1, identities, depths);
			};
			mJobs.unshift(next);
		} else {
			mJobs.unshift(function() {
				bakeSamples(node);
			});
		}
	}

	function rememberSample(node:ArtNode, frame:ArtFrame, parent:DisplayObject, source:DisplayObject, path:String, index:Int, depth:Int) {
		mSampleBakes[frame] = {
			"node": node,
			"frame": frame,
			"parent": parent,
			"path": path,
			"index": index,
			"depth": depth,
			"scales": [],
			"matrix": drawMatrix(source),
			"state": rememberTree(source)
		};
	}

	function bakeSamples(node:ArtNode) {
		var __ax4_iter_255:ASAny;
		var child:ArtNode;
		var sample:ASObject;
		var frame:ArtFrame;
		mJobs.push(function() {
			finishSamples(node);
		});
		final __ax4_iter_254 = node.children;
		if (checkNullIteratee(__ax4_iter_254))
			for (_tmp_ in __ax4_iter_254) {
				child = _tmp_;
				if (ASCompat.dictionaryLookupNeNull(mSamples, child)) {
					__ax4_iter_255 = mSamples[child];
					if (checkNullIteratee(__ax4_iter_255))
						for (_tmp_ in __ax4_iter_255) {
							frame = ASCompat.coerce(_tmp_, uI.hud.starlingConverted.ArtFrame);
							sample = mSampleBakes[frame];
							if (sample != null) {
								queueSample(sample);
							}
						}
				}
			}
	}

	function queueSample(sample:ASObject) {
		mJobs.push(function() {
			var constructed:Bool;
			var parent = ASCompat.coerce(sample.parent, flash.display.DisplayObject);
			var clip = ASCompat.reinterpretAs(parent, MovieClip);
			var target = clip != null ? ASCompat.toInt(sample.index) % clip.totalFrames + 1 : 1;
			rememberTouched(parent);
			if (clip != null) {
				clip.gotoAndStop(target);
			}
			constructed = constructChildren(parent) && (clip == null || clip.currentFrame == target);
			stopTree(parent);
			if (mDriver != null && !constructed) {
				mWaitingForFrame = true;
				mCapture = function() {
					bakeSample(sample);
				};
			} else {
				bakeSample(sample);
			}
		});
	}

	function bakeSample(sample:ASObject) {
		var _loc4_:Vector<DisplayObject> = /*undefined*/ null;
		var _loc7_ = 0;
		var _loc2_ = ASCompat.dynamicAs(sample.parent, DisplayObjectContainer);
		constructChildren(_loc2_);
		var _loc8_ = ASCompat.coerce(ASCompat.toInt(sample.depth) < 0 ? _loc2_ : _loc2_.getChildAt(ASCompat.toInt(sample.depth)), flash.display.DisplayObject);
		rememberTouched(_loc8_);
		restoreTree(_loc8_, sample.state);
		constructTree(_loc8_);
		stopTree(_loc8_);
		mDrawMatrices[_loc8_] = cast(sample.matrix, Matrix).clone();
		assignContext(_loc8_, sample.path);
		var _loc5_:Array<ASAny> = ASCompat.coerce(sample.scales, Array);
		ASCompat.ASArray.sortWithOptions(_loc5_, 16);
		var _loc3_ = ASCompat.floatToInt(_loc5_.length / 2);
		var _loc6_ = _loc5_.length % 2 == 0 ? (ASCompat.toNumber(_loc5_[_loc3_ - 1]) +
			ASCompat.toNumber(_loc5_[_loc3_])) / 2 : ASCompat.toNumber(_loc5_[_loc3_]);
		if (ASCompat.toInt(sample.depth) < 0) {
			_loc4_ = new Vector<DisplayObject>((0 : UInt));
			_loc7_ = 0;
			while (_loc7_ < _loc2_.numChildren) {
				_loc4_.push(_loc2_.getChildAt(_loc7_));
				_loc7_++;
			}
		}
		scheduleBake(ASCompat.coerce(sample.node, uI.hud.starlingConverted.ArtNode), _loc8_, sample.path, ASCompat.toInt(sample.index),
			ASCompat.coerce(sample.frame, uI.hud.starlingConverted.ArtFrame), _loc4_, _loc6_);
		mSampleBakes.remove(sample.frame);
	}

	function finishSamples(node:ArtNode) {
		var __ax4_iter_257:Vector<ArtFrame>;
		var _loc2_:ArtNode = null;
		var _loc3_:ArtFrame = null;
		final __ax4_iter_256 = node.children;
		if (checkNullIteratee(__ax4_iter_256))
			for (_tmp_ in __ax4_iter_256) {
				_loc2_ = _tmp_;
				if (ASCompat.toNumber(mSampleCounts[_loc2_]) == 1) {
					_loc3_ = null;
					__ax4_iter_257 = _loc2_.frames;
					if (checkNullIteratee(__ax4_iter_257))
						for (_tmp_ in __ax4_iter_257) {
							_loc3_ = _tmp_;
							if (_loc3_ != null) {
								break;
							}
						}
					if (_loc3_ != null) {
						_loc2_.cell = _loc3_.cell;
						_loc2_.kind = "static";
						_loc2_.frames.length = 0;
						_loc2_.totalFrames = _loc2_.authoredFrames = 1;
					}
				}
			}
	}

	function recordGraphics(node:ArtNode, source:DisplayObject, path:String, index:Int, frame:ArtFrame, identities:ASDictionary<ASAny, ASAny>) {
		var _loc12_ = 0;
		var _loc8_:ArtNode = null;
		var _loc11_ = ASCompat.reinterpretAs(source, Sprite);
		if (_loc11_ == null || _loc11_.graphics.readGraphicsData(false).length == 0) {
			return;
		}
		if (identities.exists(source)) {
			_loc12_ = ASCompat.toInt(identities[source]);
		} else {
			_loc12_ = node.children.length;
			_loc8_ = new ArtNode();
			_loc8_.name = "@graphics";
			_loc8_.kind = "flipbook";
			_loc8_.totalFrames = _loc8_.authoredFrames = node.frames.length;
			_loc8_.frames.length = node.frames.length;
			node.children.push(_loc8_);
			identities[source] = _loc12_;
			mSamples[_loc8_] = {};
			mSampleCounts[_loc8_] = 0;
		}
		_loc8_ = node.children[_loc12_];
		var _loc10_:ASObject = mSamples[_loc8_];
		var _loc7_ = haxe.Json.stringify(_loc11_.graphics.readGraphicsData(false));
		var _loc9_ = ASCompat.coerce(_loc10_[_loc7_], uI.hud.starlingConverted.ArtFrame);
		if (_loc9_ == null) {
			_loc9_ = new ArtFrame();
			_loc10_[_loc7_] = _loc9_;
			mSampleCounts[_loc8_] = ASCompat.toInt(mSampleCounts[_loc8_]) + 1;
			rememberSample(_loc8_, _loc9_, source, source, path + ".@graphics", index, -1);
		}
		ASCompat.dynPush(mSampleBakes[_loc9_].scales, scaleOf(source));
		_loc8_.frames[index] = _loc9_;
		var _loc13_ = new ArtChildState();
		_loc13_.child = _loc12_;
		_loc13_.matrix = new Matrix();
		_loc13_.alpha = 1;
		_loc13_.visible = true;
		_loc13_.blendMode = "normal";
		_loc13_.colorTransform = new ColorTransform();
		_loc13_.frame = index;
		frame.children.push(_loc13_);
	}

	function pixelsSignature(source:DisplayObject, frame:Int):String {
		var _loc6_ = 0;
		var _loc3_ = source.mask != null ? inPlaceBake(source, null, false, mScale) : StarlingRaster.bake(source, mScale);
		if (_loc3_ == null) {
			return "refused:" + frame;
		}
		var _loc7_:Float = 2166136261;
		var _loc5_ = _loc3_.bitmap.getVector(_loc3_.bitmap.rect);
		_loc6_ = 0;
		while (_loc6_ < _loc5_.length) {
			_loc7_ = ASCompat.toInt(_loc7_) ^ _loc5_[_loc6_];
			_loc7_ += (ASCompat.floatToInt(_loc7_) << 1) + (ASCompat.floatToInt(_loc7_) << 4) + (ASCompat.floatToInt(_loc7_) << 7)
				+ (ASCompat.floatToInt(_loc7_) << 8) + (ASCompat.floatToInt(_loc7_) << 24);
			_loc6_++;
		}
		var _loc4_ = _loc3_.pixelScale
			+ ":"
			+ _loc3_.bitmap.width
			+ ":"
			+ _loc3_.bitmap.height
			+ ":"
			+ _loc3_.originX
			+ ":"
			+ _loc3_.originY
			+ ":"
			+ _loc7_;
		_loc3_.dispose();
		return _loc4_;
	}

	function assignContext(source:DisplayObject, path:String) {
		var _loc3_:String = null;
		var _loc4_ = source;
		var _loc5_ = "";
		while (_loc4_ != null) {
			_loc3_ = ASCompat.getQualifiedClassName(_loc4_);
			if (_loc3_.indexOf("flash.") != 0) {
				break;
			}
			if (_loc4_.parent == null) {
				if (ASCompat.dictionaryLookupEqNull(sAnonymous, _loc4_)) {
					sAnonymous[_loc4_] = ++sNextAnonymous;
				}
				_loc3_ = "anonymous:" + Std.string(sAnonymous[_loc4_]);
				break;
			}
			_loc5_ = "." + _loc4_.parent.getChildIndex(_loc4_) + _loc5_;
			_loc4_ = _loc4_.parent;
		}
		mContexts[source] = {
			"symbol": _loc3_,
			"path": _loc5_,
			"original": path
		};
	}

	function scheduleBake(node:ArtNode, source:DisplayObject, path:String, frame:Int, target:ArtFrame, hidden:Vector<DisplayObject> = null,
			scale:Float = null) {
		if (scale == null)
			scale = Math.NaN;
		var content:String;
		var pixelScale = Math.isNaN(scale) ? scaleOf(source, node.barFill) : scale;
		if (ASCompat.dictionaryLookupEqNull(mDrawMatrices, source)) {
			captureMatrix(source);
		}
		content = contentKey(source, path, frame, pixelScale);
		mJobs.push(function() {
			var _loc3_:BakedPicture = null;
			var _loc4_:BakedPicture = null;
			var _loc5_:String = null;
			var _loc2_:BakedCell = null;
			var _loc6_:DisplayObject = null;
			if (target == null && node.kind != "static") {
				return;
			}
			var _loc1_ = node.kind == "flipbook" ? mFramePages : mPages;
			var _loc8_ = content;
			if (node.barFill) {
				_loc8_ += "|fullFill";
			}
			var _loc7_ = _loc1_.acquire(_loc8_);
			if (_loc7_ == null) {
				if (Std.isOfType(source, DisplayObjectContainer)) {
					if (hidden == null) {
						hidden = new Vector<DisplayObject>((0 : UInt));
					}
					collectExcluded(cast(source, DisplayObjectContainer), hidden);
				}
				_loc3_ = source.mask != null
					|| node.barFill ? inPlaceBake(source, hidden, node.barFill, pixelScale) : StarlingRaster.bake(source, pixelScale, hidden);
				if (_loc3_ != null) {
					_loc4_ = copyBake(_loc3_);
					_loc7_ = _loc1_.add(_loc8_, _loc3_, true);
					if (_loc7_ != null) {
						sPixels[_loc7_] = _loc4_;
					} else {
						_loc4_.dispose();
					}
				}
			}
			node.hold(_loc7_, _loc1_);
			if (target != null) {
				target.cell = _loc7_;
			} else {
				node.cell = _loc7_;
			}
			if (target == null
				&& (source.name == "hit" || isButtonState(source) || _loc7_ != null && _loc7_.isEmpty && Std.isOfType(source, Shape))) {
				_loc5_ = _loc8_ + "|hit";
				_loc2_ = _loc1_.acquire(_loc5_);
				if (_loc2_ == null) {
					_loc6_ = hitGeometry(source, true, source.name == "hit");
					_loc3_ = StarlingRaster.bake(_loc6_, pixelScale);
					if (_loc3_ != null) {
						_loc2_ = _loc1_.add(_loc5_, _loc3_, true);
					}
				}
				node.hitCell = node.hold(_loc2_, _loc1_);
			}
			if (_loc7_ == null) {
				mFailures = mFailures + 1;
				node.failures++;
			}
		});
	}

	function scaleOf(source:DisplayObject, fullFill:Bool = false):Float {
		return mHudScale * BakeScale.magnitude(drawMatrix(source, fullFill));
	}

	function captureMatrix(source:DisplayObject) {
		var _loc2_:DisplayObject = null;
		if (ASCompat.dictionaryLookupEqNull(mDrawParents, source)) {
			_loc2_ = source.parent;
			if (_loc2_ == null) {
				throw new Error("HUD draw transform unavailable: " + source.name);
			}
			if (ASCompat.dictionaryLookupEqNull(mDrawMatrices, _loc2_)) {
				captureMatrix(_loc2_);
			}
			mDrawParents[source] = cast(mDrawMatrices[_loc2_], Matrix).clone();
		}
		var _loc3_ = source.transform.matrix.clone();
		_loc3_.concat(ASCompat.coerce(mDrawParents[source], flash.geom.Matrix));
		mDrawMatrices[source] = _loc3_;
	}

	function drawMatrix(source:DisplayObject, fullFill:Bool = false):Matrix {
		if (ASCompat.dictionaryLookupEqNull(mDrawMatrices, source)) {
			captureMatrix(source);
		}
		if (!fullFill) {
			return cast(mDrawMatrices[source], Matrix).clone();
		}
		var _loc4_ = source.transform.matrix.clone();
		var _loc3_ = Math.sqrt(_loc4_.a * _loc4_.a + _loc4_.b * _loc4_.b);
		if (_loc3_ > 0) {
			_loc4_.a /= _loc3_;
			_loc4_.b /= _loc3_;
		}
		_loc4_.concat(ASCompat.coerce(mDrawParents[source], flash.geom.Matrix));
		return _loc4_;
	}

	function contentKey(source:DisplayObject, path:String, frame:Int, scale:Float = null):String {
		if (scale == null)
			scale = Math.NaN;
		var _loc5_:ASObject = mContexts[source];
		return Std.string((_loc5_ != null ? _loc5_.symbol : mSymbol))
			+ "|"
			+ (_loc5_ != null ? Std.string(_loc5_.path) + path.substr(ASCompat.toString(_loc5_.original).length) : path)
			+ "|"
			+ frame
			+ "|"
			+ BakedPages.scaleKey(Math.isNaN(scale) ? scaleOf(source) : scale);
	}

	function hitGeometry(source:DisplayObject, root:Bool, ignoreVisibility:Bool):DisplayObject {
		var _loc7_:Vector<IGraphicsData> = /*undefined*/ null;
		var _loc5_:IGraphicsData = null;
		var _loc13_:DisplayObject = null;
		var _loc12_:DisplayObject = null;
		var _loc8_ = 0;
		var _loc11_:Rectangle = null;
		var _loc9_ = new Sprite();
		var _loc4_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		var _loc10_ = ASCompat.reinterpretAs(source, Sprite);
		var _loc6_ = ASCompat.reinterpretAs(source, Shape);
		if (!root) {
			_loc9_.transform.matrix = source.transform.matrix;
		}
		if (_loc6_ != null || _loc10_ != null) {
			_loc7_ = _loc6_ != null ? _loc6_.graphics.readGraphicsData(false) : _loc10_.graphics.readGraphicsData(false);
			if (checkNullIteratee(_loc7_))
				for (_tmp_ in _loc7_) {
					_loc5_ = _tmp_;
					if (Std.isOfType(_loc5_, IGraphicsFill)) {
						opaqueFill(ASCompat.reinterpretAs(_loc5_, IGraphicsFill));
					} else if (Std.isOfType(_loc5_, GraphicsStroke)) {
						opaqueFill(cast(_loc5_, GraphicsStroke).fill);
					}
				}
			_loc9_.graphics.drawGraphicsData(_loc7_);
		} else if (Std.isOfType(source, TextField) || Std.isOfType(source, Bitmap)) {
			_loc11_ = source.getBounds(source);
			_loc9_.graphics.beginFill((16777215 : UInt));
			_loc9_.graphics.drawRect(_loc11_.x, _loc11_.y, _loc11_.width, _loc11_.height);
			_loc9_.graphics.endFill();
		}
		if (_loc4_ != null) {
			_loc8_ = 0;
			while (_loc8_ < _loc4_.numChildren) {
				_loc13_ = _loc4_.getChildAt(_loc8_);
				if (!(!ignoreVisibility && !_loc13_.visible || excluded(_loc13_) || isMask(_loc4_, _loc13_))) {
					_loc12_ = hitGeometry(_loc13_, false, ignoreVisibility);
					_loc9_.addChild(_loc12_);
				}
				_loc8_++;
			}
		}
		return _loc9_;
	}

	function inheritSilhouettes(node:ArtNode, inherited:Bool) {
		var _loc3_:ArtNode = null;
		node.wantsSilhouette = inherited || node.wantsSilhouette;
		final __ax4_iter_258 = node.children;
		if (checkNullIteratee(__ax4_iter_258))
			for (_tmp_ in __ax4_iter_258) {
				_loc3_ = _tmp_;
				inheritSilhouettes(_loc3_, node.wantsSilhouette);
			}
	}

	function inPlaceBake(source:DisplayObject, hidden:Vector<DisplayObject>, fullFill:Bool, scale:Float = null):BakedPicture {
		var __finallyReturn0:BakedPicture;
		var __finallyReturn1:BakedPicture;
		var __finallyReturn2:BakedPicture;
		if (scale == null)
			scale = Math.NaN;
		var _loc6_:BakedPicture = null;
		var _loc8_:BakedPicture = null;
		var _loc14_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc21_:Matrix = null;
		var _loc20_:DisplayObject = null;
		var _loc9_ = Math.NaN;
		var _loc24_:Rectangle = null;
		var _loc23_ = 0;
		var _loc11_ = 0;
		var _loc25_ = 0;
		var _loc17_ = 0;
		var _loc13_:Matrix = null;
		var _loc12_:Rectangle = null;
		var _loc15_:BitmapData = null;
		var _loc5_ = source.parent;
		if (_loc5_ == null) {
			return StarlingRaster.bake(source, Math.isNaN(scale) ? scaleOf(source, fullFill) : scale, hidden);
		}
		var _loc16_ = source.mask;
		while (_loc16_ != null && !_loc5_.contains(_loc16_) && _loc5_.parent != null) {
			_loc5_ = _loc5_.parent;
		}
		var _loc22_ = hidden != null ? hidden.concat() : new Vector<DisplayObject>((0 : UInt));
		hideOthers(_loc5_, source, _loc16_, _loc22_);
		var _loc10_ = source.transform.colorTransform;
		var _loc19_ = source.visible;
		var _loc7_ = source.scaleX;
		{
			var __finallyReturn0:BakedPicture;
			var __finallyReturn1:BakedPicture;
			var __finallyReturn2:BakedPicture;
			try {
				source.visible = true;
				source.transform.colorTransform = new ColorTransform();
				if (fullFill) {
					source.scaleX = 1;
				}
				_loc18_ = _loc14_ = Math.isNaN(scale) ? scaleOf(source, fullFill) : scale;
				_loc21_ = source.transform.matrix;
				_loc20_ = source.parent;
				while (_loc20_ != null && _loc20_ != _loc5_) {
					_loc21_.concat(_loc20_.transform.matrix);
					_loc20_ = _loc20_.parent;
				}
				_loc9_ = _loc14_ / BakeScale.magnitude(_loc21_);
				_loc21_.invert();
				_loc6_ = StarlingRaster.bake(_loc5_, _loc9_, _loc22_, false);
				if (_loc6_ == null) {
					{
						__finallyReturn0 = null;
						{
							if (fullFill) {
								source.scaleX = _loc7_;
							}
							source.transform.colorTransform = _loc10_;
							source.visible = _loc19_;
						};
						return __finallyReturn0;
					};
				}
				if (_loc6_.empty) {
					_loc6_.pixelScale = _loc14_;
					{
						__finallyReturn1 = _loc6_;
						{
							if (fullFill) {
								source.scaleX = _loc7_;
							}
							source.transform.colorTransform = _loc10_;
							source.visible = _loc19_;
						};
						return __finallyReturn1;
					};
				}
				_loc9_ = _loc6_.pixelScale;
				_loc24_ = localBounds(_loc6_, _loc21_);
				_loc23_ = ASCompat.floatToInt(Math.ffloor(_loc24_.x * _loc14_) - 1);
				_loc11_ = ASCompat.floatToInt(Math.ffloor(_loc24_.y * _loc14_) - 1);
				_loc25_ = ASCompat.floatToInt(Math.fceil(_loc24_.right * _loc14_) - _loc23_ + 1);
				_loc17_ = ASCompat.floatToInt(Math.fceil(_loc24_.bottom * _loc14_) - _loc11_ + 1);
				if (_loc25_ > 1024 || _loc17_ > 1024) {
					_loc14_ *= (1024 - 4) / Math.max(_loc25_, _loc17_);
					_loc23_ = ASCompat.floatToInt(Math.ffloor(_loc24_.x * _loc14_) - 1);
					_loc11_ = ASCompat.floatToInt(Math.ffloor(_loc24_.y * _loc14_) - 1);
					_loc25_ = ASCompat.floatToInt(Math.fceil(_loc24_.right * _loc14_) - _loc23_ + 1);
					_loc17_ = ASCompat.floatToInt(Math.fceil(_loc24_.bottom * _loc14_) - _loc11_ + 1);
				}
				_loc8_ = new BakedPicture();
				_loc8_.bitmap = new BitmapData(ASCompat.floatToInt(Math.max(2, _loc25_)), ASCompat.floatToInt(Math.max(2, _loc17_)), true, (0 : UInt));
				_loc13_ = new Matrix(1 / _loc9_, 0, 0, 1 / _loc9_, -_loc6_.originX / _loc9_, -_loc6_.originY / _loc9_);
				_loc13_.concat(_loc21_);
				_loc13_.scale(_loc14_, _loc14_);
				_loc13_.translate(-_loc23_, -_loc11_);
				_loc8_.bitmap.draw(_loc6_.bitmap, _loc13_, null, null, null, true);
				_loc6_.dispose();
				_loc12_ = _loc8_.bitmap.getColorBoundsRect((ASCompat.floatToInt(4278190080) : UInt), (0 : UInt), false);
				if (_loc12_.width == 0 || _loc12_.height == 0) {
					_loc12_.setTo(0, 0, 1, 1);
				}
				_loc15_ = new BitmapData(ASCompat.floatToInt(_loc12_.width + 2), ASCompat.floatToInt(_loc12_.height + 2), true, (0 : UInt));
				_loc15_.copyPixels(_loc8_.bitmap, _loc12_, new Point(1, 1));
				_loc8_.bitmap.dispose();
				_loc8_.bitmap = _loc15_;
				_loc8_.originX = ASCompat.floatToInt(-_loc23_ - _loc12_.x + 1);
				_loc8_.originY = ASCompat.floatToInt(-_loc11_ - _loc12_.y + 1);
				_loc8_.pixelScale = _loc14_;
				StarlingRaster.limit(_loc8_, _loc18_);
				{
					__finallyReturn2 = _loc8_;
					{
						if (fullFill) {
							source.scaleX = _loc7_;
						}
						source.transform.colorTransform = _loc10_;
						source.visible = _loc19_;
					};
					return __finallyReturn2;
				};
			} catch (__finallyError3:Dynamic) {
				{
					if (fullFill) {
						source.scaleX = _loc7_;
					}
					source.transform.colorTransform = _loc10_;
					source.visible = _loc19_;
				};
				ASCompat.rethrowKeepingStack(__finallyError3);
				throw __finallyError3;
			};
			{
				if (fullFill) {
					source.scaleX = _loc7_;
				}
				source.transform.colorTransform = _loc10_;
				source.visible = _loc19_;
			};
		}
		return null;
	}

	function hideOthers(parent:DisplayObjectContainer, source:DisplayObject, mask:DisplayObject, hide:Vector<DisplayObject>) {
		var _loc6_ = 0;
		var _loc7_:DisplayObject = null;
		var _loc5_:DisplayObjectContainer = null;
		_loc6_ = 0;
		while (_loc6_ < parent.numChildren) {
			_loc7_ = parent.getChildAt(_loc6_);
			if (!(_loc7_ == source || _loc7_ == mask || isMask(parent, _loc7_))) {
				_loc5_ = ASCompat.reinterpretAs(_loc7_, DisplayObjectContainer);
				if (_loc5_ != null && (_loc5_.contains(source) || mask != null && _loc5_.contains(mask))) {
					hideOthers(_loc5_, source, mask, hide);
				} else {
					hide.push(_loc7_);
				}
			}
			_loc6_++;
		}
	}

	function barRoot(source:DisplayObject, path:String):Bool {
		return new compat.RegExp("^(HP_bar(?:_delta|_invincible)?|mana_bar(?:_delta)?|xp_bar(?:_delta)?|buster_bar|hpBar)$").test(source.name);
	}

	function isBar(source:DisplayObject, path:String):Bool {
		var _loc3_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		if (barRoot(source, path)) {
			return _loc3_ == null || _loc3_.getChildByName("bar") == null;
		}
		var _loc4_ = path.lastIndexOf(".");
		return source.name == "bar" && source.parent != null && barRoot(source.parent, _loc4_ >= 0 ? path.substr(0, _loc4_) : "");
	}

	function rememberTouched(source:DisplayObject) {
		var _loc3_ = 0;
		if (ASCompat.dictionaryLookupEqNull(mTouched, source)) {
			mTouched[source] = rememberTree(source, false);
		}
		var _loc2_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		if (_loc2_ != null) {
			_loc3_ = 0;
			while (_loc3_ < _loc2_.numChildren) {
				rememberTouched(_loc2_.getChildAt(_loc3_));
				_loc3_++;
			}
		}
	}

	function seekTree(source:DisplayObject, frame:Int):Bool {
		var _loc5_ = 0;
		rememberTouched(source);
		var _loc6_ = ASCompat.reinterpretAs(source, MovieClip);
		var _loc7_ = _loc6_ != null ? frame % _loc6_.totalFrames + 1 : 1;
		if (_loc6_ != null) {
			_loc6_.gotoAndStop(_loc7_);
		}
		var _loc4_ = _loc6_ == null || _loc6_.currentFrame == _loc7_;
		var _loc3_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		if (_loc3_ != null) {
			_loc5_ = 0;
			while (_loc5_ < _loc3_.numChildren) {
				_loc4_ = seekTree(_loc3_.getChildAt(_loc5_), frame) && _loc4_;
				_loc5_++;
			}
		}
		return _loc4_;
	}

	function constructTree(source:DisplayObject):Bool {
		rememberTouched(source);
		var _loc2_ = ASCompat.reinterpretAs(source, MovieClip);
		var _loc3_ = ASCompat.floatToInt(_loc2_ != null ? ASCompat.floatToInt(Math.max(1, _loc2_.currentFrame)) : 1);
		if (_loc2_ != null) {
			_loc2_.gotoAndStop(_loc3_);
		}
		return constructChildren(source) && (_loc2_ == null || _loc2_.currentFrame == _loc3_);
	}

	function constructChildren(source:DisplayObject):Bool {
		var _loc4_ = 0;
		var _loc2_ = ASCompat.reinterpretAs(source, DisplayObjectContainer);
		var _loc3_ = true;
		if (_loc2_ != null) {
			_loc4_ = 0;
			while (_loc4_ < _loc2_.numChildren) {
				_loc3_ = constructTree(_loc2_.getChildAt(_loc4_)) && _loc3_;
				_loc4_++;
			}
		}
		return _loc3_;
	}

	function hasMasks(parent:DisplayObjectContainer):Bool {
		var _loc2_ = 0;
		if (parent == null) {
			return false;
		}
		discoverMasks(parent);
		_loc2_ = 0;
		while (_loc2_ < parent.numChildren) {
			if (isMask(parent, parent.getChildAt(_loc2_))) {
				return true;
			}
			_loc2_++;
		}
		return false;
	}

	function discoverMasks(source:DisplayObjectContainer) {
		var _loc4_ = 0;
		var _loc5_:DisplayObject = null;
		var _loc2_:Rectangle = null;
		var _loc6_:BakedPicture = null;
		var _loc3_ = false;
		_loc4_ = 0;
		while (_loc4_ < source.numChildren) {
			_loc5_ = source.getChildAt(_loc4_);
			if (TimelineMasks.isMask(source, _loc5_)) {
				mMasks[_loc5_] = true;
			} else if (!(!Std.isOfType(_loc5_, Shape) || ASCompat.toBool(mMaskProbed[_loc5_]) || !_loc5_.visible || _loc5_.alpha <= 0)) {
				mMaskProbed[_loc5_] = true;
				_loc2_ = _loc5_.getBounds(_loc5_);
				if (!(_loc2_.width <= 0 || _loc2_.height <= 0)) {
					_loc6_ = StarlingRaster.bake(_loc5_, scaleOf(_loc5_));
					if (_loc6_ != null) {
						_loc3_ = !_loc6_.empty;
						_loc6_.dispose();
						if (_loc3_) {
							_loc6_ = inPlaceBake(_loc5_, null, false);
							if (_loc6_ != null) {
								if (_loc6_.empty) {
									mMasks[_loc5_] = true;
								}
								_loc6_.dispose();
							}
						}
					}
				}
			}
			_loc4_++;
		}
	}

	function isMask(source:DisplayObjectContainer, child:DisplayObject):Bool {
		var _loc3_ = 0;
		if (ASCompat.toBool(mMasks[child])) {
			return true;
		}
		_loc3_ = 0;
		while (_loc3_ < source.numChildren) {
			if (source.getChildAt(_loc3_).mask == child) {
				return true;
			}
			_loc3_++;
		}
		return false;
	}
}
