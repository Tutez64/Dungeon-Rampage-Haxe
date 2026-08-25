package brain.sound;

import brain.component.Component;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import org.as3commons.collections.Set;
import org.as3commons.collections.framework.ISetIterator;

class SoundComponent extends Component {
	var mSoundHandles:Set;

	public function new(facade:Facade) {
		super(facade);
		mSoundHandles = new Set();
	}

	public function playOneShot(soundAsset:SoundAsset, category:String, loopCount:Int = 0, volume:Float = 1, panning:Float = 0, startPosition:Float = 0) {
		var _loc7_ = new SoundHandle(mFacade.soundManager, mFacade, soundAsset.sound, category, null, false, volume, panning);
		MemoryTracker.track(_loc7_, "SoundHandle - one-shot, category: " + category, "brain");
		_loc7_.play(loopCount, startPosition);
	}

	public function playManagedSound(soundAsset:SoundAsset, category:String, volume:Float = 1, panning:Float = 0):SoundHandle {
		var soundHandle = new SoundHandle(mFacade.soundManager, mFacade, soundAsset.sound, category, function(param1:SoundHandle) {
			unregisterSoundHandle(param1);
		}, true, volume, panning);
		MemoryTracker.track(soundHandle, "SoundHandle - managed, category: " + category, "brain");
		mSoundHandles.add(soundHandle);
		return soundHandle;
	}

	function unregisterSoundHandle(soundHandle:SoundHandle) {
		if (!mSoundHandles.has(soundHandle)) {
			Logger.warn("Trying to unregister soundHandle which does not exist in SoundComponent\'s set.");
			return;
		}
		mSoundHandles.remove(soundHandle);
	}

	override public function destroy() {
		var _loc1_:SoundHandle = null;
		var _loc2_ = ASCompat.reinterpretAs(mSoundHandles.iterator(), ISetIterator);
		while (_loc2_.hasNext()) {
			_loc1_ = ASCompat.dynamicAs(_loc2_.next(), brain.sound.SoundHandle);
			_loc1_.destroy();
		}
		mSoundHandles.clear();
		mSoundHandles = null;
	}
}
