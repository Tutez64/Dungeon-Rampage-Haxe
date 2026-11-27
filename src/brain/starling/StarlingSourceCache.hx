package brain.starling;

import brain.utils.MemoryTracker;
import flash.display.BitmapData;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import flash.display.BitmapData;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class StarlingSourceCache {
	var mEntries:ASDictionary<ASAny, ASAny>;

	var mAtlases:ASDictionary<ASAny, ASAny>;

	public function new() {
		mEntries = new ASDictionary<ASAny, ASAny>();
		mAtlases = new ASDictionary<ASAny, ASAny>();
	}

	public function getOrCreate(key:String, bitmapData:BitmapData):Texture {
		var _loc3_ = ASCompat.coerce(ASDictionary.getString(mEntries, key), TextureCacheEntry);
		if (_loc3_ != null) {
			_loc3_.refCount++;
			bitmapData.dispose();
			return _loc3_.texture;
		}
		var _loc4_ = Texture.fromBitmapData(bitmapData, false);
		MemoryTracker.track(_loc4_, "StarlingSourceCache - Texture: " + key, "starling");
		mEntries[key] = new TextureCacheEntry(_loc4_, bitmapData, 1);
		return _loc4_;
	}

	public function getOrCreateShared(key:String, bitmapData:BitmapData):Texture {
		var _loc3_ = ASCompat.coerce(ASDictionary.getString(mEntries, key), TextureCacheEntry);
		if (_loc3_ != null) {
			_loc3_.refCount++;
			return _loc3_.texture;
		}
		var _loc5_ = bitmapData.clone();
		var _loc4_ = Texture.fromBitmapData(_loc5_, false);
		MemoryTracker.track(_loc4_, "StarlingSourceCache - Texture: " + key, "starling");
		mEntries[key] = new TextureCacheEntry(_loc4_, _loc5_, 1);
		return _loc4_;
	}

	public function peek(key:String):Texture {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(mEntries, key), TextureCacheEntry);
		if (_loc2_ == null) {
			return null;
		}
		return _loc2_.texture;
	}

	public function has(key:String):Bool {
		return ASCompat.dictionaryLookupNeNull(mEntries, key);
	}

	public function get(key:String):Texture {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(mEntries, key), TextureCacheEntry);
		if (_loc2_ == null) {
			return null;
		}
		_loc2_.refCount++;
		return _loc2_.texture;
	}

	public function releaseRef(key:String) {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(mEntries, key), TextureCacheEntry);
		if (_loc2_ == null) {
			return;
		}
		_loc2_.refCount--;
		if (_loc2_.refCount <= 0) {
			_loc2_.texture.dispose();
			_loc2_.bitmapData.dispose();
			mEntries.remove(key);
		}
	}

	public function registerAtlas(key:String, atlas:TextureAtlas, bitmapData:BitmapData) {
		var _loc4_ = ASCompat.coerce(ASDictionary.getString(mAtlases, key), AtlasCacheEntry);
		if (_loc4_ != null) {
			_loc4_.refCount++;
			atlas.dispose();
			bitmapData.dispose();
			return;
		}
		MemoryTracker.track(atlas, "StarlingSourceCache - TextureAtlas: " + key, "starling");
		mAtlases[key] = new AtlasCacheEntry(atlas, bitmapData, 1);
	}

	public function getAtlas(key:String):TextureAtlas {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(mAtlases, key), AtlasCacheEntry);
		if (_loc2_ == null) {
			return null;
		}
		_loc2_.refCount++;
		return _loc2_.atlas;
	}

	public function peekAtlas(key:String):TextureAtlas {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(mAtlases, key), AtlasCacheEntry);
		if (_loc2_ == null) {
			return null;
		}
		return _loc2_.atlas;
	}

	public function releaseAtlasRef(key:String) {
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(mAtlases, key), AtlasCacheEntry);
		if (_loc2_ == null) {
			return;
		}
		_loc2_.refCount--;
		if (_loc2_.refCount <= 0) {
			_loc2_.atlas.dispose();
			_loc2_.bitmapData.dispose();
			mAtlases.remove(key);
		}
	}

	public function restoreSources() {
		var _loc1_:TextureCacheEntry = null;
		var _loc3_:AtlasCacheEntry = null;
		var _loc4_:String;
		final __ax4_iter_91 = mEntries;
		if (checkNullIteratee(__ax4_iter_91))
			for (_tmp_ in __ax4_iter_91.keys()) {
				_loc4_ = _tmp_;
				_loc1_ = ASCompat.coerce(ASDictionary.getString(mEntries, _loc4_), TextureCacheEntry);
				if (_loc1_.bitmapData != null && _loc1_.texture != null) {
					_loc1_.texture.root.uploadBitmapData(_loc1_.bitmapData);
				}
			}
		var _loc2_:String;
		final __ax4_iter_92 = mAtlases;
		if (checkNullIteratee(__ax4_iter_92))
			for (_tmp_ in __ax4_iter_92.keys()) {
				_loc2_ = _tmp_;
				_loc3_ = ASCompat.coerce(ASDictionary.getString(mAtlases, _loc2_), AtlasCacheEntry);
				if (_loc3_.bitmapData != null && _loc3_.atlas != null) {
					_loc3_.atlas.texture.root.uploadBitmapData(_loc3_.bitmapData);
				}
			}
	}

	public function dispose() {
		var _loc1_:TextureCacheEntry = null;
		var _loc3_:AtlasCacheEntry = null;
		var _loc4_:String;
		final __ax4_iter_93 = mEntries;
		if (checkNullIteratee(__ax4_iter_93))
			for (_tmp_ in __ax4_iter_93.keys()) {
				_loc4_ = _tmp_;
				_loc1_ = ASCompat.coerce(ASDictionary.getString(mEntries, _loc4_), TextureCacheEntry);
				_loc1_.texture.dispose();
				_loc1_.bitmapData.dispose();
				mEntries.remove(_loc4_);
			}
		var _loc2_:String;
		final __ax4_iter_94 = mAtlases;
		if (checkNullIteratee(__ax4_iter_94))
			for (_tmp_ in __ax4_iter_94.keys()) {
				_loc2_ = _tmp_;
				_loc3_ = ASCompat.coerce(ASDictionary.getString(mAtlases, _loc2_), AtlasCacheEntry);
				_loc3_.atlas.dispose();
				_loc3_.bitmapData.dispose();
				mAtlases.remove(_loc2_);
			}
	}
}

private class TextureCacheEntry {
	public var texture:Texture;

	public var bitmapData:BitmapData;

	public var refCount:Int = 0;

	public function new(texture:Texture, bitmapData:BitmapData, refCount:Int) {
		this.texture = texture;
		this.bitmapData = bitmapData;
		this.refCount = refCount;
	}
}

private class AtlasCacheEntry {
	public var atlas:TextureAtlas;

	public var bitmapData:BitmapData;

	public var refCount:Int = 0;

	public function new(atlas:TextureAtlas, bitmapData:BitmapData, refCount:Int) {
		this.atlas = atlas;
		this.bitmapData = bitmapData;
		this.refCount = refCount;
	}
}
