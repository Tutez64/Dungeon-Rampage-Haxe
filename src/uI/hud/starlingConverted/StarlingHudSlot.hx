package uI.hud.starlingConverted;

import brain.assetRepository.AssetLoadingComponent;
import brain.starling.swfConverter.BakedPages;
import brain.utils.TextUtil;
import combat.weapon.ConsumableWeaponGameObject;
import combat.weapon.WeaponGameObject;
import dBGlobals.DBGlobal;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import facade.GameMasterLocale;
import flash.display.MovieClip;
import flash.geom.Point;
import starling.core.Starling;
import starling.display.DisplayObject;

class StarlingHudSlot {
	@:allow(UI.Hud.StarlingConverted) static inline final WEAPON_TOOLTIP_SWF = "Resources/Art2D/UI/db_UI_town.swf";

	@:allow(UI.Hud.StarlingConverted) static final WEAPON_TOOLTIPS:Vector<String> = Vector.ofArray(["DR_weapon_tooltip_z", "DR_weapon_tooltip"]);

	var mFacade:DBFacade;

	var mTicker:HudTicker;

	var mAssets:AssetLoadingComponent;

	var mButton:StarlingButton;

	var mRoot:ArtDisplay;

	var mGraphic:ArtDisplay;

	var mSelection:ArtDisplay;

	var mAuthoredTooltip:ArtDisplay;

	var mCooldown:TimelineView;

	var mQuantity:StarlingText;

	var mTextX:ArtDisplay;

	var mSpace:DisplayObject;

	var mOwner:HeroGameObjectOwner;

	var mIndex:Int = 0;

	var mTooltip:StarlingTooltip;

	var mWeaponTooltip:StarlingWeaponTooltip;

	var mConsumableTooltip:MovieClip;

	var mIcon:ArtView;

	var mRarity:ArtView;

	var mGeneration:UInt = 0;

	var mRetries:Vector<ASFunction> = new Vector((0 : UInt));

	var mFlashAmount:Float = Math.NaN;

	var mChanged:ASFunction;

	var mDestroyed:Bool = false;

	var mTooltipY:Float = Math.NaN;

	var mArt:ArtNode;

	var mPath:String;

	public function new(facade:DBFacade, ticker:HudTicker, view:ArtView, path:String, space:DisplayObject, index:Int, changed:ASFunction) {
		var _loc8_:ArtDisplay = null;

		mFacade = facade;
		mTicker = ticker;
		mAssets = new AssetLoadingComponent(facade);
		mSpace = space;
		mIndex = index;
		mChanged = changed;
		mArt = view.artNode("");
		mPath = path;
		mButton = new StarlingButton(view, path, space);
		mRoot = ASCompat.reinterpretAs(mButton.root, ArtDisplay);
		mGraphic = ASCompat.reinterpretAs(view.node(path + ".graphic"), ArtDisplay);
		if (mRoot == null || mGraphic == null) {
			throw new HudFatalError("Required HUD slot art missing: " + path);
		}
		mSelection = ASCompat.reinterpretAs(view.node(path + ".selectionFrame"), ArtDisplay);
		mAuthoredTooltip = ASCompat.reinterpretAs(view.node(path + ".tooltip"), ArtDisplay);
		mCooldown = ASCompat.reinterpretAs(view.node(path + ".cooldown"), TimelineView);
		mQuantity = ASCompat.reinterpretAs(view.node(path + ".quantity"), StarlingText);
		mTextX = ASCompat.reinterpretAs(view.node(path + ".textx"), ArtDisplay);
		if (mGraphic.numChildren > 0) {
			_loc8_ = mGraphic.flashChild(0);
			if (_loc8_ != null) {
				mGraphic.removeArt(_loc8_);
				_loc8_.dispose();
			}
		}
		reset();
		mTooltipY = -mRoot.height * 0.5;
	}

	@:allow(UI.Hud.StarlingConverted) static function rarityEnabled(facade:DBFacade, rarity:ASObject):Bool {
		return rarity != null
			&& ASCompat.toBool(rarity.HasColoredBackground)
			&& facade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds");
	}

	@:allow(UI.Hud.StarlingConverted) static function rarityKey(layout:ArtNode, swf:String, name:String):String {
		return RarityArt.key(swf, name, HudArt.artSetScale(layout));
	}

	@:isVar public var button(get, never):StarlingButton;

	public function get_button():StarlingButton {
		return mButton;
	}

	@:isVar public var consumableTooltip(never, set):MovieClip;

	public function set_consumableTooltip(value:MovieClip):MovieClip {
		return mConsumableTooltip = value;
	}

	public function reset() {
		var _loc1_:ASFunction = null;
		mGeneration = mGeneration + 1;
		final __ax4_iter_161 = mRetries;
		if (checkNullIteratee(__ax4_iter_161))
			for (_tmp_ in __ax4_iter_161) {
				_loc1_ = _tmp_;
				mTicker.cancelBake(_loc1_);
			}
		mRetries.length = 0;
		mFacade.mTween.killTweensOf(this);
		mFacade.mTween.killTweensOf(mGraphic);
		flashAmount = 0;
		mGraphic.alpha = 1;
		mGraphic.scaleX = mGraphic.scaleY = 1;
		stopCooldown(false);
		if (mIcon != null) {
			mGraphic.removeArt(ASCompat.reinterpretAs(mIcon.root, ArtDisplay));
			mIcon.dispose();
		}
		if (mRarity != null) {
			mRarity.dispose();
		}
		mIcon = mRarity = null;
		if (mTooltip != null) {
			mTooltip.dispose();
		}
		if (mWeaponTooltip != null) {
			mWeaponTooltip.clearAllIcons();
		}
		mTooltip = null;
		if (mConsumableTooltip != null) {
			mConsumableTooltip.visible = false;
		}
		if (mSelection != null) {
			mSelection.setHudVisibility(false);
		}
		if (mAuthoredTooltip != null) {
			mAuthoredTooltip.setHudVisibility(false);
		}
		mButton.pressCallback = mButton.releaseCallback = mButton.pressRollOutCallback = null;
		mButton.rollOverCallback = mButton.rollOutCallback = null;
		mButton.enabled = true;
		mButton.upOnly = true;
		mButton.restartState();
		mButton.setHover(false);
		mButton.setPressed(false);
		mRoot.setGrayscale(false);
		if (mQuantity != null) {
			mQuantity.setContent("", "glyphs");
			mQuantity.setHudVisibility(false);
		}
		if (mTextX != null) {
			mTextX.setHudVisibility(false);
		}
		mOwner = null;
	}

	public function equipWeapon(owner:HeroGameObjectOwner, weapon:WeaponGameObject) {
		reset();
		mOwner = owner;
		if (weapon == null) {
			return;
		}
		mButton.upOnly = false;
		mButton.pressCallback = weaponPressed;
		mButton.releaseCallback = weaponReleased;
		mButton.pressRollOutCallback = heldRollOut;
		loadWeaponTooltip(weapon);
		loadArt(weapon.weaponAesthetic.IconSwf, weapon.weaponAesthetic.IconName);
		var _loc3_ = weapon.gmRarity;
		if (rarityEnabled(mFacade, _loc3_)) {
			attachRarity(_loc3_.BackgroundSwf, _loc3_.BackgroundIcon);
		}
	}

	public function equipConsumable(owner:HeroGameObjectOwner, weapon:ConsumableWeaponGameObject) {
		reset();
		mOwner = owner;
		if (weapon == null) {
			return;
		}
		mButton.upOnly = false;
		mQuantity.setHudVisibility(true);
		mTextX.setHudVisibility(true);
		mQuantity.text = Std.string(weapon.getConsumableCount());
		mButton.releaseCallback = consumableReleased;
		TextUtil.setText(ASCompat.coerce((mConsumableTooltip : ASAny).description_label, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION", weapon.getGMStackable().Constant));
		mTooltip = new StarlingTooltip(mFacade, mRoot, mSpace, mConsumableTooltip, 0, new Point(mRoot.x, mRoot.y), true);
		mButton.rollOverCallback = mTooltip.rollOver;
		mButton.rollOutCallback = mTooltip.hide;
		loadArt(weapon.getGMStackable().UISwfFilepath, weapon.getGMStackable().IconName);
		if (weapon.getConsumableCount() == 0) {
			exhaust();
		}
	}

	function weaponPressed() {
		if (mOwner == null) {
			return;
		}
		if (mOwner.currentWeaponIndex != mIndex) {
			mOwner.currentWeaponIndex = mIndex;
		} else {
			mOwner.PlayerAttack.addToPotentialWeaponInputQueue((mIndex : UInt), true, true);
		}
	}

	function weaponReleased() {
		if (mOwner != null && mOwner.currentWeaponIndex == mIndex) {
			mOwner.PlayerAttack.addToPotentialWeaponInputQueue((mIndex : UInt), false, true);
		}
	}

	function heldRollOut() {
		mButton.handPressToGame();
		mFacade.inputManager.onMouseDown(null);
	}

	function consumableReleased() {
		if (mOwner != null) {
			mOwner.tryToUseConsumable((mIndex : UInt));
		}
	}

	function loadWeaponTooltip(weapon:WeaponGameObject) {
		var generation = mGeneration;
		var swf = "Resources/Art2D/UI/db_UI_town.swf";
		var name = WEAPON_TOOLTIPS[mIndex == 0 ? 0 : 1];
		HudArt.loadRuntimeSwf(mAssets, swf, name, function(param1:brain.assetRepository.SwfAsset) {
			if (mDestroyed || generation != mGeneration) {
				return;
			}
			var _loc2_ = HudArt.requireClass(param1, swf, name);
			if (mWeaponTooltip == null) {
				mWeaponTooltip = new StarlingWeaponTooltip(mFacade, _loc2_);
			}
			mWeaponTooltip.setWeaponItemFromWeaponGameObject(weapon);
			mTooltip = new StarlingTooltip(mFacade, mRoot, mSpace, mWeaponTooltip, 0.4, new Point(0, mTooltipY));
			mButton.rollOverCallback = mTooltip.rollOver;
			mButton.rollOutCallback = mTooltip.hide;
		});
	}

	function attachRarity(swf:String, name:String) {
		var _loc5_ = rarityKey(mArt, swf, name);
		var _loc3_ = RarityArt.request(mArt, _loc5_);
		var _loc4_ = ArtView.build(_loc3_, mTicker);
		cast(_loc4_.root, ArtDisplay).advanceHiddenTimelines(true);
		_loc4_.root.scaleX = _loc4_.root.scaleY = 0.85;
		_loc4_.root.name = "rarityIcon";
		_loc4_.root.y -= 6;
		if (mRarity != null) {
			mRarity.dispose();
		}
		mRarity = _loc4_;
		mRoot.addAtFlashDepth(_loc4_.root, 2);
		if (Std.isOfType(_loc4_.root, TimelineView)) {
			cast(_loc4_.root, TimelineView).play(0, true);
		}
		mChanged();
	}

	function loadArt(swf:String, name:String) {
		var generation = mGeneration;
		HudArt.loadRuntimeSwf(mAssets, swf, name, function(param1:brain.assetRepository.SwfAsset) {
			var symbol:Dynamic;
			var scale:Float;
			var pixelScale:Float;
			var key:String;
			var source:MovieClip = null;
			var retry:ASFunction = null;
			var asset = param1;
			if (mDestroyed || generation != mGeneration) {
				return;
			}
			symbol = HudIconBake.symbol(asset, swf, name);
			TimelineMasks.register(asset);
			scale = 60 / DBGlobal.WEAPON_ICON_NATIVE_SIZE;
			pixelScale = BakeScale.forArt(mArt, mPath + ".graphic") * HudArt.pixelScale * scale;
			key = swf + "|" + name + "|" + scale + "|" + BakedPages.scaleKey(pixelScale);
			retry = function():Bool {
				var _loc10_:Bool;
				var _loc1_:ArtNode = null;
				var _loc2_:ArtView = null;
				try {
					if (mDestroyed || generation != mGeneration) {
						return true;
					}
					if (Starling.current == null || !Starling.current.contextValid) {
						return false;
					}
					_loc1_ = HudArt.content(key);
					if (_loc1_ == null) {
						if (source == null) {
							try {
								source = ASCompat.dynamicAs(ASCompat.createInstance(symbol, []), MovieClip);
								if (source == null) {
									throw new Error("Required HUD slot icon is not a MovieClip");
								}
							} catch (constructionError:ASAny) {
								HudArt.runtimeAssetFailed(swf, name, constructionError);
								return true;
							}
						}
						_loc1_ = HudArtConverter.convert(source, HudArt.pages, pixelScale, {
							"flatten": true,
							"framePages": HudArt.framePages
						});
						HudArtConverter.stopTree(source);
						if (_loc1_ == null || _loc1_.failures > 0) {
							if (_loc1_ != null) {
								_loc1_.release(HudArt.pages);
							}
							throw new Error("HUD slot rasterisation refused");
						}
						HudArt.storeContent(key, _loc1_);
					}
					_loc2_ = ArtView.build(_loc1_, mTicker);
					cast(_loc2_.root, ArtDisplay).advanceHiddenTimelines(true);
					_loc2_.root.scaleX = _loc2_.root.scaleY = scale;
					_loc2_.root.name = "weaponIcon";
					mIcon = _loc2_;
					mGraphic.addAtFlashDepth(_loc2_.root, 0, true);
					if (!mButton.enabled) {
						applyGrayscale();
					}
					source = null;
					mRetries.removeAt(mRetries.indexOf(retry));
					mChanged();
					return true;
				} catch (error:Dynamic) {
					StarlingHud.reportError(error);
					_loc10_ = true;
				}
				return _loc10_;
			};
			mRetries.push(retry);
			if (!ASCompat.toBool(retry())) {
				mTicker.deferBake(retry);
			}
		});
	}

	public function highlight(value:Bool) {
		if (mSelection != null) {
			mSelection.setHudVisibility(value);
		}
	}

	public function startCooldown(seconds:Float, elapsed:Float = 0) {
		if (mCooldown == null) {
			return;
		}
		mCooldown.setHudVisibility(true);
		mCooldown.stageRate = false;
		mCooldown.playRate = 4.1 / seconds;
		mCooldown.play(Math.min(mCooldown.art.totalFrames - 1, 24 * elapsed * mCooldown.playRate));
		mGraphic.alpha = 0.5;
		mChanged();
	}

	public function stopCooldown(flash:Bool = true) {
		if (mCooldown != null) {
			mCooldown.stop();
			mCooldown.setHudVisibility(false);
		}
		mGraphic.alpha = 1;
		if (!flash) {
			return;
		}
		mFacade.mTween.tweenMaxTo(mGraphic, 0.25, {
			"scaleX": 1.25,
			"scaleY": 1.25
		});
		mFacade.mTween.tweenMaxTo(this, 0.25, {
			"flashAmount": 1,
			"onComplete": flashBack
		});
	}

	function flashBack() {
		try {
			mFacade.mTween.tweenMaxTo(mGraphic, 0.25, {
				"scaleX": 1,
				"scaleY": 1
			});
			mFacade.mTween.tweenMaxTo(this, 0.25, {"flashAmount": 0});
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
	}

	@:isVar public var flashAmount(get, set):Float;

	public function get_flashAmount():Float {
		return mFlashAmount;
	}

	function set_flashAmount(value:Float):Float {
		try {
			mFlashAmount = value;
			mGraphic.tint(1 - value, 1 - value, 1 - value, 255 * value, 255 * value, 255 * value);
			if (mChanged != null) {
				mChanged();
			}
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
		return value;
	}

	public function decrement() {
		if (mQuantity != null) {
			mQuantity.text = Std.string(ASCompat.toInt(mQuantity.text) - 1);
		}
		mChanged();
	}

	function applyGrayscale() {
		if (!mRoot.setGrayscale(true)) {
			throw new Error("HUD grayscale content refused");
		}
	}

	public function exhaust() {
		mButton.enabled = false;
		if (mTooltip != null) {
			mTooltip.hide();
		}
		applyGrayscale();
		mChanged();
	}

	public function hideTooltip() {
		if (mTooltip != null) {
			mTooltip.hide();
		}
	}

	public function dispose() {
		if (mDestroyed) {
			return;
		}
		mDestroyed = true;
		try {
			reset();
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
		StarlingHud.disposeResource(mIcon);
		StarlingHud.disposeResource(mRarity);
		StarlingHud.disposeResource(mTooltip);
		StarlingHud.disposeResource(mAssets, "destroy");
		StarlingHud.disposeResource(mWeaponTooltip, "destroy");
		mWeaponTooltip = null;
		StarlingHud.disposeResource(mButton);
		mConsumableTooltip = null;
		mFacade = null;
	}
}
