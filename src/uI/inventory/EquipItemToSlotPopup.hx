package uI.inventory
;
   import account.InventoryBaseInfo;
   import account.ItemInfo;
   import account.StackableInfo;
   import brain.assetRepository.SwfAsset;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.utils.MemoryTracker;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.Locale;
   import uI.popup.DBUIOneButtonPopup;
   import uI.popup.DBUIPopup;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class EquipItemToSlotPopup extends DBUIPopup
   {
      
      static inline final POPUP_SWF_PATH= "Resources/Art2D/UI/db_UI_town.swf";
      
      static inline final EQUIP_POPUP_CLASS_NAME= "popup_equip";
      
      var mAvatarInstanceId:Int = 0;
      
      var mClosePopupCallback:ASFunction;
      
      var mNotAllowedCallback:ASFunction;
      
      var mItemInfoToEquip:InventoryBaseInfo;
      
      var mSceneGraphComponent:SceneGraphComponent ;
      
      var mEquipPopupRoot:MovieClip;
      
      var mTitleLabel:TextField;
      
      var mMessageLabel:TextField;
      
      var mEquipSlot0:UIButton;
      
      var mEquipSlot1:UIButton;
      
      var mEquipSlot2:UIButton;
      
      var mEquipSlot0Tooltip:UIWeaponTooltip;
      
      var mEquipSlot1Tooltip:UIWeaponTooltip;
      
      var mEquipSlot2Tooltip:UIWeaponTooltip;
      
      var mIsConsumable:Bool = false;
      
      public function new(param1:DBFacade, param2:Int, param3:ASFunction, param4:InventoryBaseInfo, param5:ASFunction = null, param6:Bool = false)
      {
         mDBFacade = param1;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"EquipItemToSlotPopup");
         mAvatarInstanceId = param2;
         mClosePopupCallback = param3;
         mNotAllowedCallback = param5;
         mItemInfoToEquip = param4;
         mIsConsumable = param6;
         super(param1);
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         mSwfAsset = param1;
         var _loc7_= param1.getClass("popup_equip");
         mEquipPopupRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []), flash.display.MovieClip);
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mEquipPopupRoot : ASAny).close, flash.display.MovieClip));
         mCloseButton.releaseCallback = mClosePopupCallback;
         mRoot.addChild(mEquipPopupRoot);
         mTitleLabel = ASCompat.dynamicAs((mEquipPopupRoot : ASAny).title_label , TextField);
         mTitleLabel.text = Locale.getString("EQUIP_POPUP_TITLE");
         mMessageLabel = ASCompat.dynamicAs((mEquipPopupRoot : ASAny).message_label , TextField);
         mMessageLabel.text = Locale.getString("EQUIP_POPUP_MESSAGE");
         ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_weapons, "visible", false);
         ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_potions, "visible", false);
         ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_pets, "visible", false);
         mSceneGraphComponent.addChild(mRoot,(105 : UInt));
         refresh();
         mRoot.scaleY = mRoot.scaleX = 1.8;
         var _loc6_= mRoot.getBounds(mDBFacade.stageRef);
         mRoot.x = mDBFacade.stageRef.stageWidth / 2 - _loc6_.width / 2 - _loc6_.x;
         mRoot.y = mDBFacade.stageRef.stageHeight / 2 - _loc6_.height / 2 - _loc6_.y;
      }
      
      function refresh() 
      {
         if(mEquipPopupRoot == null)
         {
            return;
         }
         if(mAvatarInstanceId != -1)
         {
            if(mIsConsumable)
            {
               refreshAvatarConsumableSlots();
            }
            else
            {
               refreshAvatarWeaponSlots();
            }
         }
      }
      
      function refreshAvatarConsumableSlots() 
      {
         var equippedItem:StackableInfo;
         var equippedItemInfo0:StackableInfo = null;
         var equippedItemInfo1:StackableInfo = null;
         var avatarInfo= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForAvatarInstanceId((mAvatarInstanceId : UInt));
         var equippedItems= mDBFacade.dbAccountInfo.inventoryInfo.getEquipedConsumablesOnAvatar(avatarInfo);
         var i= (0 : UInt);
         while(i < (equippedItems.length : UInt))
         {
            equippedItem = equippedItems[(i : Int)];
            switch(equippedItem.consumableSlot)
            {
               case 0:
                  equippedItemInfo0 = equippedItem;
                  
               case 1:
                  equippedItemInfo1 = equippedItem;
            }
            i = i + 1;
         }
         ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_potions, "visible", true);
         mEquipSlot0 = new UIButton(mDBFacade,ASCompat.dynamicAs((mEquipPopupRoot : ASAny).UI_potions.equip_slot_0, flash.display.MovieClip));
         mEquipSlot0.label.visible = true;
         mEquipSlot0.label.text = "1";
         mEquipSlot0.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         ASCompat.setProperty((mEquipSlot0.root : ASAny).selected, "visible", false);
         ASCompat.setProperty((mEquipSlot0.root : ASAny).quantity, "visible", false);
         ASCompat.setProperty((mEquipSlot0.root : ASAny).textx, "visible", false);
         mEquipSlot0.releaseCallback = function()
         {
            equipToAvatarConsumableSlot((0 : UInt));
         };
         if(equippedItemInfo0 != null)
         {
            ItemInfo.loadItemIconFromId(equippedItemInfo0.gmId,ASCompat.dynamicAs((mEquipSlot0.root : ASAny).graphic, flash.display.DisplayObjectContainer),mDBFacade,(70 : UInt),(Std.int(equippedItemInfo0.iconScale) : UInt),mAssetLoadingComponent);
            ASCompat.setProperty((mEquipSlot0.root : ASAny).quantity, "visible", true);
            ASCompat.setProperty((mEquipSlot0.root : ASAny).quantity, "text", Std.string(equippedItemInfo0.count));
            ASCompat.setProperty((mEquipSlot0.root : ASAny).textx, "visible", true);
         }
         mEquipSlot1 = new UIButton(mDBFacade,ASCompat.dynamicAs((mEquipPopupRoot : ASAny).UI_potions.equip_slot_1, flash.display.MovieClip));
         mEquipSlot1.label.visible = true;
         mEquipSlot1.label.text = "2";
         mEquipSlot1.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         ASCompat.setProperty((mEquipSlot1.root : ASAny).selected, "visible", false);
         ASCompat.setProperty((mEquipSlot1.root : ASAny).quantity, "visible", false);
         ASCompat.setProperty((mEquipSlot1.root : ASAny).textx, "visible", false);
         mEquipSlot1.releaseCallback = function()
         {
            equipToAvatarConsumableSlot((1 : UInt));
         };
         if(equippedItemInfo1 != null)
         {
            ItemInfo.loadItemIconFromId(equippedItemInfo1.gmId,ASCompat.dynamicAs((mEquipSlot1.root : ASAny).graphic, flash.display.DisplayObjectContainer),mDBFacade,(70 : UInt),(Std.int(equippedItemInfo1.iconScale) : UInt),mAssetLoadingComponent);
            ASCompat.setProperty((mEquipSlot1.root : ASAny).quantity, "visible", true);
            ASCompat.setProperty((mEquipSlot1.root : ASAny).quantity, "text", Std.string(equippedItemInfo1.count));
            ASCompat.setProperty((mEquipSlot1.root : ASAny).textx, "visible", true);
         }
         animatedEntrance();
      }
      
      function refreshAvatarWeaponSlots() 
      {
         var equippedItems:Vector<ItemInfo>;
         var equippedItem:ItemInfo;
         var equippedItemInfo0:ItemInfo = null;
         var equippedItemInfo1:ItemInfo = null;
         var equippedItemInfo2:ItemInfo = null;
         var i:UInt;
         ASCompat.setProperty((mEquipPopupRoot : ASAny).UI_weapons, "visible", true);
         equippedItems = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar((mAvatarInstanceId : UInt));
         i = (0 : UInt);
         while(i < (equippedItems.length : UInt))
         {
            equippedItem = equippedItems[(i : Int)];
            switch(equippedItem.avatarSlot)
            {
               case 0:
                  equippedItemInfo0 = equippedItem;
                  
               case 1:
                  equippedItemInfo1 = equippedItem;
                  
               case 2:
                  equippedItemInfo2 = equippedItem;
            }
            i = i + 1;
         }
         if(mEquipSlot0 == null)
         {
            mEquipSlot0 = new UIButton(mDBFacade,ASCompat.dynamicAs((mEquipPopupRoot : ASAny).UI_weapons.equip_slot_0, flash.display.MovieClip));
         }
         mEquipSlot0.label.text = "J";
         mEquipSlot0.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         ASCompat.setProperty((mEquipSlot0.root : ASAny).selected, "visible", false);
         mEquipSlot0.releaseCallback = function()
         {
            equipToAvatarWeaponSlot((0 : UInt));
         };
         if(equippedItemInfo0 != null)
         {
            ItemInfo.loadItemIconFromItemInfo(equippedItemInfo0,ASCompat.dynamicAs((mEquipSlot0.root : ASAny).graphic, flash.display.DisplayObjectContainer),mDBFacade,(70 : UInt),(Std.int(equippedItemInfo0.iconScale) : UInt),mAssetLoadingComponent);
            if(mEquipSlot0Tooltip == null)
            {
               mEquipSlot0Tooltip = new UIWeaponTooltip(mDBFacade,mSwfAsset.getClass("DR_weapon_equip_tooltip"));
               mEquipSlot0.tooltip = mEquipSlot0Tooltip;
            }
            mEquipSlot0Tooltip.setWeaponItemFromItemInfo(equippedItemInfo0);
         }
         if(mEquipSlot1 == null)
         {
            mEquipSlot1 = new UIButton(mDBFacade,ASCompat.dynamicAs((mEquipPopupRoot : ASAny).UI_weapons.equip_slot_1, flash.display.MovieClip));
         }
         mEquipSlot1.label.text = "K";
         mEquipSlot1.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         ASCompat.setProperty((mEquipSlot1.root : ASAny).selected, "visible", false);
         mEquipSlot1.releaseCallback = function()
         {
            equipToAvatarWeaponSlot((1 : UInt));
         };
         if(equippedItemInfo1 != null)
         {
            ItemInfo.loadItemIconFromItemInfo(equippedItemInfo1,ASCompat.dynamicAs((mEquipSlot1.root : ASAny).graphic, flash.display.DisplayObjectContainer),mDBFacade,(70 : UInt),(Std.int(equippedItemInfo1.iconScale) : UInt),mAssetLoadingComponent);
            if(mEquipSlot1Tooltip == null)
            {
               mEquipSlot1Tooltip = new UIWeaponTooltip(mDBFacade,mSwfAsset.getClass("DR_weapon_equip_tooltip"));
               mEquipSlot1.tooltip = mEquipSlot1Tooltip;
            }
            mEquipSlot1Tooltip.setWeaponItemFromItemInfo(equippedItemInfo1);
         }
         if(mEquipSlot2 == null)
         {
            mEquipSlot2 = new UIButton(mDBFacade,ASCompat.dynamicAs((mEquipPopupRoot : ASAny).UI_weapons.equip_slot_2, flash.display.MovieClip));
         }
         mEquipSlot2.label.text = "L";
         mEquipSlot2.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         ASCompat.setProperty((mEquipSlot2.root : ASAny).selected, "visible", false);
         mEquipSlot2.releaseCallback = function()
         {
            equipToAvatarWeaponSlot((2 : UInt));
         };
         if(equippedItemInfo2 != null)
         {
            ItemInfo.loadItemIconFromItemInfo(equippedItemInfo2,ASCompat.dynamicAs((mEquipSlot2.root : ASAny).graphic, flash.display.DisplayObjectContainer),mDBFacade,(70 : UInt),(Std.int(equippedItemInfo2.iconScale) : UInt),mAssetLoadingComponent);
            if(mEquipSlot2Tooltip == null)
            {
               mEquipSlot2Tooltip = new UIWeaponTooltip(mDBFacade,mSwfAsset.getClass("DR_weapon_equip_tooltip"));
               mEquipSlot2.tooltip = mEquipSlot2Tooltip;
            }
            mEquipSlot2Tooltip.setWeaponItemFromItemInfo(equippedItemInfo2);
         }
         animatedEntrance();
      }
      
      function showNotAllowedPopup() 
      {
         var _loc1_= new DBUIOneButtonPopup(mDBFacade,Locale.getString("STACK_NOT_ALLOWED_TITLE"),Locale.getString("STACK_NOT_ALLOWED_MESSAGE"),Locale.getString("CANCEL"),mNotAllowedCallback);
         MemoryTracker.track(_loc1_,"DBUIOneButtonPopup - created in EquipItemToSlotPopup.showNotAllowedPopup()");
      }
      
      function equipToAvatarWeaponSlot(param1:UInt) 
      {
         mDBFacade.dbAccountInfo.inventoryInfo.equipItemOnAvatar((mAvatarInstanceId : UInt),mItemInfoToEquip.databaseId,param1,mClosePopupCallback);
      }
      
      function equipToAvatarConsumableSlot(param1:UInt) 
      {
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForAvatarInstanceId((mAvatarInstanceId : UInt));
         var _loc3_= ASCompat.reinterpretAs(mItemInfoToEquip , StackableInfo);
         if(mDBFacade.dbAccountInfo.inventoryInfo.canEquipThisConsumable(_loc2_,param1,_loc3_.gmId))
         {
            mDBFacade.dbAccountInfo.inventoryInfo.equipConsumableOnAvatar((mAvatarInstanceId : UInt),_loc3_.gmStackable.Id,param1,false,mClosePopupCallback);
         }
         else
         {
            showNotAllowedPopup();
         }
      }
      
      override public function destroy() 
      {
         mSceneGraphComponent.destroy();
         super.destroy();
      }
   }


