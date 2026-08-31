package brain.assetRepository;

import brain.logger.Logger;
import flash.display.MovieClip;
#if cpp
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.media.Sound;
import flash.text.TextField;
import flash.text.TextFormat;
import haxe.ds.StringMap;
import haxe.io.Path;
import lime.utils.AssetBundle;
import openfl.utils.AssetLibrary;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import swf.exporters.animate.AnimateButtonSymbol;
import swf.exporters.animate.AnimateDynamicTextSymbol;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateSpriteSymbol;
import swf.exporters.animate.AnimateSymbol;
import swf.exporters.animate.AnimateTimeline;
import sys.FileSystem;
#end

#if cpp
@:access(openfl.display.MovieClip)
@:access(swf.exporters.animate.AnimateLibrary)
@:access(swf.exporters.animate.AnimateSpriteSymbol)
@:access(swf.exporters.animate.AnimateTimeline)
#end
class SwfAsset extends Asset {
	#if cpp
	static var sLoadedPreprocessedLibraries:StringMap<AssetLibrary> = new StringMap<AssetLibrary>();
	static var sFailedPreprocessedLibraries:StringMap<Bool> = new StringMap<Bool>();
	static var sFontMaps:StringMap<StringMap<String>> = new StringMap<StringMap<String>>();
	#end

	var mRootClip:MovieClip;

	var mSwfPath:String;

	var mHdRootClip:MovieClip = null;

	var mHdSwfPath:String = null;

	#if cpp
	var mPreprocessedLibraryName:String = null;
	var mPreprocessedLibrary:AssetLibrary = null;
	var mHdPreprocessedLibraryName:String = null;
	var mHdPreprocessedLibrary:AssetLibrary = null;
	var mPreprocessedRootObject:MovieClip = null;
	var mRootInstancePropertiesApplied:Bool = false;
	#end

	public function new(rootClip:MovieClip, swfPath:String) {
		mRootClip = rootClip;
		mSwfPath = swfPath;
		#if cpp
		mPreprocessedLibraryName = getPreprocessedLibraryId(swfPath);
		#end
		super();
	}

	override public function destroy() {
		#if cpp
		unloadSwfRoot(mRootClip);
		mRootClip = null;
		mSwfPath = null;
		mPreprocessedLibrary = null;
		mHdPreprocessedLibrary = null;
		if (mPreprocessedRootObject != null) {
			unloadSwfRoot(mPreprocessedRootObject);
			mPreprocessedRootObject = null;
		}
		if (mHdRootClip != null) {
			unloadSwfRoot(mHdRootClip);
			mHdRootClip = null;
		}
		mHdSwfPath = null;
		#else
		mRootClip.loaderInfo.loader.unloadAndStop();
		mRootClip = null;
		if (mHdRootClip != null) {
			mHdRootClip.loaderInfo.loader.unloadAndStop();
			mHdRootClip = null;
		}
		#end
	}

	@:isVar public var swfPath(get, never):String;

	public function get_swfPath():String {
		return mSwfPath;
	}

	public function setHdAsset(hdRootClip:MovieClip, hdSwfPath:String) {
		mHdRootClip = hdRootClip;
		mHdSwfPath = hdSwfPath;
		#if cpp
		mHdPreprocessedLibraryName = getPreprocessedLibraryId(hdSwfPath);
		#end
	}

	@:isVar public var hasHdAsset(get, never):Bool;

	public function get_hasHdAsset():Bool {
		return mHdRootClip != null;
	}

	@:isVar public var hdSwfPath(get, never):String;

	public function get_hdSwfPath():String {
		return mHdSwfPath;
	}

	@:isVar public var root(get, never):MovieClip;

	public function get_root():MovieClip {
		#if cpp
		if (mRootClip != null) {
			ensurePreprocessedLibrariesLoaded();
			if (!mRootInstancePropertiesApplied) {
				applyRootInstanceProperties(mRootClip, mPreprocessedLibrary, mSwfPath);
				mRootInstancePropertiesApplied = true;
			}
			return mRootClip;
		}
		ensurePreprocessedLibrariesLoaded();
		if (mPreprocessedRootObject == null) {
			mPreprocessedRootObject = instantiatePreprocessedRootObject(mPreprocessedLibrary, mSwfPath);
			if (mPreprocessedRootObject != null) {
				applyRootInstanceProperties(mPreprocessedRootObject, mPreprocessedLibrary, mSwfPath);
				applyExportedFonts(mPreprocessedRootObject, mPreprocessedLibraryName, mSwfPath);
			}
		}
		return mPreprocessedRootObject;
		#else
		return mRootClip;
		#end
	}

	public function getClass(className:String, suppressWarnings:Bool = false):Dynamic {
		#if cpp
		var hdDomain = getApplicationDomain(mHdRootClip);
		var rootDomain = getApplicationDomain(mRootClip);
		if (hdDomain != null && hdDomain.hasDefinition(className)) {
			return (hdDomain.getDefinition(className) : Dynamic);
		}
		if (rootDomain != null && rootDomain.hasDefinition(className)) {
			return (rootDomain.getDefinition(className) : Dynamic);
		}
		if (hasPreprocessedAsset(className)) {
			return cast((new SwfClassProxy(this, className) : Dynamic));
		}
		if (!suppressWarnings) {
			if (rootDomain == null) {
				Logger.warn("Could not resolve applicationDomain for SwfAsset "
					+ mSwfPath
					+ " while looking for class: "
					+ className
					+ ". rootType="
					+ objectTypeName(mRootClip)
					+ (mHdRootClip != null ? " hdRootType=" + objectTypeName(mHdRootClip) : ""));
			} else {
				Logger.warn("Could not find class name: "
					+ className
					+ " in SwfAsset "
					+ mSwfPath
					+ (mHdSwfPath != null ? " or HD asset " + mHdSwfPath : ""));
			}
		}
		return Type.resolveClass(className);
		#else
		if (mHdRootClip != null && mHdRootClip.loaderInfo.applicationDomain.hasDefinition(className)) {
			return (mHdRootClip.loaderInfo.applicationDomain.getDefinition(className) : Dynamic);
		}
		if (!mRootClip.loaderInfo.applicationDomain.hasDefinition(className)) {
			if (!suppressWarnings) {
				Logger.warn("Could not find class name: "
					+ className
					+ " in SwfAsset "
					+ mRootClip.loaderInfo.url
					+ (mHdRootClip != null ? " or HD asset " + mHdRootClip.loaderInfo.url : ""));
			}
			return null;
		}
		return (mRootClip.loaderInfo.applicationDomain.getDefinition(className) : Dynamic);
		#end
	}

	#if cpp
	public static function getPreprocessedLibraryId(swfPath:String):String {
		var normalized = normalizeSwfAssetPath(swfPath).toLowerCase();
		var buf = new StringBuf();
		var i:Int = 0;
		var ch:String = null;
		buf.add("ax4_swf_");
		i = 0;
		while (i < normalized.length) {
			ch = normalized.charAt(i);
			if ((ch >= "a" && ch <= "z") || (ch >= "0" && ch <= "9")) {
				buf.add(ch);
			} else {
				buf.add("_");
			}
			i++;
		}
		return ~/[_]+/g.replace(buf.toString(), "_");
	}

	public static function hasPreprocessedBundleForPath(swfPath:String):Bool {
		return FileSystem.exists(getPreprocessedBundlePath(getPreprocessedLibraryId(swfPath)));
	}

	static function normalizeSwfAssetPath(path:String):String {
		if (path == null) {
			return "";
		}
		path = StringTools.replace(path, "\\", "/");
		while (StringTools.startsWith(path, "./")) {
			path = path.substr(2);
		}
		return path;
	}

	public function instantiateRuntimeSymbol(className:String, args:Array<Dynamic>):Dynamic {
		var instance = instantiatePreprocessedSymbol(className);
		if (instance != null) {
			return instance;
		}
		instance = instantiateFromLoadedRoot(className);
		if (instance != null) {
			bindTimelineFields(instance);
			return instance;
		}
		Logger.warn("SwfAsset.instantiateRuntimeSymbol: failed to instantiate symbol " + className + " in " + mSwfPath);
		return null;
	}

	function hasPreprocessedAsset(className:String):Bool {
		ensurePreprocessedLibrariesLoaded();
		if (className == null) {
			return false;
		}
		return libraryHasPreprocessedSymbol(mHdPreprocessedLibrary, className) || libraryHasPreprocessedSymbol(mPreprocessedLibrary, className);
	}

	function libraryHasPreprocessedSymbol(library:AssetLibrary, className:String):Bool {
		if (library == null || className == null) {
			return false;
		}
		return library.exists(className, null);
	}

	function instantiatePreprocessedSymbol(className:String):Dynamic {
		ensurePreprocessedLibrariesLoaded();
		var instance = instantiatePreprocessedFromSource(mHdPreprocessedLibrary, mHdPreprocessedLibraryName, className);
		if (instance != null) {
			return instance;
		}
		return instantiatePreprocessedFromSource(mPreprocessedLibrary, mPreprocessedLibraryName, className);
	}

	function instantiatePreprocessedFromSource(library:AssetLibrary, libraryName:String, className:String):Dynamic {
		return instantiatePreprocessedSymbolFromLibrary(library, libraryName, className);
	}

	function instantiatePreprocessedSymbolFromLibrary(library:AssetLibrary, libraryName:String, className:String):Dynamic {
		var clip:MovieClip = null;
		var audio = null;
		if (library == null || className == null) {
			return null;
		}
		if (library.exists(className, cast AssetType.MOVIE_CLIP)) {
			clip = library.getMovieClip(className);
			if (clip != null) {
				bindTimelineFields(clip);
				applyExportedFonts(clip, libraryName, mSwfPath);
				return clip;
			}
		}
		if (library.exists(className, cast AssetType.SOUND) || library.exists(className, cast AssetType.MUSIC)) {
			audio = library.getAudioBuffer(className);
			if (audio != null) {
				return Sound.fromAudioBuffer(audio);
			}
		}
		if (libraryName != null && Assets.exists(libraryName + ":" + className, cast AssetType.IMAGE)) {
			return Assets.getBitmapData(libraryName + ":" + className);
		}
		return null;
	}

	function ensurePreprocessedLibrariesLoaded():Void {
		if (mHdPreprocessedLibrary == null && mHdPreprocessedLibraryName != null) {
			mHdPreprocessedLibrary = loadPreprocessedLibrarySync(mHdPreprocessedLibraryName, mHdSwfPath);
		}
		if (mPreprocessedLibrary == null && mPreprocessedLibraryName != null) {
			mPreprocessedLibrary = loadPreprocessedLibrarySync(mPreprocessedLibraryName, mSwfPath);
		}
	}

	public function preloadPreprocessedLibraries():Void {
		ensurePreprocessedLibrariesLoaded();
	}

	function applyRootInstanceProperties(clip:MovieClip, library:AssetLibrary, swfPath:String):Void {
		var animateLibrary:AnimateLibrary = null;
		var properties:Dynamic = null;
		var field:String = null;
		if (clip == null || library == null) {
			return;
		}
		animateLibrary = Std.isOfType(library, AnimateLibrary) ? cast library : null;
		if (animateLibrary == null) {
			return;
		}
		properties = animateLibrary.getRootInstanceProperties();
		if (properties == null) {
			return;
		}
		for (field in Reflect.fields(properties)) {
			try {
				ASCompat.setProperty(clip, field, cloneInstanceProperty(Reflect.field(properties, field)));
			} catch (e:Dynamic) {
				Logger.warn("SwfAsset.applyRootInstanceProperties: failed to set field " + field + " on " + swfPath + ": " + Std.string(e));
			}
		}
	}

	function cloneInstanceProperty(value:Dynamic):Dynamic {
		var clonedArray:Array<Dynamic> = null;
		var cloned:Dynamic = null;
		var field:String = null;
		if (value == null || Std.isOfType(value, String) || Std.isOfType(value, Bool) || Std.isOfType(value, Int) || Std.isOfType(value, Float)) {
			return value;
		}
		if (Std.isOfType(value, Array)) {
			clonedArray = [];
			for (item in cast(value, Array<Dynamic>)) {
				clonedArray.push(cloneInstanceProperty(item));
			}
			return clonedArray;
		}
		cloned = {};
		for (field in Reflect.fields(value)) {
			Reflect.setField(cloned, field, cloneInstanceProperty(Reflect.field(value, field)));
		}
		return cloned;
	}

	function instantiatePreprocessedRootObject(library:AssetLibrary, swfPath:String):MovieClip {
		var animateLibrary:AnimateLibrary = null;
		if (library == null) {
			return null;
		}
		animateLibrary = Std.isOfType(library, AnimateLibrary) ? cast library : null;
		if (animateLibrary == null) {
			return null;
		}
		try {
			return animateLibrary.getMovieClip("");
		} catch (e:Dynamic) {
			Logger.warn("SwfAsset.instantiatePreprocessedRootObject: failed for " + swfPath + ": " + Std.string(e));
		}
		return null;
	}

	function applyExportedFonts(target:DisplayObject, libraryName:String, swfPath:String):Void {
		var fontMap:StringMap<String> = null;
		if (target == null || libraryName == null) {
			return;
		}
		fontMap = getExportedFontMap(libraryName);
		if (fontMap == null) {
			return;
		}
		applyExportedFontsRecursive(target, fontMap, swfPath);
	}

	function applyExportedFontsRecursive(target:DisplayObject, fontMap:StringMap<String>, swfPath:String):Void {
		var textField:TextField = ASCompat.dynamicAs(target, TextField);
		var container:DisplayObjectContainer = null;
		var i:Int = 0;
		if (textField != null) {
			applyExportedFontToTextField(textField, fontMap, swfPath);
		}
		container = ASCompat.dynamicAs(target, DisplayObjectContainer);
		if (container != null) {
			i = 0;
			while (i < container.numChildren) {
				applyExportedFontsRecursive(container.getChildAt(i), fontMap, swfPath);
				i++;
			}
		}
	}

	function applyExportedFontToTextField(textField:TextField, fontMap:StringMap<String>, swfPath:String):Void {
		var format:TextFormat = null;
		var lookup:String = null;
		var fontPath:String = null;
		try {
			format = textField.defaultTextFormat;
			if (format == null || format.font == null) {
				return;
			}
			lookup = normalizeFontLookupName(format.font);
			fontPath = fontMap.get(lookup);
			if (fontPath == null) {
				return;
			}
			format.font = fontPath;
			textField.embedFonts = true;
			textField.defaultTextFormat = format;
			if (textField.length > 0) {
				format = textField.getTextFormat();
				format.font = fontPath;
				textField.setTextFormat(format);
			}
		} catch (e:Dynamic) {
			Logger.warn("SwfAsset.applyExportedFontToTextField: failed for " + swfPath + ": " + Std.string(e));
		}
	}

	public static function applyExportedFontsForBind(target:DisplayObject, libraryName:String, className:String = ""):Void {
		var timeline:AnimateTimeline = null;
		var fontIds:Array<Int> = null;
		var fontPath:String = null;
		if (target == null || libraryName == null) {
			return;
		}
		if (className == null || className.length == 0) {
			className = Type.getClassName(Type.getClass(target));
		}
		timeline = getBindTimeline(target);
		if (timeline == null || timeline.__library == null || timeline.__symbol == null) {
			return;
		}
		fontIds = collectDynamicTextFontIDs(timeline.__library, timeline.__symbol);
		if (fontIds.length == 0) {
			return;
		}
		if (fontIds.length == 1) {
			fontPath = getExportedFontPathById(libraryName, fontIds[0]);
			if (fontPath != null) {
				applyExportedFontPathRecursive(target, fontPath, className);
			}
			return;
		}
		applyExportedFontsForBindRecursive(target, libraryName, className);
	}

	static function applyExportedFontsForBindRecursive(target:DisplayObject, libraryName:String, className:String):Void {
		var textField:TextField = ASCompat.dynamicAs(target, TextField);
		var container:DisplayObjectContainer = null;
		var i:Int = 0;
		var fontId:Int = 0;
		var fontPath:String = null;
		if (textField != null) {
			fontId = resolveBindFontId(textField);
			if (fontId >= 0) {
				fontPath = getExportedFontPathById(libraryName, fontId);
				if (fontPath != null) {
					applyExportedFontPathToTextField(textField, fontPath, className);
				}
			}
			return;
		}
		container = ASCompat.dynamicAs(target, DisplayObjectContainer);
		if (container != null) {
			i = 0;
			while (i < container.numChildren) {
				applyExportedFontsForBindRecursive(container.getChildAt(i), libraryName, className);
				i++;
			}
		}
	}

	static function resolveBindFontId(target:DisplayObject):Int {
		var current:DisplayObject = target;
		var timeline:AnimateTimeline = null;
		var fontIds:Array<Int> = null;
		while (current != null && current.parent != null) {
			timeline = getBindTimeline(current.parent);
			if (timeline != null) {
				fontIds = getFontIDsForBindChild(timeline, current);
				if (fontIds.length == 1) {
					return fontIds[0];
				}
			}
			current = current.parent;
		}
		return -1;
	}

	static function getBindTimeline(target:DisplayObject):AnimateTimeline {
		var clip = ASCompat.dynamicAs(target, MovieClip);
		if (clip == null || clip.__timeline == null) {
			return null;
		}
		if (!Std.isOfType(clip.__timeline, AnimateTimeline)) {
			return null;
		}
		return cast clip.__timeline;
	}

	static function getFontIDsForBindChild(timeline:AnimateTimeline, child:DisplayObject):Array<Int> {
		var instances:Array<Dynamic> = null;
		var instance:Dynamic = null;
		if (timeline.__activeInstances == null || timeline.__library == null || timeline.__library.symbols == null) {
			return [];
		}
		instances = cast timeline.__activeInstances;
		for (instance in instances) {
			if (instance.displayObject == child) {
				return collectDynamicTextFontIDs(timeline.__library, timeline.__library.symbols.get(instance.characterID));
			}
		}
		return [];
	}

	static function collectDynamicTextFontIDs(library:AnimateLibrary, symbol:AnimateSymbol):Array<Int> {
		var fontIds = new Array<Int>();
		if (library == null || library.symbols == null || symbol == null) {
			return fontIds;
		}
		collectDynamicTextFontIDsRecursive(library, symbol, new Map(), fontIds);
		return fontIds;
	}

	static function collectDynamicTextFontIDsRecursive(library:AnimateLibrary, symbol:AnimateSymbol, seen:Map<Int, Bool>, fontIds:Array<Int>):Void {
		var button:AnimateButtonSymbol = null;
		var sprite:AnimateSpriteSymbol = null;
		var fontId:Int = 0;
		if (symbol == null || seen.exists(symbol.id)) {
			return;
		}
		seen.set(symbol.id, true);
		if (Std.isOfType(symbol, AnimateDynamicTextSymbol)) {
			fontId = cast(symbol, AnimateDynamicTextSymbol).fontID;
			if (fontIds.indexOf(fontId) == -1) {
				fontIds.push(fontId);
			}
			return;
		}
		if (Std.isOfType(symbol, AnimateButtonSymbol)) {
			button = cast symbol;
			collectDynamicTextFontIDsRecursive(library, button.upState, seen, fontIds);
			collectDynamicTextFontIDsRecursive(library, button.overState, seen, fontIds);
			collectDynamicTextFontIDsRecursive(library, button.downState, seen, fontIds);
			collectDynamicTextFontIDsRecursive(library, button.hitState, seen, fontIds);
			return;
		}
		if (!Std.isOfType(symbol, AnimateSpriteSymbol)) {
			return;
		}
		sprite = cast symbol;
		if (sprite.frames != null) {
			for (frame in sprite.frames) {
				if (frame.objects == null) {
					continue;
				}
				for (object in frame.objects) {
					collectDynamicTextFontIDsRecursive(library, library.symbols.get(object.symbol), seen, fontIds);
				}
			}
		}
		if (sprite.compactTimeline != null) {
			fontId = 0;
			while (fontId < sprite.compactTimeline.objects.length) {
				collectDynamicTextFontIDsRecursive(library, library.symbols.get(Std.int(sprite.compactTimeline.objects[fontId + 2])), seen, fontIds);
				fontId = sprite.compactTimeline.getNextObjectPosition(fontId);
			}
		}
	}

	static function applyExportedFontPathRecursive(target:DisplayObject, fontPath:String, className:String):Void {
		var textField:TextField = ASCompat.dynamicAs(target, TextField);
		var container:DisplayObjectContainer = null;
		var i:Int = 0;
		if (textField != null) {
			applyExportedFontPathToTextField(textField, fontPath, className);
		}
		container = ASCompat.dynamicAs(target, DisplayObjectContainer);
		if (container != null) {
			i = 0;
			while (i < container.numChildren) {
				applyExportedFontPathRecursive(container.getChildAt(i), fontPath, className);
				i++;
			}
		}
	}

	static function applyExportedFontPathToTextField(textField:TextField, fontPath:String, className:String):Void {
		var format:TextFormat = null;
		try {
			format = textField.defaultTextFormat;
			if (format == null || format.font == null || isDeviceFontName(format.font)) {
				return;
			}
			format.font = fontPath;
			textField.embedFonts = true;
			textField.defaultTextFormat = format;
			if (textField.length > 0) {
				format = textField.getTextFormat();
				format.font = fontPath;
				textField.setTextFormat(format);
			}
		} catch (e:Dynamic) {
			Logger.warn("SwfAsset.applyExportedFontPathToTextField: failed for " + className + ": " + Std.string(e));
		}
	}

	static function getExportedFontPathById(libraryName:String, fontId:Int):String {
		var directory:String = null;
		var prefix:String = null;
		var entry:String = null;
		directory = getExportedFontDirectory(libraryName);
		if (directory == null || !FileSystem.exists(directory) || !FileSystem.isDirectory(directory)) {
			return null;
		}
		prefix = Std.string(fontId) + "_";
		for (entry in FileSystem.readDirectory(directory)) {
			if (StringTools.startsWith(entry, prefix)) {
				prefix = entry.toLowerCase();
				if (StringTools.endsWith(prefix, ".ttf") || StringTools.endsWith(prefix, ".otf")) {
					return Path.normalize(Path.join([directory, entry]));
				}
			}
		}
		return null;
	}

	static function getExportedFontMap(libraryName:String):StringMap<String> {
		var fontMap:StringMap<String> = null;
		var directory:String = null;
		var entry:String = null;
		var lookup:String = null;
		var separator:Int = 0;
		if (sFontMaps.exists(libraryName)) {
			return sFontMaps.get(libraryName);
		}
		fontMap = new StringMap<String>();
		directory = getExportedFontDirectory(libraryName);
		if (directory != null && FileSystem.exists(directory) && FileSystem.isDirectory(directory)) {
			for (entry in FileSystem.readDirectory(directory)) {
				lookup = entry.toLowerCase();
				if (!StringTools.endsWith(lookup, ".ttf") && !StringTools.endsWith(lookup, ".otf")) {
					continue;
				}
				separator = entry.indexOf("_");
				if (separator <= 0) {
					continue;
				}
				lookup = entry.substr(separator + 1);
				lookup = Path.withoutExtension(lookup);
				if (isDeviceFontName(lookup)) {
					continue;
				}
				fontMap.set(normalizeFontLookupName(lookup), Path.normalize(Path.join([directory, entry])));
			}
		}
		sFontMaps.set(libraryName, fontMap);
		return fontMap;
	}

	static function getExportedFontDirectory(libraryName:String):String {
		var programDir:String = Path.directory(Sys.programPath());
		var candidates:Array<String> = null;
		var candidate:String = null;
		if (programDir == null || programDir.length == 0) {
			return null;
		}
		candidates = [
			Path.normalize(Path.join([programDir, "Resources", "ffdec_fonts", libraryName])),
			Path.normalize(Path.join([programDir, "..", "Resources", "Resources", "ffdec_fonts", libraryName])),
		];
		for (candidate in candidates) {
			if (FileSystem.exists(candidate)) {
				return candidate;
			}
		}
		return candidates[0];
	}

	static function normalizeFontLookupName(name:String):String {
		if (name == null) {
			return "";
		}
		name = StringTools.replace(name, "\x00", "");
		name = StringTools.trim(name);
		return name.toLowerCase();
	}

	static function isDeviceFontName(name:String):Bool {
		name = normalizeFontLookupName(name);
		return name == "arial" || name == "_sans" || name == "_serif" || name == "_typewriter";
	}

	static function loadPreprocessedLibrarySync(libraryId:String, swfPath:String):AssetLibrary {
		var library:AssetLibrary = null;
		var bundlePath:String = null;
		if (libraryId == null || libraryId.length == 0) {
			return null;
		}
		if (sLoadedPreprocessedLibraries.exists(libraryId)) {
			return sLoadedPreprocessedLibraries.get(libraryId);
		}
		if (sFailedPreprocessedLibraries.exists(libraryId)) {
			return null;
		}
		bundlePath = getPreprocessedBundlePath(libraryId);
		if (bundlePath == null || !FileSystem.exists(bundlePath)) {
			sFailedPreprocessedLibraries.set(libraryId, true);
			return null;
		}
		library = cast Assets.getLibrary(libraryId);
		if (library != null) {
			sLoadedPreprocessedLibraries.set(libraryId, library);
			return library;
		}
		try {
			library = AssetLibrary.fromBundle(AssetBundle.fromFile(bundlePath));
			if (library == null) {
				throw "AssetLibrary.fromBundle returned null";
			}
			if (Std.isOfType(library, AnimateLibrary)) {
				cast(library, AnimateLibrary).load();
			}
			Assets.registerLibrary(libraryId, library);
			sLoadedPreprocessedLibraries.set(libraryId, library);
			return library;
		} catch (e:Dynamic) {
			Logger.warn("SwfAsset.loadPreprocessedLibrarySync: failed for "
				+ swfPath
				+ " id="
				+ libraryId
				+ " bundle="
				+ bundlePath
				+ ": "
				+ Std.string(e));
		}
		sFailedPreprocessedLibraries.set(libraryId, true);
		return null;
	}

	static function getPreprocessedBundlePath(libraryId:String):String {
		var programDir = Path.directory(Sys.programPath());
		var candidates:Array<String> = null;
		var candidate:String = null;
		var previous:String = null;
		if (programDir == null || programDir.length == 0) {
			return null;
		}
		candidates = [
			Path.normalize(Path.join([programDir, "lib", libraryId + ".zip"])),
			Path.normalize(Path.join([programDir, "..", "Resources", "lib", libraryId + ".zip"]))
		];
		for (candidate in candidates) {
			if (previous != candidate && FileSystem.exists(candidate)) {
				return candidate;
			}
			previous = candidate;
		}
		return candidates[0];
	}

	static function extractSimpleSymbolName(className:String):String {
		var name = className;
		var sep = name.lastIndexOf("::");
		if (sep != -1) {
			name = name.substring(sep + 2);
		}
		sep = name.lastIndexOf(".");
		if (sep != -1) {
			name = name.substring(sep + 1);
		}
		return name;
	}

	function instantiateFromLoadedRoot(className:String):Dynamic {
		var container:DisplayObjectContainer = null;
		var found:DisplayObject = null;
		var simpleName:String = null;
		container = ASCompat.dynamicAs(mRootClip, DisplayObjectContainer);
		if (container == null) {
			container = ASCompat.dynamicAs(mHdRootClip, DisplayObjectContainer);
		}
		if (container == null) {
			return null;
		}
		simpleName = SwfAsset.extractSimpleSymbolName(className);
		found = findDisplayObjectByNameRecursive(container, simpleName);
		if (found == null && simpleName != className) {
			found = findDisplayObjectByNameRecursive(container, className);
		}
		if (found != null) {
			try {
				if (found.parent != null) {
					found.parent.removeChild(found);
				}
			} catch (e:Dynamic) {}
		}
		return found;
	}

	function findDisplayObjectByNameRecursive(container:DisplayObjectContainer, objectName:String):DisplayObject {
		var child:DisplayObject = null;
		var nested:DisplayObjectContainer = null;
		var i = 0;
		if (container == null || objectName == null || objectName.length == 0) {
			return null;
		}
		if (container.name == objectName) {
			return container;
		}
		while (i < container.numChildren) {
			child = container.getChildAt(i);
			if (child != null) {
				if (child.name == objectName) {
					return child;
				}
				nested = ASCompat.dynamicAs(child, DisplayObjectContainer);
				if (nested != null) {
					child = findDisplayObjectByNameRecursive(nested, objectName);
					if (child != null) {
						return child;
					}
				}
			}
			i++;
		}
		return null;
	}

	function bindTimelineFields(target:Dynamic) {
		var container:DisplayObjectContainer = ASCompat.dynamicAs(target, DisplayObjectContainer);
		if (container == null) {
			return;
		}
		bindTimelineFieldsRecursive(container);
	}

	function bindTimelineFieldsRecursive(container:DisplayObjectContainer) {
		var child:DisplayObject = null;
		var nested:DisplayObjectContainer = null;
		var childName:String = null;
		var label:DisplayObject = null;
		var state:DisplayObjectContainer = null;
		var i = 0;
		if (container == null) {
			return;
		}
		while (i < container.numChildren) {
			child = container.getChildAt(i);
			if (child != null) {
				childName = child.name;
				if (childName != null && childName.length > 0) {
					try {
						if (!Reflect.hasField(container, childName) || Reflect.field(container, childName) == null) {
							Reflect.setField(container, childName, child);
							if (Reflect.field(container, childName) == null) {
								Reflect.setProperty(container, childName, child);
							}
						}
					} catch (e:Dynamic) {}
				}
				nested = ASCompat.dynamicAs(child, DisplayObjectContainer);
				if (nested != null) {
					bindTimelineFieldsRecursive(nested);
				}
			}
			i++;
		}
		if (!Reflect.hasField(container, "label") || Reflect.field(container, "label") == null) {
			label = container.getChildByName("label");
			if (label == null) {
				state = ASCompat.dynamicAs(container.getChildByName("up"), DisplayObjectContainer);
				if (state != null) {
					label = state.getChildByName("label");
				}
			}
			if (label == null) {
				state = ASCompat.dynamicAs(container.getChildByName("over"), DisplayObjectContainer);
				if (state != null) {
					label = state.getChildByName("label");
				}
			}
			if (label != null) {
				try {
					Reflect.setField(container, "label", label);
				} catch (e:Dynamic) {}
			}
		}
	}

	function unloadSwfRoot(root:Dynamic) {
		var loaderInfo:Dynamic = null;
		var loader:Dynamic = null;
		if (root == null) {
			return;
		}
		try {
			loaderInfo = Reflect.field(root, "loaderInfo");
			if (loaderInfo == null) {
				return;
			}
			loader = Reflect.field(loaderInfo, "loader");
			if (loader != null && Reflect.hasField(loader, "unloadAndStop")) {
				Reflect.callMethod(loader, Reflect.field(loader, "unloadAndStop"), []);
			}
		} catch (e:Dynamic) {}
	}

	function getApplicationDomain(root:Dynamic):Dynamic {
		var loaderInfo:Dynamic = null;
		if (root == null) {
			return null;
		}
		try {
			loaderInfo = Reflect.field(root, "loaderInfo");
			if (loaderInfo == null) {
				return null;
			}
			return Reflect.field(loaderInfo, "applicationDomain");
		} catch (e:Dynamic) {}
		return null;
	}

	function objectTypeName(value:Dynamic):String {
		var cls:Dynamic = null;
		if (value == null) {
			return "null";
		}
		cls = Type.getClass(value);
		if (cls == null) {
			return "unknown";
		}
		return Type.getClassName(cls);
	}
	#end
}

#if cpp
class SwfClassProxy {
	var mSwfAsset:SwfAsset;
	var mClassName:String;

	public function new(swfAsset:SwfAsset, className:String) {
		mSwfAsset = swfAsset;
		mClassName = className;
	}

	public function create(args:Array<Dynamic>):Dynamic {
		if (mSwfAsset == null) {
			return null;
		}
		return mSwfAsset.instantiateRuntimeSymbol(mClassName, args);
	}
}
#end
