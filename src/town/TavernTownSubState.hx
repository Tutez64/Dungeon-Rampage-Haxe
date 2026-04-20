package town
;
   import brain.event.EventComponent;
   import facade.DBFacade;
   import uI.tavern.UITavern;
   
    class TavernTownSubState extends TownSubState
   {
      
      static inline final NAME= "TavernTownSubState";
      
      var mTavernUI:UITavern;
      
      var mEventComponent:EventComponent;
      
      public function new(param1:DBFacade, param2:TownStateMachine)
      {
         super(param1,param2,"TavernTownSubState");
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      override public function destroy() 
      {
         if(mTavernUI != null)
         {
            mTavernUI.destroy();
            mTavernUI = null;
         }
         mEventComponent.destroy();
         super.destroy();
      }
      
      override function setupState() 
      {
         super.setupState();
         mTavernUI = new UITavern(mDBFacade,mRootMovieClip,mTownStateMachine.townHeader);
      }
      
      override public function enterState() 
      {
         super.enterState();
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:events.DBAccountResponseEvent)
         {
            mTavernUI.refresh();
         });
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("TAVERN_MENU",mTownStateMachine.townHeader.determineCallback,mTavernUI.getDefaultMenuNavigationObject());
         mTavernUI.refresh();
         mTownStateMachine.townHeader.showCloseButton(true);
         mTavernUI.animateEntry();
      }
      
      override function setupHeaderLinks() 
      {
         super.setupHeaderLinks();
      }
      
      override public function exitState() 
      {
         mTavernUI.processChosenAvatar();
         mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
         mDBFacade.menuNavigationController.popLayer("TAVERN_MENU");
         mTavernUI.resetHeaderLinks();
         super.exitState();
      }
   }


