package uI.equipPicker;

import account.ItemInfo;
import account.StackableInfo;
import facade.DBFacade;
import gameMasterDictionary.GMStackable;
import flash.display.MovieClip;

class ConsumableEquipElement extends AvatarEquipElement {
	var mStackableInfo:StackableInfo;

	public function new(dbFacade:DBFacade, keyLabel:String, root:MovieClip, tooltipClass:Dynamic, unequipCallback:ASFunction, handleDropCallback:ASFunction,
			equipSlot:UInt, clickedEquipedWeaponCallback:ASFunction = null, equipResponseCallback:ASFunction = null, allowEquipmentSwapping:Bool = false) {
		super(dbFacade, keyLabel, root, tooltipClass, unequipCallback, handleDropCallback, equipSlot, clickedEquipedWeaponCallback, equipResponseCallback,
			allowEquipmentSwapping);
		ASCompat.setProperty((mRoot : ASAny).textx, "visible", false);
		ASCompat.setProperty((mRoot : ASAny).quantity, "visible", false);
	}

	override public function clear() {
		super.clear();
		ASCompat.setProperty((mRoot : ASAny).textx, "visible", false);
		ASCompat.setProperty((mRoot : ASAny).quantity, "visible", false);
	}

	public function init(gmStackable:GMStackable, slot:UInt, count:UInt) {
		var _loc4_:ItemInfo = null;
		clear();
		mStackableInfo = new StackableInfo(mDBFacade, null, gmStackable);
		stackableInfo.setPropertiesAsConsumable(gmStackable.Id, slot, count);
		mItemInfo = stackableInfo;
		if (mItemInfo != null) {
			ASCompat.setProperty((mRoot : ASAny).frame, "alpha", 1);
			loadItemIcon();
			_loc4_ = ASCompat.reinterpretAs(mItemInfo, ItemInfo);
			if (_loc4_ == null) {}
			draggable = true;
		} else {
			ASCompat.setProperty((mRoot : ASAny).frame, "alpha", 0);
			draggable = false;
		}
		ASCompat.setProperty((mRoot : ASAny).textx, "visible", true);
		ASCompat.setProperty((mRoot : ASAny).quantity, "visible", true);
		ASCompat.setProperty((mRoot : ASAny).quantity, "text", Std.string(count));
	}

	@:isVar public var stackableInfo(get, never):StackableInfo;

	public function get_stackableInfo():StackableInfo {
		return mStackableInfo;
	}

	override function resetDragUnequipFunc() {
		mUnequipCallback(mItemInfo, mEquipSlot, mEquipResponseCallback);
	}
}
