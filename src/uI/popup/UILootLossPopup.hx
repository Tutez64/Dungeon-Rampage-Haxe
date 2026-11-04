package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.render.MovieClipRenderer;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMChest;
import gameMasterDictionary.GMDoober;
import flash.display.MovieClip;
import flash.geom.Point;

class UILootLossPopup extends DBUITwoButtonPopup {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_screens.swf";

	static inline final POPUP_CLASS_NAME = "exitdungeon_popup";

	static final OPTIONS_BUTTON_POSITION:Point = new Point(190, 131);

	var movieClipRenderers:Vector<MovieClipRenderer>;

	var mXpLoss:UInt = 0;

	var mTreasure:Vector<UInt>;

	var mOptionsCallback:ASFunction;

	var mOptionsButton:ExitDungeonOptionsButton;

	public function new(dbFacade:DBFacade, xpLoss:UInt, treasure:Vector<UInt>, leftCallback:ASFunction, rightCallback:ASFunction,
			optionsCallback:ASFunction = null) {
		mXpLoss = xpLoss;
		mTreasure = treasure;
		mOptionsCallback = optionsCallback;
		super(dbFacade, "EXIT_DUNGEON", Locale.getString("UI_HUD_EXIT_TITLE"), Locale.getString("UI_HUD_EXIT_MESSAGE"),
			Locale.getString("UI_HUD_EXIT_CONFIRM"), leftCallback, Locale.getString("UI_HUD_EXIT_CANCEL"), rightCallback);
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		var treasure_icons:Array<ASAny>;
		var i:UInt;
		var gmDoober:GMDoober;
		var gmChestItem:GMChest;
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		if (mOptionsCallback != null) {
			mOptionsButton = new ExitDungeonOptionsButton(mDBFacade, mAssetLoadingComponent, mPopup, OPTIONS_BUTTON_POSITION, mCloseButton, mRightButton,
				mOptionsCallback);
		}
		movieClipRenderers = new Vector<MovieClipRenderer>();
		mDBFacade.metrics.log("LootLossPopupPresented");
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).XP_amount, flash.text.TextField), Std.string(mXpLoss) + " XP");
		if (mTreasure.length == 0) {
			return;
		}
		treasure_icons = [(mPopup : ASAny).treasure_icon_01, (mPopup : ASAny).treasure_icon_02];
		i = (0 : UInt);
		while (i < (mTreasure.length:UInt)) {
			gmDoober = ASCompat.coerce(mDBFacade.gameMaster.dooberById.itemFor(mTreasure[(i : Int)]), gameMasterDictionary.GMDoober);
			gmChestItem = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(gmDoober.ChestId), gameMasterDictionary.GMChest);
			if (gmChestItem != null && ASCompat.stringAsBool(gmChestItem.IconName)) {
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmChestItem.IconSwf), function(param1:SwfAsset) {
					var _loc3_ = param1.getClass(gmChestItem.IconName);
					var _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), MovieClip);
					_loc2_.scaleX = _loc2_.scaleY = 0.8;
					treasure_icons[(i : Int)].addChild(_loc2_);
					movieClipRenderers.push(new MovieClipRenderer(mDBFacade, _loc2_));
				});
			}
			i = i + 1;
		}
	}

	override function handleInputCalledClosed() {
		if (mDBFacade.hud != null) {
			mDBFacade.hud.suppressNextExitMenuToggle();
		}
		super.handleInputCalledClosed();
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_screens.swf";
	}

	override function getClassName():String {
		return "exitdungeon_popup";
	}

	override public function destroy() {
		var _loc1_ = (0 : UInt);
		if (movieClipRenderers != null) {
			_loc1_ = (0 : UInt);
			while (_loc1_ < (movieClipRenderers.length:UInt)) {
				movieClipRenderers[(_loc1_ : Int)].destroy();
				_loc1_++;
			}
		}
		if (mOptionsButton != null) {
			mOptionsButton.destroy();
			mOptionsButton = null;
		}
		mOptionsCallback = null;
		if (mDBFacade != null) {
			if (mDBFacade.hud != null) {
				mDBFacade.hud.clearExitMenu();
			}
		}
		movieClipRenderers = null;
		mTreasure = null;
		super.destroy();
	}
}
