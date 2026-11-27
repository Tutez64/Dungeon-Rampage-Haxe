package sound;

import brain.sound.SoundAsset;
import brain.sound.SoundComponent;
import brain.sound.SoundHandle;
import facade.DBFacade;
import flash.geom.Vector3D;
import flash.media.Sound;

class DBSoundComponent extends SoundComponent {
	var MIN_DISTANCE_FOR_SOUND:Float = 690;

	var mDBFacade:DBFacade;

	var mDBSoundManager:DBSoundManager;

	public function new(dbFacade:DBFacade) {
		super(dbFacade);
		mDBFacade = dbFacade;
		mDBSoundManager = ASCompat.reinterpretAs(mDBFacade.soundManager, DBSoundManager);
		MIN_DISTANCE_FOR_SOUND = mDBFacade.dbConfigManager.getConfigNumber("min_sound_distance", 690);
	}

	override public function destroy() {
		super.destroy();
		mDBFacade = null;
		mDBSoundManager = null;
	}

	public function playSfxOneShot(sfxSoundAsset:SoundAsset, soundPosition:Vector3D = null, loopCount:Int = 0, volume:Float = 1, panning:Float = 0,
			startPosition:Float = 0) {
		var _loc7_ = new Vector3D();
		_loc7_.x = -mDBFacade.camera.rootPosition.x;
		_loc7_.y = -mDBFacade.camera.rootPosition.y;
		if (soundPosition != null && Vector3D.distance(soundPosition, _loc7_) > MIN_DISTANCE_FOR_SOUND) {
			return;
		}
		this.playOneShot(sfxSoundAsset, "sfx", loopCount, volume, panning, startPosition);
	}

	public function playSfxManaged(sfxSoundAsset:SoundAsset, volume:Float = 1, panning:Float = 0):SoundHandle {
		return this.playManagedSound(sfxSoundAsset, "sfx", volume, panning);
	}

	public function playMusic(musicSoundAsset:SoundAsset, volume:Float = 1, panning:Float = 0, startTime:Float = 0):SoundHandle {
		return playStreamingMusic(musicSoundAsset.sound, volume, panning, startTime);
	}

	public function playStreamingMusic(sound:Sound, volume:Float = 1, panning:Float = 0, startTime:Float = 0):SoundHandle {
		var _loc5_ = new SoundHandle(mDBSoundManager, mDBFacade, sound, "music", unregisterSoundHandle, true, volume, panning);
		mSoundHandles.add(_loc5_);
		_loc5_.play(2147483647);
		return _loc5_;
	}
}
