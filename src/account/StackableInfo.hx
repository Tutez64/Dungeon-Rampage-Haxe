package account;

import facade.DBFacade;
import gameMasterDictionary.GMStackable;

class StackableInfo extends InventoryBaseInfo {
	var mCount:UInt = 0;

	var mGMStackable:GMStackable;

	var mConsumableSlot:Int = -1;

	public function new(dbFacade:DBFacade, json:ASObject, gmStackable:GMStackable = null) {
		if (json == null) {
			mDBFacade = dbFacade;
			mGMStackable = gmStackable;
		} else {
			super(dbFacade, json);
			mGMStackable = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(mGMId), gameMasterDictionary.GMStackable);
		}
		mGMInventoryBase = mGMStackable;
	}

	@:isVar public var gmStackable(get, never):GMStackable;

	public function get_gmStackable():GMStackable {
		return mGMStackable;
	}

	override public function get_isEquipped():Bool {
		return this.gmStackable != null && mConsumableSlot != -1 && this.gmStackable.AccountBooster == false;
	}

	@:isVar public var equipSlot(get, never):Int;

	public function get_equipSlot():Int {
		return mConsumableSlot;
	}

	@:isVar public var count(get, set):UInt;

	public function get_count():UInt {
		return mCount;
	}

	function set_count(value:UInt):UInt {
		return mCount = value;
	}

	override function parseJson(json:ASObject) {
		if (json == null) {
			return;
		}
		mGMId = ASCompat.asUint(json.stack_id);
		mAccountId = ASCompat.asUint(json.account_id);
		mDatabaseId = ASCompat.asUint(json.id);
		mCount = ASCompat.asUint(json.count);
		mIsNew = false;
		mConsumableSlot = -1;
	}

	public function setPropertiesAsConsumable(gmId:UInt, slot:UInt, count:UInt) {
		mGMId = gmId;
		mAccountId = (0 : UInt);
		mDatabaseId = (0 : UInt);
		mCount = count;
		mConsumableSlot = (slot : Int);
		mIsNew = false;
	}

	public function setConsumableSlot(slotNum:UInt) {
		mConsumableSlot = (slotNum : Int);
	}

	override public function get_hasColoredBackground():Bool {
		return false;
	}

	override public function get_backgroundIconName():String {
		return "";
	}

	override public function get_backgroundSwfPath():String {
		return "";
	}

	override public function hasGMPropertySetup():Bool {
		return mGMStackable != null;
	}

	@:isVar public var consumableSlot(get, never):Int;

	public function get_consumableSlot():Int {
		return mConsumableSlot;
	}
}
