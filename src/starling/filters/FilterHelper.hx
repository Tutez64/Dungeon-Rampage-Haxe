package starling.filters;

import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.utils.MathUtil;
import starling.utils.Pool;

/*use*/ /*namespace*/ /*starling_internal*/ /*internal*/
class FilterHelper implements IFilterHelper {
	var _width:Float = Math.NaN;

	var _height:Float = Math.NaN;

	var _nativeWidth:Int = 0;

	var _nativeHeight:Int = 0;

	var _pool:Vector<Texture>;

	var _usePotTextures:Bool = false;

	var _textureFormat:String;

	var _preferredScale:Float = Math.NaN;

	var _scale:Float = Math.NaN;

	var _sizeStep:Int = 0;

	var _numPasses:Int = 0;

	var _projectionMatrix:Matrix3D;

	var _renderTarget:Texture;

	var _targetBounds:Rectangle;

	var _target:DisplayObject;

	var _clipRect:Rectangle;

	var sRegion:Rectangle = new Rectangle();

	public function new(textureFormat:String = "bgra") {
		_usePotTextures = Starling.current.profile == "baselineConstrained";
		_preferredScale = Starling.contentScaleFactor;
		_textureFormat = textureFormat;
		_sizeStep = 64;
		_pool = new Vector<Texture>((0 : UInt));
		_projectionMatrix = new Matrix3D();
		_targetBounds = new Rectangle();
		setSize(_sizeStep, _sizeStep);
	}

	public function dispose() {
		Pool.putRectangle(_clipRect);
		_clipRect = null;
		purge();
	}

	public function start(numPasses:Int, drawLastPassToBackBuffer:Bool) {
		_numPasses = drawLastPassToBackBuffer ? numPasses : -1;
	}

	public function getTexture(resolution:Float = 1):Texture {
		var _loc3_:Texture = null;
		var _loc2_:SubTexture = null;
		if (_numPasses >= 0) {
			if (_numPasses-- == 0) {
				return null;
			}
		}
		if (_pool.length != 0) {
			_loc3_ = _pool.pop();
		} else {
			_loc3_ = Texture.empty(_nativeWidth / _scale, _nativeHeight / _scale, true, false, true, _scale, _textureFormat);
		}
		if (!MathUtil.isEquivalent(_loc3_.width, _width, 0.1)
			|| !MathUtil.isEquivalent(_loc3_.height, _height, 0.1)
			|| !MathUtil.isEquivalent(_loc3_.scale, _scale * resolution)) {
			sRegion.setTo(0, 0, _width * resolution, _height * resolution);
			_loc2_ = ASCompat.reinterpretAs(_loc3_, SubTexture);
			if (_loc2_ != null) {
				_loc2_.setTo(_loc3_.root, sRegion, true, null, false, resolution);
			} else {
				_loc3_ = new SubTexture(_loc3_.root, sRegion, true, null, false, resolution);
			}
		}
		_loc3_.root.clear();
		return _loc3_;
	}

	public function putTexture(texture:Texture) {
		if (texture != null) {
			if (texture.root.nativeWidth == _nativeWidth && texture.root.nativeHeight == _nativeHeight) {
				_pool.insertAt(_pool.length, texture);
			} else {
				texture.dispose();
			}
		}
	}

	public function purge() {
		var _loc2_ = 0;
		var _loc1_ = 0;
		_loc2_ = 0;
		_loc1_ = _pool.length;
		while (_loc2_ < _loc1_) {
			_pool[_loc2_].dispose();
			_loc2_++;
		}
		_pool.length = 0;
	}

	function setSize(width:Float, height:Float) {
		var _loc6_ = Math.NaN;
		var _loc7_ = _preferredScale;
		var _loc4_ = Texture.getMaxSize(_textureFormat);
		var _loc5_ = getNativeSize(width, _loc7_);
		var _loc3_ = getNativeSize(height, _loc7_);
		if (_loc5_ > _loc4_ || _loc3_ > _loc4_) {
			_loc6_ = _loc4_ / Math.max(_loc5_, _loc3_);
			_loc5_ = ASCompat.floatToInt(_loc5_ * _loc6_);
			_loc3_ = ASCompat.floatToInt(_loc3_ * _loc6_);
			_loc7_ *= _loc6_;
		}
		if (_nativeWidth != _loc5_ || _nativeHeight != _loc3_ || _scale != _loc7_) {
			purge();
			_scale = _loc7_;
			_nativeWidth = _loc5_;
			_nativeHeight = _loc3_;
		}
		_width = width;
		_height = height;
	}

	function getNativeSize(size:Float, textureScale:Float):Int {
		var _loc3_ = size * textureScale;
		if (_usePotTextures) {
			return _loc3_ > _sizeStep ? MathUtil.getNextPowerOfTwo(_loc3_) : _sizeStep;
		}
		return ASCompat.floatToInt(Math.fceil(_loc3_ / _sizeStep) * _sizeStep);
	}

	@:isVar public var projectionMatrix3D(get, set):Matrix3D;

	public function get_projectionMatrix3D():Matrix3D {
		return _projectionMatrix;
	}

	function set_projectionMatrix3D(value:Matrix3D):Matrix3D {
		_projectionMatrix.copyFrom(value);
		return value;
	}

	@:isVar public var renderTarget(get, set):Texture;

	public function get_renderTarget():Texture {
		return _renderTarget;
	}

	function set_renderTarget(value:Texture):Texture {
		return _renderTarget = value;
	}

	@:isVar public var clipRect(get, set):Rectangle;

	public function get_clipRect():Rectangle {
		return _clipRect;
	}

	function set_clipRect(value:Rectangle):Rectangle {
		if (value != null) {
			if (_clipRect != null) {
				_clipRect.copyFrom(value);
			} else {
				_clipRect = Pool.getRectangle(value.x, value.y, value.width, value.height);
			}
		} else if (_clipRect != null) {
			Pool.putRectangle(_clipRect);
			_clipRect = null;
		}
		return value;
	}

	@:isVar public var targetBounds(get, set):Rectangle;

	public function get_targetBounds():Rectangle {
		return _targetBounds;
	}

	function set_targetBounds(value:Rectangle):Rectangle {
		_targetBounds.copyFrom(value);
		setSize(value.width, value.height);
		return value;
	}

	@:isVar public var target(get, set):DisplayObject;

	public function get_target():DisplayObject {
		return _target;
	}

	function set_target(value:DisplayObject):DisplayObject {
		return _target = value;
	}

	@:isVar public var textureScale(get, set):Float;

	public function get_textureScale():Float {
		return _preferredScale;
	}

	function set_textureScale(value:Float):Float {
		_preferredScale = value > 0 ? value : Starling.contentScaleFactor;
		return value;
	}

	@:isVar public var textureFormat(get, set):String;

	public function get_textureFormat():String {
		return _textureFormat;
	}

	function set_textureFormat(value:String):String {
		return _textureFormat = value;
	}
}
