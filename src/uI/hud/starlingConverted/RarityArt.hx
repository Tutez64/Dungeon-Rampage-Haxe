package uI.hud.starlingConverted;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.starling.swfConverter.BakedPages;
import facade.DBFacade;
import flash.display.MovieClip;

/*internal*/
class RarityArt {
	@:allow(uI.hud.starlingConverted) static inline final DISPLAY_SCALE:Float = 0.85;

	static var sRows:Array<Dynamic>;

	static var sLoading:Int = 0;

	static var sLoaded:ASFunction;

	static var sDone:ASFunction;

	static var sPages:BakedPages;

	static var sFrames:BakedPages;

	static var sConverter:HudArtConverter;

	static var sModel:MovieClip;

	static var sIndex:Int = 0;

	static var sFailures:Int = 0;

	static final SLOT_PATHS:Vector<String> = Vector.ofArray(["UI_weapons.weapon_z", "UI_weapons.weapon_x", "UI_weapons.weapon_c"]);

	static var sLibraries:ASObject;

	static var sDefinitions:Array<Dynamic> = ASCompat.allocArray((0 : UInt));

	public function new() {}

	@:allow(uI.hud.starlingConverted) @:isVar static var busy(get, never):Bool;

	static function get_busy():Bool {
		return sDone != null;
	}

	@:allow(uI.hud.starlingConverted) @:isVar static var failures(get, never):Int;

	static function get_failures():Int {
		return sFailures;
	}

	@:allow(uI.hud.starlingConverted) static function key(swf:String, name:String, artSetScale:Float):String {
		return swf + "|" + name + "|" + BakedPages.scaleKey(artSetScale);
	}

	@:allow(uI.hud.starlingConverted) static function verifySlots(layout:ArtNode, facade:DBFacade) {
		var __ax4_iter_168:Vector<gameMasterDictionary.GMRarity>;
		var _loc3_:String = null;
		var _loc6_:ASObject = null;
		var _loc5_:String = null;
		var _loc4_:ArtNode = null;
		final __ax4_iter_167 = SLOT_PATHS;
		if (checkNullIteratee(__ax4_iter_167))
			for (_tmp_ in __ax4_iter_167) {
				_loc3_ = _tmp_;
				if (layout == null || layout.find(_loc3_) == null) {
					HudArt.fatal("Required HUD rarity slot missing: " + _loc3_);
				}
				__ax4_iter_168 = facade.gameMaster.Rarity;
				if (checkNullIteratee(__ax4_iter_168))
					for (_tmp_ in __ax4_iter_168) {
						_loc6_ = _tmp_;
						if (!(_loc6_ == null || !ASCompat.toBool(_loc6_.HasColoredBackground))) {
							_loc5_ = StarlingHudSlot.rarityKey(layout, _loc6_.BackgroundSwf, _loc6_.BackgroundIcon);
							_loc4_ = HudArt.artSetContent(layout, _loc5_);
							if (_loc4_ == null || _loc4_.failures > 0 || !hasPixels(_loc4_)) {
								HudArt.fatal("Required HUD rarity art missing: " + _loc5_ + " at " + _loc3_);
							}
						}
					}
			}
	}

	@:allow(uI.hud.starlingConverted) static function load(facade:DBFacade, assets:AssetLoadingComponent, done:ASFunction) {
		var _loc8_:ASObject = null;
		var _loc7_:String = null;
		var _loc4_:String = null;
		sLoaded = done;
		var _loc6_:ASObject = {};
		final __ax4_iter_169 = facade.gameMaster.Rarity;
		if (checkNullIteratee(__ax4_iter_169))
			for (_tmp_ in __ax4_iter_169) {
				_loc8_ = _tmp_;
				if (ASCompat.toBool(_loc8_.HasColoredBackground)) {
					_loc4_ = _loc8_.BackgroundSwf;
					_loc7_ = _loc4_ + "|" + Std.string(_loc8_.BackgroundIcon);
					if (_loc4_ == null
						|| _loc4_.length == 0
						|| _loc8_.BackgroundIcon == null
						|| ASCompat.toNumberField(_loc8_.BackgroundIcon, "length") == 0) {
						HudArt.fatal("Missing required HUD rarity background definition", true);
						return;
					}
					if (!ASCompat.toBool(_loc6_[_loc7_])) {
						_loc6_[_loc7_] = true;
						sDefinitions.push({
							"swf": _loc4_,
							"name": _loc8_.BackgroundIcon
						});
						sLibraries[_loc4_] = null;
					}
				}
			}
		var _loc5_ = new Vector<String>((0 : UInt));
		final __ax4_iter_170:ASObject = sLibraries;
		if (checkNullIteratee(__ax4_iter_170))
			for (_tmp_ in __ax4_iter_170.___keys()) {
				_loc4_ = _tmp_;
				_loc5_.push(_loc4_);
			}
		sLoading = _loc5_.length;
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_) {
				_loc4_ = _tmp_;
				loadLibrary(assets, _loc4_);
			}
		if (_loc5_.length == 0) {
			loaded();
		}
	}

	static function loadLibrary(assets:AssetLoadingComponent, path:String) {
		HudArt.loadStartupSwf(assets, path, function(param1:SwfAsset) {
			TimelineMasks.register(param1);
			sLibraries[path] = param1;
			loaded();
		});
	}

	static function loaded() {
		var _loc1_:ASObject = null;
		if (--sLoading > 0) {
			return;
		}
		final __ax4_iter_171 = sDefinitions;
		if (checkNullIteratee(__ax4_iter_171))
			for (_tmp_ in __ax4_iter_171) {
				_loc1_ = _tmp_;
				ASCompat.setProperty(_loc1_, "symbol",
					HudArt.requireClass(ASCompat.coerce(sLibraries[_loc1_.swf], brain.assetRepository.SwfAsset), _loc1_.swf, _loc1_.name));
			}
		var _loc2_ = sLoaded;
		sLoaded = null;
		if (_loc2_ != null) {
			_loc2_();
		}
	}

	@:allow(uI.hud.starlingConverted) static function bake(pages:BakedPages, frames:BakedPages, scale:Float, art:ASObject, done:ASFunction) {
		try {
			bakeSafely(pages, frames, scale, art, done);
		} catch (error:ASAny) {
			failed(error);
		}
	}

	static function bakeSafely(pages:BakedPages, frames:BakedPages, scale:Float, art:ASObject, done:ASFunction) {
		var __ax4_iter_173:Vector<String>;
		var __ax4_iter_174:Array<Dynamic>;
		var _loc11_:ASObject = null;
		var _loc6_:String = null;
		var _loc7_:String = null;
		var _loc8_:ArtNode = null;
		var _loc9_:String = null;
		sPages = pages;
		sFrames = frames;
		sDone = done;
		sRows = ASCompat.allocArray((0 : UInt));
		sIndex = 0;
		sFailures = 0;
		var _loc10_ = scale;
		var _loc12_:ASObject = {};
		final __ax4_iter_172 = Vector.ofArray(["ui_hud_old", "ui_hud"]);
		if (checkNullIteratee(__ax4_iter_172))
			for (_tmp_ in __ax4_iter_172) {
				_loc6_ = _tmp_;
				_loc8_ = ASCompat.dynamicAs(art[_loc6_], ArtNode);
				if (_loc8_ != null) {
					__ax4_iter_173 = SLOT_PATHS;
					if (checkNullIteratee(__ax4_iter_173))
						for (_tmp_ in __ax4_iter_173) {
							_loc7_ = _tmp_;
							if (_loc8_.find(_loc7_) == null) {
								throw new Error("Required HUD rarity slot missing: " + _loc6_ + "." + _loc7_);
							}
							__ax4_iter_174 = sDefinitions;
							if (checkNullIteratee(__ax4_iter_174))
								for (_tmp_ in __ax4_iter_174) {
									_loc11_ = _tmp_;
									_loc9_ = key(_loc11_.swf, _loc11_.name, scale);
									if (!(ASCompat.toBool(_loc12_[_loc9_]) || art["content|" + _loc9_] != null)) {
										_loc12_[_loc9_] = true;
										sRows.push({
											"key": _loc9_,
											"symbol": _loc11_.symbol,
											"scale": _loc10_
										});
									}
								}
						}
				}
			}
		next();
	}

	static function next() {
		try {
			nextSafely();
		} catch (error:ASAny) {
			failed(error);
		}
	}

	static function nextSafely() {
		var _loc3_:ASFunction = null;
		if (HudArt.fatalFailure) {
			return;
		}
		if (sIndex == sRows.length) {
			_loc3_ = sDone;
			sDone = null;
			if (_loc3_ != null) {
				_loc3_();
			}
			return;
		}
		var _loc2_:ASObject = sRows[sIndex];
		var _loc1_ = (_loc2_.symbol : Dynamic);
		sModel = ASCompat.dynamicAs(ASCompat.createInstance(_loc1_, []), MovieClip);
		if (sModel == null) {
			throw new Error("Required HUD rarity is not a MovieClip: " + Std.string(_loc2_.key));
		}
		sConverter = HudArtConverter.convertAsync(sModel, sPages, ASCompat.toNumberField(_loc2_, "scale"), {
			"hudScale": HudArt.bakePixelScale(sPages),
			"kind": timeline,
			"stageRate": true,
			"clipMasks": true,
			"stillChildren": true,
			"framePages": sFrames
		}, complete, 8);
	}

	static function timeline(path:String):String {
		return path.length == 0 ? "timeline" : null;
	}

	static function complete(art:ArtNode) {
		try {
			completeSafely(art);
		} catch (error:ASAny) {
			failed(error);
		}
	}

	static function completeSafely(art:ArtNode) {
		HudArtConverter.stopTree(sModel);
		var _loc2_:ASObject = sRows[sIndex];
		if (art == null || art.failures > 0 || !hasPixels(art)) {
			if (art != null) {
				art.release(sPages);
			}
			if (!HudArt.ready) {
				HudArt.fatal("Required HUD rarity bake failed: " + Std.string(_loc2_.key));
			}
			StarlingHud.reportError(new Error("HUD rarity rebake refused: " + Std.string(_loc2_.key)));
			sFailures = sFailures + 1;
			sConverter = null;
			sModel = null;
			sIndex = sIndex + 1;
			next();
			return;
		}
		art.pinStartupTree();
		HudArt.storeContent(_loc2_.key, art, sPages);
		sConverter = null;
		sModel = null;
		sIndex = sIndex + 1;
		next();
	}

	static function failed(error:ASAny) {
		var _loc3_:String = sRows != null && sIndex < sRows.length ? sRows[sIndex].key : "preparation";
		var _loc2_ = sDone;
		cancel();
		sFailures = sFailures + 1;
		HudArt.fail("HUD rarity conversion: " + _loc3_ + " " + ASCompat.toString(error), ASCompat.dynamicAs(error, Error));
		if (_loc2_ != null) {
			_loc2_();
		}
	}

	@:allow(uI.hud.starlingConverted) static function request(layout:ArtNode, key:String):ArtNode {
		var _loc3_ = HudArt.artSetContent(layout, key);
		if (_loc3_ == null) {
			HudArt.fatal("Required HUD rarity art missing: " + key);
		}
		return _loc3_;
	}

	@:allow(uI.hud.starlingConverted) static function cancel() {
		if (sConverter != null) {
			sConverter.cancel();
		}
		sConverter = null;
		sModel = null;
		sDone = null;
		sRows = null;
	}

	static function hasPixels(art:ArtNode):Bool {
		var _loc2_:ArtNode = null;
		var _loc3_:ArtFrame = null;
		if (art.cell != null && !art.cell.isEmpty) {
			return true;
		}
		final __ax4_iter_175 = art.frames;
		if (checkNullIteratee(__ax4_iter_175))
			for (_tmp_ in __ax4_iter_175) {
				_loc3_ = _tmp_;
				if (_loc3_ != null && _loc3_.cell != null && !_loc3_.cell.isEmpty) {
					return true;
				}
			}
		final __ax4_iter_176 = art.children;
		if (checkNullIteratee(__ax4_iter_176))
			for (_tmp_ in __ax4_iter_176) {
				_loc2_ = _tmp_;
				if (hasPixels(_loc2_)) {
					return true;
				}
			}
		return false;
	}

	static function __init__() {
		sLibraries = {};
	}
}
