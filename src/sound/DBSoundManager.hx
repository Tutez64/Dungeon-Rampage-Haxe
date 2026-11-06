package sound;

import brain.logger.Logger;
import brain.sound.SoundHandle;
import brain.sound.SoundManager;
import collections.Set;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import settings.model.LocalSettingsFile;

class DBSoundManager extends SoundManager {
	public static inline final MUSIC_MIXER_CATEGORY = "music";

	public static inline final SFX_MIXER_CATEGORY = "sfx";

	var mCurrentMusic:SoundHandle;

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade) {
		super(dbFacade);
		mDBFacade = dbFacade;
		setVolumeScaleForCategory("music", DBGlobal.MUSIC_VOLUME);
		setVolumeScaleForCategory("sfx", DBGlobal.SFX_VOLUME);
	}

	public function applyStoredVolumeSettings() {
		var _loc1_:ASObject = new LocalSettingsFile().read();
		if (_loc1_ == null) {
			return;
		}
		if (_loc1_.hasOwnProperty("sfxVolume") && Std.isOfType(_loc1_["sfxVolume"], Float)) {
			sfxVolumeScale = ASCompat.toNumber(_loc1_["sfxVolume"]);
		}
		if (_loc1_.hasOwnProperty("musicVolume") && Std.isOfType(_loc1_["musicVolume"], Float)) {
			musicVolumeScale = ASCompat.toNumber(_loc1_["musicVolume"]);
		}
	}

	@:isVar public var musicVolumeScale(get, set):Float;

	public function set_musicVolumeScale(musicScale:Float):Float {
		this.setVolumeScaleForCategory("music", musicScale);
		return musicScale;
	}

	function get_musicVolumeScale():Float {
		return getVolumeScaleForCategory("music");
	}

	@:isVar public var sfxVolumeScale(get, set):Float;

	public function set_sfxVolumeScale(soundScale:Float):Float {
		this.setVolumeScaleForCategory("sfx", soundScale);
		return soundScale;
	}

	function get_sfxVolumeScale():Float {
		return getVolumeScaleForCategory("sfx");
	}

	override public function registerSoundPlaying(soundHandle:SoundHandle) {
		if (soundHandle.category == "music") {
			registerMusicPlaying(soundHandle);
		} else {
			super.registerSoundPlaying(soundHandle);
		}
	}

	function registerMusicPlaying(musicSoundHandle:SoundHandle) {
		if (mCurrentMusic == null) {
			mCurrentMusic = musicSoundHandle;
			super.registerSoundPlaying(musicSoundHandle);
			return;
		}
		var _loc2_ = ASCompat.dynamicAs(mSoundsDictionary.itemFor("music"), Set);
		if (!_loc2_.has(mCurrentMusic)) {
			Logger.error("CurrentMusicHandle in DBSoundManager is not registered.");
			return;
		}
		mCurrentMusic.stop();
		mCurrentMusic = null;
		mCurrentMusic = musicSoundHandle;
		super.registerSoundPlaying(mCurrentMusic);
	}

	override public function unregisterSoundPlaying(soundHandle:SoundHandle) {
		if (soundHandle.category == "music") {
			unregisterMusicPlaying(soundHandle);
		} else {
			super.unregisterSoundPlaying(soundHandle);
		}
	}

	function unregisterMusicPlaying(soundHandle:SoundHandle) {
		if (mCurrentMusic == null) {
			Logger.error("Trying to unregister music playing but mCurrentMusic is null");
			return;
		}
		mCurrentMusic = null;
		super.unregisterSoundPlaying(soundHandle);
	}
}
