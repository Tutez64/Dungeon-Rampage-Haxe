package modding;

import facade.DBFacade;

/** Account reading available from `onReady`. Not a hero and not a floor. Fields read the live account. */
class ModAccount {
	public var id(get, never):UInt;

	/** False when the account has no active avatar. `onReady` still runs. */
	public var hasActiveAvatar(get, never):Bool;

	/** The avatar selected in town, 0 when there is none. Follows a change of selection. */
	public var activeAvatarId(get, never):UInt;

	var facade:DBFacade;

	function new(facade:DBFacade) {
		this.facade = facade;
	}

	function get_id():UInt {
		var info = facade.dbAccountInfo;
		return info == null ? 0 : info.id;
	}

	function get_hasActiveAvatar():Bool {
		var info = facade.dbAccountInfo;
		return info != null && info.activeAvatarInfo != null;
	}

	function get_activeAvatarId():UInt {
		var info = facade.dbAccountInfo;
		if (info == null)
			return 0;
		var avatar = info.activeAvatarInfo;
		return avatar == null ? 0 : avatar.id;
	}

	@:allow(modding.Host)
	static function from(facade:DBFacade):Null<ModAccount> {
		return facade == null || facade.dbAccountInfo == null ? null : new ModAccount(facade);
	}
}
