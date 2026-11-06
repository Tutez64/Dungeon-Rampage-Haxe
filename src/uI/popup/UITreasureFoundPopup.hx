package uI.popup;

import account.ChestInfo;
import account.KeyInfo;
import brain.assetRepository.SwfAsset;
import brain.render.MovieClipRenderer;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMChest;
import gameMasterDictionary.GMRarity;
import uI.hud.UIHud;
import flash.display.MovieClip;
import flash.text.TextField;

class UITreasureFoundPopup extends DBUIPopup {
	static inline final SCORE_REPORT_PATH = "Resources/Art2D/UI/db_UI_score_report.swf";

	static inline final HERO_LABEL_MIN_WIDTH:Float = 130;

	var mContentRenderer:MovieClipRenderer;

	var mAbandonButton:UIButton;

	var mKeepButton:UIButton;

	var mOpenButton:UIButton;

	public function new(dbFacade:DBFacade, chest:GMChest, abandonCallback:ASFunction, keepCallback:ASFunction, openCallback:ASFunction,
			refreshHeroInfoCallback:ASFunction) {
		super(dbFacade, "POPUP_CHEST_LAYER", "", {
			"chest": chest,
			"abandonCallback": abandonCallback,
			"keepCallback": keepCallback,
			"openCallback": openCallback,
			"refreshHeroInfoCallback": refreshHeroInfoCallback
		}, false, true, null, false);
	}

	public static function fitHeroLabel(heroLabel:TextField) {
		var _loc2_ = 130 - heroLabel.width;
		if (_loc2_ > 0) {
			heroLabel.x -= _loc2_;
			heroLabel.width += _loc2_;
		}
		TextUtil.setText(heroLabel, heroLabel.text, 1.55);
		TextUtil.fitToField(heroLabel);
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_score_report.swf";
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		mSwfAsset = swfAsset;
		var _loc6_ = ASCompat.dynamicAs(content.chest, GMChest);
		var _loc7_ = UIHud.isThisAConsumbleChestId((_loc6_.Id : Int)) ? swfAsset.getClass("popup_itemBox") : swfAsset.getClass("popup_chest");
		mPopup = ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []), MovieClip);
		mRoot.addChild(mPopup);
		scalePopup();
		centerPopup();
		Locale.setText(ASCompat.coerce((mPopup : ASAny).title_label, flash.text.TextField), "TREASURE_FOUND");
		ASCompat.setProperty((mPopup : ASAny).close, "visible", false);
		mAbandonButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).abandon_button, flash.display.MovieClip));
		mAbandonButton.releaseCallback = ASCompat.coerceFunction(content.abandonCallback);
		Locale.setText(mAbandonButton.label, "ABANDON");
		mKeepButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).keep_button, flash.display.MovieClip));
		mKeepButton.releaseCallback = ASCompat.coerceFunction(content.keepCallback);
		Locale.setText(mKeepButton.label, "KEEP");
		mOpenButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).open_button, flash.display.MovieClip));
		mOpenButton.releaseCallback = ASCompat.coerceFunction(content.openCallback);
		Locale.setText(mOpenButton.label, "UNLOCK");
		ChestInfo.loadItemIcon(_loc6_.IconSwf, _loc6_.IconName, ASCompat.coerce((mPopup : ASAny).content, flash.display.DisplayObjectContainer), mDBFacade,
			(150 : UInt), (150 : UInt), mAssetLoadingComponent);
		loadRarityBackground(_loc6_);
		loadKeyAndHeroInfo(_loc6_, ASCompat.coerceFunction(content.refreshHeroInfoCallback));
		mContentRenderer = new MovieClipRenderer(mDBFacade, ASCompat.coerce((mPopup : ASAny).content, flash.display.MovieClip));
		mContentRenderer.play((0 : UInt), true);
	}

	override function setupMenuNavigation() {
		mOpenButton.isAbove(mKeepButton);
		mAbandonButton.isToTheLeftOf(mKeepButton);
		mAbandonButton.upNavigation = mOpenButton;
	}

	override function getDefaultNavigationObject():UIObject {
		return mOpenButton;
	}

	override function getNavigationExitCallback():ASFunction {
		return rejectDismissal;
	}

	function loadRarityBackground(chest:GMChest) {
		var rarity = ASCompat.coerce(mDBFacade.gameMaster.rarityByConstant.itemFor(chest.Rarity), gameMasterDictionary.GMRarity);
		if (rarity == null || !rarity.HasColoredBackground) {
			return;
		}
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(rarity.BackgroundSwf), function(param1:SwfAsset) {
			var _loc3_ = param1.getClass(rarity.BackgroundIcon);
			if (_loc3_ == null) {
				return;
			}
			var _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), MovieClip);
			(mPopup : ASAny).content.addChildAt(_loc2_, 0);
			_loc2_.scaleX = _loc2_.scaleY = 1.5;
		});
	}

	function loadKeyAndHeroInfo(chest:GMChest, refreshHeroInfoCallback:ASFunction) {
		var matchingKey:KeyInfo = null;
		var key:KeyInfo;
		if (UIHud.isThisAConsumbleChestId((chest.Id : Int))) {
			return;
		}
		final __ax4_iter_33 = mDBFacade.dbAccountInfo.inventoryInfo.keys;
		if (checkNullIteratee(__ax4_iter_33))
			for (_tmp_ in __ax4_iter_33) {
				key = _tmp_;
				if (key.gmKey.ChestId == chest.Id) {
					matchingKey = key;
					break;
				}
			}
		if (matchingKey != null) {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(matchingKey.gmKeyOffer.BundleSwfFilepath), function(param1:SwfAsset) {
				var _loc3_ = param1.getClass(matchingKey.gmKeyOffer.BundleIcon);
				if (_loc3_ == null) {
					return;
				}
				var _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), MovieClip);
				_loc2_.scaleX = _loc2_.scaleY = 0.5;
				if (ASCompat.toNumberField((mOpenButton.root : ASAny).pick, "numChildren") > 1) {
					(mOpenButton.root : ASAny).pick.removeChildAt(1);
				}
				(mOpenButton.root : ASAny).pick.addChild(_loc2_);
			});
		}
		if (refreshHeroInfoCallback != null) {
			refreshHeroInfoCallback(mPopup);
			fitHeroLabel(ASCompat.coerce((mPopup : ASAny).hero_label, flash.text.TextField));
		}
	}

	function rejectDismissal() {}

	override public function destroy() {
		if (mDBFacade == null) {
			return;
		}
		if (mAbandonButton != null) {
			mAbandonButton.destroy();
		}
		if (mKeepButton != null) {
			mKeepButton.destroy();
		}
		if (mOpenButton != null) {
			mOpenButton.destroy();
		}
		if (mContentRenderer != null) {
			mContentRenderer.destroy();
		}
		mAbandonButton = null;
		mKeepButton = null;
		mOpenButton = null;
		mContentRenderer = null;
		super.destroy();
	}
}
