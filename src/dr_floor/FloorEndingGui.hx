package dr_floor
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.Floor;
   import events.II_FloorCompleteEvent;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMDungeonModifier;
   import gameMasterDictionary.GMMapNode;
   import uI.infiniteIsland.II_UIRewardReportPopup;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   
    class FloorEndingGui
   {
      
      public static inline final DUNGEON_FAILED_EVENT= "DUNGEON_FAILED_EVENT";
      
      public static inline final CLIENT_COUNTDOWN_FINISHED_EVENT= "CLIENT_COUNTDOWN_FINISHED_EVENT";
      
      public static inline final DUNGEON_FINISHED_SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      public static inline final DUNGEON_MODIFIER_ICONS_SWF_PATH= "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf";
      
      static inline final DEFEAT_COUNTDOWN_FIRST_SCREEN_TIME= 2;
      
      var mRoot:Sprite;
      
      var mScreensRoot:MovieClip;
      
      var mKillswitchIconsSwfAsset:SwfAsset;
      
      var mCountdownTimerLabel:TextField;
      
      var mDBFacade:DBFacade;
      
      var mSecondsUntilTransition:Int = 0;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mEventComponent:EventComponent;
      
      var mUpdateCountdownTask:Task;
      
      var mDefeatCountdownTween:TweenMax;
      
      var mVictoryRenderer:MovieClipRenderController;
      
      var mDefeatRenderer:MovieClipRenderController;
      
      var mStartRenderer:MovieClipRenderController;
      
      var mCurrentFloorRenderer:MovieClipRenderController;
      
      var mCountdownRenderer:MovieClipRenderController;
      
      var mCountdownTextField:TextField;
      
      var mDefeatCountdownStartClip:MovieClip;
      
      var mDefeatCountdownRenderer:MovieClipRenderController;
      
      var mDefeatCountdownTextField:TextField;
      
      var mKillswitchRenderer:MovieClipRenderController;
      
      var mFloor:Floor;
      
      var mFloorGUIStarted:Bool = false;
      
      var mShowStartSplash:Bool = false;
      
      var mRootInstanceName:String;
      
      var mNodeType:String;
      
      public function new(param1:Floor, param2:String, param3:DBFacade)
      {
         var floor= param1;
         var nodeType= param2;
         var dbFacade= param3;
         
         mFloor = floor;
         mFloorGUIStarted = false;
         mDBFacade = dbFacade;
         mRoot = new Sprite();
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mNodeType = nodeType;
         mShowStartSplash = mDBFacade.mainStateMachine.currentStateName == "LoadingScreenState";
         mSceneGraphComponent.addChild(mRoot,(50 : UInt));
         switch(mNodeType)
         {
            case "DUNGEON":
               mRootInstanceName = "scrn_dungeon_regular";
               
            case "BOSS":
               mRootInstanceName = "scrn_dungeon_boss";
               
            case "INFINITE":
               mRootInstanceName = "scrn_dungeon_ultimate";
               
            case "TAVERN":
               mRootInstanceName = "scrn_dungeon_regular";
               
            default:
               mRootInstanceName = "scrn_dungeon_regular";
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),dungeonFinishedSwfLoaded);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Modifier/db_icons_modifier.swf"),function(param1:SwfAsset)
         {
            mKillswitchIconsSwfAsset = param1;
         });
      }
      
      function dungeonFinishedSwfLoaded(param1:SwfAsset) 
      {
         var _loc2_= param1.getClass(mRootInstanceName);
         mScreensRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
         mScreensRoot.mouseEnabled = false;
         if(mNodeType != "INFINITE")
         {
            mVictoryRenderer = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mScreensRoot : ASAny).scrn_victory_instance, flash.display.MovieClip));
            mCountdownRenderer = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mScreensRoot : ASAny).scrn_countdown_instance, flash.display.MovieClip));
            mCountdownTextField = ASCompat.dynamicAs((mCountdownRenderer.clip : ASAny).countdown_bounce.countdown.countdown_text, flash.text.TextField);
         }
         mDefeatRenderer = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mScreensRoot : ASAny).scrn_defeat, flash.display.MovieClip));
         mStartRenderer = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mScreensRoot : ASAny).scrn_start_instance, flash.display.MovieClip));
         mCurrentFloorRenderer = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mScreensRoot : ASAny).scrn_floor, flash.display.MovieClip));
         mDefeatCountdownRenderer = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mScreensRoot : ASAny).scrn_defeat_countdown, flash.display.MovieClip));
         mDefeatCountdownStartClip = ASCompat.dynamicAs((mScreensRoot : ASAny).scrn_defeat_start_text, flash.display.MovieClip);
         mDefeatCountdownTextField = ASCompat.dynamicAs((mDefeatCountdownRenderer.clip : ASAny).countdown_bounce.countdown.countdown_text , TextField);
         hideAll();
         if(!mFloorGUIStarted)
         {
            floorStart();
         }
      }
      
      public function floorEnding(param1:UInt) 
      {
         var _loc2_:II_UIRewardReportPopup = null;
         if(mFloor.isInfiniteDungeon)
         {
            mDBFacade.eventManager.dispatchEvent(new II_FloorCompleteEvent());
            mFloor.gmMapNode;
            mFloor.parentArea.addInfiniteFloorGoldToTotal();
            _loc2_ = new II_UIRewardReportPopup(mDBFacade,mFloor.parentArea.infiniteRewardData,mFloor.parentArea.infiniteStartScore,mFloor.parentArea.infiniteTotalGold,mFloor.parentArea.infiniteFloorGold,(mFloor.getCurrentFloorNum() : Int),param1," hello",null);
            MemoryTracker.track(_loc2_,"II_UIRewardReportPopup - created in FloorEndingGui.floorComplete()");
         }
         else
         {
            setUpFloorEndingCountdownGui(param1);
         }
         checkToAddRootToScene();
      }
      
      public function floorFailing(param1:UInt) 
      {
         if(param1 == 0)
         {
            stopDefeatCounterIfRunning();
         }
         else
         {
            setUpFloorFailingCountdownGui(param1);
            checkToAddRootToScene();
         }
      }
      
      public function floorStart() 
      {
         var _loc1_:GMMapNode = null;
         var _loc2_:String = null;
         if(mScreensRoot != null && mFloor.gmMapNode != null)
         {
            mDBFacade.refreshHUD();
            mFloorGUIStarted = true;
            _loc1_ = mFloor.gmMapNode;
            _loc2_ = _loc1_.NodeType;
            if(_loc2_ == "INFINITE")
            {
               mKillswitchRenderer = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mScreensRoot : ASAny).scrn_killSwitchEngage, flash.display.MovieClip));
               mKillswitchRenderer.clip.visible = false;
            }
            displayStart();
         }
      }
      
      public function dungeonVictory() 
      {
         if(mScreensRoot != null)
         {
            displayVictory();
            checkToAddRootToScene();
         }
      }
      
      public function dungeonFailure() 
      {
         if(mScreensRoot != null)
         {
            mEventComponent.dispatchEvent(new Event("DUNGEON_FAILED_EVENT"));
            stopDefeatCounterIfRunning();
            displayDefeat();
            checkToAddRootToScene();
         }
      }
      
      public function hideAll() 
      {
         if(mScreensRoot != null)
         {
            if(mRoot.contains(mScreensRoot))
            {
               mRoot.removeChild(mScreensRoot);
            }
            if(mStartRenderer != null)
            {
               mStartRenderer.stop();
               mStartRenderer.clip.visible = false;
            }
            if(mCurrentFloorRenderer != null)
            {
               mCurrentFloorRenderer.stop();
               mCurrentFloorRenderer.clip.visible = false;
            }
            if(mVictoryRenderer != null)
            {
               mVictoryRenderer.stop();
               mVictoryRenderer.clip.visible = false;
            }
            if(mCountdownRenderer != null)
            {
               mCountdownRenderer.stop();
               mCountdownRenderer.clip.visible = false;
            }
            if(mDefeatRenderer != null)
            {
               mDefeatRenderer.stop();
               mDefeatRenderer.clip.visible = false;
            }
            if(mDefeatCountdownStartClip != null)
            {
               mDefeatCountdownStartClip.visible = false;
            }
            if(mDefeatCountdownRenderer != null)
            {
               mDefeatCountdownRenderer.stop();
               mDefeatCountdownRenderer.clip.visible = false;
            }
         }
      }
      
      function screenFinished(param1:MovieClipRenderController) 
      {
         param1.clip.visible = false;
         checkToRemoveRoot();
      }
      
      function displayNewKillswitches() 
      {
         var _loc2_= 0;
         var _loc1_= new Vector<GMDungeonModifier>();
         _loc2_ = 0;
         while(_loc2_ < mFloor.activeGMDungeonModifiers.length)
         {
            if(mFloor.activeGMDungeonModifiers[_loc2_].NewThisFloor)
            {
               _loc1_.push(mFloor.activeGMDungeonModifiers[_loc2_].GMDungeonMod);
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
         playKillswitchIntros(_loc1_,(0 : UInt));
         checkToRemoveRoot();
      }
      
      function playKillswitchIntros(param1:Vector<GMDungeonModifier>, param2:UInt) 
      {
         var _loc4_:Dynamic = null;
         var _loc3_:ASFunction = null;
         if(mKillswitchRenderer == null)
         {
            Logger.debug("Trying to play killswitch intros without a kill switch renderer.");
            return;
         }
         if((param1.length : UInt) > param2)
         {
            if(mKillswitchIconsSwfAsset != null)
            {
               _loc4_ = mKillswitchIconsSwfAsset.getClass(param1[(param2 : Int)].IconName);
               while(ASCompat.toNumberField((mKillswitchRenderer.clip : ASAny).modifier.modifier, "numChildren") > 0)
               {
                  (mKillswitchRenderer.clip : ASAny).modifier.modifier.removeChildAt(0);
               }
               if(_loc4_ == null)
               {
                  Logger.warn("Unable to find iconClass for iconName: " + param1[(param2 : Int)].IconName);
               }
               else
               {
                  (mKillswitchRenderer.clip : ASAny).modifier.modifier.addChild(ASCompat.createInstance(_loc4_, []));
               }
            }
            _loc3_ = becauseFlashSucksAtScopingVariables(param1,param2 + 1);
            mKillswitchRenderer.play((0 : UInt),false,_loc3_);
            ASCompat.setProperty((mKillswitchRenderer.clip : ASAny).banner_modifier.label_modifier, "text", param1[(param2 : Int)].Name);
            mKillswitchRenderer.clip.visible = true;
            return;
         }
         screenFinished(mKillswitchRenderer);
      }
      
      function becauseFlashSucksAtScopingVariables(param1:Vector<GMDungeonModifier>, param2:UInt) : ASFunction
      {
         var killswitches= param1;
         var index= param2;
         return function()
         {
            playKillswitchIntros(killswitches,index);
         };
      }
      
      function displayVictory() 
      {
         checkToAddRootToScene();
         mVictoryRenderer.clip.visible = true;
         mVictoryRenderer.play((0 : UInt),false,function()
         {
            screenFinished(mVictoryRenderer);
         });
      }
      
      function displayDefeat() 
      {
         checkToAddRootToScene();
         mDefeatRenderer.clip.visible = true;
         mDefeatRenderer.play((0 : UInt),false,function()
         {
            screenFinished(mDefeatRenderer);
         });
      }
      
      function displayStart() 
      {
         checkToAddRootToScene();
         displayCurrentFloor();
         if(mShowStartSplash && !mStartRenderer.isPlaying)
         {
            mStartRenderer.clip.visible = true;
            mStartRenderer.playRate = 0.65;
            mStartRenderer.play((0 : UInt),false,function()
            {
               if(mStartRenderer != null)
               {
                  mStartRenderer.clip.visible = false;
                  displayNewKillswitches();
               }
            });
         }
         else
         {
            displayNewKillswitches();
         }
      }
      
      function displayCurrentFloor() 
      {
         checkToAddRootToScene();
         mCurrentFloorRenderer.clip.visible = true;
         if(mFloor.getMaxFloorNum() >= 50)
         {
            ASCompat.setProperty((mCurrentFloorRenderer.clip : ASAny).scrn_floor.textField, "text", Locale.getString("FLOOR").toUpperCase() + " " + Std.string(mFloor.getCurrentFloorNum()));
         }
         else
         {
            ASCompat.setProperty((mCurrentFloorRenderer.clip : ASAny).scrn_floor.textField, "text", Locale.getString("FLOOR").toUpperCase() + " " + Std.string(mFloor.getCurrentFloorNum()) + " OF " + Std.string(mFloor.getMaxFloorNum()));
         }
         mCurrentFloorRenderer.playRate = 0.8;
         mCurrentFloorRenderer.play((0 : UInt),false,function()
         {
            screenFinished(mCurrentFloorRenderer);
         });
      }
      
      function checkToRemoveRoot() 
      {
         if(!mCurrentFloorRenderer.isPlaying && (mStartRenderer == null || !mStartRenderer.isPlaying) && !(mVictoryRenderer != null && !mVictoryRenderer.isPlaying) && !mDefeatRenderer.isPlaying && !(mKillswitchRenderer != null && !mKillswitchRenderer.isPlaying) && mUpdateCountdownTask == null)
         {
            mSceneGraphComponent.removeChild(mRoot);
            hideAll();
         }
      }
      
      function checkToAddRootToScene() 
      {
         if(mRoot != null && !mRoot.contains(mScreensRoot))
         {
            mRoot.addChild(mScreensRoot);
         }
         if(!mSceneGraphComponent.contains(mRoot,(50 : UInt)))
         {
            mSceneGraphComponent.addChild(mRoot,(50 : UInt));
         }
      }
      
      function setUpFloorEndingCountdownGui(param1:UInt) 
      {
         if(param1 == 0)
         {
            return;
         }
         mSecondsUntilTransition = (param1 : Int);
         mCountdownTextField.text = Std.string(mSecondsUntilTransition);
         mCountdownRenderer.play((0 : UInt),false);
         mCountdownRenderer.clip.visible = true;
         mUpdateCountdownTask = mLogicalWorkComponent.doEverySeconds(1,updateFloorEndingCountdown);
      }
      
      function setUpInfiniteDungeonFloorEndingCountdownGui(param1:UInt) 
      {
         if(param1 == 0)
         {
            return;
         }
         mSecondsUntilTransition = (param1 : Int);
         mCountdownTextField.text = Std.string(mSecondsUntilTransition);
         mCountdownRenderer.play((0 : UInt),false);
         mCountdownRenderer.clip.visible = true;
         ASCompat.setProperty((mScreensRoot : ASAny).Scrn_nextfloor_infinite.basic, "visible", false);
         ASCompat.setProperty((mScreensRoot : ASAny).Scrn_nextfloor_infinite.uncommon, "visible", false);
         ASCompat.setProperty((mScreensRoot : ASAny).Scrn_nextfloor_infinite.rare, "visible", false);
         ASCompat.setProperty((mScreensRoot : ASAny).Scrn_nextfloor_infinite.legendary, "visible", false);
         ASCompat.setProperty((mScreensRoot : ASAny).Scrn_nextfloor_infinite.coin_count, "text", "3000");
         initInfiniteDungeonTotalReward(5000,(2 : UInt));
         mUpdateCountdownTask = mLogicalWorkComponent.doEverySeconds(1,updateFloorEndingCountdown);
      }
      
      function initInfiniteDungeonTotalReward(param1:Int, param2:UInt) 
      {
         var _loc4_= 0;
         ASCompat.setProperty((mScreensRoot : ASAny).Scrn_nextfloor_infinite.current_reward.label_currentReward, "text", Locale.getString("TOTAL_REWARD"));
         var _loc3_= new Vector<MovieClip>();
         _loc3_.push(ASCompat.dynamicAs((mScreensRoot : ASAny).Scrn_nextfloor_infinite.current_reward.basic, flash.display.MovieClip));
         _loc3_.push(ASCompat.dynamicAs((mScreensRoot : ASAny).Scrn_nextfloor_infinite.current_reward.uncommon, flash.display.MovieClip));
         _loc3_.push(ASCompat.dynamicAs((mScreensRoot : ASAny).Scrn_nextfloor_infinite.current_reward.rare, flash.display.MovieClip));
         _loc3_.push(ASCompat.dynamicAs((mScreensRoot : ASAny).Scrn_nextfloor_infinite.current_reward.legendary, flash.display.MovieClip));
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc3_[_loc4_].stop();
            _loc4_++;
         }
         ASCompat.setProperty((mScreensRoot : ASAny).Scrn_nextfloor_infinite.current_reward.coin_count, "text", Std.string(param1));
         _loc4_ = param2;
         while(_loc4_ < _loc3_.length)
         {
            _loc3_[_loc4_].nextFrame();
            _loc3_[_loc4_].stop();
            _loc4_++;
         }
      }
      
      function setUpFloorFailingCountdownGui(param1:UInt) 
      {
         mDefeatCountdownStartClip.visible = true;
         mSecondsUntilTransition = (param1 : Int);
         mDefeatCountdownTween = TweenMax.to(mDefeatCountdownStartClip,2,{
            "visible":false,
            "onComplete":defeatCountdownTweenFinished
         });
      }
      
      function defeatCountdownTweenFinished() 
      {
         if(mDefeatCountdownStartClip != null)
         {
            mDefeatCountdownStartClip.visible = false;
         }
         if(mDefeatCountdownTextField != null)
         {
            mDefeatCountdownTextField.text = Std.string(mSecondsUntilTransition);
         }
         if(mDefeatCountdownRenderer != null)
         {
            mDefeatCountdownRenderer.play((0 : UInt),false);
            mDefeatCountdownRenderer.clip.visible = true;
         }
         mUpdateCountdownTask = mLogicalWorkComponent.doEverySeconds(1,updateFloorFailingCountdown);
      }
      
      function isCountdownComplete() : Bool
      {
         mSecondsUntilTransition = mSecondsUntilTransition - 1;
         if(mSecondsUntilTransition < 0)
         {
            if(mUpdateCountdownTask != null)
            {
               mUpdateCountdownTask.destroy();
               mUpdateCountdownTask = null;
            }
            return true;
         }
         return false;
      }
      
      function updateFloorEndingCountdown(param1:GameClock) 
      {
         if(!isCountdownComplete())
         {
            mCountdownTextField.text = Std.string(mSecondsUntilTransition);
            mCountdownRenderer.play((0 : UInt),false);
         }
         else
         {
            mSceneGraphComponent.fadeOut(1);
         }
      }
      
      function updateFloorFailingCountdown(param1:GameClock) 
      {
         if(!isCountdownComplete())
         {
            mDefeatCountdownTextField.text = Std.string(mSecondsUntilTransition);
            mDefeatCountdownRenderer.play((0 : UInt),false);
         }
         else
         {
            mEventComponent.dispatchEvent(new Event("CLIENT_COUNTDOWN_FINISHED_EVENT"));
            screenFinished(mDefeatCountdownRenderer);
         }
      }
      
      function stopDefeatCounterIfRunning() 
      {
         if(mDefeatCountdownTween != null)
         {
            if(mDefeatCountdownStartClip != null)
            {
               mDefeatCountdownStartClip.visible = false;
            }
            if(mDefeatCountdownTextField != null)
            {
               mDefeatCountdownTextField.text = Std.string(mSecondsUntilTransition);
            }
            if(mDefeatCountdownRenderer != null)
            {
               mDefeatCountdownRenderer.play((0 : UInt),false);
               mDefeatCountdownRenderer.clip.visible = true;
            }
            mDefeatCountdownTween.kill();
            mDefeatCountdownTween = null;
         }
         if(mUpdateCountdownTask != null)
         {
            mUpdateCountdownTask.destroy();
            mUpdateCountdownTask = null;
         }
         mSecondsUntilTransition = 0;
         screenFinished(mDefeatCountdownRenderer);
      }
      
      public function destroy() 
      {
         mFloor = null;
         mSceneGraphComponent.fadeOut(0);
         hideAll();
         if(mUpdateCountdownTask != null)
         {
            mUpdateCountdownTask.destroy();
         }
         mUpdateCountdownTask = null;
         if(mDefeatCountdownTween != null)
         {
            if(mDefeatCountdownStartClip != null)
            {
               mDefeatCountdownStartClip.visible = false;
            }
            if(mDefeatCountdownTextField != null)
            {
               mDefeatCountdownTextField.text = Std.string(mSecondsUntilTransition);
            }
            if(mDefeatCountdownRenderer != null)
            {
               mDefeatCountdownRenderer.play((0 : UInt),false);
               mDefeatCountdownRenderer.clip.visible = true;
            }
            mDefeatCountdownTween.kill();
            mDefeatCountdownTween = null;
         }
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         mScreensRoot = null;
         mRoot = null;
         mCountdownTextField = null;
         mCountdownTimerLabel = null;
         TweenMax.killTweensOf(mDefeatCountdownStartClip);
         mDefeatCountdownStartClip = null;
         mDefeatCountdownTextField = null;
         if(mVictoryRenderer != null)
         {
            mVictoryRenderer.destroy();
         }
         mVictoryRenderer = null;
         if(mDefeatRenderer != null)
         {
            mDefeatRenderer.destroy();
         }
         mDefeatRenderer = null;
         if(mStartRenderer != null)
         {
            mStartRenderer.destroy();
         }
         mStartRenderer = null;
         if(mCurrentFloorRenderer != null)
         {
            mCurrentFloorRenderer.destroy();
         }
         mCurrentFloorRenderer = null;
         mDefeatCountdownStartClip = null;
         mCountdownTextField = null;
         mDefeatCountdownTextField = null;
         if(mCountdownRenderer != null)
         {
            mCountdownRenderer.destroy();
         }
         mCountdownRenderer = null;
         if(mDefeatCountdownRenderer != null)
         {
            mDefeatCountdownRenderer.destroy();
         }
         mDefeatCountdownRenderer = null;
         if(mKillswitchRenderer != null)
         {
            mKillswitchRenderer.destroy();
            mKillswitchRenderer = null;
         }
         mDBFacade = null;
      }
   }


