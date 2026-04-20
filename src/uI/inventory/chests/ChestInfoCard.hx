package uI.inventory.chests
;
   import account.AvatarInfo;
   import account.ChestInfo;
   import account.InventoryBaseInfo;
   import account.KeyInfo;
   import account.StoreServices;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.render.MovieClipRenderer;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMSkin;
   import uI.hud.UIHud;
   import uI.popup.DBUIPopup;
   import flash.display.MovieClip;
   
    class ChestInfoCard extends UIObject
   {
      
      public static inline final UNLOCK_CHEST_COIN_EVENT= "ChestUnlockCoin";
      
      public static inline final UNLOCK_CHEST_COIN_TRY_EVENT= "ChestUnlockCoinTry";
      
      public static inline final UNLOCK_CHEST_GEM_EVENT= "ChestUnlockGem";
      
      public static inline final UNLOCK_CHEST_GEM_TRY_EVENT= "ChestUnlockGemTry";
      
      public static inline final UNLOCK_CHEST_KEY_EVENT= "ChestUnlockKey";
      
      public static inline final KEEP_CHEST_EVENT= "ChestKept";
      
      public static inline final ABANDON_CHEST= "ChestAbandoned";
      
      var mDBFacade:DBFacade;
      
      var mChestInfo:ChestInfo;
      
      var mChestCardMC:MovieClip;
      
      var mChestRenderer:MovieClipRenderer;
      
      var mChestIconHolder:MovieClip;
      
      var mChestIconUnequippable:MovieClip;
      
      var mChestKeysMC:MovieClip;
      
      var mChestKeySlots:Vector<ChestKeySlot>;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mChestRevealPopUp:ChestRevealPopUp;
      
      var mChestCanBeOpened:Bool = false;
      
      var mChestBuyKeysPopUp:ChestBuyKeysPopUp;
      
      var mKeyThatCanOpenChest:KeyInfo;
      
      var mPurchasingPopUp:DBUIPopup;
      
      var mChestCardAbandonButton:UIButton;
      
      var mChestCardOpenButton:UIButton;
      
      var mChestCardOpenButtonDS:UIButton;
      
      var mChestCardKeepButtonDS:UIButton;
      
      var mChestCardAbandonButtonDS:UIButton;
      
      var mAbandonChestCallback:ASFunction;
      
      var mOpenChestCallback:ASFunction;
      
      var mAbandonChestCallbackDS:ASFunction;
      
      var mOpenChestCallbackDS:ASFunction;
      
      var mKeepChestCallbackDS:ASFunction;
      
      var mDontUpdateChestInfo:Bool = false;
      
      public var selectedHeroId:UInt = 0;
      
      public function new(param1:DBFacade, param2:SceneGraphComponent, param3:MovieClip, param4:ASFunction, param5:ASFunction, param6:ASFunction, param7:ASFunction, param8:ASFunction)
      {
         super(param1,param3);
         mDBFacade = param1;
         mSceneGraphComponent = param2;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"ChestInfoCard");
         mOpenChestCallback = param5;
         mAbandonChestCallback = param4;
         mOpenChestCallbackDS = param7;
         mAbandonChestCallbackDS = param6;
         mKeepChestCallbackDS = param8;
         setupChestCardUI();
         setupKeyCardUI();
         hide();
      }
      
      function setupChestCardUI() 
      {
         mChestCardMC = ASCompat.dynamicAs((root : ASAny).chest_card, flash.display.MovieClip);
         ASCompat.setProperty((mChestCardMC : ASAny).selection_01, "visible", true);
         ASCompat.setProperty((mChestCardMC : ASAny).selection_02, "visible", false);
         mChestCardAbandonButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mChestCardMC : ASAny).selection_01.abandon, flash.display.MovieClip));
         mChestCardAbandonButton.label.text = Locale.getString("ABANDON");
         mChestCardAbandonButton.releaseCallback = function()
         {
            mAbandonChestCallback(mChestInfo);
         };
         mChestCardOpenButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mChestCardMC : ASAny).selection_01.open, flash.display.MovieClip));
         mChestCardOpenButton.label.text = Locale.getString("UNLOCK");
         mChestCardOpenButton.releaseCallback = function()
         {
            mOpenChestCallback(mChestInfo);
         };
         mChestCardAbandonButtonDS = new UIButton(mDBFacade,ASCompat.dynamicAs((mChestCardMC : ASAny).selection_02.abandon, flash.display.MovieClip));
         mChestCardAbandonButtonDS.label.text = Locale.getString("ABANDON");
         mChestCardAbandonButtonDS.releaseCallback = function()
         {
            mAbandonChestCallbackDS(mChestInfo);
         };
         mChestCardOpenButtonDS = new UIButton(mDBFacade,ASCompat.dynamicAs((mChestCardMC : ASAny).selection_02.open, flash.display.MovieClip));
         mChestCardOpenButtonDS.label.text = Locale.getString("UNLOCK");
         mChestCardOpenButtonDS.releaseCallback = function()
         {
            mOpenChestCallbackDS(mChestInfo);
         };
         mChestCardKeepButtonDS = new UIButton(mDBFacade,ASCompat.dynamicAs((mChestCardMC : ASAny).selection_02.keep, flash.display.MovieClip));
         mChestCardKeepButtonDS.label.text = Locale.getString("KEEP");
         mChestCardKeepButtonDS.releaseCallback = function()
         {
            mKeepChestCallbackDS(mChestInfo);
         };
         mChestIconHolder = ASCompat.dynamicAs((mChestCardMC : ASAny).item_icon, flash.display.MovieClip);
         mChestIconUnequippable = ASCompat.dynamicAs((mChestCardMC : ASAny).unequippable, flash.display.MovieClip);
         mChestIconUnequippable.visible = false;
      }
      
      function setupKeyCardUI() 
      {
         if(ASCompat.toBool((root : ASAny).chest_card_keys))
         {
            mChestKeysMC = ASCompat.dynamicAs((root : ASAny).chest_card_keys, flash.display.MovieClip);
            ASCompat.setProperty((mChestKeysMC : ASAny).label, "text", Locale.getString("KEYS_OWNED"));
            mChestKeySlots = new Vector<ChestKeySlot>();
         }
      }
      
      public function hide() 
      {
         this.visible = false;
      }
      
      public function show() 
      {
         this.visible = true;
      }
      
      @:isVar public var info(never,set):InventoryBaseInfo;
public function  set_info(param1:InventoryBaseInfo) :InventoryBaseInfo      {
         if(mDontUpdateChestInfo)
         {
            return param1;
         }
         mChestInfo = ASCompat.reinterpretAs(param1 , ChestInfo);
         if(mChestInfo == null)
         {
            hide();
         }
         else
         {
            show();
            refreshChestInfoUI();
            refreshKeyInfoUI();
            if(!UIHud.isThisAConsumbleChestId((mChestInfo.gmId : Int)))
            {
               refreshHeroInfoUI();
            }
         }
return param1;
      }
      
      public function refreshChestInfoUI() 
      {
         loadIcon();
         ASCompat.setProperty((mChestCardMC : ASAny).label, "text", GameMasterLocale.getGameMasterSubString("CHEST_NAME",mChestInfo.gmChestInfo.Rarity));
         if(mChestInfo.isFromDungeonSummary())
         {
            ASCompat.setProperty((mChestCardMC : ASAny).selection_01, "visible", false);
            ASCompat.setProperty((mChestCardMC : ASAny).selection_02, "visible", true);
         }
         else
         {
            ASCompat.setProperty((mChestCardMC : ASAny).selection_01, "visible", true);
            ASCompat.setProperty((mChestCardMC : ASAny).selection_02, "visible", false);
         }
      }
      
      public function refreshKeyInfoUI() 
      {
         var _loc2_= 0;
         var _loc3_= 0;
         var _loc1_:MovieClip = null;
         mChestCanBeOpened = false;
         if(mChestKeySlots != null)
         {
            _loc2_ = 0;
            while(_loc2_ < mChestKeySlots.length)
            {
               mChestKeySlots[_loc2_].destroy();
               _loc2_++;
            }
            mChestKeySlots.splice(0,(mChestKeySlots.length : UInt));
         }
         _loc3_ = 0;
         while(_loc3_ < 6)
         {
            if(mChestKeySlots != null)
            {
               _loc1_ = ASCompat.reinterpretAs(mChestKeysMC.getChildByName("slot_" + Std.string(_loc3_)) , MovieClip);
               if(_loc1_ != null)
               {
                  mChestKeySlots.push(new ChestKeySlot(mDBFacade,_loc1_,mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_],mAssetLoadingComponent));
               }
            }
            if(mChestInfo.gmChestInfo.Id == mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_].gmKey.ChestId)
            {
               mKeyThatCanOpenChest = mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_];
               if(_loc1_ != null)
               {
                  mChestKeySlots[_loc3_].setSelected(true);
                  if(mChestKeySlots[_loc3_].keyInfo.count > 0)
                  {
                     mChestCanBeOpened = true;
                  }
                  mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mKeyThatCanOpenChest.gmKeyOffer.BundleSwfFilepath),loadKeyIconOnButton);
               }
            }
            else if(_loc1_ != null)
            {
               mChestKeySlots[_loc3_].setSelected(false);
            }
            _loc3_++;
         }
      }
      
      public function refreshHeroInfoUI(param1:MovieClip = null) 
      {
         var mSelectedHero:GMHero;
         var mHeroInfo:AvatarInfo;
         var gmSkin:GMSkin;
         var mc= param1;
         if(mc == null)
         {
            mc = mChestCardMC;
         }
         ASCompat.setProperty((mc : ASAny).hero_label, "text", Locale.getString("OPENING_WITH"));
         mSelectedHero = mDBFacade.gameMaster.Heroes[(selectedHeroId : Int)];
         mHeroInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id);
         if(mHeroInfo == null)
         {
            hide();
            return;
         }
         gmSkin = mDBFacade.gameMaster.getSkinByType(mHeroInfo.skinId);
         if(gmSkin == null)
         {
            Logger.error("Unable to find gmSkin for ID: " + mHeroInfo.skinId);
         }
         else
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.IconSwfFilepath),function(param1:SwfAsset)
            {
               var _loc3_= param1.getClass(gmSkin.IconName);
               if(_loc3_ == null)
               {
                  return;
               }
               var _loc4_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
               var _loc2_= new MovieClipRenderController(mDBFacade,_loc4_);
               _loc2_.play();
               if(ASCompat.toNumberField((mc : ASAny).avatar, "numChildren") > 0)
               {
                  (mc : ASAny).avatar.removeChildAt(0);
               }
               (mc : ASAny).avatar.addChildAt(_loc4_,0);
               _loc4_.scaleX = _loc4_.scaleY = 1;
            });
         }
      }
      
      function loadKeyIconOnButton(param1:SwfAsset) 
      {
         var _loc3_= param1.getClass(mKeyThatCanOpenChest.gmKeyOffer.BundleIcon);
         var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []) , MovieClip);
         _loc2_.scaleX = _loc2_.scaleY = 0.5;
         if(!mChestInfo.isFromDungeonSummary())
         {
            if(ASCompat.toNumberField((mChestCardOpenButton.root : ASAny).pick, "numChildren") > 0)
            {
               (mChestCardOpenButton.root : ASAny).pick.removeChildAt(0);
            }
            (mChestCardOpenButton.root : ASAny).pick.addChild(_loc2_);
         }
         else
         {
            if(ASCompat.toNumberField((mChestCardOpenButtonDS.root : ASAny).pick, "numChildren") > 0)
            {
               (mChestCardOpenButtonDS.root : ASAny).pick.removeChildAt(0);
            }
            (mChestCardOpenButtonDS.root : ASAny).pick.addChild(_loc2_);
         }
      }
      
      public function canChestBeOpened() : Bool
      {
         return mChestCanBeOpened;
      }
      
      public function loadIcon() 
      {
         var bgColoredExists:Bool;
         var bgSwfPath:String;
         var bgIconName:String;
         var swfPath= mChestInfo.gmChestInfo.IconSwf;
         var iconName= mChestInfo.gmChestInfo.IconName;
         while(mChestIconHolder.numChildren > 1)
         {
            mChestIconHolder.removeChildAt(1);
         }
         ChestInfo.loadItemIcon(swfPath,iconName,mChestIconHolder,mDBFacade,(70 : UInt),(Std.int(mChestInfo.iconScale) : UInt),mAssetLoadingComponent);
         mChestRenderer = new MovieClipRenderer(mDBFacade,mChestIconHolder);
         mChestRenderer.play((0 : UInt),true);
         bgColoredExists = mChestInfo.hasColoredBackground;
         bgSwfPath = mChestInfo.backgroundSwfPath;
         bgIconName = mChestInfo.backgroundIconName;
         if(bgColoredExists)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset)
            {
               var _loc3_:MovieClip = null;
               var _loc2_= param1.getClass(bgIconName);
               if(_loc2_ != null)
               {
                  _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
                  mChestIconHolder.addChildAt(_loc3_,1);
               }
            });
         }
      }
      
      public function createRevealPopUp(param1:ASFunction, param2:ASFunction) 
      {
         mSceneGraphComponent.fadeOut(0.5,0.75);
         mChestRevealPopUp = new ChestRevealPopUp(mDBFacade,mChestInfo.gmChestInfo,param1,param2);
      }
      
      public function closeChestRevealPopUp() 
      {
         if(mChestRevealPopUp != null)
         {
            mDontUpdateChestInfo = false;
            mSceneGraphComponent.fadeIn(0.5);
            mChestRevealPopUp.destroy();
            mChestRevealPopUp = null;
         }
      }
      
      public function updateRevealLoot(param1:ASAny) 
      {
         if(mChestRevealPopUp != null)
         {
            mChestRevealPopUp.updateRevealLoot(param1);
         }
      }
      
      public function showBuyKeysPopUp(param1:SwfAsset) 
      {
         mSceneGraphComponent.fadeOut(0.5,0.75);
         mChestBuyKeysPopUp = new ChestBuyKeysPopUp(mDBFacade,mAssetLoadingComponent,mSceneGraphComponent,param1,mChestInfo.gmChestInfo,chestBuyCoinCallback,chestBuyGemCallback,closeBuyKeysPopUp,refreshHeroInfoUI);
      }
      
      function chestBuyCoinCallback(param1:Float) : ASFunction
      {
         var val= param1;
         return function()
         {
            var _loc1_= 0;
            mDBFacade.metrics.log("ChestUnlockCoinTry",{
               "chestId":mChestInfo.gmId,
               "rarity":mChestInfo.rarity,
               "category":"storage"
            });
            if(mDBFacade.dbAccountInfo.basicCurrency >= val)
            {
               mDBFacade.metrics.log("ChestUnlockCoin",{
                  "chestId":mChestInfo.gmId,
                  "rarity":mChestInfo.rarity,
                  "category":"storage"
               });
               closeBuyKeysPopUp();
               mPurchasingPopUp = new DBUIPopup(mDBFacade,Locale.getString("PURCHASING..."));
               MemoryTracker.track(mPurchasingPopUp,"DBUIPopup - created in ChestInfoCard.chestBuyCoinCallback()");
               mSceneGraphComponent.addChild(mPurchasingPopUp.root,(50 : UInt));
               _loc1_ = (mKeyThatCanOpenChest.gmKeyOffer.Id : Int);
               StoreServices.purchaseOffer(mDBFacade,(_loc1_ : UInt),boughtKey,boughtKeyError,(0 : UInt),false);
            }
            else
            {
               mDontUpdateChestInfo = true;
               StoreServicesController.showCoinPage(mDBFacade);
            }
         };
      }
      
      function chestBuyGemCallback(param1:Float) : ASFunction
      {
         var val= param1;
         return function()
         {
            var _loc1_= 0;
            mDBFacade.metrics.log("ChestUnlockGemTry",{
               "chestId":mChestInfo.gmId,
               "rarity":mChestInfo.rarity,
               "category":"storage"
            });
            if(mDBFacade.dbAccountInfo.premiumCurrency >= val)
            {
               mDBFacade.metrics.log("ChestUnlockGem",{
                  "chestId":mChestInfo.gmId,
                  "rarity":mChestInfo.rarity,
                  "category":"storage"
               });
               closeBuyKeysPopUp();
               mPurchasingPopUp = new DBUIPopup(mDBFacade,Locale.getString("PURCHASING..."));
               MemoryTracker.track(mPurchasingPopUp,"DBUIPopup - created in ChestInfoCard.chestBuyGemCallback()");
               mSceneGraphComponent.addChild(mPurchasingPopUp.root,(50 : UInt));
               _loc1_ = (mKeyThatCanOpenChest.gmKeyOffer.Id : Int);
               StoreServices.purchaseOffer(mDBFacade,(_loc1_ : UInt),boughtKey,boughtKeyError,(0 : UInt),false);
            }
            else
            {
               mDontUpdateChestInfo = true;
               StoreServicesController.showCashPage(mDBFacade,"chestOpenWithGemsAttemptStorage");
            }
         };
      }
      
      function boughtKey(param1:ASAny) 
      {
         mSceneGraphComponent.removeChild(mPurchasingPopUp.root);
         mPurchasingPopUp.destroy();
         mPurchasingPopUp = null;
         mChestCanBeOpened = true;
         mOpenChestCallback(mChestInfo);
      }
      
      function boughtKeyError(param1:ASAny) 
      {
         mPurchasingPopUp = new DBUIPopup(mDBFacade,Locale.getString("Error with Key Purchase. Server Error!"));
         MemoryTracker.track(mPurchasingPopUp,"DBUIPopup - created in ChestInfoCard.boughtKeyError()");
         mSceneGraphComponent.addChild(mPurchasingPopUp.root,(50 : UInt));
      }
      
      public function closeBuyKeysPopUp() 
      {
         mDontUpdateChestInfo = false;
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.fadeIn(0.5);
         }
         if(mChestBuyKeysPopUp != null)
         {
            mChestBuyKeysPopUp.destroy();
         }
         mChestBuyKeysPopUp = null;
      }
      
      override public function destroy() 
      {
         var _loc1_= 0;
         if(mChestRevealPopUp != null)
         {
            mChestRevealPopUp.destroy();
         }
         mChestRevealPopUp = null;
         if(mChestKeySlots != null)
         {
            _loc1_ = 0;
            while(_loc1_ < mChestKeySlots.length)
            {
               mChestKeySlots[_loc1_].destroy();
               _loc1_++;
            }
         }
         mChestKeySlots = null;
         if(mPurchasingPopUp != null)
         {
            mSceneGraphComponent.removeChild(mPurchasingPopUp.root);
            mPurchasingPopUp.destroy();
         }
         mPurchasingPopUp = null;
         if(mChestBuyKeysPopUp != null)
         {
            closeBuyKeysPopUp();
         }
         mKeyThatCanOpenChest = null;
         mOpenChestCallback = null;
         mAbandonChestCallback = null;
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         if(mChestRenderer != null)
         {
            mChestRenderer.destroy();
         }
         mChestRenderer = null;
         mDBFacade = null;
         mAssetLoadingComponent.destroy();
         if(mChestRevealPopUp != null)
         {
            mChestRevealPopUp.destroy();
         }
         mChestRevealPopUp = null;
         super.destroy();
      }
   }


