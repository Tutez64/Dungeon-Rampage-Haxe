package uI.hud
;
   import account.BoosterInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.clock.GameClock;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIObject;
   import brain.workLoop.LogicalWorkComponent;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import uI.*;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
    class UIStacksHud
   {
      
      static inline final STACK_TOOLTIP_DELAY:Float = 0.5;
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mStacksUI:Vector<UIObject>;
      
      var mStackTimersUI:Vector<CountdownTextTimer>;
      
      var mTooltipAPos:Point;
      
      var mTooltipBPos:Point;
      
      var mTooltipCPos:Point;
      
      var mUIRootClass:Dynamic;
      
      var mUIRoot:MovieClip;
      
      var mBoosterTimeOutTimer:Timer;
      
      var mFirstTime:Bool = true;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIStacksHud");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"UIStacksHud");
      }
      
      public function initializeHud(param1:Dynamic) 
      {
         mUIRootClass = param1;
         mUIRoot = ASCompat.dynamicAs(ASCompat.createInstance(mUIRootClass, []), flash.display.MovieClip);
         mUIRoot.x = 480;
         mUIRoot.y = 55;
         mTooltipAPos = new Point(ASCompat.toNumberField((mUIRoot : ASAny).potion_slot_A.tooltip, "x"),ASCompat.toNumberField((mUIRoot : ASAny).potion_slot_A.tooltip, "y"));
         mTooltipBPos = new Point(ASCompat.toNumberField((mUIRoot : ASAny).potion_slot_B.tooltip, "x"),ASCompat.toNumberField((mUIRoot : ASAny).potion_slot_B.tooltip, "y"));
         mTooltipCPos = new Point(ASCompat.toNumberField((mUIRoot : ASAny).potion_slot_C.tooltip, "x"),ASCompat.toNumberField((mUIRoot : ASAny).potion_slot_C.tooltip, "y"));
      }
      
      public function setupStacksUI() 
      {
         var _loc1_:ASAny = null;
         var _loc2_:ASAny = null;
         checkBoosters();
      }
      
      function createStacks() 
      {
         var _loc1_:UIObject = null;
         mStacksUI = Vector.ofArray([new UIObject(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).potion_slot_A, flash.display.MovieClip)),new UIObject(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).potion_slot_B, flash.display.MovieClip)),new UIObject(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).potion_slot_C, flash.display.MovieClip))]);
         mStackTimersUI = Vector.ofArray(([null,null,null] : Array<CountdownTextTimer>));
         final __ax4_iter_84 = mStacksUI;
         if (checkNullIteratee(__ax4_iter_84)) for (_tmp_ in __ax4_iter_84)
         {
            _loc1_  = _tmp_;
            ASCompat.setProperty(_loc1_, "enabled", false);
            ASCompat.setProperty(_loc1_, "dontKillMyChildren", true);
         }
      }
      
      function checkBoosters() 
      {
         var _loc2_:BoosterInfo = null;
         var _loc3_:BoosterInfo = null;
         removeStacks();
         resetTooltipPos();
         createStacks();
         if(mDBFacade.dbAccountInfo != null && 0 != 0)
         {
            _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterXP();
            if(_loc2_ != null)
            {
               setupBooster(_loc2_,(0 : UInt));
            }
            _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterGold();
            if(_loc3_ != null)
            {
               setupBooster(_loc3_,(1 : UInt));
            }
         }
         if(mBoosterTimeOutTimer != null)
         {
            mBoosterTimeOutTimer.stop();
            mBoosterTimeOutTimer = null;
         }
         var _loc1_= mDBFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
      }
      
      function handleBoosterTimeUp(param1:TimerEvent) 
      {
         checkBoosters();
      }
      
      function setupBooster(param1:BoosterInfo, param2:UInt) 
      {
         var xpStack:UIObject;
         var boosterInfo= param1;
         var slot= param2;
         if(boosterInfo != null)
         {
            xpStack = mStacksUI[(slot : Int)];
            xpStack.enabled = true;
            xpStack.tooltipDelay = 0.5;
            ASCompat.setProperty((xpStack.tooltip : ASAny).title_label, "text", GameMasterLocale.getGameMasterSubString("STACKABLE_NAME",boosterInfo.StackInfo.Constant).toUpperCase());
            ASCompat.setProperty((xpStack.tooltip : ASAny).description_label, "text", Locale.getString("TIME_REMAINING") + boosterInfo.getDisplayTimeLeft());
            mStackTimersUI[(slot : Int)] = new CountdownTextTimer(ASCompat.dynamicAs((xpStack.tooltip : ASAny).description_label, flash.text.TextField),boosterInfo.getEndDate(),GameClock.getWebServerDate,checkBoosters,Locale.getString("BOOSTER_REMAINING"),"",Locale.getString("EXPIRED"));
            mStackTimersUI[(slot : Int)].start();
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(boosterInfo.StackInfo.UISwfFilepath),function(param1:brain.assetRepository.SwfAsset)
            {
               var _loc2_= param1.getClass(boosterInfo.StackInfo.IconName);
               if(_loc2_ == null)
               {
                  return;
               }
               var _loc3_= ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
               _loc3_.scaleX = _loc3_.scaleY = 80 / 100;
               (mStacksUI[(slot : Int)].root : ASAny).graphic.addChildAt(_loc3_,0);
            });
         }
      }
      
      public function hide() 
      {
         if(mUIRoot != null)
         {
            mSceneGraphComponent.removeChild(mUIRoot);
         }
      }
      
      public function show() 
      {
         if(mUIRoot != null)
         {
            mSceneGraphComponent.addChild(mUIRoot,(105 : UInt));
         }
      }
      
      function resetTooltipPos() 
      {
         ASCompat.setProperty((mUIRoot : ASAny).potion_slot_A.tooltip, "x", mTooltipAPos.x);
         ASCompat.setProperty((mUIRoot : ASAny).potion_slot_A.tooltip, "y", mTooltipAPos.y);
         ASCompat.setProperty((mUIRoot : ASAny).potion_slot_B.tooltip, "x", mTooltipBPos.x);
         ASCompat.setProperty((mUIRoot : ASAny).potion_slot_B.tooltip, "y", mTooltipBPos.y);
         ASCompat.setProperty((mUIRoot : ASAny).potion_slot_C.tooltip, "x", mTooltipCPos.x);
         ASCompat.setProperty((mUIRoot : ASAny).potion_slot_C.tooltip, "y", mTooltipCPos.y);
      }
      
      function removeStacks() 
      {
         var __ax4_iter_85:Vector<UIObject>;
         var __ax4_iter_86:Vector<CountdownTextTimer>;
         var _loc2_:UIObject = null;
         var _loc1_:CountdownTextTimer = null;
         if(mStacksUI != null)
         {
            __ax4_iter_85 = mStacksUI;
            if (checkNullIteratee(__ax4_iter_85)) for (_tmp_ in __ax4_iter_85)
            {
               _loc2_  = _tmp_;
               if(ASCompat.toNumberField((_loc2_.root : ASAny).graphic, "numChildren") > 0)
               {
                  (_loc2_.root : ASAny).graphic.removeChildAt(0);
               }
               _loc2_.destroy();
            }
            mStacksUI = null;
         }
         if(mStackTimersUI != null)
         {
            __ax4_iter_86 = mStackTimersUI;
            if (checkNullIteratee(__ax4_iter_86)) for (_tmp_ in __ax4_iter_86)
            {
               _loc1_  = _tmp_;
               if(_loc1_ != null)
               {
                  _loc1_.destroy();
               }
            }
            mStackTimersUI = null;
         }
      }
      
      public function destroy() 
      {
         hide();
         removeStacks();
         mUIRoot = null;
         if(mWorkComponent != null)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mDBFacade = null;
      }
   }


