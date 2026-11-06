package uI.hud.starlingConverted;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.starling.swfConverter.BakeBudget;
import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedPages;
import brain.starling.swfConverter.BakedPicture;
import facade.DBFacade;
import settings.model.LocalSettingsFile;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.Event;
import flash.system.Capabilities;
import flash.text.TextField;
import starling.core.Starling;

class HudArt {
	static inline final HUD_PATH = "Resources/Art2D/UI/db_UI_HUD.swf";

	static inline final TOWN_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	static inline final NAMETAG_PATH = "Resources/Art2D/UI/db_UI_nametag.swf";

	static var sSymbols:Vector<String>;

	static var sAssets:AssetLoadingComponent;

	static var sClasses:ASObject;

	static var sArt:ASObject;

	static var sPages:HudPages;

	static var sPixelScale:Float = 1;

	static var sReady:Bool = false;

	static var sBegun:Bool = false;

	static var sLoading:Int = 0;

	static var sCallbacks:Vector<ASFunction>;

	static var sPendingPages:HudPages;

	static var sPendingArt:ASObject;

	static var sPendingScale:Float = Math.NaN;

	static var sConverter:HudArtConverter;

	static var sIndex:Int = 0;

	static var sPendingFailures:Int = 0;

	static var sRequestedScale:Float = 0;

	static var sWait:Shape;

	static var sContextWait:Shape;

	static var sRebakedCallbacks:Vector<ASFunction>;

	static var sLease:ASObject;

	static var sSwfs:Vector<SwfAsset>;

	static var sLeases:Array<Dynamic>;

	static var sFramePages:HudPages;

	static var sPendingFramePages:HudPages;

	static var sBakeSymbols:Vector<String>;

	static var sLayout:String;

	static var sModel:DisplayObject;

	static var sFailureReason:String;

	static var sScaleSince:Int = 0;

	static var sScaleMonitor:Shape;

	static var sDemand:Array<Dynamic>;

	static var sDemandActive:ASObject;

	static var sFacade:DBFacade;

	static var sRejectedScale:Float = Math.NaN;

	static var sObservedScale:Float = Math.NaN;

	static var sHandlingFrame:Bool = false;

	static var sFatal:Bool = false;

	static var sCacheHead:ArtNode;

	static var sCacheTail:ArtNode;

	static var sEvictCursor:ArtNode;

	@:allow(uI.hud.starlingConverted) static inline final DEATH_ICON_SWF = "Resources/Art2D/Icons/Avatars/db_icon_death.swf";

	static var sPinnedSymbols:ASObject;

	static final OPTIONAL_SYMBOLS:Vector<String> = Vector.ofArray([
		"Resources/Art2D/Icons/Princess/db_icons_princess.swf death_icon",
		"Resources/Art2D/Icons/Treasure/db_icons_treasure.swf death_icon"
	]);

	public function new() {}

	@:allow(uI.hud.starlingConverted) static function bakeContent(key:String, source:DisplayObject, scale:Float):BakedCell {
		return bakeOn(sPages, key, source, scale);
	}

	@:allow(uI.hud.starlingConverted) static function bakeOn(pages:BakedPages, key:String, source:DisplayObject, scale:Float, required:Bool = true):BakedCell {
		var _loc7_ = pages.acquire(key);
		if (_loc7_ != null) {
			return _loc7_;
		}
		var _loc6_ = StarlingRaster.bake(source, scale);
		_loc7_ = _loc6_ != null ? pages.add(key, _loc6_, true) : null;
		if (_loc7_ == null && required) {
			throw new Error("HUD content rasterisation refused");
		}
		return _loc7_;
	}

	@:allow(uI.hud.starlingConverted) static function bakePixels(source:DisplayObject, scale:Float):BakedPicture {
		return StarlingRaster.bake(source, scale);
	}

	@:allow(uI.hud.starlingConverted) static function buildFont(pages:BakedPages, prefix:String, model:TextField, scale:Float, chars:String,
			layer:Int):StarlingGlyphFont {
		var _loc8_:StarlingGlyphFont = null;
		var _loc7_:ArtNode = null;
		try {
			_loc8_ = StarlingGlyphFont.build(pages, prefix, model, scale, chars, layer);
		} catch (error:Dynamic) {
			if (!sReady) {
				throw error;
			}
			StarlingHud.reportError(ASCompat.asError(error));
			_loc8_ = null;
		}
		if (_loc8_ == null && !sReady) {
			throw new Error("HUD glyph font unavailable: " + model.name);
		}
		if (_loc8_ != null && content("font|" + _loc8_.cell.key, pages) == null) {
			_loc7_ = new ArtNode();
			_loc7_.cell = _loc7_.hold(pages.acquire(_loc8_.cell.key), pages);
			storeContent("font|" + _loc8_.cell.key, _loc7_, pages);
		}
		return _loc8_;
	}

	public static function begin(facade:DBFacade) {
		if (sBegun) {
			return;
		}
		sSymbols = Vector.ofArray([
			"ui_hud_old",
			"ui_hud",
			"stacks_hud",
			"buff_cooldown_icon",
			"floater_text",
			"options_panel_button",
			"UI_widget",
			"UI_nametag",
			"UI_speechbubble_typing",
			"UI_teamloot_basic",
			"UI_teamloot_uncommon",
			"UI_teamloot_rare",
			"UI_teamloot_legendary",
			"UI_teamloot_box_small",
			"UI_teamloot_box_royal"
		]);
		sClasses = {};
		sArt = {};
		if (sCallbacks == null) {
			sCallbacks = new Vector<ASFunction>((0 : UInt));
		}
		if (sRebakedCallbacks == null) {
			sRebakedCallbacks = new Vector<ASFunction>((0 : UInt));
		}
		sSwfs = new Vector<SwfAsset>((0 : UInt));
		sDemand = ASCompat.allocArray((0 : UInt));
		sLeases = ASCompat.allocArray((0 : UInt));
		sBegun = true;
		sFacade = facade;
		sPixelScale = Math.min(Capabilities.screenResolutionX / 1920, Capabilities.screenResolutionY / 1080);
		var _loc2_:ASObject = new LocalSettingsFile().read();
		sLayout = _loc2_ != null
			&& _loc2_.hasOwnProperty("hudStyle")
			&& ASCompat.toString(_loc2_["hudStyle"]) == "1" ? "ui_hud" : "ui_hud_old";
		sAssets = new AssetLoadingComponent(facade);
		sContextWait = new Shape();
		sContextWait.addEventListener("enterFrame", waitForContext);
		sLoading = 5;
		loadStartupSwf(sAssets, "Resources/Art2D/UI/db_UI_HUD.swf", loadedHud);
		loadStartupSwf(sAssets, "Resources/Art2D/UI/db_UI_town.swf", loadedTown);
		loadStartupSwf(sAssets, "Resources/Art2D/UI/db_UI_nametag.swf", loadedNametag);
		HudIconBake.load(facade, sAssets, loaded);
		RarityArt.load(facade, sAssets, loaded);
	}

	static function loadedHud(asset:SwfAsset) {
		var _loc2_ = 0;
		TimelineMasks.register(asset);
		sSwfs.push(asset);
		_loc2_ = 0;
		while (_loc2_ < sSymbols.length) {
			if (sSymbols[_loc2_] != "options_panel_button"
				&& sSymbols[_loc2_] != "UI_widget"
				&& sSymbols[_loc2_] != "UI_nametag"
				&& sSymbols[_loc2_] != "UI_speechbubble_typing") {
				sClasses[sSymbols[_loc2_]] = requireClass(asset, "Resources/Art2D/UI/db_UI_HUD.swf", sSymbols[_loc2_]);
			}
			_loc2_++;
		}
		loaded();
	}

	static function loadedTown(asset:SwfAsset) {
		TimelineMasks.register(asset);
		sSwfs.push(asset);
		ASCompat.setProperty(sClasses, "options_panel_button", requireClass(asset, "Resources/Art2D/UI/db_UI_town.swf", "options_panel_button"));
		ASCompat.setProperty(sClasses, "legendary_background_icon", requireClass(asset, "Resources/Art2D/UI/db_UI_town.swf", "legendary_background_icon"));
		loaded();
	}

	static function loadedNametag(asset:SwfAsset) {
		sSwfs.push(asset);
		TimelineMasks.register(asset);
		ASCompat.setProperty(sClasses, "UI_widget", requireClass(asset, "Resources/Art2D/UI/db_UI_nametag.swf", "UI_widget"));
		ASCompat.setProperty(sClasses, "UI_nametag", requireClass(asset, "Resources/Art2D/UI/db_UI_nametag.swf", "UI_nametag"));
		ASCompat.setProperty(sClasses, "UI_speechbubble_typing", requireClass(asset, "Resources/Art2D/UI/db_UI_nametag.swf", "UI_speechbubble_typing"));
		loaded();
	}

	@:allow(uI.hud.starlingConverted) static function requireClass(asset:SwfAsset, swf:String, name:String):Dynamic {
		var _loc4_ = optionalClass(asset, swf, name);
		if (_loc4_ == null) {
			fatal("Missing required HUD class: " + swf + " " + name);
		}
		return _loc4_;
	}

	@:allow(uI.hud.starlingConverted) static function isOptional(swf:String, name:String):Bool {
		return OPTIONAL_SYMBOLS.indexOf(swf + " " + name) >= 0;
	}

	@:allow(uI.hud.starlingConverted) static function optionalClass(asset:SwfAsset, swf:String, name:String):Dynamic {
		var _loc4_:Dynamic = null;
		if (asset == null || name == null || name.length == 0) {
			fatal("HUD SWF or class name missing: " + swf + " " + name);
		}
		try {
			_loc4_ = asset.getClass(name, true);
		} catch (error:Dynamic) {
			fatal("HUD class load failed: " + swf + " " + name + " " + ASCompat.asError(error).message);
		}
		return _loc4_;
	}

	@:allow(uI.hud.starlingConverted) static function loadStartupSwf(assets:AssetLoadingComponent, path:String, onLoaded:ASFunction) {
		assets.getSwfAsset(DBFacade.buildFullDownloadPath(path), function(param1:SwfAsset) {
			try {
				onLoaded(param1);
			} catch (error:Dynamic) {
				fatal("HUD startup SWF: " + path + " " + ASCompat.asError(error).message, true);
			}
		}, function() {
			fatal("HUD startup SWF load failed: " + path, true);
		});
	}

	@:allow(uI.hud.starlingConverted) static function loadRuntimeSwf(assets:AssetLoadingComponent, path:String, symbol:String, onLoaded:ASFunction) {
		try {
			assets.getSwfAsset(DBFacade.buildFullDownloadPath(path), function(param1:SwfAsset) {
				try {
					onLoaded(param1);
				} catch (error:ASAny) {
					runtimeAssetFailed(path, symbol, error);
				}
			}, function() {
				fatal("HUD runtime SWF load failed: " + path + " " + symbol, true);
			});
		} catch (loadError:ASAny) {
			runtimeAssetFailed(path, symbol, loadError);
		}
	}

	@:allow(uI.hud.starlingConverted) static function runtimeAssetFailed(path:String, symbol:String, error:ASAny) {
		fatal("HUD runtime SWF load/construction failed: " + path + " " + symbol + " " + ASCompat.toString(error), true);
	}

	@:allow(uI.hud.starlingConverted) static function fatal(reason:String, deferred:Bool = false) {
		var first = !sFatal;
		sFatal = true;
		sReady = false;
		sFailureReason = reason;
		sDemandActive = null;
		if (sDemand != null) {
			sDemand.resize(0);
		}
		if (sPages != null && sFramePages != null) {
			setPinBakes(sPages, sFramePages, false);
		}
		if (sPendingPages != null && sPendingFramePages != null) {
			setPinBakes(sPendingPages, sPendingFramePages, false);
		}
		if (first) {
			StarlingHud.giveUp();
		}
		if (deferred) {
			sFacade.preRenderWorkManager.doLater(0, Reflect.makeVarArgs(function(_rest:Array<ASAny>) {
				var rest = ASCompat.restToArray(_rest);
				fatal(reason);
			}), false, "HudArt.fatal");
			return;
		}
		throw new HudFatalError(reason);
	}

	@:allow(uI.hud.starlingConverted) static function fail(reason:String, error:Error = null, report:Bool = true) {
		if (Std.isOfType(error, HudFatalError)) {
			fatal(error.message);
		}
		if (!sReady) {
			fatal(reason);
		}
		sFailureReason = reason;
		if (error == null) {
			error = new Error(reason);
		}
		if (report) {
			StarlingHud.reportError(error);
		}
	}

	static function starlingInUse():Bool {
		return sFacade != null && sFacade.featureFlags.getFlagValue("starling-hud");
	}

	static function discardPending() {
		var __ax4_iter_270:ASObject;
		var _loc1_:ArtNode = null;
		HudIconBake.cancel();
		RarityArt.cancel();
		if (sPendingArt != null) {
			__ax4_iter_270 = sPendingArt;
			if (checkNullIteratee(__ax4_iter_270))
				for (_tmp_ in iterateDynamicValues(__ax4_iter_270)) {
					_loc1_ = ASCompat.coerce(_tmp_, uI.hud.starlingConverted.ArtNode);
					try {
						_loc1_.release(sPendingPages);
					} catch (error:ASAny) {}
				}
		}
		if (sPendingPages != null) {
			try {
				sPendingPages.dispose();
			} catch (pagesError:ASAny) {}
		}
		if (sPendingFramePages != null) {
			try {
				sPendingFramePages.dispose();
			} catch (framesError:ASAny) {}
		}
		sPendingPages = sPendingFramePages = null;
		sPendingArt = null;
		nextDemand();
	}

	static function loaded() {
		sLoading = sLoading - 1;
	}

	static function waitForContext(event:Event) {
		if (sFatal || HudArtConverter.busy || sHandlingFrame || sContextWait == null) {
			return;
		}
		sHandlingFrame = true;
		{
			try {
				try {
					contextReady();
				} catch (error:ASAny) {
					fail("HUD context wait: " + ASCompat.toString(error), ASCompat.dynamicAs(error, Error));
				};
			} catch (__finallyError0:Dynamic) {
				{
					sHandlingFrame = false;
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				sHandlingFrame = false;
			};
		}
	}

	static function contextReady() {
		var _loc1_ = sFacade.starlingLayerManager != null ? sFacade.starlingLayerManager.starlingInstance : null;
		if (sLoading != 0 || _loc1_ == null || !_loc1_.contextValid || !sFacade.starlingLayerManager.isReady()) {
			return;
		}
		sContextWait.removeEventListener("enterFrame", waitForContext);
		sContextWait = null;
		try {
			startBake(sPixelScale);
		} catch (error:Dynamic) {
			fail("HUD context/bake: " + ASCompat.asError(error).message, ASCompat.asError(error));
		}
	}

	static function startBake(scale:Float) {
		var _loc2_:String = null;
		reserveBakeCap(scale);
		sPendingScale = scale;
		sPendingPages = new HudPages();
		sPendingFramePages = new HudPages(true);
		sPendingArt = {};
		sBakeSymbols = new Vector<String>((0 : UInt));
		final __ax4_iter_271 = sSymbols;
		if (checkNullIteratee(__ax4_iter_271))
			for (_tmp_ in __ax4_iter_271) {
				_loc2_ = _tmp_;
				if (!((_loc2_ == "ui_hud" || _loc2_ == "ui_hud_old") && _loc2_ != sLayout && !ASCompat.toBool(sPinnedSymbols[_loc2_]))) {
					sBakeSymbols.push(_loc2_);
				}
			}
		sPendingFailures = 0;
		sIndex = 0;
		convertNext();
	}

	static function convertNext() {
		var _loc1_:String = null;
		var _loc2_:Dynamic = null;
		var _loc3_:DisplayObject = null;
		if (sFatal) {
			return;
		}
		while (sIndex < sBakeSymbols.length) {
			_loc1_ = sBakeSymbols[sIndex];
			setPinBakes(sPendingPages, sPendingFramePages, !sReady || sPinnedSymbols[_loc1_] == true || _loc1_ == "ui_hud" || _loc1_ == "ui_hud_old");
			_loc2_ = (sClasses[_loc1_] : Dynamic);
			if (_loc2_ == null) {
				fail("Missing required HUD class: " + _loc1_);
				sPendingFailures = sPendingFailures + 1;
				sIndex = sIndex + 1;
			} else {
				HudArtConverter.beginWork();
				{
					try {
						try {
							_loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), DisplayObject);
							if (_loc1_ == "UI_nametag") {
								HudArtConverter.stopTree(_loc3_);
								_loc3_ = ASCompat.coerce((cast(_loc3_, MovieClip) : ASAny).hp.hpBar, flash.display.DisplayObject);
							}
							sModel = _loc3_;
							sConverter = HudArtConverter.convertAsync(_loc3_, sPendingPages, sPendingScale * symbolScale(_loc1_), {
								"hudScale": sPendingScale,
								"kind": kindFor(_loc1_),
								"clipMasks": petMasks,
								"stageRate": currencyStageRate,
								"framePages": sPendingFramePages
							}, converted, 8);
							{
								{
									HudArtConverter.endWork();
								};
								return;
							};
						} catch (error:ASAny) {
							fail("HUD conversion: " + _loc1_ + " " + ASCompat.toString(error), ASCompat.dynamicAs(error, Error));
							sPendingFailures = sPendingFailures + 1;
							sIndex = sIndex + 1;
							convertNext();
							{
								{
									HudArtConverter.endWork();
								};
								return;
							};
						};
					} catch (__finallyError0:Dynamic) {
						{
							HudArtConverter.endWork();
						};
						ASCompat.rethrowKeepingStack(__finallyError0);
						throw __finallyError0;
					};
					{
						HudArtConverter.endWork();
					};
				}
			}
		}
		if (sReady && sPendingFailures > 0) {
			completeBake();
			return;
		}
		setPinBakes(sPendingPages, sPendingFramePages, true);
		HudIconBake.bake(sPendingPages, sPendingFramePages, sPendingScale, sPendingArt, sLayout, iconsBaked);
	}

	static function iconsBaked() {
		RarityArt.bake(sPendingPages, sPendingFramePages, sPendingScale, sPendingArt, rarityBaked);
	}

	static function rarityBaked() {
		sPendingFailures += RarityArt.failures;
		if (RarityArt.failures > 0) {
			sFailureReason = "HUD rarity rebake incomplete";
		}
		setPinBakes(sPendingPages, sPendingFramePages, false);
		completeBake();
	}

	static function setPinBakes(pages:HudPages, frames:HudPages, pinned:Bool) {
		pages.mPinBakes = pinned;
		frames.mPinBakes = pinned;
	}

	static function prepareText(node:ArtNode, path:String = "") {
		var _loc3_:StarlingText = null;
		var _loc5_:ArtNode = null;
		var _loc4_ = false;
		if (node == null) {
			return;
		}
		if (node.kind == "text") {
			_loc4_ = node.name == "HP_text" || node.name == "mana_text" || node.name == "xp_level" || node.name == "xp_points"
				|| node.name == "game_currency_text" || node.name == "cash_text" || node.name == "quantity";
			{
				try {
					try {
						_loc3_ = new StarlingText(node, node.textPages, node.pixelScale,
							_loc4_ ? "glyphs" : (node.name == "NametagText" || node.name == "AlertText" ? "baked" : "auto"));
					} catch (error:Dynamic) {
						fail("HUD text preparation: " + path + " " + ASCompat.asError(error).message, ASCompat.asError(error));
					};
				} catch (__finallyError0:Dynamic) {
					{
						if (_loc3_ != null) {
							_loc3_.dispose();
						}
					};
					ASCompat.rethrowKeepingStack(__finallyError0);
					throw __finallyError0;
				};
				{
					if (_loc3_ != null) {
						_loc3_.dispose();
					}
				};
			}
		}
		final __ax4_iter_272 = node.children;
		if (checkNullIteratee(__ax4_iter_272))
			for (_tmp_ in __ax4_iter_272) {
				_loc5_ = _tmp_;
				prepareText(_loc5_, path + "." + _loc5_.name);
			}
	}

	static function kindFor(symbol:String):ASFunction {
		return function(param1:String):String {
			if (param1.length == 0 && symbol.indexOf("UI_teamloot_") == 0) {
				return "timeline";
			}
			return new compat.RegExp("^UI_currency_cash\\.cash\\.@\\d+$").test(param1) ? "flipbook" : null;
		};
	}

	static function petMasks(path:String):Bool {
		return path == "pet" || path.indexOf("pet.") == 0;
	}

	static function symbolScale(symbol:String):Float {
		if (symbol == "options_panel_button") {
			return 0.9;
		}
		if (symbol.indexOf("UI_teamloot_") == 0) {
			return 1.8;
		}
		if (symbol == "UI_widget" || symbol == "UI_nametag" || symbol == "UI_speechbubble_typing") {
			return 1.44;
		}
		return 1;
	}

	static function currencyStageRate(path:String):Bool {
		return path.indexOf("UI_currency_coin.coin.") == 0 || path.indexOf("UI_currency_cash.cash.") == 0;
	}

	@:allow(uI.hud.starlingConverted) static function content(key:String, pages:BakedPages = null):ArtNode {
		var _loc4_:ASObject = pages != null && pages == sPendingPages ? sPendingArt : sArt;
		var _loc3_ = _loc4_ != null ? ASCompat.dynamicAs(_loc4_["content|" + key], ArtNode) : null;
		if (_loc3_ != null) {
			touchContent(_loc3_);
		}
		return _loc3_;
	}

	@:allow(uI.hud.starlingConverted) static function artSetScale(layout:ArtNode):Float {
		if (layout == null || layout.lease == null) {
			fatal("Required HUD art-set lease missing");
		}
		return ASCompat.toNumber(layout.lease.pixelScale);
	}

	@:allow(uI.hud.starlingConverted) static function artSetContent(layout:ArtNode, key:String):ArtNode {
		artSetScale(layout);
		return ASCompat.dynamicAs(layout.lease.art["content|" + key], ArtNode);
	}

	@:allow(uI.hud.starlingConverted) static function storeContent(key:String, node:ArtNode, pages:BakedPages = null) {
		if (Std.isOfType(pages, HudPages) && cast(pages, HudPages).mPinBakes) {
			node.mPinned = true;
		}
		if (pages != null && pages == sPendingPages) {
			sPendingArt["content|" + key] = node;
		} else {
			sArt["content|" + key] = node;
			assignLease(node, sLease);
		}
		cacheContent(node, "content|" + key, pages != null && pages == sPendingPages ? sPendingArt : sArt,
			ASCompat.coerce(pages ?? sPages, brain.starling.swfConverter.BakedPages));
	}

	static function cacheContent(node:ArtNode, key:String, art:ASObject, pages:BakedPages) {
		if (node == null || node.mPinned) {
			return;
		}
		node.mCacheKey = key;
		node.mCacheArt = art;
		node.mCachePages = pages;
		touchContent(node);
	}

	static function touchContent(node:ArtNode) {
		if (node.mCacheArt == null || sCacheTail == node) {
			return;
		}
		removeCached(node);
		node.mCachePrevious = sCacheTail;
		if (sCacheTail != null) {
			sCacheTail.mCacheNext = node;
		} else {
			sCacheHead = node;
		}
		sCacheTail = node;
	}

	@:allow(uI.hud.starlingConverted) static function removeCached(node:ArtNode) {
		if (sEvictCursor == node) {
			sEvictCursor = node.mCacheNext;
		}
		if (node.mCachePrevious != null) {
			node.mCachePrevious.mCacheNext = node.mCacheNext;
		} else if (sCacheHead == node) {
			sCacheHead = node.mCacheNext;
		}
		if (node.mCacheNext != null) {
			node.mCacheNext.mCachePrevious = node.mCachePrevious;
		} else if (sCacheTail == node) {
			sCacheTail = node.mCachePrevious;
		}
		node.mCachePrevious = node.mCacheNext = null;
	}

	@:allow(uI.hud.starlingConverted) static function beginEviction() {
		sEvictCursor = sCacheHead;
	}

	@:allow(uI.hud.starlingConverted) static function evictContent():Bool {
		var _loc1_:ArtNode = null;
		while (sEvictCursor != null) {
			_loc1_ = sEvictCursor;
			sEvictCursor = _loc1_.mCacheNext;
			if (_loc1_.canEvict()) {
				ASCompat.deleteProperty(_loc1_.mCacheArt, _loc1_.mCacheKey);
				_loc1_.release(_loc1_.mCachePages);
				return true;
			}
		}
		return false;
	}

	static function converted(art:ArtNode) {
		try {
			convertedSafely(art);
		} catch (error:Dynamic) {
			fail("HUD conversion completion: " + ASCompat.asError(error).message, ASCompat.asError(error));
		}
	}

	static function convertedSafely(art:ArtNode) {
		if (sFatal) {
			return;
		}
		var _loc2_ = sBakeSymbols[sIndex];
		HudArtConverter.stopTree(sModel);
		sModel = null;
		prepareText(art, _loc2_);
		var _loc3_ = sConverter;
		if (!sReady && (art == null || _loc3_.failures > 0)) {
			if (art != null) {
				art.release(sPendingPages);
			}
			fatal("Required HUD bake failed: " + _loc2_ + (_loc3_.error != null ? " " + _loc3_.error : ""));
		}
		if (art != null) {
			art.mPinned = sPendingPages.mPinBakes;
			if (art.mPinned) {
				sPinnedSymbols[_loc2_] = true;
			}
			sPendingArt[_loc2_] = art;
		}
		sPendingFailures += _loc3_.failures;
		if (_loc3_.failures > 0) {
			sFailureReason = "HUD bake failed: " + _loc2_ + (_loc3_.error != null ? " " + _loc3_.error : "");
		}
		sConverter = null;
		sIndex = sIndex + 1;
		convertNext();
	}

	static function completeBake() {
		var __ax4_iter_276:Vector<ASFunction>;
		var _loc1_:ArtNode = null;
		var _loc4_:String = null;
		var _loc3_:ASFunction = null;
		HudIconBake.cancel();
		setPinBakes(sPendingPages, sPendingFramePages, false);
		if (sFatal) {
			return;
		}
		if (!sReady && sPendingFailures > 0) {
			fatal(sFailureReason ?? "HUD startup conversion incomplete");
		}
		if (sReady && sPendingFailures > 0) {
			sRejectedScale = Math.fround(sPendingScale * 1000);
			fail(sFailureReason ?? "HUD rebake incomplete", null, false);
			discardPending();
			return;
		}
		var _loc5_:ASObject = {
			"pages": sPendingPages,
			"framePages": sPendingFramePages,
			"art": sPendingArt,
			"pixelScale": sPendingScale,
			"views": 0,
			"retired": false,
			"release": releaseLease
		};
		final __ax4_iter_273:ASObject = sPendingArt;
		if (checkNullIteratee(__ax4_iter_273))
			for (_tmp_ in __ax4_iter_273.___keys()) {
				_loc4_ = _tmp_;
				assignLease(ASCompat.dynamicAs(sPendingArt[_loc4_], ArtNode), _loc5_);
			}
		final __ax4_iter_274 = Vector.ofArray(["ui_hud_old", "ui_hud"]);
		if (checkNullIteratee(__ax4_iter_274))
			for (_tmp_ in __ax4_iter_274) {
				_loc4_ = _tmp_;
				_loc1_ = ASCompat.dynamicAs(sPendingArt[_loc4_], ArtNode);
				if (_loc1_ != null) {
					RarityArt.verifySlots(_loc1_, sFacade);
				}
			}
		var _loc2_:ASObject = sLease;
		sPages = sPendingPages;
		sFramePages = sPendingFramePages;
		sArt = sPendingArt;
		sPixelScale = sPendingScale;
		sPendingPages = null;
		sPendingFramePages = null;
		sPendingArt = null;
		sLease = _loc5_;
		sLeases.push(sLease);
		sizeStarlingCap();
		final __ax4_iter_275:ASObject = sArt;
		if (checkNullIteratee(__ax4_iter_275))
			for (_tmp_ in __ax4_iter_275.___keys()) {
				_loc4_ = _tmp_;
				_loc1_ = ASCompat.dynamicAs(sArt[_loc4_], ArtNode);
				cacheContent(_loc1_, _loc4_, sArt, sPages);
			}
		sReady = true;
		{
			var __ax4_iter_276:Vector<ASFunction>;
			try {
				while (sCallbacks.length > 0) {
					_loc3_ = sCallbacks.shift();
					try {
						_loc3_();
					} catch (error:Dynamic) {
						StarlingHud.reportError(ASCompat.asError(error));
					}
				}
				if (_loc2_ != null) {
					__ax4_iter_276 = sRebakedCallbacks;
					if (checkNullIteratee(__ax4_iter_276))
						for (_tmp_ in __ax4_iter_276) {
							_loc3_ = _tmp_;
							try {
								_loc3_();
							} catch (rebakedError:Dynamic) {
								StarlingHud.reportError(ASCompat.asError(rebakedError));
							}
						}
				}
			} catch (__finallyError0:Dynamic) {
				{
					if (_loc2_ != null) {
						ASCompat.setProperty(_loc2_, "retired", true);
						if (ASCompat.toNumberField(_loc2_, "views") == 0) {
							releaseLease(_loc2_);
						}
					}
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				if (_loc2_ != null) {
					ASCompat.setProperty(_loc2_, "retired", true);
					if (ASCompat.toNumberField(_loc2_, "views") == 0) {
						releaseLease(_loc2_);
					}
				}
			};
		}
		if (sRequestedScale > 0) {
			waitForRebake();
		}
		if (sScaleMonitor == null) {
			sScaleMonitor = new Shape();
			sScaleMonitor.addEventListener("enterFrame", monitorScale);
		}
		nextDemand();
	}

	static function rebake(scale:Float) {
		if (!sBegun || !starlingInUse() || scale <= 0 || !Math.isFinite(scale)) {
			return;
		}
		var _loc2_ = Math.fround(scale * 1000);
		if (sObservedScale != _loc2_) {
			sObservedScale = _loc2_;
			sRejectedScale = Math.NaN;
			sScaleSince = flash.Lib.getTimer();
		}
		if (_loc2_ == sRejectedScale) {
			return;
		}
		if (Math.abs(scale / sPixelScale - 1) <= 0.15) {
			sRequestedScale = 0;
			sScaleSince = 0;
			if (sWait != null) {
				sWait.removeEventListener("enterFrame", tryRebake);
			}
			sWait = null;
			return;
		}
		if (sRequestedScale == 0) {
			sScaleSince = flash.Lib.getTimer();
		}
		sRequestedScale = scale;
		waitForRebake();
	}

	static function waitForRebake() {
		if (sWait != null) {
			return;
		}
		sWait = new Shape();
		sWait.addEventListener("enterFrame", tryRebake);
	}

	static function tryRebake(event:Event) {
		if (HudArtConverter.busy || sHandlingFrame || sWait == null) {
			return;
		}
		sHandlingFrame = true;
		{
			try {
				try {
					rebakeWhenReady();
				} catch (error:ASAny) {
					fail("HUD rebake: " + ASCompat.toString(error), ASCompat.dynamicAs(error, Error));
				};
			} catch (__finallyError0:Dynamic) {
				{
					sHandlingFrame = false;
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				sHandlingFrame = false;
			};
		}
	}

	static function rebakeWhenReady() {
		if (!starlingInUse()) {
			return;
		}
		if (sRequestedScale <= 0 || !Math.isFinite(sRequestedScale)) {
			return;
		}
		if (Math.fround(sRequestedScale * 1000) == sRejectedScale) {
			sRequestedScale = 0;
			sWait.removeEventListener("enterFrame", tryRebake);
			sWait = null;
			return;
		}
		if (!sReady
			|| sPendingPages != null
			|| sDemandActive != null
			|| RarityArt.busy
			|| flash.Lib.getTimer() - sScaleSince <= 2000
			|| !BakeBudget.mayAllocate) {
			return;
		}
		sWait.removeEventListener("enterFrame", tryRebake);
		sWait = null;
		var _loc1_ = sRequestedScale;
		sRequestedScale = 0;
		if (Math.abs(_loc1_ / sPixelScale - 1) > 0.15) {
			startBake(_loc1_);
		}
	}

	static function monitorScale(event:Event) {
		if (HudArtConverter.busy || sHandlingFrame) {
			return;
		}
		try {
			if (starlingInUse() && Starling.current != null && Starling.current.contextValid) {
				rebake(Starling.contentScaleFactor);
			}
		} catch (error:Dynamic) {
			fail("HUD scale monitor: " + ASCompat.asError(error).message, ASCompat.asError(error));
		}
	}

	@:isVar public static var begun(get, never):Bool;

	static public function get_begun():Bool {
		return sBegun;
	}

	public static function removeReady(callback:ASFunction) {
		var _loc2_ = sCallbacks.indexOf(callback);
		if (_loc2_ >= 0) {
			sCallbacks.removeAt(_loc2_);
		}
	}

	@:isVar public static var ready(get, never):Bool;

	static public function get_ready():Bool {
		return sReady;
	}

	@:allow(uI.hud.starlingConverted) @:isVar static var fatalFailure(get, never):Bool;

	static function get_fatalFailure():Bool {
		return sFatal;
	}

	public static function onReady(callback:ASFunction) {
		if (sReady) {
			callback();
		} else {
			if (sCallbacks == null) {
				sCallbacks = new Vector<ASFunction>((0 : UInt));
			}
			sCallbacks.push(callback);
		}
	}

	public static function onRebaked(callback:ASFunction) {
		if (sRebakedCallbacks == null) {
			sRebakedCallbacks = new Vector<ASFunction>((0 : UInt));
		}
		if (sRebakedCallbacks.indexOf(callback) < 0) {
			sRebakedCallbacks.push(callback);
		}
	}

	public static function removeRebaked(callback:ASFunction) {
		var _loc2_ = sRebakedCallbacks.indexOf(callback);
		if (_loc2_ >= 0) {
			sRebakedCallbacks.removeAt(_loc2_);
		}
	}

	public static function art(symbolName:String):ArtNode {
		var _loc2_ = ASCompat.dynamicAs(sArt[symbolName], ArtNode);
		if (_loc2_ != null) {
			touchContent(_loc2_);
		}
		return _loc2_;
	}

	public static function swfClass(symbolName:String):Dynamic {
		var _loc4_:SwfAsset = null;
		var _loc2_ = (sClasses[symbolName] : Dynamic);
		if (_loc2_ != null) {
			return _loc2_;
		}
		final __ax4_iter_277 = sSwfs;
		if (checkNullIteratee(__ax4_iter_277))
			for (_tmp_ in __ax4_iter_277) {
				_loc4_ = _tmp_;
				try {
					_loc2_ = _loc4_.getClass(symbolName, true);
				} catch (error:Dynamic) {
					fatal("HUD class load failed: " + _loc4_.swfPath + " " + symbolName + " " + ASCompat.asError(error).message);
				}
				if (_loc2_ != null) {
					sClasses[symbolName] = _loc2_;
					return _loc2_;
				}
			}
		var _loc3_ = "";
		final __ax4_iter_278 = sSwfs;
		if (checkNullIteratee(__ax4_iter_278))
			for (_tmp_ in __ax4_iter_278) {
				_loc4_ = _tmp_;
				_loc3_ += _loc4_.swfPath + " ";
			}
		fatal("Missing required HUD class: " + _loc3_ + symbolName);
		return null;
	}

	@:isVar public static var pages(get, never):BakedPages;

	static public function get_pages():BakedPages {
		return sPages;
	}

	@:isVar public static var framePages(get, never):BakedPages;

	static public function get_framePages():BakedPages {
		return sFramePages;
	}

	@:isVar public static var pixelScale(get, never):Float;

	static public function get_pixelScale():Float {
		return sPixelScale;
	}

	@:allow(uI.hud.starlingConverted) static function bakePixelScale(pages:BakedPages):Float {
		return pages == sPendingPages ? sPendingScale : sPixelScale;
	}

	public static function convertLayout(type:UInt, onDone:ASFunction) {
		sDemand.push({
			"symbol": (type == 1 ? "ui_hud" : "ui_hud_old"),
			"callback": onDone,
			"layout": true
		});
		nextDemand();
	}

	public static function convertSymbol(symbol:String, onDone:ASFunction) {
		var _loc3_ = art(symbol);
		if (_loc3_ != null) {
			if (onDone != null) {
				onDone(_loc3_);
			}
			return;
		}
		sDemand.push({
			"symbol": symbol,
			"callback": onDone
		});
		nextDemand();
	}

	static function nextDemand() {
		var _loc3_:Dynamic = null;
		if (sFatal || !sReady || sPendingPages != null || sDemandActive != null || sDemand.length == 0) {
			return;
		}
		sDemandActive = sDemand.shift();
		var _loc1_ = art(sDemandActive.symbol);
		if (_loc1_ != null) {
			finishDemand(_loc1_);
			return;
		}
		var _loc2_ = sDemandActive.symbol == "ui_hud" || sDemandActive.symbol == "ui_hud_old";
		setPinBakes(sPages, sFramePages, _loc2_);
		HudArtConverter.beginWork();
		{
			try {
				try {
					if (_loc2_) {
						reserveBakeCap(sPixelScale);
					}
					_loc3_ = swfClass(sDemandActive.symbol);
					sModel = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), DisplayObject);
					sConverter = HudArtConverter.convertAsync(sModel, sPages, sPixelScale * symbolScale(sDemandActive.symbol), {
						"hudScale": sPixelScale,
						"kind": kindFor(sDemandActive.symbol),
						"clipMasks": petMasks,
						"stageRate": currencyStageRate,
						"framePages": sFramePages
					}, demandConverted, 8);
				} catch (error:ASAny) {
					fail("HUD conversion: " + ASCompat.toString(error), ASCompat.dynamicAs(error, Error));
					finishDemand(null);
				};
			} catch (__finallyError0:Dynamic) {
				{
					HudArtConverter.endWork();
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				HudArtConverter.endWork();
			};
		}
	}

	static function demandConverted(node:ArtNode) {
		try {
			demandConvertedSafely(node);
		} catch (error:Dynamic) {
			fail("HUD demand completion: " + ASCompat.asError(error).message, ASCompat.asError(error));
		}
	}

	static function demandConvertedSafely(node:ArtNode) {
		if (sFatal) {
			return;
		}
		HudArtConverter.stopTree(sModel);
		sModel = null;
		var _loc4_ = sDemandActive.symbol == "ui_hud" || sDemandActive.symbol == "ui_hud_old";
		if (_loc4_ && node != null) {
			node.pinStartupTree();
		}
		setPinBakes(sPages, sFramePages, _loc4_);
		{
			try {
				try {
					prepareText(node, sDemandActive.symbol);
				} catch (error:Dynamic) {
					fail("HUD text preparation: " + ASCompat.asError(error).message, ASCompat.asError(error));
				};
			} catch (__finallyError0:Dynamic) {
				{
					setPinBakes(sPages, sFramePages, false);
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				setPinBakes(sPages, sFramePages, false);
			};
		}
		var _loc3_ = sConverter;
		var _loc2_:String = sDemandActive.symbol;
		if (_loc3_.failures > 0) {
			fail("HUD conversion incomplete: " + _loc2_, null, false);
			if (node != null) {
				node.release(sPages);
			}
			sConverter = null;
			finishDemand(null);
			return;
		}
		if (node != null) {
			node.mPinned = _loc4_;
			if (node.mPinned) {
				sPinnedSymbols[_loc2_] = true;
			}
		}
		sArt[_loc2_] = node;
		assignLease(node, sLease);
		cacheContent(node, _loc2_, sArt, sPages);
		if (_loc4_) {
			RarityArt.bake(sPages, sFramePages, sPixelScale, sArt, layoutPrepared);
			return;
		}
		sConverter = null;
		finishDemand(node);
	}

	static function layoutPrepared() {
		var _loc1_:String = null;
		var _loc2_:ArtNode = null;
		if (sFatal) {
			return;
		}
		if (RarityArt.failures > 0) {
			_loc1_ = sDemandActive.symbol;
			fail("HUD rarity preparation incomplete: " + _loc1_, null, false);
			_loc2_ = ASCompat.dynamicAs(sArt[_loc1_], ArtNode);
			ASCompat.deleteProperty(sArt, _loc1_);
			ASCompat.deleteProperty(sPinnedSymbols, _loc1_);
			if (_loc2_ != null) {
				_loc2_.release(sPages);
			}
			sConverter = null;
			finishDemand(null);
			return;
		}
		RarityArt.verifySlots(ASCompat.dynamicAs(sArt[sDemandActive.symbol], ArtNode), sFacade);
		sizeStarlingCap();
		sConverter = null;
		finishDemand(ASCompat.dynamicAs(sArt[sDemandActive.symbol], ArtNode));
	}

	static function finishDemand(node:ArtNode) {
		setPinBakes(sPages, sFramePages, false);
		if (sFatal) {
			return;
		}
		if (node != null && sDemandActive.layout == true) {
			sLayout = sDemandActive.symbol;
		}
		var _loc2_ = ASCompat.coerceFunction(sDemandActive.callback);
		sDemandActive = null;
		if (_loc2_ != null) {
			try {
				_loc2_(node);
			} catch (error:Dynamic) {
				StarlingHud.reportError(ASCompat.asError(error));
			}
		}
		nextDemand();
	}

	static function sizeStarlingCap() {
		var _loc1_ = (sPages.pinnedBytes + sFramePages.pinnedBytes) / 1048576;
		BakeBudget.HUD_STARLING_CAP_MIB = Math.fceil(Math.max(32 * Math.max(1, sPixelScale * sPixelScale),
			Math.max(Math.max(_loc1_ * 2.5, accountedBytes() / 1048576 * 2.5), residentBytes() / 1048576)));
	}

	static function reserveBakeCap(scale:Float) {
		var _loc2_ = scale * scale;
		var _loc3_ = sReady ? accountedBytes() / 1048576 * _loc2_ / (sPixelScale * sPixelScale) * 1.5 : 64 * Math.max(1, _loc2_);
		BakeBudget.HUD_STARLING_CAP_MIB = Math.fceil(Math.max(BakeBudget.HUD_STARLING_CAP_MIB, residentBytes() / 1048576 + _loc3_));
	}

	static function accountedBytes():Float {
		return sPages != null ? sPages.accountedBytes + sFramePages.accountedBytes : 0;
	}

	static function residentBytes():Float {
		var _loc2_:ASObject = null;
		var _loc1_:Float = 0;
		final __ax4_iter_279 = sLeases;
		if (checkNullIteratee(__ax4_iter_279))
			for (_tmp_ in __ax4_iter_279) {
				_loc2_ = _tmp_;
				_loc1_ += cast(_loc2_.pages, HudPages).accountedBytes + cast(_loc2_.framePages, HudPages).accountedBytes;
			}
		if (sPendingPages != null) {
			_loc1_ += sPendingPages.accountedBytes + sPendingFramePages.accountedBytes;
		}
		return _loc1_;
	}

	static function assignLease(node:ArtNode, lease:ASObject) {
		var _loc3_:ArtNode = null;
		if (node == null) {
			return;
		}
		node.lease = lease;
		final __ax4_iter_280 = node.children;
		if (checkNullIteratee(__ax4_iter_280))
			for (_tmp_ in __ax4_iter_280) {
				_loc3_ = _tmp_;
				assignLease(_loc3_, lease);
			}
	}

	static function releaseLease(lease:ASObject) {
		var _loc2_:ArtNode = null;
		final __ax4_iter_281:ASAny = lease.art;
		if (checkNullIteratee(__ax4_iter_281))
			for (_tmp_ in __ax4_iter_281) {
				_loc2_ = ASCompat.coerce(_tmp_, uI.hud.starlingConverted.ArtNode);
				_loc2_.release(ASCompat.coerce(lease.pages, brain.starling.swfConverter.BakedPages));
			}
		lease.pages.dispose();
		lease.framePages.dispose();
		ASCompat.setProperty(lease, "art", null);
		var _loc3_ = sLeases.indexOf(lease);
		if (_loc3_ >= 0) {
			sLeases.splice(_loc3_, 1);
		}
	}

	static function __init__() {
		sPinnedSymbols = {};
	}
}
