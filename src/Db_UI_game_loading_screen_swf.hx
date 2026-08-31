import brain.assetRepository.SwfAsset;
import flash.display.MovieClip;

@:bind
@:native("symbol55")
class Db_UI_game_loading_screen_swf extends MovieClip {
	public var loadingBar:ASAny;

	public var loading_text:ASAny;

	public function new() {
		super();
		#if cpp
		SwfAsset.applyExportedFontsForBind(this, "assets");
		#end
	}
}
