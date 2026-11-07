package brain.assetRepository;

import flash.display.Loader;
import flash.filesystem.File;
import flash.system.LoaderContext;

class TestResourceLocator {
	public function new() {}

	public static function apply(arguments:Array<ASAny>) {}

	public static function file(path:String):File {
		return null;
	}

	public static function url(path:String):String {
		return path;
	}

	public static function loadBytes(loader:Loader, path:String, context:LoaderContext):Bool {
		return false;
	}
}
