package brain.uI;

import brain.facade.Facade;
import flash.display.MovieClip;
import flash.events.MouseEvent;

class UIRadioButton extends UIButton {
	static var mAllRadioButtons:Vector<UIRadioButton> = new Vector();

	var mGroup:String;

	public function new(facade:Facade, root:MovieClip, group:String) {
		super(facade, root);
		mGroup = group;
		mAllRadioButtons.push(this);
	}

	static function deselectAllInGroup(selectedButton:UIRadioButton) {
		var _loc2_:UIRadioButton;
		final __ax4_iter_162 = mAllRadioButtons;
		if (checkNullIteratee(__ax4_iter_162))
			for (_tmp_ in __ax4_iter_162) {
				_loc2_ = _tmp_;
				if (_loc2_ != selectedButton && _loc2_.group == selectedButton.group) {
					_loc2_.selected = false;
					_loc2_.enabled = _loc2_.enabled;
				}
			}
	}

	override public function destroy() {
		mAllRadioButtons.splice(mAllRadioButtons.indexOf(this), (1 : UInt));
		super.destroy();
	}

	override public function set_selected(value:Bool):Bool {
		super.selected = value;
		mRoot.buttonMode = !value;
		mRoot.tabEnabled = !value;
		if (mSelected) {
			deselectAllInGroup(this);
		}
		return value;
	}

	@:isVar public var group(get, set):String;

	public function get_group():String {
		return mGroup;
	}

	function set_group(value:String):String {
		return mGroup = value;
	}

	override function onRelease(event:MouseEvent) {
		this.selected = true;
		super.onRelease(event);
	}
}
