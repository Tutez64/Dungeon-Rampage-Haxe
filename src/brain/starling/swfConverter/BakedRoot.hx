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
			} catch (__finallyError75:Dynamic) {
				{
					painter.cacheEnabled = _loc2_;
				};
				throw __finallyError75;
			};
			{
				painter.cacheEnabled = _loc2_;
			};
		}
	}
}
