package town;

import brain.event.EventComponent;
import brain.uI.UIButton;
import facade.DBFacade;
import uI.inventory.UIInventory;

class InventoryTownSubState extends TownSubState {
	public static inline final NAME = "InventoryTownSubState";

	var mUIInventory:UIInventory;

	var mEventComponent:EventComponent;

	var mBackButton:UIButton;

	var mStartAtCategoryTab:String = "";

	public function new(dbFacade:DBFacade, townStateMachine:TownStateMachine) {
		super(dbFacade, townStateMachine, "InventoryTownSubState");
		mEventComponent = new EventComponent(mDBFacade);
	}

	override public function destroy() {
		if (mUIInventory != null) {
			mUIInventory.destroy();
			mUIInventory = null;
		}
		mEventComponent.destroy();
		super.destroy();
	}

	override function setupState() {
		super.setupState();
		mUIInventory = new UIInventory(mDBFacade, mTownStateMachine.townHeader);
	}

	public function setRevlealedState(type:UInt, offerId:UInt, showEquipOption:Bool = false) {
		mUIInventory.setRevealedState(type, offerId, showEquipOption);
	}

	override public function enterState() {
		mRoot.addChild(mUIInventory.root);
		super.enterState();
		mTownStateMachine.townHeader.showCloseButton(true);
		if (mStartAtCategoryTab != "") {
			mUIInventory.currentTab = mStartAtCategoryTab;
		}
		mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE", function(param1:events.DBAccountResponseEvent) {
			mUIInventory.refresh();
		});
		mUIInventory.refresh(true);
		mUIInventory.animateEntry();
		super.resetHeaderLinks();
		super.setupHeaderLinks();
		mDBFacade.menuNavigationController.pushNewLayer("INVENTORY_MENU", mTownStateMachine.townHeader.determineCallback,
			mTownStateMachine.townHeader.closeButton, mTownStateMachine.townHeader.closeButton);
	}

	override public function exitState() {
		mDBFacade.menuNavigationController.popLayer("INVENTORY_MENU");
		mRoot.removeChild(mUIInventory.root);
		mUIInventory.exitState();
		mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
		super.exitState();
	}

	@:isVar public var startAtCategoryTab(never, set):String;

	public function set_startAtCategoryTab(category:String):String {
		return mStartAtCategoryTab = category;
	}
}
