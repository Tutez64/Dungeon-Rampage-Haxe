package modding;

import account.DBAccountInfo;

/** Account reading available from `onReady`. Not a hero and not a floor. */
class ModAccount {
	public var id(default, null):UInt;

	/** False when the account has no active avatar. `onReady` still runs. */
	public var hasActiveAvatar(default, null):Bool;

	public var activeAvatarId(default, null):UInt;

	function new(info:DBAccountInfo) {
		id = info.id;
		var avatar = info.activeAvatarInfo;
		hasActiveAvatar = avatar != null;
		activeAvatarId = hasActiveAvatar ? avatar.id : 0;
	}

	@:allow(modding.Host)
	static function from(info:DBAccountInfo):Null<ModAccount> {
		return info == null ? null : new ModAccount(info);
	}
}
