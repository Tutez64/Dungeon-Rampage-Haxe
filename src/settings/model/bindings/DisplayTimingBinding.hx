package settings.model.bindings;

import settings.model.DisplayTimingSettings;

class DisplayTimingBinding implements ISettingBinding {
	var mTiming:DisplayTimingSettings;

	var mIsFrameRate:Bool = false;

	public function new(timing:DisplayTimingSettings, isFrameRate:Bool) {
		mTiming = timing;
		mIsFrameRate = isFrameRate;
	}

	public function read():ASAny {
		if (mIsFrameRate) {
			return mTiming.frameRate;
		}
		return mTiming.vsync;
	}

	public function write(value:ASAny) {
		if (mIsFrameRate) {
			mTiming.frameRate = ASCompat.toNumber(value);
		} else {
			mTiming.vsync = ASCompat.toBool(value);
		}
	}

	public function writeInitial(value:ASAny) {
		write(value);
	}

	public function destroy() {
		mTiming = null;
	}
}
