package uI.portrait;

import account.FriendInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.logger.Logger;
import facade.DBFacade;
import gameMasterDictionary.GMSkin;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Rectangle;

class PlayerPortraitView extends MovieClip {
	public static inline final DEFAULT_SKIN_ID = (151 : UInt);

	public static inline final STEAM_READY = "PlayerPortraitSteamReady";

	var mDBFacade:DBFacade;

	var mAssets:AssetLoadingComponent;

	var mFriend:FriendInfo;

	var mSize:Float = Math.NaN;

	var mTopLeft:Bool = false;

	var mGeneration:UInt = (0 : UInt);

	var mDestroyed:Bool = false;

	var mSteamReady:Bool = false;

	public function new(dbFacade:DBFacade, size:Float = 0, topLeft:Bool = false) {
		super();
		mDBFacade = dbFacade;
		mSize = size;
		mTopLeft = topLeft;
		mouseEnabled = mouseChildren = false;
		if (size > 0) {
			graphics.beginFill((0 : UInt), 0);
			graphics.drawRect(topLeft ? 0 : -size / 2, topLeft ? 0 : -size / 2, size, size);
			graphics.endFill();
		}
	}

	public function bindFriend(friend:FriendInfo) {
		if (mDestroyed) {
			return;
		}
		unbindFriend();
		mFriend = friend;
		if (mFriend != null) {
			mFriend.addEventListener("FriendPortraitChanged", friendChanged);
		}
		friendChanged(null);
	}

	function unbindFriend() {
		if (mFriend != null) {
			mFriend.removeEventListener("FriendPortraitChanged", friendChanged);
		}
		mFriend = null;
	}

	function friendChanged(event:Event) {
		if (mFriend != null) {
			update(mFriend.skinId, mFriend.steamAvatarUrl);
		}
	}

	public function update(skinId:UInt, steamUrl:String = null) {
		var generation:UInt;
		if (mDestroyed) {
			return;
		}
		generation = ++mGeneration;
		if (mAssets != null) {
			mAssets.destroy();
		}
		mAssets = new AssetLoadingComponent(mDBFacade);
		mSteamReady = false;
		clearImage();
		loadHero(skinId, generation, false);
		if (steamUrl != null && steamUrl != "") {
			try {
				mAssets.getImageAsset(steamUrl, function(param1:brain.assetRepository.ImageAsset) {
					var _loc2_:Bitmap = null;
					if (mDestroyed || generation != mGeneration) {
						return;
					}
					try {
						if (param1 == null || param1.image == null || param1.image.bitmapData == null) {
							return;
						}
						_loc2_ = new Bitmap(param1.image.bitmapData);
					} catch (bitmapError:Dynamic) {
						return;
					}
					mSteamReady = true;
					showImage(_loc2_);
					dispatchEvent(new Event("PlayerPortraitSteamReady"));
				}, function() {});
			} catch (error:Dynamic) {}
		}
	}

	function loadHero(skinId:UInt, generation:UInt, isFallback:Bool) {
		var skin:GMSkin;
		var failed:ASFunction;
		if (mDestroyed || generation != mGeneration || mSteamReady) {
			return;
		}
		skin = mDBFacade.gameMaster.getSkinByType(skinId);
		if (skin == null || !ASCompat.stringAsBool(skin.UISwfFilepath) || !ASCompat.stringAsBool(skin.IconName)) {
			if (!isFallback) {
				loadHero((151 : UInt), generation, true);
			}
			return;
		}
		failed = function() {
			if (mDestroyed || generation != mGeneration || mSteamReady) {
				return;
			}
			if (!isFallback && skinId != 151) {
				loadHero((151 : UInt), generation, true);
			} else {
				Logger.warn("Unable to load default player portrait");
			}
		};
		mAssets.getSwfAsset(DBFacade.buildFullDownloadPath(skin.UISwfFilepath), function(param1:brain.assetRepository.SwfAsset) {
			if (mDestroyed || generation != mGeneration || mSteamReady) {
				return;
			}
			var _loc3_ = param1.getClass(skin.IconName);
			if (_loc3_ == null) {
				failed();
				return;
			}
			var _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), DisplayObject);
			if (_loc2_ == null) {
				failed();
				return;
			}
			showImage(_loc2_);
		}, failed);
	}

	function showImage(image:DisplayObject) {
		var _loc2_:Rectangle = null;
		var _loc3_ = Math.NaN;
		clearImage();
		if (mSize > 0) {
			_loc2_ = image.getBounds(image);
			if (_loc2_.width > 0 && _loc2_.height > 0) {
				_loc3_ = mSize / Math.max(_loc2_.width, _loc2_.height);
				image.scaleX = image.scaleY = _loc3_;
				image.x = -_loc2_.x * _loc3_ + (mSize - _loc2_.width * _loc3_) / 2;
				image.y = -_loc2_.y * _loc3_ + (mSize - _loc2_.height * _loc3_) / 2;
				if (!mTopLeft) {
					image.x -= mSize / 2;
					image.y -= mSize / 2;
				}
			}
		}
		addChild(image);
	}

	function clearImage() {
		while (numChildren > 0) {
			removeChildAt(numChildren - 1);
		}
	}

	public function destroy() {
		if (mDestroyed) {
			return;
		}
		mDestroyed = true;
		mGeneration = mGeneration + 1;
		unbindFriend();
		if (mAssets != null) {
			mAssets.destroy();
		}
		mAssets = null;
		clearImage();
		if (parent != null) {
			parent.removeChild(this);
		}
		mDBFacade = null;
	}
}
