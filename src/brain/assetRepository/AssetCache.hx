package brain.assetRepository
;
   import flash.utils.*;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   /*internal*/ final class AssetCache
   {
      
      var mCachedAssets:Map = new Map();
      
      public function new()
      {
         
         mCachedAssets = new Map();
      }
      
      public function itemFor(param1:AssetLoaderInfo) : Asset
      {
         if(param1.useCache)
         {
            return ASCompat.dynamicAs(mCachedAssets.itemFor(param1.getKey()), brain.assetRepository.Asset);
         }
         return null;
      }
      
      public function add(param1:AssetLoaderInfo, param2:Asset) : Bool
      {
         if(param1.useCache)
         {
            return mCachedAssets.add(param1.getKey(),param2);
         }
         return false;
      }
      
      public function remove(param1:Asset) : Bool
      {
         return mCachedAssets.remove(param1);
      }
      
      @:isVar public var size(get,never):Int;
public function  get_size() : Int
      {
         return (mCachedAssets.size : Int);
      }
      
      public function removeCacheForSpriteSheetAssets() 
      {
         var _loc2_:SpriteSheetAsset = null;
         var _loc3_:String = null;
         var _loc5_= 0;
         var _loc6_= new Map();
         var _loc4_= new Vector<String>();
         var _loc1_= ASCompat.reinterpretAs(mCachedAssets.iterator() , IMapIterator);
         while(_loc1_.hasNext())
         {
            _loc1_.next();
            _loc2_ = ASCompat.dynamicAs(_loc1_.current , SpriteSheetAsset);
            if(_loc2_ != null)
            {
               _loc4_.push(_loc2_.cacheKey);
               _loc2_.destroy();
               _loc2_ = null;
            }
            else
            {
               _loc6_.add(ASCompat.asString(_loc1_.key ),_loc1_.current);
            }
         }
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc3_ = _loc4_[_loc5_];
            if(_loc6_.hasKey(_loc3_))
            {
               _loc6_.removeKey(_loc3_);
            }
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
         mCachedAssets.clear();
         mCachedAssets = _loc6_;
         _loc6_ = null;
      }
      
      public function Dump() 
      {
         var _loc2_:Asset = null;
         trace(" Asset Cache ------------------------------");
         var _loc1_= ASCompat.reinterpretAs(mCachedAssets.iterator() , IMapIterator);
         while(_loc1_.hasNext())
         {
            _loc1_.next();
            _loc2_ = ASCompat.dynamicAs(_loc1_.current , Asset);
            if(_loc2_ != null)
            {
               trace("AssetCache : ",_loc1_.key,ASCompat.getQualifiedClassName(((((_loc2_ : ASObject) ) : ASAny).constructor : Dynamic) ));
            }
         }
      }
   }


