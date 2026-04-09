package stateMachine.mainStateMachine
;
   import actor.player.input.DungeonBusterControlActivatedEvent;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.event.EventComponent;
   import brain.render.MovieClipRenderer;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.workLoop.LogicalWorkComponent;
   import facade.DBFacade;
   import facade.Locale;
   import com.greensock.TimelineMax;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
    class DungeonTutorial
   {
      
      public static inline final MOVEMENT_TUTORIAL= "MOVEMENT_TUTORIAL";
      
      public static inline final BUSTER_TUTORIAL= "BUSTER_TUTORIAL";
      
      public static inline final CHARGE_TUTORIAL= "CHARGE_TUTORIAL";
      
      public static inline final REVIVE_TUTORIAL= "REVIVE_TUTORIAL";
      
      public static inline final LOOT_SHARING_TUTORIAL= "LOOT_SHARING_TUTORIAL";
      
      public static inline final SUPER_WEAK_TUTORIAL= "SUPER_WEAK_TUTORIAL";
      
      public static inline final TUTORIAL_PANEL_LEFT= "TUTORIAL_PANEL_LEFT";
      
      public static inline final TUTORIAL_PANEL_RIGHT= "TUTORIAL_PANEL_RIGHT";
      
      public static inline final REVIVE_SPACEBAR_PRESSED_EVENT= "REVIVE_SPACEBAR_PRESSED";
      
      public static inline final CHEST_TUTORIAL_NEARBY= "CHEST_TUTORIAL_NEARBY";
      
      public static inline final CHEST_TUTORIAL_COLLECTED= "CHEST_TUTORIAL_COLLECTED";
      
      public static inline final COOLDOWN_TUTORIAL= "COOLDOWN_TUTORIAL";
      
      public static inline final SCALING_TUTORIAL= "SCALING_TUTORIAL";
      
      public static inline final REPEATER_TUTORIAL= "REPEATER_TUTORIAL";
      
      static inline final ATTACK_POPUP_DELAY:Float = 1;
      
      static inline final TUTORIAL_SWF= "Resources/Art2D/UI/db_UI_screens.swf";
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mMovementTutorialDone:Bool = false;
      
      var mMovementPopup:MovieClip;
      
      var mAttackTutorialDone:Bool = false;
      
      var mAttackPopup:MovieClip;
      
      var mChestTutorialDone:Bool = false;
      
      var mChestCloseButton:UIButton;
      
      var mChestPopup:MovieClip;
      
      var mCooldownRenderer:MovieClipRenderer;
      
      var mCooldownTutorialReadyToClose:Bool = false;
      
      var mScalingTutorialReadyToClose:Bool = false;
      
      var mRepeaterTutorialReadyToClose:Bool = false;
      
      var mChargeTutorialReadyToClose:Bool = false;
      
      var mCooldownTutorialDone:Bool = false;
      
      var mScalingTutorialDone:Bool = false;
      
      var mRepeaterTutorialDone:Bool = false;
      
      var mChargeTutorialDone:Bool = false;
      
      var mBusterTutorialDone:Bool = false;
      
      var mBusterCloseButton:UIButton;
      
      var mBusterPopup:MovieClip;
      
      var mChargeCloseButton:UIButton;
      
      var mChargePopup:MovieClip;
      
      var mReviveTutorialDone:Bool = false;
      
      var mReviveCloseButton:UIButton;
      
      var mRevivePopup:MovieClip;
      
      var mRevivePopupPosition:String;
      
      var mLootSharingTutorialDone:Bool = false;
      
      var mLootSharingCloseButton:UIButton;
      
      var mLootSharingPopup:MovieClip;
      
      var mSuperWeakTutorialDone:Bool = false;
      
      var mSuperWeakCloseButton:UIButton;
      
      var mSuperWeakPopup:MovieClip;
      
      var mTutorialComplete:Bool = false;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mDBFacade.stageRef.addEventListener("keyDown",handleKeyDown);
         mDBFacade.stageRef.addEventListener("mouseDown",handleMouseDown);
         mEventComponent.addListener("DungeonBusterControlActivatedEvent",handleBuster);
         mEventComponent.addListener("REVIVE_SPACEBAR_PRESSED",handleRevive);
         if(mDBFacade.dbAccountInfo.dbAccountParams.hasMovementTutorialParam())
         {
            mMovementTutorialDone = true;
         }
      }
      
      public function destroy() 
      {
         mDBFacade.stageRef.removeEventListener("keyDown",handleKeyDown);
         mDBFacade.stageRef.removeEventListener("mouseDown",handleMouseDown);
         this.destroyChestTutorial();
         this.destroyMovementTutorial();
         this.destroyAttackTutorial();
         this.destroyBusterTutorial();
         this.destroyChargeTutorial();
         this.destroyReviveTutorial();
         this.destroyLootSharingTutorial();
         this.destroySuperWeakTutorial();
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
         mDBFacade = null;
      }
      
      function handleMouseDown(param1:MouseEvent) 
      {
         if(mMovementPopup != null && !mMovementTutorialDone)
         {
            this.advanceToAttackTutorial();
         }
      }
      
      function handleKeyDown(param1:KeyboardEvent) 
      {
         switch(param1.keyCode)
         {
            case 27:
               if(mAttackPopup != null && !mAttackTutorialDone)
               {
                  this.finishAttackTutorial();
               }
               if(mMovementPopup != null && !mMovementTutorialDone)
               {
                  this.advanceToAttackTutorial();
               }
               if(mChestPopup != null && !mChestTutorialDone)
               {
                  this.finishChestTutorial();
               }
               if(mChestPopup != null && !mCooldownTutorialDone)
               {
                  this.finishCooldownTutorial();
               }
               if(mChestPopup != null && !mScalingTutorialDone)
               {
                  this.finishScalingTutorial();
               }
               if(mChestPopup != null && !mRepeaterTutorialDone)
               {
                  this.finishRepeaterTutorial();
               }
               if(mBusterPopup != null && !mBusterTutorialDone)
               {
                  this.finishBusterTutorial();
               }
               if(mChargePopup != null && !mChargeTutorialDone)
               {
                  this.finishChargeTutorial();
               }
               
            case 90
               | 88
               | 67
               | 74
               | 75
               | 76:
               if(mAttackPopup != null && !mAttackTutorialDone)
               {
                  this.finishAttackTutorial();
               }
               if(mChestPopup != null && !mCooldownTutorialDone)
               {
                  this.finishCooldownTutorial();
               }
               if(mChestPopup != null && !mScalingTutorialDone)
               {
                  this.finishScalingTutorial();
               }
               if(mChestPopup != null && !mRepeaterTutorialDone)
               {
                  this.finishRepeaterTutorial();
               }
               if(mChargePopup != null && !mChargeTutorialDone)
               {
                  this.finishChargeTutorial();
               }
               
            case 66:
               if(mBusterPopup != null && !mBusterTutorialDone)
               {
                  this.finishBusterTutorial();
               }
               
            case 38
               | 40
               | 39
               | 87
               | 83
               | 68
               | 65
               | 37:
               if(mMovementPopup != null && !mMovementTutorialDone)
               {
                  this.advanceToAttackTutorial();
               }
         }
      }
      
      function handleBuster(param1:DungeonBusterControlActivatedEvent) 
      {
         if(mBusterPopup != null && !mBusterTutorialDone)
         {
            this.finishBusterTutorial();
         }
      }
      
      function handleRevive(param1:Event) 
      {
         if(mRevivePopup != null && !mReviveTutorialDone)
         {
            this.finishReviveTutorial();
         }
      }
      
      function timelineAttackAdvance() 
      {
         destroyMovementTutorial();
         showAttackTutorial();
      }
      
      public function advanceToAttackTutorial() 
      {
         mMovementTutorialDone = true;
         ASCompat.setProperty((mMovementPopup : ASAny).check, "visible", true);
         var _loc1_= mMovementPopup.x;
         var _loc3_= mDBFacade.viewWidth + mMovementPopup.width;
         var _loc2_= mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mMovementPopup,0.08333333333333333,{
               "delay":1,
               "x":_loc1_ - 20,
               "y":_loc2_
            }),TweenMax.to(mMovementPopup,0.3333333333333333,{
               "x":_loc3_,
               "y":_loc2_
            }),TweenMax.delayedCall(1.5,timelineAttackAdvance)],
            "align":"sequence"
         });
      }
      
      function destroyMovementTutorial() 
      {
         if(mMovementPopup != null)
         {
            TweenMax.killDelayedCallsTo(timelineAttackAdvance);
            TweenMax.killTweensOf(mMovementPopup);
            mSceneGraphComponent.removeChild(mMovementPopup);
            mMovementPopup = null;
         }
      }
      
      public function showMovementTutorial() 
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass("tutorial_movement");
            if(_loc3_ == null)
            {
               return;
            }
            mMovementPopup = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            ASCompat.setProperty((mMovementPopup : ASAny).title, "text", Locale.getString("TUTORIAL_MOVEMENT_TITLE"));
            ASCompat.setProperty((mMovementPopup : ASAny).check, "visible", false);
            mSceneGraphComponent.addChild(mMovementPopup,(105 : UInt));
            mMovementPopup.scaleX = mMovementPopup.scaleY = 0.85;
            var _loc2_= mDBFacade.viewWidth - mMovementPopup.width * 0.5 - 50;
            var _loc4_= mDBFacade.viewHeight * 0.5;
            mMovementPopup.x = mDBFacade.viewWidth + mMovementPopup.width;
            mMovementPopup.y = _loc4_;
            new TimelineMax({
               "tweens":[TweenMax.to(mMovementPopup,0.3333333333333333,{
                  "x":_loc2_ - 20,
                  "y":_loc4_
               }),TweenMax.to(mMovementPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      function finishAttackTutorial() 
      {
         var advanceFunc:ASFunction;
         var curX:Float;
         var offscreenX:Float;
         var offscreenY:Float;
         if(!mAttackTutorialDone)
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setMovementTutorialParam();
         }
         mAttackTutorialDone = true;
         ASCompat.setProperty((mAttackPopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroyAttackTutorial();
         };
         curX = mAttackPopup.x;
         offscreenX = -mAttackPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mAttackPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mAttackPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      function destroyAttackTutorial() 
      {
         if(mAttackPopup != null)
         {
            TweenMax.killTweensOf(mAttackPopup);
            mSceneGraphComponent.removeChild(mAttackPopup);
            mAttackPopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showAttackTutorial() 
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass("tutorial_attack");
            if(_loc3_ == null)
            {
               return;
            }
            mAttackPopup = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            ASCompat.setProperty((mAttackPopup : ASAny).title, "text", Locale.getString("TUTORIAL_ATTACK_TITLE"));
            ASCompat.setProperty((mAttackPopup : ASAny).check, "visible", false);
            mSceneGraphComponent.addChild(mAttackPopup,(105 : UInt));
            mAttackPopup.scaleX = mAttackPopup.scaleY = 0.85;
            var _loc2_= mAttackPopup.width * 0.5 + 10;
            var _loc4_= mDBFacade.viewHeight * 0.5;
            mAttackPopup.x = -mAttackPopup.width;
            mAttackPopup.y = _loc4_;
            new TimelineMax({
               "tweens":[TweenMax.to(mAttackPopup,0.3333333333333333,{
                  "x":_loc2_ + 20,
                  "y":_loc4_
               }),TweenMax.to(mAttackPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      function finishReviveTutorial() 
      {
         var advanceFunc:ASFunction;
         var destX:Float;
         var bounceOffset:Float;
         var curX:Float;
         mReviveTutorialDone = true;
         ASCompat.setProperty((mRevivePopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroyReviveTutorial();
         };
         curX = mRevivePopup.x;
         if(mRevivePopupPosition == "TUTORIAL_PANEL_RIGHT")
         {
            destX = mDBFacade.viewWidth + mRevivePopup.width;
            bounceOffset = -20;
         }
         else
         {
            destX = -mRevivePopup.width;
            bounceOffset = 20;
         }
         new TimelineMax({
            "tweens":[TweenMax.to(mRevivePopup,0.08333333333333333,{
               "delay":1,
               "x":curX + bounceOffset
            }),TweenMax.to(mRevivePopup,0.3333333333333333,{
               "x":destX,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      function destroyReviveTutorial() 
      {
         if(mRevivePopup != null)
         {
            TweenMax.killTweensOf(mRevivePopup);
            mSceneGraphComponent.removeChild(mRevivePopup);
            mRevivePopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showReviveTutorial(param1:String) 
      {
         var popupPosition= param1;
         if(mRevivePopup != null)
         {
            return;
         }
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam())
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setReviveTutorialParam();
         }
         mRevivePopupPosition = popupPosition;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= Math.NaN;
            var _loc2_= Math.NaN;
            var _loc4_= param1.getClass("tutorial_revive");
            if(_loc4_ == null)
            {
               return;
            }
            mRevivePopup = ASCompat.dynamicAs(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
            ASCompat.setProperty((mRevivePopup : ASAny).title, "text", Locale.getString("TUTORIAL_REVIVE_TITLE"));
            ASCompat.setProperty((mRevivePopup : ASAny).description, "text", Locale.getString("TUTORIAL_REVIVE_DESCRIPTION"));
            ASCompat.setProperty((mRevivePopup : ASAny).check, "visible", false);
            mReviveCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRevivePopup : ASAny).close, flash.display.MovieClip));
            mReviveCloseButton.releaseCallback = finishReviveTutorial;
            mSceneGraphComponent.addChild(mRevivePopup,(105 : UInt));
            mRevivePopup.scaleX = mRevivePopup.scaleY = 0.85;
            mRevivePopup.y = mDBFacade.viewHeight * 0.5;
            if(mRevivePopupPosition == "TUTORIAL_PANEL_RIGHT")
            {
               mRevivePopup.x = mDBFacade.viewWidth + mRevivePopup.width / 2;
               _loc3_ = mDBFacade.viewWidth - mRevivePopup.width / 2 + 25;
               _loc2_ = -20;
            }
            else
            {
               mRevivePopup.x = 0 - mRevivePopup.width / 2;
               _loc3_ = mRevivePopup.width / 2;
               _loc2_ = 20;
            }
            new TimelineMax({
               "tweens":[TweenMax.to(mRevivePopup,0.3333333333333333,{"x":_loc3_ + _loc2_}),TweenMax.to(mRevivePopup,0.08333333333333333,{"x":_loc3_})],
               "align":"sequence"
            });
         });
      }
      
      function finishLootSharingTutorial() 
      {
         var advanceFunc:ASFunction;
         var curX:Float;
         var offscreenX:Float;
         var offscreenY:Float;
         mLootSharingTutorialDone = true;
         ASCompat.setProperty((mLootSharingPopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroyLootSharingTutorial();
         };
         curX = mLootSharingPopup.x;
         offscreenX = mDBFacade.stageRef.stageWidth;
         offscreenY = mDBFacade.viewHeight * 0.3;
         new TimelineMax({
            "tweens":[TweenMax.to(mLootSharingPopup,0.08333333333333333,{
               "delay":1,
               "x":curX - 40,
               "y":offscreenY
            }),TweenMax.to(mLootSharingPopup,0.3333333333333333,{
               "x":offscreenX - 40,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      function destroyLootSharingTutorial() 
      {
         if(mLootSharingPopup != null)
         {
            TweenMax.killTweensOf(mLootSharingPopup);
            mSceneGraphComponent.removeChild(mLootSharingPopup);
            mLootSharingPopup = null;
         }
         mTutorialComplete = true;
      }
      
      function finishSuperWeakTutorial(param1:String, param2:Bool = true) 
      {
         var advanceFunc:ASFunction;
         var curX:Float;
         var sign:Int;
         var offscreenX:Float;
         var offscreenY:Float;
         var className= param1;
         var isRight= param2;
         ASCompat.setProperty((mSuperWeakPopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroySuperWeakTutorial();
            if(className == "tutorial_enemy_defense1")
            {
               showSuperWeakTutorial("tutorial_enemy_defense2",false);
            }
            else if(className == "tutorial_enemy_defense2")
            {
               showSuperWeakTutorial("tutorial_enemy_defense3");
            }
            else if(className == "tutorial_enemy_defense3")
            {
               showSuperWeakTutorial("tutorial_enemy_defense4",false);
            }
            else
            {
               mSuperWeakTutorialDone = true;
            }
         };
         curX = mSuperWeakPopup.x;
         sign = isRight ? 1 : -1;
         offscreenX = isRight ? 900 : -100;
         offscreenY = mSuperWeakPopup.y;
         new TimelineMax({
            "tweens":[TweenMax.to(mSuperWeakPopup,0.08333333333333333,{
               "delay":1,
               "x":curX - sign * 40,
               "y":offscreenY
            }),TweenMax.to(mSuperWeakPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      function destroySuperWeakTutorial() 
      {
         if(mSuperWeakPopup != null)
         {
            TweenMax.killTweensOf(mSuperWeakPopup);
            mSceneGraphComponent.removeChild(mSuperWeakPopup);
            mSuperWeakPopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showLootSharingTutorial() 
      {
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasLootSharingTutorialParam())
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setLootSharingTutorialParam();
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var swfAsset= param1;
            var popupClass= swfAsset.getClass("tutorial_loot_alt");
            if(popupClass == null)
            {
               return;
            }
            mLootSharingPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
            ASCompat.setProperty((mLootSharingPopup : ASAny).title, "text", Locale.getString("TUTORIAL_LOOT_TITLE"));
            ASCompat.setProperty((mLootSharingPopup : ASAny).shared_text, "text", Locale.getString("TUTORIAL_LOOT_SHARED"));
            ASCompat.setProperty((mLootSharingPopup : ASAny).not_shared_text, "text", Locale.getString("TUTORIAL_LOOT_NOT_SHARED"));
            ASCompat.setProperty((mLootSharingPopup : ASAny).check, "visible", false);
            mLootSharingCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mLootSharingPopup : ASAny).close, flash.display.MovieClip));
            mLootSharingCloseButton.releaseCallback = finishLootSharingTutorial;
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),function(param1:brain.assetRepository.SwfAsset)
            {
               var xpStar:MovieClip;
               var dbStar:MovieClip;
               var food:MovieClip;
               var treasureMC:MovieClip;
               var destX:Float;
               var destY:Float;
               var swfAsset2= param1;
               var gold3= swfAsset2.getClass("doober_currency_coin");
               var xp= swfAsset2.getClass("doober_xp_star");
               var db= swfAsset2.getClass("doober_db_star");
               var treasure= swfAsset2.getClass("db_doobers_treasure_chest_basic_static");
               var foodClass= swfAsset2.getClass("doober_health_burger");
               var gold= ASCompat.dynamicAs(ASCompat.createInstance(gold3, []), flash.display.MovieClip);
               gold.scaleX = gold.scaleY = 0.75;
               xpStar = ASCompat.dynamicAs(ASCompat.createInstance(xp, []), flash.display.MovieClip);
               xpStar.scaleX = xpStar.scaleY = 1;
               xpStar.x += 10;
               xpStar.y -= 10;
               dbStar = ASCompat.dynamicAs(ASCompat.createInstance(db, []), flash.display.MovieClip);
               dbStar.scaleX = dbStar.scaleY = 1.75;
               dbStar.x += 10;
               dbStar.y -= 10;
               food = ASCompat.dynamicAs(ASCompat.createInstance(foodClass, []), flash.display.MovieClip);
               food.scaleX = food.scaleY = 0.9;
               treasureMC = ASCompat.dynamicAs(ASCompat.createInstance(treasure, []), flash.display.MovieClip);
               treasureMC.scaleX = treasureMC.scaleY = 0.65;
               treasureMC.x += 10;
               treasureMC.y += 5;
               (mLootSharingPopup : ASAny).gold3.addChild(gold);
               (mLootSharingPopup : ASAny).xp.addChild(xpStar);
               (mLootSharingPopup : ASAny).db.addChild(dbStar);
               (mLootSharingPopup : ASAny).treasure.addChild(treasureMC);
               (mLootSharingPopup : ASAny).food.addChild(food);
               mSceneGraphComponent.addChild(mLootSharingPopup,(105 : UInt));
               destX = mDBFacade.stageRef.stageWidth - mLootSharingPopup.width;
               destY = mDBFacade.viewHeight * 0.3;
               mLootSharingPopup.x = destX;
               mLootSharingPopup.y = destY;
               new TimelineMax({
                  "tweens":[TweenMax.to(mLootSharingPopup,0.3333333333333333,{
                     "x":destX + 20,
                     "y":destY
                  }),TweenMax.to(mLootSharingPopup,0.08333333333333333,{
                     "x":destX,
                     "y":destY
                  })],
                  "align":"sequence"
               });
               mLogicalWorkComponent.doLater(10,function(param1:brain.clock.GameClock)
               {
                  if(!mLootSharingTutorialDone)
                  {
                     finishLootSharingTutorial();
                  }
               });
            });
         });
      }
      
      public function showSuperWeakTutorial(param1:String, param2:Bool = true) 
      {
         var className= param1;
         var isRight= param2;
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasSuperWeakParam())
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setSuperWeakParam();
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var swfAsset= param1;
            var popupClass= swfAsset.getClass(className);
            if(popupClass == null)
            {
               return;
            }
            mSuperWeakPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
            ASCompat.setProperty((mSuperWeakPopup : ASAny).title, "text", Locale.getString("TUTORIAL_SUPER_WEAK_TITLE"));
            ASCompat.setProperty((mSuperWeakPopup : ASAny).check, "visible", false);
            mSuperWeakCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mSuperWeakPopup : ASAny).close, flash.display.MovieClip));
            mSuperWeakCloseButton.releaseCallback = function()
            {
               mLogicalWorkComponent.clear();
               finishSuperWeakTutorial(className,isRight);
            };
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),function(param1:brain.assetRepository.SwfAsset)
            {
               var destXCaseRight:Float;
               var destXCaseLeft:Float;
               var destX:Float;
               var destY:Float;
               var swfAsset2= param1;
               mSceneGraphComponent.addChild(mSuperWeakPopup,(105 : UInt));
               destXCaseRight = mDBFacade.stageRef.stageWidth - mSuperWeakPopup.width / 1.6;
               destXCaseLeft = mSuperWeakPopup.width / 3;
               destX = isRight ? destXCaseRight : destXCaseLeft;
               destY = mDBFacade.viewHeight * 0.5;
               mSuperWeakPopup.x = destX;
               mSuperWeakPopup.y = destY;
               new TimelineMax({
                  "tweens":[TweenMax.to(mSuperWeakPopup,0.3333333333333333,{
                     "x":destX + 20,
                     "y":destY
                  }),TweenMax.to(mSuperWeakPopup,0.08333333333333333,{
                     "x":destX,
                     "y":destY
                  })],
                  "align":"sequence"
               });
               mLogicalWorkComponent.clear();
               mLogicalWorkComponent.doLater(5,function(param1:brain.clock.GameClock)
               {
                  if(!mSuperWeakTutorialDone)
                  {
                     finishSuperWeakTutorial(className,isRight);
                  }
               });
            });
         });
      }
      
      public function finishChestTutorial() 
      {
         var advanceFunc:ASFunction;
         var curX:Float;
         var offscreenX:Float;
         var offscreenY:Float;
         mDBFacade.dbAccountInfo.dbAccountParams.setChestCollectedTutorialParam();
         mChestTutorialDone = true;
         if(mChestPopup == null)
         {
            return;
         }
         ASCompat.setProperty((mChestPopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      public function finishCooldownTutorial() 
      {
         var advanceFunc:ASFunction;
         var curX:Float;
         var offscreenX:Float;
         var offscreenY:Float;
         if(!mCooldownTutorialReadyToClose)
         {
            return;
         }
         mCooldownTutorialDone = true;
         ASCompat.setProperty((mChestPopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      public function finishScalingTutorial() 
      {
         var advanceFunc:ASFunction;
         var curX:Float;
         var offscreenX:Float;
         var offscreenY:Float;
         if(!mScalingTutorialReadyToClose)
         {
            return;
         }
         mScalingTutorialDone = true;
         ASCompat.setProperty((mChestPopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      public function finishRepeaterTutorial() 
      {
         var advanceFunc:ASFunction;
         var curX:Float;
         var offscreenX:Float;
         var offscreenY:Float;
         if(!mRepeaterTutorialReadyToClose)
         {
            return;
         }
         mRepeaterTutorialDone = true;
         ASCompat.setProperty((mChestPopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      function finishBusterTutorial() 
      {
         var advanceFunc:ASFunction;
         var curX:Float;
         var offscreenX:Float;
         var offscreenY:Float;
         if(!mBusterTutorialDone)
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setDungeonBusterTutorialParam();
         }
         mBusterTutorialDone = true;
         ASCompat.setProperty((mBusterPopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroyBusterTutorial();
         };
         curX = mBusterPopup.x;
         offscreenX = mDBFacade.viewWidth + mBusterPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mBusterPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mBusterPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      function destroyChestTutorial() 
      {
         if(mChestPopup != null)
         {
            mLogicalWorkComponent.clear();
            if(mCooldownRenderer != null)
            {
               mCooldownRenderer.destroy();
               mCooldownRenderer = null;
            }
            TweenMax.killTweensOf(mChestPopup);
            mSceneGraphComponent.removeChild(mChestPopup);
            mChestCloseButton.destroy();
            mChestCloseButton = null;
            mChestPopup = null;
         }
         mTutorialComplete = true;
      }
      
      function destroyBusterTutorial() 
      {
         if(mBusterPopup != null)
         {
            TweenMax.killTweensOf(mBusterPopup);
            mSceneGraphComponent.removeChild(mBusterPopup);
            mBusterCloseButton.destroy();
            mBusterCloseButton = null;
            mBusterPopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showChestTutorial() 
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setChestNearbyTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass("tutorial_chest");
            if(_loc3_ == null)
            {
               return;
            }
            mChestPopup = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            ASCompat.setProperty((mChestPopup : ASAny).title, "text", Locale.getString("TUTORIAL_CHEST_TITLE"));
            ASCompat.setProperty((mChestPopup : ASAny).title1, "text", Locale.getString("TUTORIAL_CHEST_DESC").toUpperCase());
            ASCompat.setProperty((mChestPopup : ASAny).check, "visible", false);
            mChestCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mChestPopup : ASAny).close, flash.display.MovieClip));
            mChestCloseButton.releaseCallback = finishChestTutorial;
            mSceneGraphComponent.addChild(mChestPopup,(105 : UInt));
            mChestPopup.scaleX = mChestPopup.scaleY = 0.85;
            var _loc2_= mDBFacade.viewWidth - mChestPopup.width / 1.6;
            var _loc4_= mDBFacade.viewHeight * 0.5;
            mChestPopup.x = _loc2_;
            mChestPopup.y = _loc4_;
            new TimelineMax({
               "tweens":[TweenMax.to(mChestPopup,0.3333333333333333,{
                  "x":_loc2_ + 20,
                  "y":_loc4_
               }),TweenMax.to(mChestPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      public function showCooldownTutorial() 
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setCooldownTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var destX:Float;
            var destY:Float;
            var swfAsset= param1;
            var popupClass= swfAsset.getClass("tutorial_cooldown");
            if(popupClass == null)
            {
               return;
            }
            mChestPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
            ASCompat.setProperty((mChestPopup : ASAny).title, "text", Locale.getString("TUTORIAL_COOLDOWN_TITLE"));
            ASCompat.setProperty((mChestPopup : ASAny).description, "text", Locale.getString("TUTORIAL_COOLDOWN_DESC").toUpperCase());
            ASCompat.setProperty((mChestPopup : ASAny).check, "visible", false);
            mChestCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mChestPopup : ASAny).close, flash.display.MovieClip));
            mChestCloseButton.releaseCallback = finishCooldownTutorial;
            mSceneGraphComponent.addChild(mChestPopup,(105 : UInt));
            mChestPopup.scaleX = mChestPopup.scaleY = 0.85;
            destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            destY = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = destX;
            mChestPopup.y = destY;
            new TimelineMax({
               "tweens":[TweenMax.to(mChestPopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),TweenMax.to(mChestPopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:brain.clock.GameClock)
            {
               mCooldownTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:brain.clock.GameClock)
            {
               if(mCooldownTutorialReadyToClose && !mCooldownTutorialDone)
               {
                  finishCooldownTutorial();
               }
            });
            mCooldownRenderer = new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((mChestPopup : ASAny).icon, flash.display.MovieClip));
            mCooldownRenderer.play();
         });
      }
      
      public function showScalingTutorial() 
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setScalingTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var destX:Float;
            var destY:Float;
            var swfAsset= param1;
            var popupClass= swfAsset.getClass("tutorial_scaling");
            if(popupClass == null)
            {
               return;
            }
            mChestPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
            ASCompat.setProperty((mChestPopup : ASAny).title, "text", Locale.getString("TUTORIAL_SCALING_TITLE"));
            ASCompat.setProperty((mChestPopup : ASAny).description, "text", Locale.getString("TUTORIAL_SCALING_DESC").toUpperCase());
            ASCompat.setProperty((mChestPopup : ASAny).check, "visible", false);
            mChestCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mChestPopup : ASAny).close, flash.display.MovieClip));
            mChestCloseButton.releaseCallback = finishScalingTutorial;
            mSceneGraphComponent.addChild(mChestPopup,(105 : UInt));
            mChestPopup.scaleX = mChestPopup.scaleY = 0.85;
            destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            destY = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = destX;
            mChestPopup.y = destY;
            new TimelineMax({
               "tweens":[TweenMax.to(mChestPopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),TweenMax.to(mChestPopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:brain.clock.GameClock)
            {
               mScalingTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:brain.clock.GameClock)
            {
               if(mScalingTutorialReadyToClose && !mScalingTutorialDone)
               {
                  finishScalingTutorial();
               }
            });
         });
      }
      
      public function showRepeaterTutorial() 
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setRepeaterTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var destX:Float;
            var destY:Float;
            var swfAsset= param1;
            var popupClass= swfAsset.getClass("tutorial_repeater");
            if(popupClass == null)
            {
               return;
            }
            mChestPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
            ASCompat.setProperty((mChestPopup : ASAny).title, "text", Locale.getString("TUTORIAL_REPEATER_TITLE"));
            ASCompat.setProperty((mChestPopup : ASAny).description, "text", Locale.getString("TUTORIAL_REPEATER_DESC").toUpperCase());
            ASCompat.setProperty((mChestPopup : ASAny).check, "visible", false);
            mChestCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mChestPopup : ASAny).close, flash.display.MovieClip));
            mChestCloseButton.releaseCallback = finishRepeaterTutorial;
            mSceneGraphComponent.addChild(mChestPopup,(105 : UInt));
            mChestPopup.scaleX = mChestPopup.scaleY = 0.85;
            destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            destY = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = destX;
            mChestPopup.y = destY;
            new TimelineMax({
               "tweens":[TweenMax.to(mChestPopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),TweenMax.to(mChestPopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:brain.clock.GameClock)
            {
               mRepeaterTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:brain.clock.GameClock)
            {
               if(mRepeaterTutorialReadyToClose && !mRepeaterTutorialDone)
               {
                  finishRepeaterTutorial();
               }
            });
         });
      }
      
      public function showBusterTutorial() 
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass("tutorial_db");
            if(_loc3_ == null)
            {
               return;
            }
            mBusterPopup = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            ASCompat.setProperty((mBusterPopup : ASAny).title, "text", Locale.getString("TUTORIAL_BUSTER_TITLE"));
            ASCompat.setProperty((mBusterPopup : ASAny).check, "visible", false);
            mBusterCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mBusterPopup : ASAny).close, flash.display.MovieClip));
            mBusterCloseButton.releaseCallback = finishBusterTutorial;
            mSceneGraphComponent.addChild(mBusterPopup,(105 : UInt));
            mBusterPopup.scaleX = mBusterPopup.scaleY = 0.85;
            var _loc2_= mDBFacade.viewWidth - mBusterPopup.width * 0.5 - 50;
            var _loc4_= mDBFacade.viewHeight * 0.5;
            mBusterPopup.x = mDBFacade.viewWidth;
            mBusterPopup.y = _loc4_;
            new TimelineMax({
               "tweens":[TweenMax.to(mBusterPopup,0.3333333333333333,{
                  "x":_loc2_ + 20,
                  "y":_loc4_
               }),TweenMax.to(mBusterPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      function finishChargeTutorial() 
      {
         var advanceFunc:ASFunction;
         var curX:Float;
         var offscreenX:Float;
         var offscreenY:Float;
         if(!mChargeTutorialReadyToClose)
         {
            return;
         }
         mChargeTutorialDone = true;
         ASCompat.setProperty((mChargePopup : ASAny).check, "visible", true);
         advanceFunc = function()
         {
            destroyChargeTutorial();
         };
         curX = mChargePopup.x;
         offscreenX = -mChargePopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         new TimelineMax({
            "tweens":[TweenMax.to(mChargePopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),TweenMax.to(mChargePopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      function destroyChargeTutorial() 
      {
         if(mChargePopup != null)
         {
            TweenMax.killTweensOf(mChargePopup);
            mSceneGraphComponent.removeChild(mChargePopup);
            mChargeCloseButton.destroy();
            mChargeCloseButton = null;
            mChargePopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showChargeTutorial() 
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setChargeTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var destX:Float;
            var destY:Float;
            var swfAsset= param1;
            var popupClass= swfAsset.getClass("tutorial_charge");
            if(popupClass == null)
            {
               return;
            }
            mChargePopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
            ASCompat.setProperty((mChargePopup : ASAny).title, "text", Locale.getString("TUTORIAL_CHARGE_TITLE"));
            ASCompat.setProperty((mChargePopup : ASAny).check, "visible", false);
            mChargeCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mChargePopup : ASAny).close, flash.display.MovieClip));
            mChargeCloseButton.releaseCallback = finishChargeTutorial;
            mSceneGraphComponent.addChild(mChargePopup,(105 : UInt));
            mChargePopup.scaleX = mChargePopup.scaleY = 0.85;
            destX = mChargePopup.width * 0.5 + 10;
            destY = mDBFacade.viewHeight * 0.5;
            mChargePopup.x = -mChargePopup.width;
            mChargePopup.y = destY;
            new TimelineMax({
               "tweens":[TweenMax.to(mChargePopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),TweenMax.to(mChargePopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:brain.clock.GameClock)
            {
               mChargeTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:brain.clock.GameClock)
            {
               if(mChargeTutorialReadyToClose && !mChargeTutorialDone)
               {
                  finishChargeTutorial();
               }
            });
         });
      }
      
      @:isVar public var isTutorialComplete(get,never):Bool;
public function  get_isTutorialComplete() : Bool
      {
         return mTutorialComplete;
      }
   }


