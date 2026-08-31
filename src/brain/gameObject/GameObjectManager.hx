package brain.gameObject;

import brain.facade.Facade;
import brain.logger.Logger;
import org.as3commons.collections.Map;

class GameObjectManager {
	var mGameObjects:Map = new Map();

	var mFacade:Facade;

	public function new(facade:Facade) {
		mFacade = facade;
	}

	public function isIdActive(id:UInt):Bool {
		return mGameObjects.hasKey(id);
	}

	public function removeIdReference(uid:UniqueID) {
		if (mGameObjects.hasKey(uid.id)) {
			mGameObjects.removeKey(uid.id);
		} else {
			Logger.error("GameObjectManager:removeIdReference Removing id not existing " + uid);
		}
	}

	public function addIdReference(id:UInt, go:GameObject) {
		if (mGameObjects.hasKey(id)) {
			Logger.error("GameObjectManager:addIdReference Adding Id That Already Exists " + id);
		}
		mGameObjects.add(id, go);
	}

	public function getReferenceFromId(id:UInt):GameObject {
		return ASCompat.dynamicAs(mGameObjects.itemFor(id), brain.gameObject.GameObject);
	}
}
