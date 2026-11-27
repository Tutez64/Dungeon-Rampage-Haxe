package settings.model.bindings;

import settings.model.GameLogFile;

class LogFileBinding implements ISettingBinding {
	public function new() {}

	public function read():ASAny {
		return GameLogFile.enabled;
	}

	public function write(value:ASAny) {
		GameLogFile.enabled = ASCompat.toBool(value);
	}

	public function writeInitial(value:ASAny) {
		write(value);
	}

	public function destroy() {
		GameLogFile.enabled = false;
	}
}
