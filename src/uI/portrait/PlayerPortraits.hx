package uI.portrait;

import account.FriendInfo;
import facade.DBFacade;
import flash.display.DisplayObjectContainer;

class PlayerPortraits {
	var mViews:ASDictionary<ASAny, ASAny> = new ASDictionary();

	public function new() {}

	public function show(container:DisplayObjectContainer, facade:DBFacade, skinId:UInt, size:Float = 0, steamUrl:String = null,
			topLeft:Bool = false):PlayerPortraitView {
		var _loc7_ = create(container, facade, size, topLeft);
		_loc7_.update(skinId, steamUrl);
		return _loc7_;
	}

	public function showFriend(container:DisplayObjectContainer, facade:DBFacade, friend:FriendInfo, size:Float = 50):PlayerPortraitView {
		var _loc5_ = create(container, facade, size, true);
		_loc5_.bindFriend(friend);
		return _loc5_;
	}

	function create(container:DisplayObjectContainer, facade:DBFacade, size:Float, topLeft:Bool):PlayerPortraitView {
		remove(container);
		var _loc5_ = new PlayerPortraitView(facade, size, topLeft);
		mViews[container] = _loc5_;
		container.addChild(_loc5_);
		return _loc5_;
	}

	public function remove(container:DisplayObjectContainer) {
		var _loc2_ = ASCompat.coerce(mViews[container], uI.portrait.PlayerPortraitView);
		if (_loc2_ != null) {
			_loc2_.destroy();
		}
		mViews.remove(container);
	}

	public function clear() {
		var _loc1_:PlayerPortraitView;
		final __ax4_iter_483 = mViews;
		if (checkNullIteratee(__ax4_iter_483))
			for (_tmp_ in __ax4_iter_483) {
				_loc1_ = ASCompat.coerce(_tmp_, uI.portrait.PlayerPortraitView);
				_loc1_.destroy();
			}
		mViews = new ASDictionary<ASAny, ASAny>();
	}

	public function destroy() {
		clear();
	}
}
