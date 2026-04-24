package uI.map
;
   import account.MapnodeInfo;
   import actor.FloatingMessage;
   import actor.Revealer;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.uI.UIProgressBar;
   import brain.utils.ColorMatrix;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import brain.jsonRPC.JSONRPCService;
   import dBGlobals.DBGlobal;
   import distributedObjects.MatchMaker;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import gameMasterDictionary.GMColiseumTier;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMInfiniteDungeon;
   import gameMasterDictionary.GMMapNode;
   import town.TownStateMachine;
   import uI.infiniteIsland.II_UIMapBattlePopup;
   import uI.popup.DBUIOneButtonPopup;
   import uI.popup.DBUIUltimateRampagePopup;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.Set;

import gameMasterDictionary.GMMapNode;
   
    class UIMapWorldMap
   {
      
      static inline final MAX_BOING_MAG:Float = 1.45;
      
      static inline final BOING_DECAY:Float = 0.5;
      
      static inline final BOING_RATE:Float = 2;
      
      static inline final SQUASH_BALANCE:Float = 0.75;
      
      static inline final SQUASH_RATE:Float = 0.25;
      
      static inline final AVATAR_LERP_SPEED:Float = 12;
      
      static inline final AVATAR_ARC_HEIGHT:Float = 30;
      
      static inline final CUTSCENE_PATH= "Resources/Art2D/UI/animatic0104.swf";
      
      static inline final CAMERA_LERP_SPEED:Float = 0.2916666666666667;
      
      static inline final CAMERA_CENTER_TIMEOUT:Float = 144;
      
      static inline final CAMERA_SPEED_SCALE:Float = 1;
      
      static inline final LEADERBOARD_HEIGHT:Float = 90;
      
      static inline final DRAG_MESSAGE_TIME:Float = 17;
      
      static inline final ROOKIE_LEAGUE= (0 : UInt);
      
      static inline final GLADIATOR_LEAGUE= (1 : UInt);
      
      static inline final HEROIC_LEAGUE= (2 : UInt);
      
      static inline final GRINDER_LEAGUE= (3 : UInt);
      
      static inline final INFINITE_ISLAND_LEAGUE= (4 : UInt);
      
      static var OPEN_COLOR_MATRIX:ColorMatrix = new ColorMatrix();
      
      static var CLOSED_COLOR_MATRIX:ColorMatrix = new ColorMatrix();
      
      static final ___init = {
         OPEN_COLOR_MATRIX.adjustBrightness(-20);
         OPEN_COLOR_MATRIX.adjustSaturation(0.75);
         OPEN_COLOR_MATRIX.adjustHue(65);
         CLOSED_COLOR_MATRIX.adjustBrightness(-40);
         CLOSED_COLOR_MATRIX.adjustSaturation(0);
         null;
      };
      
      var mLastKeyboardUpdateFrame:UInt = (0 : UInt);
      
      var KEYBOARD_FRAME_DELAY_UPDATE:UInt = (12 : UInt);
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mDBFacade:DBFacade;
      
      var mRootMovieClip:MovieClip;
      
      var mTownSwfAsset:SwfAsset;
      
      var mMapAvatar:UIMapAvatar;
      
      var mAvatarList:Array<ASAny>;
      
      var mAvatarDropShadowList:Array<ASAny>;
      
      var mSpentKeyMessage:MovieClip;
      
      var mXPBar:UIProgressBar;
      
      var mIIBattlePopup:UIMapBattlePopup;
      
      var mRegularBattlePopup:UIMapBattlePopup;
      
      var mBattlePopup:UIMapBattlePopup;
      
      var mInfiniteIslandUnlocked:Bool = false;
      
      var mWantCinematics:Bool = false;
      
      var mMouseTask:Task;
      
      var mCameraLerpTask:Task;
      
      var mFriendFadeTask:Task;
      
      var mCameraTargetX:Float = Math.NaN;
      
      var mCameraTargetY:Float = Math.NaN;
      
      var mCameraVelocityX:Float = Math.NaN;
      
      var mCameraVelocityY:Float = Math.NaN;
      
      var mOldMouseX:Float = Math.NaN;
      
      var mOldMouseY:Float = Math.NaN;
      
      var mMouseVelocityX:Float = Math.NaN;
      
      var mMouseVelocityY:Float = Math.NaN;
      
      var mCurrentNode:GMMapNode;
      
      var mNodeQueue:Array<ASAny>;
      
      var mNodePath:Array<ASAny>;
      
      var mClosedNodeList:Set;
      
      var mOpenNodeButtons:Map;
      
      var mLockedNodeButtons:Map;
      
      var mMapDragTask:Task;
      
      var mMapNodeClass:Dynamic;
      
      var mDragMessageRevealer:Revealer;
      
      var mDragMessageFloater:FloatingMessage;
      
      var mChooseDungeonMessage:FloatingMessage;
      
      var mShowedDragMessage:Bool = false;
      
      var mDidDrag:Bool = false;
      
      var mLeagueNameRevealer:Revealer;
      
      var mDidKeySpentMessage:Bool = false;
      
      var mUnlockSuccessful:Bool = false;
      
      var mUnlockResponseReceived:Bool = false;
      
      var mRevealer:Revealer;
      
      var mReturnToMapNode:GMMapNode;
      
      var mMapWidth:Float = Math.NaN;
      
      var mMapHeight:Float = Math.NaN;
      
      var mReturnToTownButton:UIButton;
      
      var mReturnToTownCallback:ASFunction;
      
      var mCurrentLeague:UInt = (0 : UInt);
      
      var mLeftLeagueButton:UIButton;
      
      var mRightLeagueButton:UIButton;
      
      var mTownStateMachine:TownStateMachine;
      
      var mEpochCountdownTimer:Timer;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:SwfAsset, param4:TownStateMachine)
      {
         
         mDBFacade = param1;
         mTownStateMachine = param4;
         mAssetLoadingComponent = new AssetLoadingComponent(param1);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIMapWorldMap");
         mEventComponent = new EventComponent(mDBFacade);
         mWantCinematics = mDBFacade.dbConfigManager.getConfigBoolean("want_story",true);
         mRootMovieClip = param2;
         mTownSwfAsset = param3;
         mShowedDragMessage = false;
         mInfiniteIslandUnlocked = false;
      }
      
      public function initialize(param1:ASFunction, param2:ASFunction, param3:ASFunction, param4:ASFunction) 
      {
         var finalLeagueBounds:Rectangle;
         var globalBottomRight:Point;
         var setReturnNode:ASFunction;
         var tavernCallback= param1;
         var inventoryCallback= param2;
         var shopCallback= param3;
         var townCallback= param4;
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"UIMapWorldMap");
         mWorkComponent.doEverySeconds(59,mDBFacade.playerActivityCount.fetchPublicDungeonActivityLevel);
         finalLeagueBounds = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.infinite_island_league.getRect((mRootMovieClip : ASAny).worldmap.infinite_island_league), flash.geom.Rectangle);
         globalBottomRight = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.infinite_island_league.localToGlobal(finalLeagueBounds.bottomRight), flash.geom.Point);
         mMapWidth = ASCompat.toNumber(globalBottomRight.x - ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "x") + 390);
         mMapHeight = ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "height");
         mCurrentNode = null;
         mReturnToTownCallback = townCallback;
         setReturnNode = function(param1:ASFunction):ASFunction
         {
            var callback= param1;
            return function()
            {
               callback();
               mReturnToMapNode = mCurrentNode;
            };
         };
         mIIBattlePopup = new II_UIMapBattlePopup(mDBFacade,ASCompat.asFunction(setReturnNode(tavernCallback)),ASCompat.asFunction(setReturnNode(inventoryCallback)),ASCompat.asFunction(setReturnNode(shopCallback)),this.battleButtonCallback,"MapBattlePopup");
         MemoryTracker.track(mIIBattlePopup,"II_UIMapBattlePopup - created in UIMapWorldMap.UIMapWorldMap()");
         mIIBattlePopup.animatePopupOut();
         mRegularBattlePopup = new UIMapBattlePopup(mDBFacade,ASCompat.asFunction(setReturnNode(tavernCallback)),ASCompat.asFunction(setReturnNode(inventoryCallback)),ASCompat.asFunction(setReturnNode(shopCallback)),this.battleButtonCallback,"MapBattlePopup");
         MemoryTracker.track(mRegularBattlePopup,"UIMapBattlePopup - created in UIMapWorldMap.UIMapWorldMap()");
         mRegularBattlePopup.animatePopupOut();
         mBattlePopup = mRegularBattlePopup;
         mEventComponent.addListener(MatchMaker.EPOCH_ROLL_OVER_EVENT_NAME,epochRollOverHandler);
         mUnlockResponseReceived = false;
         mUnlockSuccessful = false;
         mDidKeySpentMessage = false;
         mCameraVelocityX = 0;
         mCameraVelocityY = 0;
         mCurrentLeague = (0 : UInt);
         mMapNodeClass = ((cast((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.DisplayObjectContainer).getChildByName("TUTORIAL") : ASAny).constructor : Dynamic);
         mXPBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).ui_league.UI_XP.xp_bar, flash.display.MovieClip));
         mXPBar.dontKillMyChildren = true;
         setXP(mDBFacade.dbAccountInfo.activeAvatarInfo.experience,mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero);
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01.label, "text", Locale.getString("MAP_PAGE_ROOKIE_LEAGUE_LABEL"));
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02.label, "text", Locale.getString("MAP_PAGE_GLADIATOR_LEAGUE_LABEL"));
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04.label, "text", Locale.getString("MAP_PAGE_CHAMPION_LEAGUE_LABEL"));
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03.label, "text", Locale.getString("MAP_PAGE_GRINDER_LEAGUE_LABEL"));
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05.label, "text", Locale.getString("MAP_PAGE_INFINITE_LEAGUE_LABEL"));
         mLeftLeagueButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).ui_league.shift_left, flash.display.MovieClip));
         mLeftLeagueButton.releaseCallback = function()
         {
            var _loc1_= mCurrentLeague;
            mCurrentLeague = (ASCompat.toInt(mCurrentLeague > 0 ? mCurrentLeague - 1 : (0 : UInt)) : UInt);
            if(_loc1_ != mCurrentLeague)
            {
               updateCurrentLeague();
            }
         };
         mRightLeagueButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).ui_league.shift_right, flash.display.MovieClip));
         mRightLeagueButton.releaseCallback = function()
         {
            var _loc1_= mCurrentLeague;
            mCurrentLeague = determineNextLeague();
            if(_loc1_ != mCurrentLeague)
            {
               updateCurrentLeague();
            }
         };
         (mRootMovieClip : ASAny).worldmap.addEventListener("mouseDown",onMouseDown);
         mDBFacade.dbAccountInfo.activeAvatarInfo.loadHeroIcon(function(param1:MovieClip)
         {
            UIObject.scaleToFit(param1,40);
            (mRootMovieClip : ASAny).ui_league.ui_avatar.addChild(param1);
         });
         clearMouseEnabledOnWorldmap();
         hideAllMapNodes();
         setupMapNodeButtons();
         setupMapNodeLinks();
         if(mChooseDungeonMessage == null)
         {
            mWorkComponent.doLater(1,showChooseDungeonMessage);
         }
         if(!mShowedDragMessage)
         {
            mWorkComponent.doEverySeconds(17,function()
            {
               var dragMessageClass:Dynamic;
               var dragMessage:MovieClip;
               if(!mDidDrag)
               {
                  mShowedDragMessage = true;
                  dragMessageClass = mTownSwfAsset.getClass("Branch_map_drag");
                  dragMessage = ASCompat.dynamicAs(ASCompat.createInstance(dragMessageClass, []) , MovieClip);
                  mRootMovieClip.addChild(dragMessage);
                  dragMessage.x = dragMessage.stage.stageWidth / 2;
                  dragMessage.y = dragMessage.stage.stageHeight * 0.4;
                  dragMessage.mouseChildren = false;
                  dragMessage.mouseEnabled = false;
                  dragMessage.alpha = 0;
                  dragMessage.scaleX = dragMessage.scaleY = 0.9;
                  if(mDragMessageRevealer != null)
                  {
                     mDragMessageRevealer.destroy();
                     mDragMessageRevealer = null;
                  }
                  mDragMessageRevealer = new Revealer(dragMessage,mDBFacade,(24 : UInt),function()
                  {
                     mDragMessageFloater = new FloatingMessage(dragMessage,mDBFacade,(32 : UInt),(48 : UInt),1.5,0,null,function()
                     {
                        mRootMovieClip.removeChild(dragMessage);
                     });
                  },(1 : UInt));
               }
            });
         }
         if(mReturnToMapNode != null)
         {
            moveAvatarToNode(mReturnToMapNode)();
            mReturnToMapNode = null;
         }
         mCameraTargetY = -156;
         ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "x", mCameraTargetX);
         ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "y", mCameraTargetY);
         updateCurrentLeague();
         clampMap();
         if(mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_PLAY_MAP_NODE",false))
         {
            setUpHacksToPlayNode();
         }
         mWorkComponent.doEveryFrame(keyboardCheck);
      }
      
      function setupMapNodeLinks() 
      {
         var _loc8_= 0;
         var _loc9_= 0;
         var _loc4_:GMMapNode = null;
         var _loc7_:UIButton = null;
         var _loc5_= 0;
         var _loc6_:UIButton = null;
         var _loc2_= 0;
         var _loc3_:UIButton = null;
         var _loc1_= mOpenNodeButtons.keysToArray();
         ASCompat.ASArray.sortWithOptions(_loc1_, 16);
         setupMapNodeNavigationUltimateRampage();
         _loc8_ = 0;
         while(_loc8_ < _loc1_.length)
         {
            _loc9_ = ASCompat.toInt(_loc1_[_loc8_]);
            if(mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.hasKey(_loc9_))
            {
               _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeById.itemFor(_loc9_), gameMasterDictionary.GMMapNode);
               if(_loc4_.IsInfiniteDungeon)
               {
                  break;
               }
               _loc7_ = ASCompat.dynamicAs(mOpenNodeButtons.itemFor(_loc9_), brain.uI.UIButton);
               _loc5_ = ASCompat.toInt(_loc8_ > 0 ? _loc1_[_loc8_ - 1] : 0);
               if(_loc5_ > 0)
               {
                  _loc6_ = ASCompat.dynamicAs(mOpenNodeButtons.itemFor(_loc5_), brain.uI.UIButton);
                  if(_loc6_ != null && mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.hasKey(_loc5_))
                  {
                     _loc7_.leftNavigation = _loc6_;
                  }
               }
               _loc2_ = ASCompat.toInt(_loc8_ < _loc1_.length - 1 ? _loc1_[_loc8_ + 1] : 0);
               if(_loc2_ > 0)
               {
                  _loc3_ = ASCompat.dynamicAs(mOpenNodeButtons.itemFor(_loc2_), brain.uI.UIButton);
                  if(_loc3_ != null && mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.hasKey(_loc2_) && _loc2_ != 50150)
                  {
                     _loc7_.rightNavigation = _loc3_;
                  }
               }
            }
            _loc8_++;
         }
         setupMapNodeMenuNavigationLeagueChangeTriggers();
         setupMapNodeNavigationGladiatorLeaguePrisonPath();
         setupMapNodeNavigationGladiatorLeagueCretaceousPath();
         setupMapNodeNavigationGladiatorLeagueFrostguardPath();
         setupMapNodeNavigationChampionLeagueKnightFortressPath();
      }
      
      function setupMapNodeMenuNavigationLeagueChangeTriggers() 
      {
         ASCompat.setProperty(mOpenNodeButtons.itemFor(50020), "rightNavigationAdditionalInteraction", function()
         {
            setCurrentLeague((1 : UInt));
         });
         ASCompat.setProperty(mOpenNodeButtons.itemFor(50021), "leftNavigationAdditionalInteraction", function()
         {
            setCurrentLeague((0 : UInt));
         });
         ASCompat.setProperty(mOpenNodeButtons.itemFor(50051), "rightNavigationAdditionalInteraction", function()
         {
            setCurrentLeague((2 : UInt));
         });
         ASCompat.setProperty(mOpenNodeButtons.itemFor(50052), "leftNavigationAdditionalInteraction", function()
         {
            setCurrentLeague((1 : UInt));
         });
         ASCompat.setProperty(mOpenNodeButtons.itemFor(50083), "rightNavigationAdditionalInteraction", function()
         {
            setCurrentLeague((3 : UInt));
         });
         ASCompat.setProperty(mOpenNodeButtons.itemFor(50084), "leftNavigationAdditionalInteraction", function()
         {
            setCurrentLeague((2 : UInt));
         });
         ASCompat.setProperty(mOpenNodeButtons.itemFor(50099), "rightNavigationAdditionalInteraction", function()
         {
            setCurrentLeague((4 : UInt));
         });
         ASCompat.setProperty(mOpenNodeButtons.itemFor(50156), "leftNavigationAdditionalInteraction", function()
         {
            setCurrentLeague((3 : UInt));
         });
      }
      
      function setupMapNodeNavigationGladiatorLeaguePrisonPath() 
      {
         var _loc8_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50026), brain.uI.UIButton);
         var _loc6_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50027), brain.uI.UIButton);
         var _loc7_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50028), brain.uI.UIButton);
         var _loc4_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50029), brain.uI.UIButton);
         var _loc5_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50030), brain.uI.UIButton);
         var _loc2_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50031), brain.uI.UIButton);
         var _loc3_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50032), brain.uI.UIButton);
         var _loc1_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50033), brain.uI.UIButton);
         _loc8_.clearNavigationAndInteractions();
         _loc6_.clearNavigationAndInteractions();
         _loc7_.clearNavigationAndInteractions();
         _loc4_.clearNavigationAndInteractions();
         _loc5_.clearNavigationAndInteractions();
         _loc2_.clearNavigationAndInteractions();
         _loc3_.clearNavigationAndInteractions();
         _loc1_.clearLeftNavigation();
         _loc8_.leftNavigation = ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50025), brain.uI.UIObject);
         _loc5_.isAbove(_loc8_);
         _loc5_.leftNavigation = _loc8_;
         _loc3_.isToTheLeftOf(_loc1_);
         _loc3_.isAbove(_loc2_);
         _loc2_.isToTheLeftOf(_loc3_);
         _loc2_.isAbove(_loc5_);
         _loc5_.isToTheLeftOf(_loc2_);
         _loc8_.isToTheLeftOf(_loc6_);
         _loc6_.isToTheLeftOf(_loc7_);
         _loc7_.isToTheLeftOf(_loc4_);
         _loc4_.rightNavigation = _loc1_;
         _loc1_.isAbove(_loc4_);
      }
      
      function setupMapNodeNavigationGladiatorLeagueCretaceousPath() 
      {
         var _loc8_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50036), brain.uI.UIButton);
         var _loc4_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50037), brain.uI.UIButton);
         var _loc3_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50038), brain.uI.UIButton);
         var _loc6_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50039), brain.uI.UIButton);
         var _loc5_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50040), brain.uI.UIButton);
         var _loc2_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50041), brain.uI.UIButton);
         var _loc1_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50042), brain.uI.UIButton);
         var _loc7_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50043), brain.uI.UIButton);
         _loc4_.clearNavigationAndInteractions();
         _loc6_.clearNavigationAndInteractions();
         _loc3_.clearNavigationAndInteractions();
         _loc2_.clearNavigationAndInteractions();
         _loc1_.clearNavigationAndInteractions();
         _loc7_.clearNavigationAndInteractions();
         _loc5_.clearNavigationAndInteractions();
         _loc4_.leftNavigation = _loc8_;
         _loc8_.downNavigation = _loc4_;
         _loc6_.isAbove(_loc4_);
         _loc6_.isToTheLeftOf(_loc5_);
         _loc5_.isAbove(_loc6_);
         _loc4_.isAbove(_loc3_);
         _loc3_.leftNavigation = _loc4_;
         _loc3_.isAbove(_loc2_);
         _loc3_.isToTheLeftOf(_loc2_);
         _loc2_.isAbove(_loc1_);
         _loc2_.isToTheLeftOf(_loc1_);
         _loc1_.isAbove(_loc7_);
         _loc1_.isToTheLeftOf(_loc7_);
      }
      
      function setupMapNodeNavigationGladiatorLeagueFrostguardPath() 
      {
         var _loc9_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50044), brain.uI.UIButton);
         var _loc10_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50045), brain.uI.UIButton);
         var _loc1_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50046), brain.uI.UIButton);
         var _loc2_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50047), brain.uI.UIButton);
         var _loc3_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50048), brain.uI.UIButton);
         var _loc4_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50049), brain.uI.UIButton);
         var _loc5_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50050), brain.uI.UIButton);
         var _loc6_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50051), brain.uI.UIButton);
         _loc9_.clearNavigationAndInteractions();
         _loc10_.clearNavigationAndInteractions();
         _loc1_.clearNavigationAndInteractions();
         _loc2_.clearNavigationAndInteractions();
         _loc3_.clearNavigationAndInteractions();
         _loc4_.clearNavigationAndInteractions();
         _loc5_.clearNavigationAndInteractions();
         _loc6_.clearLeftNavigation();
         var _loc7_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50040), brain.uI.UIButton);
         var _loc8_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50043), brain.uI.UIButton);
         _loc8_.isToTheLeftOf(_loc9_);
         _loc7_.isToTheLeftOf(_loc3_);
         _loc9_.isToTheLeftOf(_loc10_);
         _loc10_.isAbove(_loc9_);
         _loc10_.isToTheLeftOf(_loc1_);
         _loc1_.isAbove(_loc10_);
         _loc1_.isToTheLeftOf(_loc2_);
         _loc2_.isAbove(_loc1_);
         _loc3_.isToTheLeftOf(_loc4_);
         _loc3_.isAbove(_loc4_);
         _loc4_.isToTheLeftOf(_loc5_);
         _loc4_.isAbove(_loc5_);
         _loc5_.isAbove(_loc2_);
         _loc5_.rightNavigation = _loc2_;
         _loc2_.isToTheLeftOf(_loc6_);
      }
      
      function setupMapNodeNavigationChampionLeagueKnightFortressPath() 
      {
         var _loc19_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50064), brain.uI.UIButton);
         var _loc20_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50065), brain.uI.UIButton);
         var _loc22_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50066), brain.uI.UIButton);
         var _loc16_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50067), brain.uI.UIButton);
         var _loc17_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50068), brain.uI.UIButton);
         var _loc24_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50069), brain.uI.UIButton);
         var _loc5_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50070), brain.uI.UIButton);
         var _loc2_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50071), brain.uI.UIButton);
         var _loc3_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50072), brain.uI.UIButton);
         var _loc1_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50073), brain.uI.UIButton);
         _loc19_.clearNavigationAndInteractions();
         _loc20_.clearNavigationAndInteractions();
         _loc22_.clearNavigationAndInteractions();
         _loc16_.clearNavigationAndInteractions();
         _loc17_.clearNavigationAndInteractions();
         _loc24_.clearNavigationAndInteractions();
         _loc5_.clearNavigationAndInteractions();
         _loc2_.clearNavigationAndInteractions();
         _loc3_.clearNavigationAndInteractions();
         _loc1_.clearNavigationAndInteractions();
         _loc19_.isToTheLeftOf(_loc20_);
         _loc20_.isToTheLeftOf(_loc22_);
         _loc22_.isToTheLeftOf(_loc16_);
         _loc16_.isToTheLeftOf(_loc17_);
         _loc17_.isToTheLeftOf(_loc24_);
         _loc24_.isToTheLeftOf(_loc5_);
         _loc5_.isToTheLeftOf(_loc2_);
         _loc2_.isToTheLeftOf(_loc3_);
         _loc3_.isToTheLeftOf(_loc1_);
         var _loc10_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50057), brain.uI.UIButton);
         var _loc11_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50058), brain.uI.UIButton);
         var _loc7_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50059), brain.uI.UIButton);
         var _loc9_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50060), brain.uI.UIButton);
         var _loc4_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50061), brain.uI.UIButton);
         var _loc6_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50062), brain.uI.UIButton);
         var _loc28_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50063), brain.uI.UIButton);
         var _loc27_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50074), brain.uI.UIButton);
         var _loc26_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50075), brain.uI.UIButton);
         var _loc25_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50076), brain.uI.UIButton);
         _loc10_.clearNavigationAndInteractions();
         _loc11_.clearNavigationAndInteractions();
         _loc7_.clearNavigationAndInteractions();
         _loc9_.clearNavigationAndInteractions();
         _loc4_.clearNavigationAndInteractions();
         _loc6_.clearNavigationAndInteractions();
         _loc28_.clearNavigationAndInteractions();
         _loc27_.clearNavigationAndInteractions();
         _loc26_.clearNavigationAndInteractions();
         _loc25_.clearNavigationAndInteractions();
         _loc10_.isToTheLeftOf(_loc11_);
         _loc11_.isToTheLeftOf(_loc7_);
         _loc7_.isToTheLeftOf(_loc9_);
         _loc9_.isToTheLeftOf(_loc4_);
         _loc4_.isToTheLeftOf(_loc6_);
         _loc6_.isToTheLeftOf(_loc28_);
         _loc28_.isToTheLeftOf(_loc27_);
         _loc27_.isToTheLeftOf(_loc26_);
         _loc26_.isToTheLeftOf(_loc25_);
         var _loc8_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50077), brain.uI.UIButton);
         var _loc15_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50078), brain.uI.UIButton);
         var _loc14_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50079), brain.uI.UIButton);
         var _loc13_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50080), brain.uI.UIButton);
         var _loc12_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50081), brain.uI.UIButton);
         var _loc18_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50082), brain.uI.UIButton);
         var _loc21_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50083), brain.uI.UIButton);
         _loc8_.clearNavigationAndInteractions();
         _loc15_.clearNavigationAndInteractions();
         _loc14_.clearNavigationAndInteractions();
         _loc13_.clearNavigationAndInteractions();
         _loc12_.clearNavigationAndInteractions();
         _loc18_.clearNavigationAndInteractions();
         _loc21_.clearLeftNavigation();
         _loc1_.isAbove(_loc8_);
         _loc8_.isAbove(_loc15_);
         _loc8_.isToTheLeftOf(_loc15_);
         _loc15_.isAbove(_loc12_);
         _loc15_.rightNavigation = _loc12_;
         _loc25_.isToTheLeftOf(_loc14_);
         _loc14_.isToTheLeftOf(_loc13_);
         _loc13_.isToTheLeftOf(_loc12_);
         _loc12_.isToTheLeftOf(_loc18_);
         _loc18_.isToTheLeftOf(_loc21_);
         _loc1_.isToTheLeftOf(_loc8_);
         var _loc23_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50056), brain.uI.UIButton);
         _loc23_.clearRightNavigation();
         _loc19_.isAbove(_loc23_);
         _loc23_.isToTheLeftOf(_loc10_);
         _loc23_.isAbove(ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50055), brain.uI.UIObject));
      }
      
      function setupMapNodeNavigationUltimateRampage() 
      {
         var _loc6_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50150), brain.uI.UIButton);
         var _loc8_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50151), brain.uI.UIButton);
         var _loc9_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50153), brain.uI.UIButton);
         var _loc4_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50155), brain.uI.UIButton);
         var _loc2_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50156), brain.uI.UIButton);
         var _loc5_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50158), brain.uI.UIButton);
         var _loc10_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50159), brain.uI.UIButton);
         var _loc7_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50161), brain.uI.UIButton);
         var _loc3_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50162), brain.uI.UIButton);
         var _loc1_= ASCompat.dynamicAs(mOpenNodeButtons.itemFor(50099), brain.uI.UIButton);
         _loc3_.isAbove(_loc2_);
         _loc3_.isToTheLeftOf(_loc8_);
         _loc8_.isToTheLeftOf(_loc4_);
         _loc4_.isAbove(_loc6_);
         _loc6_.isAbove(_loc7_);
         _loc5_.isToTheLeftOf(_loc6_);
         _loc10_.isToTheLeftOf(_loc7_);
         _loc9_.isToTheLeftOf(_loc10_);
         _loc2_.isAbove(_loc9_);
         _loc1_.isToTheLeftOf(_loc2_);
      }
      
      public function getCurrentNodeButton() : UIButton
      {
         return ASCompat.dynamicAs(mOpenNodeButtons.itemFor(mCurrentNode.Id), brain.uI.UIButton);
      }
      
      public function getCurrentNodeLeagueValue() : UInt
      {
         return getNodeLeagueValue(mCurrentNode);
      }
      
      public function getButtonLeagueView(param1:UIObject) : UInt
      {
         var _loc5_= 0;
         var _loc6_= 0;
         var _loc2_:UIButton = null;
         var _loc3_:GMMapNode = null;
         var _loc4_= mOpenNodeButtons.keysToArray();
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc6_ = ASCompat.toInt(_loc4_[_loc5_]);
            _loc2_ = ASCompat.dynamicAs(mOpenNodeButtons.itemFor(_loc6_), brain.uI.UIButton);
            if(_loc2_ == param1)
            {
               _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeById.itemFor(_loc6_), gameMasterDictionary.GMMapNode);
               return getNodeLeagueValue(_loc3_);
            }
            _loc5_++;
         }
         return (0 : UInt);
      }
      
      function getNodeLeagueValue(param1:GMMapNode) : UInt
      {
         var _loc3_= 0;
         var _loc4_:MovieClip = null;
         var _loc2_:MovieClip = null;
         _loc3_ = 0;
         while(_loc3_ <= 4)
         {
            _loc4_ = getLeagueClip((_loc3_ : UInt));
            _loc2_ = ASCompat.reinterpretAs(_loc4_.getChildByName(param1.Constant) , MovieClip);
            if(_loc2_ != null)
            {
               return (_loc3_ : UInt);
            }
            _loc3_++;
         }
         return (0 : UInt);
      }
      
      function getLeagueClip(param1:UInt) : MovieClip
      {
         switch(param1)
         {
            case 0:
               return ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.MovieClip);
            case 1:
               return ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.MovieClip);
            case 2:
               return ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.MovieClip);
            case 3:
               return ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.MovieClip);
            case 4:
               return ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.MovieClip);
            default:
               return null;
         }
return null;
      }
      
      public function getCurrentLeagueView() : UInt
      {
         return mCurrentLeague;
      }
      
      public function setCurrentLeague(param1:UInt, param2:Bool = true) 
      {
         if(param1 != mCurrentLeague)
         {
            mCurrentLeague = param1;
            updateCurrentLeague(param2);
         }
      }
      
      function epochRollOverHandler(param1:Event) 
      {
         if(mBattlePopup == mIIBattlePopup)
         {
            mBattlePopup.animatePopupOut();
            setCurrentNode(mCurrentNode);
            mBattlePopup.animatePopupIn();
         }
      }
      
      function determineNextLeague() : UInt
      {
         return (ASCompat.toInt(mCurrentLeague < 4 ? mCurrentLeague + 1 : (4 : UInt)) : UInt);
      }
      
      function keyboardCheck(param1:GameClock) 
      {
      }
      
      function popLeagueName(param1:MovieClip) 
      {
         if(mLeagueNameRevealer != null)
         {
            mLeagueNameRevealer.destroy();
            mLeagueNameRevealer = null;
         }
         param1.scaleX = 1;
         param1.scaleY = 1;
         param1.alpha = 1;
         mLeagueNameRevealer = new Revealer(param1,mDBFacade,(10 : UInt));
      }
      
      function updateCurrentLeague(param1:Bool = true) 
      {
         var _loc2_:DBUIUltimateRampagePopup = null;
         var _loc3_:MovieClip = null;
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.clock, "visible", false);
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_new_dungeon, "visible", false);
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_timer, "visible", false);
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.ui_avatar, "visible", true);
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.UI_XP, "visible", true);
         endEpochCountdown();
         switch(mCurrentLeague)
         {
            case 0:
               mLeftLeagueButton.enabled = false;
               mRightLeagueButton.enabled = true;
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", true);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", false);
               centerMapOnClip(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.MovieClip),"ROOKIE");
               _loc3_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).ui_league.league_01, flash.display.MovieClip);
               
            case 1:
               mLeftLeagueButton.enabled = true;
               mRightLeagueButton.enabled = true;
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", true);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", false);
               centerMapOnClip(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.MovieClip),"GLADIATOR");
               _loc3_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).ui_league.league_02, flash.display.MovieClip);
               
            case 2:
               mLeftLeagueButton.enabled = true;
               mRightLeagueButton.enabled = true;
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", true);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", false);
               centerMapOnClip(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.MovieClip),"CHAMPION");
               _loc3_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).ui_league.league_04, flash.display.MovieClip);
               
            case 3:
               mLeftLeagueButton.enabled = true;
               mRightLeagueButton.enabled = true;
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", true);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", false);
               centerMapOnClip(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.MovieClip),"GRINDHOUSE");
               _loc3_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).ui_league.league_03, flash.display.MovieClip);
               
            case 4:
               if(mInfiniteIslandUnlocked && !mDBFacade.dbAccountInfo.hasAttribute("seenUltimatePopup"))
               {
                  mDBFacade.dbAccountInfo.alterAttribute("seenUltimatePopup","1");
                  _loc2_ = new DBUIUltimateRampagePopup(mDBFacade);
                  MemoryTracker.track(_loc2_,"DBUIOneButtonPopup - created in UIMapWorldMap.setLeague()");
               }
               mLeftLeagueButton.enabled = true;
               mRightLeagueButton.enabled = false;
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.ui_avatar, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.UI_XP, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_01, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_02, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_03, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_04, "visible", false);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.league_05, "visible", true);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.clock, "visible", true);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_new_dungeon, "text", Locale.getString("INFINITE_TIMER_LABEL"));
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_new_dungeon, "visible", true);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_timer, "visible", true);
               ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_timer, "text", "");
               startEpochCountdown();
               centerMapOnClip(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.MovieClip),"INFINITEISLAND");
               _loc3_ = null;
               
            default:
               Logger.warn("Map page league paging in borked state");
         }
         if(param1 && _loc3_ != null)
         {
            popLeagueName(_loc3_);
         }
      }
      
      function startEpochCountdown() 
      {
         mEpochCountdownTimer = new Timer(1000);
         mEpochCountdownTimer.addEventListener("timer",tickEpochCountdown);
         tickEpochCountdown(null);
         mEpochCountdownTimer.start();
      }
      
      function endEpochCountdown() 
      {
         if(mEpochCountdownTimer != null)
         {
            mEpochCountdownTimer.removeEventListener("timer",tickEpochCountdown);
            mEpochCountdownTimer.stop();
         }
      }
      
      function tickEpochCountdown(param1:TimerEvent) 
      {
         var _loc2_= GameClock.getArrayTimeToEpoch();
         var _loc3_= "";
         if(ASCompat.toNumber(_loc2_[4]) == 1)
         {
            _loc3_ += Std.string(_loc2_[4]) + " " + Locale.getString("EPOCH_TIMER_WEEK");
         }
         else if(ASCompat.toBool(_loc2_[4]))
         {
            _loc3_ += Std.string(_loc2_[4]) + " " + Locale.getString("EPOCH_TIMER_WEEKS");
         }
         if(ASCompat.toNumber(_loc2_[3]) == 1)
         {
            _loc3_ += Std.string(_loc2_[3]) + " " + Locale.getString("EPOCH_TIMER_DAY");
         }
         else if(ASCompat.toBool(_loc2_[3]))
         {
            _loc3_ += Std.string(_loc2_[3]) + " " + Locale.getString("EPOCH_TIMER_DAYS");
         }
         if(ASCompat.toNumber(_loc2_[4]) == 0 && ASCompat.toNumber(_loc2_[3]) == 0)
         {
            _loc3_ = ASCompat.toNumber(_loc2_[2]) + ":" + zeroPad(ASCompat.toInt(_loc2_[1]),2) + ":" + zeroPad(ASCompat.toInt(_loc2_[0]),2);
         }
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.label_timer, "text", _loc3_);
      }
      
      public function zeroPad(param1:Int, param2:Int) : String
      {
         var _loc3_= "" + param1;
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
      function setXP(param1:UInt, param2:GMHero) 
      {
         mXPBar.value = param1;
         var _loc5_= param2.getLevelFromExp(param1);
         ASCompat.setProperty((mRootMovieClip : ASAny).ui_league.UI_XP.xp_level, "text", Std.string(_loc5_));
         var _loc4_= param1;
         var _loc3_= (param2.getLevelIndex(param1) : UInt);
         var _loc7_= (ASCompat.toInt(_loc3_ > 0 ? param2.getExpFromIndex(_loc3_ - 1) : 0) : UInt);
         var _loc6_= param2.getExpFromIndex(_loc3_);
         mXPBar.value = ASCompat.toNumber(_loc4_ - _loc7_) / (_loc6_ - _loc7_);
      }
      
      public function deinit() 
      {
         var _loc1_:ASAny;
         var __ax4_iter_165:Array<ASAny>;
         mTownStateMachine = null;
         mDidDrag = false;
         mShowedDragMessage = false;
         endEpochCountdown();
         if(mXPBar != null)
         {
            mXPBar.destroy();
            mXPBar = null;
         }
         if(mRevealer != null)
         {
            mRevealer.destroy();
            mRevealer = null;
         }
         if(mLeagueNameRevealer != null)
         {
            mLeagueNameRevealer.destroy();
            mLeagueNameRevealer = null;
         }
         if(mChooseDungeonMessage != null)
         {
            mChooseDungeonMessage.destroy();
            mChooseDungeonMessage = null;
         }
         if(mDragMessageRevealer != null)
         {
            mDragMessageRevealer.destroy();
            mDragMessageRevealer = null;
         }
         if(mDragMessageFloater != null)
         {
            mDragMessageFloater.destroy();
            mDragMessageFloater = null;
         }
         if(mReturnToTownButton != null)
         {
            mReturnToTownButton.enabled = false;
            mReturnToTownButton.destroy();
            mReturnToTownButton = null;
         }
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseUp",onMouseUp);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseOut",onMouseOut);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseLeave",onMouseOut);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseMove",onDrag);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseOver",onMouseOver);
         mDBFacade.mouseCursorManager.popMouseCursor();
         if(mClosedNodeList != null)
         {
            mClosedNodeList.clear();
         }
         mNodePath = null;
         mNodeQueue = null;
         if(mIIBattlePopup != null)
         {
            mIIBattlePopup.destroy();
            mIIBattlePopup = null;
         }
         if(mRegularBattlePopup != null)
         {
            mRegularBattlePopup.destroy();
            mRegularBattlePopup = null;
         }
         mBattlePopup = null;
         if(mMouseTask != null)
         {
            mMouseTask.destroy();
            mMouseTask = null;
         }
         if(mCameraLerpTask != null)
         {
            mCameraLerpTask.destroy();
            mCameraLerpTask = null;
         }
         if(mMapDragTask != null)
         {
            mMapDragTask.destroy();
            mMapDragTask = null;
         }
         if(mMapAvatar != null)
         {
            mMapAvatar.destroy(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap, flash.display.MovieClip));
            mMapAvatar = null;
         }
         if(mOpenNodeButtons != null)
         {
            __ax4_iter_165 = mOpenNodeButtons.toArray();
            if (checkNullIteratee(__ax4_iter_165)) for (_tmp_ in __ax4_iter_165)
            {
               _loc1_ = _tmp_;
               ASCompat.setProperty(_loc1_, "enabled", false);
               _loc1_.destroy();
            }
            mOpenNodeButtons.clear();
            mOpenNodeButtons = null;
         }
         if(mMouseTask != null)
         {
            mMouseTask.destroy();
            mMouseTask = null;
         }
         if(mWorkComponent != null)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         if(mEventComponent != null)
         {
            mEventComponent.removeAllListeners();
         }
         if(mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_PLAY_MAP_NODE",false))
         {
            tearDownHacksToPlayNode();
         }
      }
      
      function createPlayerAvatar() 
      {
         var node:DisplayObject;
         var forceClassCompilation:UIMapAvatarDropMover;
         var mapAvatarClass= mTownSwfAsset.getClass("Branch_map_avatar");
         var avatar= ASCompat.dynamicAs(ASCompat.createInstance(mapAvatarClass, []) , MovieClip);
         var avatarDropShadowClass= mTownSwfAsset.getClass("Branch_map_avatar_shadow");
         var avatarDropShadow= ASCompat.dynamicAs(ASCompat.createInstance(avatarDropShadowClass, []) , MovieClip);
         (mRootMovieClip : ASAny).worldmap.addChild(avatar);
         (mRootMovieClip : ASAny).worldmap.addChild(avatarDropShadow);
         node = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.DisplayObjectContainer).getChildByName(mCurrentNode.Constant), flash.display.DisplayObject);
         if(node != null)
         {
            node.visible = true;
            ASCompat.setProperty((avatar : ASAny).join, "visible", false);
            avatar.x = node.x;
            avatar.y = node.y - avatar.height / 2;
            avatarDropShadow.x = avatar.x;
            avatarDropShadow.y = avatar.y;
            mDBFacade.dbAccountInfo.activeAvatarInfo.loadHeroIcon(function(param1:MovieClip)
            {
               (avatar : ASAny).pic.addChild(param1);
            });
            avatarDropShadow.mouseChildren = false;
            avatarDropShadow.mouseEnabled = false;
            avatar.mouseChildren = false;
            avatar.mouseEnabled = false;
            mMapAvatar = new UIMapAvatar(mDBFacade,avatar,avatarDropShadow,(Type.resolveClass("UI.Map.UIMapAvatarDropMover") : Dynamic));
         }
      }
      
      function friendJoinCallback(param1:UInt) : ASFunction
      {
         var friendId= param1;
         return function()
         {
            if(mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length == 0)
            {
               mDBFacade.metrics.log("NoWeaponsEquippedWarning");
               mDBFacade.errorPopup("Warning","Cannot enter dungeon with no weapons equipped.","NO_WEAPONS_DUNGEON_ERROR_POPUP");
            }
            else
            {
               mDBFacade.mouseCursorManager.popMouseCursor();
               mDBFacade.mouseCursorManager.disable = true;
               mDBFacade.metrics.log("JoinFriend",{"friendId":friendId});
               mDBFacade.mainStateMachine.enterLoadingScreenState((0 : UInt),"",friendId,(0 : UInt),true,mBattlePopup.IsPrivate);
            }
         };
      }
      
      function clearAvatarList() 
      {
         var _loc2_:ASAny;
         var __ax4_iter_166:Array<ASAny>;
         var _loc1_:ASAny;
         var __ax4_iter_167:Array<ASAny>;
         if(mAvatarList != null)
         {
            __ax4_iter_166 = mAvatarList;
            if (checkNullIteratee(__ax4_iter_166)) for (_tmp_ in __ax4_iter_166)
            {
               _loc2_ = _tmp_;
               (mRootMovieClip : ASAny).worldmap.removeChild(_loc2_);
            }
         }
         if(mAvatarDropShadowList != null)
         {
            __ax4_iter_167 = mAvatarDropShadowList;
            if (checkNullIteratee(__ax4_iter_167)) for (_tmp_ in __ax4_iter_167)
            {
               _loc1_ = _tmp_;
               (mRootMovieClip : ASAny).worldmap.removeChild(_loc1_);
            }
         }
      }
      
      function sortAvatarList() 
      {
         var i:UInt;
         var avatar_clip:MovieClip;
         var shadow_clip:MovieClip;
         var ysort:ASFunction = function(param1:MovieClip, param2:MovieClip):Int
         {
            if(param1.y < param2.y - 15)
            {
               return -1;
            }
            if(param1.y > param2.y + 15)
            {
               return 1;
            }
            return 0;
         };
         ASCompat.ASArray.sort(mAvatarList, ysort);
         ASCompat.ASArray.sort(mAvatarDropShadowList, ysort);
         i = (0 : UInt);
         while(i < (mAvatarList.length : UInt))
         {
            avatar_clip = ASCompat.dynamicAs(mAvatarList[(i : Int)], flash.display.MovieClip);
            shadow_clip = ASCompat.dynamicAs(mAvatarDropShadowList[(i : Int)], flash.display.MovieClip);
            (mRootMovieClip : ASAny).worldmap.addChild(shadow_clip);
            (mRootMovieClip : ASAny).worldmap.addChild(avatar_clip);
            i = i + 1;
         }
      }
      
      function updateFriends(param1:Event = null) 
      {
      }
      
      function cutsceneSwfLoaded(param1:String) : ASFunction
      {
         var className= param1;
         return function(param1:SwfAsset)
         {
            mRootMovieClip.visible = false;
            mBattlePopup.animatePopupOut();
            mSceneGraphComponent.fadeIn(1);
            var _loc2_= new MovieClipRenderController(mDBFacade,param1.root);
            mSceneGraphComponent.addChild(param1.root,(50 : UInt));
            _loc2_.play((0 : UInt),false,cutsceneDone(param1.root,_loc2_));
         };
      }
      
      function cutsceneDone(param1:MovieClip, param2:MovieClipRenderController) : ASFunction
      {
         var clip= param1;
         var movieClipRenderer= param2;
         return function()
         {
            mSceneGraphComponent.removeChild(clip);
            mDBFacade.mouseCursorManager.popMouseCursor();
            mDBFacade.mouseCursorManager.disable = true;
            mDBFacade.mainStateMachine.enterLoadingScreenState(mCurrentNode.Id,mCurrentNode.NodeType,(0 : UInt),(0 : UInt),true,mBattlePopup.IsPrivate);
            movieClipRenderer.destroy();
         };
      }
      
      function killCameraLerp() 
      {
         if(mCameraLerpTask != null)
         {
            mCameraLerpTask.destroy();
            mCameraLerpTask = null;
            mCameraVelocityX = 0;
            mCameraVelocityY = 0;
         }
      }
      
      function centerMapOnClip(param1:MovieClip, param2:String = null) 
      {
         var _loc6_= param1.getRect(param1);
         var _loc3_= param1.localToGlobal(new Point(_loc6_.left + param1.width * 0.5,0));
         var _loc4_= ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.localToGlobal(new Point(0,0)), flash.geom.Point);
         var _loc5_= _loc3_.x - _loc4_.x;
         if(param2 == "ROOKIE")
         {
            mCameraTargetX = mRootMovieClip.stage.stageWidth * 0.9 - _loc5_;
         }
         else if(param2 == "GLADIATOR")
         {
            mCameraTargetX = -1900;
         }
         else if(param2 == "CHAMPION")
         {
            mCameraTargetX = -3850;
         }
         else if(param2 == "GRINDHOUSE")
         {
            mCameraTargetX = -5800;
         }
         if(param2 == "INFINITEISLAND")
         {
            mCameraTargetX = -8100;
         }
         if(mCameraLerpTask != null)
         {
            mCameraLerpTask.destroy();
         }
         mCameraVelocityX = 0;
         mCameraVelocityY = 0;
         mCameraLerpTask = mWorkComponent.doEveryFrame(centerCamera);
      }
      
      function centerCamera(param1:GameClock) 
      {
         var _loc3_= ASCompat.toNumber(mCameraTargetX - ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "x"));
         var _loc4_= ASCompat.toNumber(mCameraTargetY - ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "y"));
         var _loc2_= _loc3_ * _loc3_ + _loc4_ * _loc4_;
         var _loc5_= 1 - Math.pow(1 - 0.2916666666666667,param1.tickLength / GameClock.ANIMATION_FRAME_DURATION);
         mCameraVelocityX = _loc3_ * _loc5_;
         var __tmpAssignObj11:ASAny = (mRootMovieClip : ASAny).worldmap;
         ASCompat.setProperty(__tmpAssignObj11, "x", __tmpAssignObj11.x + mCameraVelocityX);
         clampMap();
         if(_loc2_ < 0.0001)
         {
            mCameraVelocityX = 0;
            mCameraVelocityY = 0;
            killCameraLerp();
         }
      }
      
      function startSlide() 
      {
         ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "mouseChildren", true);
         if(mMouseTask != null)
         {
            mMouseTask.destroy();
            mMouseTask = null;
         }
         mMouseTask = mWorkComponent.doEveryFrame(updateSlide);
      }
      
      function clampMap() 
      {
         ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "x", Math.min(ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "x"),-13));
         ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "x", Math.max(ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "x"),ASCompat.toNumber(-mMapWidth + (mRootMovieClip : ASAny).worldmap.stage.stageWidth)));
      }
      
      function updateSlide(param1:GameClock) 
      {
         var _loc2_= 0;
         var _loc7_:Point = null;
         var _loc3_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc4_:Point = null;
         updateDrag(param1);
         var _loc8_= Math.abs(mMouseVelocityX);
         if(mMouseTask != null)
         {
            mMouseTask.destroy();
            mMouseTask = null;
            _loc2_ = (mCurrentLeague : Int);
            if(_loc8_ > 10)
            {
               if(mMouseVelocityX > 0)
               {
                  mCurrentLeague = determineNextLeague();
                  updateCurrentLeague((_loc2_ : UInt) != mCurrentLeague);
               }
               else
               {
                  mCurrentLeague = (ASCompat.toInt(mCurrentLeague > 0 ? mCurrentLeague - 1 : (0 : UInt)) : UInt);
                  updateCurrentLeague((_loc2_ : UInt) != mCurrentLeague);
               }
            }
            else
            {
               _loc7_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.gladiator_league.localToGlobal(new Point(0,0)), flash.geom.Point);
               _loc3_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.rookie_league.localToGlobal(new Point(0,0)), flash.geom.Point);
               _loc5_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.grinder_league.localToGlobal(new Point(0,0)), flash.geom.Point);
               _loc6_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.heroic_league.localToGlobal(new Point(0,0)), flash.geom.Point);
               _loc4_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.infinite_island_league.localToGlobal(new Point(0,0)), flash.geom.Point);
               if(Math.abs(_loc7_.x) < Math.abs(_loc3_.x) && Math.abs(_loc7_.x) < Math.abs(_loc5_.x) && Math.abs(_loc7_.x) < Math.abs(_loc6_.x) && Math.abs(_loc7_.x) < Math.abs(_loc4_.x))
               {
                  mCurrentLeague = (1 : UInt);
                  updateCurrentLeague((_loc2_ : UInt) != mCurrentLeague);
               }
               else if(Math.abs(_loc3_.x) < Math.abs(_loc7_.x) && Math.abs(_loc3_.x) < Math.abs(_loc5_.x) && Math.abs(_loc3_.x) < Math.abs(_loc6_.x) && Math.abs(_loc3_.x) < Math.abs(_loc4_.x))
               {
                  mCurrentLeague = (0 : UInt);
                  updateCurrentLeague((_loc2_ : UInt) != mCurrentLeague);
               }
               else if(Math.abs(_loc5_.x) < Math.abs(_loc3_.x) && Math.abs(_loc5_.x) < Math.abs(_loc7_.x) && Math.abs(_loc5_.x) < Math.abs(_loc6_.x) && Math.abs(_loc5_.x) < Math.abs(_loc4_.x))
               {
                  mCurrentLeague = (3 : UInt);
                  updateCurrentLeague((_loc2_ : UInt) != mCurrentLeague);
               }
               else if(Math.abs(_loc6_.x) < Math.abs(_loc3_.x) && Math.abs(_loc6_.x) < Math.abs(_loc7_.x) && Math.abs(_loc6_.x) < Math.abs(_loc5_.x) && Math.abs(_loc6_.x) < Math.abs(_loc4_.x))
               {
                  mCurrentLeague = (2 : UInt);
                  updateCurrentLeague((_loc2_ : UInt) != mCurrentLeague);
               }
               else if(Math.abs(_loc4_.x) < Math.abs(_loc3_.x) && Math.abs(_loc4_.x) < Math.abs(_loc7_.x) && Math.abs(_loc4_.x) < Math.abs(_loc5_.x) && Math.abs(_loc4_.x) < Math.abs(_loc6_.x))
               {
                  mCurrentLeague = (4 : UInt);
                  updateCurrentLeague((_loc2_ : UInt) != mCurrentLeague);
               }
            }
         }
      }
      
      function updateDrag(param1:GameClock) 
      {
         var _loc2_= mMouseVelocityX * Math.min(0.9,param1.tickLength * 10);
         var __tmpAssignObj12:ASAny = (mRootMovieClip : ASAny).worldmap;
         ASCompat.setProperty(__tmpAssignObj12, "x", __tmpAssignObj12.x - _loc2_);
         mMouseVelocityX -= _loc2_;
         clampMap();
      }
      
      function onDrag(param1:MouseEvent) 
      {
         mDidDrag = true;
         killCameraLerp();
         var _loc2_= mOldMouseX - param1.stageX;
         mMouseVelocityX += _loc2_;
         mOldMouseX = param1.stageX;
         mOldMouseY = param1.stageY;
         clampMap();
      }
      
      function onMouseUp(param1:MouseEvent) 
      {
         if(mMapDragTask != null)
         {
            mMapDragTask.destroy();
            mMapDragTask = null;
         }
         mDBFacade.mouseCursorManager.popMouseCursor();
         ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "mouseChildren", true);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseUp",onMouseUp);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseOut",onMouseOut);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseLeave",onMouseOut);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseMove",onDrag);
         startSlide();
      }
      
      function onMouseOut(param1:MouseEvent) 
      {
         mDBFacade.mouseCursorManager.popMouseCursor();
         ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "mouseChildren", true);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseUp",onMouseUp);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseOut",onMouseOut);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseLeave",onMouseOut);
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseMove",onDrag);
         (mRootMovieClip : ASAny).worldmap.addEventListener("mouseOver",onMouseOver);
         startSlide();
      }
      
      function onMouseOver(param1:MouseEvent) 
      {
         (mRootMovieClip : ASAny).worldmap.removeEventListener("mouseOver",onMouseOver);
         if(param1.buttonDown)
         {
            onMouseDown(param1);
         }
      }
      
      function onMouseDown(param1:MouseEvent) 
      {
         mDBFacade.mouseCursorManager.pushMouseCursor("DRAG");
         if(mMouseTask != null)
         {
            mMouseTask.destroy();
            mMouseTask = null;
         }
         mOldMouseX = param1.stageX;
         mOldMouseY = param1.stageY;
         mMouseVelocityX = 0;
         mMouseVelocityY = 0;
         if(mMapDragTask == null)
         {
            mMapDragTask = mWorkComponent.doEveryFrame(updateDrag);
         }
         ASCompat.setProperty((mRootMovieClip : ASAny).worldmap, "mouseChildren", false);
         (mRootMovieClip : ASAny).worldmap.addEventListener("mouseMove",onDrag);
         (mRootMovieClip : ASAny).worldmap.addEventListener("mouseUp",onMouseUp);
         (mRootMovieClip : ASAny).worldmap.addEventListener("mouseOut",onMouseOut);
         (mRootMovieClip : ASAny).worldmap.addEventListener("mouseLeave",onMouseOut);
      }
      
      function isMapNode(param1:ASObject) : Bool
      {
         return (param1 : ASAny).constructor == mMapNodeClass;
      }
      
      function clearMouseEnabledOnWorldmap() 
      {
         var _loc1_= 0;
         var _loc2_:MovieClip = null;
         _loc1_ = 0;
         while(_loc1_ < ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "numChildren"))
         {
            _loc2_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.getChildAt(_loc1_) , MovieClip);
            if(_loc2_ != null && _loc2_ != (mRootMovieClip : ASAny).worldmap.TOWNBUTTON && _loc2_ != (mRootMovieClip : ASAny).worldmap.rookie_league && _loc2_ != (mRootMovieClip : ASAny).worldmap.gladiator_league && _loc2_ != (mRootMovieClip : ASAny).worldmap.grinder_league && _loc2_ != (mRootMovieClip : ASAny).worldmap.heroic_league && _loc2_ != (mRootMovieClip : ASAny).worldmap.infinite_island_league)
            {
               _loc2_.mouseChildren = false;
               _loc2_.mouseEnabled = false;
            }
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      function hideAllMapNodes() 
      {
      }
      
      function revealCallback(param1:MovieClip) : ASFunction
      {
         var childClip= param1;
         return function(param1:GameClock)
         {
            var _loc2_:Revealer = null;
            if(childClip != null)
            {
               childClip.visible = true;
               _loc2_ = new Revealer(childClip,mDBFacade,(24 : UInt));
            }
         };
      }
      
      function getMapnodeFromCurrentNode1() : MapnodeInfo
      {
         return ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(mCurrentNode.Id), account.MapnodeInfo);
      }
      
      function mapNodesOpen(param1:Array<ASAny>, param2:Bool = false) : Bool
      {
         var _loc4_= 0;
         var _loc3_:GMMapNode = null;
         if(param1 == null || mDBFacade.dbAccountInfo == null || mDBFacade.dbAccountInfo.inventoryInfo == null)
         {
            return false;
         }
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = ASCompat.dynamicAs(param1[_loc4_], gameMasterDictionary.GMMapNode);
            if(mapNodeOpen(_loc3_,param2))
            {
               return true;
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         return false;
      }
      
      function mapNodeOpen(param1:GMMapNode, param2:Bool = false) : Bool
      {
         if(param1 == null || mDBFacade.dbAccountInfo == null || mDBFacade.dbAccountInfo.inventoryInfo == null)
         {
            return false;
         }
         var _loc3_= ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(param1.Id), account.MapnodeInfo);
         return _loc3_ != null && (!param2 || _loc3_.MapnodeState == 1 || _loc3_.MapnodeState == 3);
      }
      
      function mapNodeOpenNotDefeated(param1:GMMapNode) : Bool
      {
         if(param1 == null || mDBFacade.dbAccountInfo == null || mDBFacade.dbAccountInfo.inventoryInfo == null)
         {
            return false;
         }
         var _loc2_= ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(param1.Id), account.MapnodeInfo);
         return _loc2_ != null && _loc2_.MapnodeState == 3;
      }
      
      function mapNodeLocked(param1:GMMapNode) : Bool
      {
         if(param1 == null || mDBFacade.dbAccountInfo == null || mDBFacade.dbAccountInfo.inventoryInfo == null)
         {
            return false;
         }
         var _loc2_= ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(param1.Id), account.MapnodeInfo);
         return _loc2_ == null;
      }
      
      function getUnlockedNodes() : Array<ASAny>
      {
         return mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.toArray();
      }
      
      function hasLockedNextNode(param1:GMMapNode) : Bool
      {
         var _loc2_:ASAny;
         final __ax4_iter_168 = param1.ChildNodes;
         if (checkNullIteratee(__ax4_iter_168)) for (_tmp_ in __ax4_iter_168)
         {
            _loc2_ = _tmp_;
            if(ASCompat.toBool(_loc2_))
            {
               if(mapNodeLocked(ASCompat.dynamicAs(_loc2_, gameMasterDictionary.GMMapNode)))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      function hasUnlockedChild(param1:GMMapNode) : Bool
      {
         var _loc2_:GMMapNode = null;
         var _loc3_:ASAny;
         final __ax4_iter_169 = param1.RevealNodes;
         if (checkNullIteratee(__ax4_iter_169)) for (_tmp_ in __ax4_iter_169)
         {
            _loc3_ = _tmp_;
            if(ASCompat.toBool(_loc3_))
            {
               _loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc3_), gameMasterDictionary.GMMapNode);
               if(_loc2_ != null && mapNodeOpen(_loc2_,true))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      function isChildNode(param1:GMMapNode, param2:String) : Bool
      {
         var _loc3_:ASAny;
         final __ax4_iter_170 = param1.ChildNodes;
         if (checkNullIteratee(__ax4_iter_170)) for (_tmp_ in __ax4_iter_170)
         {
            _loc3_ = _tmp_;
            if(ASCompat.toBool(_loc3_) && _loc3_.Constant == param2)
            {
               return true;
            }
         }
         return false;
      }
      
      function getClipFromConstant(param1:String) : MovieClip
      {
         var _loc2_= ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.DisplayObjectContainer).getChildByName(param1) , MovieClip);
         if(_loc2_ == null)
         {
            _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.DisplayObjectContainer).getChildByName(param1) , MovieClip);
            if(_loc2_ == null)
            {
               _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.DisplayObjectContainer).getChildByName(param1) , MovieClip);
               if(_loc2_ == null)
               {
                  _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.DisplayObjectContainer).getChildByName(param1) , MovieClip);
                  if(_loc2_ == null)
                  {
                     _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.DisplayObjectContainer).getChildByName(param1) , MovieClip);
                     if(_loc2_ == null)
                     {
                        return null;
                     }
                  }
               }
            }
         }
         return _loc2_;
      }
      
      function revealChildNodes(param1:GMMapNode) 
      {
         var _loc3_:GMMapNode = null;
         var _loc2_:MovieClip = null;
         var _loc5_:GMMapNode = null;
         var _loc6_= getClipFromConstant(param1.Constant);
         if(_loc6_ == null)
         {
            return;
         }
         _loc6_.visible = true;
         var _loc7_:Float = 0.15;
         var _loc4_= hasUnlockedChild(param1);
         var _loc8_:ASAny;
         final __ax4_iter_171 = param1.RevealNodes;
         if (checkNullIteratee(__ax4_iter_171)) for (_tmp_ in __ax4_iter_171)
         {
            _loc8_ = _tmp_;
            if(ASCompat.toBool(_loc8_))
            {
               _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc8_), gameMasterDictionary.GMMapNode);
               if(!(_loc3_ != null && mapNodeOpen(_loc3_,true)))
               {
                  _loc2_ = getClipFromConstant(_loc8_);
                  if(_loc4_)
                  {
                     if(_loc2_ != null)
                     {
                        _loc2_.visible = true;
                     }
                  }
                  else if(_loc2_ != null)
                  {
                     _loc5_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc2_.name), gameMasterDictionary.GMMapNode);
                     if(_loc5_ != null && !_loc5_.AlwaysVisible)
                     {
                        mWorkComponent.doLater(_loc7_,revealCallback(_loc2_));
                        _loc7_ += 0.15;
                     }
                  }
               }
            }
         }
      }
      
      function initializeLeagueMapNodes(param1:MovieClip, param2:Bool = false) 
      {
         var _loc5_= 0;
         var _loc3_:MovieClip = null;
         var _loc4_:GMMapNode = null;
         _loc5_ = 0;
         while(_loc5_ < param1.numChildren)
         {
            _loc3_ = ASCompat.reinterpretAs(param1.getChildAt(_loc5_) , MovieClip);
            if(_loc3_ != null)
            {
               ASCompat.setProperty((_loc3_ : ASAny).arrow, "visible", false);
               ASCompat.setProperty((_loc3_ : ASAny).arrow, "mouseEnabled", false);
               ASCompat.setProperty((_loc3_ : ASAny).arrow, "mouseChildren", false);
               if(ASCompat.toBool((_loc3_ : ASAny).defeated) && ASCompat.toBool((_loc3_ : ASAny).unlocked) && ASCompat.toBool((_loc3_ : ASAny).locked))
               {
                  ASCompat.setProperty((_loc3_ : ASAny).defeated, "visible", false);
                  ASCompat.setProperty((_loc3_ : ASAny).unlocked, "visible", false);
                  ASCompat.setProperty((_loc3_ : ASAny).locked, "visible", true);
               }
               if(ASCompat.toBool((_loc3_ : ASAny).lock))
               {
                  ASCompat.setProperty((_loc3_ : ASAny).lock, "visible", false);
                  ASCompat.setProperty((_loc3_ : ASAny).lock, "mouseEnabled", false);
               }
               if(ASCompat.toBool((_loc3_ : ASAny).text_popup) && ASCompat.toBool((_loc3_ : ASAny).text_popup.title_label))
               {
                  ASCompat.setProperty((_loc3_ : ASAny).text_popup, "visible", false);
                  ASCompat.setProperty((_loc3_ : ASAny).text_popup.title_label, "text", Locale.getString("DUNGEON_LOCKED_TITLE"));
               }
               if(ASCompat.toBool((_loc3_ : ASAny).label))
               {
                  ASCompat.setProperty((_loc3_ : ASAny).label, "text", "");
               }
               _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc3_.name), gameMasterDictionary.GMMapNode);
               if(_loc4_ == null)
               {
                  Logger.warn("Can\'t find gmMapNode for: " + _loc3_.name);
               }
               else if(!_loc4_.AlwaysVisible)
               {
                  _loc3_.visible = false;
               }
            }
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
      }
      
      function initializeAllMapNodes() 
      {
         var _loc2_= 0;
         var _loc1_:MovieClip = null;
         _loc2_ = 0;
         while(_loc2_ < ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "numChildren"))
         {
            _loc1_ = ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.getChildAt(_loc2_) , MovieClip);
            if(_loc1_ != null && _loc1_.name.indexOf("_unlocked") != -1)
            {
               _loc1_.visible = false;
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
         initializeLeagueMapNodes(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.MovieClip));
         initializeLeagueMapNodes(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.MovieClip));
         initializeLeagueMapNodes(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.MovieClip));
         initializeLeagueMapNodes(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.MovieClip));
         initializeLeagueMapNodes(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.MovieClip),true);
      }
      
      function initializeOpenMapNodes() 
      {
         var _loc8_:MapnodeInfo = null;
         var _loc5_:GMMapNode = null;
         var _loc2_:MovieClip = null;
         var _loc9_:String = null;
         var _loc11_:GMColiseumTier = null;
         var _loc3_= 0;
         var _loc10_:GMInfiniteDungeon = null;
         var _loc1_:Array<ASAny> = null;
         var _loc7_= 0;
         var _loc4_= getUnlockedNodes();
         _loc4_.sort(Reflect.compare);
         var _loc6_= (0 : UInt);
         mCurrentLeague = (0 : UInt);
         ASCompat.ASArray.sortOn(_loc4_, "nodeId",16);
         _loc6_ = (0 : UInt);
         while(_loc6_ < (_loc4_.length : UInt))
         {
            _loc8_ = ASCompat.dynamicAs(_loc4_[(_loc6_ : Int)] , MapnodeInfo);
            _loc5_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeById.itemFor(_loc8_.nodeId), gameMasterDictionary.GMMapNode);
            if(_loc5_ != null)
            {
               _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.DisplayObjectContainer).getChildByName(_loc5_.Constant), flash.display.MovieClip);
               if(_loc2_ == null)
               {
                  _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.DisplayObjectContainer).getChildByName(_loc5_.Constant), flash.display.MovieClip);
                  mCurrentLeague = (ASCompat.toInt(_loc2_ != null && mCurrentLeague < 1 ? (1 : UInt) : mCurrentLeague) : UInt);
                  if(_loc2_ == null)
                  {
                     _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.DisplayObjectContainer).getChildByName(_loc5_.Constant), flash.display.MovieClip);
                     mCurrentLeague = (ASCompat.toInt(_loc2_ != null && mCurrentLeague < 3 ? (3 : UInt) : mCurrentLeague) : UInt);
                     if(_loc2_ == null)
                     {
                        _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.DisplayObjectContainer).getChildByName(_loc5_.Constant), flash.display.MovieClip);
                        mCurrentLeague = (ASCompat.toInt(_loc2_ != null && mCurrentLeague < 2 ? (2 : UInt) : mCurrentLeague) : UInt);
                        if(_loc2_ == null)
                        {
                           _loc2_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.DisplayObjectContainer).getChildByName(_loc5_.Constant), flash.display.MovieClip);
                           mCurrentLeague = (ASCompat.toInt(_loc2_ != null && mCurrentLeague < 4 ? (4 : UInt) : mCurrentLeague) : UInt);
                           if(_loc2_ == null)
                           {
                              Logger.warn("Can\'t find movie clip node for gmMapNode Constant: " + _loc5_.Constant);
                           }
                        }
                     }
                  }
               }
               mCurrentNode = _loc5_;
               if(_loc2_ != null)
               {
                  if(ASCompat.toBool((_loc2_ : ASAny).text_popup) && ASCompat.toBool((_loc2_ : ASAny).text_popup.title_label) && ASCompat.toBool((_loc2_ : ASAny).text_popup.description_label))
                  {
                     ASCompat.setProperty((_loc2_ : ASAny).text_popup, "visible", true);
                     ASCompat.setProperty((_loc2_ : ASAny).text_popup.title_label, "text", GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",_loc5_.Constant).toUpperCase());
                     _loc11_ = ASCompat.dynamicAs(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(_loc5_.TierRank), gameMasterDictionary.GMColiseumTier);
                     if(_loc11_.TotalFloors > 0 && _loc5_.NodeType != "BOSS")
                     {
                        _loc9_ = _loc11_.TotalFloors > 1 ? Locale.getString("FLOORS") : Locale.getString("FLOOR");
                        if(_loc11_.TotalFloors >= 50)
                        {
                           ASCompat.setProperty((_loc2_ : ASAny).text_popup.description_label, "text", Locale.getString("INFINITE_FLOORS_POPUP"));
                        }
                        else
                        {
                           ASCompat.setProperty((_loc2_ : ASAny).text_popup.description_label, "text", Std.string(_loc11_.TotalFloors) + " " + _loc9_);
                        }
                     }
                     else
                     {
                        ASCompat.setProperty((_loc2_ : ASAny).text_popup.description_label, "text", GameMasterLocale.getGameMasterSubString("DUNGEON_DIFFICULTY_NAME",_loc5_.Constant));
                     }
                  }
                  _loc2_.visible = true;
                  ASCompat.setProperty((_loc2_ : ASAny).arrow, "visible", false);
                  ASCompat.setProperty((_loc2_ : ASAny).arrow, "mouseEnabled", false);
                  ASCompat.setProperty((_loc2_ : ASAny).arrow, "mouseChildren", false);
                  if(ASCompat.toBool((_loc2_ : ASAny).locked))
                  {
                     ASCompat.setProperty((_loc2_ : ASAny).locked, "visible", false);
                  }
                  if(mapNodeOpenNotDefeated(_loc5_))
                  {
                     ASCompat.setProperty((_loc2_ : ASAny).unlocked, "visible", true);
                     revealChildNodes(_loc5_);
                  }
                  else if(mapNodeOpen(_loc5_,true))
                  {
                     if(ASCompat.toBool((_loc2_ : ASAny).defeated))
                     {
                        ASCompat.setProperty((_loc2_ : ASAny).defeated, "visible", true);
                     }
                     revealChildNodes(_loc5_);
                  }
                  else if(ASCompat.toBool((_loc2_ : ASAny).unlocked))
                  {
                     ASCompat.setProperty((_loc2_ : ASAny).unlocked, "visible", true);
                     if(hasLockedNextNode(_loc5_))
                     {
                        ASCompat.setProperty((_loc2_ : ASAny).arrow, "visible", true);
                        ASCompat.setProperty((_loc2_ : ASAny).arrow, "mouseChildren", false);
                        ASCompat.setProperty((_loc2_ : ASAny).arrow, "mouseEnabled", false);
                     }
                  }
                  if(_loc5_.IsInfiniteDungeon)
                  {
                     if(mDBFacade.dbAccountInfo.localFriendInfo == null)
                     {
                        return;
                     }
                     _loc3_ = mDBFacade.dbAccountInfo.localFriendInfo.getIIAvatarScoreForNode((mDBFacade.dbAccountInfo.activeAvatarId : Int),(_loc5_.Id : Int));
                     _loc10_ = ASCompat.dynamicAs(mDBFacade.gameMaster.infiniteDungeonsByConstant.itemFor(_loc5_.InfiniteDungeon), gameMasterDictionary.GMInfiniteDungeon);
                     _loc1_ = [(_loc2_ : ASAny).reward01,(_loc2_ : ASAny).reward02,(_loc2_ : ASAny).reward03,(_loc2_ : ASAny).reward04];
                     _loc7_ = 0;
                     while(_loc7_ < 4)
                     {
                        ASCompat.setProperty(_loc1_[_loc7_], "visible", (_loc3_ : UInt) > _loc10_.RewardFloors[_loc7_]);
                        _loc7_++;
                     }
                  }
                  if(ASCompat.toBool((_loc2_ : ASAny).label) && mCurrentLeague != 3)
                  {
                     ASCompat.setProperty((_loc2_ : ASAny).label, "text", GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",_loc5_.Constant).toUpperCase());
                  }
                  else if(ASCompat.toBool((_loc2_ : ASAny).label) && mCurrentLeague == 3)
                  {
                     ASCompat.setProperty((_loc2_ : ASAny).label, "visible", false);
                  }
               }
            }
            _loc6_++;
         }
      }
      
      function createNodeButtonsForLeague(param1:MovieClip) : Bool
      {
         var _loc5_= 0;
         var _loc10_:MovieClip = null;
         var _loc13_= false;
         var _loc11_= false;
         var _loc3_:GMMapNode = null;
         var _loc9_:MovieClip = null;
         var _loc4_:MovieClipRenderController = null;
         var _loc7_= 0;
         var _loc6_:GMMapNode = null;
         var _loc14_:MovieClip = null;
         var _loc8_:UIButton = null;
         var _loc12_:UIButton = null;
         var _loc2_= false;
         _loc5_ = 0;
         while(_loc5_ < param1.numChildren)
         {
            _loc10_ = ASCompat.reinterpretAs(param1.getChildAt(_loc5_) , MovieClip);
            if(_loc10_ != null)
            {
               _loc13_ = false;
               _loc11_ = false;
               _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc10_.name), gameMasterDictionary.GMMapNode);
               if(_loc3_ != null)
               {
                  if(mapNodesOpen(_loc3_.ParentNodes,false))
                  {
                     if(_loc3_.LevelRequirement <= mDBFacade.dbAccountInfo.activeAvatarInfo.level)
                     {
                        if(ASCompat.toBool((_loc10_ : ASAny).level_req))
                        {
                           ASCompat.setProperty((_loc10_ : ASAny).level_req, "visible", false);
                        }
                     }
                     else
                     {
                        _loc13_ = true;
                        if(ASCompat.toBool((_loc10_ : ASAny).level_req))
                        {
                           ASCompat.setProperty((_loc10_ : ASAny).level_req, "visible", true);
                           ASCompat.setProperty((_loc10_ : ASAny).level_req.level_label, "text", Std.string(_loc3_.LevelRequirement));
                        }
                        if(ASCompat.toBool((_loc10_ : ASAny).text_popup))
                        {
                           ASCompat.setProperty((_loc10_ : ASAny).text_popup.description_label, "text", "You are not high enough level to play this dungeon.");
                        }
                     }
                     if(_loc3_.TrophyRequirement <= mDBFacade.dbAccountInfo.trophies)
                     {
                        if(ASCompat.toBool((_loc10_ : ASAny).level_req))
                        {
                           ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left, "visible", false);
                           ASCompat.setProperty((_loc10_ : ASAny).trophy_req, "visible", false);
                        }
                     }
                     else
                     {
                        _loc13_ = true;
                        if((_loc10_ : ASAny).level_req.visible == true)
                        {
                           ASCompat.setProperty((_loc10_ : ASAny).level_req, "visible", false);
                           ASCompat.setProperty((_loc10_ : ASAny).trophy_req, "visible", false);
                           ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left, "visible", true);
                           ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left.level_label, "text", Std.string(_loc3_.LevelRequirement));
                           ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left.trophy_label, "text", Std.string(_loc3_.TrophyRequirement));
                           ASCompat.setProperty((_loc10_ : ASAny).text_popup.description_label, "text", "Not high enough level, and not enough trophies.");
                        }
                        else
                        {
                           ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left, "visible", false);
                           ASCompat.setProperty((_loc10_ : ASAny).trophy_req, "visible", true);
                           ASCompat.setProperty((_loc10_ : ASAny).trophy_req.trophy_label, "text", Std.string(_loc3_.TrophyRequirement));
                           ASCompat.setProperty((_loc10_ : ASAny).text_popup.description_label, "text", "Not enough trophies to play this dungeon.");
                        }
                     }
                     if(_loc13_)
                     {
                        if(ASCompat.toBool((_loc10_ : ASAny).lock))
                        {
                           ASCompat.setProperty((_loc10_ : ASAny).lock, "visible", true);
                        }
                        _loc11_ = true;
                     }
                     else if(!mapNodesOpen(_loc3_.ParentNodes,true))
                     {
                        if(ASCompat.toBool((_loc10_ : ASAny).lock))
                        {
                           ASCompat.setProperty((_loc10_ : ASAny).lock, "visible", true);
                        }
                        _loc13_ = true;
                     }
                  }
                  else if(ASCompat.toBool((_loc10_ : ASAny).level_req) && ASCompat.toBool((_loc10_ : ASAny).trophy_req))
                  {
                     ASCompat.setProperty((_loc10_ : ASAny).level_req, "visible", false);
                     ASCompat.setProperty((_loc10_ : ASAny).trophy_req_left, "visible", false);
                     ASCompat.setProperty((_loc10_ : ASAny).trophy_req, "visible", false);
                  }
                  if((_loc10_ : ASAny).unlocked.visible == true)
                  {
                     _loc9_ = ASCompat.dynamicAs((_loc10_ : ASAny).unlocked, flash.display.MovieClip);
                     _loc4_ = new MovieClipRenderController(mDBFacade,_loc9_);
                     _loc4_.play((0 : UInt),true);
                  }
                  else if((_loc10_ : ASAny).defeated.visible == true)
                  {
                     _loc9_ = ASCompat.dynamicAs((_loc10_ : ASAny).defeated, flash.display.MovieClip);
                  }
                  else
                  {
                     _loc13_ = true;
                     _loc9_ = ASCompat.dynamicAs((_loc10_ : ASAny).locked, flash.display.MovieClip);
                  }
                  if(!_loc13_)
                  {
                     _loc2_ = true;
                     _loc7_ = 0;
                     while(_loc7_ < _loc3_.ParentNodes.length)
                     {
                        _loc6_ = ASCompat.dynamicAs(_loc3_.ParentNodes[_loc7_], gameMasterDictionary.GMMapNode);
                        if(_loc6_ != null && mapNodeOpen(_loc6_,true))
                        {
                           _loc14_ = ASCompat.dynamicAs(cast((mRootMovieClip : ASAny).worldmap, flash.display.DisplayObjectContainer).getChildByName(_loc6_.Constant + "_" + _loc3_.Constant + "_unlocked"), flash.display.MovieClip);
                           if(_loc14_ != null)
                           {
                              _loc14_.visible = true;
                              _loc4_ = new MovieClipRenderController(mDBFacade,_loc14_);
                              if(_loc9_ == (_loc10_ : ASAny).unlocked)
                              {
                                 _loc4_.play((0 : UInt),false);
                              }
                              else
                              {
                                 _loc4_.setFrame((_loc14_.totalFrames - 1 : UInt));
                              }
                           }
                        }
                        _loc7_ = ASCompat.toInt(_loc7_) + 1;
                     }
                     _loc8_ = new UIButton(mDBFacade,_loc9_);
                     _loc8_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
                     _loc8_.releaseCallback = moveAvatarToNode(_loc3_);
                     _loc8_.rollOverCursor = "POINT";
                     _loc8_.dontKillMyChildren = true;
                     ASCompat.setProperty((_loc10_ : ASAny).text_popup, "x", 0);
                     ASCompat.setProperty((_loc10_ : ASAny).text_popup, "y", 0);
                     _loc8_.tooltip = ASCompat.dynamicAs((_loc10_ : ASAny).text_popup, flash.display.MovieClip);
                     mOpenNodeButtons.add(_loc3_.Id,_loc8_);
                  }
                  else
                  {
                     _loc12_ = new UIButton(mDBFacade,_loc9_);
                     if(ASCompat.toBool((_loc10_ : ASAny).text_popup) && ASCompat.toBool((_loc10_ : ASAny).text_popup.description_label))
                     {
                        if(!_loc11_)
                        {
                           ASCompat.setProperty((_loc10_ : ASAny).text_popup.description_label, "text", Locale.getString("DUNGEON_LOCKED_DESCRIPTION"));
                        }
                        ASCompat.setProperty((_loc10_ : ASAny).text_popup, "x", 0);
                        ASCompat.setProperty((_loc10_ : ASAny).text_popup, "y", 0);
                        ASCompat.setProperty((_loc10_ : ASAny).text_popup, "visible", true);
                        _loc12_.tooltip = ASCompat.dynamicAs((_loc10_ : ASAny).text_popup, flash.display.MovieClip);
                     }
                     _loc12_.rolloverFilter = DBGlobal.UI_DISABLED_FILTER;
                     _loc12_.releaseCallback = null;
                     _loc12_.rollOverCursor = "POINT";
                     _loc12_.dontKillMyChildren = true;
                     mOpenNodeButtons.add(_loc3_.Id,_loc12_);
                  }
               }
               else
               {
                  Logger.warn("Badly named map node in worldmap: " + _loc10_.name + " for node: " + _loc3_);
               }
            }
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
         return _loc2_;
      }
      
      function setupMapNodeButtons() 
      {
         mOpenNodeButtons = new Map();
         mLockedNodeButtons = new Map();
         initializeAllMapNodes();
         initializeOpenMapNodes();
         createNodeButtonsForLeague(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.rookie_league, flash.display.MovieClip));
         createNodeButtonsForLeague(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.gladiator_league, flash.display.MovieClip));
         createNodeButtonsForLeague(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.grinder_league, flash.display.MovieClip));
         createNodeButtonsForLeague(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.heroic_league, flash.display.MovieClip));
         mInfiniteIslandUnlocked = createNodeButtonsForLeague(ASCompat.dynamicAs((mRootMovieClip : ASAny).worldmap.infinite_island_league, flash.display.MovieClip));
         setCurrentNode(mCurrentNode);
      }
      
      function startFriendFader() 
      {
         if(mFriendFadeTask == null)
         {
            mFriendFadeTask = mWorkComponent.doEveryFrame(hideFriendsOnHover);
         }
      }
      
      function stopFriendFader() 
      {
         var _loc1_:ASAny;
         var __ax4_iter_172:Array<ASAny>;
         if(mFriendFadeTask != null)
         {
            mFriendFadeTask.destroy();
            mFriendFadeTask = null;
            if(mAvatarList != null)
            {
               __ax4_iter_172 = mAvatarList;
               if (checkNullIteratee(__ax4_iter_172)) for (_tmp_ in __ax4_iter_172)
               {
                  _loc1_ = _tmp_;
                  ASCompat.setProperty(_loc1_, "alpha", 1);
                  ASCompat.setProperty((cast(_loc1_, MovieClip) : ASAny).join, "alpha", 1);
               }
            }
         }
      }
      
      function hideFriendsOnHover(param1:GameClock) 
      {
         var _loc4_:ASAny;
         var __ax4_iter_173:Array<ASAny>;
         var _loc2_= Math.NaN;
         var _loc3_= Math.NaN;
         if(mAvatarList != null)
         {
            __ax4_iter_173 = mAvatarList;
            if (checkNullIteratee(__ax4_iter_173)) for (_tmp_ in __ax4_iter_173)
            {
               _loc4_ = _tmp_;
               _loc2_ = Math.abs(ASCompat.toNumber(ASCompat.toNumberField(_loc4_, "x") - ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "mouseX")));
               _loc3_ = Math.abs(ASCompat.toNumber(ASCompat.toNumberField(_loc4_, "y") - ASCompat.toNumberField((mRootMovieClip : ASAny).worldmap, "mouseY")));
               if(_loc2_ < 60 && _loc3_ < 60)
               {
                  _loc2_ /= 60;
                  _loc3_ /= 60;
                  ASCompat.setProperty(_loc4_, "alpha", Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_));
               }
               else
               {
                  ASCompat.setProperty(_loc4_, "alpha", 1);
               }
               ASCompat.setProperty((cast(_loc4_, MovieClip) : ASAny).join, "alpha", 1 / Math.max(0.01,ASCompat.toNumberField(_loc4_, "alpha")));
            }
         }
      }
      
      function clipFromNodeId(param1:UInt) : MovieClip
      {
         var _loc2_= ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeById.itemFor(param1), gameMasterDictionary.GMMapNode);
         if(_loc2_ != null)
         {
            return getClipFromConstant(_loc2_.Constant);
         }
         return null;
      }
      
      function checkTransition() 
      {
         if(mUnlockResponseReceived && mDidKeySpentMessage)
         {
            if(mUnlockSuccessful)
            {
               mDBFacade.mouseCursorManager.popMouseCursor();
               mDBFacade.mouseCursorManager.disable = true;
               mDBFacade.mainStateMachine.enterLoadingScreenState(mCurrentNode.Id,mCurrentNode.NodeType,(0 : UInt),(0 : UInt),true,mBattlePopup.IsPrivate);
            }
            else
            {
               mBattlePopup.battleButton.enabled = true;
               mUnlockResponseReceived = false;
               mUnlockSuccessful = false;
               mDidKeySpentMessage = false;
            }
         }
      }
      
      function unlockMapNodeSuccessCallback(param1:ASAny) 
      {
         mUnlockResponseReceived = true;
         mUnlockSuccessful = true;
         checkTransition();
      }
      
      function unlockMapNodeFailCallback(param1:Error) 
      {
         mUnlockResponseReceived = true;
         mUnlockSuccessful = false;
         Logger.error(Std.string(param1));
         checkTransition();
      }
      
      function unlockMapNode() 
      {
         var node:MovieClip;
         var popup:DBUIOneButtonPopup;
         var spentKeyClass:Dynamic;
         var keyCostClip:MovieClip;
         var global_position:Point;
         var floatingMessage:FloatingMessage;
         var unlockMapNodeRPC:ASFunction;
         if(mSpentKeyMessage != null)
         {
            return;
         }
         node = getClipFromConstant(mCurrentNode.Constant);
         if(node == null)
         {
            Logger.error("Attempting to unlock invalid dungeon");
            return;
         }
         if(mCurrentNode.TrophyRequirement > mDBFacade.dbAccountInfo.trophies)
         {
            mDBFacade.metrics.log("NotEnoughTrophiesWarning");
            popup = new DBUIOneButtonPopup(mDBFacade,"STOP IT!","NO! NOT ENOUGH TROPHIES!","OK",null);
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in UIMapWorldMap.unlockMapNode()");
            return;
         }
         spentKeyClass = mTownSwfAsset.getClass("Branch_map_spent_key");
         mSpentKeyMessage = ASCompat.dynamicAs(ASCompat.createInstance(spentKeyClass, []) , MovieClip);
         keyCostClip = mBattlePopup.keyCostClip;
         global_position = keyCostClip.localToGlobal(new Point(keyCostClip.x,keyCostClip.y));
         mSpentKeyMessage.x = mBattlePopup.battleButton.root.x;
         mSpentKeyMessage.y = mBattlePopup.battleButton.root.y - 40;
         if(mCurrentNode.BasicKeys > mCurrentNode.PremiumKeys)
         {
            ASCompat.setProperty((mSpentKeyMessage : ASAny).keyamount, "text", Std.string(mCurrentNode.BasicKeys));
         }
         else
         {
            ASCompat.setProperty((mSpentKeyMessage : ASAny).keyamount, "text", Std.string(mCurrentNode.PremiumKeys));
         }
         mBattlePopup.battleButton.enabled = false;
         mWorkComponent.doLater(1,function(param1:GameClock)
         {
            mBattlePopup.animatePopupOut(true);
         });
         mDBFacade.sceneGraphManager.addChild(mSpentKeyMessage,105);
         floatingMessage = new FloatingMessage(mSpentKeyMessage,mDBFacade,(12 : UInt),(64 : UInt),10,60,null,function()
         {
            mDBFacade.sceneGraphManager.removeChild(mSpentKeyMessage);
            mDidKeySpentMessage = true;
            checkTransition();
         });
         unlockMapNodeRPC = JSONRPCService.getFunction("UnlockMapNode",mDBFacade.rpcRoot + "worldmap");
         unlockMapNodeSuccessCallback(null);
      }
      
      function moveAvatarToNode(param1:GMMapNode, param2:Bool = false, param3:Bool = false) : ASFunction
      {
         var gmMapNode= param1;
         var force= param2;
         var returningToNodeFromAnotherScreen= param3;
         return function()
         {
            setCurrentNode(gmMapNode);
            if(mapNodeOpen(gmMapNode,false) || mapNodesOpen(gmMapNode.ParentNodes,true))
            {
               mBattlePopup.animatePopupIn();
               return;
            }
            mBattlePopup.animatePopupOut();
         };
      }
      
      function setCurrentNode(param1:GMMapNode) 
      {
         mCurrentNode = param1;
         if(mCurrentNode != null)
         {
            if(mCurrentNode.IsInfiniteDungeon)
            {
               mBattlePopup = mIIBattlePopup;
            }
            else
            {
               mBattlePopup = mRegularBattlePopup;
            }
            mBattlePopup.currentDungeon = mCurrentNode;
            mBattlePopup.mapNodeOpen = mapNodeOpen(mCurrentNode);
            mBattlePopup.setDungeonDetails();
         }
      }
      
      public function battleButtonCallback() 
      {
         var _loc2_:DBUIOneButtonPopup = null;
         var _loc1_:DBUIOneButtonPopup = null;
         if(mCurrentNode.LevelRequirement <= mDBFacade.dbAccountInfo.activeAvatarInfo.level)
         {
            if(mCurrentNode.TrophyRequirement > mDBFacade.dbAccountInfo.trophies)
            {
               mDBFacade.metrics.log("NotEnoughTrophiesWarning");
               _loc2_ = new DBUIOneButtonPopup(mDBFacade,"STOP IT!","NO! NOT ENOUGH TROPHIES!","OK",null);
               MemoryTracker.track(_loc2_,"DBUIOneButtonPopup - created in UIMapWorldMap.battleButtonCallback()");
               return;
            }
            if(mapNodeOpen(mCurrentNode))
            {
               mDBFacade.mouseCursorManager.popMouseCursor();
               mDBFacade.mouseCursorManager.disable = true;
               mDBFacade.mainStateMachine.enterLoadingScreenState(mCurrentNode.Id,mCurrentNode.NodeType,(0 : UInt),(0 : UInt),true,mBattlePopup.IsPrivate);
            }
            else
            {
               unlockMapNode();
            }
         }
         else
         {
            _loc1_ = new DBUIOneButtonPopup(mDBFacade,"STOP IT!","NO! NOT HIGH ENOUGH LEVEL!","OK",null);
            MemoryTracker.track(_loc1_,"DBUIOneButtonPopup - created in UIMapWorldMap.battleButtonCallback()");
         }
      }
      
      public function showFloatingMessage(param1:Float, param2:Float, param3:String) 
      {
         var floatingMessage:FloatingMessage;
         var xPos= param1;
         var yPos= param2;
         var message= param3;
         var messageClass= mTownSwfAsset.getClass("floating_text");
         var messageClip= ASCompat.dynamicAs(ASCompat.createInstance(messageClass, []) , MovieClip);
         mRootMovieClip.addChild(messageClip);
         messageClip.x = xPos;
         messageClip.y = yPos;
         messageClip.mouseChildren = false;
         messageClip.mouseEnabled = false;
         messageClip.alpha = 0;
         ASCompat.setProperty((messageClip : ASAny).label, "text", message);
         floatingMessage = new FloatingMessage(messageClip,mDBFacade,(25 : UInt),(100 : UInt),20,30,null,function()
         {
            mRootMovieClip.removeChild(messageClip);
         });
      }
      
      function showChooseDungeonMessage(param1:GameClock) 
      {
         var clock= param1;
         var messageClass= mTownSwfAsset.getClass("Branch_choose_dungeon");
         var messageClip= ASCompat.dynamicAs(ASCompat.createInstance(messageClass, []) , MovieClip);
         mRootMovieClip.addChild(messageClip);
         messageClip.x = messageClip.stage.stageWidth / 2;
         messageClip.y = messageClip.stage.stageHeight * 0.4;
         messageClip.scaleX = messageClip.scaleY = 1.5;
         messageClip.mouseChildren = false;
         messageClip.mouseEnabled = false;
         messageClip.alpha = 0;
         mRevealer = new Revealer(messageClip,mDBFacade,(32 : UInt),function()
         {
            mChooseDungeonMessage = new FloatingMessage(messageClip,mDBFacade,(32 : UInt),(32 : UInt),1.35,0,null,function()
            {
               mChooseDungeonMessage = null;
               mRootMovieClip.removeChild(messageClip);
            });
         },(1 : UInt));
      }
      
      @:isVar public var returnToMapNode(never,set):GMMapNode;
public function  set_returnToMapNode(param1:GMMapNode) :GMMapNode      {
         return mReturnToMapNode = param1;
      }
      
      function buildPathFromSearchNode(param1:SearchNode) 
      {
         mNodePath = [];
         mNodePath.push(param1.Node);
         while(param1.Parent != null)
         {
            param1 = param1.Parent;
            if(param1.Parent != null)
            {
               mNodePath.push(param1.Node);
            }
         }
      }
      
      function findPathToNode(param1:GMMapNode) 
      {
         var _loc2_:SearchNode = null;
         if(param1 == null || mCurrentNode == null || param1 == mCurrentNode)
         {
            return;
         }
         mNodeQueue = [];
         mClosedNodeList = new Set();
         var _loc3_= new SearchNode(mCurrentNode,null);
         mNodeQueue.push(_loc3_);
         while(mNodeQueue.length != 0)
         {
            _loc2_ = ASCompat.dynamicAs(mNodeQueue.shift(), SearchNode);
            mClosedNodeList.add(_loc2_.Node);
            if(_loc2_.Node == param1)
            {
               buildPathFromSearchNode(_loc2_);
               return;
            }
            addChildrenToQueue(_loc2_);
         }
         Logger.error("Can\'t find path to selected map node.");
      }
      
      function addChildrenToQueue(param1:SearchNode) 
      {
         var _loc2_= 0;
         var _loc3_:GMMapNode = null;
         _loc2_ = 0;
         while(_loc2_ < param1.Node.ChildNodes.length)
         {
            _loc3_ = ASCompat.dynamicAs(param1.Node.ChildNodes[_loc2_], gameMasterDictionary.GMMapNode);
            if(_loc3_ != null && !mClosedNodeList.has(_loc3_))
            {
               mNodeQueue.push(new SearchNode(_loc3_,param1));
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      function setUpHacksToPlayNode() 
      {
         mDBFacade.stageRef.addEventListener("keyDown",hackToHandleKeyPressToPlayNode);
      }
      
      function tearDownHacksToPlayNode() 
      {
         mDBFacade.stageRef.removeEventListener("keyDown",hackToHandleKeyPressToPlayNode);
      }
      
      function hackToHandleKeyPressToPlayNode(param1:KeyboardEvent) 
      {
         switch(param1.keyCode - 69)
         {
            case 0:
               hackToPlayNode((50153 : UInt));
               
            case 12:
               hackToPlayNode((50150 : UInt));
               
            case 13:
               hackToPlayNode((50200 : UInt));
               
            case 18:
               hackToPlayNode((50151 : UInt));
         }
      }
      
      function hackToPlayNode(param1:UInt) 
      {
         mDBFacade.mainStateMachine.enterLoadingScreenState(param1,"",(0 : UInt),(0 : UInt),true,false);
      }
   }


private class SearchNode
{
   
   public var Node:GMMapNode;
   
   public var Parent:SearchNode;
   
   public function new(param1:GMMapNode, param2:SearchNode)
   {
      
      Node = param1;
      Parent = param2;
   }
}
