package uI.inventory;

import brain.utils.TextUtil;
import facade.DBFacade;
import flash.display.MovieClip;
import flash.text.TextField;

class UITapHoldTooltip extends MovieClip {
	var mDBFacade:DBFacade;

	var mRoot:MovieClip;

	var mTitle:TextField;

	var mDescription:TextField;

	public function new(dbFacade:DBFacade, templateClass:Dynamic) {
		super();
		mDBFacade = dbFacade;
		mRoot = ASCompat.coerce(ASCompat.createInstance(templateClass, []), flash.display.MovieClip);
		this.addChild(mRoot);
		mTitle = ASCompat.coerce((mRoot : ASAny).title_label, flash.text.TextField);
		mDescription = ASCompat.coerce((mRoot : ASAny).charge_description_label, flash.text.TextField);
		mRoot.scaleX = mRoot.scaleY = UIWeaponTooltip.tooltipScale(mDescription, 1.55);
	}

	public function destroy() {
		mDBFacade = null;
		this.removeChild(mRoot);
		mRoot = null;
	}

	public function setValues(name:String, desc:String) {
		TextUtil.setText(mTitle, name.toUpperCase());
		TextUtil.setText(mDescription, desc);
	}
}
