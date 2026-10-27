package brain.gameObject;

import brain.facade.Facade;
import brain.logger.Logger;

class LocalUniqueID extends UniqueID {
	static var minId:UInt = (1000000 : UInt);

	static var maxId:UInt = (1099999 : UInt);

	static var cache:UInt = (1000000 : UInt);

	public function new(dbFacade:Facade, go:GameObject) {
		var _loc3_ = (0 : UInt);
		var _loc4_ = nextCandidate();
		while (_loc3_ == 0) {
			if (dbFacade.gameObjectManager.isIdActive(_loc4_)) {
				_loc4_ = nextCandidate();
			} else {
				_loc3_ = _loc4_;
			}
		}
		super(dbFacade, _loc3_, go);
	}

	function nextCandidate():UInt {
		cache += (1 : UInt);
		if (cache > maxId) {
			Logger.debug("--------------------------->Wrap **************************************");
			cache = minId;
		}
		return cache;
	}
}
