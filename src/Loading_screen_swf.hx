import brain.assetRepository.SwfAsset;
import flash.display.MovieClip;

@:bind
@:native("symbol35")
class Loading_screen_swf extends MovieClip {
	public var loadingBar:ASAny;

	public var loading_text:ASAny;

	public function new() {
		super();
		#if cpp
		SwfAsset.applyExportedFontById(this, "assets", 27, "Loading_screen_swf");
		#end
	}
}
