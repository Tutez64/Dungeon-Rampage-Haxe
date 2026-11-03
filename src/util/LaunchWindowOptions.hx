package util;

import brain.logger.Logger;
import brain.utils.FeatureFlags;
import flash.display.NativeWindow;
import flash.display.Stage;

class LaunchWindowOptions {
	public function new() {}

	public static function apply(stage:Stage, flags:FeatureFlags, arguments:Array<ASAny>) {
		var _loc5_:Array<ASAny> = null;
		var _loc6_:NativeWindow = null;
		var _loc4_:String;
		if (checkNullIteratee(arguments))
			for (_tmp_ in arguments) {
				_loc4_ = _tmp_;
				if (!(_loc4_ != "--windowed" && _loc4_.indexOf("--windowed=") != 0)) {
					_loc5_ = ASCompat.coerce(_loc4_ == "--windowed" ? null : ASCompat.coerce(new compat.RegExp("^(\\d{1,4})x(\\d{1,4})$",
						"i").exec(_loc4_.substr(11)), Array),
						Array);
					if (_loc4_ != "--windowed"
						&& (_loc5_ == null || ASCompat.toInt(_loc5_[1]) < 1 || ASCompat.toInt(_loc5_[2]) < 1 || ASCompat.toInt(_loc5_[1]) > 8192
							|| ASCompat.toInt(_loc5_[2]) > 8192)) {
						Logger.warn("Expected --windowed or --windowed=WIDTHxHEIGHT (each dimension 1..8192)");
						return;
					}
					flags.setFlagCliValue("start-windowed", true);
					stage.displayState = "normal";
					_loc6_ = stage.nativeWindow;
					_loc6_.restore();
					if (_loc5_ == null) {
						return;
					}
					_loc6_.width += ASCompat.toInt(_loc5_[1]) - stage.stageWidth;
					_loc6_.height += ASCompat.toInt(_loc5_[2]) - stage.stageHeight;
					Logger.info("Windowed game size requested: " + Std.string(_loc5_[1]) + "x" + Std.string(_loc5_[2]));
					return;
				}
			}
	}
}
