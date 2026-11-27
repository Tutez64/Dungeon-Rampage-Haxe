package starling.filters;

import starling.rendering.Painter;
import starling.textures.Texture;

class GlowFilter extends FragmentFilter {
	var _blurFilter:BlurFilter;

	var _compositeFilter:CompositeFilter;

	var _inner:Bool = false;

	var _knockout:Bool = false;

	public function new(color:UInt = (16776960 : UInt), alpha:Float = 1, blur:Float = 1, quality:Float = 0.5, inner:Bool = false, knockout:Bool = false) {
		super();
		_compositeFilter = new CompositeFilter();
		_blurFilter = new BlurFilter(blur, blur);
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
		padding.copyFrom(_blurFilter.padding);
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
