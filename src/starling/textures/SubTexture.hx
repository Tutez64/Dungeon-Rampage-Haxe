package starling.textures;

import flash.display3D.textures.TextureBase;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.system.Capabilities;

/*use*/ /*namespace*/ /*starling_internal*/ class SubTexture extends Texture {
	static inline final E:Float = 0.000001;

	var _parent:Texture;

	var _ownsParent:Bool = false;

	var _region:Rectangle;

	var _frame:Rectangle;

	var _rotated:Bool = false;

	var _width:Float = Math.NaN;

	var _height:Float = Math.NaN;

	var _scale:Float = Math.NaN;

	var _transformationMatrix:Matrix;

	var _transformationMatrixToRoot:Matrix;

	public function new(parent:Texture, region:Rectangle = null, ownsParent:Bool = false, frame:Rectangle = null, rotated:Bool = false,
			scaleModifier:Float = 1) {
		super();
		/*starling_internal::*/ setTo(parent, region, ownsParent, frame, rotated, scaleModifier);
	}

	/*starling_internal*/
	public function setTo(parent:Texture, region:Rectangle = null, ownsParent:Bool = false, frame:Rectangle = null, rotated:Bool = false,
			scaleModifier:Float = 1) {
		if (_region == null) {
			_region = new Rectangle();
		}
		if (region != null) {
			_region.copyFrom(region);
		} else {
			_region.setTo(0, 0, parent.width, parent.height);
		}
		if (frame != null) {
			if (_frame != null) {
				_frame.copyFrom(frame);
			} else {
				_frame = frame.clone();
			}
		} else {
			_frame = null;
		}
		_parent = parent;
		_ownsParent = ownsParent;
		_rotated = rotated;
		_width = (rotated ? _region.height : _region.width) / scaleModifier;
		_height = (rotated ? _region.width : _region.height) / scaleModifier;
		_scale = _parent.scale * scaleModifier;
		if (Capabilities.isDebugger
			&& _frame != null
			&& (_frame.x > 0 || _frame.y > 0 || _frame.right + 0.000001 < _width || _frame.bottom + 0.000001 < _height)) {}
		updateMatrices();
	}

	function updateMatrices() {
		if (_transformationMatrix != null) {
			_transformationMatrix.identity();
		} else {
			_transformationMatrix = new Matrix();
		}
		if (_transformationMatrixToRoot != null) {
			_transformationMatrixToRoot.identity();
		} else {
			_transformationMatrixToRoot = new Matrix();
		}
		if (_rotated) {
			_transformationMatrix.translate(0, -1);
			_transformationMatrix.rotate(3.141592653589793 / 2);
		}
		_transformationMatrix.scale(_region.width / _parent.width, _region.height / _parent.height);
		_transformationMatrix.translate(_region.x / _parent.width, _region.y / _parent.height);
		var _loc1_ = this;
		while (_loc1_ != null) {
			_transformationMatrixToRoot.concat(_loc1_._transformationMatrix);
			_loc1_ = ASCompat.reinterpretAs(_loc1_.parent, SubTexture);
		}
	}

	override public function dispose() {
		if (_ownsParent) {
			_parent.dispose();
		}
		super.dispose();
	}

	@:isVar public var parent(get, never):Texture;

	public function get_parent():Texture {
		return _parent;
	}

	@:isVar public var ownsParent(get, never):Bool;

	public function get_ownsParent():Bool {
		return _ownsParent;
	}

	@:isVar public var rotated(get, never):Bool;

	public function get_rotated():Bool {
		return _rotated;
	}

	@:isVar public var region(get, never):Rectangle;

	public function get_region():Rectangle {
		return _region;
	}

	override public function get_transformationMatrix():Matrix {
		return _transformationMatrix;
	}

	override public function get_transformationMatrixToRoot():Matrix {
		return _transformationMatrixToRoot;
	}

	override public function get_base():TextureBase {
		return _parent.base;
	}

	override public function get_root():ConcreteTexture {
		return _parent.root;
	}

	override public function get_format():String {
		return _parent.format;
	}

	override public function get_width():Float {
		return _width;
	}

	override public function get_height():Float {
		return _height;
	}

	override public function get_nativeWidth():Float {
		return _width * _scale;
	}

	override public function get_nativeHeight():Float {
		return _height * _scale;
	}

	override public function get_mipMapping():Bool {
		return _parent.mipMapping;
	}

	override public function get_premultipliedAlpha():Bool {
		return _parent.premultipliedAlpha;
	}

	override public function get_scale():Float {
		return _scale;
	}

	override public function get_frame():Rectangle {
		return _frame;
	}
}
