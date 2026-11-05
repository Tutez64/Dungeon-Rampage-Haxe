package uI.hud.starlingConverted;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.starling.swfConverter.BakedPages;
import facade.DBFacade;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import starling.core.Starling;

class HudIconBake {
	@:allow(uI.hud.starlingConverted) static inline final AVATAR_MOUNT = "UI_widget.UI_avatar";

	static var sLoading:Int = 0;

	static var sLoaded:ASFunction;

	static var sDone:ASFunction;

	static var sDriver:Shape;

	static var sPages:BakedPages;

	static var sFrames:BakedPages;

	static var sArt:ASObject;

	static var sLayout:String;

	static var sIndex:Int = 0;

	static var sScale:Float = Math.NaN;

	static var sModifierWidth:Float = Math.NaN;

	static var sRows:Array<Dynamic> = ASCompat.allocArray((0 : UInt));

	static var sSeen:ASObject;

	static var sLibraries:ASObject;

	public function new() {}

	@:allow(uI.hud.starlingConverted) static function symbol(asset:SwfAsset, swf:String, name:String):Dynamic {
		return HudArt.isOptional(swf, name) ? HudArt.optionalClass(asset, swf, name) : HudArt.requireClass(asset, swf, name);
	}

	@:allow(uI.hud.starlingConverted) @:isVar static var requests(get, never):Array<Dynamic>;

	static function get_requests():Array<Dynamic> {
		return sRows;
	}

	@:allow(uI.hud.starlingConverted) static function load(facade:DBFacade, assets:AssetLoadingComponent, done:ASFunction) {
		var _loc5_:ASObject = null;
		var _loc4_:String = null;
		sLoaded = done;
		var _loc6_:ASObject = facade.gameMaster;
		final __ax4_iter_181:ASAny = _loc6_.Stackables;
		if (checkNullIteratee(__ax4_iter_181))
			for (_tmp_ in __ax4_iter_181) {
				_loc5_ = _tmp_;
				if (_loc5_.UsageAttack != null
					&& ASCompat.toNumberField(_loc5_.UsageAttack, "length") > 0
					&& !ASCompat.toBool(_loc5_.AccountBooster)) {
					add(_loc5_.UISwfFilepath, _loc5_.IconName, 0.6, false, true, "consumables_01.graphic");
				}
			}
		final __ax4_iter_182:ASAny = _loc6_.Buffs;
		if (checkNullIteratee(__ax4_iter_182))
			for (_tmp_ in __ax4_iter_182) {
				_loc5_ = _tmp_;
				if (ASCompat.toBool(_loc5_.ShowInHUD)) {
					add(_loc5_.IconSwf, _loc5_.IconName, 0.75, false, false, "buff_cooldown_icon.graphic");
				}
			}
		final __ax4_iter_183:ASAny = _loc6_.Npcs;
		if (checkNullIteratee(__ax4_iter_183))
			for (_tmp_ in __ax4_iter_183) {
				_loc5_ = _tmp_;
				if (_loc5_.CharType == "PET" && ASCompat.toBool(_loc5_.UsePetUI)) {
					add(_loc5_.IconSwfFilepath, _loc5_.IconName, 1.1764705882352942, false, false, "pet.graphic");
				}
				if (ASCompat.toBool(_loc5_.HasOffscreenIndicator)) {
					avatar(_loc5_.IconSwfFilepath, _loc5_.IconName);
				}
			}
		var _loc8_:ASObject = _loc6_.getSkinByType(facade.dbAccountInfo.activeAvatarSkinId);
		final __ax4_iter_184:ASAny = _loc6_.Skins;
		if (checkNullIteratee(__ax4_iter_184))
			for (_tmp_ in __ax4_iter_184) {
				_loc5_ = _tmp_;
				avatar(_loc5_.IconSwfFilepath, _loc5_.IconName);
			}
		if (_loc8_ != null) {
			add(_loc8_.UISwfFilepath, _loc8_.IconName, 1, false, false, "UI_profile.avatar", true);
		}
		final __ax4_iter_185:ASAny = _loc6_.DungeonModifiers;
		if (checkNullIteratee(__ax4_iter_185))
			for (_tmp_ in __ax4_iter_185) {
				_loc5_ = _tmp_;
				add(_loc5_.IconFilepath, _loc5_.IconName, 1, false, false, "floor_modifier01");
			}
		var _loc7_ = new Vector<String>((0 : UInt));
		final __ax4_iter_186:ASObject = sLibraries;
		if (checkNullIteratee(__ax4_iter_186))
			for (_tmp_ in __ax4_iter_186.___keys()) {
				_loc4_ = _tmp_;
				_loc7_.push(_loc4_);
			}
		sLoading = _loc7_.length;
		if (checkNullIteratee(_loc7_))
			for (_tmp_ in _loc7_) {
				_loc4_ = _tmp_;
				loadLibrary(assets, _loc4_);
			}
		if (_loc7_.length == 0) {
			loaded();
		}
	}

	static function avatar(swf:String, name:String) {
		add(swf, name, 1, false, false, "UI_widget.UI_avatar");
		add(swf, name, 1, true, false, "UI_widget.UI_avatar");
		add("Resources/Art2D/Icons/Avatars/db_icon_death.swf", "death_icon", 1, false, false, "UI_widget.UI_avatar");
	}

	public static function maskAvatar(source:DisplayObject, widgetClass:Dynamic = null):Sprite {
		var _loc4_ = false;
		var _loc9_:DisplayObject = null;
		var _loc6_ = 0;
		if (widgetClass == null) {
			widgetClass = HudArt.swfClass("UI_widget");
		}
		var _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(widgetClass, []), MovieClip);
		HudArtConverter.stopTree(_loc3_);
		var _loc8_ = ASCompat.reinterpretAs(_loc3_.getChildByName("UI_avatar"), DisplayObjectContainer);
		_loc6_ = 0;
		while (_loc6_ < _loc3_.numChildren) {
			_loc9_ = _loc3_.getChildAt(_loc6_);
			if (TimelineMasks.isMask(_loc3_, _loc9_)) {
				_loc4_ = true;
			} else if (_loc9_ != _loc8_) {
				_loc9_.visible = false;
			}
			_loc6_++;
		}
		if (_loc8_ == null || !_loc4_) {
			HudArt.fatal("UI_widget avatar mask missing");
		}
		_loc8_.addChild(source);
		var _loc5_ = _loc8_.transform.matrix.clone();
		_loc5_.invert();
		_loc3_.transform.matrix = _loc5_;
		var _loc7_ = new Sprite();
		_loc7_.addChild(_loc3_);
		return _loc7_;
	}

	static function add(swf:String, name:String, scale:Float, red:Bool = false, slot:Bool = false, mount:String = "", portrait:Bool = false) {
		if (swf == null || swf.length == 0 || name == null || name.length == 0) {
			return;
		}
		var _loc8_ = swf + "|" + name + "|" + scale + "|" + (slot ? "" : red + "|") + mount + "|" + portrait;
		if (ASCompat.toBool(sSeen[_loc8_])) {
			return;
		}
		sSeen[_loc8_] = true;
		sLibraries[swf] = null;
		sRows.push({
			"swf": swf,
			"name": name,
			"scale": scale,
			"red": red,
			"slot": slot,
			"mount": mount,
			"portrait": portrait
		});
	}

	static function loadLibrary(assets:AssetLoadingComponent, path:String) {
		HudArt.loadStartupSwf(assets, path, function(param1:SwfAsset) {
			sLibraries[path] = param1;
			loaded();
		});
	}

	static function loaded() {
		if (--sLoading > 0) {
			return;
		}
		var _loc1_ = sLoaded;
		sLoaded = null;
		if (_loc1_ != null) {
			_loc1_();
		}
	}

	@:allow(uI.hud.starlingConverted) static function bake(pages:BakedPages, frames:BakedPages, scale:Float, art:ASObject, layout:String, done:ASFunction) {
		var _loc8_:ArtView = null;
		var _loc7_:StarlingButton = null;
		sPages = pages;
		sFrames = frames;
		cast(pages, HudPages).mPinBakes = cast(frames, HudPages).mPinBakes = false;
		sLayout = layout;
		sScale = scale;
		sArt = art;
		sDone = done;
		sIndex = 0;
		var _loc9_ = ASCompat.dynamicAs(sArt[layout], ArtNode);
		var _loc10_ = ASCompat.coerce(_loc9_ != null ? _loc9_.find("floor_modifier01") : null, uI.hud.starlingConverted.ArtNode);
		sModifierWidth = 0;
		if (_loc10_ != null) {
			_loc8_ = ArtView.build(_loc10_);
			_loc7_ = new StarlingButton(_loc8_);
			sModifierWidth = _loc7_.root.width;
			_loc7_.dispose();
			_loc8_.dispose();
		}
		sDriver = new Shape();
		sDriver.addEventListener("enterFrame", update);
	}

	static function mountScale(path:String):Float {
		var _loc2_ = path.indexOf("UI_widget.") == 0 ? "UI_widget" : (path.indexOf("buff_cooldown_icon.") == 0 ? "buff_cooldown_icon" : sLayout);
		var _loc3_ = ASCompat.dynamicAs(sArt[_loc2_], ArtNode);
		if (_loc3_ == null || path.length == 0) {
			return 1;
		}
		if (_loc2_ == "UI_widget" || _loc2_ == "buff_cooldown_icon") {
			path = path.substr(_loc2_.length + 1);
		}
		return BakeScale.forArt(_loc3_, path) * (_loc2_ == "UI_widget" ? 1.44 : 1);
	}

	static function update(event:Event) {
		var _loc7_:ASObject = null;
		var _loc2_:Dynamic = null;
		var _loc8_:DisplayObject = null;
		var _loc6_:Sprite = null;
		var _loc3_:ArtNode = null;
		var _loc10_:String = null;
		var _loc4_:ArtNode = null;
		var _loc9_ = false;
		if (HudArt.fatalFailure) {
			cancel();
			return;
		}
		if (Starling.current == null || !Starling.current.contextValid) {
			return;
		}
		if (HudArtConverter.busy) {
			return;
		}
		var _loc5_ = flash.Lib.getTimer();
		while (sIndex < sRows.length && flash.Lib.getTimer() - _loc5_ < 8) {
			_loc7_ = sRows[sIndex++];
			_loc2_ = HudIconBake.symbol(ASCompat.coerce(sLibraries[_loc7_.swf], brain.assetRepository.SwfAsset), _loc7_.swf, _loc7_.name);
			if (_loc2_ != null) {
				try {
					_loc8_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), DisplayObject);
					if (_loc8_ == null) {
						throw new Error("Required HUD icon is not a DisplayObject");
					}
					HudArtConverter.stopTree(_loc8_);
				} catch (constructionError:ASAny) {
					cancel();
					HudArt.fatal("HUD startup icon construction failed: " + Std.string(_loc7_.swf) + " " + Std.string(_loc7_.name) + " "
						+ ASCompat.toString(constructionError));
				}
				try {
					if (ASCompat.toBool(_loc7_.portrait)) {
						_loc4_ = ASCompat.dynamicAs(sArt[sLayout], ArtNode);
						ASCompat.setProperty(_loc7_, "mount", _loc4_.find("avatar") != null ? "avatar" : "UI_profile.avatar");
					}
					ASCompat.setProperty(_loc7_,
						"displayScale", _loc7_.mount == "floor_modifier01" && sModifierWidth > 0 ? sModifierWidth / Math.max(_loc8_.width,
							_loc8_.height) : _loc7_.scale);
					ASCompat.setProperty(_loc7_, "pixelScale", sScale * ASCompat.toNumberField(_loc7_, "displayScale") * mountScale(_loc7_.mount));
					_loc9_ = _loc7_.mount == "UI_widget.UI_avatar";
					_loc10_ = ASCompat.toBool(_loc7_.portrait) ? "hudStarlingPortrait|"
						+ Std.string(_loc7_.swf)
						+ "|"
						+ Std.string(_loc7_.name)
						+ "|"
						+ BakedPages.scaleKey(ASCompat.toNumberField(_loc7_, "pixelScale")) : Std.string(_loc7_.swf)
						+ "|"
						+ Std.string(_loc7_.name)
						+ "|"
						+ Std.string(_loc7_.displayScale)
						+ "|"
						+ (ASCompat.toBool(_loc7_.slot) ? "" : Std.string(_loc7_.red) + "|")
						+ (_loc9_ ? "circle|" : "")
						+ BakedPages.scaleKey(ASCompat.toNumberField(_loc7_, "pixelScale"));
					if (sArt["content|" + _loc10_] == null) {
						if (ASCompat.toBool(_loc7_.red)) {
							_loc8_.transform.colorTransform = new ColorTransform(2.5, 0.25, 0.25, 1);
							_loc6_ = new Sprite();
							_loc6_.addChild(_loc8_);
							_loc8_ = _loc6_;
						}
						if (_loc9_) {
							_loc8_ = maskAvatar(_loc8_);
						}
						if (ASCompat.toBool(_loc7_.portrait) || _loc9_) {
							_loc3_ = new ArtNode();
							_loc3_.kind = "static";
							_loc3_.key = _loc10_;
							_loc3_.cell = _loc3_.hold(HudArt.bakeOn(sPages, _loc10_, _loc8_, ASCompat.toNumberField(_loc7_, "pixelScale"), false), sPages);
							if (_loc3_.cell == null) {
								_loc3_.failures++;
							}
						} else {
							_loc3_ = HudArtConverter.convert(_loc8_, sPages, ASCompat.toNumberField(_loc7_, "pixelScale"), {
								"hudScale": HudArt.bakePixelScale(sPages),
								"flatten": true,
								"framePages": sFrames
							});
						}
						HudArtConverter.stopTree(_loc8_);
						if (_loc3_ == null || _loc3_.failures > 0) {
							if (_loc3_ != null) {
								_loc3_.release(sPages);
							}
							if (!HudArt.ready) {
								cancel();
								HudArt.fatal("Required HUD icon bake failed: " + _loc10_);
							}
							StarlingHud.reportError(new Error("HUD icon rebake refused: " + _loc10_));
						} else {
							sArt["content|" + _loc10_] = _loc3_;
							_loc3_.pinStartupTree();
						}
					}
				} catch (error:ASAny) {
					cancel();
					if (Std.isOfType(error, HudFatalError)) {
						throw error;
					}
					HudArt.fatal("HUD startup icon preparation failed: " + Std.string(_loc7_.swf) + " " + Std.string(_loc7_.name) + " "
						+ ASCompat.toString(error));
				}
			}
		}
		if (sIndex == sRows.length) {
			finish();
		}
	}

	static function finish() {
		cancel();
		var _loc1_ = sDone;
		sDone = null;
		if (_loc1_ != null) {
			_loc1_();
		}
	}

	@:allow(uI.hud.starlingConverted) static function cancel() {
		if (sDriver != null) {
			sDriver.removeEventListener("enterFrame", update);
		}
		sDriver = null;
	}

	static function __init__() {
		sSeen = {};
		sLibraries = {};
	}
}
