package brain.uI;

import brain.facade.Facade;
import flash.display.MovieClip;
import flash.events.MouseEvent;

class UIToggleButton extends UIButton {
	var m_id:UInt = 0;

	var selectionChangeCallback:ASFunction;

	public function new(facade:Facade, id:UInt, root:MovieClip, isSelected:Bool, changeInStateCallback:ASFunction, tooltipDrawLayer:Int = 0) {
		super(facade, root, tooltipDrawLayer);
		m_id = id;
		selectionChangeCallback = changeInStateCallback;
		this.selected = isSelected;
	}

	override function onRelease(event:MouseEvent) {
		this.selected = !this.selected;
		selectionChangeCallback(m_id, this.selected);
		super.onRelease(event);
	}
}
