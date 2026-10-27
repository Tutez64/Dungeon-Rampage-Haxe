package brain.component;

import brain.facade.Facade;

class Component {
	var mFacade:Facade;

	public function new(facade:Facade) {
		mFacade = facade;
	}

	public function destroy() {
		mFacade = null;
	}
}
