package modding;

import brain.assetRepository.SwfAsset;
import brain.uI.UIButton;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormatAlign;
import settings.model.SettingBuilder;
import settings.model.SettingCategory;
import settings.model.SettingDefinition;
import settings.model.SettingsModel;
import settings.view.SettingsList;
import settings.view.rows.KeyBindingSettingRow;
import settings.view.rows.SettingRow;

/**
 * The game's settings menu, opened to the mods: what the `api` mod builds its settings and keys on.
 * Not for mods, which declare theirs through the `api`.
 *
 * A setting added here is a definition of the game's catalog like the game's own: its row, its place in
 * the menu's reset, and for a key the game's rule that it is one action's. What differs is done here:
 * a tab of its own (`CATEGORY`), a header over each group, a row that is a button, and values that stay
 * out of the game's `settings.json`, since whoever added them keeps them.
 *
 * `modding.Hooks` has the game call this at four points: the settings file being written, a list of rows
 * shown, a row made, and the popup's art set up.
 */
@:access(modding.Host)
@:access(facade.Locale)
@:access(settings.model.SettingsCatalog)
@:access(settings.model.SettingsModel)
@:access(settings.view.SettingsList)
@:access(settings.view.rows.SettingRow)
class ModSettings {
	/** The tab the mods' own settings go to. Keys go to the game's `controls`. */
	public static inline final CATEGORY = "mods";

	static inline final CATEGORY_LABEL_KEY = "SETTINGS_CATEGORY_MODS";

	static inline final CATEGORY_LABEL = "MODS";

	static inline final POPUP_LINKAGE = "settings_popup";

	static final PANEL_NAME = ~/^panel_(\d+)$/;

	static inline final HEADER_COLOR = 0xFFC400;

	/** A header's text against a row's label. */
	static inline final HEADER_SCALE = 0.62;

	/** How small a label may get to fit its field: past that it is cut, as the game cuts its own. */
	static inline final SMALLEST = 0.6;

	/** How far the tabs start above where the game's six do, and the reset button sits below, in tabs. */
	static inline final TABS_RAISED = 0.22;

	static inline final RESET_LOWERED = 0.12;

	/** In the order they were added. */
	static var added:Array<ModSetting> = [];

	/** The headers of the list last shown. */
	static var headers:Array<Sprite> = [];

	static var warned:Bool = false;

	/**
	 * Adds a definition to the game's settings, after the others of its `group` in its tab: its value is
	 * then read from its binding. `group` is the header its rows show under. From `onReady`.
	 */
	public static function add(definition:SettingDefinition, group:String):Void {
		if (definition == null || find(definition) != null)
			return;
		var model = model();
		if (model == null)
			throw "modding.ModSettings.add: the game has no settings yet";
		place(model, new ModSetting(definition, group));
	}

	/**
	 * Adds a row that is a button: `label` names the row, `caption` the button, `run` is called when it
	 * is pressed. It holds no value. Returns its definition, to `remove`.
	 */
	public static function button(id:String, group:String, label:String, caption:String, run:Void->Void):SettingDefinition {
		var model = model();
		if (model == null)
			throw "modding.ModSettings.button: the game has no settings yet";
		var definition = new SettingBuilder(id, CATEGORY).literalText(label, "").build();
		var setting = new ModSetting(definition, group);
		setting.caption = caption;
		setting.run = run;
		place(model, setting);
		return definition;
	}

	/** Takes a definition `add` or `button` put in back out of the game's settings. */
	public static function remove(definition:SettingDefinition):Void {
		var setting = find(definition);
		if (setting == null)
			return;
		added.remove(setting);
		var model = model();
		if (model != null && model.mCatalog != null) {
			var definitions = model.mCatalog.mDefinitions;
			var at = definitions.indexOf(definition);
			if (at >= 0)
				definitions.splice(at, 1);
			model.mCatalog.mDefinitionsById.remove(definition.id);
			ASCompat.deleteProperty(model.mValues, definition.id);
			ASCompat.deleteProperty(model.mLoadedValues, definition.id);
			ASCompat.deleteProperty(model.mDirtyIds, definition.id);
		}
		if (!tabNeeded()) {
			var at = SettingCategory.ORDERED.indexOf(CATEGORY);
			if (at >= 0)
				SettingCategory.ORDERED.splice(at, 1);
		}
	}

	static function model():Null<SettingsModel> {
		return Host.facade == null ? null : Host.facade.settingsModel;
	}

	static function find(definition:SettingDefinition):Null<ModSetting> {
		for (setting in added)
			if (setting.definition == definition)
				return setting;
		return null;
	}

	static function tabNeeded():Bool {
		for (setting in added)
			if (setting.definition.category == CATEGORY)
				return true;
		return false;
	}

	static function place(model:SettingsModel, setting:ModSetting):Void {
		var definition = setting.definition;
		var definitions = model.mCatalog.mDefinitions;
		var after = -1;
		for (other in added)
			if (other.group == setting.group && other.definition.category == definition.category) {
				var at = definitions.indexOf(other.definition);
				if (at > after)
					after = at;
			}
		if (after < 0 || after == definitions.length - 1)
			definitions.push(definition);
		else
			definitions.insertAt(after + 1, definition);
		model.mCatalog.mDefinitionsById[definition.id] = definition;
		if (definition.binding != null) {
			var value:ASAny = definition.binding.read();
			model.mValues[definition.id] = value;
			model.mLoadedValues[definition.id] = value;
		}
		added.push(setting);
		// The menu's reset goes through the tabs in order: the mods' is one of them from then on.
		if (definition.category == CATEGORY && SettingCategory.ORDERED.indexOf(CATEGORY) < 0)
			SettingCategory.ORDERED.push(CATEGORY);
	}

	/** The game writes its `settings.json`: what was added here is kept by whoever added it. */
	public static function written(blob:ASObject):Void {
		if (blob == null)
			return;
		for (setting in added)
			ASCompat.deleteProperty(blob, setting.definition.id);
	}

	/** The game makes a row: a button's is made here, null for any other. */
	public static function row(facade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, index:Int):Null<SettingRow> {
		var setting = find(definition);
		if (setting == null || setting.run == null)
			return null;
		return new ActionRow(facade, swfAsset, definition, model, index, setting.caption, setting.run);
	}

	/** The game has built a tab's rows: each group gets its header, and a label too long is brought to fit. */
	public static function listShown(list:SettingsList):Void {
		try {
			dress(list);
		} catch (e:Dynamic) {
			warn("the settings rows keep no header: " + Host.errorText(e));
		}
	}

	static function dress(list:SettingsList):Void {
		for (header in headers)
			if (header.parent != null)
				header.parent.removeChild(header);
		headers = [];
		var rows = list.mRows;
		if (rows == null || rows.length == 0 || list.mScrollPane == null || added.length == 0)
			return;
		var holder:DisplayObjectContainer = list.mScrollPane.root;
		// Where the game's own labels start, the leftmost of them.
		var left = Math.POSITIVE_INFINITY;
		for (row in rows)
			if (row.mNameLabel != null && row.mNameLabel.x < left)
				left = row.mNameLabel.x;
		if (!Math.isFinite(left))
			left = 0;
		var shift = 0.0;
		var above:Null<String> = null;
		for (row in rows) {
			var setting = find(row.definition);
			var group = setting == null ? null : setting.group;
			if (group != null && group != above) {
				var header = makeHeader(group, row, left);
				header.y = row.root.y + shift;
				holder.addChild(header);
				headers.push(header);
				shift += header.height + 4;
			}
			above = group;
			row.root.y += shift;
			if (setting != null)
				fit(row.mNameLabel);
		}
		if (shift > 0) {
			list.mContentHeight += shift;
			list.updateScrollRange();
		}
	}

	/** A group's name over a line, in the lettering of the row under it. */
	static function makeHeader(name:String, row:SettingRow, left:Float):Sprite {
		var header = new Sprite();
		header.mouseEnabled = false;
		header.mouseChildren = false;
		var width:Float = row.root.width;
		var title = new TextField();
		var label = row.mNameLabel;
		if (label != null) {
			var format = label.length > 0 ? label.getTextFormat(0, 1) : label.defaultTextFormat;
			var size:Float = format.size == null ? 28 : format.size;
			format.size = Std.int(Math.max(10, size * HEADER_SCALE));
			format.color = HEADER_COLOR;
			format.align = TextFormatAlign.LEFT;
			title.embedFonts = label.embedFonts;
			title.defaultTextFormat = format;
			title.filters = label.filters;
		}
		title.selectable = false;
		title.mouseEnabled = false;
		title.text = name.toUpperCase();
		title.x = left;
		title.width = Math.max(40, width - left * 2);
		title.height = title.textHeight + 6;
		header.addChild(title);
		header.graphics.beginFill(HEADER_COLOR, 0.7);
		header.graphics.drawRect(left, title.height + 1, Math.max(40, width - left * 2), 2);
		header.graphics.endFill();
		return header;
	}

	/** A label wider than its field is made smaller in place, down to `SMALLEST`. */
	static function fit(label:Null<TextField>):Void {
		if (label == null || label.scaleX != 1 || label.scaleY != 1)
			return;
		var room = label.width - 4;
		var needed = label.textWidth;
		if (room <= 0 || needed <= room)
			return;
		var scale = Math.max(SMALLEST, room / needed);
		var width = label.width;
		var height = label.height;
		label.width = width / scale;
		label.scaleX = label.scaleY = scale;
		label.y += height * (1 - scale) / 2;
	}

	/**
	 * The game sets its popup's art up, before it makes a tab of each `panel_N` clip it finds there, top
	 * to bottom. The art has six, for the game's six tabs: while a mod has a setting of its own, a seventh
	 * is taken from a second copy of the art, and the seven are laid out in the room of the six, a little
	 * higher, the reset button a little lower.
	 */
	public static function popupArt(popup:MovieClip, swfAsset:SwfAsset):Void {
		try {
			if (popup != null && swfAsset != null && tabNeeded())
				addTab(popup, swfAsset);
		} catch (e:Dynamic) {
			warn("the settings menu has no tab for the mods: " + Host.errorText(e));
		}
	}

	static function addTab(popup:MovieClip, swfAsset:SwfAsset):Void {
		var panels = panelsOf(popup);
		var categories = SettingCategory.ORDERED.length;
		if (panels.length < 2 || panels.length >= categories)
			return;
		var art = swfAsset.getClass(POPUP_LINKAGE);
		if (art == null)
			throw "no " + POPUP_LINKAGE + " in the settings art";
		var copy:MovieClip = ASCompat.dynamicAs(ASCompat.createInstance(art, []), MovieClip);
		var spares = copy == null ? [] : panelsOf(copy);
		if (spares.length == 0)
			throw "no tab to copy in the settings art";
		var highest = 0;
		for (panel in panels)
			if (PANEL_NAME.match(panel.name))
				highest = Std.int(Math.max(highest, Std.parseInt(PANEL_NAME.matched(1))));
		var last = panels[panels.length - 1];
		var extra = spares[spares.length - 1];
		extra.name = "panel_" + (highest + 1);
		extra.x = last.x;
		extra.scaleX = last.scaleX;
		extra.scaleY = last.scaleY;
		popup.addChildAt(extra, popup.getChildIndex(last) + 1);

		// Seven tabs between a little above the first and the reset button, itself a little lower.
		var first = panels[0].getBounds(popup);
		var pitch = panels[1].getBounds(popup).top - first.top;
		var reset = resetButton(popup);
		var bottom = reset == null ? last.getBounds(popup).top + pitch : reset.getBounds(popup).top;
		var top = first.top - pitch * TABS_RAISED;
		if (reset != null)
			reset.y += pitch * RESET_LOWERED;
		panels.push(extra);
		var room = (bottom - top) / panels.length;
		var squeeze = Math.min(1, room / pitch);
		for (i in 0...panels.length) {
			var panel = panels[i];
			panel.scaleY *= squeeze;
			panel.y += top + i * room - panel.getBounds(popup).top;
		}
		// The game labels a tab from its texts, where the mods' has none.
		var table:ASObject = Locale.mDefaultStringTable;
		if (table != null && table.strings != null)
			table.strings[CATEGORY_LABEL_KEY] = CATEGORY_LABEL;
	}

	static function panelsOf(clip:MovieClip):Array<MovieClip> {
		var panels:Array<MovieClip> = [];
		for (i in 0...clip.numChildren) {
			var child = Std.downcast(clip.getChildAt(i), MovieClip);
			if (child != null && PANEL_NAME.match(child.name))
				panels.push(child);
		}
		panels.sort(function(a, b) return a.y < b.y ? -1 : (a.y > b.y ? 1 : 0));
		return panels;
	}

	/** The popup's reset button, as the game finds it. */
	static function resetButton(popup:MovieClip):Null<DisplayObject> {
		var named = popup.getChildByName("reset_button");
		if (named != null)
			return named;
		for (i in 0...popup.numChildren) {
			var child = Std.downcast(popup.getChildAt(i), MovieClip);
			if (child != null && Std.isOfType(child.getChildByName("reset_label"), TextField))
				return child;
		}
		return null;
	}

	static function warn(text:String):Void {
		if (warned)
			return;
		warned = true;
		Host.logNow("warn", "modding: " + text);
	}
}

/** One definition added to the game's settings, and the header it shows under. */
private class ModSetting {
	public var definition:SettingDefinition;

	public var group:String;

	/** A button's text and what it does; null for a setting with a value. */
	public var caption:Null<String>;

	public var run:Null<Void->Void>;

	public function new(definition:SettingDefinition, group:String) {
		this.definition = definition;
		this.group = group;
	}
}

/**
 * A row that is a button, on the art of the game's key row, the only one with a button: its first
 * button is kept, its second, its reset and their captions are hidden.
 */
@:access(modding.Host)
private class ActionRow extends SettingRow {
	static final HIDDEN = ["alternative_button", "reset_button", "Primary_Label", "Alternate_Label", "Reset_Label", "key_label"];

	var caption:String;

	var run:Void->Void;

	var button:Null<UIButton>;

	public function new(facade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, index:Int, caption:String,
			run:Void->Void) {
		super(facade, swfAsset, KeyBindingSettingRow.LINKAGE_NAME, definition, model, index);
		this.caption = caption;
		this.run = run;
	}

	override function bindControls() {
		for (name in HIDDEN) {
			var child = mRoot.getChildByName(name);
			if (child != null)
				child.visible = false;
		}
		var clip = clipNamed("primary_button");
		if (clip == null)
			return;
		button = new UIButton(mDBFacade, clip);
		button.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		button.releaseCallback = pressed;
		if (button.label != null)
			button.label.text = caption;
	}

	/** Chosen with a controller, where the row itself has the focus. */
	override public function onSelected(fromController:Bool = false) {
		pressed();
	}

	function pressed():Void {
		try {
			run();
		} catch (e:Dynamic) {
			Host.logNow("warn", "modding: a settings button failed: " + Host.errorText(e));
		}
	}

	override public function destroy() {
		if (button != null) {
			button.destroy();
			button = null;
		}
		super.destroy();
	}
}
