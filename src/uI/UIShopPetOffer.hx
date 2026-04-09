package uI
;
   import facade.DBFacade;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMNpc;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMOfferDetail;
   
    class UIShopPetOffer extends UIShopOffer
   {
      
      var mGMOfferDetail:GMOfferDetail;
      
      var mGMOfferPet:GMNpc;
      
      public function new(param1:DBFacade, param2:Dynamic, param3:ASFunction = null)
      {
         super(param1,param2,param3);
      }
      
      override public function showOffer(param1:GMOffer, param2:GMHero) 
      {
         this.offer = param1;
         mGMOfferDetail = this.offer.Details[0];
         mGMOfferPet = ASCompat.dynamicAs(mDBFacade.gameMaster.npcById.itemFor(mGMOfferDetail.PetId), gameMasterDictionary.GMNpc);
         super.showOffer(param1,param2);
      }
      
      override function  get_nativeIconSize() : Float
      {
         return 68;
      }
      
      override function  get_offerDescription() : String
      {
         return mGMOfferPet != null ? mGMOfferPet.Description : "";
      }
      
      override function  get_offerIconName() : String
      {
         return mGMOfferPet != null ? mGMOfferPet.IconName : "";
      }
      
      override function  get_offerSwfPath() : String
      {
         return mGMOfferPet != null ? mGMOfferPet.IconSwfFilepath : "";
      }
      
      override function hasRequirements() : Bool
      {
         return false;
      }
      
      override function requirementsMetForPurchase() : Bool
      {
         return true;
      }
   }


