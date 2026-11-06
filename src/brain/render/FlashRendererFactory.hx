package brain.render;

import brain.facade.Facade;

class FlashRendererFactory extends RendererFactory {
	public function new(facade:Facade, backend:IRenderingBackend) {
		super(facade, backend);
	}
}
