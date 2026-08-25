package dr_floor;

import brain.logger.Logger;
import facade.DBFacade;
import gameMasterDictionary.GMDungeonModifier;

class DungeonModifierHelper {
	public var GMDungeonMod:GMDungeonModifier;

	public var NewThisFloor:Bool = false;

	public function new(dungeonModId:UInt, newThisFloor:Bool, dbFacade:DBFacade) {
		GMDungeonMod = ASCompat.dynamicAs(dbFacade.gameMaster.dungeonModifierById.itemFor(dungeonModId), gameMasterDictionary.GMDungeonModifier);
		if (GMDungeonMod == null) {
			Logger.error("Unable to find GMDungeonModifier with ID: " + dungeonModId);
		}
		NewThisFloor = newThisFloor;
	}
}
