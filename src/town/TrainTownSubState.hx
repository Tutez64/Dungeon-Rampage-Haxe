package town
;
   import facade.DBFacade;
   import uI.training.UIHeroTraining;
   
    class TrainTownSubState extends TownSubState
   {
      
      public static inline final NAME= "TrainTownSubState";
      
      var mUIHeroTraining:UIHeroTraining;
      
      public function new(param1:DBFacade, param2:TownStateMachine)
      {
         super(param1,param2,"TrainTownSubState");
      }
      
      override function setupState() 
      {
         super.setupState();
         mUIHeroTraining = new UIHeroTraining(mDBFacade,mTownStateMachine.townSwf,mRootMovieClip,mTownStateMachine.townHeader);
      }
      
      override public function enterState() 
      {
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("TRAINING_MENU",mTownStateMachine.townHeader.determineCallback,mTownStateMachine.townHeader.closeButton,mTownStateMachine.townHeader.closeButton);
         super.enterState();
         if(mUIHeroTraining != null)
         {
            mUIHeroTraining.enableHud();
         }
         mTownStateMachine.townHeader.showCloseButton(true);
         mUIHeroTraining.animateEntry();
      }
      
      override public function destroy() 
      {
         if(mUIHeroTraining != null)
         {
            mUIHeroTraining.destroy();
            mUIHeroTraining = null;
         }
         super.destroy();
      }
      
      override public function exitState() 
      {
         mDBFacade.menuNavigationController.popLayer("TRAINING_MENU");
         if(mUIHeroTraining != null)
         {
            mUIHeroTraining.processChosenAvatar();
            mUIHeroTraining.disableHud();
         }
         super.exitState();
      }
   }


