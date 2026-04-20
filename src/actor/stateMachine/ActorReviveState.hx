package actor.stateMachine
;
   import account.StackableInfo;
   import account.StoreServicesController;
   import actor.ActorView;
   import box2D.collision.shapes.B2CircleShape;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.gameObject.GameObject;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.uI.UICircularProgressBar;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import collision.HeroReviveSensor;
   import dBGlobals.DBGlobal;
   import distributedObjects.HeroGameObject;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMChest;
   import gameMasterDictionary.GMDoober;
   import gameMasterDictionary.GMOffer;
   import generatedCode.InfiniteRewardData;
   import stateMachine.mainStateMachine.DungeonTutorial;
   import uI.infiniteIsland.II_UIExitDungeonPopUp;
   import uI.popup.UILootLossPopup;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.filters.ColorMatrixFilter;
   
    class ActorReviveState extends ActorState
   {
      
      public static inline final NAME= "ActorReviveState";
      
      public static inline final CLEAR_REVIVE_EVENT= "CLEAR_REVIVE_EVENT";
      
      public static inline final ON_ENTER_STATE_SATURATE_VALUE:Float = 25;
      
      public static inline final ON_EXIT_STATE_SATURATE_VALUE:Float = 100;
      
      public static inline final REVIVE_DURATION:Float = 30;
      
      public static inline final REVIVE_CIRCULAR_BAR_INCREMENT_DURATION:Float = 0.5;
      
      public static inline final DEAD_PLAYER_EFFECT_Y_OFFSET:Float = -100;
      
      public static inline final TRIGGER_RANGE:Float = 100;
      
      static inline final REVIVE_KEYCODE= 32;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mOffScreenBootTimer:UICircularProgressBar;
      
      var mPopupBootTimer:UICircularProgressBar;
      
      var mPopupBootTimerTask:Task;
      
      var mDestroyTimerTask:Task;
      
      var mSpaceBarTask:Task;
      
      var mLoadReviveTriggerTask:Task;
      
      var mRevivePanel:MovieClip;
      
      var mSelfReviveMeButton:UIButton;
      
      var mSelfReviveAllButton:UIButton;
      
      var mReturnToTownButton:UIButton;
      
      var mDeadPlayerEffect:MovieClip;
      
      var mKeyBoardInput:MovieClip;
      
      var mMouseInput:MovieClip;
      
      var mReviveTrigger:HeroReviveSensor;
      
      var mHeroGameObject:HeroGameObject;
      
      var mSpaceBarReviveFunction:ASFunction;
      
      var mDungeonReviveTutorial:DungeonTutorial;
      
      var mDeathCount:UInt = (0 : UInt);
      
      var mHitTabClip:MovieClip;
      
      var mHitTabTween:TweenMax;
      
      var mCloseButton:UIButton;
      
      public function new(param1:DBFacade, param2:HeroGameObject, param3:ActorView, param4:ASFunction = null)
      {
         var dbFacade= param1;
         var heroGameObject= param2;
         var actorView= param3;
         var finishedCallback= param4;
         super(dbFacade,heroGameObject,actorView,"ActorReviveState",finishedCallback);
         mHeroGameObject = heroGameObject;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"ActorReviveState");
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"ActorReviveState");
         mDungeonReviveTutorial = new DungeonTutorial(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener("CLEAR_REVIVE_EVENT",function(param1:Event)
         {
            deActivateReviveUI();
         });
         mEventComponent.addListener("DUNGEON_FAILED_EVENT",function(param1:Event)
         {
            destroyUI();
         });
         mEventComponent.addListener("CLIENT_COUNTDOWN_FINISHED_EVENT",function(param1:Event)
         {
            if(mRevivePanel != null)
            {
               mRevivePanel.visible = false;
            }
         });
      }
      
      override public function enterState() 
      {
         var ownerHero:HeroGameObjectOwner;
         var ownerHeroId:UInt;
         var go:GameObject;
         var ownerHeroGO:HeroGameObjectOwner;
         var reviveTutorialPopupPosition:String;
         super.enterState();
         mActorView.actionsForDeadState();
         mHeroGameObject.movementControllerType = "locked";
         mHeroGameObject.stopRunIdleMonitoring();
         mEventComponent.dispatchEvent(new Event("CLEAR_REVIVE_EVENT"));
         if(mActorView.hasAnimationRenderer())
         {
            mActorView.playAnim("death",0,false,false);
         }
         if(mActorView.currentWeapon != null && mActorView.currentWeapon.weaponRenderer != null)
         {
            mActorView.currentWeapon.weaponRenderer.stop();
         }
         if(Std.isOfType(mHeroGameObject , HeroGameObjectOwner))
         {
            ownerHero = ASCompat.reinterpretAs(mHeroGameObject , HeroGameObjectOwner);
            ownerHero.clearWeaponInput();
         }
         if(Std.isOfType(mHeroGameObject , HeroGameObjectOwner))
         {
            cast(mHeroGameObject, HeroGameObjectOwner).startDeathCamInput();
         }
         if(mHeroGameObject.distributedDungeonFloor != null && mHeroGameObject.distributedDungeonFloor.isADefeat)
         {
            return;
         }
         mLoadReviveTriggerTask = mLogicalWorkComponent.doEverySeconds(0.5,checkIfHeroIsReadyAndInitReviveSensor);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),function(param1:SwfAsset)
         {
            var swfAsset= param1;
            var assetClass= swfAsset.getClass("UI_widget");
            mDeadPlayerEffect = ASCompat.dynamicAs(ASCompat.createInstance(assetClass, []), flash.display.MovieClip);
            mDeadPlayerEffect.y += -100;
            ASCompat.setProperty((mDeadPlayerEffect : ASAny).NametagText, "text", "");
            ASCompat.setProperty((mDeadPlayerEffect : ASAny).AlertText, "text", Locale.getString("NAMETAG_RESCUE"));
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Avatars/db_icons_avatars.swf"),function(param1:SwfAsset)
            {
               var _loc3_= param1.getClass("death_icon");
               var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
               _loc2_.name = "revivePic";
               (mDeadPlayerEffect : ASAny).UI_avatar.addChild(_loc2_);
            });
            ASCompat.setProperty((mDeadPlayerEffect : ASAny).UI_arrow, "visible", false);
            mDeadPlayerEffect.name = "deadEffect";
            mHeroGameObject.view.root.addChildAt(mDeadPlayerEffect,0);
         });
         if(mDBFacade.hud.offScreenPlayerManager != null)
         {
            mDBFacade.hud.offScreenPlayerManager.handlePicChange((mHeroGameObject.id : Int),"REVIVE");
         }
         if(Std.isOfType(mHeroGameObject , HeroGameObjectOwner))
         {
            mDeathCount = mDeathCount + 1;
            if(mDBFacade.facebookController != null && mDeathCount >= 10 && !mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
            {
               mDBFacade.facebookController.updateGuestAchievement((6 : UInt));
            }
            saturate(25);
            loadDeadPlayerUI();
         }
         else if(!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam())
         {
            if(mHeroGameObject != null && mHeroGameObject.distributedDungeonFloor != null)
            {
               ownerHeroId = mDBFacade.dbAccountInfo.activeAvatarInfo.id;
               go = mDBFacade.gameObjectManager.getReferenceFromId(ownerHeroId);
               ownerHeroGO = ASCompat.reinterpretAs(go , HeroGameObjectOwner);
               if(ownerHeroGO != null)
               {
                  reviveTutorialPopupPosition = "TUTORIAL_PANEL_RIGHT";
                  if(ownerHeroGO.view.position.x < mHeroGameObject.view.position.x)
                  {
                     reviveTutorialPopupPosition = "TUTORIAL_PANEL_LEFT";
                  }
                  if(ownerHeroGO.heroStateMachine.currentStateName != "ActorReviveState")
                  {
                     mDungeonReviveTutorial = new DungeonTutorial(mDBFacade);
                     mDungeonReviveTutorial.showReviveTutorial(reviveTutorialPopupPosition);
                  }
               }
            }
         }
      }
      
      function checkIfHeroIsReadyAndInitReviveSensor(param1:GameClock) 
      {
         var _loc2_:B2CircleShape = null;
         if(mHeroGameObject != null && mHeroGameObject.distributedDungeonFloor != null)
         {
            _loc2_ = new B2CircleShape(100 / 50);
            mReviveTrigger = new HeroReviveSensor(mDBFacade,mHeroGameObject.distributedDungeonFloor,_loc2_,(mHeroGameObject.team : UInt));
            mReviveTrigger.position = mHeroGameObject.actorView.position;
            mReviveTrigger.callback = activateReviveUI;
            mReviveTrigger.finishedCallback = deActivateReviveUI;
            if(mLoadReviveTriggerTask != null)
            {
               mLoadReviveTriggerTask.destroy();
            }
            mLoadReviveTriggerTask = null;
         }
      }
      
      override public function exitState() 
      {
         if(mHitTabTween != null)
         {
            mHitTabTween.kill();
         }
         mHitTabTween = null;
         mSceneGraphComponent.removeChild(mHitTabClip);
         mHitTabClip = null;
         if(Std.isOfType(mHeroGameObject , HeroGameObjectOwner))
         {
            cast(mHeroGameObject, HeroGameObjectOwner).stopDeathCamInput();
         }
         mActorView.playAnim("revive",0,false,false);
         mActorGameObject.playEffectAtActor("Resources/Art2D/FX/db_fx_library.swf","db_fx_revive",1,"foreground");
         mActorView.reviveHighlight();
         mLogicalWorkComponent.doLater(0.1,removeHighlight);
         mDBFacade.regainFocus();
         mActorView.actionsForExitDeadState();
         if(mDBFacade.hud.offScreenPlayerManager != null)
         {
            mDBFacade.hud.offScreenPlayerManager.handlePicChange((mHeroGameObject.id : Int),"alive");
         }
         mLogicalWorkComponent.doLater(2,destroyReviveTutorial);
         this.destroyUI();
         super.exitState();
      }
      
      function removeHighlight(param1:GameClock = null) 
      {
         mActorView.reviveUnhighlight();
      }
      
      function activateReviveUI(param1:HeroGameObjectOwner) 
      {
         var heroGameObjectOwner= param1;
         if(heroGameObjectOwner != mHeroGameObject)
         {
            if(mKeyBoardInput == null)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),function(param1:SwfAsset)
               {
                  var _loc2_= param1.getClass("db_fx_revive_spacebar");
                  mKeyBoardInput = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
                  ASCompat.setProperty((mKeyBoardInput : ASAny).label, "text", Locale.getString("REVIVE_TRIGGER_BUTTON"));
                  mKeyBoardInput.x = mActorGameObject.position.x;
                  mKeyBoardInput.y = mActorGameObject.position.y;
                  mSceneGraphComponent.addChild(mKeyBoardInput,(30 : UInt));
               });
            }
            else
            {
               mKeyBoardInput.visible = true;
            }
            if(mSpaceBarReviveFunction == null)
            {
               mSpaceBarReviveFunction = function(param1:KeyboardEvent)
               {
                  reviveKeyEvent(param1,heroGameObjectOwner);
               };
            }
            mDBFacade.stageRef.removeEventListener("keyDown",mSpaceBarReviveFunction);
            mDBFacade.stageRef.addEventListener("keyDown",mSpaceBarReviveFunction);
         }
      }
      
      function deActivateReviveUI() 
      {
         if(mKeyBoardInput != null)
         {
            mKeyBoardInput.visible = false;
         }
         if(mSpaceBarReviveFunction != null)
         {
            mDBFacade.stageRef.removeEventListener("keyDown",mSpaceBarReviveFunction);
         }
      }
      
      function reviveKeyEvent(param1:KeyboardEvent, param2:HeroGameObjectOwner) 
      {
         if(param2 != null && param2.heroStateMachine != null && mHeroGameObject != null)
         {
            if(param1.keyCode == 32 && didPressReviveAction() && param2.heroStateMachine.currentSubState.name == "ActorNavigationState")
            {
               if(mSpaceBarTask != null)
               {
                  mSpaceBarTask.destroy();
               }
               mSpaceBarTask = null;
               param2.attemptRevive(mHeroGameObject);
               if(mDBFacade.facebookController != null && param2.playerID == mDBFacade.accountId)
               {
                  mDBFacade.facebookController.updateGuestAchievement((3 : UInt));
               }
               if(!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam() && mDungeonReviveTutorial != null)
               {
                  mEventComponent.dispatchEvent(new Event("REVIVE_SPACEBAR_PRESSED"));
               }
            }
         }
      }
      
      function didPressReviveAction() : Bool
      {
         return mDBFacade.inputManager.pressed(32) || mDBFacade.steamInputManager.pressedAction("revive_ally");
      }
      
      function initRevive() 
      {
      }
      
      function loadDeadPlayerUI() 
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"),function(param1:SwfAsset)
         {
            if(mHeroGameObject.distributedDungeonFloor.isInfiniteDungeon)
            {
               loadDeadPlayerUIStage2(param1);
            }
            else
            {
               buildOriginalPanel(param1);
            }
         });
      }
      
      function loadDeadPlayerUIStage2(param1:SwfAsset) 
      {
         var stage1Asset= param1;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),function(param1:SwfAsset)
         {
            if(mHeroGameObject.distributedDungeonFloor.isInfiniteDungeon)
            {
               buildLimitedHealthBombUsageRevivePanel(stage1Asset,param1);
            }
            else
            {
               buildOriginalPanel(param1);
            }
         });
      }
      
      public function desaturate(param1:DisplayObject) 
      {
         var _loc2_:Float = 0.212671;
         var _loc5_:Float = 0.71516;
         var _loc3_:Float = 0.072169;
         var _loc6_:Float = 0.7;
         var _loc4_:Float = 0.6;
         var _loc7_:Float = 0.5;
         var _loc8_:Array<ASAny> = [_loc2_ * _loc6_,_loc5_ * _loc6_,_loc3_ * _loc6_,0,0,_loc2_ * _loc4_,_loc5_ * _loc4_,_loc3_ * _loc4_,0,0,_loc2_ * _loc7_,_loc5_ * _loc7_,_loc3_ * _loc7_,0,0,0,0,0,1,0];
         param1.filters = cast([new ColorMatrixFilter(cast(_loc8_))]);
      }
      
      function buildLimitedHealthBombUsageRevivePanel(param1:SwfAsset, param2:SwfAsset) 
      {
         var __tmpAssignObj9:ASAny;
         var reviveMeCallback:ASFunction;
         var reviveAllCallback:ASFunction;
         var partyBombsOwned:StackableInfo;
         var ownedHealthBombs:StackableInfo;
         var healthBombCount:UInt;
         var partyBombCount:UInt;
         var hitTabClass:Dynamic;
         var rewardSlots:Vector<MovieClip>;
         var myHero:HeroGameObjectOwner;
         var myRewards:Vector<InfiniteRewardData>;
         var reward:InfiniteRewardData;
         var slotNumber:Int;
         var alreadyReceived:Bool;
         var dooberData:GMDoober;
         var gmChestItem:GMChest;
         var chestClass:Dynamic;
         var dooberMC:MovieClip;
         var dooberController:MovieClipRenderController;
         var swfAsset= param1;
         var chestAsset= param2;
         var healthBombCostMultiplier:Float = 1;
         var offer:GMOffer = null;
         var assetClass:Dynamic = null;
         assetClass = swfAsset.getClass("revive_prompt");
         mRevivePanel = ASCompat.dynamicAs(ASCompat.createInstance(assetClass, []), flash.display.MovieClip);
         mRevivePanel.x = mDBFacade.stageRef.stageWidth - mRevivePanel.width / 2.8;
         mRevivePanel.y += 169;
         mSceneGraphComponent.addChildAt(mRevivePanel,(105 : UInt),(0 : UInt));
         ASCompat.setProperty((mRevivePanel : ASAny).prompt_heading, "text", Locale.getString("REVIVE_PANEL_HEADER"));
         if(mHeroGameObject.distributedDungeonFloor.remoteHeroes.size > 0)
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_text_box, "text", Locale.getString("REVIVE_PANEL_INNER_MULTI_PLAYER"));
         }
         else
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_text_box, "text", Locale.getString("REVIVE_PANEL_INNER_SINGLE_PLAYER"));
         }
         mSelfReviveMeButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePanel : ASAny).prompt_button_1_buy_me, flash.display.MovieClip));
         mSelfReviveAllButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePanel : ASAny).prompt_button_1_buy_all, flash.display.MovieClip));
         mReturnToTownButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePanel : ASAny).prompt_button, flash.display.MovieClip));
         ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.use_buy_me, "text", "");
         ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.use_buy_me, "text", "");
         ASCompat.setProperty((mRevivePanel : ASAny).label_buy_me, "text", Locale.getString("REVIVE_PANEL_SELF_REVIVE_BUTTON"));
         ASCompat.setProperty((mRevivePanel : ASAny).label_buy_all, "text", Locale.getString("REVIVE_PANEL_PARTY_REVIVE_BUTTON"));
         partyBombsOwned = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(60018), account.StackableInfo);
         offer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(51369), gameMasterDictionary.GMOffer);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem((60018 : UInt)) && partyBombsOwned != null)
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cost_text_buy_me, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cash_icon_buy_me, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.use_buy_me, "text", Locale.getString("REVIVE_PANEL_USE"));
            reviveAllCallback = function()
            {
               mRevivePanel.visible = false;
               useRezAllPotion();
            };
         }
         else
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cost_text_buy_me, "visible", true);
            ASCompat.setProperty((mRevivePanel : ASAny).label_buy_all, "text", Locale.getString("REVIVE_PANEL_PARTY_REVIVE_BUTTON_NO_REZ_FROG"));
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0 != 0)
            {
               mSelfReviveAllButton.destroy();
               ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all, "visible", false);
            }
            ASCompat.setProperty((mSelfReviveAllButton.root : ASAny).cost_text_buy_me, "text", Std.string(offer.Price));
            reviveAllCallback = function()
            {
               if(offer.CurrencyType == "PREMIUM" && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  mRevivePanel.visible = false;
                  mRevivePanel.addEventListener("purchaseReviveAll-failed",handleReviveAllPurchaseFail);
               }
               buyReviveAll();
            };
         }
         mSelfReviveAllButton.releaseCallback = reviveAllCallback;
         if(mHeroGameObject.canUsePartyBombs())
         {
            mSelfReviveAllButton.enabled = true;
            ASCompat.setProperty((mSelfReviveAllButton.root : ASAny).cost_text_buy_me, "text", Std.string(offer.Price));
         }
         else
         {
            mSelfReviveAllButton.enabled = false;
            ASCompat.setProperty((mSelfReviveAllButton.root : ASAny).cost_text_buy_me, "text", Locale.getString("REVIVE_PANEL_USED_MAX_PARTY_BOMBS_BUY_BUTTON_TEXT"));
         }
         mReturnToTownButton.label.text = Locale.getString("REVIVE_PANEL_FORFEIT_BUTTON");
         ownedHealthBombs = null;
         ownedHealthBombs = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(60001), account.StackableInfo);
         healthBombCount = (0 : UInt);
         if(ownedHealthBombs != null)
         {
            healthBombCount = ownedHealthBombs.count;
         }
         ASCompat.setProperty((mRevivePanel : ASAny).quantity_hBomb, "text", Locale.getString("LIMITED_REVIVES_PANEL_HBOMBS_OWNED") + ": " + Std.string(healthBombCount));
         partyBombCount = (0 : UInt);
         if(partyBombsOwned != null)
         {
            partyBombCount = partyBombsOwned.count;
         }
         ASCompat.setProperty((mRevivePanel : ASAny).quantity_pBomb, "text", Locale.getString("LIMITED_REVIVES_PANEL_PBOMBS_OWNED") + ": " + Std.string(partyBombCount));
         offer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(51304), gameMasterDictionary.GMOffer);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem((60001 : UInt)) && ownedHealthBombs != null)
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cost_text_buy_me, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cash_icon_buy_me, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.use_buy_me, "text", Locale.getString("REVIVE_PANEL_USE"));
            reviveMeCallback = function()
            {
               mRevivePanel.visible = false;
               useRezMePotion();
            };
         }
         else
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cost_text_buy_me, "visible", true);
            ASCompat.setProperty((mRevivePanel : ASAny).label_buy_me, "text", Locale.getString("REVIVE_PANEL_SELF_REVIVE_BUTTON_NO_REZ_FROG"));
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0 != 0)
            {
               mSelfReviveMeButton.destroy();
               ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me, "visible", false);
               mSelfReviveMeButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePanel : ASAny).prompt_button_sale, flash.display.MovieClip));
               ASCompat.setProperty((mSelfReviveMeButton.root : ASAny).original_cost_text, "text", Std.string(Math.fround(offer.Price / healthBombCostMultiplier)));
               __tmpAssignObj9 = (mSelfReviveMeButton.root : ASAny).strike;
               ASCompat.setProperty(__tmpAssignObj9, "scaleX", __tmpAssignObj9.scaleX * ASCompat.toNumberField((mSelfReviveMeButton.root : ASAny).original_cost_text.text, "length") / 3);
            }
            ASCompat.setProperty((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, "text", Std.string(offer.Price));
            reviveMeCallback = function()
            {
               if(offer.CurrencyType == "PREMIUM" && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  mRevivePanel.visible = false;
               }
               buyReviveMe();
            };
         }
         mSelfReviveMeButton.releaseCallback = reviveMeCallback;
         if(mHeroGameObject.canUseHealthBombs())
         {
            mSelfReviveMeButton.enabled = true;
            ASCompat.setProperty((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, "text", Std.string(offer.Price));
         }
         else
         {
            mSelfReviveMeButton.enabled = false;
            ASCompat.setProperty((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, "text", Locale.getString("REVIVE_PANEL_USED_MAX_HEALTH_BOMBS_BUY_BUTTON_TEXT"));
         }
         mReturnToTownButton.label.text = Locale.getString("REVIVE_PANEL_FORFEIT_BUTTON");
         mReturnToTownButton.releaseCallback = function()
         {
            var _loc2_= mHeroGameObject.distributedDungeonFloor.completionXp;
            var _loc1_= new II_UIExitDungeonPopUp(mDBFacade,onForfeitClick,null);
         };
         hitTabClass = swfAsset.getClass("popup_keyboard_tab");
         mHitTabClip = ASCompat.dynamicAs(ASCompat.createInstance(hitTabClass, []) , MovieClip);
         mHitTabClip.x = -150;
         mHitTabClip.y = 250;
         ASCompat.setProperty((mHitTabClip : ASAny).label, "text", Locale.getString("HIT_TAB_TEXT"));
         mSceneGraphComponent.addChildAt(mHitTabClip,(105 : UInt),(0 : UInt));
         mHitTabTween = TweenMax.to(mHitTabClip,0.5,{
            "x":20,
            "y":mHitTabClip.y
         });
         rewardSlots = new Vector<MovieClip>();
         rewardSlots.push(ASCompat.dynamicAs((mRevivePanel : ASAny).current_reward.loot_01, flash.display.MovieClip));
         rewardSlots.push(ASCompat.dynamicAs((mRevivePanel : ASAny).current_reward.loot_02, flash.display.MovieClip));
         rewardSlots.push(ASCompat.dynamicAs((mRevivePanel : ASAny).current_reward.loot_03, flash.display.MovieClip));
         rewardSlots.push(ASCompat.dynamicAs((mRevivePanel : ASAny).current_reward.loot_04, flash.display.MovieClip));
         ASCompat.setProperty((mRevivePanel : ASAny).current_reward.coin_count, "text", Std.string(mHeroGameObject.distributedDungeonFloor.parentArea.infiniteTotalGold));
         myHero = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mDBFacade.dbAccountInfo.activeAvatarInfo.id) , HeroGameObjectOwner);
         myRewards = myHero.distributedDungeonFloor.parentArea.infiniteRewardData;
         slotNumber = 0;
         if (checkNullIteratee(myRewards)) for (_tmp_ in myRewards)
         {
            reward  = _tmp_;
            if(slotNumber < rewardSlots.length)
            {
               alreadyReceived = false;
               if(reward.status == 1)
               {
                  alreadyReceived = true;
               }
               else
               {
                  if(reward.status == 0)
                  {
                     break;
                  }
                  if(reward.status == 3)
                  {
                     continue;
                  }
               }
               dooberData = ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(reward.dooberId), gameMasterDictionary.GMDoober);
               gmChestItem = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(dooberData.ChestId), gameMasterDictionary.GMChest);
               chestClass = chestAsset.getClass(gmChestItem.IconName);
               dooberMC = ASCompat.dynamicAs(ASCompat.createInstance(chestClass, []), flash.display.MovieClip);
               if(slotNumber == 0)
               {
                  dooberMC.scaleY = 0.4;
                  dooberMC.scaleX = 0.4;
                  dooberMC.x -= 2;
               }
               else
               {
                  dooberMC.scaleY = 0.51;
                  dooberMC.scaleX = 0.51;
               }
               if(alreadyReceived)
               {
                  desaturate(dooberMC);
               }
               dooberController = new MovieClipRenderController(mDBFacade,dooberMC);
               dooberController.loop = false;
               dooberController.stop();
               rewardSlots[slotNumber].addChild(dooberMC);
               ASCompat.setProperty((rewardSlots[slotNumber] : ASAny).loot, "visible", false);
            }
            slotNumber = slotNumber + 1;
         }
         setUpLimitedHealthBombGUI((mHeroGameObject.healthBombUsesRemaining : UInt),mRevivePanel);
         setUpLimitedPartyBombGUI((mHeroGameObject.partyBombUsesRemaining : UInt),mRevivePanel);
      }
      
      function setUpLimitedHealthBombGUI(param1:UInt, param2:MovieClip) 
      {
         ASCompat.setProperty((param2 : ASAny).hBomb01, "visible", false);
         ASCompat.setProperty((param2 : ASAny).hBomb01_off, "visible", true);
         ASCompat.setProperty((param2 : ASAny).hBomb02, "visible", false);
         ASCompat.setProperty((param2 : ASAny).hBomb02_off, "visible", true);
         ASCompat.setProperty((param2 : ASAny).hBomb03, "visible", false);
         ASCompat.setProperty((param2 : ASAny).hBomb03_off, "visible", true);
         switch(param1 - 1)
         {
            case 0:
               ASCompat.setProperty((param2 : ASAny).hBomb01, "visible", true);
               ASCompat.setProperty((param2 : ASAny).hBomb01_off, "visible", false);
               
            case 1:
               ASCompat.setProperty((param2 : ASAny).hBomb01, "visible", true);
               ASCompat.setProperty((param2 : ASAny).hBomb01_off, "visible", false);
               ASCompat.setProperty((param2 : ASAny).hBomb02, "visible", true);
               ASCompat.setProperty((param2 : ASAny).hBomb02_off, "visible", false);
               
            case 2:
               ASCompat.setProperty((param2 : ASAny).hBomb01, "visible", true);
               ASCompat.setProperty((param2 : ASAny).hBomb01_off, "visible", false);
               ASCompat.setProperty((param2 : ASAny).hBomb02, "visible", true);
               ASCompat.setProperty((param2 : ASAny).hBomb02_off, "visible", false);
               ASCompat.setProperty((param2 : ASAny).hBomb03, "visible", true);
               ASCompat.setProperty((param2 : ASAny).hBomb03_off, "visible", false);
         }
      }
      
      function setUpLimitedPartyBombGUI(param1:UInt, param2:MovieClip) 
      {
         ASCompat.setProperty((param2 : ASAny).pBomb01, "visible", false);
         ASCompat.setProperty((param2 : ASAny).pBomb01_off, "visible", true);
         ASCompat.setProperty((param2 : ASAny).pBomb02, "visible", false);
         ASCompat.setProperty((param2 : ASAny).pBomb02_off, "visible", true);
         ASCompat.setProperty((param2 : ASAny).pBomb03, "visible", false);
         ASCompat.setProperty((param2 : ASAny).pBomb03_off, "visible", true);
         switch(param1 - 1)
         {
            case 0:
               ASCompat.setProperty((param2 : ASAny).pBomb01, "visible", true);
               ASCompat.setProperty((param2 : ASAny).pBomb01_off, "visible", false);
               
            case 1:
               ASCompat.setProperty((param2 : ASAny).pBomb01, "visible", true);
               ASCompat.setProperty((param2 : ASAny).pBomb01_off, "visible", false);
               ASCompat.setProperty((param2 : ASAny).pBomb02, "visible", true);
               ASCompat.setProperty((param2 : ASAny).pBomb02_off, "visible", false);
               
            case 2:
               ASCompat.setProperty((param2 : ASAny).pBomb01, "visible", true);
               ASCompat.setProperty((param2 : ASAny).pBomb01_off, "visible", false);
               ASCompat.setProperty((param2 : ASAny).pBomb02, "visible", true);
               ASCompat.setProperty((param2 : ASAny).pBomb02_off, "visible", false);
               ASCompat.setProperty((param2 : ASAny).pBomb03, "visible", true);
               ASCompat.setProperty((param2 : ASAny).pBomb03_off, "visible", false);
         }
      }
      
      function buildOriginalPanel(param1:SwfAsset) 
      {
         var __tmpAssignObj10:ASAny;
         var reviveMeCallback:ASFunction;
         var reviveAllCallback:ASFunction;
         var partyBomb:StackableInfo;
         var hitTabClass:Dynamic;
         var swfAsset= param1;
         var healthBombCostMultiplier:Float = 1;
         var offer:GMOffer = null;
         var assetClass:Dynamic = null;
         var healthBomb:StackableInfo = null;
         assetClass = swfAsset.getClass("DR_revive_prompt");
         mRevivePanel = ASCompat.dynamicAs(ASCompat.createInstance(assetClass, []), flash.display.MovieClip);
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePanel : ASAny).revive_king.revive_chat_balloon.close, flash.display.MovieClip));
         mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mCloseButton.releaseCallback = function()
         {
            mRevivePanel.removeChild(ASCompat.dynamicAs((mRevivePanel : ASAny).revive_king, flash.display.DisplayObject));
         };
         ASCompat.setProperty((mRevivePanel : ASAny).revive_king.revive_chat_balloon, "king_title", Locale.getString("KING_REVIVE_TITLE"));
         ASCompat.setProperty((mRevivePanel : ASAny).revive_king.revive_chat_balloon, "king_text", Locale.getString("KING_REVIVE_MESSAGE"));
         mSceneGraphComponent.addChildAt(mRevivePanel,(105 : UInt),(0 : UInt));
         mRevivePanel.x = mDBFacade.viewWidth - mRevivePanel.width / 2;
         mRevivePanel.y = mDBFacade.viewHeight - mRevivePanel.height / 2;
         ASCompat.setProperty((mRevivePanel : ASAny).revive_king, "scaleX", ASCompat.setProperty((mRevivePanel : ASAny).revive_king, "scaleY", 1.8));
         ASCompat.setProperty((mRevivePanel : ASAny).revive_king, "x", -1350);
         ASCompat.setProperty((mRevivePanel : ASAny).revive_king, "y", -100);
         ASCompat.setProperty((mRevivePanel : ASAny).prompt_heading, "text", Locale.getString("REVIVE_PANEL_HEADER"));
         if(mHeroGameObject.distributedDungeonFloor.remoteHeroes.size > 0)
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_text_box, "text", Locale.getString("REVIVE_PANEL_INNER_MULTI_PLAYER"));
         }
         else
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_text_box, "text", Locale.getString("REVIVE_PANEL_INNER_SINGLE_PLAYER"));
         }
         mSelfReviveMeButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePanel : ASAny).prompt_button_1_buy_me, flash.display.MovieClip));
         mSelfReviveAllButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePanel : ASAny).prompt_button_1_buy_all, flash.display.MovieClip));
         mReturnToTownButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePanel : ASAny).prompt_button_2, flash.display.MovieClip));
         ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.use_buy_me, "text", "");
         ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.use_buy_all, "text", "");
         ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.stackable_buy_me, "text", "");
         ASCompat.setProperty((mRevivePanel : ASAny).label_buy_me, "text", Locale.getString("REVIVE_PANEL_SELF_REVIVE_BUTTON"));
         ASCompat.setProperty((mRevivePanel : ASAny).label_buy_all, "text", Locale.getString("REVIVE_PANEL_PARTY_REVIVE_BUTTON"));
         partyBomb = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(60018), account.StackableInfo);
         offer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(51369), gameMasterDictionary.GMOffer);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem((60018 : UInt)) && partyBomb != null)
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.stackable_buy_all, "text", "X" + Std.string(partyBomb.count));
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cost_text_buy_all, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cash_icon_buy_me, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.use_buy_all, "text", Locale.getString("REVIVE_PANEL_USE"));
            reviveAllCallback = function()
            {
               mRevivePanel.visible = false;
               useRezAllPotion();
            };
         }
         else
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.cost_text_buy_all, "visible", true);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.stackable_buy_all, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).label_buy_all, "text", Locale.getString("REVIVE_PANEL_PARTY_REVIVE_BUTTON_NO_REZ_FROG"));
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0 != 0)
            {
               mSelfReviveAllButton.destroy();
               ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all, "visible", false);
            }
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_all.stackable_buy_all, "text", "0");
            ASCompat.setProperty((mSelfReviveAllButton.root : ASAny).cost_text_buy_all, "text", Std.string(offer.Price));
            reviveAllCallback = function()
            {
               if(offer.CurrencyType == "PREMIUM" && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  mRevivePanel.visible = false;
                  mRevivePanel.addEventListener("purchaseReviveAll-failed",handleReviveAllPurchaseFail);
               }
               buyReviveAll();
            };
         }
         mSelfReviveAllButton.releaseCallback = reviveAllCallback;
         if(mHeroGameObject.canUsePartyBombs())
         {
            mSelfReviveAllButton.enabled = true;
            ASCompat.setProperty((mSelfReviveAllButton.root : ASAny).cost_text_buy_all, "text", Std.string(offer.Price));
         }
         else
         {
            mSelfReviveAllButton.enabled = false;
            ASCompat.setProperty((mSelfReviveAllButton.root : ASAny).cost_text_buy_all, "text", Locale.getString("REVIVE_PANEL_USED_MAX_PARTY_BOMBS_BUY_BUTTON_TEXT"));
         }
         mReturnToTownButton.label.text = Locale.getString("REVIVE_PANEL_FORFEIT_BUTTON");
         healthBomb = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.stackablesByStackableID.itemFor(60001), account.StackableInfo);
         offer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(51304), gameMasterDictionary.GMOffer);
         if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem((60001 : UInt)) && healthBomb != null)
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.stackable_buy_me, "text", "X" + Std.string(healthBomb.count));
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cost_text_buy_me, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cash_icon_buy_me, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.use_buy_me, "text", Locale.getString("REVIVE_PANEL_USE"));
            reviveMeCallback = function()
            {
               mRevivePanel.visible = false;
               useRezMePotion();
            };
         }
         else
         {
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.cost_text_buy_me, "visible", true);
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.stackable_buy_me, "visible", false);
            ASCompat.setProperty((mRevivePanel : ASAny).label_buy_me, "text", Locale.getString("REVIVE_PANEL_SELF_REVIVE_BUTTON_NO_REZ_FROG"));
            healthBombCostMultiplier = getHealthBombSplitTestMultiplier();
            if(healthBombCostMultiplier < 1 && 0 != 0)
            {
               mSelfReviveMeButton.destroy();
               ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me, "visible", false);
               mSelfReviveMeButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePanel : ASAny).prompt_button_sale, flash.display.MovieClip));
               ASCompat.setProperty((mSelfReviveMeButton.root : ASAny).original_cost_text, "text", Std.string(Math.fround(offer.Price / healthBombCostMultiplier)));
               __tmpAssignObj10 = (mSelfReviveMeButton.root : ASAny).strike;
               ASCompat.setProperty(__tmpAssignObj10, "scaleX", __tmpAssignObj10.scaleX * ASCompat.toNumberField((mSelfReviveMeButton.root : ASAny).original_cost_text.text, "length") / 3);
            }
            ASCompat.setProperty((mRevivePanel : ASAny).prompt_button_1_buy_me.stackable_buy_me, "text", "0");
            ASCompat.setProperty((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, "text", Std.string(offer.Price));
            reviveMeCallback = function()
            {
               if(offer.CurrencyType == "PREMIUM" && mDBFacade.dbAccountInfo.premiumCurrency >= offer.Price)
               {
                  mRevivePanel.visible = false;
               }
               buyReviveMe();
            };
         }
         mSelfReviveMeButton.releaseCallback = reviveMeCallback;
         if(mHeroGameObject.canUseHealthBombs())
         {
            mSelfReviveMeButton.enabled = true;
            ASCompat.setProperty((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, "text", Std.string(offer.Price));
         }
         else
         {
            mSelfReviveMeButton.enabled = false;
            ASCompat.setProperty((mSelfReviveMeButton.root : ASAny).cost_text_buy_me, "text", Locale.getString("REVIVE_PANEL_USED_MAX_HEALTH_BOMBS_BUY_BUTTON_TEXT"));
         }
         mReturnToTownButton.label.text = Locale.getString("REVIVE_PANEL_FORFEIT_BUTTON");
         mReturnToTownButton.releaseCallback = function()
         {
            var _loc2_= mHeroGameObject.distributedDungeonFloor.completionXp;
            var _loc1_= new UILootLossPopup(mDBFacade,_loc2_,mHeroGameObject.distributedDungeonFloor.treasureCollected,onForfeitClick,null);
            MemoryTracker.track(_loc1_,"UILootLossPopup - created in ActorReviveState.loadedAssets()");
         };
         hitTabClass = swfAsset.getClass("popup_keyboard_tab");
         mHitTabClip = ASCompat.dynamicAs(ASCompat.createInstance(hitTabClass, []) , MovieClip);
         mHitTabClip.x = -150;
         mHitTabClip.y = 250;
         ASCompat.setProperty((mHitTabClip : ASAny).label, "text", Locale.getString("HIT_TAB_TEXT"));
         mSceneGraphComponent.addChildAt(mHitTabClip,(105 : UInt),(0 : UInt));
         mHitTabTween = TweenMax.to(mHitTabClip,0.5,{
            "x":20,
            "y":mHitTabClip.y
         });
      }
      
      function handleReviveAllPurchaseFail(param1:Event) 
      {
         mRevivePanel.visible = false;
      }
      
      function getHealthBombSplitTestMultiplier() : Float
      {
         return mDBFacade.getSplitTestNumber("InDungeonHealthBombSale",1);
      }
      
      function startLogMetrics(param1:String) 
      {
         var _loc2_:ASObject = {};
         ASCompat.setProperty(_loc2_, "buttonDesc", param1);
         ASCompat.setProperty(_loc2_, "areaType", "Dungeon");
         logMetrics("ButtonClick",_loc2_);
      }
      
      function onForfeitClick() 
      {
         var metricsObject:ASObject = {};
         ASCompat.setProperty(metricsObject, "buttonDesc", "Revive Exit Button Clicked");
         ASCompat.setProperty(metricsObject, "areaType", "Dungeon");
         logMetrics("ButtonClick",metricsObject);
         Logger.debug("ActorReviveState -- Starting Clean Shutdown");
         mLogicalWorkComponent.doLater(5,function()
         {
            mDBFacade.mainStateMachine.enterReloadTownState();
         });
         mDBFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
         mDBFacade.hud.chatLog.hideChatLog();
         this.destroyUI();
      }
      
      public function useRezMePotion() 
      {
         startLogMetrics("Rez Potion Button Clicked");
         ASCompat.reinterpretAs(mHeroGameObject , HeroGameObjectOwner).proposeSelfRevive((0 : UInt));
      }
      
      public function buyReviveMe() 
      {
         startLogMetrics("Buy Revive Button Clicked");
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(51304), gameMasterDictionary.GMOffer);
         StoreServicesController.tryBuyOffer(mDBFacade,_loc1_,buyReviveMeSuccess);
      }
      
      public function buyReviveMeSuccess(param1:ASAny) 
      {
         ASCompat.reinterpretAs(mHeroGameObject , HeroGameObjectOwner).proposeSelfRevive((0 : UInt));
      }
      
      public function useRezAllPotion() 
      {
         startLogMetrics("Rez Potion Button Clicked");
         ASCompat.reinterpretAs(mHeroGameObject , HeroGameObjectOwner).proposeSelfRevive((1 : UInt));
      }
      
      public function buyReviveAll() 
      {
         startLogMetrics("Buy Revive Button Clicked");
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(51369), gameMasterDictionary.GMOffer);
         StoreServicesController.tryBuyOffer(mDBFacade,_loc1_,buyReviveAllSuccess);
      }
      
      public function buyReviveAllSuccess(param1:ASAny) 
      {
         ASCompat.reinterpretAs(mHeroGameObject , HeroGameObjectOwner).proposeSelfRevive((1 : UInt));
      }
      
      public function destroyUI() 
      {
         if(Std.isOfType(mHeroGameObject , HeroGameObjectOwner))
         {
            saturate(100);
         }
         if(mLoadReviveTriggerTask != null)
         {
            mLoadReviveTriggerTask.destroy();
            mLoadReviveTriggerTask = null;
         }
         if(mSpaceBarTask != null)
         {
            mSpaceBarTask.destroy();
            mSpaceBarTask = null;
         }
         if(mDeadPlayerEffect != null)
         {
            if(mHeroGameObject.view.root.contains(mDeadPlayerEffect))
            {
               mHeroGameObject.view.root.removeChild(mDeadPlayerEffect);
            }
            mDeadPlayerEffect = null;
         }
         if(mKeyBoardInput != null)
         {
            mSceneGraphComponent.removeChild(mKeyBoardInput);
            mKeyBoardInput = null;
         }
         if(mSpaceBarReviveFunction != null)
         {
            mDBFacade.stageRef.removeEventListener("keyDown",mSpaceBarReviveFunction);
            mSpaceBarReviveFunction = null;
         }
         if(mReviveTrigger != null)
         {
            mReviveTrigger.destroy();
            mReviveTrigger = null;
         }
         if(mRevivePanel != null)
         {
            mSceneGraphComponent.removeChild(mRevivePanel);
            if(mSelfReviveMeButton != null)
            {
               mSelfReviveMeButton.destroy();
               mSelfReviveMeButton = null;
            }
            if(mReturnToTownButton != null)
            {
               mReturnToTownButton.destroy();
               mReturnToTownButton = null;
            }
            if(mCloseButton != null)
            {
               mCloseButton.destroy();
               mCloseButton = null;
            }
            mRevivePanel = null;
         }
      }
      
      function destroyReviveTutorial(param1:GameClock = null) 
      {
         if(mDungeonReviveTutorial != null)
         {
            mDungeonReviveTutorial.destroy();
         }
         mDungeonReviveTutorial = null;
      }
      
      override public function destroy() 
      {
         this.destroyUI();
         mHeroGameObject = null;
         destroyReviveTutorial();
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
         super.destroy();
      }
      
      public function logMetrics(param1:String, param2:ASObject) 
      {
         ASCompat.setProperty(param2, "areaId", mHeroGameObject.distributedDungeonFloor.id);
         mDBFacade.metrics.log(param1,param2);
      }
      
      function saturate(param1:Float) 
      {
         var _loc2_:Array<ASAny> = [50,105];
         mSceneGraphComponent.saturateLayers(param1,_loc2_);
      }
   }


