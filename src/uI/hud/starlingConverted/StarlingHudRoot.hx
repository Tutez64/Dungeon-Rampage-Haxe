package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedRoot;
import starling.core.Starling;
import starling.rendering.Painter;
import starling.rendering.RenderState;

/*internal*/
class StarlingHudRoot extends BakedRoot {
	static final sSaved:RenderState = new RenderState();

	public function new() {
		super();
	}

	override public function render(painter:Painter) {
		var _loc2_ = painter.stencilReferenceValue;
		sSaved.copyFrom(painter.state);
		try {
			super.render(painter);
		} catch (error:Dynamic) {
			StarlingHud.reportError(ASCompat.asError(error));
			try {
				painter.finishMeshBatch();
			} catch (flushError:Dynamic) {
				StarlingHud.reportError(ASCompat.asError(flushError));
			}
			painter.state.copyFrom(sSaved);
			if (painter.stencilReferenceValue != _loc2_) {
				painter.stencilReferenceValue = _loc2_;
			}
			if (Starling.current != null && Starling.current.contextValid) {
				Starling.context.setStencilActions("frontAndBack", "equal");
			}
		}
	}
}
