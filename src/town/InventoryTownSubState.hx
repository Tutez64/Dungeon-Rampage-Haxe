package town
;
   import brain.event.EventComponent;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import uI.inventory.UIInventory;
   
    class InventoryTownSubState extends TownSubState
   {
      
      public static inline final NAME= "InventoryTownSubState";
      
      var mUIInventory:UIInventory;
      
      var mEventComponent:EventComponent;
      
      var mBackButton:UIButton;
      
      var mStartAtCategoryTab:String = "";
      
      public function new(param1:DBFacade, param2:TownStateMachine)
      {
         super(param1,param2,"InventoryTownSubState");
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      override public function destroy() 
      {
         if(mUIInventory != null)
         {
            mUIInventory.destroy();
            mUIInventory = null;
         }
         mEventComponent.destroy();
         super.destroy();
      }
      
      override function setupState() 
      {
         super.setupState();
         mUIInventory = new UIInventory(mDBFacade,mTownStateMachine.townHeader);
      }
      
      public function setRevlealedState(param1:UInt, param2:UInt, param3:Bool = false) 
      {
         mUIInventory.setRevealedState(param1,param2,param3);
      }
      
      override public function enterState() 
      {
         mRoot.addChild(mUIInventory.root);
         super.enterState();
         mTownStateMachine.townHeader.showCloseButton(true);
         if(mStartAtCategoryTab != "")
         {
            mUIInventory.currentTab = mStartAtCategoryTab;
         }
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:events.DBAccountResponseEvent)
         {
            mUIInventory.refresh();
         });
         mUIInventory.refresh(true);
         mUIInventory.animateEntry();
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("INVENTORY_MENU",mTownStateMachine.townHeader.determineCallback,mTownStateMachine.townHeader.closeButton,mTownStateMachine.townHeader.closeButton);
      }
      
      override public function exitState() 
      {
         mDBFacade.menuNavigationController.popLayer("INVENTORY_MENU");
         mRoot.removeChild(mUIInventory.root);
         mUIInventory.exitState();
         mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
         super.exitState();
      }
      
      @:isVar public var startAtCategoryTab(never,set):String;
public function  set_startAtCategoryTab(param1:String) :String      {
         return mStartAtCategoryTab = param1;
      }
   }


