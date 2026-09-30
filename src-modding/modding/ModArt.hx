package modding;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.uI.UIObject;
import facade.DBFacade;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import gameMasterDictionary.GMRarity;
import gameMasterDictionary.GMWeaponItem;
import uI.inventory.UIWeaponTooltip;

/**
 * Game art handed to mods as plain sprites. Each sprite loads its art itself and releases it when
 * removed from its parent. Not for mods: they go through `ModWeapon` and `ModHero`.
 */
@:allow(modding.ModWeapon)
@:allow(modding.ModHero)
class ModArt {
	/** Holds the weapon tooltip template, as on the end screen. */
	static inline final TOWN_SWF = "Resources/Art2D/UI/db_UI_town.swf";

	/** Scales the end screen gives a weapon's icon and its rarity background. */
	static inline final ICON_SCALE:Float = 0.5;

	static inline final BACKGROUND_SCALE:Float = 0.65;

	/** Part of the square the icon's own bounds fill. */
	static inline final ICON_SHARE:Float = 1;

	static function weaponIcon(id:UInt, power:UInt, requiredLevel:UInt, rarityId:UInt, modifier1:UInt, modifier2:UInt, legendaryModifier:UInt,
			size:Float):Sprite {
		var root = new Sprite();
		root.mouseChildren = false;
		var facade = Host.facade;
		if (facade == null || facade.gameMaster == null)
			return root;
		var loader = new AssetLoadingComponent(facade);
		var item:GMWeaponItem = cast facade.gameMaster.weaponItemById.itemFor(id);
		var aesthetic = item == null ? null : item.getWeaponAesthetic(requiredLevel, legendaryModifier > 0);
		var rarity:GMRarity = cast facade.gameMaster.rarityById.itemFor(rarityId);
		var art = new Sprite();
		var back = new Sprite();
		var front = new Sprite();
		art.addChild(back);
		art.addChild(front);
		root.addChild(art);
		// The icon is fitted to the square; its background follows at the end screen's ratio, both on
		// their own origin, so a larger background (legendary) stays larger around it.
		if (aesthetic != null)
			load(loader, aesthetic.IconSwf, aesthetic.IconName, function(icon:DisplayObject) {
				UIObject.scaleToFit(icon, size * ICON_SHARE);
				var iconScale = icon.scaleX;
				centre(icon, iconScale, size);
				front.addChild(icon);
				if (rarity != null && rarity.HasColoredBackground)
					load(loader, rarity.BackgroundSwf, rarity.BackgroundIcon, function(background:DisplayObject) {
						centre(background, iconScale * BACKGROUND_SCALE / ICON_SCALE, size);
						back.addChild(background);
					});
				// Whatever the symbols' origin, the icon ends up in the middle and the background keeps its place around it.
				var bounds = icon.getBounds(art);
				art.x = size / 2 - (bounds.x + bounds.width / 2);
				art.y = size / 2 - (bounds.y + bounds.height / 2);
			});

		var tooltip:UIWeaponTooltip = null;
		if (item != null) {
			loader.getSwfAsset(DBFacade.buildFullDownloadPath(TOWN_SWF), function(asset:SwfAsset) {
				var template:Dynamic = asset.getClass("DR_weapon_tooltip");
				if (template == null || loader == null)
					return;
				tooltip = new UIWeaponTooltip(facade, template);
				tooltip.mouseEnabled = false;
				tooltip.mouseChildren = false;
				tooltip.setWeaponItemFromData(aesthetic != null ? aesthetic.Name : item.Name, power, item.TapIcon, item.HoldIcon, modifier1, modifier2,
					legendaryModifier, rarityId, requiredLevel, aesthetic);
			});
		}

		// The game shows tooltips in its scene graph, under the overlay; this one goes on top of it.
		function hide() {
			if (tooltip != null && tooltip.parent != null)
				tooltip.parent.removeChild(tooltip);
		}
		root.addEventListener("rollOver", function(_) {
			var top = Host.overlay;
			if (tooltip == null || top == null || root.stage == null)
				return;
			// Anchored on the icon's centre, as the end screen anchors it on its slot's origin.
			var at = top.globalToLocal(root.localToGlobal(new Point(size / 2, size / 2)));
			tooltip.x = at.x;
			tooltip.y = at.y;
			top.addChild(tooltip);
		});
		root.addEventListener("rollOut", function(_) hide());
		root.addEventListener("removedFromStage", function(_) hide());
		releaseOnRemove(root, function() {
			hide();
			if (tooltip != null)
				tooltip.destroy();
			tooltip = null;
			loader.destroy();
			loader = null;
		});
		return root;
	}

	static function skinPortrait(skinType:UInt, size:Float):Sprite {
		var root = new Sprite();
		root.mouseChildren = false;
		var facade = Host.facade;
		if (facade == null || facade.gameMaster == null || skinType == 0)
			return root;
		var skin = facade.gameMaster.getSkinByType(skinType);
		if (skin == null)
			return root;
		var loader = new AssetLoadingComponent(facade);
		place(loader, skin.UISwfFilepath, skin.IconName, root, size);
		releaseOnRemove(root, function() loader.destroy());
		return root;
	}

	/** Loads a symbol from a swf, scaled to fit and centred in a `size` square of `into`. */
	static function place(loader:AssetLoadingComponent, swf:String, symbol:String, into:Sprite, size:Float):Void {
		load(loader, swf, symbol, function(clip:DisplayObject) {
			UIObject.scaleToFit(clip, size);
			clip.x += size / 2;
			clip.y += size / 2;
			into.addChild(clip);
		});
	}

	static function centre(clip:DisplayObject, scale:Float, size:Float):Void {
		clip.scaleX = clip.scaleY = scale;
		clip.x = size / 2;
		clip.y = size / 2;
	}

	/** Loads a symbol from a swf and hands over a new instance of it. */
	static function load(loader:AssetLoadingComponent, swf:String, symbol:String, ready:DisplayObject->Void):Void {
		if (swf == null || swf == "" || symbol == null || symbol == "")
			return;
		loader.getSwfAsset(DBFacade.buildFullDownloadPath(swf), function(asset:SwfAsset) {
			var type:Dynamic = asset.getClass(symbol);
			if (type == null)
				return;
			ready(cast ASCompat.createInstance(type, []));
		});
	}

	/** Runs `release` once, when `root` itself leaves its parent. */
	static function releaseOnRemove(root:Sprite, release:Void->Void):Void {
		var done = false;
		root.addEventListener("removed", function(event:Event) {
			if (done || event.target != root)
				return;
			done = true;
			release();
		});
	}
}
