package uI.inventory
;
   import account.InventoryBaseInfo;
   import account.ItemInfo;
   import account.StackableInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderer;
   import brain.uI.UIButton;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.Locale;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   
    class UIInventoryItem extends UIButton
   {
      
      var mInfo:InventoryBaseInfo;
      
      var mDBFacade:DBFacade;
      
      var mIcon:MovieClip;
      
      var mNewLabel:TextField;
      
      var mStackCountLabel:TextField;
      
      var mSelectedEffect:MovieClip;
      
      var mWeaponTooltip:UIWeaponTooltip;
      
      var mClickedCallback:ASFunction;
      
      var mDragDelay:UInt = 0;
      
      var mDragDelayTask:Task;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEquippable:UInt = 0;
      
      var mParentSlot:MovieClip;
      
      var mRenderer:MovieClipRenderer;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:Dynamic, param4:Dynamic, param5:ASFunction)
      {
         var dbFacade= param1;
         var parentSlot= param2;
         var templateClass= param3;
         var tooltipClass= param4;
         var clickedCallback= param5;
         super(dbFacade,ASCompat.dynamicAs(ASCompat.createInstance(templateClass, []), flash.display.MovieClip));
         mDBFacade = dbFacade;
         mParentSlot = parentSlot;
         mClickedCallback = clickedCallback;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mParentSlot.addChild(mRoot);
         mIcon = ASCompat.dynamicAs((mRoot : ASAny).icon, flash.display.MovieClip);
         mNewLabel = ASCompat.dynamicAs((mRoot : ASAny).new_label, flash.text.TextField);
         mStackCountLabel = ASCompat.dynamicAs((mRoot : ASAny).number_label, flash.text.TextField);
         mStackCountLabel.visible = false;
         mSelectedEffect = ASCompat.dynamicAs((mRoot : ASAny).selected_effect, flash.display.MovieClip);
         mSelectedEffect.visible = false;
         mWeaponTooltip = new UIWeaponTooltip(mDBFacade,tooltipClass);
         this.tooltip = mWeaponTooltip;
         this.tooltipPos = new Point(0,this.root.height * -0.4);
         mWeaponTooltip.visible = false;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mPressCallback = function()
         {
            mClickedCallback(mInfo);
         };
         equippable = mEquippable;
         this.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
      }
      
      override public function destroy() 
      {
         if(mRenderer != null)
         {
            mRenderer.destroy();
         }
         mRenderer = null;
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mPressCallback = null;
         if(mWeaponTooltip != null)
         {
            mWeaponTooltip.destroy();
         }
         mDBFacade = null;
         super.destroy();
      }
      
            
      @:isVar public var info(get,set):InventoryBaseInfo;
public function  set_info(param1:InventoryBaseInfo) :InventoryBaseInfo      {
         var _loc3_:ItemInfo = null;
         var _loc2_= 0;
         mInfo = param1;
         while(mIcon.numChildren != 0)
         {
            mIcon.removeChildAt(0);
         }
         mWeaponTooltip.visible = false;
         mStackCountLabel.visible = false;
         if(mInfo != null)
         {
            loadItemIcon();
            mNewLabel.visible = mInfo.isNew;
            mNewLabel.text = Locale.getString("INV_NEW");
            this.enabled = true;
            _loc3_ = ASCompat.reinterpretAs(mInfo , ItemInfo);
            if(_loc3_ != null && _loc3_.gmWeaponItem != null)
            {
               mWeaponTooltip.setWeaponItemFromItemInfo(_loc3_);
               mWeaponTooltip.visible = true;
            }
            if(ASCompat.reinterpretAs(mInfo , StackableInfo) != null)
            {
               _loc2_ = cast(mInfo, StackableInfo).count;
               mStackCountLabel.text = "x" + Std.string(_loc2_);
               mStackCountLabel.visible = true;
            }
         }
         else
         {
            this.enabled = false;
         }
return param1;
      }
function  get_info() : InventoryBaseInfo
      {
         return mInfo;
      }
      
      public function dragSwapItem(param1:InventoryBaseInfo) 
      {
         reset();
         mParentSlot.addChild(mRoot);
         info = param1;
      }
      
      function loadItemIcon() 
      {
         var bgColoredExists= mInfo.hasColoredBackground;
         var bgSwfPath= mInfo.backgroundSwfPath;
         var bgIconName= mInfo.backgroundIconName;
         var swfPath= mInfo.uiSwfFilepath;
         var iconName= mInfo.iconName;
         var needsRenderer= mInfo.needsRenderer;
         while(mIcon.numChildren != 0)
         {
            mIcon.removeChildAt(0);
         }
         if(ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName))
         {
            if(bgColoredExists && mDBFacade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds"))
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc3_:MovieClip = null;
                  var _loc2_= param1.getClass(bgIconName);
                  if(_loc2_ != null)
                  {
                     _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
                     mIcon.addChild(_loc3_);
                  }
               });
            }
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:brain.assetRepository.SwfAsset)
            {
               var _loc2_:MovieClip = null;
               var _loc3_= param1.getClass(iconName);
               if(_loc3_ != null)
               {
                  _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
                  _loc2_.scaleX = _loc2_.scaleY = 72 / mInfo.iconScale;
                  mIcon.addChild(_loc2_);
                  if(needsRenderer)
                  {
                     mRenderer = new MovieClipRenderer(mDBFacade,_loc2_);
                     mRenderer.play((0 : UInt),true);
                  }
               }
               else
               {
                  Logger.warn("Missing icon: " + iconName);
               }
            });
         }
         else
         {
            Logger.error("Missing IconName or UISwfFilepath for GMItem: " + mInfo.gmId);
         }
      }
      
      override public function  set_enabled(param1:Bool) :Bool      {
         super.enabled = param1;
         equippable = (param1 ? (1 : UInt) : (3 : UInt) : UInt);
return param1;
      }
      
            
      @:isVar public var equippable(get,set):UInt;
public function  set_equippable(param1:UInt) :UInt      {
         mEquippable = param1;
         switch(mEquippable - 1)
         {
            case 0:
               mDraggable = true;
               ASCompat.setProperty((mRoot : ASAny).unequippable, "visible", false);
               ASCompat.setProperty((mRoot : ASAny).unusable, "visible", false);
               
            case 1:
               mDraggable = false;
               ASCompat.setProperty((mRoot : ASAny).unequippable, "visible", true);
               ASCompat.setProperty((mRoot : ASAny).unusable, "visible", false);
               
            case 2:
               mDraggable = false;
               ASCompat.setProperty((mRoot : ASAny).unequippable, "visible", true);
               ASCompat.setProperty((mRoot : ASAny).unusable, "visible", true);
         }
return param1;
      }
function  get_equippable() : UInt
      {
         return mEquippable;
      }
      
      public function reset() 
      {
         mRoot.x = mDragStartPos.x;
         mRoot.y = mDragStartPos.y;
         while(mIcon.numChildren != 0)
         {
            mIcon.removeChildAt(0);
         }
      }
      
      public function select() 
      {
         mSelectedEffect.visible = true;
      }
      
      public function deSelect() 
      {
         mSelectedEffect.visible = false;
      }
      
      override function startDrag() 
      {
         this.deSelect();
         super.startDrag();
      }
   }


