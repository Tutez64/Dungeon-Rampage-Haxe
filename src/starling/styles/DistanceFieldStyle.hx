package starling.styles;

import flash.geom.Matrix;
import starling.core.Starling;
import starling.display.Mesh;
import starling.rendering.MeshEffect;
import starling.rendering.RenderState;
import starling.rendering.VertexData;
import starling.rendering.VertexDataFormat;
import starling.utils.Color;
import starling.utils.MathUtil;
import flash.display3D.Context3D;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;
import starling.styles.DistanceFieldStyle;
import starling.utils.StringUtil;

class DistanceFieldStyle extends MeshStyle {
	public static inline final MODE_BASIC = "basic";

	public static inline final MODE_OUTLINE = "outline";

	public static inline final MODE_GLOW = "glow";

	public static inline final MODE_SHADOW = "shadow";

	public static final VERTEX_FORMAT:VertexDataFormat = MeshStyle.VERTEX_FORMAT.extend("basic:bytes4, extended:bytes4, outerColor:bytes4");

	var _mode:String;

	var _multiChannel:Bool = false;

	var _threshold:Float = Math.NaN;

	var _alpha:Float = Math.NaN;

	var _softness:Float = Math.NaN;

	var _outerThreshold:Float = Math.NaN;

	var _outerAlphaEnd:Float = Math.NaN;

	var _shadowOffsetX:Float = Math.NaN;

	var _shadowOffsetY:Float = Math.NaN;

	var _outerColor:UInt = 0;

	var _outerAlphaStart:Float = Math.NaN;

	public function new(softness:Float = 0.125, threshold:Float = 0.5) {
		super();
		_mode = "basic";
		_threshold = threshold;
		_softness = softness;
		_alpha = 1;
		_outerThreshold = _outerAlphaEnd = 0;
		_shadowOffsetX = _shadowOffsetY = 0;
		_outerColor = (0 : UInt);
		_outerAlphaStart = 0;
	}

	override public function copyFrom(meshStyle:MeshStyle) {
		var _loc2_ = ASCompat.reinterpretAs(meshStyle, DistanceFieldStyle);
		if (_loc2_ != null) {
			_mode = _loc2_._mode;
			_multiChannel = _loc2_._multiChannel;
			_threshold = _loc2_._threshold;
			_softness = _loc2_._softness;
			_alpha = _loc2_._alpha;
			_outerThreshold = _loc2_._outerThreshold;
			_outerAlphaEnd = _loc2_._outerAlphaEnd;
			_shadowOffsetX = _loc2_._shadowOffsetX;
			_shadowOffsetY = _loc2_._shadowOffsetY;
			_outerColor = _loc2_._outerColor;
			_outerAlphaStart = _loc2_._outerAlphaStart;
		}
		super.copyFrom(meshStyle);
	}

	override public function createEffect():MeshEffect {
		return new DistanceFieldEffect();
	}

	override public function get_vertexFormat():VertexDataFormat {
		return VERTEX_FORMAT;
	}

	override function onTargetAssigned(target:Mesh) {
		updateVertices();
	}

	function updateVertices() {
		var _loc7_ = 0;
		if (vertexData == null) {
			return;
		}
		var _loc1_ = vertexData.numVertices;
		var _loc4_ = 8;
		var _loc3_ = 8;
		var _loc5_ = (_shadowOffsetX + _loc3_) / (2 * _loc3_);
		var _loc6_ = (_shadowOffsetY + _loc3_) / (2 * _loc3_);
		var _loc8_ = (ASCompat.floatToInt(_threshold * 255) | ASCompat.floatToInt(_alpha * 255) << 8 | ASCompat.floatToInt(_softness / 2 * 255) << 16 | ASCompat.floatToInt(1 / _loc4_ * 255) << 24:UInt);
		var _loc9_ = (ASCompat.floatToInt(_outerThreshold * 255) | ASCompat.floatToInt(_outerAlphaEnd * 255) << 8 | ASCompat.floatToInt(_loc5_ * 255) << 16 | ASCompat.floatToInt(_loc6_ * 255) << 24:UInt);
		var _loc2_ = (Color.getRed(_outerColor) | Color.getGreen(_outerColor) << 8 | Color.getBlue(_outerColor) << 16 | ASCompat.floatToInt(_outerAlphaStart * 255) << 24:UInt);
		_loc7_ = 0;
		while (_loc7_ < _loc1_) {
			vertexData.setUnsignedInt(_loc7_, "basic", _loc8_);
			vertexData.setUnsignedInt(_loc7_, "extended", _loc9_);
			vertexData.setUnsignedInt(_loc7_, "outerColor", _loc2_);
			_loc7_++;
		}
		setVertexDataChanged();
	}

	override public function batchVertexData(targetStyle:MeshStyle, targetVertexID:Int = 0, matrix:Matrix = null, vertexID:Int = 0, numVertices:Int = -1) {
		var _loc8_ = Math.NaN;
		var _loc12_:VertexData = null;
		var _loc6_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc9_ = 0;
		var _loc10_ = (0 : UInt);
		var _loc14_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc7_ = (0 : UInt);
		super.batchVertexData(targetStyle, targetVertexID, matrix, vertexID, numVertices);
		if (matrix != null) {
			_loc8_ = Math.sqrt(matrix.a * matrix.a + matrix.c * matrix.c);
			if (!MathUtil.isEquivalent(_loc8_, 1, 0.01)) {
				_loc12_ = ASCompat.reinterpretAs(targetStyle, DistanceFieldStyle).vertexData;
				_loc6_ = 8;
				_loc13_ = _loc6_ / 255;
				if (numVertices < 0) {
					numVertices = vertexData.numVertices - vertexID;
				}
				_loc9_ = 0;
				while (_loc9_ < numVertices) {
					_loc10_ = vertexData.getUnsignedInt(vertexID + _loc9_, "basic");
					_loc14_ = ((_loc10_ : Int) >> 24 & 0xFF) / 255 * _loc6_;
					_loc11_ = MathUtil.clamp(_loc14_ * _loc8_, _loc13_, _loc6_);
					_loc7_ = ((_loc10_ : Int) & 0xFFFFFF | ASCompat.floatToInt(_loc11_ / _loc6_ * 255) << 24 : UInt);
					_loc12_.setUnsignedInt(targetVertexID + _loc9_, "basic", _loc7_);
					_loc9_++;
				}
			}
		}
	}

	override public function updateEffect(effect:MeshEffect, state:RenderState) {
		var _loc4_:Matrix = null;
		var _loc3_ = Math.NaN;
		var _loc5_ = ASCompat.reinterpretAs(effect, DistanceFieldEffect);
		_loc5_.mode = _mode;
		_loc5_.multiChannel = _multiChannel;
		if (state.is3D) {
			_loc5_.scale = 1;
		} else {
			_loc4_ = state.modelviewMatrix;
			_loc3_ = Math.sqrt(_loc4_.a * _loc4_.a + _loc4_.c * _loc4_.c);
			_loc5_.scale = _loc3_ * Starling.contentScaleFactor;
		}
		super.updateEffect(effect, state);
	}

	override public function canBatchWith(meshStyle:MeshStyle):Bool {
		var _loc2_ = ASCompat.reinterpretAs(meshStyle, DistanceFieldStyle);
		if (_loc2_ != null && super.canBatchWith(meshStyle)) {
			return _loc2_._mode == _mode && _loc2_._multiChannel == _multiChannel;
		}
		return false;
	}

	public function setupBasic() {
		_mode = "basic";
		setRequiresRedraw();
	}

	public function setupOutline(width:Float = 0.25, color:UInt = (0 : UInt), alpha:Float = 1) {
		_mode = "outline";
		_outerThreshold = MathUtil.clamp(_threshold - width, 0, _threshold);
		_outerColor = color;
		_outerAlphaStart = _outerAlphaEnd = MathUtil.clamp(alpha, 0, 1);
		_shadowOffsetX = _shadowOffsetY = 0;
		updateVertices();
	}

	public function setupGlow(blur:Float = 0.2, color:UInt = (16776960 : UInt), alpha:Float = 0.5) {
		_mode = "glow";
		_outerThreshold = MathUtil.clamp(_threshold - blur, 0, _threshold);
		_outerColor = color;
		_outerAlphaStart = MathUtil.clamp(alpha, 0, 1);
		_outerAlphaEnd = 0;
		_shadowOffsetX = _shadowOffsetY = 0;
		updateVertices();
	}

	public function setupDropShadow(blur:Float = 0.2, offsetX:Float = 2, offsetY:Float = 2, color:UInt = (0 : UInt), alpha:Float = 0.5) {
		var _loc6_ = Math.NaN;
		_loc6_ = 8;
		_mode = "shadow";
		_outerThreshold = MathUtil.clamp(_threshold - blur, 0, _threshold);
		_outerColor = color;
		_outerAlphaStart = MathUtil.clamp(alpha, 0, 1);
		_outerAlphaEnd = 0;
		_shadowOffsetX = MathUtil.clamp(offsetX, -8, 8);
		_shadowOffsetY = MathUtil.clamp(offsetY, -8, 8);
		updateVertices();
	}

	@:isVar public var mode(get, set):String;

	public function get_mode():String {
		return _mode;
	}

	function set_mode(value:String):String {
		_mode = value;
		setRequiresRedraw();
		return value;
	}

	@:isVar public var multiChannel(get, set):Bool;

	public function get_multiChannel():Bool {
		return _multiChannel;
	}

	function set_multiChannel(value:Bool):Bool {
		_multiChannel = value;
		setRequiresRedraw();
		return value;
	}

	@:isVar public var threshold(get, set):Float;

	public function get_threshold():Float {
		return _threshold;
	}

	function set_threshold(value:Float):Float {
		value = MathUtil.clamp(value, 0, 1);
		if (_threshold != value) {
			_threshold = value;
			updateVertices();
		}
		return value;
	}

	@:isVar public var softness(get, set):Float;

	public function get_softness():Float {
		return _softness;
	}

	function set_softness(value:Float):Float {
		value = MathUtil.clamp(value, 0, 1);
		if (_softness != value) {
			_softness = value;
			updateVertices();
		}
		return value;
	}

	@:isVar public var alpha(get, set):Float;

	public function get_alpha():Float {
		return _alpha;
	}

	function set_alpha(value:Float):Float {
		value = MathUtil.clamp(value, 0, 1);
		if (_alpha != value) {
			_alpha = value;
			updateVertices();
		}
		return value;
	}

	@:isVar public var outerThreshold(get, set):Float;

	public function get_outerThreshold():Float {
		return _outerThreshold;
	}

	function set_outerThreshold(value:Float):Float {
		value = MathUtil.clamp(value, 0, 1);
		if (_outerThreshold != value) {
			_outerThreshold = value;
			updateVertices();
		}
		return value;
	}

	@:isVar public var outerAlphaStart(get, set):Float;

	public function get_outerAlphaStart():Float {
		return _outerAlphaStart;
	}

	function set_outerAlphaStart(value:Float):Float {
		value = MathUtil.clamp(value, 0, 1);
		if (_outerAlphaStart != value) {
			_outerAlphaStart = value;
			updateVertices();
		}
		return value;
	}

	@:isVar public var outerAlphaEnd(get, set):Float;

	public function get_outerAlphaEnd():Float {
		return _outerAlphaEnd;
	}

	function set_outerAlphaEnd(value:Float):Float {
		value = MathUtil.clamp(value, 0, 1);
		if (_outerAlphaEnd != value) {
			_outerAlphaEnd = value;
			updateVertices();
		}
		return value;
	}

	@:isVar public var outerColor(get, set):UInt;

	public function get_outerColor():UInt {
		return _outerColor;
	}

	function set_outerColor(value:UInt):UInt {
		if (_outerColor != value) {
			_outerColor = value;
			updateVertices();
		}
		return value;
	}

	@:isVar public var shadowOffsetX(get, set):Float;

	public function get_shadowOffsetX():Float {
		return _shadowOffsetX;
	}

	function set_shadowOffsetX(value:Float):Float {
		var _loc2_ = Math.NaN;
		_loc2_ = 8;
		value = MathUtil.clamp(value, -8, 8);
		if (_shadowOffsetX != value) {
			_shadowOffsetX = value;
			updateVertices();
		}
		return value;
	}

	@:isVar public var shadowOffsetY(get, set):Float;

	public function get_shadowOffsetY():Float {
		return _shadowOffsetY;
	}

	function set_shadowOffsetY(value:Float):Float {
		var _loc2_ = Math.NaN;
		_loc2_ = 8;
		value = MathUtil.clamp(value, -8, 8);
		if (_shadowOffsetY != value) {
			_shadowOffsetY = value;
			updateVertices();
		}
		return value;
	}
}

private class DistanceFieldEffect extends MeshEffect {
	public static inline final MAX_OUTER_OFFSET = 8;

	public static inline final MAX_SCALE = 8;

	public static final VERTEX_FORMAT:VertexDataFormat = DistanceFieldStyle.VERTEX_FORMAT;

	static final sVector:Vector<Float> = new Vector((4 : UInt), true);

	var _mode:String;

	var _scale:Float = Math.NaN;

	var _multiChannel:Bool = false;

	public function new() {
		super();
		_scale = 1;
		_mode = "basic";
	}

	static function step(inOutReg:String, minReg:String, maxReg:String, tmpReg:String = "ft6"):String {
		return [
			StringUtil.format("sub {0}, {1}, {2}", tmpReg, maxReg, minReg),
			StringUtil.format("rcp {0}, {0}", tmpReg),
			StringUtil.format("sub {0}, {0}, {1}", inOutReg, minReg),
			StringUtil.format("mul {0}, {0}, {1}", inOutReg, tmpReg),
			StringUtil.format("sat {0}, {0}", inOutReg)
		].join("\n");
	}

	static function median(inOutReg:String):String {
		return [
			StringUtil.format("max {0}.xyz, {0}.xxy, {0}.yzz", inOutReg),
			StringUtil.format("min {0}.x, {0}.x, {0}.y", inOutReg),
			StringUtil.format("min {0}, {0}.xxxx, {0}.zzzz", inOutReg)
		].join("\n");
	}

	override function createProgram():Program {
		var _temp_18:Vector<String>;
		var _loc1_ = false;
		var _loc4_ = false;
		var _loc2_:Vector<String> = /*undefined*/ null;
		var _loc3_:Vector<String> = /*undefined*/ null;
		if (texture != null) {
			_loc1_ = _mode == "basic";
			_loc4_ = _mode == "shadow";
			_loc2_ = Vector.ofArray([
				"m44 op, va0, vc0",
				"mov v0, va1",
				"mul vt4, va3.yyyy, vc4",
				"mul v1, va2, vt4",
				"mov v3, va3",
				"mov v4, va4",
				"mov v5, va5",
				"mul vt4.w, vc4.w, va2.w",
				"mul v4.y, va4.y, vt4.w",
				"mul v5.w, va5.w, vt4.w",
				"mul vt0.x, va3.w, vc5.z",
				"mul vt0.x, vt0.x, vc5.w",
				"div vt0.x, va3.z, vt0.x",
				"mov vt1, vc4",
				"sub vt1.x, va3.x, vt0.x",
				"add vt1.y, va3.x, vt0.x"
			]);
			if (!_loc1_) {
				ASCompat.ASArray.pushMultiple(_loc2_, "sub vt1.z, va4.x, vt0.x", "add vt1.w, va4.x, vt0.x");
			}
			_loc2_.push("sat v6, vt1");
			if (_loc4_) {
				ASCompat.ASArray.pushMultiple(_loc2_, "mul vt0.xy, va4.zw, vc6.zz", "sub vt0.xy, vt0.xy, vc6.yy", "mul vt0.xy, vt0.xy, vc5.xy",
					"sub v7, va1, vt0.xyxy", "sub vt0.z, va3.x, va4.x", "add v7.z, va3.x, vt0.z");
			}
			_temp_18 = Vector.ofArray([
				starling.rendering.FilterEffect.tex("ft0", "v0", 0, texture),
				_multiChannel ? median("ft0") : "mov ft0, ft0.xxxx",
				"mov ft1, ft0",
				step("ft1.w", "v6.x", "v6.y"),
				"mov ft3, ft1",
				"mul ft1, v1, ft1.wwww"
			]);
			_loc3_ = Vector.ofArray([
				starling.rendering.FilterEffect.tex("ft0", "v0", 0, texture),
				_multiChannel ? median("ft0") : "mov ft0, ft0.xxxx",
				"mov ft1, ft0",
				step("ft1.w", "v6.x", "v6.y"),
				"mov ft3, ft1",
				"mul ft1, v1, ft1.wwww"
			]);
			if (_loc4_) {
				ASCompat.ASArray.pushMultiple(_loc3_, starling.rendering.FilterEffect.tex("ft0", "v7", 0, texture),
					_multiChannel ? median("ft0") : "mov ft0, ft0.xxxx", "mov ft5.x, v7.z");
			} else if (!_loc1_) {
				_loc3_.push("mov ft5.x, v6.x");
			}
			if (!_loc1_) {
				ASCompat.ASArray.pushMultiple(_loc3_, "mov ft2, ft0", step("ft2.w", "v6.z", "v6.w"), "sub ft2.w, ft2.w, ft3.w", "sat ft2.w, ft2.w",
					"mov ft4, ft0", step("ft4.w", "v6.z", "ft5.x"), "sub ft6.w, v5.w, v4.y", "mul ft4.w, ft4.w, ft6.w", "add ft4.w, ft4.w, v4.y",
					"mul ft2.w, ft2.w, ft4.w", "mul ft2.xyz, v5.xyz, ft2.www");
			}
			if (_loc1_) {
				_loc3_.push("mov oc, ft1");
			} else {
				_loc3_.push("add oc, ft1, ft2");
			}
			return Program.fromSource(_loc2_.join("\n"), _loc3_.join("\n"));
		}
		return super.createProgram();
	}

	override function beforeDraw(context:Context3D) {
		var _loc3_ = Math.NaN;
		var _loc2_ = Math.NaN;
		super.beforeDraw(context);
		if (texture != null) {
			vertexFormat.setVertexBufferAt(3, vertexBuffer, "basic");
			vertexFormat.setVertexBufferAt(4, vertexBuffer, "extended");
			vertexFormat.setVertexBufferAt(5, vertexBuffer, "outerColor");
			_loc3_ = 1 / (texture.root.nativeWidth / texture.scale);
			_loc2_ = 1 / (texture.root.nativeHeight / texture.scale);
			sVector[0] = 8 * _loc3_;
			sVector[1] = 8 * _loc2_;
			sVector[2] = 8;
			sVector[3] = _scale;
			context.setProgramConstantsFromVector("vertex", 5, sVector);
			sVector[0] = 0;
			sVector[1] = 1;
			sVector[2] = 2;
			context.setProgramConstantsFromVector("vertex", 6, sVector);
		}
	}

	override function afterDraw(context:Context3D) {
		if (texture != null) {
			context.setVertexBufferAt(3, null);
			context.setVertexBufferAt(4, null);
			context.setVertexBufferAt(5, null);
		}
		super.afterDraw(context);
	}

	override public function get_vertexFormat():VertexDataFormat {
		return VERTEX_FORMAT;
	}

	override function get_programVariantName():UInt {
		var _loc1_ = (0 : UInt);
		switch (_mode) {
			case "shadow":
				_loc1_ = (3 : UInt);

			case "glow":
				_loc1_ = (2 : UInt);

			case "outline":
				_loc1_ = (1 : UInt);

			default:
				_loc1_ = (0 : UInt);
		}
		if (_multiChannel) {
			_loc1_ = ((_loc1_ | (4 : UInt) : UInt) : UInt);
		}
		return ((super.programVariantName : Int) | (_loc1_ : Int) << 8 : UInt);
	}

	@:isVar public var scale(get, set):Float;

	public function get_scale():Float {
		return _scale;
	}

	function set_scale(value:Float):Float {
		return _scale = value;
	}

	@:isVar public var mode(get, set):String;

	public function get_mode():String {
		return _mode;
	}

	function set_mode(value:String):String {
		return _mode = value;
	}

	@:isVar public var multiChannel(get, set):Bool;

	public function get_multiChannel():Bool {
		return _multiChannel;
	}

	function set_multiChannel(value:Bool):Bool {
		return _multiChannel = value;
	}
}
