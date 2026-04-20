package town
;
   import facade.DBFacade;
   import uI.shop.UIShop;
   
    class ShopTownSubState extends TownSubState
   {
      
      public static inline final NAME= "ShopTownSubState";
      
      var mUIShop:UIShop;
      
      var mStartAtCategoryTab:String = "";
      
      public function new(param1:DBFacade, param2:TownStateMachine)
      {
         super(param1,param2,"ShopTownSubState");
      }
      
      override public function enterState() 
      {
         super.enterState();
         if(mUIShop != null)
         {
            mUIShop.refresh(mStartAtCategoryTab);
            mUIShop.animateEntry();
         }
         mTownStateMachine.townHeader.showCloseButton(true);
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("SHOP_MENU",mTownStateMachine.townHeader.determineCallback,mTownStateMachine.townHeader.closeButton,mTownStateMachine.townHeader.closeButton);
      }
      
      override function setupHeaderLinks() 
      {
      }
      
      override public function exitState() 
      {
         mDBFacade.menuNavigationController.popLayer("SHOP_MENU");
         mUIShop.processChosenAvatar();
         super.exitState();
      }
      
      override public function destroy() 
      {
         super.destroy();
         mUIShop.destroy();
         mUIShop = null;
      }
      
      override function setupState() 
      {
         super.setupState();
         mUIShop = new UIShop(mDBFacade,mTownStateMachine.townSwf,mRootMovieClip,mTownStateMachine.townHeader);
      }
      
      @:isVar public var startAtCategoryTab(never,set):String;
public function  set_startAtCategoryTab(param1:String) :String      {
         return mStartAtCategoryTab = param1;
      }
   }


