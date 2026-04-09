package uI
;
   import account.StoreServicesController;
   import brain.assetRepository.SwfAsset;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import facade.Locale;
   import flash.text.TextField;
   
    class UIDragonKnightUpsellPopup extends DBUIPopup
   {
      
      static inline final DRAGON_KNIGHT_POPUP_SEEN_ATTRIBUTE= "dragon_knight_upsell_seen";
      
      static inline final DUNGEONS_NEEDED_TO_COMPLETE_BEFORE_DRAGON_KNIGHT_POPUP= (40 : UInt);
      
      static var DK_UPSELL_CLASS_NAME:String = "popup_dragonKnight";
      
      var mBuyButton:UIButton;
      
      var mLabel:TextField;
      
      public function new(param1:DBFacade)
      {
         super(param1,Locale.getString("DRAGON_KNIGHT_UPSELL_POPUP_TITLE"),null,true,true,setUpsellAsSeen,false);
         mDBFacade.metrics.log("dragonKnightExclusiveUpsellPopupShown");
      }
      
      public static function ShouldDisplayDragonKnightUpsell(param1:DBFacade) : Bool
      {
         return false;
      }
      
      override function getClassName() : String
      {
         return DK_UPSELL_CLASS_NAME;
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mBuyButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).button_purchase, flash.display.MovieClip));
         mBuyButton.label.text = Locale.getString("DRAGON_KNIGHT_UPSELL_POPUP_BUY_BUTTON");
         mBuyButton.releaseCallbackThis = function(param1:UIButton)
         {
            var _this= param1;
            mPopup.enabled = false;
            StoreServicesController.showCashPage(mDBFacade,"dragonKnightUpsell",null,function()
            {
               _this.destroy();
            },function()
            {
               if(mPopup != null)
               {
                  mPopup.enabled = true;
               }
            });
         };
      }
      
      function setUpsellAsSeen() 
      {
         mDBFacade.dbAccountInfo.alterAttribute("dragon_knight_upsell_seen","true");
      }
      
      override public function destroy() 
      {
         if(mBuyButton != null)
         {
            mBuyButton.destroy();
            mBuyButton = null;
         }
         super.destroy();
      }
   }


