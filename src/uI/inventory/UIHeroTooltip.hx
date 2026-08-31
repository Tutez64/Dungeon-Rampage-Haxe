package uI.inventory;

import account.AvatarInfo;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMHero;
import flash.display.MovieClip;
import flash.text.TextField;

class UIHeroTooltip extends MovieClip {
	var mDBFacade:DBFacade;

	var mRoot:MovieClip;

	var mLabel:TextField;

	var mLevelLabel:TextField;

	var mDescriptionLabel:TextField;

	var mStar:MovieClip;

	public function new(dbFacade:DBFacade, templateClass:Dynamic) {
		super();
		mDBFacade = dbFacade;
		mRoot = ASCompat.dynamicAs(ASCompat.createInstance(templateClass, []), flash.display.MovieClip);
		this.addChild(mRoot);
		mLabel = ASCompat.dynamicAs((mRoot : ASAny).title_label, flash.text.TextField);
		mLevelLabel = ASCompat.dynamicAs((mRoot : ASAny).level_star_label, flash.text.TextField);
		mDescriptionLabel = ASCompat.dynamicAs((mRoot : ASAny).description_label, flash.text.TextField);
		mStar = ASCompat.dynamicAs((mRoot : ASAny).star, flash.display.MovieClip);
	}

	public function destroy() {
		mDBFacade = null;
		this.removeChild(mRoot);
		mRoot = null;
	}

	@:isVar public var ownedHero(never, set):AvatarInfo;

	public function set_ownedHero(avatarInfo:AvatarInfo):AvatarInfo {
		mLabel.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME", avatarInfo.gmHero.Constant).toUpperCase();
		mLevelLabel.text = Std.string(avatarInfo.level);
		mLevelLabel.visible = true;
		mStar.visible = true;
		mDescriptionLabel.visible = false;
		return avatarInfo;
	}

	@:isVar public var unownedHero(never, set):GMHero;

	public function set_unownedHero(gmHero:GMHero):GMHero {
		mLabel.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME", gmHero.Constant).toUpperCase();
		mLevelLabel.visible = false;
		mStar.visible = false;
		mDescriptionLabel.text = Locale.getString("HERO_NOT_UNLOCKED_TOOLTIP");
		mDescriptionLabel.visible = true;
		return gmHero;
	}
}
