package uI.shop
;
   import account.AvatarInfo;
   import account.StoreServicesController;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import gameMasterDictionary.GMChest;
   import uI.inventory.chests.ChestRevealPopUp;
   import uI.popup.DBUIConfirmChestPurchasePopup;
   
    class UIChestOffer extends UIShopBundleOffer
   {
      
      static inline final TOWN_PATH= "Resources/Art2D/UI/db_UI_town.swf";
      
      static inline final CHEST_SHOP_POPUP_CLASS= "chest_shop_popup";
      
      var mConfirmPurchaseChestPopup:DBUIConfirmChestPurchasePopup;
      
      var mGMChest:GMChest;
      
      var mSelectedAvatarInfo:AvatarInfo;
      
      public function new(param1:DBFacade, param2:Dynamic, param3:AvatarInfo, param4:ASFunction = null)
      {
         super(param1,param2,param4);
         mSelectedAvatarInfo = param3;
      }
      
      override function buyButtonCallback() 
      {
         mGMChest = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(this.offer.Details[0].ChestId), gameMasterDictionary.GMChest);
         if(mGMChest == null)
         {
            Logger.error("Unable to find GMChest for chestId: " + this.offer.Details[0].ChestId);
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass("chest_shop_popup");
            if(_loc2_ == null)
            {
               Logger.error("Unable to find class: chest_shop_popup in: Resources/Art2D/UI/db_UI_town.swf");
               return;
            }
            mConfirmPurchaseChestPopup = new DBUIConfirmChestPurchasePopup(mDBFacade,ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip),purchaseChest,close,offer,mSelectedAvatarInfo.skinId,true,null);
            MemoryTracker.track(mConfirmPurchaseChestPopup,"DBUIConfirmChestPurchasePopup - created in UIChestOffer.buyButtonCallback()");
         });
      }
      
      function purchaseChest() 
      {
         StoreServicesController.tryBuyOffer(mDBFacade,this.offer,workAroundForOfferBeingDestroyed(mDBFacade,mGMChest),mSelectedAvatarInfo.id);
      }
      
      function workAroundForOfferBeingDestroyed(param1:DBFacade, param2:GMChest) : ASFunction
      {
         var dbFacade= param1;
         var gmChest= param2;
         return function(param1:ASAny)
         {
            var selfManagedPopup:ChestRevealPopUp = null;
            var details:ASAny = param1;
            selfManagedPopup = new ChestRevealPopUp(dbFacade,gmChest,function()
            {
               selfManagedPopup.destroy();
            },null);
            selfManagedPopup.updateRevealLoot(details);
         };
      }
      
      function close() 
      {
         mConfirmPurchaseChestPopup.destroy();
      }
      
      override public function destroy() 
      {
         if(mConfirmPurchaseChestPopup != null)
         {
            mConfirmPurchaseChestPopup.destroy();
         }
         super.destroy();
      }
   }


