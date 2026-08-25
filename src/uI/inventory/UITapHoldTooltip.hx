package uI.inventory;

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
		mRoot = ASCompat.dynamicAs(ASCompat.createInstance(templateClass, []), flash.display.MovieClip);
		this.addChild(mRoot);
		mTitle = ASCompat.dynamicAs((mRoot : ASAny).title_label, flash.text.TextField);
		mDescription = ASCompat.dynamicAs((mRoot : ASAny).charge_description_label, flash.text.TextField);
	}

	public function destroy() {
		mDBFacade = null;
		this.removeChild(mRoot);
		mRoot = null;
	}

	public function setValues(name:String, desc:String) {
		mTitle.text = name.toUpperCase();
		mDescription.text = desc;
	}
}
