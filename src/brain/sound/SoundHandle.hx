package brain.sound;

import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import brain.workLoop.WorkComponent;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

class SoundHandle {
	var mSoundManager:SoundManager;

	var mWorkComponent:WorkComponent;

	var mEventComponent:EventComponent;

	var mSoundCompleteTask:Task;

	var mSound:Sound;

	var mSoundChannel:SoundChannel;

	var mOwnerComponentDestroy:ASFunction;

	var mVolume:Float = Math.NaN;

	var mPanning:Float = Math.NaN;

	var mCategory:String;

	var mLoopCount:Int = 0;

	var mSoundTransform:SoundTransform;

	var mPausePosition:Float = Math.NaN;

	var mManaged:Bool = false;

	var mRegistered:Bool = false;

	public function new(manager:SoundManager, facade:Facade, sound:Sound, category:String, destroyFunction:ASFunction, managed:Bool, volume:Float = 1,
			panning:Float = 0) {
		mSoundManager = manager;
		mWorkComponent = new LogicalWorkComponent(facade, "SoundHandle");
		MemoryTracker.track(mWorkComponent, "LogicalWorkComponent - created in SoundHandle, category: " + category, "brain");
		mSound = sound;
		mVolume = volume;
		mPanning = panning;
		mManaged = managed;
		mCategory = category;
		mEventComponent = new EventComponent(facade);
		MemoryTracker.track(mEventComponent, "EventComponent - created in SoundHandle, category: " + category, "brain");
		mEventComponent.addListener("SoundCategoryVoumeChangedEvent", handleVolumeCategoryChangedEvent);
		mOwnerComponentDestroy = destroyFunction;
		mSoundTransform = buildSoundTransform();
	}

	function handleVolumeCategoryChangedEvent(e:Event) {
		applySoundTransform();
	}

	public function play(loopCount:Float = 1, startPosition:Float = 0):Bool {
		if (!mRegistered && mManaged) {
			registerPlaying();
		}
		mLoopCount = Std.int(loopCount);
		mSoundTransform = buildSoundTransform();
		mSoundChannel = mSound.play(0, mLoopCount, mSoundTransform);
		if (mSoundChannel == null) {
			return false;
		}
		var _loc3_ = (mSound.length - startPosition) / 1000;
		if (_loc3_ <= 0) {
			Logger.warn("Bad sound length="
				+ Std.string(mSound.length)
				+ " or startPosition="
				+ Std.string(startPosition)
				+ " url="
				+ mSound.url);
			mLoopCount = 0;
			this.soundComplete();
		} else {
			mSoundCompleteTask = mWorkComponent.doLater(_loc3_, soundComplete);
		}
		return true;
	}

	public function pause() {
		if (mSoundChannel == null) {
			return;
		}
		mPausePosition = mSoundChannel.position;
		unregisterPlayingFromManager();
		mSoundChannel.stop();
	}

	public function resume() {
		play(mLoopCount, mPausePosition);
	}

	function soundComplete(gameClock:GameClock = null) {
		if (mLoopCount == 0) {
			if (!mManaged) {
				destroy();
				return;
			}
			if (mSoundCompleteTask != null) {
				mSoundCompleteTask.destroy();
			}
			mSoundCompleteTask = null;
		} else {
			mLoopCount = mLoopCount - 1;
			if (mSoundCompleteTask != null) {
				mSoundCompleteTask.destroy();
			}
			mSoundCompleteTask = null;
			if (mSoundChannel != null) {
				mSoundChannel.stop();
			}
			play(mLoopCount);
		}
	}

	public function stop() {
		if (mRegistered) {
			unregisterPlayingFromManager();
		}
		if (mSoundChannel == null) {
			return;
		}
		mSoundChannel.stop();
		mSoundChannel.removeEventListener("soundComplete", soundComplete);
		mPausePosition = 0;
		if (mSoundCompleteTask != null) {
			mSoundCompleteTask.destroy();
			mSoundCompleteTask = null;
		}
		mLoopCount = 0;
	}

	function registerPlaying() {
		mRegistered = true;
		mSoundManager.registerSoundPlaying(this);
	}

	function unregisterPlayingFromManager() {
		mRegistered = false;
		mSoundManager.unregisterSoundPlaying(this);
	}

	function buildSoundTransform():SoundTransform {
		var _loc1_ = mSoundManager.getDampenedVolumeScaleForCategory(mCategory);
		return new SoundTransform(mVolume * _loc1_, mPanning);
	}

	function applySoundTransform() {
		mSoundTransform = buildSoundTransform();
		if (mSoundChannel == null) {
			return;
		}
		mSoundChannel.soundTransform = mSoundTransform;
	}

	@:isVar public var volume(get, set):Float;

	public function get_volume():Float {
		return mVolume;
	}

	function set_volume(vol:Float):Float {
		mVolume = vol;
		applySoundTransform();
		return vol;
	}

	@:isVar public var panning(get, set):Float;

	public function get_panning():Float {
		return mPanning;
	}

	function set_panning(panning:Float):Float {
		mPanning = panning;
		applySoundTransform();
		return panning;
	}

	@:isVar public var category(get, never):String;

	public function get_category():String {
		return mCategory;
	}

	public function destroy() {
		stop();
		if (mOwnerComponentDestroy != null) {
			mOwnerComponentDestroy(this);
			mOwnerComponentDestroy = null;
		}
		mSoundManager = null;
		mSound = null;
		if (mSoundChannel != null) {
			mSoundChannel.stop();
			mSoundChannel = null;
		}
		mCategory = null;
		mSoundTransform = null;
		if (mWorkComponent != null) {
			mWorkComponent.destroy();
			mWorkComponent = null;
		}
		if (mEventComponent != null) {
			mEventComponent.destroy();
			mEventComponent = null;
		}
	}
}
