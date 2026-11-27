package starling.textures;

import flash.display3D.textures.TextureBase;
import flash.display3D.textures.VideoTexture;
import flash.events.Event;
import starling.core.Starling;
import starling.utils.Execute;

/*internal*/
class ConcreteVideoTexture extends ConcreteTexture {
	var _textureReadyCallback:ASFunction;

	var _disposed:Bool = false;

	public function new(base:VideoTexture, scale:Float = 1) {
		super(base, "bgra", base.videoWidth, base.videoHeight, false, false, false, scale);
	}

	override public function dispose() {
		base.removeEventListener("textureReady", onTextureReady);
		if (!_disposed) {
			videoBase.attachCamera(null);
			videoBase.attachNetStream(null);
			_disposed = true;
		}
		super.dispose();
	}

	override function createBase():TextureBase {
		return Starling.context.createVideoTexture();
	}

	@:allow(starling.textures)
	override function attachVideo(type:String, attachment:ASObject, onComplete:ASFunction = null) {
		_textureReadyCallback = onComplete;
		(base : ASAny)["attach" + type](attachment);
		base.addEventListener("textureReady", onTextureReady);
		setDataUploaded();
	}

	function onTextureReady(event:Event) {
		base.removeEventListener("textureReady", onTextureReady);
		Execute.execute(_textureReadyCallback, this);
		_textureReadyCallback = null;
	}

	override public function get_nativeWidth():Float {
		return videoBase.videoWidth;
	}

	override public function get_nativeHeight():Float {
		return videoBase.videoHeight;
	}

	override public function get_width():Float {
		return nativeWidth / scale;
	}

	override public function get_height():Float {
		return nativeHeight / scale;
	}

	@:isVar var videoBase(get, never):VideoTexture;

	function get_videoBase():VideoTexture {
		return ASCompat.reinterpretAs(base, VideoTexture);
	}
}
