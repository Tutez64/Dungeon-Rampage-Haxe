package uI.equipPicker
;
   import account.InventoryBaseInfo;
   import account.ItemInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import uI.inventory.UIWeaponTooltip;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
    class AvatarEquipElement extends UIButton
   {
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mItemInfo:InventoryBaseInfo;
      
      var mIcon:MovieClip;
      
      var mWeaponTooltip:UIWeaponTooltip;
      
      var mContainerHeight:UInt = 0;
      
      var mContainerWidth:UInt = 0;
      
      var mUnequipCallback:ASFunction;
      
      var mHandleDropCallback:ASFunction;
      
      var mEquipSlot:UInt = 0;
      
      var mEquipResponseCallback:ASFunction;
      
      var mClickedEquipedWeaponCallback:ASFunction;
      
      var mAllowEquipmentSwapping:Bool = false;
      
      public function new(param1:DBFacade, param2:String, param3:MovieClip, param4:Dynamic, param5:ASFunction, param6:ASFunction, param7:UInt, param8:ASFunction = null, param9:ASFunction = null, param10:Bool = false)
      {
         super(param1,param3);
         this.label.text = param2;
         this.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mDBFacade = param1;
         mUnequipCallback = param5;
         mHandleDropCallback = param6;
         mEquipSlot = param7;
         mEquipResponseCallback = param9;
         mClickedEquipedWeaponCallback = param8;
         mAllowEquipmentSwapping = param10;
         draggable = false;
         mContainerHeight = (ASCompat.toInt((mRoot : ASAny).frame.height) : UInt);
         mContainerWidth = (ASCompat.toInt((mRoot : ASAny).frame.width) : UInt);
         mWeaponTooltip = new UIWeaponTooltip(mDBFacade,param4);
         this.tooltip = mWeaponTooltip;
         this.tooltipPos = new Point(0,this.root.height * -0.5);
         mWeaponTooltip.visible = false;
         ASCompat.setProperty((mRoot : ASAny).selected, "visible", false);
         setupClickedCallback();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         ASCompat.setProperty((mRoot : ASAny).frame, "alpha", 0);
      }
      
      override public function destroy() 
      {
         mDBFacade = null;
         mItemInfo = null;
         mHandleDropCallback = null;
         mUnequipCallback = null;
         mAssetLoadingComponent.destroy();
         mEquipResponseCallback = null;
         mWeaponTooltip.destroy();
         super.destroy();
      }
      
            
      @:isVar public var itemInfo(get,set):InventoryBaseInfo;
public function  get_itemInfo() : InventoryBaseInfo
      {
         return mItemInfo;
      }
      
      @:isVar public var equipSlot(get,never):UInt;
public function  get_equipSlot() : UInt
      {
         return mEquipSlot;
      }
function  set_itemInfo(param1:InventoryBaseInfo) :InventoryBaseInfo      {
         var _loc2_:ItemInfo = null;
         clear();
         mItemInfo = param1;
         if(mItemInfo != null)
         {
            ASCompat.setProperty((mRoot : ASAny).frame, "alpha", 1);
            loadItemIcon();
            _loc2_ = ASCompat.reinterpretAs(mItemInfo , ItemInfo);
            if(_loc2_ != null)
            {
               mWeaponTooltip.setWeaponItemFromItemInfo(_loc2_);
               mWeaponTooltip.visible = true;
            }
            draggable = true;
         }
         else
         {
            ASCompat.setProperty((mRoot : ASAny).frame, "alpha", 0);
            draggable = false;
         }
return param1;
      }
      
      override public function  set_draggable(param1:Bool) :Bool      {
         if(mAllowEquipmentSwapping)
         {
            super.draggable = param1;
         }
         else
         {
            super.draggable = false;
         }
return param1;
      }
      
      function setupClickedCallback() 
      {
         this.releaseCallbackThis = function(param1:UIButton)
         {
            if(mClickedEquipedWeaponCallback != null)
            {
               mClickedEquipedWeaponCallback(param1);
            }
         };
      }
      
      function loadItemIcon() 
      {
         var swfPath= mItemInfo.uiSwfFilepath;
         var iconName= mItemInfo.iconName;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:brain.assetRepository.SwfAsset)
         {
            var bgColoredExists:Bool;
            var bgSwfPath:String;
            var bgIconName:String;
            var swfAsset= param1;
            var iconClass= swfAsset.getClass(iconName);
            if(iconClass == null)
            {
               Logger.error("Unable to find iconClass of name: " + iconName);
            }
            else
            {
               mIcon = ASCompat.dynamicAs(ASCompat.createInstance(iconClass, []), flash.display.MovieClip);
               mIcon.scaleX = mIcon.scaleY = 60 / mItemInfo.iconScale;
               (mRoot : ASAny).graphic.addChild(mIcon);
            }
            bgColoredExists = mItemInfo.hasColoredBackground;
            bgSwfPath = mItemInfo.backgroundSwfPath;
            bgIconName = mItemInfo.backgroundIconName;
            if(bgColoredExists)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc3_:MovieClip = null;
                  var _loc2_= param1.getClass(bgIconName);
                  if(_loc2_ != null)
                  {
                     _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
                     _loc3_.scaleX = _loc3_.scaleY = 0.85;
                     (mRoot : ASAny).graphic.addChildAt(_loc3_,0);
                  }
               });
            }
         });
      }
      
      public function reset() 
      {
         super.resetDrag();
      }
      
      override function resetDrag() 
      {
         super.resetDrag();
         resetDragUnequipFunc();
      }
      
      function resetDragUnequipFunc() 
      {
         mUnequipCallback(mItemInfo,mEquipResponseCallback);
      }
      
      override public function handleDrop(param1:UIObject) : Bool
      {
         return ASCompat.toBool(mHandleDropCallback(param1,mItemInfo,mEquipSlot));
      }
      
      public function clear() 
      {
         while(ASCompat.toNumberField((mRoot : ASAny).graphic, "numChildren") > 0)
         {
            (mRoot : ASAny).graphic.removeChildAt(0);
         }
         mItemInfo = null;
         draggable = false;
         ASCompat.setProperty((mRoot : ASAny).frame, "alpha", 0);
         mWeaponTooltip.visible = false;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
      }
      
      public function select() 
      {
         ASCompat.setProperty((this.root : ASAny).selected, "visible", true);
      }
      
      public function deselect() 
      {
         ASCompat.setProperty((this.root : ASAny).selected, "visible", false);
      }
   }


