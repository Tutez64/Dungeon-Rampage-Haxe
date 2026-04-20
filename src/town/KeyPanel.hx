package town
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import facade.Locale;
   import uI.inventory.chests.ChestKeySlot;
   import flash.display.MovieClip;
   
    class KeyPanel
   {
      
      public static inline final KEY_PANEL_CLASS_NAME= "header_key_inventory";
      
      static inline final KEY_PANEL_OPENED_EVENT= "KeyPanelOpened";
      
      static inline final KEY_PANEL_ADD_BUTTON_CLICKED_EVENT= "KeyPanelAddButtonClicked";
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mRoot:MovieClip;
      
      var mStateCreated:String;
      
      var mChestKeySlots:Vector<ChestKeySlot>;
      
      var mBuyButton:UIButton;
      
      var mBuyKeysCallback:ASFunction;
      
      var mCloseButton:UIButton;
      
      var mCloseCallBack:ASFunction;
      
      public function new(param1:DBFacade, param2:AssetLoadingComponent, param3:ASFunction, param4:ASFunction, param5:String)
      {
         
         mDBFacade = param1;
         mAssetLoadingComponent = param2;
         mBuyKeysCallback = param3;
         mCloseCallBack = param4;
         mStateCreated = param5;
         mChestKeySlots = new Vector<ChestKeySlot>();
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"KeyPanel");
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),swfLoaded);
         var _loc6_:ASObject = {};
         ASCompat.setProperty(_loc6_, "mainGameState", mStateCreated);
         mDBFacade.metrics.log("KeyPanelOpened",_loc6_);
      }
      
      function swfLoaded(param1:SwfAsset) 
      {
         var _loc2_= param1.getClass("header_key_inventory");
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         mSceneGraphComponent.addChild(mRoot,(105 : UInt));
         mRoot.x = 563;
         mRoot.y = 93;
         setupUI();
      }
      
      function setupUI() 
      {
         var i:Int;
         var slotMC:MovieClip;
         ASCompat.setProperty((mRoot : ASAny).label, "text", Locale.getString("KEYS_OWNED"));
         i = 0;
         while(i < 4)
         {
            slotMC = ASCompat.reinterpretAs(mRoot.getChildByName("slot_" + Std.string(i)) , MovieClip);
            mChestKeySlots.push(new ChestKeySlot(mDBFacade,slotMC,mDBFacade.dbAccountInfo.inventoryInfo.keys[i],mAssetLoadingComponent,true));
            i = i + 1;
         }
         mBuyButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).buy, flash.display.MovieClip));
         mBuyButton.label.text = Locale.getString("ADD");
         mBuyButton.releaseCallback = function()
         {
            var _loc1_:ASObject = {};
            ASCompat.setProperty(_loc1_, "mainGameState", mStateCreated);
            mDBFacade.metrics.log("KeyPanelAddButtonClicked",_loc1_);
            mBuyKeysCallback();
         };
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).close, flash.display.MovieClip));
         mCloseButton.releaseCallback = mCloseCallBack;
      }
      
      public function refresh() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            mChestKeySlots[_loc1_].refresh(mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_]);
            _loc1_++;
         }
      }
      
      public function disableBuyButton() 
      {
         mBuyButton.label.text = Locale.getString("CLOSE");
      }
      
      public function destroy() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < mChestKeySlots.length)
         {
            mChestKeySlots[_loc1_].destroy();
            _loc1_++;
         }
         mChestKeySlots.splice(0,(mChestKeySlots.length : UInt));
         mSceneGraphComponent.removeChild(mRoot);
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mAssetLoadingComponent = null;
         mRoot = null;
      }
   }


