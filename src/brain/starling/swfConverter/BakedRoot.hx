package brain.starling.swfConverter;

import starling.display.Sprite;
import starling.rendering.Painter;

class BakedRoot extends Sprite {
	public function new() {
		super();
		touchable = false;
	}

	override public function render(painter:Painter) {
		painter.excludeFromCache(this);
		var _loc2_ = painter.cacheEnabled;
		painter.cacheEnabled = false;
		{
			try {
				super.render(painter);
			} catch (__finallyError0:Dynamic) {
				{
					painter.cacheEnabled = _loc2_;
				};
				ASCompat.rethrowKeepingStack(__finallyError0);
				throw __finallyError0;
			};
			{
				painter.cacheEnabled = _loc2_;
			};
		}
	}
}
