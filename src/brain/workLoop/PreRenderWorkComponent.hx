package brain.workLoop;

import brain.facade.Facade;

class PreRenderWorkComponent extends WorkComponent {
	public function new(dbFacade:Facade, ownerName:String = null) {
		super(dbFacade, dbFacade.preRenderWorkManager, ownerName);
	}
}
