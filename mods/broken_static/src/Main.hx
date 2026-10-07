package mods.broken_static;

import mods.api.Mod;
import mods.api.Context;

/** A static initialiser throws while the world starts: the host fails the mod before the compile, and drops it. */
class Main extends Mod {
	static var value:Int = boom();

	static function boom():Int {
		throw "thrown on purpose";
	}

	override public function init(ctx:Context):Void {
		ctx.log("FAIL init reached a mod whose static initialiser threw");
	}
}
