package starling.filters;

import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.textures.Texture;

interface IFilterHelper {
	function getTexture(resolution:Float = 1):Texture;

	function putTexture(texture:Texture):Void;

	@:isVar var targetBounds(get, never):Rectangle;

	@:isVar var target(get, never):DisplayObject;
}
