package uI.inventory
;
   import account.InventoryBaseInfo;
   import account.ItemInfo;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import facade.DBFacade;
   import uI.DBUITwoButtonPopup;
   import flash.display.MovieClip;
   
    class UISellItemPopup extends DBUITwoButtonPopup
   {
      
      static inline final POPUP_CLASS_NAME= "item_popup";
      
      var mInfo:InventoryBaseInfo;
      
      public function new(param1:DBFacade, param2:String, param3:InventoryBaseInfo, param4:String, param5:ASFunction, param6:String, param7:ASFunction, param8:Bool = true, param9:ASFunction = null)
      {
         mInfo = param3;
         super(param1,param2,null,param4,param5,param6,param7,param8,param9);
      }
      
      override public function destroy() 
      {
         super.destroy();
      }
      
      override function getClassName() : String
      {
         return "item_popup";
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var itemInfo:ItemInfo;
         var swfPath:String;
         var iconName:String;
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         itemInfo = ASCompat.reinterpretAs(mInfo , ItemInfo);
         ASCompat.setProperty((mPopup : ASAny).power, "visible", itemInfo != null);
         if(itemInfo != null)
         {
            ASCompat.setProperty((mPopup : ASAny).power.label, "text", Std.string(itemInfo.power));
         }
         swfPath = mInfo.uiSwfFilepath;
         iconName = mInfo.iconName;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset)
         {
            var _loc3_= param1.getClass(iconName);
            if(_loc3_ == null)
            {
               Logger.error("Unable to get iconClass for iconName: " + iconName);
               return;
            }
            var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            _loc2_.scaleX = _loc2_.scaleY = 70 / mInfo.iconScale;
            (mPopup : ASAny).item_icon.addChild(_loc2_);
         });
         ASCompat.setProperty((mPopup : ASAny).coin, "visible", true);
         ASCompat.setProperty((mPopup : ASAny).coin, "mouseEnabled", false);
         ASCompat.setProperty((mPopup : ASAny).coin, "mouseChildren", false);
         ASCompat.setProperty((mPopup : ASAny).price, "text", Std.string(mInfo.sellCoins));
         ASCompat.setProperty((mPopup : ASAny).price, "mouseEnabled", false);
      }
   }


