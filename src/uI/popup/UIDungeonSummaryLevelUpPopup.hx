package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.render.MovieClipRenderController;
import brain.uI.UIButton;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMFeedPosts;
import gameMasterDictionary.GMSkin;
import flash.display.MovieClip;

class UIDungeonSummaryLevelUpPopup extends DBUIOneButtonPopup {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	static inline final POPUP_CLASS_NAME = "UI_prompt_levelup";

	static inline final AVATAR_PIC_SCALE:Float = 0.45;

	var mGMSkin:GMSkin;

	var mLevelUpPost:GMFeedPosts;

	var mPicClass:Dynamic;

	public function new(dbFacade:DBFacade, centerCallback:ASFunction, gmSkin:GMSkin, levelUpPost:GMFeedPosts, avatarClass:Dynamic) {
		mGMSkin = gmSkin;
		mLevelUpPost = levelUpPost;
		mPicClass = avatarClass;
		super(dbFacade, Locale.getString("INVITE_POPUP_TITLE"), Locale.getString("INVITE_POPUP_MESSAGE"), null, centerCallback, true, null, null, null, true,
			"DUNGEON_SUMMARY_LEVEL_UP_POPUP");
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
		avatarPic = ASCompat.dynamicAs(ASCompat.createInstance(mPicClass, []), flash.display.MovieClip);
		movieClipRenderer = new MovieClipRenderController(mDBFacade, avatarPic);
		movieClipRenderer.play();
		avatarPic.scaleX = avatarPic.scaleY = 0.45;
		(mPopup : ASAny).avatar.addChildAt(avatarPic, 0);
		ASCompat.setProperty((mPopup : ASAny).level_text, "text", mLevelUpPost.LevelTrigger);
		ASCompat.setProperty((mPopup : ASAny).congrats_label, "text", Locale.getString("LEVEL_UP_SHARE_TITLE"));
		ASCompat.setProperty((mPopup : ASAny).label, "text", Locale.getString("LEVEL_UP_SHARE_TEXT") + mLevelUpPost.LevelTrigger);
		levelUpButton = new UIButton(mDBFacade, ASCompat.dynamicAs((mPopup : ASAny).share, flash.display.MovieClip));
		if (mDBFacade.isDRPlayer) {
			levelUpButton.label.text = Locale.getString("SWEET");
		} else {
			levelUpButton.label.text = Locale.getString("LEVEL_UP_SHARE_BUTTON_TEXT");
		}
		levelUpButton.releaseCallback = function() {
			close(null);
		};
		mPopup.x = mDBFacade.viewWidth / 2;
		mPopup.y = mDBFacade.viewHeight / 2;
		mCloseButton.clearNavigationAndInteractions();
		mCloseButton.isAbove(levelUpButton);
	}
}
