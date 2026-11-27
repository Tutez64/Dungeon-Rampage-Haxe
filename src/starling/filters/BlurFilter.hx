package starling.filters;

import starling.core.Starling;
import starling.rendering.FilterEffect;
import starling.rendering.Painter;
import starling.textures.Texture;
import starling.utils.MathUtil;
import flash.display3D.Context3D;
import starling.rendering.FilterEffect;
import starling.rendering.Program;

class BlurFilter extends FragmentFilter {
	var _blurX:Float = Math.NaN;

	var _blurY:Float = Math.NaN;

	var _quality:Float = Math.NaN;

	public function new(blurX:Float = 1, blurY:Float = 1, resolution:Float = 1) {
		super();
		_blurX = Math.abs(blurX);
		_blurY = Math.abs(blurY);
		_quality = 1;
		this.resolution = resolution;
		this.maintainResolutionAcrossPasses = true;
	}

	static function getNumPasses(blur:Float):Int {
		var _loc2_ = 1;
		while (blur > 1) {
			_loc2_ += 1;
			blur /= 2;
		}
		return _loc2_;
	}

	override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null,
			input3:Texture = null):Texture {
		var _loc11_:Texture = null;
		var _loc9_ = ASCompat.reinterpretAs(this.effect, BlurEffect);
		if (_blurX == 0 && _blurY == 0) {
			_loc9_.strength = 0;
			return super.process(painter, helper, input0);
		}
		var _loc7_ = input0;
		var _loc8_ = totalBlurX;
		var _loc10_ = totalBlurY;
		_loc9_.quality = _quality;
		_loc9_.direction = "horizontal";
		while (_loc8_ > 0) {
			_loc9_.strength = _loc8_;
			_loc11_ = _loc7_;
			_loc7_ = super.process(painter, helper, _loc11_);
			if (_loc11_ != input0) {
				helper.putTexture(_loc11_);
			}
			if (_loc8_ <= 1) {
				break;
			}
			_loc8_ /= 2;
		}
		_loc9_.direction = "vertical";
		while (_loc10_ > 0) {
			_loc9_.strength = _loc10_;
			_loc11_ = _loc7_;
			_loc7_ = super.process(painter, helper, _loc11_);
			if (_loc11_ != input0) {
				helper.putTexture(_loc11_);
			}
			if (_loc10_ <= 1) {
				break;
			}
			_loc10_ /= 2;
		}
		return _loc7_;
	}

	override function createEffect():FilterEffect {
		return new BlurEffect();
	}

	override public function set_resolution(value:Float):Float {
		super.resolution = value;
		updatePadding();
		return value;
	}

	function updatePadding() {
		var _loc1_ = ASCompat.floatAsBool(_blurX) ? (totalBlurX * 3 + 2) / (resolution * _quality) : 0;
		var _loc2_ = ASCompat.floatAsBool(_blurY) ? (totalBlurY * 3 + 2) / (resolution * _quality) : 0;
		padding.setTo(_loc1_, _loc1_, _loc2_, _loc2_);
	}

	override public function get_numPasses():Int {
		if (_blurX == 0 && _blurY == 0) {
			return 1;
		}
		return getNumPasses(totalBlurX) + getNumPasses(totalBlurY);
	}

	@:isVar var totalBlurX(get, never):Float;

	function get_totalBlurX():Float {
		return _blurX * Starling.contentScaleFactor;
	}

	@:isVar var totalBlurY(get, never):Float;

	function get_totalBlurY():Float {
		return _blurY * Starling.contentScaleFactor;
	}

	@:isVar public var blurX(get, set):Float;

	public function get_blurX():Float {
		return _blurX;
	}

	function set_blurX(value:Float):Float {
		if (_blurX != value) {
			_blurX = Math.abs(value);
			updatePadding();
		}
		return value;
	}

	@:isVar public var blurY(get, set):Float;

	public function get_blurY():Float {
		return _blurY;
	}

	function set_blurY(value:Float):Float {
		if (_blurY != value) {
			_blurY = Math.abs(value);
			updatePadding();
		}
		return value;
	}

	@:isVar public var quality(get, set):Float;

	public function get_quality():Float {
		return _quality;
	}

	function set_quality(value:Float):Float {
		if (_quality != value) {
			_quality = MathUtil.clamp(value, 0.1, 1);
			updatePadding();
		}
		return value;
	}
}

private class BlurEffect extends FilterEffect {
	public static inline final HORIZONTAL = "horizontal";

	public static inline final VERTICAL = "vertical";

	static final sTmpWeights:Vector<Float> = Vector.ofArray(([0, 0, 0, 0, 0] : Array<Float>));

	static final sWeights:Vector<Float> = Vector.ofArray(([0, 0, 0, 0] : Array<Float>));

	static final sOffsets:Vector<Float> = Vector.ofArray(([0, 0, 0, 0] : Array<Float>));

	var _strength:Float = Math.NaN;

	var _direction:String;

	var _quality:Float = Math.NaN;

	public function new() {
		super();
		_strength = 0;
		_direction = "horizontal";
		_quality = 1;
	}

	override function createProgram():Program {
		if (_strength == 0) {
			return super.createProgram();
		}
		var _loc1_ = [
			"m44 op, va0, vc0      ",
			"mov v0, va1           ",
			"add v1,  va1, vc4.xyww",
			"sub v2,  va1, vc4.xyww",
			"add v3,  va1, vc4.zwxx",
			"sub v4,  va1, vc4.zwxx"
		].join("\n");
		var _loc2_ = [
			FilterEffect.tex("ft0", "v0", 0, texture),
			"mul ft5, ft0, fc0.xxxx       ",
			FilterEffect.tex("ft1", "v1", 0, texture),
			"mul ft1, ft1, fc0.yyyy       ",
			"add ft5, ft5, ft1            ",
			FilterEffect.tex("ft2", "v2", 0, texture),
			"mul ft2, ft2, fc0.yyyy       ",
			"add ft5, ft5, ft2            ",
			FilterEffect.tex("ft3", "v3", 0, texture),
			"mul ft3, ft3, fc0.zzzz       ",
			"add ft5, ft5, ft3            ",
			FilterEffect.tex("ft4", "v4", 0, texture),
			"mul ft4, ft4, fc0.zzzz       ",
			"add  oc, ft5, ft4            "
		].join("\n");
		return Program.fromSource(_loc1_, _loc2_);
	}

	override function beforeDraw(context:Context3D) {
		super.beforeDraw(context);
		if (ASCompat.floatAsBool(_strength)) {
			updateParameters();
			context.setProgramConstantsFromVector("vertex", 4, sOffsets);
			context.setProgramConstantsFromVector("fragment", 0, sWeights);
		}
	}

	function updateParameters() {
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc1_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc5_ = 0;
		var _loc2_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc8_ = 1 / (_direction == "horizontal" ? texture.root.nativeWidth : texture.root.nativeHeight);
		if (_strength <= 1) {
			_loc1_ = _strength * 2;
			_loc9_ = 2 * _loc1_ * _loc1_;
			_loc3_ = 1 / Math.sqrt(_loc9_ * 3.141592653589793);
			_loc5_ = 0;
			while (_loc5_ < 5) {
				sTmpWeights[_loc5_] = _loc3_ * Math.exp(-_loc5_ * _loc5_ / _loc9_);
				_loc5_++;
			}
			sWeights[0] = sTmpWeights[0];
			sWeights[1] = sTmpWeights[1] + sTmpWeights[2];
			sWeights[2] = sTmpWeights[3] + sTmpWeights[4];
			_loc2_ = sWeights[0] + 2 * sWeights[1] + 2 * sWeights[2];
			_loc4_ = 1 / _loc2_;
			sWeights[0] *= _loc4_;
			sWeights[1] *= _loc4_;
			sWeights[2] *= _loc4_;
			_loc7_ = (sTmpWeights[1] + 2 * sTmpWeights[2]) / sWeights[1];
			_loc6_ = (3 * sTmpWeights[3] + 4 * sTmpWeights[4]) / sWeights[2];
		} else {
			sWeights[0] = 0.29412;
			sWeights[1] = 0.23529;
			sWeights[2] = 0.11765;
			_loc7_ = _strength * 1.3;
			_loc6_ = _strength * 2.3;
		}
		if (_direction == "horizontal") {
			sOffsets[0] = _loc7_ * _loc8_ / _quality;
			sOffsets[1] = 0;
			sOffsets[2] = _loc6_ * _loc8_ / _quality;
			sOffsets[3] = 0;
		} else {
			sOffsets[0] = 0;
			sOffsets[1] = _loc7_ * _loc8_ / _quality;
			sOffsets[2] = 0;
			sOffsets[3] = _loc6_ * _loc8_ / _quality;
		}
	}

	override function get_programVariantName():UInt {
		return ((super.programVariantName : Int) | (ASCompat.floatAsBool(_strength) ? 16 : 0) : UInt);
	}

	@:isVar public var direction(get, set):String;

	public function get_direction():String {
		return _direction;
	}

	function set_direction(value:String):String {
		return _direction = value;
	}

	@:isVar public var strength(get, set):Float;

	public function get_strength():Float {
		return _strength;
	}

	function set_strength(value:Float):Float {
		return _strength = value;
	}

	@:isVar public var quality(get, set):Float;

	public function get_quality():Float {
		return _quality;
	}

	function set_quality(value:Float):Float {
		return _quality = value;
	}
}
