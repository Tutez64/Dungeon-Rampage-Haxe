package brain.workLoop;

import brain.facade.Facade;

class LogicalWorkComponent extends WorkComponent {
	public function new(facade:Facade, ownerName:String = null, category:String = "brain") {
		super(facade, facade.logicalWorkManager, ownerName, category);
	}
}
