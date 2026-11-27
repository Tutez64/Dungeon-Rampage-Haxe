package uI.inventory.chests;

import account.ChestInfo;
import brain.assetRepository.SwfAsset;
import brain.render.MovieClipRenderer;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMChest;
import gameMasterDictionary.GMRarity;
import uI.hud.UIHud;
import uI.popup.DBUIPopup;
import uI.popup.UITreasureFoundPopup;
import flash.display.MovieClip;
import flash.geom.Rectangle;

class ChestBuyKeysPopUp extends DBUIPopup {
	static inline final SCORE_REPORT_PATH = "Resources/Art2D/UI/db_UI_score_report.swf";

	var mBuyCoinButton:UIButton;

	var mBuyGemButton:UIButton;

	var mRenderer:MovieClipRenderer;

	var mChestKeySlots:Vector<ChestKeySlot>;

	var mCoinButtonCenteredPosition:Int = 1;

	var mCoinIconCenteredPosition:Int = -50;

	public function new(dbFacade:DBFacade, selectedGMChest:GMChest, chestBuyCoinCallback:ASFunction, chestBuyGemCallback:ASFunction,
			closeKeylessChestPopup:ASFunction, refreshHeroInfoCallback:ASFunction, isFromSummary:Bool = false) {
		super(dbFacade, "POPUP_KEYLESS", "", {
			"chest": selectedGMChest,
			"buyCoinCallback": chestBuyCoinCallback,
			"buyGemCallback": chestBuyGemCallback,
			"refreshHeroInfoCallback": refreshHeroInfoCallback,
			"isFromSummary": isFromSummary
		}, true, true, closeKeylessChestPopup, false, false);
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_score_report.swf";
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
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
		mSwfAsset = swfAsset;
		var selectedGMChest = ASCompat.dynamicAs(content.chest, GMChest);
		var openKeyChestClass = UIHud.isThisAConsumbleChestId((selectedGMChest.Id : Int)) ? swfAsset.getClass("popup_itemBox_open") : swfAsset.getClass("popup_chest_keyless");
		mPopup = ASCompat.coerce(ASCompat.createInstance(openKeyChestClass, []), flash.display.MovieClip);
		mRoot.addChild(mPopup);
		mPopup.scaleX = mPopup.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
		bounds = mPopup.getBounds(mDBFacade.scalingRoot);
		mPopup.x = mDBFacade.viewWidth / 2 - bounds.width / 2 - bounds.x;
		mPopup.y = mDBFacade.viewHeight / 2 - bounds.height / 2 - bounds.y;
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).title_label, flash.text.TextField),
			ASCompat.toBool(content.isFromSummary) ? Locale.getString("TREASURE_FOUND") : GameMasterLocale.getGameMasterSubString("CHEST_NAME",
				selectedGMChest.Rarity));
		if (ASCompat.toBool((mPopup : ASAny).description_label)) {
			Locale.setText(ASCompat.coerce((mPopup : ASAny).description_label, flash.text.TextField), "BUY_KEY_TO_OPEN",
				{"CHEST": GameMasterLocale.getGameMasterSubString("CHEST_NAME", selectedGMChest.Rarity)});
		}
		swfPath = selectedGMChest.IconSwf;
		iconName = selectedGMChest.IconName;
		ChestInfo.loadItemIcon(swfPath, iconName, ASCompat.coerce((mPopup : ASAny).content, flash.display.DisplayObjectContainer), mDBFacade, (150 : UInt),
			(150 : UInt), mAssetLoadingComponent);
		ASCompat.setProperty((mPopup : ASAny).content, "y", UIHud.isThisAConsumbleChestId((selectedGMChest.Id : Int)) ? -6 : -35);
		mRenderer = new MovieClipRenderer(mDBFacade, ASCompat.coerce((mPopup : ASAny).content, flash.display.MovieClip));
		mRenderer.play((0 : UInt), true);
		rarity = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(selectedGMChest.Rarity), gameMasterDictionary.GMRarity);
		bgColoredExists = rarity.HasColoredBackground;
		bgSwfPath = rarity.BackgroundSwf;
		bgIconName = rarity.BackgroundIcon;
		if (bgColoredExists) {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath), function(param1:SwfAsset) {
				var _loc3_:MovieClip = null;
				var _loc2_ = param1.getClass(bgIconName);
				if (_loc2_ != null) {
					_loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
					(mPopup : ASAny).content.addChildAt(_loc3_, 0);
					_loc3_.scaleX = _loc3_.scaleY = 1.5;
				}
			});
		}
		coinCostForChestKey = 0;
		cashCostForChestKey = 0;
		i = 0;
		while (i < 6) {
			if (mDBFacade.dbAccountInfo.inventoryInfo.keys[i].gmKey.ChestId == selectedGMChest.Id) {
				coinCostForChestKey = mDBFacade.dbAccountInfo.inventoryInfo.keys[i].gmKeyOffer.Price;
			}
			i = i + 1;
		}
		ASCompat.setProperty((mPopup : ASAny).coin_button, "x", mCoinButtonCenteredPosition);
		ASCompat.setProperty((mPopup : ASAny).coin_icon, "x", mCoinIconCenteredPosition);
		mBuyCoinButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).coin_button, flash.display.MovieClip));
		mBuyCoinButton.releaseCallback = ASCompat.coerceFunction(content.buyCoinCallback(coinCostForChestKey));
		TextUtil.setText(mBuyCoinButton.label, Std.string(coinCostForChestKey));
		mBuyGemButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).gem_button, flash.display.MovieClip));
		ASCompat.setProperty((mPopup : ASAny).gem_icon, "visible", false);
		mBuyGemButton.visible = false;
		mCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).close, flash.display.MovieClip));
		mCloseButton.releaseCallback = handleInputCalledClosed;
		ASCompat.setProperty((mPopup : ASAny).coin_icon, "mouseEnabled", false);
		ASCompat.setProperty((mPopup : ASAny).coin_icon, "mouseChildren", false);
		ASCompat.setProperty((mPopup : ASAny).gem_icon, "mouseEnabled", false);
		ASCompat.setProperty((mPopup : ASAny).gem_icon, "mouseChildren", false);
		if (!UIHud.isThisAConsumbleChestId((selectedGMChest.Id : Int))) {
			createKeySlots(selectedGMChest);
			content.refreshHeroInfoCallback(mPopup);
			UITreasureFoundPopup.fitHeroLabel(ASCompat.coerce((mPopup : ASAny).hero_label, flash.text.TextField));
		}
	}

	override function setupMenuNavigation() {
		mCloseButton.isAbove(mBuyCoinButton);
		mBuyCoinButton.isToTheLeftOf(mBuyGemButton);
	}

	function createKeySlots(selectedGMChest:GMChest) {
		var _loc3_ = 0;
		var _loc2_:MovieClip = null;
		mChestKeySlots = new Vector<ChestKeySlot>();
		_loc3_ = 0;
		while (_loc3_ < 4) {
			_loc2_ = ASCompat.reinterpretAs(mPopup.getChildByName("slot_" + Std.string(_loc3_)), MovieClip);
			mChestKeySlots.push(new ChestKeySlot(mDBFacade, _loc2_, mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_], mAssetLoadingComponent));
			if (selectedGMChest.Id == mChestKeySlots[_loc3_].keyInfo.gmKey.ChestId) {
				mChestKeySlots[_loc3_].setSelected(true);
			} else {
				mChestKeySlots[_loc3_].setSelected(false);
			}
			_loc3_++;
		}
	}

	override function getDefaultNavigationObject():UIObject {
		return mCloseButton;
	}

	override function getInitialFocusedNavigationObject():UIObject {
		return mBuyCoinButton;
	}

	override public function destroy() {
		var _loc1_ = 0;
		if (mDBFacade == null) {
			return;
		}
		if (mBuyCoinButton != null) {
			mBuyCoinButton.destroy();
		}
		mBuyCoinButton = null;
		if (mBuyGemButton != null) {
			mBuyGemButton.destroy();
		}
		mBuyGemButton = null;
		if (mRenderer != null) {
			mRenderer.destroy();
		}
		mRenderer = null;
		if (mChestKeySlots != null) {
			_loc1_ = 0;
			while (_loc1_ < mChestKeySlots.length) {
				mChestKeySlots[_loc1_].destroy();
				_loc1_++;
			}
			mChestKeySlots.splice(0, (mChestKeySlots.length : UInt));
			mChestKeySlots = null;
		}
		super.destroy();
	}
}
