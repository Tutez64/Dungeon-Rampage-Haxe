package uI
;
   import account.StoreServicesController;
   import facade.DBFacade;
   
    class UIShopBundleOffer extends UIShopOffer
   {
      
      public function new(param1:DBFacade, param2:Dynamic, param3:ASFunction = null, param4:Bool = true, param5:Bool = true)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      override function  get_offerDescription() : String
      {
         return this.offer.BundleDescription;
      }
      
      override function  get_offerIconName() : String
      {
         return this.offer.BundleIcon;
      }
      
      override function  get_offerSwfPath() : String
      {
         return this.offer.BundleSwfFilepath;
      }
      
      override function hasRequirements() : Bool
      {
         return false;
      }
      
      override function requirementsMetForPurchase() : Bool
      {
         return !StoreServicesController.alreadyOwns(mDBFacade,this.offer);
      }
   }


