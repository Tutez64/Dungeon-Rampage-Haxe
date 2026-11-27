package starling.filters;

import starling.rendering.Painter;
import starling.textures.Texture;

class DropShadowFilter extends FragmentFilter {
	var _blurFilter:BlurFilter;

	var _compositeFilter:CompositeFilter;

	var _distance:Float = Math.NaN;

	var _angle:Float = Math.NaN;

	var _inner:Bool = false;

	var _knockout:Bool = false;

	public function new(distance:Float = 4, angle:Float = 0.785, color:UInt = (0 : UInt), alpha:Float = 0.5, blur:Float = 1, quality:Float = 0.5,
			inner:Bool = false, knockout:Bool = false) {
		super();
		_compositeFilter = new CompositeFilter();
		_blurFilter = new BlurFilter(blur, blur);
		_distance = distance;
		_angle = angle;
		this.color = color;
		this.alpha = alpha;
		this.quality = quality;
		this.inner = inner;
		this.knockout = knockout;
		updatePadding();
	}

	static function getMode(inner:Bool, knockout:Bool):String {
		return knockout ? (inner ? "insideKnockout" : "outsideKnockout") : (inner ? "inside" : "outside");
	}

	override public function dispose() {
		_blurFilter.dispose();
		_compositeFilter.dispose();
		super.dispose();
	}

	override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null,
			input3:Texture = null):Texture {
		var _loc8_ = _blurFilter.process(painter, helper, input0);
		var _loc7_ = _compositeFilter.process(painter, helper, input0, _loc8_);
		helper.putTexture(_loc8_);
		return _loc7_;
	}

	override public function get_numPasses():Int {
		return _blurFilter.numPasses + _compositeFilter.numPasses;
	}

	function updatePadding() {
		var _loc1_ = Math.cos(_angle) * _distance;
		var _loc2_ = Math.sin(_angle) * _distance;
		_compositeFilter.setOffsetAt(1, _loc1_, _loc2_);
		var _loc6_ = _blurFilter.padding;
		var _loc4_ = _loc6_.left;
		var _loc7_ = _loc6_.right;
		var _loc3_ = _loc6_.top;
		var _loc5_ = _loc6_.bottom;
		if (_loc1_ > 0) {
			_loc7_ += _loc1_;
		} else {
			_loc4_ -= _loc1_;
		}
		if (_loc2_ > 0) {
			_loc5_ += _loc2_;
		} else {
			_loc3_ -= _loc2_;
		}
		padding.setTo(_loc4_, _loc7_, _loc3_, _loc5_);
	}

	@:isVar public var color(get, set):UInt;

	public function get_color():UInt {
		return _compositeFilter.getColorAt(1);
	}

	function set_color(value:UInt):UInt {
		if (color != value || !_compositeFilter.getReplaceColorAt(1)) {
			_compositeFilter.setColorAt(1, value, true);
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var alpha(get, set):Float;

	public function get_alpha():Float {
		return _compositeFilter.getAlphaAt(1);
	}

	function set_alpha(value:Float):Float {
		if (alpha != value) {
			_compositeFilter.setAlphaAt(1, value);
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var distance(get, set):Float;

	public function get_distance():Float {
		return _distance;
	}

	function set_distance(value:Float):Float {
		if (_distance != value) {
			_distance = value;
			setRequiresRedraw();
			updatePadding();
		}
		return value;
	}

	@:isVar public var angle(get, set):Float;

	public function get_angle():Float {
		return _angle;
	}

	function set_angle(value:Float):Float {
		if (_angle != value) {
			_angle = value;
			setRequiresRedraw();
			updatePadding();
		}
		return value;
	}

	@:isVar public var blur(get, set):Float;

	public function get_blur():Float {
		return _blurFilter.blurX;
	}

	function set_blur(value:Float):Float {
		if (blur != value) {
			_blurFilter.blurX = _blurFilter.blurY = value;
			setRequiresRedraw();
			updatePadding();
		}
		return value;
	}

	@:isVar public var quality(get, set):Float;

	public function get_quality():Float {
		return _blurFilter.quality;
	}

	function set_quality(value:Float):Float {
		if (quality != value) {
			_blurFilter.quality = value;
			setRequiresRedraw();
			updatePadding();
		}
		return value;
	}

	@:isVar public var inner(get, set):Bool;

	public function get_inner():Bool {
		return _inner;
	}

	function set_inner(value:Bool):Bool {
		_inner = value;
		_compositeFilter.setModeAt(1, getMode(_inner, _knockout));
		_compositeFilter.setInvertAlphaAt(1, _inner);
		setRequiresRedraw();
		return value;
	}

	@:isVar public var knockout(get, set):Bool;

	public function get_knockout():Bool {
		return _knockout;
	}

	function set_knockout(value:Bool):Bool {
		_knockout = value;
		_compositeFilter.setModeAt(1, getMode(_inner, _knockout));
		setRequiresRedraw();
		return value;
	}
}
