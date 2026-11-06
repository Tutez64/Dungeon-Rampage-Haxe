package uI.inventory.chests;

import account.ItemInfo;
import account.StoreServices;
import actor.Revealer;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.render.MovieClipRenderer;
import brain.sound.SoundAsset;
import brain.sound.SoundHandle;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import collections.IMapIterator;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
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
import uI.hud.UIHud;
import uI.inventory.UITapHoldTooltip;
import uI.modifiers.UIModifier;
import uI.popup.DBUIPopup;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

class ChestRevealPopUp extends DBUIPopup {
	public static inline final popUpName = "reveal_chest_popup";

	static inline final DESCRIPTION_MAX_LINES = 2;

	public static inline final SLOT_MACHINE_ANIMATION_WEAPON_NAME = "reveal_chest_slotMachine";

	public static inline final SLOT_MACHINE_ANIMATION_CONSUMABLE_NAME = "reveal_itemBox_slotMachine";

	public static inline final weaponMCName = "reveal_chest_weapon_total";

	public static inline final REVEALED_ITEM_WEAPON = (1 : UInt);

	public static inline final REVEALED_ITEM_STACKABLE = (2 : UInt);

	public static inline final REVEALED_ITEM_PET = (3 : UInt);

	var mChestGM:GMChest;

	var mSoundComponent:DBSoundComponent;

	var mPopUpMC:MovieClip;

	var mAnimationMC:MovieClip;

	var mSlotMachineAnimationMC:MovieClip;

	var mItemMC:MovieClip;

	var mChestRenderer:MovieClipRenderer;

	var mSlotMachineRenderer:MovieClipRenderer;

	var mItemRenderer:MovieClipRenderer;

	var mWeaponTextField:TextField;

	var mItemName:String;

	var mItemDesc:String;

	var mRevealedItemIcon:MovieClip;

	var mWeaponRevealer:Revealer;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mItemOfferId:UInt = 0;

	var mRevealCloseCallback:ASFunction;

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

	public function new(dbFacade:DBFacade, chestGM:GMChest, closeCallback:ASFunction, goToStorageCallback:ASFunction) {
		mChestGM = chestGM;
		mRevealCloseCallback = closeCallback;
		mGoToStorageCallback = goToStorageCallback;
		mSoundComponent = new DBSoundComponent(dbFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(dbFacade, "ChestRevealPopUp");
		super(dbFacade, "", "", null, false, true, null, false, false);
		mItemOfferId = (0 : UInt);
		mUpdateToInventoryDone = false;
		mNewWeaponDBID = 0;
		mModifiersList = new Vector<UIModifier>();
		loadSounds();
	}

	static function growUpToFit(field:TextField) {
		var _loc2_ = (field.textHeight + 4) * field.scaleY;
		if (_loc2_ > field.height) {
			field.y -= _loc2_ - field.height;
			field.height = _loc2_;
		}
	}

	override function getSwfPath():String {
		return mChestGM.InventoryRevealSwf;
	}

	function loadSounds() {
		mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), "guitar_wank07", function(param1:SoundAsset) {
			mSound1 = param1;
		});
		mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), "guitar_wank18", function(param1:SoundAsset) {
			mSound2 = param1;
		});
		mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), "guitar_wank21", function(param1:SoundAsset) {
			mSound3 = param1;
		});
		mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), "guitar_wank26", function(param1:SoundAsset) {
			mSound4 = param1;
		});
		mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), "chestKeyOpen", function(param1:SoundAsset) {
			mChestOpenSfx = param1;
		});
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		var bounds:Rectangle;
		var rarity:GMRarity;
		var openAnimation:Dynamic;
		var slotMachineAnimation:Dynamic;
		var weaponClass:Dynamic;
		var itemInfoCardSwfClass:Dynamic;
		mSwfAsset = swfAsset;
		var backgroundSwfClass = swfAsset.getClass("reveal_chest_popup");
		mPopUpMC = ASCompat.dynamicAs(ASCompat.createInstance(backgroundSwfClass, []), MovieClip);
		mPopup = mPopUpMC;
		mRoot.addChild(mPopUpMC);
		TextUtil.setText(ASCompat.coerce((mPopUpMC : ASAny).title_label, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("CHEST_NAME", mChestGM.Rarity));
		mPopUpMC.scaleX = mPopUpMC.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
		bounds = mPopUpMC.getBounds(mDBFacade.scalingRoot);
		mPopUpMC.x = mDBFacade.viewWidth / 2 - bounds.width / 2 - bounds.x;
		mPopUpMC.y = mDBFacade.viewHeight / 2 - bounds.height / 2 - bounds.y;
		TextUtil.setText(ASCompat.coerce((mPopUpMC : ASAny).title_label, flash.text.TextField), mChestGM.Name);
		rarity = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(mChestGM.Rarity), gameMasterDictionary.GMRarity);
		if (rarity != null && rarity.TextColor != 0) {
			ASCompat.setProperty((mPopUpMC : ASAny).title_label, "textColor", rarity.TextColor);
		}
		openAnimation = swfAsset.getClass(mChestGM.InventoryRevealName);
		mAnimationMC = ASCompat.dynamicAs(ASCompat.createInstance(openAnimation, []), MovieClip);
		slotMachineAnimation = swfAsset.getClass(UIHud.isThisAConsumbleChestId((mChestGM.Id : Int)) ? "reveal_itemBox_slotMachine" : "reveal_chest_slotMachine");
		mSlotMachineAnimationMC = ASCompat.dynamicAs(ASCompat.createInstance(slotMachineAnimation, []), MovieClip);
		weaponClass = swfAsset.getClass("reveal_chest_weapon_total");
		mItemMC = ASCompat.dynamicAs(ASCompat.createInstance(weaponClass, []), MovieClip);
		mWeaponTextField = ASCompat.coerce((mItemMC : ASAny).reveal_chest_weaponTextField, flash.text.TextField);
		if (ASCompat.toBool((mSlotMachineAnimationMC : ASAny).reveal_chest_forgeTextField)) {
			ASCompat.setProperty((mSlotMachineAnimationMC : ASAny).reveal_chest_forgeTextField, "visible", false);
		}
		mCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mPopUpMC : ASAny).close, flash.display.MovieClip));
		mCloseButton.visible = false;
		mCloseButton.enabled = false;
		mCloseButton.releaseCallback = preCloseCallback;
		itemInfoCardSwfClass = swfAsset.getClass("item_card");
		mItemInfoCardMC = ASCompat.dynamicAs(ASCompat.createInstance(itemInfoCardSwfClass, []), MovieClip);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"), function(param1:SwfAsset) {
			var _loc2_ = param1.getClass("DR_charge_tooltip");
			mTapIcon = new UIObject(mDBFacade, ASCompat.coerce((mItemInfoCardMC : ASAny).ability.tap_icon, flash.display.MovieClip));
			mTapTooltip = new UITapHoldTooltip(mDBFacade, _loc2_);
			mTapIcon.tooltip = mTapTooltip;
			mTapIcon.tooltipPos = new Point(0, mTapIcon.root.height * 0.5);
			mTapTooltip.visible = false;
			mHoldIcon = new UIObject(mDBFacade, ASCompat.coerce((mItemInfoCardMC : ASAny).ability.icon, flash.display.MovieClip));
			mHoldTooltip = new UITapHoldTooltip(mDBFacade, _loc2_);
			mHoldIcon.tooltip = mHoldTooltip;
			mHoldIcon.tooltipPos = new Point(0, mHoldIcon.root.height * 0.5);
			mHoldTooltip.visible = false;
		});
		mPopUpMC.addChild(mItemInfoCardMC);
		mItemInfoCardMC.visible = false;
		revealChest();
	}

	function revealChest() {
		var startRevealTime:Float;
		(mPopUpMC : ASAny).reveal_chest_slot.addChild(mAnimationMC);
		mChestRenderer = new MovieClipRenderer(mDBFacade, mAnimationMC);
		mChestRenderer.play((0 : UInt), false);
		mLogicalWorkComponent.doLater(1.25, function(param1:GameClock) {
			if (mChestOpenSfx != null) {
				mSoundComponent.playSfxOneShot(mChestOpenSfx);
			}
		});
		startRevealTime = UIHud.isThisAConsumbleChestId((mChestGM.Id : Int)) ? 0.125 : 2.2916666666666665;
		mLogicalWorkComponent.doLater(startRevealTime, revealSlotMachine);
	}

	function revealSlotMachine(gameClock:GameClock = null) {
		(mPopUpMC : ASAny).reveal_chest_slot.removeChild(mAnimationMC);
		mChestRenderer.destroy();
		mChestRenderer = null;
		if (mSound2 != null) {
			mSound2Handle = mSoundComponent.playSfxManaged(mSound2);
			mSound2Handle.play(10);
		}
		(mPopUpMC : ASAny).reveal_chest_slot.addChild(mSlotMachineAnimationMC);
		mSlotMachineRenderer = new MovieClipRenderer(mDBFacade, mSlotMachineAnimationMC);
		mSlotMachineRenderer.play((0 : UInt), true);
		mLogicalWorkComponent.doLater(UIHud.isThisAConsumbleChestId((mChestGM.Id : Int)) ? 1.375 : 2, startCheckForRevealWeapon);
	}

	public function updateRevealLoot(details:ASAny) {
		var __ax4_iter_434:Vector<GMOfferDetail>;
		var offerId:UInt = 0;
		var weaponId:UInt = 0;
		var swfPath:String = null;
		var iconClass:String = null;
		var name:String = null;
		var unlockMetricsDetails:ASObject;
		var offerDetail:GMOfferDetail;
		var gmStackable:GMStackable;
		var gmPet:GMNpc;
		var aesthetic:GMWeaponAesthetic;
		mDBFacade.steamAchievementsHelper.addValueToStatInt(1, "CHESTS_OPENED");
		unlockMetricsDetails = {};
		ASCompat.setProperty(unlockMetricsDetails, "isWeapon", false);
		mNewWeaponDBID = 0;
		if (details.hasOwnProperty("NewWeaponDetails")) {
			if (details.NewWeaponDetails != null) {
				mNewWeaponDBID = ASCompat.toNumberField(details.NewWeaponDetails, "id");
				ASCompat.setProperty(unlockMetricsDetails, "isWeapon", true);
			}
			offerId = ASCompat.asUint(details.OfferId);
			weaponId = ASCompat.asUint(details.WeaponId);
		} else if (details.hasOwnProperty("customResult")) {
			if (details.customResult.hasOwnProperty("purchasedChestResults")) {
				if (details.customResult.purchasedChestResults.NewWeaponDetails != null) {
					mNewWeaponDBID = ASCompat.toNumberField(details.customResult.purchasedChestResults.NewWeaponDetails, "id");
					ASCompat.setProperty(unlockMetricsDetails, "isWeapon", true);
				}
				offerId = ASCompat.asUint(details.customResult.purchasedChestResults.OfferId);
				weaponId = ASCompat.asUint(details.customResult.purchasedChestResults.WeaponId);
			}
		}
		mRevealedGMOffer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(offerId), gameMasterDictionary.GMOffer);
		if (mRevealedGMOffer == null) {
			mRevealedItemInfo = ASCompat.coerce(mDBFacade.dbAccountInfo.inventoryInfo.items.itemFor(weaponId), account.ItemInfo);
			if (mRevealedItemInfo == null) {
				Logger.warn("Can\'t find gmOffer or itemInfo for loot with offerId: "
					+ Std.string(offerId)
					+ " and weaponId: "
					+ Std.string(weaponId));
				return;
			}
			ASCompat.setProperty(unlockMetricsDetails, "lootLevel", mRevealedItemInfo.requiredLevel);
			ASCompat.setProperty(unlockMetricsDetails, "lootPower", mRevealedItemInfo.power);
			if (mRevealedItemInfo.modifiers.length > 0) {
				ASCompat.setProperty(unlockMetricsDetails, "lootMod1", mRevealedItemInfo.modifiers[0].Constant);
			}
			if (mRevealedItemInfo.modifiers.length > 1) {
				ASCompat.setProperty(unlockMetricsDetails, "lootMod2", mRevealedItemInfo.modifiers[1].Constant);
			}
			if (mRevealedItemInfo.legendaryModifier > 0) {
				ASCompat.setProperty(unlockMetricsDetails, "legendaryModifier", mRevealedItemInfo.legendaryModifier);
			}
			mRevealedGMWeapon = mRevealedItemInfo.gmWeaponItem;
			mItemType = (1 : UInt);
			mItemOfferId = mRevealedGMWeapon.Id;
		} else {
			mItemType = (2 : UInt);
			mItemOfferId = mRevealedGMOffer.Id;
		}
		if (mItemType == 2) {
			if (mRevealedGMOffer.IsBundle) {
				swfPath = mRevealedGMOffer.BundleSwfFilepath;
				iconClass = mRevealedGMOffer.BundleIcon;
				name = GameMasterLocale.getGameMasterSubString("BUNDLE_OFFER_NAME", Std.string(mRevealedGMOffer.Id));
				mItemType = (2 : UInt);
				mRevealedItemId = offerId;
			} else if (mRevealedGMOffer.Details != null && mRevealedGMOffer.Details.length > 0) {
				__ax4_iter_434 = mRevealedGMOffer.Details;
				if (checkNullIteratee(__ax4_iter_434))
					for (_tmp_ in __ax4_iter_434) {
						offerDetail = _tmp_;
						if (offerDetail.StackableId != 0) {
							gmStackable = ASCompat.coerce(mDBFacade.gameMaster.stackableById.itemFor(offerDetail.StackableId),
								gameMasterDictionary.GMStackable);
							swfPath = gmStackable.UISwfFilepath;
							iconClass = gmStackable.IconName;
							name = GameMasterLocale.getGameMasterSubString("STACKABLE_NAME", gmStackable.Constant);
							mItemType = (2 : UInt);
							mRevealedItemId = offerDetail.StackableId;
						} else if (offerDetail.PetId != 0) {
							gmPet = ASCompat.coerce(mDBFacade.gameMaster.npcById.itemFor(offerDetail.PetId), gameMasterDictionary.GMNpc);
							swfPath = gmPet.IconSwfFilepath;
							iconClass = gmPet.IconName;
							name = GameMasterLocale.getGameMasterSubString("PET_NAME", gmPet.Constant);
							mItemType = (3 : UInt);
							mRevealedItemId = offerDetail.PetId;
						}
					}
			}
		} else {
			mRevealedItemId = mItemOfferId;
			mRevealedItemLevel = mRevealedItemInfo.requiredLevel;
			aesthetic = mRevealedGMWeapon.getWeaponAesthetic(mRevealedItemLevel, mRevealedItemInfo.legendaryModifier > 0);
			swfPath = aesthetic.IconSwf;
			iconClass = aesthetic.IconName;
			name = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME", aesthetic.Constant);
			mItemType = (1 : UInt);
		}
		mItemName = name;
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath), function(param1:SwfAsset) {
			var _loc2_ = param1.getClass(iconClass);
			mRevealedItemIcon = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
		});
		ASCompat.setProperty(unlockMetricsDetails, "chestId", mChestGM.Id);
		ASCompat.setProperty(unlockMetricsDetails, "rarity", mChestGM.Rarity);
		ASCompat.setProperty(unlockMetricsDetails, "chestName", mChestGM.Name);
		ASCompat.setProperty(unlockMetricsDetails, "lootName", mItemName);
		ASCompat.setProperty(unlockMetricsDetails, "lootId", mRevealedItemId);
		mDBFacade.metrics.log("ChestUnlockResult", unlockMetricsDetails);
	}

	function startCheckForRevealWeapon(gameClock:GameClock = null) {
		mLogicalWorkComponent.doEveryFrame(checkForRevealWeapon);
	}

	function checkForRevealWeapon(gameClock:GameClock = null) {
		if (mItemOfferId > 0) {
			revealWeapon();
		}
	}

	function revealWeapon() {
		if (mSound2Handle != null) {
			mSound2Handle.destroy();
			mSound2Handle = null;
		}
		if (UIHud.isThisAConsumbleChestId((mChestGM.Id : Int))) {
			if (mSound4 != null) {
				mSoundComponent.playSfxOneShot(mSound4);
			}
		} else if (mSound1 != null) {
			mSoundComponent.playSfxOneShot(mSound1);
		}
		mLogicalWorkComponent.clear();
		mSlotMachineRenderer.destroy();
		(mPopUpMC : ASAny).reveal_chest_slot.removeChild(mSlotMachineAnimationMC);
		mCloseButton.visible = true;
		mCloseButton.enabled = true;
		mItemInfoCardMC.visible = true;
		mItemRenderer = new MovieClipRenderer(mDBFacade, mItemMC);
		mItemRenderer.play((0 : UInt), false);
		setupRevealedItemUI();
		mUpdateToInventoryDone = true;
	}

	function setupRevealedItemUI() {
		var __tmpAssignObj69:ASAny;
		var __tmpAssignObj70:ASAny;
		var __tmpAssignObj71:ASAny;
		var __tmpAssignObj72:ASAny;
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
		var isWeapon = false;
		var isEquippable = true;
		var typeOfUnequippable = (0 : UInt);
		var currentlySelectedAvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
		var price = (0 : UInt);
		var isSellable = false;
		ASCompat.setProperty((mItemInfoCardMC : ASAny).number_label, "visible", false);
		if (mItemType == 1) {
			ASCompat.setProperty((mItemInfoCardMC : ASAny).ability, "visible", true);
			ASCompat.setProperty((mItemInfoCardMC : ASAny).pet_stats, "visible", false);
			mRevealedItemIcon.scaleX = mRevealedItemIcon.scaleY = 0.5;
			gmWeaponItem = ASCompat.coerce(mDBFacade.gameMaster.weaponItemById.itemFor(mRevealedItemId), gameMasterDictionary.GMWeaponItem);
			mItemDesc = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_DESCRIPTION",
				gmWeaponItem.getWeaponAesthetic(mRevealedItemLevel, mRevealedItemInfo.legendaryModifier > 0).WeaponItemConstant);
			isWeapon = isSellable = true;
			mItemName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",
				gmWeaponItem.getWeaponAesthetic(mRevealedItemLevel, mRevealedItemInfo.legendaryModifier > 0).Constant);
			gmMasterTypeVector = mDBFacade.gameMaster.WeaponMastertypes;
			vi = 0;
			while (vi < gmMasterTypeVector.length) {
				if (gmMasterTypeVector[vi].Constant == gmWeaponItem.MasterType) {
					weaponType = GameMasterLocale.getGameMasterSubString("WEAPON_MASTERTYPE", gmMasterTypeVector[vi].Constant).toUpperCase();
				}
				vi = vi + 1;
			}
			weaponRequiredLevel = mRevealedItemLevel;
			levelRequirement = Locale.getString("REQUIRES_LEVEL") + Std.string(weaponRequiredLevel);
			power = Std.string(mRevealedItemInfo.power);
			if (ASCompat.stringAsBool(gmWeaponItem.ChargeAttack)) {
				chargeAttack = ASCompat.coerce(mDBFacade.gameMaster.attackByConstant.itemFor(gmWeaponItem.ChargeAttack), gameMasterDictionary.GMAttack);
				if (chargeAttack != null) {
					chargeAttackName = "MAKO" + chargeAttack.Name.toUpperCase();
				}
			}
			if (currentlySelectedAvatarInfo != null && currentlySelectedAvatarInfo.levelForWeaponComparison >= weaponRequiredLevel) {
				isEquippable = true;
			} else {
				isEquippable = false;
				typeOfUnequippable = (1 : UInt);
			}
			if (isEquippable) {
				if (currentlySelectedAvatarInfo != null
					&& mDBFacade.dbAccountInfo.inventoryInfo.canAvatarEquipThisMasterType(currentlySelectedAvatarInfo, gmWeaponItem.MasterType)) {
					isEquippable = true;
				} else {
					isEquippable = false;
					typeOfUnequippable = (2 : UInt);
				}
			}
			bgColoredExists = mRevealedItemInfo.rarity.HasColoredBackground;
			bgSwfPath = mRevealedItemInfo.rarity.BackgroundSwf;
			bgIconName = mRevealedItemInfo.rarity.BackgroundIcon;
			if (bgColoredExists) {
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath), function(param1:SwfAsset) {
					var _loc3_:MovieClip = null;
					var _loc2_ = param1.getClass(bgIconName);
					if (_loc2_ != null) {
						_loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
						(mItemInfoCardMC : ASAny).item_icon.addChildAt(_loc3_, 0);
					}
				});
			}
			price = (mRevealedItemInfo.sellCoins : UInt);
		} else if (mItemType == 2) {
			ASCompat.setProperty((mItemInfoCardMC : ASAny).ability, "visible", false);
			ASCompat.setProperty((mItemInfoCardMC : ASAny).pet_stats, "visible", false);
			__tmpAssignObj69 = (mItemInfoCardMC : ASAny).icon_slot;
			ASCompat.setProperty(__tmpAssignObj69, "x", __tmpAssignObj69.x + 100);
			__tmpAssignObj70 = (mItemInfoCardMC : ASAny).item_icon;
			ASCompat.setProperty(__tmpAssignObj70, "x", __tmpAssignObj70.x + 100);
			__tmpAssignObj71 = (mItemInfoCardMC : ASAny).item_card_frame;
			ASCompat.setProperty(__tmpAssignObj71, "x", __tmpAssignObj71.x + 100);
			mRevealedItemIcon.scaleX = mRevealedItemIcon.scaleY = 0.6;
			gmStackable = ASCompat.coerce(mDBFacade.gameMaster.stackableById.itemFor(mRevealedItemId), gameMasterDictionary.GMStackable);
			if (gmStackable == null) {
				gmOffer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(mRevealedItemId), gameMasterDictionary.GMOffer);
				mItemDesc = GameMasterLocale.getGameMasterSubString("BUNDLE_OFFER_DESCRIPTION", Std.string(gmOffer.Id));
				if (gmOffer.Details.length > 0) {
					if (gmOffer.Details[0].StackableId != 0) {
						ASCompat.setProperty((mItemInfoCardMC : ASAny).number_label, "visible", true);
						TextUtil.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).number_label, flash.text.TextField),
							"x" + Std.string(gmOffer.Details[0].StackableCount));
						__tmpAssignObj72 = (mItemInfoCardMC : ASAny).number_label;
						ASCompat.setProperty(__tmpAssignObj72, "x", __tmpAssignObj72.x + 100);
					}
				}
			} else {
				mItemDesc = GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION", gmStackable.Constant);
			}
		} else if (mItemType == 3) {
			ASCompat.setProperty((mItemInfoCardMC : ASAny).ability, "visible", false);
			ASCompat.setProperty((mItemInfoCardMC : ASAny).pet_stats, "visible", true);
			mRevealedItemIcon.scaleX = mRevealedItemIcon.scaleY = 1;
			gmPet = ASCompat.coerce(mDBFacade.gameMaster.npcById.itemFor(mRevealedItemId), gameMasterDictionary.GMNpc);
			mItemDesc = GameMasterLocale.getGameMasterSubString("PET_DESCRIPTION", gmPet.Constant);
			j = (1 : UInt);
			while (j <= 5) {
				powerStarMC = ASCompat.coerce(cast((mItemInfoCardMC : ASAny).pet_stats.pet_stats_power, flash.display.DisplayObjectContainer)
					.getChildByName("star"
					+ Std.string(j)),
					flash.display.MovieClip);
				defenseStarMC = ASCompat.coerce(cast((mItemInfoCardMC : ASAny).pet_stats.pet_stats_power, flash.display.DisplayObjectContainer)
					.getChildByName("star"
					+ Std.string(j)),
					flash.display.MovieClip);
				speedStarMC = ASCompat.coerce(cast((mItemInfoCardMC : ASAny).pet_stats.pet_stats_power, flash.display.DisplayObjectContainer)
					.getChildByName("star"
					+ Std.string(j)),
					flash.display.MovieClip);
				powerStarMC.visible = gmPet.AttackRating >= j;
				defenseStarMC.visible = gmPet.DefenseRating >= j;
				speedStarMC.visible = gmPet.SpeedRating >= j;
				j = j + 1;
			}
		}
		(mItemInfoCardMC : ASAny).item_icon.addChildAt(mRevealedItemIcon, 1);
		ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label_unequippable, "visible", false);
		ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label, "visible", false);
		ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement_not_met, "visible", false);
		ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement, "visible", false);
		if (isWeapon) {
			ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label_unequippable, "visible", typeOfUnequippable == 2);
			ASCompat.setProperty((mItemInfoCardMC : ASAny).weapon_type_label, "visible", typeOfUnequippable != 2);
			ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement_not_met, "visible", typeOfUnequippable == 1);
			ASCompat.setProperty((mItemInfoCardMC : ASAny).level_requirement, "visible", typeOfUnequippable != 1);
			TextUtil.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).weapon_type_label, flash.text.TextField), weaponType);
			TextUtil.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).level_requirement, flash.text.TextField), levelRequirement);
			TextUtil.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).weapon_type_label_unequippable, flash.text.TextField), weaponType);
			TextUtil.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).level_requirement_not_met, flash.text.TextField), levelRequirement);
		}
		switch (typeOfUnequippable) {
			case 0:
				setDescription(mItemDesc);

			case 1:
				setDescription(Locale.getString("ITEM_CARD_UNUSABLE_LEVEL"));

			case 2:
				setDescription(Locale.getString("ITEM_CARD_UNUSABLE_MASTERCLASS"));
		}
		Locale.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).ability.label_tap, flash.text.TextField), "TAP");
		Locale.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).ability.label, flash.text.TextField), "HOLD");
		if (isWeapon) {
			ASCompat.setProperty((mPopUpMC : ASAny).title_label, "textColor", mRevealedItemInfo.getTextColor());
			ASCompat.setProperty((mItemInfoCardMC : ASAny).description, "textColor", mRevealedItemInfo.getTextColor());
			if (ASCompat.stringAsBool(gmWeaponItem.TapIcon) && gmWeaponItem.TapIcon != "") {
				mTapIcon.visible = true;
				swfPath = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
				iconName = gmWeaponItem.TapIcon;
				if (ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName)) {
					mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath), function(param1:SwfAsset) {
						var _loc2_:MovieClip = null;
						var _loc3_ = param1.getClass(iconName);
						if (_loc3_ != null) {
							_loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
							_loc2_.scaleX = _loc2_.scaleY = 0.5;
							mTapIcon.root.addChild(_loc2_);
							mTapTooltip.setValues(GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_TAP_TITLE", gmWeaponItem.Constant),
								GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_TAP_DESCRIPTION", gmWeaponItem.Constant));
							mTapTooltip.visible = true;
							stagePos = new Point();
							stagePos.y += mTapIcon.root.height * 0.5;
							mTapIcon.tooltipPos = stagePos;
						}
					});
				}
			}
			if (ASCompat.stringAsBool(gmWeaponItem.HoldIcon) && gmWeaponItem.HoldIcon != "") {
				mHoldIcon.visible = true;
				swfPath1 = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
				iconName1 = gmWeaponItem.HoldIcon;
				if (ASCompat.stringAsBool(swfPath1) && ASCompat.stringAsBool(iconName1)) {
					mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath1), function(param1:SwfAsset) {
						var _loc2_:MovieClip = null;
						var _loc4_:String = null;
						var _loc3_ = param1.getClass(iconName1);
						if (_loc3_ != null) {
							_loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
							_loc2_.scaleX = _loc2_.scaleY = 0.5;
							mHoldIcon.root.addChild(_loc2_);
							_loc4_ = gmWeaponItem.WeaponController != null ? GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_CONTROLLER",
								gmWeaponItem.WeaponController) : gmWeaponItem.HoldTitle;
							mHoldTooltip.setValues(_loc4_, GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_HOLD_DESCRIPTION", gmWeaponItem.Constant));
							mHoldTooltip.visible = true;
							stagePos = new Point();
							stagePos.y += mHoldIcon.root.height * 0.5;
							mHoldIcon.tooltipPos = stagePos;
						}
					});
				}
			}
		}
		if (isWeapon) {
			Locale.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).power.attack_label, flash.text.TextField), "POWER");
			TextUtil.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).power.label, flash.text.TextField), power);
		} else {
			ASCompat.setProperty((mItemInfoCardMC : ASAny).power, "visible", false);
		}
		ASCompat.setProperty((mItemInfoCardMC : ASAny).unequippable, "visible", !isEquippable);
		mItemInfoCardSellButton = new UIButton(mDBFacade, ASCompat.coerce((mItemInfoCardMC : ASAny).sell, flash.display.MovieClip));
		Locale.setText(mItemInfoCardSellButton.label, "ITEM_CARD_SELL");
		mItemInfoCardSellButton.visible = isSellable;
		mItemInfoCardSellButton.enabled = isSellable;
		if (isSellable) {
			TextUtil.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).sell.sell_text, flash.text.TextField), Std.string(price));
		}
		mItemInfoCardSellButton.releaseCallback = sellRevealedItem;
		mItemInfoCardStoreButton = new UIButton(mDBFacade, ASCompat.coerce((mItemInfoCardMC : ASAny).store, flash.display.MovieClip));
		Locale.setText(mItemInfoCardStoreButton.label, "KEEP");
		mItemInfoCardStoreButton.releaseCallback = function() {
			preCloseCallback(true);
		};
		mItemInfoCardEquipButton = new UIButton(mDBFacade, ASCompat.coerce((mItemInfoCardMC : ASAny).equip, flash.display.MovieClip));
		Locale.setText(mItemInfoCardEquipButton.label, "ITEM_CARD_EQUIP");
		if (isEquippable) {
			mItemInfoCardEquipButton.releaseCallback = goToStorage;
		} else {
			mItemInfoCardEquipButton.releaseCallback = function() {
				goToStorage(false);
			};
		}
		mItemInfoCardEquipButton.visible = isWeapon;
		mItemInfoCardEquipButton.enabled = isWeapon && isEquippable;
		if (isWeapon) {
			preNameModifiers = "";
			modifierList = mRevealedItemInfo.modifiers;
			Locale.setText(ASCompat.coerce((mItemInfoCardMC : ASAny).ability.label_modifier, flash.text.TextField), "MODIFIERS");
			i = 0;
			while (i < modifierList.length) {
				mModifiersList.push(new UIModifier(mDBFacade,
					ASCompat.dynamicAs(cast((mItemInfoCardMC : ASAny).ability, flash.display.DisplayObjectContainer).getChildByName("modifier_icon_"
						+ Std.string((i + 1))),
						MovieClip),
					modifierList[i].Constant));
				preNameModifiers += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME", modifierList[i].Constant) + " ";
				i = i + 1;
			}
			mItemName = preNameModifiers + mItemName;
			if (mRevealedItemInfo.legendaryModifier > 0) {
				mModifiersList.push(new UIModifier(mDBFacade,
					ASCompat.dynamicAs(cast((mItemInfoCardMC : ASAny).ability, flash.display.DisplayObjectContainer).getChildByName("modifier_icon_3"),
						MovieClip),
					"", (0 : UInt), true, mRevealedItemInfo.legendaryModifier));
				mItemName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",
					mRevealedItemInfo.gmWeaponItem.getWeaponAesthetic((0 : UInt), true).Constant);
			}
		}
		TextUtil.setText(ASCompat.coerce((mPopUpMC : ASAny).title_label, flash.text.TextField), mItemName.toUpperCase());
		if (mItemType == 1 || mItemType == 3) {
			mDBFacade.menuNavigationController.pushNewLayer("POPUP_WEAPON_CHEST_REVEALER", closeFromNavigationCallback, mItemInfoCardStoreButton,
				mItemInfoCardEquipButton);
			mItemInfoCardSellButton.isToTheLeftOf(mItemInfoCardStoreButton);
			mItemInfoCardStoreButton.isToTheLeftOf(mItemInfoCardEquipButton);
			mCloseButton.isAbove(mItemInfoCardEquipButton);
			mItemInfoCardSellButton.upNavigation = mCloseButton;
			mItemInfoCardStoreButton.upNavigation = mCloseButton;
		} else if (mItemType == 2) {
			mDBFacade.menuNavigationController.pushNewLayer("POPUP_WEAPON_CHEST_REVEALER", closeFromNavigationCallback, mItemInfoCardStoreButton,
				mItemInfoCardStoreButton);
			mCloseButton.isAbove(mItemInfoCardStoreButton);
		}
	}

	function setDescription(text:String) {
		var _loc2_ = ASCompat.coerce((mItemInfoCardMC : ASAny).description, flash.text.TextField);
		TextUtil.setText(_loc2_, text, 1.55);
		if (_loc2_.numLines > 2) {
			TextUtil.setText(_loc2_, text);
		}
		growUpToFit(_loc2_);
	}

	function sellRevealedItem() {
		var _loc1_:GMWeaponItem = null;
		var _loc3_ = (0 : UInt);
		var _loc2_:IMapIterator = null;
		var _loc4_:ItemInfo = null;
		if (mItemType == 1) {
			_loc1_ = ASCompat.coerce(mDBFacade.gameMaster.weaponItemById.itemFor(mRevealedItemId), gameMasterDictionary.GMWeaponItem);
			_loc3_ = (ASCompat.floatToInt(mNewWeaponDBID) : UInt);
			if (_loc3_ == 0) {
				Logger.error(" sellRevealedItem  had to find a weapon .. arg  Somethign is rong ");
				_loc2_ = ASCompat.reinterpretAs(mDBFacade.dbAccountInfo.inventoryInfo.items.iterator(), IMapIterator);
				while (_loc2_.hasNext() && _loc3_ == 0) {
					_loc2_.next();
					_loc4_ = ASCompat.dynamicAs(_loc2_.current, ItemInfo);
					if (_loc4_.gmWeaponItem.Id == _loc1_.Id) {
						_loc3_ = _loc4_.databaseId;
						break;
					}
				}
			} else {
				Logger.info("sellRevealedItem  Selling Weapon id :" + Std.string(_loc3_));
			}
			StoreServices.sellWeapon(mDBFacade, _loc3_, sellSuccessFunction, sellFailureFunction);
		}
		mItemInfoCardSellButton.enabled = false;
	}

	function sellSuccessFunction(details:ASAny) {
		preCloseCallback();
	}

	function sellFailureFunction(e:Error) {
		Logger.error("Trying to sell revealed item but failed");
	}

	function closeFromNavigationCallback() {
		preCloseCallback();
	}

	function preCloseCallback(keptItem:Bool = false) {
		mUpdateToInventoryDone = true;
		if (mRevealCloseCallback != null) {
			mRevealCloseCallback(mItemType, mItemOfferId, keptItem);
		} else {
			this.destroy();
		}
	}

	function goToStorage(callEquip:Bool = true) {
		mUpdateToInventoryDone = true;
		if (mGoToStorageCallback != null) {
			mGoToStorageCallback(mItemType, mItemOfferId, callEquip);
		} else {
			mDBFacade.mainStateMachine.enterTownInventoryState(mItemType, mItemOfferId, callEquip);
			preCloseCallback();
		}
	}

	override public function destroy() {
		var _loc1_:UIModifier;
		var __ax4_iter_435:Vector<UIModifier>;
		if (mDBFacade == null) {
			return;
		}
		if (mHoldTooltip != null) {
			mHoldTooltip.destroy();
		}
		if (mHoldIcon != null) {
			mHoldIcon.destroy();
		}
		mDBFacade.menuNavigationController.popLayer("POPUP_WEAPON_CHEST_REVEALER");
		mHoldTooltip = null;
		mHoldIcon = null;
		if (mModifiersList.length > 0) {
			__ax4_iter_435 = mModifiersList;
			if (checkNullIteratee(__ax4_iter_435))
				for (_tmp_ in __ax4_iter_435) {
					_loc1_ = _tmp_;
					_loc1_.destroy();
				}
		}
		mModifiersList = null;
		mChestGM = null;
		if (mChestRenderer != null) {
			mChestRenderer.destroy();
		}
		mChestRenderer = null;
		if (mSlotMachineRenderer != null) {
			mSlotMachineRenderer.destroy();
		}
		mSlotMachineRenderer = null;
		if (mItemRenderer != null) {
			mItemRenderer.destroy();
		}
		mItemRenderer = null;
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
		}
		mLogicalWorkComponent = null;
		if (mWeaponRevealer != null) {
			mWeaponRevealer.destroy();
			mWeaponRevealer = null;
		}
		mAnimationMC = null;
		mSlotMachineAnimationMC = null;
		mPopUpMC = null;
		mSoundComponent.destroy();
		mSoundComponent = null;
		mSound1 = null;
		mSound2 = null;
		if (mSound2Handle != null) {
			mSound2Handle.destroy();
		}
		mSound3 = null;
		mChestOpenSfx = null;
		super.destroy();
	}
}
