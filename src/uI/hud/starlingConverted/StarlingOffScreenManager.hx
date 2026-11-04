package uI.hud.starlingConverted;

import actor.ActorGameObject;
import brain.event.EventComponent;
import collections.IMapIterator;
import distributedObjects.HeroGameObject;
import distributedObjects.HeroGameObjectOwner;
import events.ActorLifetimeEvent;
import facade.DBFacade;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import starling.display.DisplayObjectContainer;

class StarlingOffScreenManager {
	var mFacade:DBFacade;

	var mOwner:HeroGameObjectOwner;

	var mParent:DisplayObjectContainer;

	var mTicker:HudTicker;

	var mEvents:EventComponent;

	var mClips:Vector<StarlingOffScreenClip> = new Vector((0 : UInt));

	var mBounds:Rectangle;

	var mDirection:Vector3D = new Vector3D();

	var mPosition:Vector3D = new Vector3D();

	var mRemoteCount:UInt = 0;

	var mChanged:ASFunction;

	var mCut:StarlingWorldCut;

	public function new(facade:DBFacade, ticker:HudTicker, parent:DisplayObjectContainer, owner:HeroGameObjectOwner, changed:ASFunction,
			cut:StarlingWorldCut = null) {
		mFacade = facade;
		mTicker = ticker;
		mParent = parent;
		mOwner = owner;
		mChanged = changed;
		mCut = cut;
		mBounds = new Rectangle(50, 100, facade.viewWidth - 110, facade.viewHeight - 225);
		mEvents = new EventComponent(facade);
		mEvents.addListener("ACTOR_CREATED", actorCreated);
		mEvents.addListener("ACTOR_DESTROYED", actorDestroyed);
		syncRemote();
	}

	static function worldCenter(actor:ActorGameObject, result:Vector3D) {
		if (actor.navCollisions == null || actor.navCollisions.length == 0 || actor.navCollisions[0] == null) {
			result.copyFrom(actor.position);
			return;
		}
		var _loc3_ = actor.navCollisions[0].getBody().GetWorldCenter();
		result.setTo(_loc3_.x * 50, _loc3_.y * 50, 0);
	}

	function syncRemote() {
		var _loc2_ = mOwner.distributedDungeonFloor.remoteHeroes;
		mRemoteCount = _loc2_.size;
		var _loc1_ = ASCompat.reinterpretAs(_loc2_.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			add(ASCompat.dynamicAs(_loc1_.next(), ActorGameObject));
		}
	}

	function actorCreated(event:ActorLifetimeEvent) {
		var _loc2_:ActorGameObject = null;
		try {
			_loc2_ = mOwner.distributedDungeonFloor.getActor(event.actorId);
			if (_loc2_ == null) {
				_loc2_ = ASCompat.dynamicAs(mOwner.distributedDungeonFloor.remoteHeroes.itemFor(event.actorId), ActorGameObject);
			}
			if (_loc2_ != null
				&& _loc2_ != mOwner
				&& (mOwner.distributedDungeonFloor.remoteHeroes.hasKey(_loc2_.id) || _loc2_.actorData.gMActor.HasOffscreenIndicator)) {
				add(_loc2_);
			}
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
	}

	function actorDestroyed(event:ActorLifetimeEvent) {
		var _loc2_ = 0;
		try {
			_loc2_ = 0;
			while (_loc2_ < mClips.length) {
				if (mClips[_loc2_].player.id == event.actorId) {
					remove(_loc2_);
					return;
				}
				_loc2_++;
			}
		} catch (error:Dynamic) {
			StarlingHud.reportError(error);
		}
	}

	function add(actor:ActorGameObject) {
		var _loc2_:StarlingOffScreenClip = null;
		if (actor == null || actor == mOwner || actor.isDestroyed) {
			return;
		}
		final __ax4_iter_278 = mClips;
		if (checkNullIteratee(__ax4_iter_278))
			for (_tmp_ in __ax4_iter_278) {
				_loc2_ = _tmp_;
				if (_loc2_.player == actor) {
					return;
				}
			}
		_loc2_ = new StarlingOffScreenClip(mFacade, mTicker, mParent, actor, mChanged);
		mClips.push(_loc2_);
		if (mCut != null) {
			mCut.addDynamic(_loc2_.root);
		}
	}

	function remove(index:Int) {
		if (mCut != null) {
			mCut.removeDynamic(mClips[index].root);
		}
		mClips[index].dispose();
		mClips.removeAt(index);
		mChanged();
	}

	public function update() {
		var _loc8_ = 0;
		var _loc12_:StarlingOffScreenClip = null;
		var _loc1_:ActorGameObject = null;
		var _loc9_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc4_ = false;
		if (mRemoteCount != mOwner.distributedDungeonFloor.remoteHeroes.size) {
			syncRemote();
		}
		if (mClips.length == 0 || mOwner.view == null) {
			return;
		}
		var _loc2_ = mOwner.view.position;
		var _loc11_ = mPosition;
		var _loc3_ = mFacade.camera.visibleRectangle;
		_loc8_ = 0;
		while (_loc8_ < mClips.length) {
			_loc12_ = mClips[_loc8_];
			_loc1_ = _loc12_.player;
			if (_loc1_.isDestroyed
				|| Std.isOfType(_loc1_, HeroGameObject)
				&& !mOwner.distributedDungeonFloor.remoteHeroes.hasKey(_loc1_.id)
				&& !_loc1_.actorData.gMActor.HasOffscreenIndicator) {
				remove(_loc8_--);
				syncRemote();
			} else if (_loc1_.view != null) {
				if (_loc12_.beginUpdate()) {
					_loc12_.update();
					worldCenter(_loc1_, _loc11_);
					_loc4_ = !_loc3_.contains(_loc11_.x, _loc11_.y);
					if (_loc12_.root.visible != _loc4_) {
						_loc12_.root.visible = _loc4_;
						if (!_loc4_) {
							_loc12_.showSteamAvatar();
						}
						mChanged();
					}
					if (_loc4_) {
						mDirection.setTo(_loc2_.x - _loc11_.x, _loc2_.y - _loc11_.y, _loc2_.z - _loc11_.z);
						_loc6_ = mDirection.length;
						if (_loc6_ != 0) {
							mDirection.scaleBy(1 / _loc6_);
							_loc9_ = Math.acos(-mDirection.x) * 180 / 3.141592653589793;
							_loc5_ = (_loc11_.y > _loc2_.y ? _loc9_ + 180 : 180 - _loc9_) * 3.141592653589793 / 180;
							_loc7_ = _loc9_ <= 45 ? mBounds.right : (_loc9_ >= 135 ? mBounds.left : mBounds.right - mBounds.width / 90 * (_loc9_ - 45));
							if (_loc11_.y > _loc2_.y) {
								_loc10_ = _loc9_ > 45
									&& _loc9_ < 135 ? mBounds.bottom : (_loc9_ <= 45 ? mBounds.top + mBounds.height / 2 +
										mBounds.height / 90 * _loc9_ : mBounds.bottom
										- mBounds.height / 90 * (_loc9_ - 135));
							} else {
								_loc10_ = _loc9_ > 45
									&& _loc9_ < 135 ? mBounds.top : (_loc9_ <= 45 ? mBounds.top +
										mBounds.height / 2 - mBounds.height / 90 * _loc9_ : mBounds.top
										+ mBounds.height / 90 * (_loc9_ - 135));
							}
							if (_loc12_.root.x != _loc7_ || _loc12_.root.y != _loc10_ || _loc12_.arrow.rotation != _loc5_) {
								mChanged();
							}
							_loc12_.root.x = _loc7_;
							_loc12_.root.y = _loc10_;
							_loc12_.arrow.rotation = _loc5_;
							_loc12_.keepTextOnScreen(mFacade.viewWidth);
							_loc12_.keepChatOnScreen(mFacade.viewWidth, mFacade.viewHeight);
						}
					}
				}
			}
			_loc8_++;
		}
	}

	public function handlePicChange(playerId:Int, type:String) {
		var _loc3_:StarlingOffScreenClip = null;
		final __ax4_iter_279 = mClips;
		if (checkNullIteratee(__ax4_iter_279))
			for (_tmp_ in __ax4_iter_279) {
				_loc3_ = _tmp_;
				if (_loc3_.player.id == (playerId : UInt)) {
					_loc3_.handlePicChange(type);
					return;
				}
			}
	}

	public function dispose() {
		var _loc1_:StarlingOffScreenClip = null;
		final __ax4_iter_280 = mClips;
		if (checkNullIteratee(__ax4_iter_280))
			for (_tmp_ in __ax4_iter_280) {
				_loc1_ = _tmp_;
				if (mCut != null) {
					mCut.removeDynamic(_loc1_.root);
				}
				try {
					_loc1_.dispose();
				} catch (error:Dynamic) {
					StarlingHud.reportError(error);
				}
			}
		mClips.length = 0;
		mEvents.destroy();
	}
}
