package uI.equipPicker;

import brain.uI.UIObject;
import facade.DBFacade;
import flash.display.MovieClip;

class EquipSlot extends UIObject {
	var mEquipPicker_handleItemDrop:ASFunction;

	var mEquipSlot:UInt = 0;

	public function new(dbFacade:DBFacade, root:MovieClip, equipPicker_handleItemDrop:ASFunction, equipSlot:UInt) {
		super(dbFacade, root);
		mEquipPicker_handleItemDrop = equipPicker_handleItemDrop;
		mEquipSlot = equipSlot;
	}

	override public function handleDrop(dropObject:UIObject):Bool {
		return ASCompat.toBool(mEquipPicker_handleItemDrop(dropObject, null, mEquipSlot));
	}
}
