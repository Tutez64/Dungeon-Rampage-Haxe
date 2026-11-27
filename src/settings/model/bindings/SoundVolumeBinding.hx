package settings.model.bindings;

import facade.DBFacade;
import sound.DBSoundManager;

class SoundVolumeBinding implements ISettingBinding {
	public static inline final MUSIC = "music";

	public static inline final SFX = "sfx";

	var mSoundManager:DBSoundManager;

	var mChannel:String;

	public function new(dbFacade:DBFacade, channel:String) {
		mSoundManager = ASCompat.reinterpretAs(dbFacade.soundManager, DBSoundManager);
		mChannel = channel;
	}

	public function read():ASAny {
		if (mSoundManager == null) {
			return 0;
		}
		return mChannel == "music" ? mSoundManager.musicVolumeScale : mSoundManager.sfxVolumeScale;
	}

	public function write(value:ASAny) {
		if (mSoundManager == null) {
			return;
		}
		if (mChannel == "music") {
			mSoundManager.musicVolumeScale = ASCompat.toNumber(value);
		} else {
			mSoundManager.sfxVolumeScale = ASCompat.toNumber(value);
		}
	}

	public function writeInitial(value:ASAny) {
		write(value);
	}

	public function destroy() {
		mSoundManager = null;
	}
}
