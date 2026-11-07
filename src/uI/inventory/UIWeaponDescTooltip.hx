package uI.inventory;

import brain.utils.TextUtil;
import facade.DBFacade;
import facade.GameMasterLocale;
import gameMasterDictionary.GMWeaponItem;
import flash.display.MovieClip;
import flash.text.TextField;

class UIWeaponDescTooltip extends MovieClip {
	var mDBFacade:DBFacade;

	var mRoot:MovieClip;

	var mDescription:TextField;

	public function new(dbFacade:DBFacade, templateClass:Dynamic) {
		super();
		mDBFacade = dbFacade;
		mRoot = ASCompat.coerce(ASCompat.createInstance(templateClass, []), flash.display.MovieClip);
		this.addChild(mRoot);
		mDescription = ASCompat.coerce((mRoot : ASAny).description_label, flash.text.TextField);
		mRoot.scaleX = mRoot.scaleY = UIWeaponTooltip.tooltipScale(mDescription, 1.55);
	}

	public function destroy() {
		mDBFacade = null;
		this.removeChild(mRoot);
		mRoot = null;
	}

	public function place(x:Int, y:Int) {
		mRoot.x = x;
		mRoot.y = y;
	}

	public function setWeaponItem(gmWeapon:GMWeaponItem, level:UInt, isLegendary:Bool = false) {
		TextUtil.setText(mDescription,
			GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_DESCRIPTION", gmWeapon.getWeaponAesthetic(level, isLegendary).WeaponItemConstant));
	}
}
