package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.render.MovieClipRenderController;
import brain.uI.UIButton;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMSkin;
import flash.display.MovieClip;

class UIDungeonSummaryLevelUpPopup extends DBUIOneButtonPopup {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	static inline final POPUP_CLASS_NAME = "UI_prompt_levelup";

	static inline final AVATAR_PIC_SCALE:Float = 0.45;

	public static final LEVELS:Vector<UInt> = Vector.ofArray(([
		(3 : UInt),
		(4 : UInt),
		(5 : UInt),
		(10 : UInt),
		(15 : UInt),
		(20 : UInt),
		(25 : UInt),
		(30 : UInt),
		(40 : UInt),
		(50 : UInt),
		(60 : UInt),
		(70 : UInt),
		(80 : UInt),
		(90 : UInt),
		(100 : UInt)
	] : Array<UInt>));

	var mGMSkin:GMSkin;

	var mLevel:UInt = 0;

	var mPicClass:Dynamic;

	public function new(dbFacade:DBFacade, centerCallback:ASFunction, gmSkin:GMSkin, level:UInt, avatarClass:Dynamic) {
		mGMSkin = gmSkin;
		mLevel = level;
		mPicClass = avatarClass;
		super(dbFacade, "DUNGEON_SUMMARY_LEVEL_UP_POPUP", Locale.getString("INVITE_POPUP_TITLE"), Locale.getString("INVITE_POPUP_MESSAGE"), null,
			centerCallback);
		mDBFacade.metrics.log("InvitePopupPresented");
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_town.swf";
	}

	override function getClassName():String {
		return "UI_prompt_levelup";
	}

	override function centerButtonCallback() {
		mDBFacade.metrics.log("InvitePopupContinue");
		super.centerButtonCallback();
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		var avatarPic:MovieClip;
		var movieClipRenderer:MovieClipRenderController;
		var levelUpButton:UIButton;
		super.setupUI(swfAsset, titleText, null, allowClose, closeCallback);
		mPopup.x += 40;
		avatarPic = ASCompat.coerce(ASCompat.createInstance(mPicClass, []), flash.display.MovieClip);
		movieClipRenderer = new MovieClipRenderController(mDBFacade, avatarPic);
		movieClipRenderer.play();
		avatarPic.scaleX = avatarPic.scaleY = 0.45;
		(mPopup : ASAny).avatar.addChildAt(avatarPic, 0);
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).level_text, flash.text.TextField), Std.string(mLevel));
		Locale.setText(ASCompat.coerce((mPopup : ASAny).congrats_label, flash.text.TextField), "LEVEL_UP_SHARE_TITLE");
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).label, flash.text.TextField), Locale.getString("LEVEL_UP_SHARE_TEXT") + mLevel);
		levelUpButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).share, flash.display.MovieClip));
		Locale.setText(levelUpButton.label, "SWEET");
		levelUpButton.releaseCallback = function() {
			close(null);
		};
		mPopup.x = mDBFacade.viewWidth / 2;
		mPopup.y = mDBFacade.viewHeight / 2;
		mCloseButton.clearNavigationAndInteractions();
		mCloseButton.isAbove(levelUpButton);
	}
}
