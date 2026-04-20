package account
;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMOfferDetail;
   import gameMasterDictionary.GMStackable;
   import gameMasterDictionary.GMWeaponItem;
   import uI.inventory.UIPurchaseOfferPopup;
   import uI.inventory.UISellItemPopup;
   import uI.popup.DBUIOneButtonPopup;
   import uI.popup.DBUIPopup;
   import uI.popup.DBUITwoButtonPopup;
   import uI.popup.UICashPage;
   import uI.popup.UICoinPage;
   import uI.popup.UIGiftPage;
   import uI.popup.UIOfferPopup;
   import uI.popup.UIStorageFullPopup;
   import org.as3commons.collections.Map;
   
    class StoreServicesController
   {
      
      public static inline final MAX_INVENTORY_SLOTS= (120 : UInt);
      
      public static inline final CONFIRM_PREMIUM_PURCHASES= false;
      
      public static inline final CONFIRM_BASIC_PURCHASES= false;
      
      public static inline final CONFIRM_ALREADY_OWN= true;
      
      public static final BASIC_KEY_OFFERS:Vector<UInt> = Vector.ofArray(([(51201 : UInt),(51203 : UInt),(51205 : UInt)] : Array<UInt>));
      
      public static final PREMIUM_KEY_OFFERS:Vector<UInt> = Vector.ofArray(([(51211 : UInt),(51212 : UInt),(51213 : UInt)] : Array<UInt>));
      
      public static final COIN_OFFERS:Vector<UInt> = Vector.ofArray(([(51102 : UInt),(51103 : UInt),(51104 : UInt)] : Array<UInt>));
      
      public static final STORAGE_OFFERS:Vector<UInt> = Vector.ofArray(([(51401 : UInt),(51402 : UInt),(51403 : UInt)] : Array<UInt>));
      
      public static final GIFT_OFFERS:Vector<UInt> = Vector.ofArray(([(51301 : UInt),(51399 : UInt),(51398 : UInt)] : Array<UInt>));
      
      public static final HERO_OFFERS:Vector<UInt> = Vector.ofArray(([(51012 : UInt),(51013 : UInt),(51014 : UInt),(51015 : UInt)] : Array<UInt>));
      
      public function new()
      {
         
      }
      
      public static function getOfferMetrics(param1:DBFacade, param2:GMOffer) : ASObject
      {
         var _loc3_:ASObject = {};
         ASCompat.setProperty(_loc3_, "offerId", param2.Id);
         ASCompat.setProperty(_loc3_, "offerName", param2.getDisplayName(param1.gameMaster,Locale.getString("SHOP_UNKNOWN_NAME")));
         ASCompat.setProperty(_loc3_, "price", param2.Price);
         ASCompat.setProperty(_loc3_, "currencyType", param2.CurrencyType);
         return _loc3_;
      }
      
      static function getSellMetrics(param1:DBFacade, param2:InventoryBaseInfo) : ASObject
      {
         var _loc3_:ASObject = {};
         ASCompat.setProperty(_loc3_, "itemId", param2.gmId);
         ASCompat.setProperty(_loc3_, "itemName", param2.Name.toUpperCase());
         ASCompat.setProperty(_loc3_, "price", param2.sellCoins);
         ASCompat.setProperty(_loc3_, "currencyType", "BASIC");
         return _loc3_;
      }
      
      public static function tryBuyOffer(param1:DBFacade, param2:GMOffer, param3:ASFunction, param4:UInt = (0 : UInt)) 
      {
         param1.metrics.log("ShopPurchaseTry",getOfferMetrics(param1,param2));
         if(StoreServicesController.stackableLimitWouldOverflow(param1,param2))
         {
            StoreServicesController.stackableLimitPopup(param1,param2);
         }
         else if(StoreServicesController.weaponInventoryWouldOverflow(param1,param2))
         {
            StoreServicesController.weaponInventoryFullPopup(param1,param2);
         }
         else if(StoreServicesController.weaponStorageWouldOverflow(param1,param2))
         {
            StoreServicesController.weaponStorageLimitPopup(param1,param2);
         }
         else if(alreadyOwns(param1,param2))
         {
            StoreServicesController.confirmAlreadyOwnsPopup(param1,param2,param3,param4);
         }
         else if(StoreServicesController.getOfferLevelReq(param1,param2) > param1.dbAccountInfo.highestAvatarLevel)
         {
            StoreServicesController.notHighEnoughLevelPopup(param1,param2);
         }
         else if(weaponRestrictedAndHeroNotOwned(param1,param2))
         {
            StoreServicesController.doesntOwnHeroPopup(param1,param2);
         }
         else if(param2.CurrencyType == "PREMIUM" && param1.dbAccountInfo.premiumCurrency < param2.Price)
         {
            StoreServicesController.showCashPage(param1,"tryBuyOffer",param2,param3,null,param4);
         }
         else if(param2.CurrencyType == "BASIC" && param1.dbAccountInfo.basicCurrency < param2.Price)
         {
            StoreServicesController.notEnoughCoinsPopup(param1,param2);
         }
         else if(false && param2.CurrencyType == "PREMIUM")
         {
            StoreServicesController.confirmPurchasePopup(param1,param2,param3,param4);
         }
         else if(false && param2.CurrencyType == "BASIC")
         {
            StoreServicesController.confirmPurchasePopup(param1,param2,param3,param4);
         }
         else
         {
            StoreServicesController.buyOffer(param1,param2,param3,param4);
         }
      }
      
      public static function trySellItem(param1:DBFacade, param2:InventoryBaseInfo, param3:ASFunction = null, param4:ASFunction = null) 
      {
         param1.metrics.log("TrySell",StoreServicesController.getSellMetrics(param1,param2));
         if(param2.isEquipped)
         {
            StoreServicesController.itemIsEquippedPopup(param1,param2,param3,param4);
         }
         else
         {
            StoreServicesController.confirmSell(param1,param2,param3,param4);
         }
      }
      
      public static function getOfferLevelReq(param1:DBFacade, param2:GMOffer) : UInt
      {
         if(param2.IsBundle)
         {
            return (0 : UInt);
         }
         var _loc3_= param2.Details[0];
         if(_loc3_.Level != 0)
         {
            return _loc3_.Level;
         }
         return (0 : UInt);
      }
      
      public static function getWeaponMastertype(param1:DBFacade, param2:GMOffer) : String
      {
         var _loc3_:GMWeaponItem = null;
         if(param2.IsBundle)
         {
            return null;
         }
         var _loc4_= param2.Details[0];
         if(_loc4_.WeaponId != 0)
         {
            _loc3_ = ASCompat.dynamicAs(param1.gameMaster.weaponItemById.itemFor(_loc4_.WeaponId), gameMasterDictionary.GMWeaponItem);
            return _loc3_.MasterType;
         }
         return null;
      }
      
      public static function getHeroId(param1:DBFacade, param2:GMOffer) : UInt
      {
         if(param2.IsBundle)
         {
            return (0 : UInt);
         }
         var _loc3_= param2.Details[0];
         return _loc3_.HeroId;
      }
      
      public static function getSkinId(param1:DBFacade, param2:GMOffer) : UInt
      {
         if(param2.IsBundle)
         {
            return (0 : UInt);
         }
         var _loc3_= param2.Details[0];
         return _loc3_.SkinId;
      }
      
      public static function alreadyOwns(param1:DBFacade, param2:GMOffer) : Bool
      {
         var _loc3_= param1.dbAccountInfo.inventoryInfo;
         var _loc4_:GMOfferDetail;
         final __ax4_iter_2 = param2.Details;
         if (checkNullIteratee(__ax4_iter_2)) for (_tmp_ in __ax4_iter_2)
         {
            _loc4_ = _tmp_;
            if(ASCompat.toBool(_loc4_.HeroId) && _loc3_.ownsItem((ASCompat.toInt(_loc4_.HeroId) : UInt)))
            {
               return true;
            }
            if(ASCompat.toBool(_loc4_.PetId) && _loc3_.ownsItem((ASCompat.toInt(_loc4_.PetId) : UInt)))
            {
               return true;
            }
            if(ASCompat.toBool(_loc4_.WeaponId) && _loc3_.ownsExactWeapon(_loc4_))
            {
               return true;
            }
            if(ASCompat.toBool(_loc4_.SkinId) && _loc3_.ownsItem((ASCompat.toInt(_loc4_.SkinId) : UInt)))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function weaponRestrictedAndHeroNotOwned(param1:DBFacade, param2:GMOffer) : Bool
      {
         var _loc3_= requiredHeroForWeapon(param1,param2);
         if(_loc3_ != 0 && !param1.dbAccountInfo.inventoryInfo.ownsItem(_loc3_))
         {
            return true;
         }
         return false;
      }
      
      public static function weaponInventoryWouldOverflow(param1:DBFacade, param2:GMOffer) : Bool
      {
         var _loc4_= (0 : UInt);
         var _loc5_:GMOfferDetail;
         final __ax4_iter_3 = param2.Details;
         if (checkNullIteratee(__ax4_iter_3)) for (_tmp_ in __ax4_iter_3)
         {
            _loc5_ = _tmp_;
            if(ASCompat.toNumberField(_loc5_, "WeaponId") != 0)
            {
               _loc4_++;
            }
            else if(ASCompat.toNumberField(_loc5_, "ChestId") != 0 && (ASCompat.toNumberField(_loc5_, "ChestId") != 60005 && ASCompat.toNumberField(_loc5_, "ChestId") != 60006))
            {
               _loc4_++;
            }
         }
         return _loc4_ != 0 && _loc4_ + param1.dbAccountInfo.unequippedWeaponCount > param1.dbAccountInfo.inventoryLimitWeapons;
      }
      
      public static function stackableLimitWouldOverflow(param1:DBFacade, param2:GMOffer) : Bool
      {
         var _loc8_:GMOfferDetail = null;
         var _loc4_:ASAny = 0;
         var _loc9_:ASAny = 0;
         var _loc5_= 0;
         var _loc3_:ASAny = 0;
         var _loc6_:GMStackable = null;
         var _loc7_= new Map();
         final __ax4_iter_4 = param2.Details;
         if (checkNullIteratee(__ax4_iter_4)) for (_tmp_ in __ax4_iter_4)
         {
            _loc8_  = _tmp_;
            _loc4_ = _loc8_.StackableId;
            if(ASCompat.toBool(_loc4_))
            {
               if(_loc7_.hasKey(_loc4_))
               {
                  _loc9_ = _loc7_.itemFor(_loc4_);
                  _loc7_.replaceFor(_loc4_,_loc9_ + _loc8_.StackableCount);
               }
               else
               {
                  _loc7_.add(_loc4_,_loc8_.StackableCount);
               }
            }
         }
         final __ax4_iter_5 = param2.Details;
         if (checkNullIteratee(__ax4_iter_5)) for (_tmp_ in __ax4_iter_5)
         {
            _loc8_  = _tmp_;
            _loc4_ = _loc8_.StackableId;
            if(ASCompat.toBool(_loc4_))
            {
               _loc5_ = (param1.dbAccountInfo.inventoryInfo.getStackCount((ASCompat.toInt(_loc4_) : UInt)) : Int);
               _loc3_ = _loc7_.itemFor(_loc4_);
               _loc6_ = ASCompat.dynamicAs(param1.gameMaster.stackableById.itemFor(_loc4_), gameMasterDictionary.GMStackable);
               if(ASCompat.toNumber(_loc5_ + _loc3_) > _loc6_.StackLimit)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public static function weaponStorageWouldOverflow(param1:DBFacade, param2:GMOffer) : Bool
      {
         var _loc5_= (0 : UInt);
         var _loc4_:GMOfferDetail;
         final __ax4_iter_6 = param2.Details;
         if (checkNullIteratee(__ax4_iter_6)) for (_tmp_ in __ax4_iter_6)
         {
            _loc4_ = _tmp_;
            _loc5_ += (ASCompat.toInt(_loc4_.WeaponSlots) : UInt);
         }
         if(_loc5_ == 0)
         {
            return false;
         }
         return _loc5_ + param1.dbAccountInfo.inventoryLimitWeapons > 120;
      }
      
      public static function requiredHeroForWeapon(param1:DBFacade, param2:GMOffer) : UInt
      {
         return (0 : UInt);
      }
      
      public static function itemIsEquippedPopup(param1:DBFacade, param2:InventoryBaseInfo, param3:ASFunction, param4:ASFunction) 
      {
         var popup:UISellItemPopup;
         var dbFacade= param1;
         var info= param2;
         var buySuccessCallback= param3;
         var errorCallback= param4;
         dbFacade.metrics.log("ItemEquippedDuringSell",StoreServicesController.getSellMetrics(dbFacade,info));
         popup = new UISellItemPopup(dbFacade,Locale.getString("ITEM_CONFIRM_SELL"),info,Locale.getString("CANCEL"),null,Locale.getString("ITEM_SELL_BUTTON"),function()
         {
            sellItem(dbFacade,info,buySuccessCallback,errorCallback);
         });
         MemoryTracker.track(popup,"UISellItemPopup - created in StoreServicesController.itemIsEquippedPopup()");
      }
      
      public static function confirmSell(param1:DBFacade, param2:InventoryBaseInfo, param3:ASFunction, param4:ASFunction) 
      {
         var popup:UISellItemPopup;
         var dbFacade= param1;
         var info= param2;
         var buySuccessCallback= param3;
         var errorCallback= param4;
         dbFacade.metrics.log("ConfirmSell",StoreServicesController.getSellMetrics(dbFacade,info));
         popup = new UISellItemPopup(dbFacade,Locale.getString("ITEM_CONFIRM_SELL"),info,Locale.getString("CANCEL"),null,Locale.getString("ITEM_SELL_BUTTON"),function()
         {
            sellItem(dbFacade,info,buySuccessCallback,errorCallback);
         });
         MemoryTracker.track(popup,"UISellItemPopup - created in StoreServicesController.confirmSell()");
      }
      
      public static function notEnoughCashPopup(param1:DBFacade, param2:GMOffer) 
      {
         var popup:DBUITwoButtonPopup;
         var dbFacade= param1;
         var gmOffer= param2;
         dbFacade.metrics.log("ShopPurchaseNotEnoughCash",getOfferMetrics(dbFacade,gmOffer));
         popup = new DBUITwoButtonPopup(dbFacade,Locale.getString("SHOP_NOT_ENOUGH_CASH_TITLE"),Locale.getString("SHOP_NOT_ENOUGH_CASH_MESSAGE"),Locale.getString("SHOP_GET_CASH"),function()
         {
            showCashPage(dbFacade,"notEnoughGemsPopup");
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"DBUITwoButtonPopup - created in StoreServicesController.notEnoughCashPopup()");
      }
      
      public static function notEnoughCoinsPopup(param1:DBFacade, param2:GMOffer) 
      {
         var popup:DBUITwoButtonPopup;
         var dbFacade= param1;
         var gmOffer= param2;
         dbFacade.metrics.log("ShopPurchaseNotEnoughCoins",getOfferMetrics(dbFacade,gmOffer));
         popup = new DBUITwoButtonPopup(dbFacade,Locale.getString("SHOP_NOT_ENOUGH_COINS_TITLE"),Locale.getString("SHOP_NOT_ENOUGH_COINS_MESSAGE"),Locale.getString("SHOP_GET_COINS"),function()
         {
            showCoinPage(dbFacade);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"DBUITwoButtonPopup - created in StoreServicesController.notEnoughCoinsPopup()");
      }
      
      public static function notHighEnoughLevelPopup(param1:DBFacade, param2:GMOffer) 
      {
         var popup:DBUITwoButtonPopup;
         var dbFacade= param1;
         var gmOffer= param2;
         dbFacade.metrics.log("ShopPurchaseNotHighLevel",getOfferMetrics(dbFacade,gmOffer));
         popup = new DBUITwoButtonPopup(dbFacade,Locale.getString("SHOP_NOT_HIGH_LEVEL_TITLE"),Locale.getString("SHOP_NOT_HIGH_LEVEL_MESSAGE"),Locale.getString("SHOP_BUY_ANYWAYS"),function()
         {
            buyOffer(dbFacade,gmOffer,null);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"DBUITwoButtonPopup - created in StoreServicesController.notHighEnoughLevelPopup()");
      }
      
      public static function weaponInventoryFullPopup(param1:DBFacade, param2:GMOffer) 
      {
         var popup:DBUITwoButtonPopup;
         var dbFacade= param1;
         var gmOffer= param2;
         dbFacade.metrics.log("ShopPurchaseWeaponInventoryFull",getOfferMetrics(dbFacade,gmOffer));
         popup = new UIStorageFullPopup(dbFacade,Locale.getString("SHOP_WEAPON_INVENTORY_FULL_TITLE"),Locale.getString("SHOP_WEAPON_INVENTORY_FULL_MESSAGE"),Locale.getString("SHOP_GET_STORAGE"),function()
         {
            showStoragePage(dbFacade);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"UIStorageFullPopup - created in StoreServicesController.weaponInventoryFullPopup()");
      }
      
      public static function stackableLimitPopup(param1:DBFacade, param2:GMOffer) 
      {
         param1.metrics.log("ShopPurchaseStackLimit",getOfferMetrics(param1,param2));
         var _loc3_= new DBUIOneButtonPopup(param1,Locale.getString("SHOP_STACK_LIMIT_TITLE"),Locale.getString("SHOP_STACK_LIMIT_MESSAGE"),Locale.getString("CANCEL"),null);
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in StoreServicesController.stackableLimitPopup()");
      }
      
      public static function weaponStorageLimitPopup(param1:DBFacade, param2:GMOffer) 
      {
         param1.metrics.log("ShopPurchaseWeaponStorageLimit",getOfferMetrics(param1,param2));
         var _loc3_= new DBUIOneButtonPopup(param1,Locale.getString("SHOP_WEAPON_STORAGE_LIMIT_TITLE"),Locale.getString("SHOP_WEAPON_STORAGE_LIMIT_MESSAGE"),Locale.getString("CANCEL"),null);
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in StoreServicesController.weaponStorageLimitPopup()");
      }
      
      public static function doesntOwnHeroPopup(param1:DBFacade, param2:GMOffer) 
      {
         var popup:DBUITwoButtonPopup;
         var dbFacade= param1;
         var gmOffer= param2;
         dbFacade.metrics.log("ShopPurchaseDoesntOwnHero",getOfferMetrics(dbFacade,gmOffer));
         popup = new DBUITwoButtonPopup(dbFacade,Locale.getString("SHOP_HERO_NOT_OWNED"),null,Locale.getString("SHOP_BUY_ANYWAYS"),function()
         {
            buyOffer(dbFacade,gmOffer,null);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"DBUITwoButtonPopup - created in StoreServicesController.doesntOwnHeroPopup()");
      }
      
      public static function confirmPurchasePopup(param1:DBFacade, param2:GMOffer, param3:ASFunction, param4:UInt = (0 : UInt)) 
      {
         var popup:UIPurchaseOfferPopup;
         var dbFacade= param1;
         var gmOffer= param2;
         var buySuccessCallback= param3;
         var forHeroId= param4;
         dbFacade.metrics.log("ShopPurchaseConfirm",getOfferMetrics(dbFacade,gmOffer));
         popup = new UIPurchaseOfferPopup(dbFacade,"purchase_popup",Locale.getString("SHOP_CONFIRM_BUY"),gmOffer,Locale.getString("SHOP_BUY"),function()
         {
            buyOffer(dbFacade,gmOffer,buySuccessCallback,forHeroId);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"UIPurchaseOfferPopup - created in StoreServicesController.confirmPurchasePopup()");
      }
      
      public static function confirmAlreadyOwnsPopup(param1:DBFacade, param2:GMOffer, param3:ASFunction, param4:UInt = (0 : UInt)) 
      {
         var popup:UIPurchaseOfferPopup;
         var dbFacade= param1;
         var gmOffer= param2;
         var buySuccessCallback= param3;
         var forHeroId= param4;
         dbFacade.metrics.log("ShopPurchaseConfirmAlreadyOwns",getOfferMetrics(dbFacade,gmOffer));
         popup = new UIPurchaseOfferPopup(dbFacade,"purchase_popup",Locale.getString("SHOP_CONFIRM_DUPLICATE_BUY"),gmOffer,Locale.getString("SHOP_BUY_ANOTHER"),function()
         {
            buyOffer(dbFacade,gmOffer,buySuccessCallback,forHeroId);
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(popup,"UIPurchaseOfferPopup - created in StoreServicesController.confirmAlreadyOwnsPopup()");
      }
      
      public static function waitForPurchaseServicePopup(param1:DBFacade) : DBUIPopup
      {
         var _loc2_= new DBUIPopup(param1,Locale.getString("SHOP_PURCHASING"),null,false);
         MemoryTracker.track(_loc2_,"DBUIPopup - created in StoreServicesController.waitForPurchaseServicePopup()");
         return _loc2_;
      }
      
      public static function waitForSellServicePopup(param1:DBFacade) : DBUIPopup
      {
         var _loc2_= new DBUIPopup(param1,Locale.getString("SHOP_SELLING"),null,false);
         MemoryTracker.track(_loc2_,"DBUIPopup - created in StoreServicesController.waitForSellServicePopup()");
         return _loc2_;
      }
      
      public static function buyOffer(param1:DBFacade, param2:GMOffer, param3:ASFunction, param4:UInt = (0 : UInt)) 
      {
         var popup:DBUIPopup;
         var previousBucketsWeapon:Int;
         var dbFacade= param1;
         var gmOffer= param2;
         var buySuccessCallback= param3;
         var forHeroId= param4;
         dbFacade.metrics.log("ShopPurchase",getOfferMetrics(dbFacade,gmOffer));
         popup = StoreServicesController.waitForPurchaseServicePopup(dbFacade);
         previousBucketsWeapon = dbFacade.dbAccountInfo.inventoryInfo.storageLimitWeapon;
         StoreServices.purchaseOffer(dbFacade,gmOffer.Id,function(param1:ASAny)
         {
            var _loc2_= 0;
            popup.destroy();
            if(dbFacade.steamAchievementsManager != null)
            {
               if(gmOffer.CurrencyType == "BASIC")
               {
                  dbFacade.steamAchievementsManager.addToStatInt("SPEND_COINS_INT",Std.int(gmOffer.Price));
               }
               if(gmOffer.Tab == "WEAPON")
               {
                  dbFacade.steamAchievementsManager.setAchievement("PURCHASE_WEAPON_FIRST_TIME");
               }
            }
            StoreServices.getLimitedOfferUsage(dbFacade,param1,null,null);
            if(buySuccessCallback != null)
            {
               buySuccessCallback(param1);
               _loc2_ = dbFacade.dbAccountInfo.inventoryInfo.storageLimitWeapon;
               if(previousBucketsWeapon < _loc2_ && dbFacade.steamAchievementsManager != null)
               {
                  dbFacade.steamAchievementsManager.setAchievement("STORAGE_EXPAND_FIRST_TIME");
                  dbFacade.steamAchievementsManager.setMaxStorageStat(previousBucketsWeapon,_loc2_);
               }
            }
         },function(param1:Error)
         {
            popup.destroy();
            showErrorPopup(dbFacade,param1);
         },forHeroId);
      }
      
      public static function sellItem(param1:DBFacade, param2:InventoryBaseInfo, param3:ASFunction = null, param4:ASFunction = null) 
      {
         var popup:DBUIPopup;
         var sellFunc:ASFunction;
         var dbFacade= param1;
         var info= param2;
         var buySuccessCallback= param3;
         var errorCallback= param4;
         dbFacade.metrics.log("SellItem",StoreServicesController.getSellMetrics(dbFacade,info));
         popup = StoreServicesController.waitForSellServicePopup(dbFacade);
         if(Std.isOfType(info , ItemInfo))
         {
            sellFunc = StoreServices.sellWeapon;
         }
         else if(Std.isOfType(info , StackableInfo))
         {
            sellFunc = StoreServices.sellStackable;
         }
         else
         {
            if(!Std.isOfType(info , PetInfo))
            {
               Logger.error("Unknown item type in SellItem");
               return;
            }
            sellFunc = StoreServices.sellPet;
         }
         sellFunc(dbFacade,info.databaseId,function(param1:ASAny)
         {
            popup.destroy();
            if(buySuccessCallback != null)
            {
               buySuccessCallback(param1);
            }
         },function(param1:Error)
         {
            popup.destroy();
            showErrorPopup(dbFacade,param1);
            if(errorCallback != null)
            {
               errorCallback();
            }
         });
      }
      
      public static function useAccountBooster(param1:DBFacade, param2:InventoryBaseInfo, param3:ASFunction = null, param4:ASFunction = null) 
      {
         StoreServices.useAccountBooster(param1,param2.gmId,param3,param4);
      }
      
      public static function getWebServerTimestamp(param1:DBFacade, param2:ASFunction = null, param3:ASFunction = null) 
      {
         trace("getWebServerTimestamp");
         StoreServices.getWebServerTimestamp(param1,param2,param3);
      }
      
      public static function showErrorPopup(param1:DBFacade, param2:Error) 
      {
         param1.metrics.log("ShopError",{"error":param2.errorID});
         param1.errorPopup(Locale.getString("SHOP_ERROR") + ": " + param2.errorID,param2.message);
      }
      
      public static function showCashPage(param1:DBFacade, param2:String, param3:GMOffer = null, param4:ASFunction = null, param5:ASFunction = null, param6:UInt = (0 : UInt)) 
      {
         var _loc7_:ASObject = {};
         ASCompat.setProperty(_loc7_, "openedFrom", param2);
         param1.metrics.log("ShopCashPagePresented",_loc7_);
         var _loc8_= new UICashPage(param1);
         MemoryTracker.track(_loc8_,"UICashPage - created in StoreServicesController.showCashPage()");
      }
      
      public static function showCoinPage(param1:DBFacade) 
      {
         param1.metrics.log("ShopCoinPagePresented");
         var _loc2_= new UICoinPage(param1);
         MemoryTracker.track(_loc2_,"UICoinPage - created in StoreServicesController.showCoinPage()");
      }
      
      public static function showStoragePage(param1:DBFacade) 
      {
         param1.metrics.log("ShopStoragePagePresented");
         var _loc2_= new UIOfferPopup(param1,Locale.getString("SHOP_STORAGE_PAGE_TITLE"),STORAGE_OFFERS,null,null,true,false);
         MemoryTracker.track(_loc2_,"UIOfferPopup - created in StoreServicesController.showStoragePage()");
      }
      
      public static function showGiftPage(param1:DBFacade, param2:ASFunction) 
      {
         param1.metrics.log("ShopGiftPagePresented");
         var _loc3_= new UIGiftPage(param1,param2,null);
         MemoryTracker.track(_loc3_,"UIGiftPage - created in StoreServicesController.showGiftPage()");
      }
   }


