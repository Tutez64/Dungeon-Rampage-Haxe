package brain.render;

interface IRenderingBackend {
	@:isVar var backendType(get, never):String;

	@:isVar var isReady(get, never):Bool;

	function addChildToLayer(displayObject:ASObject, layerIndex:Int):Void;

	function removeChild(displayObject:ASObject):Void;

	function clearLayer(layerIndex:Int):Void;

	function destroy():Void;
}
