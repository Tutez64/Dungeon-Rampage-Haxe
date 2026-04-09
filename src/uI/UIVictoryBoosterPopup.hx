package uI
;
   import account.StackableInfo;
   import brain.assetRepository.SwfAsset;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import gameMasterDictionary.GMStackable;
   import flash.display.MovieClip;
   import org.as3commons.collections.framework.IMapIterator;
   
    class UIVictoryBoosterPopup extends DBUIPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_score_report.swf";
      
      static inline final POPUP_CLASS_NAME= "boosterBonusPopup";
      
      public var expStack:GMStackable;
      
      public var goldStack:GMStackable;
      
      var mExpObject:UIObject;
      
      var mGoldObject:UIObject;
      
      public function new(param1:DBFacade, param2:String = "", param3:ASAny = null, param4:Bool = true, param5:ASFunction = null)
      {
         var _loc6_:StackableInfo = null;
         var _loc7_:GMStackable = null;
         var _loc8_= ASCompat.reinterpretAs(param1.dbAccountInfo.inventoryInfo.stackables.iterator() , IMapIterator);
         while(_loc8_.hasNext())
         {
            _loc6_ = ASCompat.dynamicAs(_loc8_.next(), account.StackableInfo);
            if(_loc6_.isEquipped)
            {
               _loc7_ = _loc6_.gmStackable;
               if(_loc7_.ExpMult > 0)
               {
                  expStack = _loc7_;
               }
               else if(_loc7_.GoldMult > 0)
               {
                  goldStack = _loc7_;
               }
            }
         }
         super(param1,param2,param3,param4,false,param5);
         if(mCurtainActive)
         {
            removeCurtain();
         }
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_score_report.swf";
      }
      
      override function getClassName() : String
      {
         return "boosterBonusPopup";
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mPopup.visible = false;
         ASCompat.setProperty((mPopup : ASAny).potion_slot_A, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).potion_slot_B, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).star, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).coins, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).text_value_slot_A, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).text_value_slot_B, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).text_value_slot_A, "text", "");
         ASCompat.setProperty((mPopup : ASAny).text_value_slot_B, "text", "");
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),function(param1:SwfAsset)
         {
            setupStackIcons(param1);
         });
      }
      
      function setupStackIcons(param1:SwfAsset) 
      {
         var _loc3_:Dynamic = null;
         var _loc2_:MovieClip = null;
         if(expStack != null)
         {
            mExpObject = new UIObject(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).potion_slot_A, flash.display.MovieClip),105);
            _loc3_ = param1.getClass(expStack.IconName);
            _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            _loc2_.scaleX = _loc2_.scaleY = 72 / 100;
            _loc2_.y -= 8;
            mExpObject.root.addChild(_loc2_);
            ASCompat.setProperty((mExpObject.tooltip : ASAny).title_label, "text", expStack.Name.toUpperCase());
            ASCompat.setProperty((mExpObject.tooltip : ASAny).description_label, "text", expStack.Description);
            mPopup.visible = true;
            ASCompat.setProperty((mPopup : ASAny).potion_slot_A, "visible", true);
            ASCompat.setProperty((mPopup : ASAny).star, "visible", true);
            ASCompat.setProperty((mPopup : ASAny).text_value_slot_A, "visible", true);
         }
         if(goldStack != null)
         {
            mGoldObject = new UIObject(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).potion_slot_B, flash.display.MovieClip));
            _loc3_ = param1.getClass(goldStack.IconName);
            _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            _loc2_.scaleX = _loc2_.scaleY = 72 / 100;
            _loc2_.y -= 8;
            mGoldObject.root.addChild(_loc2_);
            ASCompat.setProperty((mGoldObject.tooltip : ASAny).title_label, "text", goldStack.Name.toUpperCase());
            ASCompat.setProperty((mGoldObject.tooltip : ASAny).description_label, "text", goldStack.Description);
            mPopup.visible = true;
            ASCompat.setProperty((mPopup : ASAny).potion_slot_B, "visible", true);
            ASCompat.setProperty((mPopup : ASAny).coins, "visible", true);
            ASCompat.setProperty((mPopup : ASAny).text_value_slot_B, "visible", true);
         }
      }
      
      public function setExp(param1:Int) 
      {
         ASCompat.setProperty((mPopup : ASAny).text_value_slot_A, "text", "+" + Std.string(param1));
      }
      
      public function setGold(param1:Int) 
      {
         ASCompat.setProperty((mPopup : ASAny).text_value_slot_B, "text", "+" + Std.string(param1));
      }
      
      override public function destroy() 
      {
         if(mDBFacade != null)
         {
            super.destroy();
         }
         if(mExpObject != null)
         {
            mExpObject.destroy();
            mExpObject = null;
            expStack = null;
         }
         if(mGoldObject != null)
         {
            mGoldObject.destroy();
            mGoldObject = null;
            goldStack = null;
         }
      }
   }


