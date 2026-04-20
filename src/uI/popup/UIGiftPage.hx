package uI.popup
;
   import account.StoreServicesController;
   import brain.assetRepository.SwfAsset;
   import facade.DBFacade;
   import facade.Locale;
   
    class UIGiftPage extends UIOfferPopup
   {
      
      public function new(param1:DBFacade, param2:ASFunction, param3:ASFunction)
      {
         var dbFacade= param1;
         var buyCallback= param2;
         var closeCallback= param3;
         super(dbFacade,Locale.getString("SHOP_GIFT_PAGE_TITLE"),StoreServicesController.GIFT_OFFERS,buyCallback,closeCallback,false,false);
         if(mBuyCallback == null)
         {
            mBuyCallback = function()
            {
               close(null);
            };
         }
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         super.setupUI(param1,param2,param3,param4,param5);
      }
   }


