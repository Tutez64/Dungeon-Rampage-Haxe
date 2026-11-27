package brain.gameObject;

import brain.facade.Facade;

class UniqueID {
	var mId:UInt = (0 : UInt);

	public function new(facade:Facade, val:UInt, go:GameObject) {
		mId = val;
		facade.gameObjectManager.addIdReference(val, go);
	}

	@:isVar public var id(get, never):UInt;

	public function get_id():UInt {
		return mId;
	}

	public function destroy(facade:Facade) {
		facade.gameObjectManager.removeIdReference(this);
		mId = (0 : UInt);
	}
}
