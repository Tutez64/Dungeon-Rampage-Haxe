package starling.extensions.animate;

import flash.geom.Matrix;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Sprite;
import starling.extensions.animate.styles.ColorTransformStyle;
import starling.extensions.animate.styles.MaskColorTransformStyle;
import starling.extensions.animate.styles.MaskStyle;
import starling.filters.BlurFilter;
import starling.filters.ColorMatrixFilter;
import starling.filters.DropShadowFilter;
import starling.filters.FilterChain;
import starling.filters.FragmentFilter;
import starling.filters.GlowFilter;
import starling.rendering.Painter;
import starling.textures.Texture;
import starling.utils.MathUtil;
import flash.errors.ArgumentError;

/*internal*/
class Symbol extends DisplayObjectContainer {
	public static inline final BITMAP_SYMBOL_NAME = "___atlas_sprite___";

	static inline final QUALITY:Float = 1;

	static final sMatrix:Matrix = new Matrix();

	static var sUnsupportedBlends:ASObject;

	static final NO_KEYFRAMES:Array<Dynamic> = ASCompat.allocArray((0 : UInt));

	static final sHoldsMovieClips:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var _data:ASObject;

	var _atlas:AnimationAtlas;

	var _symbolName:String;

	var _type:String;

	var _loopMode:String;

	var _currentFrame:Int = 0;

	var _composedFrame:Int = 0;

	var _bitmap:Image;

	var _numFrames:Int = 0;

	var _numLayers:Int = 0;

	var _frameCursors:Vector<Int>;

	var _frameLabels:Array<ASAny>;

	var _labels:LabelTable;

	var _loopStart:Int = -1;

	var _forcePlayOnce:Bool = false;

	var _subtreeClamped:Bool = false;

	var _bitmapTexture:Texture;

	var _bitmapData:ASObject;

	var _isClipper:Vector<Bool>;

	var _maskContent:Bool = false;

	var _pixelSnapping:Bool = false;

	var _ownColorMatrix:Vector<Float>;

	var _ownColorAlpha:Float = 1;

	var _parentColorMatrix:Vector<Float>;

	var _composedColorMatrix:Vector<Float>;

	var _elementFilters:Array<ASAny>;

	var _filterChain:FilterChain;

	var _acfColorMatrix:Vector<Float>;

	var _acfScratch:Vector<Float>;

	var _ownFolded:Vector<Float>;

	var _alphaFoldMatrix:Vector<Float>;

	var _boundaryLeading:Vector<Float>;

	var _boundaryTrailing:Vector<Float>;

	var _boundaryTrailingRgb:Vector<Float>;

	var _leadingColorFilter:ColorMatrixFilter;

	var _trailingColorFilter:ColorMatrixFilter;

	var _lastColorData:ASObject;

	var _lastFilterData:ASObject;

	var _lastMatrixData:ASObject;

	var _composedKeyframes:Array<Dynamic>;

	var _holdsMovieClips:Int = -1;

	var _deepestFrameCount:Int = -1;

	public function new(data:ASObject, atlas:AnimationAtlas) {
		super();
		_data = data;
		_atlas = atlas;
		_composedFrame = -1;
		_numLayers = ASCompat.toInt(data.timeline.layers.length);
		_frameCursors = createFrameCursors();
		_numFrames = getNumFrames();
		_labels = atlas.getLabelTable(data);
		_frameLabels = _labels.frameLabels;
		_loopStart = _labels.loopStart;
		_symbolName = data.symbolName;
		_type = "graphic";
		_loopMode = "loop";
		_composedKeyframes = _numLayers != 0 ? ASCompat.allocArray((_numLayers : UInt)) : NO_KEYFRAMES;
		createLayers();
	}

	static function hasAlphaRowTransform(matrix:Vector<Float>):Bool {
		return matrix[15] != 0 || matrix[16] != 0 || matrix[17] != 0 || matrix[18] != 1 || matrix[19] != 0;
	}

	static function alphaRowOnly(source:Vector<Float>, out:Vector<Float>):Vector<Float> {
		out = ColorTransformStyle.copyMatrix(null, out);
		out[15] = source[15];
		out[16] = source[16];
		out[17] = source[17];
		out[18] = source[18];
		out[19] = source[19];
		return out;
	}

	static function num(value:ASAny, fallback:Float):Float {
		var _loc3_ = ASCompat.toNumber(value);
		return Math.isNaN(_loc3_) ? fallback : _loc3_;
	}

	static function parseColor(value:ASAny):UInt {
		var _loc2_:String = null;
		if (Std.isOfType(value, String)) {
			_loc2_ = ASCompat.toString(value);
			if (_loc2_.charAt(0) == "#") {
				_loc2_ = "0x" + _loc2_.substr(1);
			}
			return (ASCompat.parseInt(_loc2_) : UInt);
		}
		return (ASCompat.toInt(value) : UInt);
	}

	static function colorDataEquals(a:ASObject, b:ASObject):Bool {
		if (a == b) {
			return true;
		}
		if (a == null || b == null) {
			return false;
		}
		if (a.mode != b.mode) {
			return false;
		}
		return num(a.redMultiplier, 1) == num(b.redMultiplier, 1)
			&& num(a.greenMultiplier, 1) == num(b.greenMultiplier, 1)
			&& num(a.bitmap, 1) == num(b.bitmap, 1)
			&& num(a.alphaMultiplier, 1) == num(b.alphaMultiplier, 1)
			&& num(a.redOffset, 0) == num(b.redOffset, 0)
			&& num(a.greenOffset, 0) == num(b.greenOffset, 0)
			&& num(a.blueOffset, 0) == num(b.blueOffset, 0)
			&& num(a.alphaOffset, 0) == num(b.alphaOffset, 0)
			&& parseColor(a.tintColor) == parseColor(b.tintColor)
			&& num(a.tintMultiplier, 1) == num(b.tintMultiplier, 1)
			&& num(a.brightness, 0) == num(b.brightness, 0);
	}

	static function filterListEquals(a:ASObject, b:ASObject):Bool {
		var _loc5_ = 0;
		if (a == b) {
			return true;
		}
		var _loc3_:Array<ASAny> = ASCompat.dynamicAs(a, Array);
		var _loc4_:Array<ASAny> = ASCompat.dynamicAs(b, Array);
		if (_loc3_ == null || _loc4_ == null || _loc3_.length != _loc4_.length) {
			return false;
		}
		_loc5_ = 0;
		while (_loc5_ < _loc3_.length) {
			if (!filterDataEquals(_loc3_[_loc5_], _loc4_[_loc5_])) {
				return false;
			}
			_loc5_++;
		}
		return true;
	}

	static function filterDataEquals(a:ASObject, b:ASObject):Bool {
		if (a == b) {
			return true;
		}
		if (a == null || b == null) {
			return false;
		}
		if (a.name != b.name) {
			return false;
		}
		return num(a.blurX, 1) == num(b.blurX, 1)
			&& num(a.blurY, 1) == num(b.blurY, 1)
			&& num(a.quality, 1) == num(b.quality, 1)
			&& num(a.strength, 100) == num(b.strength, 100)
			&& num(a.distance, 4) == num(b.distance, 4)
			&& num(a.angle, 45) == num(b.angle, 45)
			&& parseColor(a.color) == parseColor(b.color)
			&& num(a.brightness, 0) == num(b.brightness, 0)
			&& num(a.contrast, 0) == num(b.contrast, 0)
			&& num(a.saturation, 0) == num(b.saturation, 0)
			&& num(a.H, 0) == num(b.H, 0)
			&& a.instanceName == true == (b.instanceName == true)
			&& a.knockout == true == (b.knockout == true);
	}

	static function blendModeFor(code:ASObject):String {
		if (code == null) {
			return "auto";
		}
		switch (ASCompat.toInt(code)) {
			case 0:
				return "add";
			case 4:
				return "erase";
			case 7:
				return "normal";
			case 9:
				return "multiply";
			case 10:
				return "normal";
			case 12:
				return "screen";
			default:
				if (!sUnsupportedBlends.hasOwnProperty(code)) {
					sUnsupportedBlends[code] = true;
				}
				return "auto";
		}
		return null;
	}

	static function frameCountForData(data:ASObject):Int {
		var _loc3_:Array<ASAny> = null;
		var _loc4_ = 0;
		var _loc5_ = 0;
		var _loc7_ = 0;
		var _loc2_ = 0;
		var _loc6_:Array<ASAny> = ASCompat.dynamicAs(data.timeline.layers, Array);
		if (_loc6_ == null) {
			return 1;
		}
		var _loc8_:ASObject;
		if (checkNullIteratee(_loc6_))
			for (_tmp_ in _loc6_) {
				_loc8_ = _tmp_;
				_loc3_ = ASCompat.dynamicAs(_loc8_.frames, Array);
				_loc4_ = _loc3_ != null ? _loc3_.length : 0;
				_loc5_ = ASCompat.toInt(_loc4_ != 0 ? _loc3_[0].index : 0);
				_loc7_ = 0;
				while (_loc7_ < _loc4_) {
					_loc5_ += ASCompat.toInt(_loc3_[_loc7_].duration);
					_loc7_++;
				}
				if (_loc5_ > _loc2_) {
					_loc2_ = _loc5_;
				}
			}
		return if (_loc2_ != 0) _loc2_ else 1;
	}

	static function timelineHoldsMovieClips(data:ASObject, atlas:AnimationAtlas):Bool {
		var _loc8_ = 0;
		var _loc4_:Array<ASAny> = null;
		var _loc6_ = 0;
		var _loc10_:Array<ASAny> = null;
		var _loc5_ = 0;
		var _loc3_:ASObject = null;
		var _loc12_:String = null;
		var _loc7_:ASObject = null;
		var _loc9_:ASAny = sHoldsMovieClips[data];
		if (_loc9_ != /*undefined*/ null) {
			return ASCompat.toBool(_loc9_);
		}
		sHoldsMovieClips[data] = true;
		var _loc13_ = false;
		var _loc11_:Array<ASAny> = ASCompat.dynamicAs(data.timeline.layers, Array);
		_loc8_ = 0;
		while (!_loc13_ && _loc8_ < _loc11_.length) {
			_loc4_ = ASCompat.dynamicAs(_loc11_[_loc8_].frames, Array);
			_loc6_ = 0;
			while (!_loc13_ && _loc4_ != null && _loc6_ < _loc4_.length) {
				_loc10_ = ASCompat.dynamicAs(_loc4_[_loc6_].elements, Array);
				_loc5_ = 0;
				while (!_loc13_ && _loc10_ != null && _loc5_ < _loc10_.length) {
					_loc3_ = _loc10_[_loc5_].symbolInstance;
					if (_loc3_ != null) {
						if (!ASCompat.toBool(_loc3_.symbolType) || SymbolType.parse(_loc3_.symbolType) == "movieclip") {
							_loc13_ = true;
							break;
						}
						_loc12_ = _loc3_.symbolName;
						if (!atlas.hasSymbol(_loc12_)) {
							_loc12_ = atlas.getFallbackSymbolName(_loc12_);
						}
						_loc7_ = ASCompat.stringAsBool(_loc12_) ? atlas.getSymbolData(_loc12_) : null;
						if (ASCompat.toBool(_loc7_) && timelineHoldsMovieClips(_loc7_, atlas)) {
							_loc13_ = true;
						}
					}
					_loc5_++;
				}
				_loc6_++;
			}
			_loc8_++;
		}
		sHoldsMovieClips[data] = _loc13_;
		return _loc13_;
	}

	public function reset() {
		sMatrix.identity();
		transformationMatrix = sMatrix;
		alpha = 1;
		blendMode = "auto";
		_currentFrame = 0;
		_composedFrame = -1;
		_loopMode = "loop";
		_forcePlayOnce = false;
		_subtreeClamped = false;
		_bitmapData = null;
		_maskContent = false;
		_lastColorData = null;
		_lastFilterData = null;
		_lastMatrixData = null;
		_ownColorMatrix = null;
		_ownColorAlpha = 1;
		_parentColorMatrix = null;
		_composedColorMatrix = null;
		_acfColorMatrix = null;
		_acfScratch = null;
		_ownFolded = null;
		_alphaFoldMatrix = null;
		_boundaryLeading = null;
		_boundaryTrailing = null;
		_boundaryTrailingRgb = null;
		if (_bitmap != null) {
			ColorTransformStyle.setColorTransform(_bitmap, null);
		}
		clearFilters();
		forgetComposedKeyframes();
	}

	function forgetComposedKeyframes() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < _numLayers) {
			_composedKeyframes[_loc1_] = null;
			_loc1_++;
		}
	}

	public function releaseLayers() {
		var _loc1_ = 0;
		var _loc2_:Sprite = null;
		var _loc3_:Symbol = null;
		_loc1_ = 0;
		while (_loc1_ < _numLayers) {
			_loc2_ = getLayer(_loc1_);
			while (_loc2_.numChildren > 0) {
				_loc3_ = ASCompat.reinterpretAs(_loc2_.removeChildAt(_loc2_.numChildren - 1), Symbol);
				_atlas.putSymbol(_loc3_);
			}
			_loc1_++;
		}
		_composedFrame = -1;
		forgetComposedKeyframes();
	}

	@:allow(starling.extensions.animate) function rewindTree() {
		var _loc2_ = 0;
		var _loc3_:Sprite = null;
		var _loc4_ = 0;
		var _loc1_ = 0;
		var _loc5_:Symbol = null;
		_currentFrame = 0;
		_composedFrame = -1;
		forgetComposedKeyframes();
		_loopMode = "loop";
		_forcePlayOnce = false;
		_subtreeClamped = false;
		_loc2_ = 0;
		while (_loc2_ < _numLayers) {
			_loc3_ = getLayer(_loc2_);
			_loc4_ = _loc3_.numChildren;
			_loc1_ = 0;
			while (_loc1_ < _loc4_) {
				_loc5_ = ASCompat.reinterpretAs(_loc3_.getChildAt(_loc1_), Symbol);
				if (_loc5_ != null) {
					_loc5_.rewindTree();
				}
				_loc1_++;
			}
			_loc2_++;
		}
	}

	public function nextFrame() {
		if (_loopMode != "singleframe") {
			currentFrame += 1;
		}
		nextFrame_MovieClips();
	}

	public function nextFrame_MovieClips(frames:Int = 1) {
		var _loc3_ = 0;
		var _loc4_:Sprite = null;
		var _loc5_ = 0;
		var _loc2_ = 0;
		if (_type == "movieclip") {
			currentFrame += frames;
		}
		if (!holdsMovieClips) {
			return;
		}
		_loc3_ = 0;
		while (_loc3_ < _numLayers) {
			_loc4_ = getLayer(_loc3_);
			_loc5_ = _loc4_.numChildren;
			_loc2_ = 0;
			while (_loc2_ < _loc5_) {
				ASCompat.reinterpretAs(_loc4_.getChildAt(_loc2_), Symbol).nextFrame_MovieClips(frames);
				_loc2_++;
			}
			_loc3_++;
		}
	}

	public function setMovieClipLoopMode(loopMode:String) {
		var _loc3_ = 0;
		var _loc4_:Sprite = null;
		var _loc5_ = 0;
		var _loc2_ = 0;
		forgetComposedKeyframes();
		if (loopMode == "playonce") {
			_forcePlayOnce = true;
		} else {
			_subtreeClamped = false;
		}
		if (_type == "movieclip") {
			_loopMode = loopMode;
		}
		_loc3_ = 0;
		while (_loc3_ < _numLayers) {
			_loc4_ = getLayer(_loc3_);
			_loc5_ = _loc4_.numChildren;
			_loc2_ = 0;
			while (_loc2_ < _loc5_) {
				ASCompat.reinterpretAs(_loc4_.getChildAt(_loc2_), Symbol).setMovieClipLoopMode(loopMode);
				_loc2_++;
			}
			_loc3_++;
		}
	}

	public function clearMovieClipsPlayOnce() {
		var _loc2_ = 0;
		var _loc3_:Sprite = null;
		var _loc4_ = 0;
		var _loc1_ = 0;
		forgetComposedKeyframes();
		_forcePlayOnce = false;
		_subtreeClamped = false;
		if (_type == "movieclip") {
			_loopMode = "loop";
		}
		_loc2_ = 0;
		while (_loc2_ < _numLayers) {
			_loc3_ = getLayer(_loc2_);
			_loc4_ = _loc3_.numChildren;
			_loc1_ = 0;
			while (_loc1_ < _loc4_) {
				ASCompat.reinterpretAs(_loc3_.getChildAt(_loc1_), Symbol).clearMovieClipsPlayOnce();
				_loc1_++;
			}
			_loc2_++;
		}
	}

	public function resetMovieClips() {
		var _loc2_ = 0;
		var _loc3_:Sprite = null;
		var _loc4_ = 0;
		var _loc1_ = 0;
		var _loc5_:Symbol = null;
		_loc2_ = 0;
		while (_loc2_ < _numLayers) {
			_loc3_ = getLayer(_loc2_);
			_loc4_ = _loc3_.numChildren;
			_loc1_ = 0;
			while (_loc1_ < _loc4_) {
				_loc5_ = ASCompat.reinterpretAs(_loc3_.getChildAt(_loc1_), Symbol);
				if (_loc5_ != null) {
					if (_loc5_._type == "movieclip") {
						_loc5_.currentFrame = 0;
					}
					_loc5_.resetMovieClips();
				}
				_loc1_++;
			}
			_loc2_++;
		}
	}

	public function update() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < _numLayers) {
			updateLayer(_loc1_);
			_loc1_++;
		}
		_composedFrame = _currentFrame;
	}

	function updateLayer(layerIndex:Int) {
		var _loc6_ = 0;
		var _loc4_:ASObject = null;
		var _loc5_:Symbol = null;
		var _loc12_:Symbol = null;
		var _loc13_:String = null;
		var _loc14_:String = null;
		var _loc9_ = 0;
		var _loc3_ = 0;
		var _loc7_ = getLayer(layerIndex);
		var _loc2_:ASObject = getFrameData(layerIndex, _currentFrame);
		var _loc11_:Array<ASAny> = ASCompat.coerce(ASCompat.toBool(_loc2_) ? ASCompat.coerce(_loc2_.elements, Array) : null, Array);
		var _loc8_ = _loc11_ != null ? _loc11_.length : 0;
		if (_loc2_ != null && _loc2_ == _composedKeyframes[layerIndex] && !_forcePlayOnce && _loc7_.numChildren == _loc8_) {
			advanceHeldElements(_loc7_, _loc2_, _loc11_, _loc8_);
			return;
		}
		_loc7_.blendMode = blendModeFor(ASCompat.toBool(_loc2_) ? _loc2_.blend : null);
		_loc6_ = 0;
		while (_loc6_ < _loc8_) {
			_loc4_ = _loc11_[_loc6_].symbolInstance;
			_loc5_ = ASCompat.coerce(_loc7_.numChildren > _loc6_ ? ASCompat.reinterpretAs(_loc7_.getChildAt(_loc6_), Symbol) : null, Symbol);
			_loc12_ = null;
			_loc13_ = _loc4_.symbolName;
			if (!_atlas.hasSymbol(_loc13_)) {
				_loc14_ = _atlas.getFallbackSymbolName(_loc13_);
				if (_loc14_ != null) {
					_loc13_ = _loc14_;
				} else {
					_loc13_ = "___atlas_sprite___";
				}
			}
			if (_loc5_ != null && _loc5_._symbolName == _loc13_) {
				_loc12_ = _loc5_;
			} else {
				if (_loc5_ != null) {
					_loc5_.removeFromParent();
					_atlas.putSymbol(_loc5_);
				}
				_loc12_ = _atlas.getSymbol(_loc13_);
				_loc7_.addChildAt(_loc12_, _loc6_);
			}
			_loc12_.setMaskContent(_maskContent || _isClipper[layerIndex]);
			_loc12_.pixelSnapping = _pixelSnapping;
			_loc12_.setTransformationMatrix(_loc4_.matrix3D);
			_loc12_.setBitmap(_loc4_.bitmap);
			_loc12_.setColor(_loc4_.color);
			_loc12_.setInheritedColor(_composedColorMatrix);
			_loc12_.setBlend(_loc4_.blend);
			_loc12_.setFilters(_loc4_.filters);
			_loc12_.setType(_loc4_.symbolType);
			_loc12_.setLoop(_loc4_.loop);
			if (_forcePlayOnce) {
				_loc12_.clampPlayOnce();
			}
			if (_loc12_.type == "graphic") {
				_loc9_ = ASCompat.toInt(_loc4_.firstFrame);
				_loc3_ = ASCompat.floatToInt(_currentFrame - ASCompat.toNumberField(_loc2_, "index"));
				if (_loc12_.loopMode == "singleframe") {
					_loc12_.currentFrame = _loc9_;
				} else if (_loc12_.loopMode == "loop") {
					_loc12_.currentFrame = _loc9_ + _loc3_;
				} else {
					_loc12_.currentFrame = _loc9_ + _loc3_;
				}
			} else if (_loc12_._composedFrame != _loc12_._currentFrame) {
				_loc12_.update();
			}
			_loc6_++;
		}
		var _loc10_ = _loc7_.numChildren - _loc8_;
		_loc6_ = 0;
		while (_loc6_ < _loc10_) {
			_loc5_ = ASCompat.reinterpretAs(_loc7_.removeChildAt(_loc8_), Symbol);
			_atlas.putSymbol(_loc5_);
			_loc6_++;
		}
		if (!_isClipper[layerIndex]) {
			_loc7_.visible = _loc8_ > 0;
		}
		_composedKeyframes[layerIndex] = _loc2_;
	}

	function advanceHeldElements(layer:Sprite, frameData:ASObject, elements:Array<ASAny>, numElements:Int) {
		var _loc7_ = 0;
		var _loc8_:Symbol = null;
		var _loc6_ = 0;
		var _loc5_ = ASCompat.floatToInt(_currentFrame - ASCompat.toNumberField(frameData, "index"));
		_loc7_ = 0;
		while (_loc7_ < numElements) {
			_loc8_ = ASCompat.reinterpretAs(layer.getChildAt(_loc7_), Symbol);
			if (_loc8_._type == "graphic") {
				_loc6_ = ASCompat.toInt(elements[_loc7_].symbolInstance.firstFrame);
				_loc8_.currentFrame = _loc8_._loopMode == "singleframe" ? _loc6_ : _loc6_ + _loc5_;
			} else if (_loc8_._composedFrame != _loc8_._currentFrame) {
				_loc8_.update();
			}
			_loc7_++;
		}
	}

	function createLayers() {
		var _loc1_ = 0;
		var _loc2_:Sprite = null;
		if (numChildren > 0) {
			throw new Error("Method must only be called once");
		}
		_loc1_ = 0;
		while (_loc1_ < _numLayers) {
			_loc2_ = new Sprite();
			_loc2_.name = getLayerData(_loc1_).layerName;
			addChild(_loc2_);
			_loc1_++;
		}
		applyMaskLayers();
	}

	function applyMaskLayers() {
		var _loc1_ = 0;
		var _loc2_:String = null;
		var _loc3_ = 0;
		_isClipper = new Vector<Bool>((_numLayers : UInt), true);
		_loc1_ = 0;
		while (_loc1_ < _numLayers) {
			_isClipper[_loc1_] = getLayerData(_loc1_).LT == "Clp";
			if (_isClipper[_loc1_]) {
				getLayer(_loc1_).visible = false;
			}
			_loc1_++;
		}
		_loc1_ = 0;
		while (_loc1_ < _numLayers) {
			_loc2_ = getLayerData(_loc1_).Clpb;
			if (_loc2_ != null) {
				_loc3_ = findClipper(_loc2_, _loc1_ + 1);
				if (_loc3_ < 0) {
					_loc3_ = findClipper(_loc2_, 0);
				}
				if (_loc3_ >= 0) {
					getLayer(_loc1_).mask = getLayer(_loc3_);
				}
			}
			_loc1_++;
		}
	}

	function findClipper(layerName:String, fromLayer:Int):Int {
		var _loc3_ = 0;
		_loc3_ = fromLayer;
		while (_loc3_ < _numLayers) {
			if (_isClipper[_loc3_] && getLayerData(_loc3_).layerName == layerName) {
				return _loc3_;
			}
			_loc3_++;
		}
		return -1;
	}

	@:allow(starling.extensions.animate) @:allow(starling.extensions.animate) @:isVar var pixelSnapping(get, set):Bool;

	function get_pixelSnapping():Bool {
		return _pixelSnapping;
	}

	function set_pixelSnapping(value:Bool):Bool {
		var _loc2_ = 0;
		var _loc4_:Sprite = null;
		var _loc3_ = 0;
		var _loc5_:Symbol = null;
		if (value == _pixelSnapping) {
			return value;
		}
		_pixelSnapping = value;
		if (_bitmap != null) {
			_bitmap.pixelSnapping = value;
		}
		setRequiresRedraw();
		_loc2_ = 0;
		while (_loc2_ < _numLayers) {
			_loc4_ = getLayer(_loc2_);
			_loc3_ = 0;
			while (_loc3_ < _loc4_.numChildren) {
				_loc5_ = ASCompat.reinterpretAs(_loc4_.getChildAt(_loc3_), Symbol);
				if (_loc5_ != null) {
					_loc5_.pixelSnapping = value;
				}
				_loc3_++;
			}
			_loc2_++;
		}
		return value;
	}

	function setMaskContent(value:Bool) {
		if (value == _maskContent) {
			return;
		}
		_maskContent = value;
		_composedFrame = -1;
		forgetComposedKeyframes();
	}

	public function setBitmap(data:ASObject) {
		var _loc3_:Texture = null;
		var _loc2_ = false;
		var _loc4_ = false;
		var _loc5_:ASObject = null;
		if (ASCompat.toBool(data)) {
			_loc3_ = _atlas.getTexture(data.name);
			_loc2_ = false;
			if (_bitmap != null) {
				if (_loc3_ != _bitmapTexture) {
					_bitmap.texture = _loc3_;
					_bitmap.readjustSize();
					_bitmapTexture = _loc3_;
				}
			} else {
				_bitmap = _atlas.getImage(_loc3_);
				_bitmapTexture = _loc3_;
				_bitmap.pixelSnapping = _pixelSnapping;
				addChild(_bitmap);
				_loc2_ = true;
			}
			_loc4_ = Std.isOfType(_bitmap.style, MaskStyle) || Std.isOfType(_bitmap.style, MaskColorTransformStyle);
			if (_maskContent && !_loc4_) {
				_bitmap.style = new MaskStyle();
				_loc2_ = true;
			} else if (!_maskContent && _loc4_) {
				_bitmap.style = null;
				_loc2_ = true;
			}
			if (_loc2_) {
				ColorTransformStyle.setColorTransform(_bitmap, _composedColorMatrix);
			}
			if (data == _bitmapData) {
				return;
			}
			_bitmapData = data;
			_loc5_ = data.position;
			if (_loc5_ == null && data.decomposedMatrix != null) {
				_loc5_ = data.decomposedMatrix.position;
			}
			if (ASCompat.toBool(_loc5_)) {
				_bitmap.x = ASCompat.toNumberField(_loc5_, "x");
				_bitmap.y = ASCompat.toNumberField(_loc5_, "y");
			}
		} else if (_bitmap != null) {
			_bitmap.x = _bitmap.y = 0;
			_bitmap.removeFromParent();
			_atlas.putImage(_bitmap);
			_bitmap = null;
			_bitmapTexture = null;
			_bitmapData = null;
		}
	}

	override public function render(painter:Painter) {
		var _loc2_ = _bitmap;
		if (_numLayers != 0 || _loc2_ == null || mask != null || filter != null || _loc2_.mask != null || _loc2_.filter != null || !_loc2_.visible
			|| _loc2_.alpha == 0 || _loc2_.scaleX == 0 || _loc2_.scaleY == 0) {
			super.render(painter);
			return;
		}
		painter.setStateTo(_loc2_.transformationMatrix, _loc2_.alpha, _loc2_.blendMode);
		_loc2_.render(painter);
	}

	function setTransformationMatrix(data:ASObject) {
		if (data == _lastMatrixData) {
			return;
		}
		_lastMatrixData = data;
		var _loc2_:Array<ASAny> = ASCompat.dynamicAs(data, Array);
		if (_loc2_ != null) {
			if (_loc2_.length >= 16) {
				sMatrix.setTo(ASCompat.toNumber(_loc2_[0]), ASCompat.toNumber(_loc2_[1]), ASCompat.toNumber(_loc2_[4]), ASCompat.toNumber(_loc2_[5]),
					ASCompat.toNumber(_loc2_[12]), ASCompat.toNumber(_loc2_[13]));
			} else {
				sMatrix.setTo(ASCompat.toNumber(_loc2_[0]), ASCompat.toNumber(_loc2_[1]), ASCompat.toNumber(_loc2_[2]), ASCompat.toNumber(_loc2_[3]),
					ASCompat.toNumber(_loc2_[4]), ASCompat.toNumber(_loc2_[5]));
			}
		} else {
			sMatrix.setTo(ASCompat.toNumberField(data, "m00"), ASCompat.toNumberField(data, "m01"), ASCompat.toNumberField(data, "m10"),
				ASCompat.toNumberField(data, "m11"), ASCompat.toNumberField(data, "m30"), ASCompat.toNumberField(data, "m31"));
		}
		var _loc3_ = scaleX == 0 || scaleY == 0;
		transformationMatrix = sMatrix;
		if (_loc3_ || scaleX == 0 || scaleY == 0) {
			setRequiresRedraw();
		}
	}

	function setColor(data:ASObject) {
		var _loc2_:String = null;
		var _loc3_:Array<ASAny> = null;
		if (colorDataEquals(data, _lastColorData)) {
			return;
		}
		_lastColorData = data;
		_ownColorMatrix = null;
		_ownColorAlpha = 1;
		if (ASCompat.toBool(data)) {
			_loc2_ = data.mode;
			if (_loc2_ == "AD" || _loc2_ == "Advanced") {
				if (num(data.redMultiplier, 1) == 1 && num(data.greenMultiplier, 1) == 1 && num(data.bitmap, 1) == 1 && num(data.redOffset, 0) == 0
					&& num(data.greenOffset, 0) == 0 && num(data.blueOffset, 0) == 0 && num(data.alphaOffset, 0) == 0) {
					_ownColorAlpha = num(data.alphaMultiplier, 1);
				} else {
					_ownColorMatrix = Vector.ofArray(([
						num(data.redMultiplier, 1),
						0,
						0,
						0,
						num(data.redOffset, 0),
						0,
						num(data.greenMultiplier, 1),
						0,
						0,
						num(data.greenOffset, 0),
						0,
						0,
						num(data.bitmap, 1),
						0,
						num(data.blueOffset, 0),
						0,
						0,
						0,
						num(data.alphaMultiplier, 1),
						num(data.alphaOffset, 0)
					] : Array<Float>));
				}
			} else if (_loc2_ == "T" || _loc2_ == "Tint") {
				_ownColorMatrix = ColorTransformStyle.animateTintMatrix(parseColor(data.tintColor), num(data.tintMultiplier, 1));
			} else if (_loc2_ == "CBRT" || _loc2_ == "Brightness") {
				_ownColorMatrix = ColorTransformStyle.animateBrightnessMatrix(num(data.brightness, 0));
			} else {
				_loc3_ = ["Alpha", "CA"];
				_ownColorAlpha = _loc3_.indexOf(_loc2_) >= 0 ? num(data.alphaMultiplier, 1) : 1;
			}
		}
		updateComposedColor();
	}

	@:allow(starling.extensions.animate) function setInheritedColor(matrix:Vector<Float>) {
		if (ColorTransformStyle.matricesEqual(matrix, _parentColorMatrix)) {
			return;
		}
		_parentColorMatrix = (matrix != null ? ColorTransformStyle.copyMatrix(matrix, _parentColorMatrix) : null : Vector<Float>);
		updateComposedColor();
	}

	function updateComposedColor() {
		var _loc5_ = 0;
		var _loc6_:Sprite = null;
		var _loc7_ = 0;
		var _loc3_ = 0;
		var _loc4_ = _ownColorMatrix;
		if (_loc4_ == null && _ownColorAlpha != 1 && (_parentColorMatrix != null || _acfColorMatrix != null)) {
			if (_alphaFoldMatrix == null) {
				_alphaFoldMatrix = Vector.ofArray(([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0] : Array<Float>));
			}
			_alphaFoldMatrix[18] = _ownColorAlpha;
			_loc4_ = _alphaFoldMatrix;
		}
		if (_acfColorMatrix != null) {
			_ownFolded = ColorTransformStyle.concat(_loc4_, _acfColorMatrix, _ownFolded);
			_loc4_ = _ownFolded;
		}
		if (_loc4_ != null && ColorTransformStyle.isIdentity(_loc4_)) {
			_loc4_ = null;
		}
		var _loc1_:Vector<Float> = null;
		var _loc2_ = _elementFilters != null;
		if (_loc2_ || _numLayers > 0 && _ownColorMatrix != null && hasAlphaRowTransform(_ownColorMatrix)) {
			updateBoundaryMatrices(_loc4_, _loc2_);
			alpha = _loc4_ == null ? _ownColorAlpha : 1;
			if (!_loc2_ && _parentColorMatrix != null && hasAlphaRowTransform(_parentColorMatrix)) {
				_loc1_ = alphaRowOnly(_parentColorMatrix, _composedColorMatrix);
			}
		} else {
			if (_loc4_ != null || _parentColorMatrix != null) {
				_loc1_ = ColorTransformStyle.concat(_loc4_, _parentColorMatrix, _composedColorMatrix);
				if (ColorTransformStyle.isIdentity(_loc1_)) {
					_loc1_ = null;
				}
			}
			alpha = _loc1_ == null ? _ownColorAlpha : 1;
			clearBoundaryMatrices();
		}
		_composedColorMatrix = _loc1_;
		if (_bitmap != null) {
			ColorTransformStyle.setColorTransform(_bitmap, _loc1_);
		}
		_loc5_ = 0;
		while (_loc5_ < _numLayers) {
			_loc6_ = getLayer(_loc5_);
			_loc7_ = _loc6_.numChildren;
			_loc3_ = 0;
			while (_loc3_ < _loc7_) {
				ASCompat.reinterpretAs(_loc6_.getChildAt(_loc3_), Symbol).setInheritedColor(_loc1_);
				_loc3_++;
			}
			_loc5_++;
		}
	}

	function setFilters(data:ASObject) {
		var _loc8_:ASObject;
		var _loc5_:FragmentFilter;
		var _loc4_:ColorMatrixFilter = null;
		var _loc7_:Vector<Float> = /*undefined*/ null;
		var _loc2_:FragmentFilter = null;
		if (filterListEquals(data, _lastFilterData)) {
			return;
		}
		_lastFilterData = data;
		var _loc3_ = _elementFilters;
		_elementFilters = null;
		_acfColorMatrix = null;
		var _loc6_:Array<ASAny> = ASCompat.dynamicAs(data, Array);
		if (_loc6_ != null && _loc6_.length > 0) {
			if (checkNullIteratee(_loc6_))
				for (_tmp_ in _loc6_) {
					_loc8_ = _tmp_;
					if (_loc8_ != null && _loc8_.name == "ACF" && _elementFilters == null) {
						_loc4_ = ASCompat.reinterpretAs(createFilter(_loc8_), ColorMatrixFilter);
						if (_loc4_ != null) {
							_loc7_ = ColorTransformStyle.concat(_acfColorMatrix, _loc4_.matrix, _acfScratch);
							_acfScratch = _acfColorMatrix;
							_acfColorMatrix = _loc7_;
							_loc4_.dispose();
						}
					} else {
						_loc2_ = createFilter(_loc8_);
						if (_loc2_ != null) {
							if (_elementFilters == null) {
								_elementFilters = [];
							}
							_elementFilters.push(_loc2_);
						}
					}
				}
		}
		updateSymbolFilters();
		updateComposedColor();
		if (_loc3_ != null) {
			if (checkNullIteratee(_loc3_))
				for (_tmp_ in _loc3_) {
					_loc5_ = ASCompat.coerce(_tmp_, starling.filters.FragmentFilter);
					_loc5_.dispose();
				}
		}
	}

	function createFilter(fd:ASObject):FragmentFilter {
		var _loc4_:ASAny = null;
		var _loc2_:ASAny = null;
		var _loc3_:ColorMatrixFilter = null;
		if (fd == null) {
			return null;
		}
		switch (fd.name) {
			case "BLF":
				return new BlurFilter(num(fd.blurX, 1), num(fd.blurY, 1));
			case "GF":
				return new GlowFilter(parseColor(fd.color), num(fd.strength, 100) / 100, Math.max(num(fd.blurX, 1), num(fd.blurY, 1)), 1,
					fd.instanceName == true, fd.knockout == true);
			case "DSF":
				return new DropShadowFilter(num(fd.distance, 4), num(fd.angle, 45) * 3.141592653589793 / 180, parseColor(fd.color),
					num(fd.strength, 100) / 100, Math.max(num(fd.blurX, 1), num(fd.blurY, 1)), 1, fd.instanceName == true, fd.knockout == true);
			case "ACF":
				_loc3_ = new ColorMatrixFilter();
				if (ASCompat.toBool(fd.brightness)) {
					_loc3_.adjustBrightness(num(fd.brightness, 0) / 100);
				}
				if (ASCompat.toBool(fd.contrast)) {
					_loc3_.adjustContrast(num(fd.contrast, 0) / 100);
				}
				if (ASCompat.toBool(fd.saturation)) {
					_loc3_.adjustSaturation(num(fd.saturation, 0) / 100);
				}
				if (ASCompat.toBool(fd.H)) {
					_loc3_.adjustHue(num(fd.H, 0) / 180);
				}
				return _loc3_;
			default:
				return null;
		}
		return null;
	}

	function updateBoundaryMatrices(own:Vector<Float>, filtered:Bool) {
		var _loc4_ = false;
		if (!ColorTransformStyle.matricesEqual(own, _boundaryLeading)) {
			_boundaryLeading = (own != null ? ColorTransformStyle.copyMatrix(own, _boundaryLeading) : null : Vector<Float>);
			_loc4_ = true;
		}
		var _loc3_ = _parentColorMatrix;
		if (!filtered && _loc3_ != null && hasAlphaRowTransform(_loc3_)) {
			_boundaryTrailingRgb = ColorTransformStyle.copyMatrix(_loc3_, _boundaryTrailingRgb);
			_boundaryTrailingRgb[15] = 0;
			_boundaryTrailingRgb[16] = 0;
			_boundaryTrailingRgb[17] = 0;
			_boundaryTrailingRgb[18] = 1;
			_boundaryTrailingRgb[19] = 0;
			_loc3_ = (ColorTransformStyle.isIdentity(_boundaryTrailingRgb) ? null : _boundaryTrailingRgb:Vector<Float>);
		}
		if (!ColorTransformStyle.matricesEqual(_loc3_, _boundaryTrailing)) {
			_boundaryTrailing = (_loc3_ != null ? ColorTransformStyle.copyMatrix(_loc3_, _boundaryTrailing) : null : Vector<Float>);
			_loc4_ = true;
		}
		if (_loc4_) {
			updateSymbolFilters();
		}
	}

	function clearBoundaryMatrices() {
		if (_boundaryLeading == null && _boundaryTrailing == null) {
			return;
		}
		_boundaryLeading = null;
		_boundaryTrailing = null;
		updateSymbolFilters();
	}

	function updateSymbolFilters() {
		var _loc3_:FragmentFilter;
		var __ax4_iter_509:Array<ASAny>;
		if (_filterChain != null) {
			while (_filterChain.numFilters > 0) {
				_filterChain.removeFilterAt(0, false);
			}
		}
		var _loc4_ = _elementFilters != null ? _elementFilters.length : 0;
		var _loc2_:ColorMatrixFilter = null;
		var _loc1_:ColorMatrixFilter = null;
		if (_boundaryLeading != null) {
			if (_leadingColorFilter == null) {
				_leadingColorFilter = new ColorMatrixFilter();
			}
			_leadingColorFilter.matrix = _boundaryLeading;
			_loc2_ = _leadingColorFilter;
			_loc4_++;
		}
		if (_boundaryTrailing != null) {
			if (_trailingColorFilter == null) {
				_trailingColorFilter = new ColorMatrixFilter();
			}
			_trailingColorFilter.matrix = _boundaryTrailing;
			_loc1_ = _trailingColorFilter;
			_loc4_++;
		}
		if (_loc4_ == 0) {
			this.filter = null;
		} else if (_loc4_ == 1) {
			this.filter = ASCompat.coerce(_loc2_ ?? ASCompat.coerce(_loc1_ ?? ASCompat.coerce(_elementFilters[0], starling.filters.FragmentFilter),
				starling.filters.FragmentFilter),
				starling.filters.FragmentFilter);
		} else {
			if (_filterChain == null) {
				_filterChain = new FilterChain();
			}
			if (_loc2_ != null) {
				_filterChain.addFilter(_loc2_);
			}
			if (_elementFilters != null) {
				__ax4_iter_509 = _elementFilters;
				if (checkNullIteratee(__ax4_iter_509))
					for (_tmp_ in __ax4_iter_509) {
						_loc3_ = ASCompat.coerce(_tmp_, starling.filters.FragmentFilter);
						_filterChain.addFilter(_loc3_);
					}
			}
			if (_loc1_ != null) {
				_filterChain.addFilter(_loc1_);
			}
			this.filter = _filterChain;
		}
	}

	override public function dispose() {
		clearFilters();
		super.dispose();
	}

	function clearFilters() {
		var _loc1_:FragmentFilter;
		var __ax4_iter_510:Array<ASAny>;
		this.filter = null;
		if (_elementFilters != null) {
			__ax4_iter_510 = _elementFilters;
			if (checkNullIteratee(__ax4_iter_510))
				for (_tmp_ in __ax4_iter_510) {
					_loc1_ = ASCompat.coerce(_tmp_, starling.filters.FragmentFilter);
					_loc1_.dispose();
				}
			_elementFilters = null;
		}
		if (_leadingColorFilter != null) {
			_leadingColorFilter.dispose();
			_leadingColorFilter = null;
		}
		if (_trailingColorFilter != null) {
			_trailingColorFilter.dispose();
			_trailingColorFilter = null;
		}
		if (_filterChain != null) {
			while (_filterChain.numFilters > 0) {
				_filterChain.removeFilterAt(0, false);
			}
			_filterChain.dispose();
			_filterChain = null;
		}
	}

	function setBlend(data:ASObject) {
		blendMode = blendModeFor(data);
	}

	function setLoop(data:String) {
		if (_forcePlayOnce && _type == "movieclip") {
			return;
		}
		_loopMode = ASCompat.stringAsBool(data) ? LoopMode.parse(data) : "loop";
	}

	function setType(data:String) {
		if (ASCompat.stringAsBool(data)) {
			_type = SymbolType.parse(data);
		}
	}

	function getNumFrames():Int {
		return frameCountForData(_data);
	}

	@:isVar public var deepestFrameCount(get, never):Int;

	public function get_deepestFrameCount():Int {
		if (_deepestFrameCount < 0) {
			_deepestFrameCount = deepestFramesIn(_data, {});
		}
		return _deepestFrameCount;
	}

	function deepestFramesIn(data:ASObject, visited:ASObject):Int {
		var _loc12_:ASObject;
		var _loc13_:ASObject;
		var _loc4_:Array<ASAny> = null;
		var _loc9_:Array<ASAny> = null;
		var _loc3_:ASObject = null;
		var _loc11_:String = null;
		var _loc6_:ASObject = null;
		var _loc8_ = 0;
		var _loc5_ = frameCountForData(data);
		var _loc10_:Array<ASAny> = ASCompat.dynamicAs(data.timeline.layers, Array);
		if (_loc10_ == null) {
			return _loc5_;
		}
		var _loc7_:ASObject;
		if (checkNullIteratee(_loc10_))
			for (_tmp_ in _loc10_) {
				_loc7_ = _tmp_;
				_loc4_ = ASCompat.dynamicAs(_loc7_.frames, Array);
				if (_loc4_ != null) {
					if (checkNullIteratee(_loc4_))
						for (_tmp_ in _loc4_) {
							_loc12_ = _tmp_;
							if (ASCompat.toNumberField(_loc12_, "index") == 0) {
								_loc9_ = ASCompat.dynamicAs(_loc12_.elements, Array);
								if (_loc9_ != null) {
									if (checkNullIteratee(_loc9_))
										for (_tmp_ in _loc9_) {
											_loc13_ = _tmp_;
											_loc3_ = _loc13_.symbolInstance;
											if (_loc3_ != null) {
												_loc11_ = _loc3_.symbolName;
												if (!(_loc11_ == null || ASCompat.toBool(visited[_loc11_]))) {
													visited[_loc11_] = true;
													_loc6_ = _atlas.getSymbolData(_loc11_);
													if (!(_loc6_ == null || _loc6_.timeline == null)) {
														_loc8_ = deepestFramesIn(_loc6_, visited);
														if (_loc8_ > _loc5_) {
															_loc5_ = _loc8_;
														}
													}
												}
											}
										}
								}
							}
						}
				}
			}
		return _loc5_;
	}

	function getLayer(layerIndex:Int):Sprite {
		return ASCompat.reinterpretAs(getChildAt(layerIndex), Sprite);
	}

	public function getNextLabel(afterLabel:String = null):String {
		return _labels.getNextLabel(afterLabel, _currentFrame);
	}

	@:isVar public var currentLabel(get, never):String;

	public function get_currentLabel():String {
		return _labels.labelAt(_currentFrame);
	}

	public function getFrame(label:String):Int {
		return _labels.getFrame(label);
	}

	public function hasFrameLabelSuffix(suffix:String):Bool {
		var _loc4_ = 0;
		var _loc3_:String = null;
		var _loc2_ = _frameLabels.length;
		_loc4_ = 0;
		while (_loc4_ < _loc2_) {
			_loc3_ = _frameLabels[_loc4_].name;
			if (_loc3_.length >= suffix.length && _loc3_.substr(_loc3_.length - suffix.length) == suffix) {
				return true;
			}
			_loc4_++;
		}
		return false;
	}

	public function hasFrameLabel(label:String):Bool {
		var _loc2_ = hasFrameLabelNoClamp(label);
		if (getFrame(label) >= 0) {
			clampPlayOnce();
		}
		return _loc2_;
	}

	public function hasFrameLabelNoClamp(label:String):Bool {
		var _loc4_ = 0;
		var _loc5_:Sprite = null;
		var _loc6_ = 0;
		var _loc3_ = 0;
		var _loc7_:Symbol = null;
		var _loc2_ = getFrame(label) >= 0;
		_loc4_ = 0;
		while (_loc4_ < _numLayers) {
			_loc5_ = getLayer(_loc4_);
			_loc6_ = _loc5_.numChildren;
			_loc3_ = 0;
			while (_loc3_ < _loc6_) {
				_loc7_ = ASCompat.reinterpretAs(_loc5_.getChildAt(_loc3_), Symbol);
				if (_loc7_ != null && _loc7_.hasFrameLabelNoClamp(label)) {
					_loc2_ = true;
				}
				_loc3_++;
			}
			_loc4_++;
		}
		return _loc2_;
	}

	function clampPlayOnce() {
		var _loc2_ = 0;
		var _loc3_:Sprite = null;
		var _loc4_ = 0;
		var _loc1_ = 0;
		var _loc5_:Symbol = null;
		if (_type == "movieclip") {
			_loopMode = "playonce";
		}
		_forcePlayOnce = true;
		if (_subtreeClamped) {
			return;
		}
		_loc2_ = 0;
		while (_loc2_ < _numLayers) {
			_loc3_ = getLayer(_loc2_);
			_loc4_ = _loc3_.numChildren;
			_loc1_ = 0;
			while (_loc1_ < _loc4_) {
				_loc5_ = ASCompat.reinterpretAs(_loc3_.getChildAt(_loc1_), Symbol);
				if (_loc5_ != null) {
					_loc5_.clampPlayOnce();
				}
				_loc1_++;
			}
			_loc2_++;
		}
		_subtreeClamped = true;
	}

	public function areMovieClipsAtFinal():Bool {
		var _loc2_ = 0;
		var _loc3_:Sprite = null;
		var _loc4_ = 0;
		var _loc1_ = 0;
		var _loc5_:Symbol = null;
		if (_type == "movieclip" && _loopMode != "singleframe" && _currentFrame < _numFrames - 1) {
			return false;
		}
		_loc2_ = 0;
		while (_loc2_ < _numLayers) {
			_loc3_ = getLayer(_loc2_);
			_loc4_ = _loc3_.numChildren;
			_loc1_ = 0;
			while (_loc1_ < _loc4_) {
				_loc5_ = ASCompat.reinterpretAs(_loc3_.getChildAt(_loc1_), Symbol);
				if (_loc5_ != null && !_loc5_.areMovieClipsAtFinal()) {
					return false;
				}
				_loc1_++;
			}
			_loc2_++;
		}
		return true;
	}

	@:isVar public var currentFrame(get, set):Int;

	public function get_currentFrame():Int {
		return _currentFrame;
	}

	function set_currentFrame(value:Int):Int {
		while (value < 0) {
			value += _numFrames;
		}
		if (_loopMode == "playonce") {
			_currentFrame = ASCompat.floatToInt(MathUtil.clamp(value, 0, _numFrames - 1));
		} else if (_loopStart > 0 && value >= _numFrames) {
			_currentFrame = _loopStart + (value - _loopStart) % (_numFrames - _loopStart);
		} else {
			_currentFrame = ASCompat.floatToInt(Math.abs(value % _numFrames));
		}
		if (_composedFrame != _currentFrame) {
			update();
		}
		return value;
	}

	@:isVar public var type(get, set):String;

	public function get_type():String {
		return _type;
	}

	function set_type(value:String):String {
		if (SymbolType.isValid(value)) {
			_type = value;
			return value;
		}
		throw new ArgumentError("Invalid symbol type: " + value);
		return value;
	}

	@:isVar public var loopMode(get, set):String;

	public function get_loopMode():String {
		return _loopMode;
	}

	function set_loopMode(value:String):String {
		if (LoopMode.isValid(value)) {
			_loopMode = value;
			return value;
		}
		throw new ArgumentError("Invalid loop mode: " + value);
		return value;
	}

	@:isVar public var symbolName(get, never):String;

	public function get_symbolName():String {
		return _symbolName;
	}

	@:isVar public var numLayers(get, never):Int;

	public function get_numLayers():Int {
		return _numLayers;
	}

	@:isVar public var numFrames(get, never):Int;

	public function get_numFrames():Int {
		return _numFrames;
	}

	@:isVar var holdsMovieClips(get, never):Bool;

	function get_holdsMovieClips():Bool {
		if (_holdsMovieClips < 0) {
			_holdsMovieClips = timelineHoldsMovieClips(_data, _atlas) ? 1 : 0;
		}
		return _holdsMovieClips == 1;
	}

	function getLayerData(layerIndex:Int):ASObject {
		return _data.timeline.layers[layerIndex];
	}

	function getFrameData(layerIndex:Int, frameIndex:Int):ASObject {
		var _loc8_:ASObject = null;
		var _loc5_ = 0;
		var _loc7_ = 0;
		var _loc6_:Array<ASAny> = ASCompat.coerce(getLayerData(layerIndex).frames, Array);
		var _loc4_ = _loc6_.length;
		var _loc3_ = _frameCursors[layerIndex];
		if (_loc3_ >= 0) {
			_loc5_ = _loc3_;
			while (_loc5_ <= _loc3_ + 1 && _loc5_ < _loc4_) {
				_loc8_ = _loc6_[_loc5_];
				if (ASCompat.toNumberField(_loc8_, "index") <= frameIndex
					&& ASCompat.toNumber(_loc8_.index + _loc8_.duration) > frameIndex) {
					_frameCursors[layerIndex] = _loc5_;
					return _loc8_;
				}
				_loc5_++;
			}
		}
		_loc7_ = 0;
		while (_loc7_ < _loc4_) {
			_loc8_ = _loc6_[_loc7_];
			if (ASCompat.toNumberField(_loc8_, "index") <= frameIndex && ASCompat.toNumber(_loc8_.index + _loc8_.duration) > frameIndex) {
				if (_loc3_ >= 0) {
					_frameCursors[layerIndex] = _loc7_;
				}
				return _loc8_;
			}
			_loc7_++;
		}
		return null;
	}

	function createFrameCursors():Vector<Int> {
		var _loc5_ = 0;
		var _loc3_:Array<ASAny> = null;
		var _loc4_ = 0;
		var _loc6_:ASObject = null;
		var _loc1_:ASObject = null;
		var _loc2_ = new Vector<Int>((_numLayers : UInt), true);
		_loc5_ = 0;
		while (_loc5_ < _numLayers) {
			_loc3_ = ASCompat.coerce(getLayerData(_loc5_).frames, Array);
			_loc4_ = 0;
			while (_loc4_ < _loc3_.length) {
				_loc6_ = _loc3_[_loc4_];
				_loc1_ = _loc4_ + 1 < _loc3_.length ? _loc3_[_loc4_ + 1] : null;
				if (!(Std.isOfType(_loc6_.index, Float)
					&& Std.isOfType(_loc6_.duration, Float)
					&& ASCompat.toNumberField(_loc6_, "duration") >= 1
					&& (_loc1_ == null || _loc6_.index + _loc6_.duration <= _loc1_.index))) {
					_loc2_[_loc5_] = -1;
					break;
				}
				_loc4_++;
			}
			_loc5_++;
		}
		return _loc2_;
	}

	static function __init__() {
		sUnsupportedBlends = {};
	}
}
