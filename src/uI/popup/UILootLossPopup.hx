package uI.popup
;
   import brain.render.MovieClipRenderer;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMChest;
   import gameMasterDictionary.GMDoober;
   import flash.display.MovieClip;
   
    class UILootLossPopup extends DBUITwoButtonPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      static inline final POPUP_CLASS_NAME= "exitdungeon_popup";
      
      var movieClipRenderers:Vector<MovieClipRenderer>;
      
      public function new(param1:DBFacade, param2:UInt, param3:Vector<UInt>, param4:ASFunction, param5:ASFunction)
      {
         var treasure_icons:Array<ASAny>;
         var i:UInt;
         var gmDoober:GMDoober;
         var gmChestItem:GMChest;
         var dbFacade= param1;
         var xpLoss= param2;
         var treasure= param3;
         var leftCallback= param4;
         var rightCallback= param5;
         super(dbFacade,Locale.getString("UI_HUD_EXIT_TITLE"),Locale.getString("UI_HUD_EXIT_MESSAGE"),Locale.getString("UI_HUD_EXIT_CONFIRM"),leftCallback,Locale.getString("UI_HUD_EXIT_CANCEL"),rightCallback);
         movieClipRenderers = new Vector<MovieClipRenderer>();
         mDBFacade.metrics.log("LootLossPopupPresented");
         ASCompat.setProperty((mPopup : ASAny).XP_amount, "text", Std.string(xpLoss) + " XP");
         if(treasure.length == 0)
         {
            return;
         }
         treasure_icons = [(mPopup : ASAny).treasure_icon_01,(mPopup : ASAny).treasure_icon_02];
         i = (0 : UInt);
         while(i < (treasure.length : UInt))
         {
            gmDoober = ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(treasure[(i : Int)]), gameMasterDictionary.GMDoober);
            gmChestItem = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(gmDoober.ChestId), gameMasterDictionary.GMChest);
            if(gmChestItem != null && ASCompat.stringAsBool(gmChestItem.IconName))
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmChestItem.IconSwf),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc3_= param1.getClass(gmChestItem.IconName);
                  var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []) , MovieClip);
                  _loc2_.scaleX = _loc2_.scaleY = 0.8;
                  treasure_icons[(i : Int)].addChild(_loc2_);
                  movieClipRenderers.push(new MovieClipRenderer(mDBFacade,_loc2_));
               });
            }
            i = i + 1;
         }
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override function getClassName() : String
      {
         return "exitdungeon_popup";
      }
      
      override public function destroy() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < movieClipRenderers.length)
         {
            movieClipRenderers[_loc1_].destroy();
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
         movieClipRenderers = null;
         super.destroy();
      }
   }


