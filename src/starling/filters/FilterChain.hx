package starling.filters;

import starling.events.Event;
import starling.rendering.Painter;
import starling.textures.Texture;
import starling.utils.Padding;
import flash.errors.ArgumentError;

class FilterChain extends FragmentFilter {
	static var sPadding:Padding = new Padding();

	var _filters:Vector<FragmentFilter>;

	public function new(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc4_ = 0;
		var _loc3_ = 0;
		var _loc2_:FragmentFilter = null;
		super();
		_filters = new Vector<FragmentFilter>((0 : UInt));
		_loc4_ = 0;
		_loc3_ = rest.length;
		while (_loc4_ < _loc3_) {
			_loc2_ = ASCompat.dynamicAs(rest[_loc4_], FragmentFilter);
			if (_loc2_ == null) {
				throw new ArgumentError("pass only fragment filters to the constructor");
			}
			addFilterAt(_loc2_, _loc4_);
			_loc4_++;
		}
		updatePadding();
		addEventListener("enterFrame", onEnterFrame);
	}

	override public function dispose() {
		var _loc1_:FragmentFilter;
		final __ax4_iter_541 = _filters;
		if (checkNullIteratee(__ax4_iter_541))
			for (_tmp_ in __ax4_iter_541) {
				_loc1_ = _tmp_;
				_loc1_.dispose();
			}
		_filters.length = 0;
		super.dispose();
	}

	override function setRequiresRedraw() {
		updatePadding();
		super.setRequiresRedraw();
	}

	override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null,
			input3:Texture = null):Texture {
		var _loc7_:Texture = null;
		var _loc10_:Texture = null;
		var _loc8_ = 0;
		var _loc9_ = _filters.length;
		if (_loc9_ > 0) {
			_loc7_ = input0;
			_loc8_ = 0;
			while (_loc8_ < _loc9_) {
				_loc10_ = _loc7_;
				_loc7_ = _filters[_loc8_].process(painter, helper, _loc10_);
				if (_loc8_ != 0) {
					helper.putTexture(_loc10_);
				}
				_loc8_++;
			}
			return _loc7_;
		}
		return super.process(painter, helper, input0, input1, input2, input3);
	}

	override public function get_numPasses():Int {
		var _loc1_ = 0;
		var _loc3_ = 0;
		var _loc2_ = _filters.length;
		_loc1_ = 0;
		while (_loc1_ < _loc2_) {
			_loc3_ += _filters[_loc1_].numPasses;
			_loc1_++;
		}
		return if (_loc3_ != 0) _loc3_ else 1;
	}

	public function getFilterAt(index:Int):FragmentFilter {
		if (index < 0) {
			index += numFilters;
		}
		return _filters[index];
	}

	public function addFilter(filter:FragmentFilter) {
		addFilterAt(filter, _filters.length);
	}

	public function addFilterAt(filter:FragmentFilter, index:Int) {
		_filters.insertAt(index, filter);
		filter.addEventListener("change", (cast setRequiresRedraw));
		setRequiresRedraw();
	}

	public function removeFilter(filter:FragmentFilter, dispose:Bool = false):FragmentFilter {
		var _loc3_ = getFilterIndex(filter);
		if (_loc3_ != -1) {
			removeFilterAt(_loc3_, dispose);
		}
		return filter;
	}

	public function removeFilterAt(index:Int, dispose:Bool = false):FragmentFilter {
		var _loc3_ = _filters.removeAt(index);
		_loc3_.removeEventListener("change", (cast setRequiresRedraw));
		if (dispose) {
			_loc3_.dispose();
		}
		setRequiresRedraw();
		return _loc3_;
	}

	public function getFilterIndex(filter:FragmentFilter):Int {
		return _filters.indexOf(filter);
	}

	function updatePadding() {
		var _loc2_:Padding = null;
		sPadding.setTo();
		var _loc1_:FragmentFilter;
		final __ax4_iter_542 = _filters;
		if (checkNullIteratee(__ax4_iter_542))
			for (_tmp_ in __ax4_iter_542) {
				_loc1_ = _tmp_;
				_loc2_ = _loc1_.padding;
				if (_loc2_.left > sPadding.left) {
					sPadding.left = _loc2_.left;
				}
				if (_loc2_.right > sPadding.right) {
					sPadding.right = _loc2_.right;
				}
				if (_loc2_.top > sPadding.top) {
					sPadding.top = _loc2_.top;
				}
				if (_loc2_.bottom > sPadding.bottom) {
					sPadding.bottom = _loc2_.bottom;
				}
			}
		this.padding.copyFrom(sPadding);
	}

	function onEnterFrame(event:Event) {
		var _loc2_ = 0;
		var _loc3_ = _filters.length;
		_loc2_ = 0;
		while (_loc2_ < _loc3_) {
			_filters[_loc2_].dispatchEvent(event);
			_loc2_++;
		}
	}

	@:isVar public var numFilters(get, never):Int;

	public function get_numFilters():Int {
		return _filters.length;
	}
}
