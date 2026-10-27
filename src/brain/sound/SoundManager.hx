package brain.sound;

import brain.event.EventComponent;
import brain.facade.Facade;
import brain.logger.Logger;
import org.as3commons.collections.Map;
import org.as3commons.collections.Set;

class SoundManager {
	static inline final GLOBAL_VOLUME_DAMPENER:Float = 0.2040816;

	static inline final DEFAULT_VOLUME:Float = 0.7;

	var mCategoryVolumeScale:Map;

	var mEventComponent:EventComponent;

	var mMaxConcurrentSounds:UInt = (20 : UInt);

	var mSoundsDictionary:Map;

	public function new(facade:Facade) {
		mCategoryVolumeScale = new Map();
		mSoundsDictionary = new Map();
		mEventComponent = new EventComponent(facade);
	}

	public function destroy() {
		mEventComponent.destroy();
		mEventComponent = null;
		mSoundsDictionary = null;
		mCategoryVolumeScale = null;
	}

	public function registerSoundPlaying(soundHandle:SoundHandle) {
		var _loc2_:Set = null;
		if (mSoundsDictionary.hasKey(soundHandle.category)) {
			_loc2_ = ASCompat.dynamicAs(mSoundsDictionary.itemFor(soundHandle.category), Set);
			if (_loc2_.has(soundHandle)) {
				Logger.warn("Trying to register a sound handle that already exists in the set.");
				return;
			}
			_loc2_.add(soundHandle);
		} else {
			_loc2_ = new Set();
			_loc2_.add(soundHandle);
			mSoundsDictionary.add(soundHandle.category, _loc2_);
		}
	}

	public function unregisterSoundPlaying(soundHandle:SoundHandle) {
		if (!mSoundsDictionary.hasKey(soundHandle.category)) {
			Logger.error("Tryign to remove soundHandle from a category that does not exist in the dictionary. Category: " + soundHandle.category);
		}
		var _loc2_ = ASCompat.dynamicAs(mSoundsDictionary.itemFor(soundHandle.category), Set);
		if (_loc2_.has(soundHandle)) {
			_loc2_.remove(soundHandle);
		} else {
			Logger.warn("Trying to remove a soundHandle from a soundCategory that does not have it in the set.");
		}
	}

	public function setVolumeScaleForCategory(category:String, volumeScale:Float) {
		if (mCategoryVolumeScale.hasKey(category)) {
			mCategoryVolumeScale.replaceFor(category, volumeScale);
		} else {
			mCategoryVolumeScale.add(category, volumeScale);
		}
		mEventComponent.dispatchEvent(new SoundCategoryVoumeChangedEvent());
	}

	public function getDampenedVolumeScaleForCategory(category:String):Float {
		return getVolumeScaleForCategory(category) * getVolumeScaleForCategory(category) * 0.2040816;
	}

	public function getVolumeScaleForCategory(category:String):Float {
		if (mCategoryVolumeScale.hasKey(category)) {
			return ASCompat.toNumber(mCategoryVolumeScale.itemFor(category));
		}
		Logger.warn("No volume category found for category: " + category + "  Returning " + 0.7);
		return 0.7;
	}
}
