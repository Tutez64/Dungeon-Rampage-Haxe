package brain.workLoop;

import brain.facade.Facade;

class LayerWorkComponent extends WorkComponent {
	public function new(dbFacade:Facade, ownerName:String = null) {
		super(dbFacade, dbFacade.layerRenderWorkManager, ownerName);
	}
}
