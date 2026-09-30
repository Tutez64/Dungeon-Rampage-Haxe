package modding;

import flash.display.Sprite;

/** One equipped weapon, copied when read: it does not follow later changes. */
class ModWeapon {
	/** 0-based weapon slot. */
	public var slot(default, null):Int;

	/** GameMaster weapon item id. */
	public var id(default, null):UInt;

	/** Display name, as the inventory shows it, without its modifiers. */
	public var name(default, null):String;

	public var power(default, null):UInt;

	public var requiredLevel(default, null):UInt;

	/** GameMaster rarity constant, empty when unknown. */
	public var rarity(default, null):String;

	/** Text color the game uses for this rarity. */
	public var rarityColor(default, null):UInt;

	public var legendary(default, null):Bool;

	var rarityId:UInt;

	var modifier1:UInt;

	var modifier2:UInt;

	var legendaryModifier:UInt;

	@:allow(modding.ModHero)
	function new(slot:Int, id:UInt, name:String, power:UInt, requiredLevel:UInt, rarity:String, rarityColor:UInt, rarityId:UInt, modifier1:UInt,
			modifier2:UInt, legendaryModifier:UInt) {
		this.slot = slot;
		this.id = id;
		this.name = name;
		this.power = power;
		this.requiredLevel = requiredLevel;
		this.rarity = rarity;
		this.rarityColor = rarityColor;
		this.rarityId = rarityId;
		this.modifier1 = modifier1;
		this.modifier2 = modifier2;
		this.legendaryModifier = legendaryModifier;
		legendary = legendaryModifier > 0;
	}

	/**
	 * The game's icon for this weapon on its rarity background, centred in a `size` square. Hovering
	 * it shows the game's weapon tooltip. The art appears once loaded, and is released when the sprite
	 * is removed from its parent. Empty before `onReady`.
	 */
	public function createIcon(size:Float):Sprite {
		return ModArt.weaponIcon(id, power, requiredLevel, rarityId, modifier1, modifier2, legendaryModifier, size);
	}
}
