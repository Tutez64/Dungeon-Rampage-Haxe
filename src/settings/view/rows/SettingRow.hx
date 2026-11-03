package settings.view.rows;

import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.uI.UIObject;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import settings.model.SettingDefinition;
import settings.model.SettingsModel;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.text.TextField;

class SettingRow extends UIObject {
	static inline final MISSING_STRING_PREFIX = "mia:";

	var mDBFacade:DBFacade;

	var mDefinition:SettingDefinition;

	var mModel:SettingsModel;

	var mRowIndex:Int = 0;

	var mNameLabel:TextField;

	var mDescriptionLabel:TextField;

	var mValueLabel:TextField;

	public var focusedCallback:ASFunction;

	var mFiltersBeforeHighlight:Array<ASAny>;

	public function new(dbFacade:DBFacade, swfAsset:SwfAsset, linkageName:String, definition:SettingDefinition, model:SettingsModel, rowIndex:Int) {
		super(dbFacade, instantiate(swfAsset, linkageName));
		mDBFacade = dbFacade;
		mDefinition = definition;
		mModel = model;
		mRowIndex = rowIndex;
	}

	static function localised(key:String):String {
		var _loc2_ = Locale.getString(key);
		if (_loc2_ == null || _loc2_.indexOf("mia:") == 0) {
			return "";
		}
		return _loc2_;
	}

	static function instantiate(swfAsset:SwfAsset, linkageName:String):MovieClip {
		var _loc3_ = swfAsset.getClass(linkageName);
		if (_loc3_ == null) {
			Logger.warn("Settings row art missing from swf: " + linkageName);
			return new MovieClip();
		}
		return ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), MovieClip);
	}

	@:isVar public var definition(get, never):SettingDefinition;

	public function get_definition():SettingDefinition {
		return mDefinition;
	}

	@:isVar public var height(get, never):Float;

	public function get_height():Float {
		return mRoot != null ? mRoot.height : 0;
	}

	public function build() {
		mNameLabel = fieldNamed("Name_Label");
		mDescriptionLabel = fieldNamed("Description_Label");
		mValueLabel = fieldNamed("Value_Label");
		if (mNameLabel != null) {
			mNameLabel.text = nameText();
		}
		mRoot.buttonMode = isActivatable;
		applyZebraShading();
		bindControls();
		refreshFromModel();
	}

	function bindControls() {}

	public function refreshFromModel() {
		updateDescription();
	}

	function onRowActivated() {}

	public function nudgeDown() {}

	public function nudgeUp() {}

	function updateDescription() {
		if (mDescriptionLabel == null) {
			return;
		}
		var _loc1_:Array<ASAny> = [];
		var _loc2_:String = mDefinition.descriptionKeyProvider != null ? mDefinition.descriptionKeyProvider() : mDefinition.descriptionKey;
		var _loc3_ = mDefinition.descriptionText ?? localised(_loc2_);
		if (_loc3_.length > 0) {
			_loc1_.push(_loc3_);
		}
		if (mDefinition.requiresRestart) {
			_loc1_.push(Locale.getString("SETTINGS_REQUIRES_RESTART"));
		}
		mDescriptionLabel.text = _loc1_.join("   ");
	}

	function nameText():String {
		return mDefinition.labelText ?? Locale.getString(mDefinition.labelKey);
	}

	function applyZebraShading() {
		if ((mRoot : ASAny).hasOwnProperty("dark_row_1") && (mRoot : ASAny).hasOwnProperty("dark_row_2")) {
			ASCompat.setProperty((mRoot : ASAny).dark_row_1, "visible", mRowIndex % 2 == 0);
			ASCompat.setProperty((mRoot : ASAny).dark_row_2, "visible", mRowIndex % 2 != 0);
		}
	}

	function fieldNamed(name:String):TextField {
		if (mRoot != null && (mRoot : ASAny).hasOwnProperty(name)) {
			return ASCompat.dynamicAs((mRoot : ASAny)[name], TextField);
		}
		return null;
	}

	function clipNamed(name:String):MovieClip {
		if (mRoot != null && (mRoot : ASAny).hasOwnProperty(name)) {
			return ASCompat.dynamicAs((mRoot : ASAny)[name], MovieClip);
		}
		return null;
	}

	override function addListeners() {
		super.addListeners();
		mRoot.addEventListener("click", onRootClicked);
	}

	override function removeListeners() {
		super.removeListeners();
		mRoot.removeEventListener("click", onRootClicked);
	}

	@:isVar var isActivatable(get, never):Bool;

	function get_isActivatable():Bool {
		return false;
	}

	function onRootClicked(event:MouseEvent) {
		onRowActivated();
	}

	override public function onSelected(fromController:Bool = false) {
		onRowActivated();
	}

	override function onRollOver(event:MouseEvent) {
		super.onRollOver(event);
		if (mRoot == null) {
			return;
		}
		mFiltersBeforeHighlight = mRoot.filters;
		mRoot.filters = cast([DBGlobal.UI_ROLLOVER_FILTER]);
		if (focusedCallback != null) {
			focusedCallback(this);
		}
	}

	override function onRollOut(event:MouseEvent) {
		super.onRollOut(event);
		if (mRoot == null) {
			return;
		}
		mRoot.filters = cast(mFiltersBeforeHighlight ?? []);
		mFiltersBeforeHighlight = null;
	}

	override public function destroy() {
		focusedCallback = null;
		mFiltersBeforeHighlight = null;
		mDefinition = null;
		mModel = null;
		mDBFacade = null;
		mNameLabel = null;
		mDescriptionLabel = null;
		mValueLabel = null;
		super.destroy();
	}
}
