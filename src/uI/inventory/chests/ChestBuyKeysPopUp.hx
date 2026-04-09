package uI.inventory.chests
;
   import account.ChestInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.render.MovieClipRenderer;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMChest;
   import gameMasterDictionary.GMRarity;
   import uI.UIHud;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   
    class ChestBuyKeysPopUp
   {
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mRoot:MovieClip;
      
      var mBuyCoinButton:UIButton;
      
      var mBuyGemButton:UIButton;
      
      var mCloseButton:UIButton;
      
      var mRenderer:MovieClipRenderer;
      
      var mChestKeySlots:Vector<ChestKeySlot>;
      
      var mCoinButtonCenteredPosition:Int = 1;
      
      var mCoinIconCenteredPosition:Int = -50;
      
      public function new(param1:DBFacade, param2:AssetLoadingComponent, param3:SceneGraphComponent, param4:SwfAsset, param5:GMChest, param6:ASFunction, param7:ASFunction, param8:ASFunction, param9:ASFunction, param10:Bool = false)
      {
         var openKeyChestClass:Dynamic;
         var bounds:Rectangle;
         var swfPath:String;
         var iconName:String;
         var rarity:GMRarity;
         var bgColoredExists:Bool;
         var bgSwfPath:String;
         var bgIconName:String;
         var coinCostForChestKey:Float;
         var cashCostForChestKey:Float;
         var i:Int;
         var dbFacade= param1;
         var assetLoadingComponent= param2;
         var sceneGraphComponent= param3;
         var swfAsset= param4;
         var selectedGMChest= param5;
         var chestBuyCoinCallback= param6;
         var chestBuyGemCallback= param7;
         var closeKeylessChestPopup= param8;
         var refreshHeroInfoCallback= param9;
         var isFromSummary= param10;
         
         mDBFacade = dbFacade;
         mAssetLoadingComponent = assetLoadingComponent;
         mSceneGraphComponent = sceneGraphComponent;
         openKeyChestClass = UIHud.isThisAConsumbleChestId((selectedGMChest.Id : Int)) ? swfAsset.getClass("popup_itemBox_open") : swfAsset.getClass("popup_chest_keyless");
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(openKeyChestClass, []), flash.display.MovieClip);
         mRoot.scaleX = mRoot.scaleY = 1.8;
         bounds = mRoot.getBounds(mDBFacade.stageRef);
         mRoot.x = mDBFacade.stageRef.stageWidth / 2 - bounds.width / 2 - bounds.x;
         mRoot.y = mDBFacade.stageRef.stageHeight / 2 - bounds.height / 2 - bounds.y;
         ASCompat.setProperty((mRoot : ASAny).title_label, "text", isFromSummary ? Locale.getString("TREASURE_FOUND") : Locale.getString(selectedGMChest.Name));
         if(ASCompat.toBool((mRoot : ASAny).description_label))
         {
            ASCompat.setProperty((mRoot : ASAny).description_label, "text", Locale.getString("BUY_KEY_TO_OPEN") + selectedGMChest.Rarity + Locale.getString("CHEST_!"));
         }
         swfPath = selectedGMChest.IconSwf;
         iconName = selectedGMChest.IconName;
         ChestInfo.loadItemIcon(swfPath,iconName,ASCompat.dynamicAs((mRoot : ASAny).content, flash.display.DisplayObjectContainer),mDBFacade,(150 : UInt),(150 : UInt),mAssetLoadingComponent);
         ASCompat.setProperty((mRoot : ASAny).content, "y", UIHud.isThisAConsumbleChestId((selectedGMChest.Id : Int)) ? -6 : -35);
         mRenderer = new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).content, flash.display.MovieClip));
         mRenderer.play((0 : UInt),true);
         rarity = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(selectedGMChest.Rarity), gameMasterDictionary.GMRarity);
         bgColoredExists = rarity.HasColoredBackground;
         bgSwfPath = rarity.BackgroundSwf;
         bgIconName = rarity.BackgroundIcon;
         if(bgColoredExists)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset)
            {
               var _loc3_:MovieClip = null;
               var _loc2_= param1.getClass(bgIconName);
               if(_loc2_ != null)
               {
                  _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
                  (mRoot : ASAny).content.addChildAt(_loc3_,0);
                  _loc3_.scaleX = _loc3_.scaleY = 1.5;
               }
            });
         }
         coinCostForChestKey = 0;
         cashCostForChestKey = 0;
         i = 0;
         while(i < 6)
         {
            if(mDBFacade.dbAccountInfo.inventoryInfo.keys[i].gmKey.ChestId == selectedGMChest.Id)
            {
               coinCostForChestKey = mDBFacade.dbAccountInfo.inventoryInfo.keys[i].gmKeyOffer.Price;
            }
            i = i + 1;
         }
         ASCompat.setProperty((mRoot : ASAny).coin_button, "x", mCoinButtonCenteredPosition);
         ASCompat.setProperty((mRoot : ASAny).coin_icon, "x", mCoinIconCenteredPosition);
         mBuyCoinButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).coin_button, flash.display.MovieClip));
         mBuyCoinButton.releaseCallback = ASCompat.asFunction(chestBuyCoinCallback(coinCostForChestKey));
         mBuyCoinButton.label.text = Std.string(coinCostForChestKey);
         mBuyGemButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).gem_button, flash.display.MovieClip));
         ASCompat.setProperty((mRoot : ASAny).gem_icon, "visible", false);
         mBuyGemButton.visible = false;
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).close, flash.display.MovieClip));
         mCloseButton.releaseCallback = closeKeylessChestPopup;
         ASCompat.setProperty((mRoot : ASAny).coin_icon, "mouseEnabled", false);
         ASCompat.setProperty((mRoot : ASAny).coin_icon, "mouseChildren", false);
         ASCompat.setProperty((mRoot : ASAny).gem_icon, "mouseEnabled", false);
         ASCompat.setProperty((mRoot : ASAny).gem_icon, "mouseChildren", false);
         if(!UIHud.isThisAConsumbleChestId((selectedGMChest.Id : Int)))
         {
            createKeySlots(selectedGMChest);
            refreshHeroInfoCallback(mRoot);
         }
         mSceneGraphComponent.addChild(mRoot,(105 : UInt));
      }
      
      function createKeySlots(param1:GMChest) 
      {
         var _loc3_= 0;
         var _loc2_:MovieClip = null;
         mChestKeySlots = new Vector<ChestKeySlot>();
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            _loc2_ = ASCompat.reinterpretAs(mRoot.getChildByName("slot_" + Std.string(_loc3_)) , MovieClip);
            mChestKeySlots.push(new ChestKeySlot(mDBFacade,_loc2_,mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_],mAssetLoadingComponent));
            if(param1.Id == mChestKeySlots[_loc3_].keyInfo.gmKey.ChestId)
            {
               mChestKeySlots[_loc3_].setSelected(true);
            }
            else
            {
               mChestKeySlots[_loc3_].setSelected(false);
            }
            _loc3_++;
         }
      }
      
      @:isVar public var root(get,never):MovieClip;
public function  get_root() : MovieClip
      {
         return mRoot;
      }
      
      public function destroy() 
      {
         var _loc1_= 0;
         mSceneGraphComponent.removeChild(mRoot);
         mDBFacade = null;
         mAssetLoadingComponent = null;
         mBuyCoinButton.destroy();
         mBuyCoinButton = null;
         mBuyGemButton.destroy();
         mBuyGemButton = null;
         mRenderer.destroy();
         mRenderer = null;
         if(mChestKeySlots != null)
         {
            _loc1_ = 0;
            while(_loc1_ < mChestKeySlots.length)
            {
               mChestKeySlots[_loc1_].destroy();
               _loc1_++;
            }
            mChestKeySlots.splice(0,(mChestKeySlots.length : UInt));
            mChestKeySlots = null;
         }
         mRoot = null;
      }
   }


