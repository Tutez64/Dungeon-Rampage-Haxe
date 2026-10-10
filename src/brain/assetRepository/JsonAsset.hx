package brain.assetRepository;

class JsonAsset extends Asset {
	var mJson:ASObject;

	public function new(loadedObject:ASObject) {
		super();
		mJson = haxe.Json.parse(Std.string(loadedObject));
	}

	@:isVar public var json(get, never):ASObject;

	public function get_json():ASObject {
		return mJson;
	}

	override public function destroy() {
		mJson = null;
		super.destroy();
	}
}
