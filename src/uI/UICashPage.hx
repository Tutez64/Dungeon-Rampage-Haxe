package uI
;
   import brain.assetRepository.AssetLoadingComponent;
   import facade.DBFacade;
   import facade.Locale;
   import flash.display.MovieClip;
   
    class UICashPage extends DBUIPopup
   {
      
      var mContentMC:MovieClip;
      
      public function new(param1:DBFacade)
      {
         var dbFacade= param1;
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass("popup_coming_soon_content");
            mContentMC = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
            ASCompat.setProperty((mContentMC : ASAny).message_label, "text", Locale.getString("HOW_TO_GEMS_CONTENT"));
         });
         super(dbFacade,Locale.getString("HOW_TO_GEMS_TITLE"),mContentMC,true,true,destroyPopup,true);
      }
      
      function destroyPopup() 
      {
         mContentMC = null;
         super.destroy();
      }
   }


