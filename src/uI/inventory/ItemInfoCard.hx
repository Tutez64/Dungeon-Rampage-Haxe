package uI.inventory
;
   import account.AvatarInfo;
   import account.InventoryBaseInfo;
   import account.ItemInfo;
   import account.PetInfo;
   import account.StackableInfo;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphManager;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.utils.MemoryTracker;
   import dBGlobals.DBGlobal;
   import distributedObjects.DistributedDungeonSummary;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMModifier;
   import gameMasterDictionary.GMWeaponItem;
   import gameMasterDictionary.GMWeaponMastertype;
   import uI.equipPicker.HeroWithEquipPicker;
   import uI.equipPicker.PetsWithEquipPicker;
   import uI.modifiers.UIModifier;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
    class ItemInfoCard extends UIObject
   {
      
      static inline final ITEM_CARD_LEVEL_REQUIREMENT= "ITEM_CARD_LEVEL_REQUIREMENT";
      
      static inline final ITEM_CARD_UNLOCK_AT_LEVEL= "ITEM_CARD_UNLOCK_AT_LEVEL";
      
      var mDBFacade:DBFacade;
      
      var mInfo:InventoryBaseInfo;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mHoldIcon:UIObject;
      
      var mHoldTooltip:UITapHoldTooltip;
      
      var mTapIcon:UIObject;
      
      var mTapTooltip:UITapHoldTooltip;
      
      var mHoldManaIcon:MovieClip;
      
      var mTapManaIcon:MovieClip;
      
      var mDescription:TextField;
      
      var mItemParent:UIObject;
      
      var mIcon:MovieClip;
      
      var mRenderer:MovieClipRenderController;
      
      var mLabel:TextField;
      
      var mPowerIcon:MovieClip;
      
      var mPowerLabel:TextField;
      
      var mLevelRequirement:TextField;
      
      var mLevelRequirementNotMet:TextField;
      
      var mSellPriceLabel:TextField;
      
      var mSellButton:UIButton;
      
      var mEquipButton:UIButton;
      
      var mCloseButton:UIButton;
      
      var mWeaponTypeLabel:TextField;
      
      var mWeaponTypeUnequippableLabel:TextField;
      
      var mModifierTitle:TextField;
      
      var mModifiersList:Vector<UIModifier>;
      
      var mEquipPopup:EquipItemToSlotPopup;
      
      var mSellItemCallback:ASFunction;
      
      var mTakeItemCallback:ASFunction;
      
      var mHeroEquipPicker:HeroWithEquipPicker;
      
      var mPetEquipPicker:PetsWithEquipPicker;
      
      var mRefreshInventoryCallback:ASFunction;
      
      var mDungeonSummary:DistributedDungeonSummary;
      
      var mEventComponent:EventComponent;
      
      var mWeaponDescTooltip:UIWeaponDescTooltip;
      
      var mOriginalXValueForIcon:Float = Math.NaN;
      
      var mOriginalPosForEquipButton:Point;
      
      var mTitleY:Float = Math.NaN;
      
      var mEquipLimitTF:TextField;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:Dynamic, param4:HeroWithEquipPicker, param5:PetsWithEquipPicker, param6:ASFunction, param7:DistributedDungeonSummary, param8:Bool = true, param9:ASFunction = null, param10:ASFunction = null, param11:ASFunction = null)
      {
         var dbFacade= param1;
         var root= param2;
         var chargeTooltipClass= param3;
         var heroEquipPicker= param4;
         var petEquipPicker= param5;
         var refreshInventoryCallback= param6;
         var dungeonSummary= param7;
         var allowCloseButton= param8;
         var sellItemCallback= param9;
         var takeItemCallback= param10;
         var closeButtonCallback= param11;
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mHeroEquipPicker = heroEquipPicker;
         mPetEquipPicker = petEquipPicker;
         mRefreshInventoryCallback = refreshInventoryCallback;
         mDungeonSummary = dungeonSummary;
         mTakeItemCallback = takeItemCallback;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         ASCompat.setProperty((mRoot : ASAny).pet_stats, "visible", false);
         ASCompat.setProperty((mRoot : ASAny).ability.label_charge, "text", Locale.getString("HOLD"));
         mHoldIcon = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).ability.icon, flash.display.MovieClip));
         mHoldManaIcon = ASCompat.dynamicAs((mRoot : ASAny).ability.mana_icon_hold, flash.display.MovieClip);
         mHoldManaIcon.visible = false;
         mTapManaIcon = ASCompat.dynamicAs((mRoot : ASAny).ability.mana_icon_tap, flash.display.MovieClip);
         mTapManaIcon.visible = false;
         mHoldTooltip = new UITapHoldTooltip(mDBFacade,chargeTooltipClass);
         mHoldIcon.tooltip = mHoldTooltip;
         mHoldIcon.tooltipPos = new Point(0,mHoldIcon.root.height * 0.5);
         mHoldTooltip.visible = false;
         ASCompat.setProperty((mRoot : ASAny).ability.label_tap, "text", Locale.getString("TAP"));
         mTapIcon = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).ability.tap_icon, flash.display.MovieClip));
         mTapTooltip = new UITapHoldTooltip(mDBFacade,chargeTooltipClass);
         mTapIcon.tooltip = mTapTooltip;
         mTapIcon.tooltipPos = new Point(0,mTapIcon.root.height * 0.5);
         mTapTooltip.visible = false;
         mDescription = ASCompat.dynamicAs((mRoot : ASAny).description, flash.text.TextField);
         mItemParent = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).item_icon, flash.display.MovieClip));
         mOriginalXValueForIcon = ASCompat.toNumberField((mRoot : ASAny).item_icon, "x");
         mWeaponTypeLabel = ASCompat.dynamicAs((mRoot : ASAny).weapon_type_label, flash.text.TextField);
         mWeaponTypeLabel.visible = false;
         mWeaponTypeUnequippableLabel = ASCompat.dynamicAs((mRoot : ASAny).weapon_type_label_unequippable, flash.text.TextField);
         mWeaponTypeUnequippableLabel.visible = false;
         mLabel = ASCompat.dynamicAs((mRoot : ASAny).label, flash.text.TextField);
         mTitleY = mLabel.y;
         mPowerIcon = ASCompat.dynamicAs((mRoot : ASAny).power, flash.display.MovieClip);
         mPowerLabel = ASCompat.dynamicAs((mRoot : ASAny).power.label, flash.text.TextField);
         mLevelRequirement = ASCompat.dynamicAs((mRoot : ASAny).level_requirement, flash.text.TextField);
         mLevelRequirementNotMet = ASCompat.dynamicAs((mRoot : ASAny).level_requirement_not_met, flash.text.TextField);
         mModifierTitle = ASCompat.dynamicAs((mRoot : ASAny).ability.label_modifier, flash.text.TextField);
         mModifiersList = new Vector<UIModifier>();
         mSellButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).sell, flash.display.MovieClip));
         mSellButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mSellButton.label.text = Locale.getString("ITEM_CARD_SELL");
         mSellPriceLabel = ASCompat.dynamicAs((mRoot : ASAny).sell.sell_text , TextField);
         mSellPriceLabel.text = "";
         mSellButton.enabled = false;
         mSellItemCallback = sellItemCallback;
         mSellButton.pressCallback = function()
         {
            mSellItemCallback(mInfo);
         };
         ASCompat.setProperty((mRoot : ASAny).pet_stats, "visible", false);
         mEquipButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).equip, flash.display.MovieClip));
         mEquipButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mOriginalPosForEquipButton = new Point(mEquipButton.root.x,mEquipButton.root.y);
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).close, flash.display.MovieClip));
         mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mCloseButton.releaseCallback = closeButtonCallback;
         mCloseButton.visible = allowCloseButton;
         mEquipLimitTF = ASCompat.dynamicAs((mRoot : ASAny).equipLimit, flash.text.TextField);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass("weapon_desc_tooltip");
            mWeaponDescTooltip = new UIWeaponDescTooltip(mDBFacade,_loc2_);
            mWeaponDescTooltip.place(0,70);
            mItemParent.tooltip = mWeaponDescTooltip;
            mWeaponDescTooltip.visible = false;
         });
         this.visible = false;
      }
      
      public function enableCloseButton(param1:ASFunction) 
      {
         mCloseButton.visible = true;
         mCloseButton.releaseCallback = param1;
      }
      
      override public function destroy() 
      {
         var _loc1_:UIModifier;
         var __ax4_iter_12:Vector<UIModifier>;
         mTapTooltip.destroy();
         mTapIcon.destroy();
         mHoldTooltip.destroy();
         mHoldIcon.destroy();
         mTapTooltip = null;
         mTapIcon = null;
         mHoldTooltip = null;
         mHoldIcon = null;
         mWeaponDescTooltip.destroy();
         if(mModifiersList.length > 0)
         {
            __ax4_iter_12 = mModifiersList;
            if (checkNullIteratee(__ax4_iter_12)) for (_tmp_ in __ax4_iter_12)
            {
               _loc1_ = _tmp_;
               _loc1_.destroy();
            }
         }
         mModifiersList = null;
         mDBFacade = null;
         mAssetLoadingComponent.destroy();
         mEventComponent.destroy();
         mSellButton.destroy();
         mEquipButton.destroy();
         mCloseButton.destroy();
         if(mRenderer != null)
         {
            mRenderer.destroy();
         }
         super.destroy();
      }
      
      @:isVar public var info(never,set):InventoryBaseInfo;
public function  set_info(param1:InventoryBaseInfo) :InventoryBaseInfo      {
         var _loc2_:ItemInfo = null;
         var _loc3_:StackableInfo = null;
         if(mEquipPopup != null)
         {
            mEquipPopup.destroy();
            mEquipPopup = null;
         }
         mInfo = param1;
         if(mInfo == null)
         {
            mRoot.visible = false;
         }
         else if(Std.isOfType(mInfo , ItemInfo))
         {
            _loc2_ = ASCompat.reinterpretAs(mInfo , ItemInfo);
            setupWeaponItemInfoUI(_loc2_);
            setupWeaponItemUI(_loc2_,_loc2_.avatarId != 0);
            mRoot.visible = true;
         }
         else if(Std.isOfType(mInfo , StackableInfo))
         {
            _loc3_ = ASCompat.reinterpretAs(mInfo , StackableInfo);
            setupStackableItemInfoUI(_loc3_);
            setupStackableInfoUI(_loc3_.isEquipped);
            mRoot.visible = true;
         }
         else if(Std.isOfType(mInfo , PetInfo))
         {
            setupPetInfoUI();
            mRoot.visible = true;
         }
return param1;
      }
      
      public function clear() 
      {
         mInfo = null;
         mRoot.visible = false;
         if(mEquipPopup != null)
         {
            mEquipPopup.destroy();
            mEquipPopup = null;
         }
      }
      
      function setupInventoryBaseUI() 
      {
         var _loc1_= (mInfo.sellCoins : UInt);
         mSellButton.enabled = true;
         mSellButton.visible = true;
         mSellPriceLabel.text = Std.string(_loc1_);
         mSellPriceLabel.visible = true;
         ASCompat.setProperty((mRoot : ASAny).pet_stats, "visible", false);
         mLabel.text = mInfo.Name.toUpperCase();
         mDescription.text = mInfo.Description;
         mModifierTitle.visible = false;
         clearModifiers();
         loadIcon();
         mEquipButton.root.x = mOriginalPosForEquipButton.x;
         mEquipButton.root.y = mOriginalPosForEquipButton.y;
         mEquipLimitTF.visible = false;
      }
      
      function setupStackableInfoUI(param1:Bool) 
      {
         ASCompat.setProperty((mRoot : ASAny).ability, "visible", false);
         mDescription.visible = true;
         mWeaponDescTooltip.visible = false;
         this.setupInventoryBaseUI();
         ASCompat.setProperty((mRoot : ASAny).icon_slot, "x", mOriginalXValueForIcon + 55);
         mItemParent.root.x = mOriginalXValueForIcon + 55;
         var _loc2_= ASCompat.reinterpretAs(mInfo , StackableInfo);
         if(_loc2_ == null)
         {
            return;
         }
         mSellButton.visible = false;
         mSellButton.enabled = false;
         mSellPriceLabel.visible = false;
         var _loc3_= (1 : UInt);
         mEquipButton.enabled = param1 ? true : _loc3_ == 1;
         mEquipButton.root.x = mOriginalPosForEquipButton.x - 60;
         mEquipButton.root.y = mOriginalPosForEquipButton.y - 10;
         mLevelRequirement.visible = false;
         mLevelRequirementNotMet.visible = false;
         mWeaponTypeUnequippableLabel.visible = false;
         mWeaponTypeLabel.visible = false;
         mPowerIcon.visible = false;
         mPowerLabel.visible = false;
         ASCompat.setProperty((mRoot : ASAny).unequippable, "visible", false);
         if(mEquipButton.visible)
         {
            mEquipLimitTF.visible = true;
            mEquipLimitTF.y = 115;
            mEquipLimitTF.text = Locale.getString("EQUIP_LIMIT") + Std.string(_loc2_.gmStackable.EquipLimit);
         }
         else
         {
            mEquipLimitTF.visible = false;
         }
         this.greyOffer(false);
      }
      
      function setupPetInfoUI() 
      {
         var petInfo:PetInfo;
         var sellBackPrice:UInt;
         mEquipButton.root.x = mOriginalPosForEquipButton.x;
         mEquipButton.root.y = mOriginalPosForEquipButton.y;
         mSellPriceLabel.visible = true;
         mEquipLimitTF.visible = false;
         ASCompat.setProperty((mRoot : ASAny).ability, "visible", false);
         mDescription.visible = true;
         mWeaponDescTooltip.visible = false;
         ASCompat.setProperty((mRoot : ASAny).icon_slot, "x", mOriginalXValueForIcon);
         mItemParent.root.x = mOriginalXValueForIcon;
         petInfo = ASCompat.reinterpretAs(mInfo , PetInfo);
         if(petInfo == null)
         {
            return;
         }
         ASCompat.setProperty((mRoot : ASAny).pet_stats.petname_label, "visible", false);
         ASCompat.setProperty((mRoot : ASAny).pet_stats, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star1, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star2, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star3, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star4, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star5, "visible", true);
         if(petInfo.attackRating < 5)
         {
            ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star5, "visible", false);
            if(petInfo.attackRating < 4)
            {
               ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star4, "visible", false);
               if(petInfo.attackRating < 3)
               {
                  ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star3, "visible", false);
                  if(petInfo.attackRating < 2)
                  {
                     ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star2, "visible", false);
                     if(petInfo.attackRating < 1)
                     {
                        ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_power.star1, "visible", false);
                     }
                  }
               }
            }
         }
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star1, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star2, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star3, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star4, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star5, "visible", true);
         if(petInfo.defenseRating < 5)
         {
            ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star5, "visible", false);
            if(petInfo.defenseRating < 4)
            {
               ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star4, "visible", false);
               if(petInfo.defenseRating < 3)
               {
                  ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star3, "visible", false);
                  if(petInfo.defenseRating < 2)
                  {
                     ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star2, "visible", false);
                     if(petInfo.defenseRating < 1)
                     {
                        ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_defense.star1, "visible", false);
                     }
                  }
               }
            }
         }
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star1, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star2, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star3, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star4, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star5, "visible", true);
         if(petInfo.speedRating < 5)
         {
            ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star5, "visible", false);
            if(petInfo.speedRating < 4)
            {
               ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star4, "visible", false);
               if(petInfo.speedRating < 3)
               {
                  ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star3, "visible", false);
                  if(petInfo.speedRating < 2)
                  {
                     ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star2, "visible", false);
                     if(petInfo.speedRating < 1)
                     {
                        ASCompat.setProperty((mRoot : ASAny).pet_stats.pet_stats_speed.star1, "visible", false);
                     }
                  }
               }
            }
         }
         mSellButton.visible = true;
         mSellButton.enabled = true;
         sellBackPrice = (petInfo.gmNpc.SellCoins : UInt);
         mSellPriceLabel.text = Std.string(sellBackPrice);
         mLabel.text = petInfo.gmNpc.Name.toUpperCase();
         mDescription.text = petInfo.gmNpc.Description;
         loadIcon();
         if(petInfo.EquippedHero == 0)
         {
            mEquipButton.visible = true;
            mEquipButton.enabled = true;
            mEquipButton.label.text = Locale.getString("ITEM_CARD_EQUIP");
            mEquipButton.releaseCallback = function()
            {
               mPetEquipPicker.handleItemDrop(null,petInfo,(1 : UInt));
            };
         }
         else
         {
            mEquipButton.visible = true;
            mEquipButton.enabled = true;
            mEquipButton.label.text = Locale.getString("ITEM_CARD_UNEQUIP");
            mEquipButton.releaseCallback = function()
            {
               mPetEquipPicker.unequipPet(petInfo);
            };
         }
         mLevelRequirement.visible = false;
         mLevelRequirementNotMet.visible = false;
         mWeaponTypeUnequippableLabel.visible = false;
         mWeaponTypeLabel.visible = false;
         mPowerIcon.visible = false;
         mPowerLabel.visible = false;
         ASCompat.setProperty((mRoot : ASAny).unequippable, "visible", false);
         this.greyOffer(false);
         if(sellBackPrice == 0)
         {
            mSellButton.visible = false;
            mEquipButton.root.x = mOriginalPosForEquipButton.x - 60;
            mEquipButton.root.y = mOriginalPosForEquipButton.y - 10;
         }
      }
      
      function setupWeaponItemUI(param1:ItemInfo, param2:Bool) 
      {
         var weaponName:String;
         var stagePos:Point;
         var gmWeaponItem:GMWeaponItem;
         var power:UInt;
         var sellBackPrice:UInt;
         var swfPath:String;
         var iconName:String;
         var swfPath1:String;
         var iconName1:String;
         var currentlySelectedAvatarInfo:AvatarInfo;
         var canEquip:UInt;
         var preNameModifiers:String;
         var modifierList:Vector<GMModifier>;
         var i:Int;
         var format:TextFormat;
         var sizeMult:Float;
         var itemInfo= param1;
         var equipped= param2;
         this.setupInventoryBaseUI();
         ASCompat.setProperty((mRoot : ASAny).ability, "visible", true);
         mDescription.visible = false;
         ASCompat.setProperty((mRoot : ASAny).icon_slot, "x", mOriginalXValueForIcon);
         mItemParent.root.x = mOriginalXValueForIcon;
         weaponName = "";
         weaponName = itemInfo.Name.toUpperCase();
         gmWeaponItem = itemInfo.gmWeaponItem;
         power = itemInfo.power;
         sellBackPrice = (gmWeaponItem.SellCoins : UInt);
         mWeaponDescTooltip.setWeaponItem(gmWeaponItem,itemInfo.requiredLevel,itemInfo.legendaryModifier > 0);
         mWeaponDescTooltip.visible = true;
         while(mTapIcon.root.numChildren > 1)
         {
            mTapIcon.root.removeChildAt(1);
            mTapIcon.visible = false;
            mTapTooltip.visible = false;
         }
         if(ASCompat.stringAsBool(gmWeaponItem.TapIcon) && gmWeaponItem.TapIcon != "")
         {
            mTapIcon.visible = true;
            swfPath = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
            iconName = gmWeaponItem.TapIcon;
            if(ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName))
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc2_:MovieClip = null;
                  var _loc3_= param1.getClass(iconName);
                  if(_loc3_ != null)
                  {
                     _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
                     _loc2_.scaleX = _loc2_.scaleY = 0.5;
                     mTapIcon.root.addChild(_loc2_);
                     mTapTooltip.setValues(gmWeaponItem.TapTitle,gmWeaponItem.TapDescription);
                     mTapTooltip.visible = true;
                     stagePos = new Point();
                     stagePos.y += mHoldIcon.root.height * 0.5;
                     mHoldIcon.tooltipPos = stagePos;
                  }
               });
            }
         }
         while(mHoldIcon.root.numChildren > 1)
         {
            mHoldIcon.root.removeChildAt(1);
            mHoldTooltip.visible = false;
         }
         if(ASCompat.stringAsBool(gmWeaponItem.HoldIcon) && gmWeaponItem.HoldIcon != "")
         {
            mHoldIcon.visible = true;
            swfPath1 = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
            iconName1 = gmWeaponItem.HoldIcon;
            if(ASCompat.stringAsBool(swfPath1) && ASCompat.stringAsBool(iconName1))
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath1),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc2_:MovieClip = null;
                  var _loc4_:String = null;
                  var _loc3_= param1.getClass(iconName1);
                  if(_loc3_ != null)
                  {
                     _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
                     _loc2_.scaleX = _loc2_.scaleY = 0.5;
                     mHoldIcon.root.addChild(_loc2_);
                     _loc4_ = gmWeaponItem.WeaponController != null ? Locale.getString(gmWeaponItem.WeaponController) : gmWeaponItem.HoldTitle;
                     mHoldTooltip.setValues(_loc4_,gmWeaponItem.HoldDescription);
                     mHoldTooltip.visible = true;
                     stagePos = new Point();
                     stagePos.y += mHoldIcon.root.height * 0.5;
                     mHoldIcon.tooltipPos = stagePos;
                  }
               });
            }
         }
         loadItemType(gmWeaponItem);
         mPowerIcon.visible = true;
         mPowerLabel.visible = true;
         mPowerLabel.text = Std.string(power);
         mLevelRequirement.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + itemInfo.requiredLevel;
         mLevelRequirementNotMet.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + itemInfo.requiredLevel;
         if(mHeroEquipPicker == null || mHeroEquipPicker.currentlySelectedHero == null)
         {
            currentlySelectedAvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         }
         else
         {
            currentlySelectedAvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroEquipPicker.currentlySelectedHero.Id);
         }
         canEquip = (1 : UInt);
         if(currentlySelectedAvatarInfo != null && currentlySelectedAvatarInfo.level >= itemInfo.requiredLevel)
         {
            mLevelRequirement.visible = true;
            mLevelRequirementNotMet.visible = false;
         }
         else
         {
            mLevelRequirement.visible = false;
            mLevelRequirementNotMet.visible = true;
            canEquip = (2 : UInt);
         }
         if(currentlySelectedAvatarInfo != null && mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(currentlySelectedAvatarInfo,gmWeaponItem.MasterType))
         {
            mWeaponTypeUnequippableLabel.visible = false;
            mWeaponTypeLabel.visible = true;
         }
         else
         {
            mWeaponTypeUnequippableLabel.visible = true;
            mWeaponTypeLabel.visible = false;
            canEquip = (3 : UInt);
         }
         mEquipButton.enabled = equipped ? true : canEquip == 1;
         switch(canEquip - 1)
         {
            case 0:
               ASCompat.setProperty((mRoot : ASAny).unequippable, "visible", false);
               this.mDescription.text = mInfo.Description;
               this.greyOffer(false);
               
            case 1:
               ASCompat.setProperty((mRoot : ASAny).unequippable, "visible", true);
               this.mDescription.text = Locale.getString("ITEM_CARD_UNUSABLE_LEVEL");
               this.greyOffer(true);
               
            case 2:
               ASCompat.setProperty((mRoot : ASAny).unequippable, "visible", true);
               this.mDescription.text = Locale.getString("ITEM_CARD_UNUSABLE_MASTERCLASS");
               this.greyOffer(true);
         }
         mModifierTitle.visible = true;
         mModifierTitle.text = Locale.getString("MODIFIERS");
         preNameModifiers = "";
         modifierList = itemInfo.modifiers;
         i = 0;
         while(i < modifierList.length)
         {
            mModifiersList.push(new UIModifier(mDBFacade,ASCompat.dynamicAs(cast((mRoot : ASAny).ability, flash.display.DisplayObjectContainer).getChildByName("modifier_icon_" + Std.string((i + 1))) , MovieClip),modifierList[i].Constant));
            preNameModifiers += modifierList[i].Name.toUpperCase() + " ";
            i = i + 1;
         }
         weaponName = preNameModifiers + mLabel.text;
         if(itemInfo.legendaryModifier > 0)
         {
            mModifiersList.push(new UIModifier(mDBFacade,ASCompat.dynamicAs(cast((mRoot : ASAny).ability, flash.display.DisplayObjectContainer).getChildByName("modifier_icon_3") , MovieClip),"",(0 : UInt),true,itemInfo.legendaryModifier));
            weaponName = gmWeaponItem.getWeaponAesthetic((0 : UInt),true).Name;
         }
         format = new TextFormat();
         sizeMult = 0.1;
         if(weaponName.length <= 34)
         {
            format.size = 13;
            sizeMult = weaponName.length < 17 ? 0.2 : 0.1;
            mLabel.y = mTitleY + mLabel.height * sizeMult;
         }
         else
         {
            format.size = 12;
            mLabel.y = mTitleY;
         }
         if(weaponName.indexOf("VINTAGE") >= 0)
         {
            mSellButton.visible = false;
            mEquipButton.root.x = mOriginalPosForEquipButton.x - 60;
            mEquipButton.root.y = mOriginalPosForEquipButton.y - 10;
         }
         mLabel.defaultTextFormat = format;
         mLabel.text = weaponName;
         mLabel.text = mLabel.text.toUpperCase();
      }
      
      function clearModifiers() 
      {
         var _loc1_:UIModifier;
         var __ax4_iter_13:Vector<UIModifier>;
         if(mModifiersList.length > 0)
         {
            __ax4_iter_13 = mModifiersList;
            if (checkNullIteratee(__ax4_iter_13)) for (_tmp_ in __ax4_iter_13)
            {
               _loc1_ = _tmp_;
               _loc1_.destroy();
            }
            mModifiersList.splice(0,(mModifiersList.length : UInt));
         }
      }
      
      function greyOffer(param1:Bool) 
      {
         var _loc4_= Vector.ofArray(([ASCompat.dynamicAs((mRoot : ASAny).bg, flash.display.DisplayObject),ASCompat.dynamicAs((mRoot : ASAny).icon_slot, flash.display.DisplayObject),ASCompat.dynamicAs((mRoot : ASAny).ribbon, flash.display.DisplayObject),mHoldIcon.root,mTapIcon.root,mPowerIcon,mItemParent.root,ASCompat.dynamicAs((mRoot : ASAny).unequippable, flash.display.DisplayObject),ASCompat.dynamicAs((mRoot : ASAny).ability.modifier_icon_1, flash.display.DisplayObject),ASCompat.dynamicAs((mRoot : ASAny).ability.modifier_icon_2, flash.display.DisplayObject),ASCompat.dynamicAs((mRoot : ASAny).ability.modifier_icon_3, flash.display.DisplayObject)] : Array<DisplayObject>));
         var _loc2_= SceneGraphManager.getGrayScaleSaturationFilter(5);
         var _loc3_:DisplayObject;
         if (checkNullIteratee(_loc4_)) for (_tmp_ in _loc4_)
         {
            _loc3_ = _tmp_;
            if(_loc3_ != null)
            {
               ASCompat.setProperty(_loc3_, "filters", param1 ? [_loc2_] : []);
            }
         }
         mLabel.textColor = (ASCompat.toInt(param1 ? (8947848 : UInt) : mInfo.getTextColor()) : UInt);
      }
      
      public function buttonsVisible(param1:Bool) 
      {
         mEquipButton.visible = param1;
         mSellButton.visible = param1;
      }
      
      function setupWeaponItemInfoUI(param1:ItemInfo) 
      {
         var itemInfo= param1;
         mEquipButton.enabled = false;
         mEquipButton.visible = false;
         if(itemInfo.avatarId == 0)
         {
            mEquipButton.visible = true;
            mEquipButton.releaseCallback = loadEquipOnAvatarPopup;
            mEquipButton.label.text = Locale.getString("ITEM_CARD_EQUIP");
         }
         else if(mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage())
         {
            mEquipButton.visible = true;
            mEquipButton.enabled = true;
            mEquipButton.releaseCallback = function()
            {
               if(Std.isOfType(mInfo , ItemInfo))
               {
                  mDBFacade.dbAccountInfo.inventoryInfo.unequipItemOffAvatar(ASCompat.reinterpretAs(mInfo , ItemInfo),mRefreshInventoryCallback);
               }
               else
               {
                  if(!Std.isOfType(mInfo , PetInfo))
                  {
                     Logger.error("Item id: " + mInfo.databaseId + " being unequipped is not an ItemInfo.");
                     return;
                  }
                  mDBFacade.dbAccountInfo.inventoryInfo.unequipPet(ASCompat.reinterpretAs(mInfo , PetInfo),mRefreshInventoryCallback);
               }
            };
            mEquipButton.label.text = Locale.getString("ITEM_CARD_UNEQUIP");
         }
      }
      
      function unEquipConsumable(param1:StackableInfo, param2:ASFunction) 
      {
         var _loc3_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroEquipPicker.currentlySelectedHero.Id);
         if(_loc3_ == null)
         {
            Logger.error("No avatar info found for currently selected hero type: " + mHeroEquipPicker.currentlySelectedHero.Id);
            return;
         }
         mDBFacade.dbAccountInfo.inventoryInfo.unequipConsumableOffAvatar(_loc3_.id,param1.gmStackable.Id,(param1.equipSlot : UInt),param2);
      }
      
      function setupStackableItemInfoUI(param1:StackableInfo) 
      {
         var itemInfo= param1;
         mEquipButton.enabled = false;
         mEquipButton.visible = false;
         if(itemInfo.gmId == 60001 || itemInfo.gmId == 60018)
         {
            return;
         }
         if(itemInfo.gmStackable.AccountBooster)
         {
            mEquipButton.visible = true;
            mEquipButton.releaseCallback = tryActivateAccountBooster;
            mEquipButton.label.text = Locale.getString("ITEM_CARD_USE");
         }
         else if(ASCompat.toNumberField(itemInfo, "isEquipped") == 0)
         {
            mEquipButton.visible = true;
            mEquipButton.releaseCallback = function()
            {
               loadEquipOnAvatarPopup(true);
            };
            mEquipButton.label.text = Locale.getString("ITEM_CARD_EQUIP");
         }
         else
         {
            mEquipButton.visible = true;
            mEquipButton.enabled = true;
            mEquipButton.releaseCallback = function()
            {
               if(Std.isOfType(mInfo , StackableInfo))
               {
                  unEquipConsumable(ASCompat.reinterpretAs(mInfo , StackableInfo),mRefreshInventoryCallback);
                  return;
               }
               Logger.error("Item id: " + mInfo.databaseId + " being unequipped is not an ItemInfo.");
            };
            mEquipButton.label.text = Locale.getString("ITEM_CARD_UNEQUIP");
         }
      }
      
      function loadIcon() 
      {
         var swfPath= mInfo.uiSwfFilepath;
         var iconName= mInfo.iconName;
         while(mItemParent.root.numChildren > 0)
         {
            mItemParent.root.removeChildAt(0);
         }
         ItemInfo.loadItemIcon(swfPath,iconName,mItemParent.root,mDBFacade,(70 : UInt),(Std.int(mInfo.iconScale) : UInt),mAssetLoadingComponent,function()
         {
            var bgColoredExists= mInfo.hasColoredBackground;
            var bgSwfPath= mInfo.backgroundSwfPath;
            var bgIconName= mInfo.backgroundIconName;
            var bgIconBorderName= mInfo.backgroundIconBorderName;
            if(bgColoredExists)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc2_:MovieClip = null;
                  var _loc4_:MovieClip = null;
                  var _loc5_= param1.getClass(bgIconBorderName);
                  if(_loc5_ != null)
                  {
                     _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []) , MovieClip);
                     mItemParent.root.addChildAt(_loc2_,0);
                  }
                  var _loc3_= param1.getClass(bgIconName);
                  if(_loc3_ != null)
                  {
                     _loc4_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []) , MovieClip);
                     mItemParent.root.addChildAt(_loc4_,1);
                  }
               });
            }
         });
      }
      
      function loadItemType(param1:GMWeaponItem) 
      {
         var _loc3_:String = null;
         var _loc2_:GMWeaponMastertype = null;
         if(param1 != null)
         {
            _loc3_ = param1.MasterType;
            _loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponSubtypeByConstant.itemFor(_loc3_), gameMasterDictionary.GMWeaponMastertype);
            if(_loc2_ != null)
            {
               mWeaponTypeLabel.visible = true;
               mWeaponTypeUnequippableLabel.visible = true;
               mWeaponTypeLabel.text = param1.Name.toUpperCase();
               mWeaponTypeUnequippableLabel.text = param1.Name.toUpperCase();
            }
            else
            {
               mWeaponTypeLabel.visible = false;
               mWeaponTypeUnequippableLabel.visible = false;
               Logger.error("Weapon master type not found: " + _loc3_);
            }
         }
      }
      
      public function loadEquipOnAvatarPopup(param1:Bool = false) 
      {
         if(mEquipPopup != null)
         {
            mEquipPopup.destroy();
         }
         var _loc4_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroEquipPicker.currentlySelectedHero.Id);
         if(_loc4_ == null)
         {
            Logger.error("No avatar info found for currently selected hero type: " + mHeroEquipPicker.currentlySelectedHero.Id);
            return;
         }
         var _loc2_= ASCompat.reinterpretAs(mInfo , ItemInfo);
         var _loc3_= ASCompat.reinterpretAs(mInfo , StackableInfo);
         if(_loc2_ == null && _loc3_ == null)
         {
            if(_loc3_ == null)
            {
               Logger.error("Current stackable info on ItemInfoCard is not an ItemInfo.  info databaseId: " + _loc3_.databaseId);
               return;
            }
            Logger.error("Current item info on ItemInfoCard is not an ItemInfo.  info databaseId: " + mInfo.databaseId);
            return;
         }
         mEquipPopup = new EquipItemToSlotPopup(mDBFacade,(_loc4_.id : Int),closeEquipCallback,ASCompat.dynamicAs(param1 ? _loc3_ : _loc2_, account.InventoryBaseInfo),null,param1);
         MemoryTracker.track(mEquipPopup,"EquipItemToSlotPopup - created in ItemInfoCard.loadEquipOnAvatarPopup()");
      }
      
      public function tryActivateAccountBooster() 
      {
         var _loc1_= ASCompat.reinterpretAs(mInfo , StackableInfo);
         StoreServicesController.useAccountBooster(mDBFacade,_loc1_);
      }
      
      public function loadEquipOnAccountPopup() 
      {
         if(mEquipPopup != null)
         {
            mEquipPopup.destroy();
         }
         var _loc1_= ASCompat.reinterpretAs(mInfo , StackableInfo);
         if(_loc1_ == null)
         {
            Logger.error("Current item info on ItemInfoCard is not an StackableInfo.  info databaseId: " + mInfo.databaseId);
            return;
         }
         mEquipPopup = new EquipItemToSlotPopup(mDBFacade,-1,closeEquipCallback,_loc1_,clear);
         MemoryTracker.track(mEquipPopup,"EquipItemToSlotPopup - created in ItemInfoCard.loadEquipOnAccountPopup()");
      }
      
      function closeEquipCallback() 
      {
         if(mEquipPopup != null)
         {
            mEquipPopup.destroy();
            mEquipPopup = null;
         }
      }
   }


