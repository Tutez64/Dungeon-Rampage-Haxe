package brain.sound;

import brain.assetRepository.Asset;
import flash.media.Sound;

class SoundAsset extends Asset {
	var mSound:Sound;

	public function new(sound:Sound) {
		super();
		mSound = sound;
	}

	@:isVar public var sound(get, never):Sound;

	public function get_sound():Sound {
		return mSound;
	}

	override public function destroy() {
		mSound = null;
		super.destroy();
	}
}
