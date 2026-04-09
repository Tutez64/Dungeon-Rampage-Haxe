package uI
;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMOfferDetail;
   import gameMasterDictionary.GMSkin;
   
    class UIShopSkinOffer extends UIShopOffer
   {
      
      var mGMOfferDetail:GMOfferDetail;
      
      var mGMOfferSkin:GMSkin;
      
      var mInfoButton:UIButton;
      
      public function new(param1:DBFacade, param2:Dynamic, param3:ASFunction = null)
      {
         super(param1,param2,param3);
      }
      
      function showInfo() 
      {
      }
      
      override public function showOffer(param1:GMOffer, param2:GMHero) 
      {
         this.offer = param1;
         mGMOfferDetail = this.offer.Details[0];
         mGMOfferSkin = mDBFacade.gameMaster.getSkinByType(mGMOfferDetail.SkinId);
         mHeroRequiredLabel.visible = !ownsRequiredHero();
         super.showOffer(param1,param2);
      }
      
      override function  get_nativeIconSize() : Float
      {
         return 72;
      }
      
      override function  get_offerDescription() : String
      {
         return mGMOfferSkin != null ? mGMOfferSkin.StoreDescription : "";
      }
      
      override function  get_offerIconName() : String
      {
         return mGMOfferSkin != null ? mGMOfferSkin.IconName : "";
      }
      
      override function  get_offerSwfPath() : String
      {
         var _loc1_= "";
         if(mGMOfferSkin != null)
         {
            _loc1_ = mGMOfferSkin.UISwfFilepath;
         }
         return _loc1_;
      }
      
      override function hasRequirements() : Bool
      {
         return false;
      }
      
      override function requirementsMetForPurchase() : Bool
      {
         if(!mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mGMOfferDetail.SkinId))
         {
            return ownsRequiredHero();
         }
         return false;
      }
      
      override function shouldGreyOffer(param1:GMHero) : Bool
      {
         return !ownsRequiredHero();
      }
      
      function ownsRequiredHero() : Bool
      {
         var _loc2_= ASCompat.dynamicAs(mDBFacade.gameMaster.heroByConstant.itemFor(mGMOfferSkin.ForHero), gameMasterDictionary.GMHero);
         var _loc1_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc2_.Id);
         return _loc1_ != null;
      }
      
      override public function destroy() 
      {
         if(mInfoButton != null)
         {
            mInfoButton.destroy();
            mInfoButton = null;
         }
      }
   }


