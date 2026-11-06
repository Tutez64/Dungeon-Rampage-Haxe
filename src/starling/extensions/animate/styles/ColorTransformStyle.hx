package starling.extensions.animate.styles;

import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Mesh;
import starling.extensions.animate.Animation;
import starling.rendering.MeshEffect;
import starling.rendering.VertexDataFormat;
import starling.styles.MeshStyle;
import starling.utils.Color;
import flash.display3D.Context3D;
import starling.extensions.animate.styles.ColorTransformStyle;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;

class ColorTransformStyle extends MeshStyle {
	static inline final LUMA_R:Float = 0.299;

	static inline final LUMA_G:Float = 0.587;

	static inline final LUMA_B:Float = 0.114;

	public static final VERTEX_FORMAT:VertexDataFormat = MeshStyle.VERTEX_FORMAT.extend("colorMul0:float4, colorMul1:float4, colorMul2:float4, colorMul3:float4, colorOffset:float4");

	var _matrix:Vector<Float>;

	var maskDiscard:Bool = false;

	public function new(matrix:Vector<Float> = null) {
		super();
		_matrix = new Vector<Float>((20 : UInt), true);
		writeMatrix(matrix, _matrix);
	}

	public static function setColorTransform(mesh:Mesh, matrix:Vector<Float>) {
		var _loc3_ = false;
		if (mesh == null) {
			return;
		}
		var _loc4_ = ASCompat.reinterpretAs(mesh.style, ColorTransformStyle);
		if (isIdentity(matrix)) {
			if (_loc4_ != null) {
				if (Std.isOfType(_loc4_, MaskColorTransformStyle)) {
					mesh.style = new MaskStyle();
				} else {
					mesh.setStyle();
				}
			}
		} else {
			if (_loc4_ == null) {
				_loc3_ = Std.isOfType(mesh.style, MaskStyle);
				if (!_loc3_ && mesh.style != null && mesh.style.type != MeshStyle) {
					return;
				}
				_loc4_ = ASCompat.coerce(_loc3_ ? new MaskColorTransformStyle() : new ColorTransformStyle(), ColorTransformStyle);
				mesh.style = _loc4_;
			}
			_loc4_.colorMatrix = matrix;
		}
	}

	public static function applyTo(target:DisplayObject, matrix:Vector<Float>) {
		var _loc3_:DisplayObjectContainer = null;
		var _loc4_ = 0;
		if (Std.isOfType(target, Animation)) {
			ASCompat.reinterpretAs(target, Animation).setColorMatrix(matrix);
		} else if (Std.isOfType(target, Mesh)) {
			setColorTransform(ASCompat.reinterpretAs(target, Mesh), matrix);
		} else if (Std.isOfType(target, DisplayObjectContainer)) {
			_loc3_ = ASCompat.reinterpretAs(target, DisplayObjectContainer);
			_loc4_ = 0;
			while (_loc4_ < _loc3_.numChildren) {
				applyTo(_loc3_.getChildAt(_loc4_), matrix);
				_loc4_++;
			}
		}
	}

	public static function isIdentity(matrix:Vector<Float>):Bool {
		var _loc2_ = 0;
		if (matrix == null) {
			return true;
		}
		if (matrix.length != 20) {
			return false;
		}
		_loc2_ = 0;
		while (_loc2_ < 20) {
			if (matrix[_loc2_] != (_loc2_ % 6 == 0 ? 1 : 0)) {
				return false;
			}
			_loc2_++;
		}
		return true;
	}

	public static function matricesEqual(a:Vector<Float>, b:Vector<Float>):Bool {
		var _loc3_ = 0;
		if (a == b) {
			return true;
		}
		if (a == null) {
			return isIdentity(b);
		}
		if (b == null) {
			return isIdentity(a);
		}
		if (a.length != 20 || b.length != 20) {
			return false;
		}
		_loc3_ = 0;
		while (_loc3_ < 20) {
			if (a[_loc3_] != b[_loc3_]) {
				return false;
			}
			_loc3_++;
		}
		return true;
	}

	public static function copyMatrix(from:Vector<Float>, out:Vector<Float> = null):Vector<Float> {
		if (out == null) {
			out = new Vector<Float>((20 : UInt), true);
		}
		writeMatrix(from, out);
		return out;
	}

	public static function concat(first:Vector<Float>, second:Vector<Float>, out:Vector<Float> = null):Vector<Float> {
		var _loc5_ = 0;
		var _loc4_ = 0;
		if (out == null) {
			out = new Vector<Float>((20 : UInt), true);
		}
		if (first == null) {
			writeMatrix(second, out);
			return out;
		}
		if (second == null) {
			writeMatrix(first, out);
			return out;
		}
		_loc5_ = 0;
		while (_loc5_ < 20) {
			_loc4_ = 0;
			while (_loc4_ < 5) {
				out[_loc5_ + _loc4_] = second[_loc5_] * first[_loc4_]
					+ second[_loc5_ + 1] * first[_loc4_ + 5] + second[_loc5_ + 2] * first[_loc4_ + 10] + second[_loc5_ + 3] * first[_loc4_ + 15] +
					(_loc4_ == 4 ? second[_loc5_
						+ 4] : 0);
				_loc4_++;
			}
			_loc5_ += 5;
		}
		return out;
	}

	public static function tintMatrix(color:UInt, amount:Float, out:Vector<Float> = null):Vector<Float> {
		out = copyMatrix(null, out);
		var _loc5_ = Color.getRed(color) / 255;
		var _loc7_ = Color.getGreen(color) / 255;
		var _loc6_ = Color.getBlue(color) / 255;
		var _loc4_ = 1 - amount;
		var _loc9_ = amount * _loc5_;
		var _loc8_ = amount * _loc7_;
		var _loc10_ = amount * _loc6_;
		out[0] = _loc4_ + _loc9_ * 0.299;
		out[1] = _loc9_ * 0.587;
		out[2] = _loc9_ * 0.114;
		out[5] = _loc8_ * 0.299;
		out[6] = _loc4_ + _loc8_ * 0.587;
		out[7] = _loc8_ * 0.114;
		out[10] = _loc10_ * 0.299;
		out[11] = _loc10_ * 0.587;
		out[12] = _loc4_ + _loc10_ * 0.114;
		return out;
	}

	public static function animateTintMatrix(color:UInt, amount:Float, out:Vector<Float> = null):Vector<Float> {
		out = copyMatrix(null, out);
		var _loc4_ = 1 - amount;
		out[0] = out[6] = out[12] = _loc4_;
		out[4] = Math.fround(Color.getRed(color) * amount);
		out[9] = Math.fround(Color.getGreen(color) * amount);
		out[14] = Math.fround(Color.getBlue(color) * amount);
		return out;
	}

	public static function animateBrightnessMatrix(brightness:Float, out:Vector<Float> = null):Vector<Float> {
		out = copyMatrix(null, out);
		if (brightness > 1) {
			brightness = 1;
		} else if (brightness < -1) {
			brightness = -1;
		}
		var _loc3_ = brightness > 0 ? brightness * 255 : 0;
		out[0] = out[6] = out[12] = 1 - Math.abs(brightness);
		out[4] = out[9] = out[14] = _loc3_;
		return out;
	}

	static function writeMatrix(from:Vector<Float>, to:Vector<Float>) {
		var _loc3_ = 0;
		if (from == null) {
			_loc3_ = 0;
			while (_loc3_ < 20) {
				to[_loc3_] = _loc3_ % 6 == 0 ? 1 : 0;
				_loc3_++;
			}
		} else {
			_loc3_ = 0;
			while (_loc3_ < 20) {
				to[_loc3_] = from[_loc3_];
				_loc3_++;
			}
		}
	}

	override public function copyFrom(meshStyle:MeshStyle) {
		var _loc2_ = ASCompat.reinterpretAs(meshStyle, ColorTransformStyle);
		if (_loc2_ != null) {
			writeMatrix(_loc2_._matrix, _matrix);
		}
		super.copyFrom(meshStyle);
	}

	override public function createEffect():MeshEffect {
		return new ColorTransformEffect(maskDiscard);
	}

	override public function get_vertexFormat():VertexDataFormat {
		return VERTEX_FORMAT;
	}

	override function onTargetAssigned(target:Mesh) {
		updateVertices();
	}

	function updateVertices() {
		var _loc2_ = 0;
		if (vertexData == null) {
			return;
		}
		var _loc3_ = _matrix;
		var _loc1_ = vertexData.numVertices;
		_loc2_ = 0;
		while (_loc2_ < _loc1_) {
			vertexData.setPoint4D(_loc2_, "colorMul0", _loc3_[0], _loc3_[1], _loc3_[2], _loc3_[3]);
			vertexData.setPoint4D(_loc2_, "colorMul1", _loc3_[5], _loc3_[6], _loc3_[7], _loc3_[8]);
			vertexData.setPoint4D(_loc2_, "colorMul2", _loc3_[10], _loc3_[11], _loc3_[12], _loc3_[13]);
			vertexData.setPoint4D(_loc2_, "colorMul3", _loc3_[15], _loc3_[16], _loc3_[17], _loc3_[18]);
			vertexData.setPoint4D(_loc2_, "colorOffset", _loc3_[4] / 255, _loc3_[9] / 255, _loc3_[14] / 255, _loc3_[19] / 255);
			_loc2_++;
		}
		setVertexDataChanged();
	}

	@:isVar public var colorMatrix(get, set):Vector<Float>;

	public function get_colorMatrix():Vector<Float> {
		return _matrix;
	}

	function set_colorMatrix(value:Vector<Float>):Vector<Float> {
		if (matricesEqual(value, _matrix)) {
			return value;
		}
		writeMatrix(value, _matrix);
		updateVertices();
		return value;
	}
}

private class ColorTransformEffect extends MeshEffect {
	public static final VERTEX_FORMAT:VertexDataFormat = ColorTransformStyle.VERTEX_FORMAT;

	static final MIN_COLOR:Vector<Float> = Vector.ofArray(([0, 0, 0, 0.0001] : Array<Float>));

	static final MASK_THRESHOLD:Vector<Float> = Vector.ofArray([0.5, 0.5, 0.5, 0.5]);

	var _maskDiscard:Bool = false;

	public function new(maskDiscard:Bool = false) {
		super();
		_maskDiscard = maskDiscard;
	}

	override function get_programVariantName():UInt {
		return ((super.programVariantName : Int) | ASCompat.toInt(texture == null) << 4 | ASCompat.toInt(_maskDiscard) << 5 : UInt);
	}

	override function createProgram():Program {
		var _loc3_:String = null;
		var _loc1_:Array<ASAny> = null;
		var _loc2_ = [
			"m44 op, va0, vc0",
			"mul v1, va2, vc4",
			"mov v2, va3",
			"mov v3, va4",
			"mov v4, va5",
			"mov v5, va6",
			"mov v6, va7"
		].join("\n");
		if (texture != null) {
			_loc2_ = "mov v0, va1\n" + _loc2_;
			_loc1_ = [starling.rendering.FilterEffect.tex("ft0", "v0", 0, texture)];
			if (_maskDiscard) {
				ASCompat.ASArray.pushMultiple(_loc1_, "sub ft1, ft0.wwww, fc1", "kil ft1.x");
			}
			ASCompat.ASArray.pushMultiple(_loc1_, "mul ft0, ft0, v1               ", "max ft0, ft0, fc0              ", "div ft0.xyz, ft0.xyz, ft0.www  ",
				"m44 ft0, ft0, v2               ", "add ft0, ft0, v6               ", "sat ft0, ft0                   ", "mul ft0.xyz, ft0.xyz, ft0.www  ",
				"mov oc, ft0                    ");
			_loc3_ = _loc1_.join("\n");
		} else {
			_loc3_ = [
				"max ft0, v1, fc0               ",
				"div ft0.xyz, ft0.xyz, ft0.www  ",
				"m44 ft0, ft0, v2               ",
				"add ft0, ft0, v6               ",
				"sat ft0, ft0                   ",
				"mul ft0.xyz, ft0.xyz, ft0.www  ",
				"mov oc, ft0                    "
			].join("\n");
		}
		return Program.fromSource(_loc2_, _loc3_);
	}

	override function beforeDraw(context:Context3D) {
		super.beforeDraw(context);
		vertexFormat.setVertexBufferAt(3, vertexBuffer, "colorMul0");
		vertexFormat.setVertexBufferAt(4, vertexBuffer, "colorMul1");
		vertexFormat.setVertexBufferAt(5, vertexBuffer, "colorMul2");
		vertexFormat.setVertexBufferAt(6, vertexBuffer, "colorMul3");
		vertexFormat.setVertexBufferAt(7, vertexBuffer, "colorOffset");
		context.setProgramConstantsFromVector("fragment", 0, MIN_COLOR);
		if (_maskDiscard) {
			context.setProgramConstantsFromVector("fragment", 1, MASK_THRESHOLD);
		}
	}

	override function afterDraw(context:Context3D) {
		context.setVertexBufferAt(3, null);
		context.setVertexBufferAt(4, null);
		context.setVertexBufferAt(5, null);
		context.setVertexBufferAt(6, null);
		context.setVertexBufferAt(7, null);
		super.afterDraw(context);
	}

	override public function get_vertexFormat():VertexDataFormat {
		return VERTEX_FORMAT;
	}
}
