package stateMachine.mainStateMachine
;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.stateMachine.State;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import events.ClientExitCompleteEvent;
   import events.GameObjectEvent;
   import events.LEClientEvent;
   import facade.DBFacade;
   import uI.hud.UITutorialController;
   import uI.uINewsFeed.UINewsFeedController;
   import flash.events.Event;
   
    class RunState extends State
   {
      
      public static inline final NAME= "RunState";
      
      public static inline final ENTER_RUN_STATE_EVENT= "ENTER_RUN_STATE_EVENT";
      
      var mDBFacade:DBFacade;
      
      var mGoToSplashScreenCallback:ASFunction;
      
      var mEventComponent:EventComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mDungeonTutorialWaitTask:Task;
      
      var mTutorialController:UITutorialController;
      
      var mNewsFeedController:UINewsFeedController;
      
      var mMovementTutorialStarted:Bool = false;
      
      var mChargeTutorialStarted:Bool = false;
      
      var mCooldownTutorialStarted:Bool = false;
      
      public function new(param1:DBFacade, param2:ASFunction)
      {
         super("RunState");
         mDBFacade = param1;
         mGoToSplashScreenCallback = param2;
         mEventComponent = new EventComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"RunState");
         mTutorialController = new UITutorialController(mDBFacade);
      }
      
      override public function destroy() 
      {
         mEventComponent.destroy();
         mLogicalWorkComponent.destroy();
         mNewsFeedController.destroy();
         mNewsFeedController = null;
         mGoToSplashScreenCallback = null;
         mDBFacade = null;
         mTutorialController.destroy();
         super.destroy();
      }
      
      override public function enterState() 
      {
         var dungeonsCompletedCount:UInt;
         var eventName:String;
         Logger.debug("MAIN STATE MACHINE TRANSITION -- ENTERING RUN STATE");
         super.enterState();
         dungeonsCompletedCount = mDBFacade.dbAccountInfo.getDungeonsCompleted();
         mDBFacade.metrics.log("DungeonRunState",{});
         if(mNewsFeedController == null)
         {
            mNewsFeedController = new UINewsFeedController(mDBFacade);
         }
         mNewsFeedController.startFeedTask();
         mDBFacade.regainFocus();
         mDBFacade.dbAccountInfo.setPresenceTask("DUNGEON");
         mEventComponent.dispatchEvent(new Event("ENTER_RUN_STATE_EVENT"));
         mEventComponent.addListener("CLIENT_EXIT_COMPLETE",gracefulSocketClose);
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasDungeonBusterTutorialParam())
         {
            eventName = GameObjectEvent.uniqueEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",mDBFacade.dbAccountInfo.activeAvatarInfo.id);
            mEventComponent.addListener(eventName,function(param1:events.BusterPointsEvent)
            {
               if(param1.busterPoints >= param1.maxBusterPoints)
               {
                  mEventComponent.removeListener(eventName);
                  mTutorialController.queueTutorial("BUSTER_TUTORIAL");
               }
            });
         }
         if(dungeonsCompletedCount >= 1)
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasLootSharingTutorialParam())
            {
               mTutorialController.queueTutorial("LOOT_SHARING_TUTORIAL");
            }
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasChestNearbyTutorialParam())
            {
               mEventComponent.addListener("FirstTreasureNearby",function(param1:events.FirstTreasureNearbyEvent)
               {
                  mEventComponent.removeListener("FirstTreasureNearby");
                  mTutorialController.queueTutorial("CHEST_TUTORIAL_NEARBY");
               });
            }
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasChestCollectedTutorialParam())
            {
               mEventComponent.addListener("FirstTreasureCollected",function(param1:events.FirstTreasureCollectedEvent)
               {
                  mEventComponent.removeListener("FirstTreasureCollected");
                  mTutorialController.endChestTutorial();
               });
            }
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasCooldownTutorialParam())
            {
               mEventComponent.addListener("FirstCooldown",function(param1:events.FirstCooldownEvent)
               {
                  mEventComponent.removeListener("FirstCooldown");
                  mTutorialController.queueTutorial("COOLDOWN_TUTORIAL");
               });
            }
         }
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasScalingTutorialParam())
         {
            mEventComponent.addListener("FirstScaling",function(param1:events.FirstScalingEvent)
            {
               mEventComponent.removeListener("FirstScaling");
               mTutorialController.queueTutorial("SCALING_TUTORIAL");
            });
         }
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasRepeaterTutorialParam())
         {
            mEventComponent.addListener("FirstRepeater",function(param1:events.FirstRepeaterEvent)
            {
               mEventComponent.removeListener("FirstRepeater");
               mTutorialController.queueTutorial("REPEATER_TUTORIAL");
            });
         }
         if(dungeonsCompletedCount >= 7)
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasSuperWeakParam())
            {
               mTutorialController.queueTutorial("SUPER_WEAK_TUTORIAL");
            }
         }
         mDBFacade.eventManager.addEventListener("SEND_EVENT",receivedClientEvent);
      }
      
      function receivedClientEvent(param1:LEClientEvent) 
      {
         var lecEvt= param1;
         if(!mMovementTutorialStarted && lecEvt.eventName == "FIRE_MOVEMENT_TUTORIAL")
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasMovementTutorialParam())
            {
               mTutorialController.queueTutorial("MOVEMENT_TUTORIAL");
            }
            mMovementTutorialStarted = true;
         }
         else if(!mChargeTutorialStarted && lecEvt.eventName == "FIRE_CHARGE_TUTORIAL")
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasChargeTutorialParam())
            {
               mTutorialController.queueTutorial("CHARGE_TUTORIAL");
            }
            mChargeTutorialStarted = true;
         }
         else if(!mCooldownTutorialStarted && lecEvt.eventName == "START_COOLDOWN_TUTORIAL")
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasCooldownTutorialParam())
            {
               mEventComponent.addListener("FirstCooldown",function(param1:events.FirstCooldownEvent)
               {
                  mEventComponent.removeListener("FirstCooldown");
                  mTutorialController.queueTutorial("COOLDOWN_TUTORIAL");
               });
            }
            mCooldownTutorialStarted = true;
         }
      }
      
      function gracefulSocketClose(param1:ClientExitCompleteEvent) 
      {
         mDBFacade.mainStateMachine.enterReloadTownState();
      }
      
      override public function exitState() 
      {
         mNewsFeedController.stopFeedTask();
         mEventComponent.removeAllListeners();
         mDBFacade.assetRepository.removeCacheForAllSpriteSheetAssets();
         super.exitState();
      }
   }


