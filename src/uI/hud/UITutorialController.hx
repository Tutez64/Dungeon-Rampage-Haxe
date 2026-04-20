package uI.hud
;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import facade.DBFacade;
   import stateMachine.mainStateMachine.DungeonTutorial;
   import org.as3commons.collections.Map;
   
    class UITutorialController
   {
      
      var mDBFacade:DBFacade;
      
      var mDungeonTutorial:DungeonTutorial;
      
      var mTutorialsCallbackQueue:Vector<ASFunction>;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mTutorialTask:Task;
      
      var mTutorialEventMap:Map;
      
      public function new(param1:DBFacade)
      {
         var dbFacade= param1;
         
         mDBFacade = dbFacade;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UITutorialController");
         mEventComponent = new EventComponent(mDBFacade);
         mTutorialsCallbackQueue = new Vector<ASFunction>();
         mTutorialEventMap = new Map();
         mEventComponent.addListener("DUNGEON_FLOOR_DESTROY",function(param1:flash.events.Event)
         {
            flushTutorialQueue();
            destroyTutorial();
         });
      }
      
      public function queueTutorial(param1:String) 
      {
         if(ASCompat.toBool(mTutorialEventMap.itemFor(param1)))
         {
            return;
         }
         switch(param1)
         {
            case "COOLDOWN_TUTORIAL":
               mTutorialsCallbackQueue.push(startCooldownTutorial);
               
            case "SCALING_TUTORIAL":
               mTutorialsCallbackQueue.push(startScalingTutorial);
               
            case "REPEATER_TUTORIAL":
               mTutorialsCallbackQueue.push(startRepeaterTutorial);
               
            case "CHEST_TUTORIAL_NEARBY":
               mTutorialsCallbackQueue.push(startChestTutorial);
               
            case "BUSTER_TUTORIAL":
               mTutorialsCallbackQueue.push(startBusterTutorial);
               
            case "CHARGE_TUTORIAL":
               mTutorialsCallbackQueue.push(startChargeTutorial);
               
            case "LOOT_SHARING_TUTORIAL":
               mTutorialsCallbackQueue.push(startLootSharingTutorial);
               
            case "MOVEMENT_TUTORIAL":
               mTutorialsCallbackQueue.push(startMovementTutorial);
               
            case "SUPER_WEAK_TUTORIAL":
               mTutorialsCallbackQueue.push(startSuperWeakTutorial);
         }
         mTutorialEventMap.add(param1,1);
         if(mTutorialTask == null)
         {
            mTutorialTask = mLogicalWorkComponent.doEverySeconds(1,checkTutorials);
         }
      }
      
      function checkTutorials(param1:GameClock) 
      {
         if(mTutorialsCallbackQueue.length == 0)
         {
            if(mTutorialTask != null)
            {
               mTutorialTask.destroy();
            }
            mTutorialTask = null;
         }
         if(mDungeonTutorial != null)
         {
            if(!mDungeonTutorial.isTutorialComplete)
            {
               return;
            }
            destroyTutorial();
         }
         var _loc2_= mTutorialsCallbackQueue.shift();
         if(_loc2_ != null)
         {
            _loc2_();
         }
      }
      
      function destroyTutorial() 
      {
         if(mDungeonTutorial != null)
         {
            mDungeonTutorial.destroy();
            mDungeonTutorial = null;
         }
      }
      
      function startChestTutorial() 
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showChestTutorial();
      }
      
      function startCooldownTutorial() 
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showCooldownTutorial();
      }
      
      function startScalingTutorial() 
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showScalingTutorial();
      }
      
      function startRepeaterTutorial() 
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showRepeaterTutorial();
      }
      
      public function endChestTutorial() 
      {
         if(mDungeonTutorial != null)
         {
            mDungeonTutorial.finishChestTutorial();
         }
      }
      
      function startBusterTutorial() 
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showBusterTutorial();
      }
      
      function startChargeTutorial() 
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showChargeTutorial();
      }
      
      function startMovementTutorial() 
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showMovementTutorial();
      }
      
      function startLootSharingTutorial() 
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showLootSharingTutorial();
      }
      
      function startSuperWeakTutorial() 
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showSuperWeakTutorial("tutorial_enemy_defense1");
      }
      
      public function flushTutorialQueue() 
      {
         var _loc2_= 0;
         var _loc1_:ASFunction = null;
         if(mTutorialTask != null)
         {
            mTutorialTask.destroy();
         }
         mTutorialTask = null;
         _loc2_ = 0;
         while(_loc2_ < mTutorialsCallbackQueue.length)
         {
            _loc1_ = mTutorialsCallbackQueue.shift();
            _loc1_ = null;
         }
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         flushTutorialQueue();
         destroyTutorial();
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
      }
   }


