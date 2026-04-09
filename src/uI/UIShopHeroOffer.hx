package uI
;
   import brain.uI.UIButton;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMOfferDetail;
   import gameMasterDictionary.GMSkin;
   import town.TownHeader;
   
    class UIShopHeroOffer extends UIShopOffer
   {
      
      var mGMOfferDetail:GMOfferDetail;
      
      var mGMOfferHero:GMHero;
      
      var mInfoButton:UIButton;
      
      var mTownHeader:TownHeader;
      
      public function new(param1:TownHeader, param2:DBFacade, param3:Dynamic, param4:ASFunction = null)
      {
         super(param2,param3,param4);
         mInfoButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).icon, flash.display.MovieClip));
         mInfoButton.releaseCallback = this.showInfo;
         mTownHeader = param1;
      }
      
      function showInfo() 
      {
         var _loc1_:UIHeroUpsellPopup = null;
         if(this.requirementsMetForPurchase())
         {
            _loc1_ = new UIHeroUpsellPopup(mTownHeader,mDBFacade,this.offer,null);
            MemoryTracker.track(_loc1_,"UIHeroUpsellPopup - created in UIShopHeroOffer.showInfo()");
         }
      }
      
      override public function destroy() 
      {
         if(mInfoButton != null)
         {
            mInfoButton.destroy();
            mInfoButton = null;
         }
      }
      
      override public function showOffer(param1:GMOffer, param2:GMHero) 
      {
         this.offer = param1;
         mGMOfferDetail = this.offer.Details[0];
         mGMOfferHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mGMOfferDetail.HeroId), gameMasterDictionary.GMHero);
         super.showOffer(param1,param2);
      }
      
      override function IsCashPageExclusiveOffer() : Bool
      {
         return mGMOfferHero.IsExclusive;
      }
      
      override function  get_nativeIconSize() : Float
      {
         return 72;
      }
      
      override function  get_offerDescription() : String
      {
         return mGMOfferHero != null ? mGMOfferHero.StoreDescription : "";
      }
      
      override function  get_offerIconName() : String
      {
         return mGMOfferHero != null ? mGMOfferHero.IconName : "";
      }
      
      override function  get_offerSwfPath() : String
      {
         var _loc2_:GMSkin = null;
         var _loc1_= "";
         if(mGMOfferHero != null)
         {
            _loc2_ = mDBFacade.gameMaster.getSkinByConstant(mGMOfferHero.DefaultSkin);
            _loc1_ = _loc2_.UISwfFilepath;
         }
         return _loc1_;
      }
      
      override function hasRequirements() : Bool
      {
         return false;
      }
      
      override function requirementsMetForPurchase() : Bool
      {
         return !mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mGMOfferDetail.HeroId);
      }
   }


