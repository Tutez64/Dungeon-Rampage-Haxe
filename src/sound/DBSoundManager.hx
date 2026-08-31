package sound;

import brain.logger.Logger;
import brain.sound.SoundHandle;
import brain.sound.SoundManager;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import org.as3commons.collections.Set;

class DBSoundManager extends SoundManager {
	public static inline final MUSIC_MIXER_CATEGORY = "music";

	public static inline final SFX_MIXER_CATEGORY = "sfx";

	var mCurrentMusic:SoundHandle;

	public function new(dbFacade:DBFacade) {
		super(dbFacade);
		setVolumeScaleForCategory("music", DBGlobal.MUSIC_VOLUME);
		setVolumeScaleForCategory("sfx", DBGlobal.SFX_VOLUME);
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
