package uI.inventory
;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMNpc;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMOfferDetail;
   import gameMasterDictionary.GMSkin;
   import gameMasterDictionary.GMWeaponAesthetic;
   import gameMasterDictionary.GMWeaponItem;
   import uI.DBUITwoButtonPopup;
   import flash.display.MovieClip;
   
    class UIPurchaseOfferPopup extends DBUITwoButtonPopup
   {
      
      var mPopupClassName:String;
      
      var mGMOffer:GMOffer;
      
      public function new(param1:DBFacade, param2:String, param3:String, param4:GMOffer, param5:String, param6:ASFunction, param7:String, param8:ASFunction, param9:Bool = true, param10:ASFunction = null)
      {
         mGMOffer = param4;
         mPopupClassName = param2;
         super(param1,param3,null,param5,param6,param7,param8,param9,param10);
      }
      
      override public function destroy() 
      {
         super.destroy();
      }
      
      override function getClassName() : String
      {
         return mPopupClassName;
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var swfPath:String = null;
         var iconName:String = null;
         var offerName:String;
         var offerDetail:GMOfferDetail;
         var weaponItem:GMWeaponItem;
         var weaponAesthetic:GMWeaponAesthetic;
         var hero:GMHero;
         var defaultSkin:GMSkin;
         var pet:GMNpc;
         var skin:GMSkin;
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         offerName = "";
         ASCompat.setProperty((mPopup : ASAny).power, "visible", false);
         if(mGMOffer.IsBundle)
         {
            offerName = mGMOffer.BundleName;
            swfPath = mGMOffer.BundleSwfFilepath;
            iconName = mGMOffer.BundleIcon;
         }
         else
         {
            offerDetail = mGMOffer.Details[0];
            if(offerDetail.WeaponId != 0)
            {
               weaponItem = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(offerDetail.WeaponId), gameMasterDictionary.GMWeaponItem);
               weaponAesthetic = weaponItem.getWeaponAesthetic(offerDetail.Level);
               offerName = weaponAesthetic.Name;
               swfPath = weaponAesthetic.IconSwf;
               iconName = weaponAesthetic.IconName;
               ASCompat.setProperty((mPopup : ASAny).power, "visible", true);
               ASCompat.setProperty((mPopup : ASAny).power.label, "text", offerDetail.WeaponPower);
            }
            else if(offerDetail.HeroId != 0)
            {
               hero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(offerDetail.HeroId), gameMasterDictionary.GMHero);
               defaultSkin = mDBFacade.gameMaster.getSkinByConstant(hero.DefaultSkin);
               if(defaultSkin != null)
               {
                  offerName = hero.Name;
                  swfPath = defaultSkin.UISwfFilepath;
                  iconName = defaultSkin.IconName;
               }
            }
            else if(offerDetail.PetId != 0)
            {
               pet = ASCompat.dynamicAs(mDBFacade.gameMaster.npcById.itemFor(offerDetail.PetId), gameMasterDictionary.GMNpc);
               offerName = pet.Name;
               swfPath = pet.IconSwfFilepath;
               iconName = pet.IconName;
            }
            else if(offerDetail.SkinId != 0)
            {
               skin = mDBFacade.gameMaster.getSkinByType(offerDetail.SkinId);
               offerName = skin.Name;
               swfPath = skin.UISwfFilepath;
               iconName = skin.IconName;
            }
         }
         if(ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName))
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset)
            {
               var _loc3_= param1.getClass(iconName);
               if(_loc3_ == null)
               {
                  Logger.error("Unable to get iconClass for iconName: " + iconName);
                  return;
               }
               var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
               _loc2_.scaleX = _loc2_.scaleY = 70 / 100;
               (mPopup : ASAny).item_icon.addChild(_loc2_);
            });
         }
         if((mPopup : ASAny).message_label != null)
         {
            ASCompat.setProperty((mPopup : ASAny).message_label, "text", offerName);
         }
         ASCompat.setProperty((mPopup : ASAny).cash, "visible", mGMOffer.Price > 0 && mGMOffer.CurrencyType == "PREMIUM");
         ASCompat.setProperty((mPopup : ASAny).coin, "visible", mGMOffer.Price > 0 && mGMOffer.CurrencyType == "BASIC");
         ASCompat.setProperty((mPopup : ASAny).price, "text", mGMOffer.Price > 0 ? Std.string(mGMOffer.Price) : Locale.getString("SHOP_FREE"));
      }
   }


