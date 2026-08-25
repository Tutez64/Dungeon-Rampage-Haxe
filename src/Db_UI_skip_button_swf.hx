import brain.assetRepository.SwfAsset;
import flash.display.MovieClip;

@:bind
@:native("symbol41")
class Db_UI_skip_button_swf extends MovieClip {
	public var over:ASAny;

	public var up:ASAny;

	public function new() {
		super();
		#if cpp
		SwfAsset.applyExportedFontById(this, "assets", 39, "Db_UI_skip_button_swf");
		#end
	}
}
