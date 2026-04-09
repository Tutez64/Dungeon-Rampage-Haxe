package uI.inventory.chests
;
   import account.ItemInfo;
   import account.StoreServices;
   import actor.Revealer;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderer;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.sound.SoundAsset;
   import brain.sound.SoundHandle;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.workLoop.LogicalWorkComponent;
   import facade.DBFacade;
   import facade.Locale;
   import facebookAPI.DBFacebookBragFeedPost;
   import gameMasterDictionary.GMAttack;
   import gameMasterDictionary.GMChest;
   import gameMasterDictionary.GMModifier;
   import gameMasterDictionary.GMNpc;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMOfferDetail;
   import gameMasterDictionary.GMRarity;
   import gameMasterDictionary.GMStackable;
   import gameMasterDictionary.GMWeaponAesthetic;
   import gameMasterDictionary.GMWeaponItem;
   import gameMasterDictionary.GMWeaponMastertype;
   import sound.DBSoundComponent;
   import uI.DBUIPopup;
   import uI.inventory.UITapHoldTooltip;
   import uI.modifiers.UIModifier;
   import uI.UIHud;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import org.as3commons.collections.framework.IMapIterator;
   
    class ChestRevealPopUp
   {
      
      public static inline final popUpName= "reveal_chest_popup";
      
      public static inline final SLOT_MACHINE_ANIMATION_WEAPON_NAME= "reveal_chest_slotMachine";
      
      public static inline final SLOT_MACHINE_ANIMATION_CONSUMABLE_NAME= "reveal_itemBox_slotMachine";
      
      public static inline final weaponMCName= "reveal_chest_weapon_total";
      
      public static inline final REVEALED_ITEM_WEAPON= (1 : UInt);
      
      public static inline final REVEALED_ITEM_STACKABLE= (2 : UInt);
      
      public static inline final REVEALED_ITEM_PET= (3 : UInt);
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mChestGM:GMChest;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mSoundComponent:DBSoundComponent;
      
      var mPopUpMC:MovieClip;
      
      var mAnimationMC:MovieClip;
      
      var mSlotMachineAnimationMC:MovieClip;
      
      var mItemMC:MovieClip;
      
      var mChestRenderer:MovieClipRenderer;
      
      var mSlotMachineRenderer:MovieClipRenderer;
      
      var mItemRenderer:MovieClipRenderer;
      
      var mWeaponTextField:TextField;
      
      var mCloseButton:UIButton;
      
      var mItemName:String;
      
      var mItemFeedPostImagePath:String;
      
      var mItemDesc:String;
      
      var mRevealedItemIcon:MovieClip;
      
      var mWeaponRevealer:Revealer;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mItemOfferId:UInt = 0;
      
      var mCloseCallback:ASFunction;
      
      var mWaitForWeaponFromServerPopUp:DBUIPopup;
      
      var mUpdateToInventoryDone:Bool = false;
      
      var mItemType:UInt = 0;
      
      var mRevealedItemId:UInt = 0;
      
      var mRevealedItemLevel:UInt = 0;
      
      var mRevealedGMOffer:GMOffer;
      
      var mRevealedGMWeapon:GMWeaponItem;
      
      var mRevealedItemInfo:ItemInfo;
      
      var mModifiersList:Vector<UIModifier>;
      
      var mGoToStorageCallback:ASFunction;
      
      var mItemInfoCardMC:MovieClip;
      
      var mItemInfoCardSellButton:UIButton;
      
      var mItemInfoCardStoreButton:UIButton;
      
      var mItemInfoCardEquipButton:UIButton;
      
      var mTapIcon:UIObject;
      
      var mTapTooltip:UITapHoldTooltip;
      
      var mHoldIcon:UIObject;
      
      var mHoldTooltip:UITapHoldTooltip;
      
      var mSound1:SoundAsset;
      
      var mSound2:SoundAsset;
      
      var mSound2Handle:SoundHandle;
      
      var mSound3:SoundAsset;
      
      var mSound4:SoundAsset;
      
      var mChestOpenSfx:SoundAsset;
      
      var mNewWeaponDBID:Float = Math.NaN;
      
      public function new(param1:DBFacade, param2:GMChest, param3:ASFunction, param4:ASFunction)
      {
         
         mDBFacade = param1;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mChestGM = param2;
         mCloseCallback = param3;
         mGoToStorageCallback = param4;
         mSoundComponent = new DBSoundComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mItemOfferId = (0 : UInt);
         mUpdateToInventoryDone = false;
         mNewWeaponDBID = 0;
         mModifiersList = new Vector<UIModifier>();
         loadUI();
      }
      
      public function loadUI() 
      {
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"guitar_wank07",function(param1:SoundAsset)
         {
            mSound1 = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"guitar_wank18",function(param1:SoundAsset)
         {
            mSound2 = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"guitar_wank21",function(param1:SoundAsset)
         {
            mSound3 = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"guitar_wank26",function(param1:SoundAsset)
         {
            mSound4 = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"chestKeyOpen",function(param1:SoundAsset)
         {
            mChestOpenSfx = param1;
         });
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mChestGM.InventoryRevealSwf),setupUI);
      }
      
      function setupUI(param1:SwfAsset) 
      {
         var bounds:Rectangle;
         var rarity:GMRarity;
         var openAnimation:Dynamic;
         var slotMachineAnimation:Dynamic;
         var weaponClass:Dynamic;
         var itemInfoCardSwfClass:Dynamic;
         var swfAsset= param1;
         var backgroundSwfClass= swfAsset.getClass("reveal_chest_popup");
         mPopUpMC = ASCompat.dynamicAs(ASCompat.createInstance(backgroundSwfClass, []) , MovieClip);
         mPopUpMC.scaleX = mPopUpMC.scaleY = 1.8;
         bounds = mPopUpMC.getBounds(mDBFacade.stageRef);
         mPopUpMC.x = mDBFacade.stageRef.stageWidth / 2 - bounds.width / 2 - bounds.x;
         mPopUpMC.y = mDBFacade.stageRef.stageHeight / 2 - bounds.height / 2 - bounds.y;
         ASCompat.setProperty((mPopUpMC : ASAny).title_label, "text", mChestGM.Name);
         rarity = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(mChestGM.Rarity), gameMasterDictionary.GMRarity);
         if(rarity != null && rarity.TextColor != 0)
         {
            ASCompat.setProperty((mPopUpMC : ASAny).title_label, "textColor", rarity.TextColor);
         }
         openAnimation = swfAsset.getClass(mChestGM.InventoryRevealName);
         mAnimationMC = ASCompat.dynamicAs(ASCompat.createInstance(openAnimation, []) , MovieClip);
         slotMachineAnimation = swfAsset.getClass(UIHud.isThisAConsumbleChestId((mChestGM.Id : Int)) ? "reveal_itemBox_slotMachine" : "reveal_chest_slotMachine");
         mSlotMachineAnimationMC = ASCompat.dynamicAs(ASCompat.createInstance(slotMachineAnimation, []) , MovieClip);
         weaponClass = swfAsset.getClass("reveal_chest_weapon_total");
         mItemMC = ASCompat.dynamicAs(ASCompat.createInstance(weaponClass, []) , MovieClip);
         mWeaponTextField = ASCompat.dynamicAs((mItemMC : ASAny).reveal_chest_weaponTextField, flash.text.TextField);
         if(ASCompat.toBool((mSlotMachineAnimationMC : ASAny).reveal_chest_forgeTextField))
         {
            ASCompat.setProperty((mSlotMachineAnimationMC : ASAny).reveal_chest_forgeTextField, "visible", false);
         }
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopUpMC : ASAny).close, flash.display.MovieClip));
         mCloseButton.visible = false;
         mCloseButton.enabled = false;
         mCloseButton.releaseCallback = preCloseCallback;
         itemInfoCardSwfClass = swfAsset.getClass("item_card");
         mItemInfoCardMC = ASCompat.dynamicAs(ASCompat.createInstance(itemInfoCardSwfClass, []) , MovieClip);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset)
         {
            var _loc2_= param1.getClass("DR_charge_tooltip");
            mTapIcon = new UIObject(mDBFacade,ASCompat.dynamicAs((mItemInfoCardMC : ASAny).ability.tap_icon, flash.display.MovieClip));
            mTapTooltip = new UITapHoldTooltip(mDBFacade,_loc2_);
            mTapIcon.tooltip = mTapTooltip;
            mTapIcon.tooltipPos = new Point(0,mTapIcon.root.height * 0.5);
            mTapTooltip.visible = false;
            mHoldIcon = new UIObject(mDBFacade,ASCompat.dynamicAs((mItemInfoCardMC : ASAny).ability.icon, flash.display.MovieClip));
            mHoldTooltip = new UITapHoldTooltip(mDBFacade,_loc2_);
            mHoldIcon.tooltip = mHoldTooltip;
            mHoldIcon.tooltipPos = new Point(0,mHoldIcon.root.height * 0.5);
            mHoldTooltip.visible = false;
         });
         mPopUpMC.addChild(mItemInfoCardMC);
         mItemInfoCardMC.visible = false;
         mSceneGraphComponent.showPopupCurtain();
         mSceneGraphComponent.addChild(mPopUpMC,(105 : UInt));
         revealChest();
      }
      
      function revealChest() 
      {
         var startRevealTime:Float;
         (mPopUpMC : ASAny).reveal_chest_slot.addChild(mAnimationMC);
         mChestRenderer = new MovieClipRenderer(mDBFacade,mAnimationMC);
         mChestRenderer.play((0 : UInt),false);
         mLogicalWorkComponent.doLater(1.25,function(param1:GameClock)
         {
            if(mChestOpenSfx != null)
            {
               mSoundComponent.playSfxOneShot(mChestOpenSfx);
            }
         });
         startRevealTime = UIHud.isThisAConsumbleChestId((mChestGM.Id : Int)) ? 0.125 : 2.2916666666666665;
         mLogicalWorkComponent.doLater(startRevealTime,revealSlotMachine);
      }
      
      function revealSlotMachine(param1:GameClock = null) 
      {
         (mPopUpMC : ASAny).reveal_chest_slot.removeChild(mAnimationMC);
         mChestRenderer.destroy();
         mChestRenderer = null;
         if(mSound2 != null)
         {
            mSound2Handle = mSoundComponent.playSfxManaged(mSound2);
            mSound2Handle.play(10);
         }
         (mPopUpMC : ASAny).reveal_chest_slot.addChild(mSlotMachineAnimationMC);
         mSlotMachineRenderer = new MovieClipRenderer(mDBFacade,mSlotMachineAnimationMC);
         mSlotMachineRenderer.play((0 : UInt),true);
         mLogicalWorkComponent.doLater(UIHud.isThisAConsumbleChestId((mChestGM.Id : Int)) ? 1.375 : 2,startCheckForRevealWeapon);
      }
      
      public function updateRevealLoot(param1:ASAny) 
      {
         var __ax4_iter_92:Vector<GMOfferDetail>;
         var offerId:UInt = 0;
         var weaponId:UInt = 0;
         var swfPath:String = null;
         var iconClass:String = null;
         var name:String = null;
         var offerDetail:GMOfferDetail;
         var gmStackable:GMStackable;
         var gmPet:GMNpc;
         var aesthetic:GMWeaponAesthetic;
         var details:ASAny = param1;
         var unlockMetricsDetails:ASObject = {};
         ASCompat.setProperty(unlockMetricsDetails, "isWeapon", false);
         mNewWeaponDBID = 0;
         if(details.hasOwnProperty("NewWeaponDetails"))
         {
            if(details.NewWeaponDetails != null)
            {
               mNewWeaponDBID = ASCompat.toNumberField(details.NewWeaponDetails, "id");
               ASCompat.setProperty(unlockMetricsDetails, "isWeapon", true);
            }
            offerId = ASCompat.asUint(details.OfferId );
            weaponId = ASCompat.asUint(details.WeaponId );
         }
         else if(details.hasOwnProperty("customResult"))
         {
            if(details.customResult.hasOwnProperty("purchasedChestResults"))
            {
               if(details.customResult.purchasedChestResults.NewWeaponDetails != null)
               {
                  mNewWeaponDBID = ASCompat.toNumberField(details.customResult.purchasedChestResults.NewWeaponDetails, "id");
                  ASCompat.setProperty(unlockMetricsDetails, "isWeapon", true);
               }
               offerId = ASCompat.asUint(details.customResult.purchasedChestResults.OfferId );
               weaponId = ASCompat.asUint(details.customResult.purchasedChestResults.WeaponId );
            }
         }
         mRevealedGMOffer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(offerId), gameMasterDictionary.GMOffer);
         if(mRevealedGMOffer == null)
         {
            mRevealedItemInfo = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.items.itemFor(weaponId), account.ItemInfo);
            if(mRevealedItemInfo == null)
            {
               Logger.warn("Can\'t find gmOffer or itemInfo for loot with offerId: " + Std.string(offerId) + " and weaponId: " + Std.string(weaponId));
               return;
            }
            ASCompat.setProperty(unlockMetricsDetails, "lootLevel", mRevealedItemInfo.requiredLevel);
            ASCompat.setProperty(unlockMetricsDetails, "lootPower", mRevealedItemInfo.power);
            if(mRevealedItemInfo.modifiers.length > 0)
            {
               ASCompat.setProperty(unlockMetricsDetails, "lootMod1", mRevealedItemInfo.modifiers[0].Constant);
            }
            if(mRevealedItemInfo.modifiers.length > 1)
            {
               ASCompat.setProperty(unlockMetricsDetails, "lootMod2", mRevealedItemInfo.modifiers[1].Constant);
            }
            if(mRevealedItemInfo.legendaryModifier > 0)
            {
               ASCompat.setProperty(unlockMetricsDetails, "legendaryModifier", mRevealedItemInfo.legendaryModifier);
            }
            mRevealedGMWeapon = mRevealedItemInfo.gmWeaponItem;
            mItemType = (1 : UInt);
            mItemOfferId = mRevealedGMWeapon.Id;
         }
         else
         {
            mItemType = (2 : UInt);
            mItemOfferId = mRevealedGMOffer.Id;
         }
         if(mItemType == 2)
         {
            if(mRevealedGMOffer.IsBundle)
            {
               swfPath = mRevealedGMOffer.BundleSwfFilepath;
               iconClass = mRevealedGMOffer.BundleIcon;
               name = mRevealedGMOffer.BundleName;
               mItemType = (2 : UInt);
               mRevealedItemId = offerId;
            }
            else if(mRevealedGMOffer.Details != null && mRevealedGMOffer.Details.length > 0)
            {
               __ax4_iter_92 = mRevealedGMOffer.Details;
               if (checkNullIteratee(__ax4_iter_92)) for (_tmp_ in __ax4_iter_92)
               {
                  offerDetail  = _tmp_;
                  if(offerDetail.StackableId != 0)
                  {
                     gmStackable = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(offerDetail.StackableId), gameMasterDictionary.GMStackable);
                     swfPath = gmStackable.UISwfFilepath;
                     iconClass = gmStackable.IconName;
                     name = gmStackable.Name;
                     mItemType = (2 : UInt);
                     mRevealedItemId = offerDetail.StackableId;
                  }
                  else if(offerDetail.PetId != 0)
                  {
                     gmPet = ASCompat.dynamicAs(mDBFacade.gameMaster.npcById.itemFor(offerDetail.PetId), gameMasterDictionary.GMNpc);
                     swfPath = gmPet.IconSwfFilepath;
                     iconClass = gmPet.IconName;
                     name = gmPet.Name;
                     mItemType = (3 : UInt);
                     mRevealedItemId = offerDetail.PetId;
                  }
               }
            }
         }
         else
         {
            mRevealedItemId = mItemOfferId;
            mRevealedItemLevel = mRevealedItemInfo.requiredLevel;
            aesthetic = mRevealedGMWeapon.getWeaponAesthetic(mRevealedItemLevel,mRevealedItemInfo.legendaryModifier > 0);
            swfPath = aesthetic.IconSwf;
            iconClass = aesthetic.IconName;
            name = aesthetic.Name;
            mItemType = (1 : UInt);
         }
         mItemName = name;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset)
         {
            var _loc2_= param1.getClass(iconClass);
            mRevealedItemIcon = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         });
         ASCompat.setProperty(unlockMetricsDetails, "chestId", mChestGM.Id);
         ASCompat.setProperty(unlockMetricsDetails, "rarity", mChestGM.Rarity);
         ASCompat.setProperty(unlockMetricsDetails, "chestName", mChestGM.Name);
         ASCompat.setProperty(unlockMetricsDetails, "lootName", mItemName);
         ASCompat.setProperty(unlockMetricsDetails, "lootId", mRevealedItemId);
         mDBFacade.metrics.log("ChestUnlockResult",unlockMetricsDetails);
      }
      
      function startCheckForRevealWeapon(param1:GameClock = null) 
      {
         mLogicalWorkComponent.doEveryFrame(checkForRevealWeapon);
      }
      
      function checkForRevealWeapon(param1:GameClock = null) 
      {
         if(mItemOfferId > 0)
         {
            revealWeapon();
         }
      }
      
      function revealWeapon() 
      {
         if(mSound2Handle != null)
         {
            mSound2Handle.destroy();
            mSound2Handle = null;
         }
         if(UIHud.isThisAConsumbleChestId((mChestGM.Id : Int)))
         {
            if(mSound4 != null)
            {
               mSoundComponent.playSfxOneShot(mSound4);
            }
         }
         else if(mSound1 != null)
         {
            mSoundComponent.playSfxOneShot(mSound1);
         }
         mLogicalWorkComponent.clear();
         mSlotMachineRenderer.destroy();
         (mPopUpMC : ASAny).reveal_chest_slot.removeChild(mSlotMachineAnimationMC);
         mCloseButton.visible = true;
         mCloseButton.enabled = true;
         mItemInfoCardMC.visible = true;
         mItemRenderer = new MovieClipRenderer(mDBFacade,mItemMC);
         mItemRenderer.play((0 : UInt),false);
         setupRevealedItemUI();
         mUpdateToInventoryDone = true;
      }
      
      function setupRevealedItemUI() 
      {
         var __tmpAssignObj3:ASAny;
         var __tmpAssignObj4:ASAny;
         var __tmpAssignObj5:ASAny;
         var __tmpAssignObj6:ASAny;
         var weaponType:String = null;
         var levelRequirement:String = null;
         var power:String = null;
         var chargeAttack:GMAttack;
         var chargeAttackName:String;
         var gmWeaponItem:GMWeaponItem = null;
         var gmMasterTypeVector:Vector<GMWeaponMastertype>;
         var vi:Int;
         var weaponRequiredLevel:UInt;
         var bgColoredExists:Bool;
         var bgSwfPath:String;
         var bgIconName:String;
         var gmStackable:GMStackable;
         var gmOffer:GMOffer;
         var gmPet:GMNpc;
         var j:UInt;
         var powerStarMC:MovieClip;
         var defenseStarMC:MovieClip;
         var speedStarMC:MovieClip;
         var stagePos:Point;
         var swfPath:String;
         var iconName:String;
         var swfPath1:String;
         var iconName1:String;
         var preNameModifiers:String;
         var modifierList:Vector<GMModifier>;
         var i:Int;
         var format:TextFormat;
         var isWeapon= false;
         var isEquippable= true;
         var typeOfUnequippable= (0 : UInt);
         var currentlySelectedAvatarInfo= mDBFacade.dbAccountInfo.activeAvatarInfo;
         var price= (0 : UInt);
         var isSellable= false;
         ASCompat.setProperty((mItemInfoCardMC : ASAny).number_label, "visible", false);
         if(mItemType == 1)
         {
            ASCompat.setProperty((mItemInfoCardMC : ASAny).ability, "visible", true);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).pet_stats, "visible", false);
            mRevealedItemIcon.scaleX = mRevealedItemIcon.scaleY = 0.5;
            gmWeaponItem = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(mRevealedItemId), gameMasterDictionary.GMWeaponItem);
            mItemDesc = gmWeaponItem.getWeaponAesthetic(mRevealedItemLevel,mRevealedItemInfo.legendaryModifier > 0).Description;
            isWeapon = isSellable = true;
            mItemName = mRevealedItemInfo.Name;
            gmMasterTypeVector = mDBFacade.gameMaster.WeaponMastertypes;
            vi = 0;
            while(vi < gmMasterTypeVector.length)
            {
               if(gmMasterTypeVector[vi].Constant == gmWeaponItem.MasterType)
               {
                  weaponType = gmMasterTypeVector[vi].Name.toUpperCase();
               }
               vi = vi + 1;
            }
            weaponRequiredLevel = mRevealedItemLevel;
            levelRequirement = Locale.getString("REQUIRES_LEVEL") + Std.string(weaponRequiredLevel);
            power = Std.string(mRevealedItemInfo.power);
            if(ASCompat.stringAsBool(gmWeaponItem.ChargeAttack))
            {
               chargeAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(gmWeaponItem.ChargeAttack), gameMasterDictionary.GMAttack);
               if(chargeAttack != null)
               {
                  chargeAttackName = chargeAttack.Name.toUpperCase();
               }
            }
            if(currentlySelectedAvatarInfo != null && currentlySelectedAvatarInfo.level >= weaponRequiredLevel)
            {
               isEquippable = true;
            }
            else
            {
               isEquippable = false;
               typeOfUnequippable = (1 : UInt);
            }
            if(isEquippable)
            {
               if(currentlySelectedAvatarInfo != null && mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(currentlySelectedAvatarInfo,gmWeaponItem.MasterType))
               {
                  isEquippable = true;
               }
               else
               {
                  isEquippable = false;
                  typeOfUnequippable = (2 : UInt);
               }
            }
            bgColoredExists = mRevealedItemInfo.rarity.HasColoredBackground;
            bgSwfPath = mRevealedItemInfo.rarity.BackgroundSwf;
            bgIconName = mRevealedItemInfo.rarity.BackgroundIcon;
            if(bgColoredExists)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset)
               {
                  var _loc3_:MovieClip = null;
                  var _loc2_= param1.getClass(bgIconName);
                  if(_loc2_ != null)
                  {
                     _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
                     (mItemInfoCardMC : ASAny).item_icon.addChildAt(_loc3_,0);
                  }
               });
            }
            price = (mRevealedItemInfo.sellCoins : UInt);
            mItemFeedPostImagePath = "Resources/Art2D/facebook/feedposts/weapons/" + gmWeaponItem.getWeaponAesthetic(mRevealedItemLevel,mRevealedItemInfo.legendaryModifier > 0).IconName + ".png";
         }
         else if(mItemType == 2)
         {
            ASCompat.setProperty((mItemInfoCardMC : ASAny).ability, "visible", false);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).pet_stats, "visible", false);
            __tmpAssignObj3 = (mItemInfoCardMC : ASAny).icon_slot;
            ASCompat.setProperty(__tmpAssignObj3, "x", __tmpAssignObj3.x + 100);
            __tmpAssignObj4 = (mItemInfoCardMC : ASAny).item_icon;
            ASCompat.setProperty(__tmpAssignObj4, "x", __tmpAssignObj4.x + 100);
            __tmpAssignObj5 = (mItemInfoCardMC : ASAny).item_card_frame;
            ASCompat.setProperty(__tmpAssignObj5, "x", __tmpAssignObj5.x + 100);
            mRevealedItemIcon.scaleX = mRevealedItemIcon.scaleY = 0.6;
            gmStackable = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(mRevealedItemId), gameMasterDictionary.GMStackable);
            if(gmStackable == null)
            {
               gmOffer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(mRevealedItemId), gameMasterDictionary.GMOffer);
               mItemDesc = gmOffer.BundleDescription;
               if(gmOffer.Details.length > 0)
               {
                  if(gmOffer.Details[0].StackableId != 0)
                  {
                     ASCompat.setProperty((mItemInfoCardMC : ASAny).number_label, "visible", true);
                     ASCompat.setProperty((mItemInfoCardMC : ASAny).number_label, "text", "x" + Std.string(gmOffer.Details[0].StackableCount));
                     __tmpAssignObj6 = (mItemInfoCardMC : ASAny).number_label;
                     ASCompat.setProperty(__tmpAssignObj6, "x", __tmpAssignObj6.x + 100);
                  }
               }
            }
            else
            {
               mItemDesc = gmStackable.Description;
            }
         }
         else if(mItemType == 3)
         {
            ASCompat.setProperty((mItemInfoCardMC : ASAny).ability, "visible", false);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).pet_stats, "visible", true);
            mRevealedItemIcon.scaleX = mRevealedItemIcon.scaleY = 1;
            gmPet = ASCompat.dynamicAs(mDBFacade.gameMaster.npcById.itemFor(mRevealedItemId), gameMasterDictionary.GMNpc);
            mItemDesc = gmPet.Description;
            j = (1 : UInt);
            while(j <= 5)
            {
               powerStarMC = ASCompat.dynamicAs(cast((mItemInfoCardMC : ASAny).pet_stats.pet_stats_power, flash.display.DisplayObjectContainer).getChildByName("star" + Std.string(j)), flash.display.MovieClip);
               defenseStarMC = ASCompat.dynamicAs(cast((mItemInfoCardMC : ASAny).pet_stats.pet_stats_power, flash.display.DisplayObjectContainer).getChildByName("star" + Std.string(j)), flash.display.MovieClip);
               speedStarMC = ASCompat.dynamicAs(cast((mItemInfoCardMC : ASAny).pet_stats.pet_stats_power, flash.display.DisplayObjectContainer).getChildByName("star" + Std.string(j)), flash.display.MovieClip);
               powerStarMC.visible = gmPet.AttackRating >= j;
               defenseStarMC.visible = gmPet.DefenseRating >= j;
               speedStarMC.visible = gmPet.SpeedRating >= j;
               j = j + 1;
            }
         }
         (mItemInfoCardMC : ASAny).item_icon.addChildAt(mRevealedItemIcon,1);
         ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label_unequippable, "visible", false);
         ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label, "visible", false);
         ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement_not_met, "visible", false);
         ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement, "visible", false);
         if(isWeapon)
         {
            ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label_unequippable, "visible", typeOfUnequippable == 2);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label, "visible", typeOfUnequippable != 2);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement_not_met, "visible", typeOfUnequippable == 1);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement, "visible", typeOfUnequippable != 1);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label, "text", weaponType);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement, "text", levelRequirement);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label_unequippable, "text", weaponType);
            ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement_not_met, "text", levelRequirement);
         }
         switch(typeOfUnequippable)
         {
            case 0:
               ASCompat.setProperty((mItemInfoCardMC : ASAny).description, "text", mItemDesc);
               
            case 1:
               ASCompat.setProperty((mItemInfoCardMC : ASAny).description, "text", Locale.getString("ITEM_CARD_UNUSABLE_LEVEL"));
               
            case 2:
               ASCompat.setProperty((mItemInfoCardMC : ASAny).description, "text", Locale.getString("ITEM_CARD_UNUSABLE_MASTERCLASS"));
         }
         ASCompat.setProperty((mItemInfoCardMC : ASAny).ability.label_tap, "text", Locale.getString("TAP"));
         ASCompat.setProperty((mItemInfoCardMC : ASAny).ability.label, "text", Locale.getString("HOLD"));
         if(isWeapon)
         {
            ASCompat.setProperty((mPopUpMC : ASAny).title_label, "textColor", mRevealedItemInfo.getTextColor());
            ASCompat.setProperty((mItemInfoCardMC : ASAny).description, "textColor", mRevealedItemInfo.getTextColor());
            if(ASCompat.stringAsBool(gmWeaponItem.TapIcon) && gmWeaponItem.TapIcon != "")
            {
               mTapIcon.visible = true;
               swfPath = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
               iconName = gmWeaponItem.TapIcon;
               if(ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName))
               {
                  mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset)
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
                        stagePos.y += mTapIcon.root.height * 0.5;
                        mTapIcon.tooltipPos = stagePos;
                     }
                  });
               }
            }
            if(ASCompat.stringAsBool(gmWeaponItem.HoldIcon) && gmWeaponItem.HoldIcon != "")
            {
               mHoldIcon.visible = true;
               swfPath1 = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
               iconName1 = gmWeaponItem.HoldIcon;
               if(ASCompat.stringAsBool(swfPath1) && ASCompat.stringAsBool(iconName1))
               {
                  mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath1),function(param1:SwfAsset)
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
         }
         if(isWeapon)
         {
            ASCompat.setProperty((mItemInfoCardMC : ASAny).power.attack_label, "text", Locale.getString("POWER"));
            ASCompat.setProperty((mItemInfoCardMC : ASAny).power.label, "text", power);
         }
         else
         {
            ASCompat.setProperty((mItemInfoCardMC : ASAny).power, "visible", false);
         }
         ASCompat.setProperty((mItemInfoCardMC : ASAny).unequippable, "visible", !isEquippable);
         mItemInfoCardSellButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mItemInfoCardMC : ASAny).sell, flash.display.MovieClip));
         mItemInfoCardSellButton.label.text = Locale.getString("ITEM_CARD_SELL");
         mItemInfoCardSellButton.visible = isSellable;
         mItemInfoCardSellButton.enabled = isSellable;
         if(isSellable)
         {
            ASCompat.setProperty((mItemInfoCardMC : ASAny).sell.sell_text, "text", Std.string(price));
         }
         mItemInfoCardSellButton.releaseCallback = sellRevealedItem;
         mItemInfoCardStoreButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mItemInfoCardMC : ASAny).store, flash.display.MovieClip));
         mItemInfoCardStoreButton.label.text = Locale.getString("KEEP");
         mItemInfoCardStoreButton.releaseCallback = preCloseCallback;
         mItemInfoCardEquipButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mItemInfoCardMC : ASAny).equip, flash.display.MovieClip));
         mItemInfoCardEquipButton.label.text = Locale.getString("ITEM_CARD_EQUIP");
         if(isEquippable)
         {
            mItemInfoCardEquipButton.releaseCallback = goToStorage;
         }
         else
         {
            mItemInfoCardEquipButton.releaseCallback = function()
            {
               goToStorage(false);
            };
         }
         mItemInfoCardEquipButton.visible = isWeapon;
         mItemInfoCardEquipButton.enabled = isWeapon && isEquippable;
         if(isWeapon)
         {
            preNameModifiers = "";
            modifierList = mRevealedItemInfo.modifiers;
            ASCompat.setProperty((mItemInfoCardMC : ASAny).ability.label_modifier, "text", Locale.getString("MODIFIERS"));
            i = 0;
            while(i < modifierList.length)
            {
               mModifiersList.push(new UIModifier(mDBFacade,ASCompat.dynamicAs(cast((mItemInfoCardMC : ASAny).ability, flash.display.DisplayObjectContainer).getChildByName("modifier_icon_" + Std.string((i + 1))) , MovieClip),modifierList[i].Constant));
               preNameModifiers += modifierList[i].Name + " ";
               i = i + 1;
            }
            mItemName = preNameModifiers + mItemName;
            if(mRevealedItemInfo.legendaryModifier > 0)
            {
               mModifiersList.push(new UIModifier(mDBFacade,ASCompat.dynamicAs(cast((mItemInfoCardMC : ASAny).ability, flash.display.DisplayObjectContainer).getChildByName("modifier_icon_3") , MovieClip),"",(0 : UInt),true,mRevealedItemInfo.legendaryModifier));
               mItemName = mRevealedItemInfo.gmWeaponItem.getWeaponAesthetic((0 : UInt),true).Name;
            }
         }
         format = new TextFormat();
         if(mItemName.length <= 32)
         {
            format.size = 18;
         }
         else
         {
            format.size = 11;
         }
         ASCompat.setProperty((mPopUpMC : ASAny).title_label, "defaultTextFormat", format);
         ASCompat.setProperty((mPopUpMC : ASAny).title_label, "text", mItemName.toUpperCase());
      }
      
      function sellRevealedItem() 
      {
         var _loc1_:GMWeaponItem = null;
         var _loc3_:Float = 0;
         var _loc2_:IMapIterator = null;
         var _loc4_:ItemInfo = null;
         if(mItemType == 1)
         {
            _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(mRevealedItemId), gameMasterDictionary.GMWeaponItem);
            _loc3_ = mNewWeaponDBID;
            if(_loc3_ == 0)
            {
               Logger.error(" sellRevealedItem  had to find a weapon .. arg  Somethign is rong ");
               _loc2_ = ASCompat.reinterpretAs(mDBFacade.dbAccountInfo.inventoryInfo.items.iterator() , IMapIterator);
               while(_loc2_.hasNext() && _loc3_ == 0)
               {
                  _loc2_.next();
                  _loc4_ = ASCompat.dynamicAs(_loc2_.current , ItemInfo);
                  if(_loc4_.gmWeaponItem.Id == _loc1_.Id)
                  {
                     _loc3_ = _loc4_.databaseId;
                     break;
                  }
               }
            }
            else
            {
               Logger.info("sellRevealedItem  Selling Weapon id :" + Std.string(_loc3_));
            }
            StoreServices.sellWeapon(mDBFacade,(Std.int(_loc3_) : UInt),sellSuccessFunction,sellFailureFunction);
         }
         mItemInfoCardSellButton.enabled = false;
      }
      
      function sellSuccessFunction(param1:ASAny) 
      {
         preCloseCallback(false);
      }
      
      function sellFailureFunction(param1:Error) 
      {
         Logger.error("Trying to sell revealed item but failed");
      }
      
      function chestRevealFeedPost() 
      {
         var _loc2_:String = null;
         var _loc1_:String = null;
         var _loc4_:GMOffer = null;
         var _loc3_= (Std.int(mDBFacade.dbConfigManager.getConfigNumber("min_feedpost_weapon_rarity",2)) : UInt);
         if(mItemType == 1 && mRevealedItemInfo.rarity.Id >= _loc3_)
         {
            _loc2_ = mRevealedItemInfo.gmWeaponAesthetic.Name;
            _loc1_ = mItemName;
            _loc1_ += ", Power " + Std.string(mRevealedItemInfo.power);
            _loc1_ += ", " + Locale.getString(mRevealedItemInfo.rarity.Constant) + "!";
            DBFacebookBragFeedPost.openChestBrag(mDBFacade,_loc2_,_loc1_,mRevealedItemIcon,mItemFeedPostImagePath,mItemType,mAssetLoadingComponent);
         }
         else if(mItemType == 2)
         {
            _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.offerByStackableId.itemFor(mRevealedItemId), gameMasterDictionary.GMOffer);
            if(_loc4_ != null)
            {
               if(_loc4_.IsBundle && _loc4_.Details[0].Gems > 0)
               {
                  DBFacebookBragFeedPost.openChestBrag(mDBFacade,mItemName,mItemName,mRevealedItemIcon,"",_loc4_.Id,mAssetLoadingComponent);
               }
            }
         }
      }
      
      function preCloseCallback(param1:Bool = false) 
      {
         mUpdateToInventoryDone = true;
         if(param1)
         {
            this.chestRevealFeedPost();
         }
         if(mCloseCallback != null)
         {
            mCloseCallback(mItemType,mItemOfferId,false);
         }
         else
         {
            this.destroy();
         }
      }
      
      function goToStorage(param1:Bool = true) 
      {
         mUpdateToInventoryDone = true;
         if(mGoToStorageCallback != null)
         {
            mGoToStorageCallback(mItemType,mItemOfferId,param1);
         }
         else
         {
            mDBFacade.mainStateMachine.enterTownInventoryState(mItemType,mItemOfferId,param1);
            preCloseCallback(false);
         }
      }
      
      public function destroy() 
      {
         var _loc1_:UIModifier;
         var __ax4_iter_93:Vector<UIModifier>;
         if(mHoldTooltip != null)
         {
            mHoldTooltip.destroy();
         }
         if(mHoldIcon != null)
         {
            mHoldIcon.destroy();
         }
         mHoldTooltip = null;
         mHoldIcon = null;
         if(mModifiersList.length > 0)
         {
            __ax4_iter_93 = mModifiersList;
            if (checkNullIteratee(__ax4_iter_93)) for (_tmp_ in __ax4_iter_93)
            {
               _loc1_ = _tmp_;
               _loc1_.destroy();
            }
         }
         mModifiersList = null;
         mDBFacade = null;
         mAssetLoadingComponent = null;
         mChestGM = null;
         if(mChestRenderer != null)
         {
            mChestRenderer.destroy();
         }
         mChestRenderer = null;
         if(mSlotMachineRenderer != null)
         {
            mSlotMachineRenderer.destroy();
         }
         mSlotMachineRenderer = null;
         if(mItemRenderer != null)
         {
            mItemRenderer.destroy();
         }
         mItemRenderer = null;
         mSceneGraphComponent.removePopupCurtain();
         mSceneGraphComponent.removeChild(mPopUpMC);
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         if(mWeaponRevealer != null)
         {
            mWeaponRevealer.destroy();
            mWeaponRevealer = null;
         }
         mAnimationMC = null;
         mSlotMachineAnimationMC = null;
         mSceneGraphComponent = null;
         mPopUpMC = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         mSound1 = null;
         mSound2 = null;
         if(mSound2Handle != null)
         {
            mSound2Handle.destroy();
         }
         mSound3 = null;
         mChestOpenSfx = null;
      }
   }


