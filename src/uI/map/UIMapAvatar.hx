package uI.map;

import facade.DBFacade;
import com.maccherone.json.JSON;
import flash.display.MovieClip;
import flash.events.Event;
import flash.net.URLLoader;

class UIMapAvatar {
	var mAvatar:MovieClip;

	var mAvatarDropShadow:MovieClip;

	var mAvatarMover:UIMapAvatarMover;

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade, avatar:MovieClip, avatarShadow:MovieClip, avatarMoverClass:Dynamic) {
		mDBFacade = dbFacade;
		mAvatar = avatar;
		mAvatarDropShadow = avatarShadow;
		mAvatarMover = ASCompat.dynamicAs(ASCompat.createInstance(avatarMoverClass, [updatePosition]), UIMapAvatarMover);
		updatePlayerName();
	}

	public function moveTo(x:Float, y:Float) {
		mAvatarMover.moveTo(x, y);
	}

	public function destroy(parent:MovieClip) {
		if (mAvatar != null) {
			parent.removeChild(mAvatar);
		}
		if (mAvatarDropShadow != null) {
			parent.removeChild(mAvatarDropShadow);
		}
		if (mAvatarMover != null) {
			mAvatarMover.destroy();
			mAvatarMover = null;
		}
	}

	function updatePosition(x:Float, y:Float) {
		mAvatar.x = x;
		mAvatar.y = y;
		mAvatarDropShadow.x = x;
		mAvatarDropShadow.y = y;
	}

	function loadedPlayerName(e:Event) {
		var _loc3_ = cast(e.target, URLLoader);
		var _loc2_:ASObject = com.maccherone.json.JSON.decode(_loc3_.data);
		ASCompat.setProperty((mAvatar : ASAny).label, "text", _loc2_["name"]);
	}

	function updatePlayerName() {
		ASCompat.setProperty((mAvatar : ASAny).label, "text",
			ASCompat.stringAsBool(mDBFacade.facebookAccountInfo.name) ? mDBFacade.facebookAccountInfo.name : mDBFacade.dbAccountInfo.name);
	}
}
