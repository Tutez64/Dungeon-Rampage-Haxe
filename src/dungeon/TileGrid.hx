package dungeon
;
   import brain.logger.Logger;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
    class TileGrid
   {
      
      public static inline final DEFAULT_GRID_WIDTH= (12 : UInt);
      
      public static inline final DEFAULT_GRID_HEIGHT= (12 : UInt);
      
      static inline final MAX_VISIBLE_TILES= (16 : UInt);
      
      var mGridWidth:UInt = 0;
      
      var mGridHeight:UInt = 0;
      
      var mTiles:Vector<Tile>;
      
      var mEmptyTileColiders:Vector<RectangleNavCollider>;
      
      public function new(param1:UInt = (12 : UInt), param2:UInt = (12 : UInt))
      {
         var _loc4_= 0;
         var _loc3_= 0;
         
         mGridWidth = param1;
         mGridHeight = param2;
         mTiles = new Vector<Tile>();
         mEmptyTileColiders = new Vector<RectangleNavCollider>();
         _loc4_ = 0;
         while((_loc4_ : UInt) < mGridHeight)
         {
            _loc3_ = 0;
            while((_loc3_ : UInt) < mGridWidth)
            {
               mTiles.push(null);
               mEmptyTileColiders.push(null);
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      public function getNonFillTilePositions() : Vector<Vector3D>
      {
         var _loc1_= new Vector<Vector3D>();
         var _loc2_:Tile;
         final __ax4_iter_126 = mTiles;
         if (checkNullIteratee(__ax4_iter_126)) for (_tmp_ in __ax4_iter_126)
         {
            _loc2_ = _tmp_;
            if(_loc2_ != null && !ASCompat.toBool(_loc2_.isFiller()))
            {
               _loc1_.push(ASCompat.dynamicAs(_loc2_.position.clone(), flash.geom.Vector3D));
            }
         }
         return _loc1_;
      }
      
      public function isPositionOpenForATile(param1:Vector3D) : Bool
      {
         if(getTileIndexAtPosition(param1) >= 0)
         {
            return getTileAtPosition(param1) == null;
         }
         return false;
      }
      
      function setTileAtIndex(param1:UInt, param2:UInt, param3:Tile) 
      {
         if(param1 >= mGridWidth || param2 >= mGridHeight)
         {
            throw new Error("index out of range");
         }
         mTiles[(param1 + param2 * mGridWidth : Int)] = param3;
         var _loc4_= mEmptyTileColiders[(param1 + param2 * mGridWidth : Int)];
         if(_loc4_ != null)
         {
            _loc4_.destroy();
            mEmptyTileColiders[(param1 + param2 * mGridWidth : Int)] = null;
         }
      }
      
      public function SetEmptyColliderAtIndex(param1:UInt, param2:UInt, param3:RectangleNavCollider) 
      {
         if(param1 >= mGridWidth || param2 >= mGridHeight)
         {
            throw new Error("index out of range");
         }
         mEmptyTileColiders[(param1 + param2 * mGridWidth : Int)] = param3;
      }
      
      public function getEmptyColliderAtIndex(param1:UInt, param2:UInt) : RectangleNavCollider
      {
         if(param1 >= mGridWidth || param2 >= mGridHeight)
         {
            return null;
         }
         return mEmptyTileColiders[(param1 + param2 * mGridWidth : Int)];
      }
      
      public function setTileAtPosition(param1:Vector3D, param2:Tile) 
      {
         if(param1.x < -900 || param1.y < -900)
         {
            Logger.error("setTileAtPosition: position must be positive: " + param1.toString());
            return;
         }
         var _loc3_= (Std.int((param1.x + 900) / 900) : UInt);
         var _loc4_= (Std.int((param1.y + 900) / 900) : UInt);
         setTileAtIndex(_loc3_,_loc4_,param2);
      }
      
      public function getTileAtIndex(param1:UInt, param2:UInt) : Tile
      {
         if(param1 >= mGridWidth || param2 >= mGridHeight)
         {
            return null;
         }
         return mTiles[(param1 + param2 * mGridWidth : Int)];
      }
      
      public function getTileAtPosition(param1:Vector3D) : Tile
      {
         if(param1.x < -900 || param1.y < -900)
         {
            return null;
         }
         var _loc2_= (Std.int((param1.x + 900) / 900) : UInt);
         var _loc3_= (Std.int((param1.y + 900) / 900) : UInt);
         return getTileAtIndex(_loc2_,_loc3_);
      }
      
      public function getTileIndexAtPosition(param1:Vector3D) : Int
      {
         if(param1.x < -900 || param1.y < -900)
         {
            return -1;
         }
         var _loc2_= (Std.int((param1.x + 900) / 900) : UInt);
         var _loc3_= (Std.int((param1.y + 900) / 900) : UInt);
         if(_loc2_ >= mGridWidth || _loc3_ >= mGridHeight)
         {
            return -1;
         }
         return (_loc2_ + _loc3_ * mGridWidth : Int);
      }
      
      public function getVisibleTiles(param1:Rectangle) : Vector<Tile>
      {
         var _loc3_:Tile = null;
         var _loc4_= 0;
         var _loc2_= 0;
         var _loc5_= new Vector<Tile>();
         _loc4_ = 0;
         _loc2_ = mTiles.length;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = mTiles[_loc4_];
            if(_loc3_ != null && _loc3_.bounds.intersects(param1))
            {
               _loc5_.push(_loc3_);
            }
            _loc4_++;
         }
         if(_loc5_.length > 16)
         {
            Logger.warn("getVisibleTiles: found " + _loc5_.length + " visible. Something wrong?");
         }
         return _loc5_;
      }
      
      public function iterator(param1:Bool = false) : TileGridIterator
      {
         return new TileGridIterator(mTiles,param1);
      }
      
      public function removeAllFromWorld() 
      {
         var _loc1_:Tile;
         final __ax4_iter_127 = mTiles;
         if (checkNullIteratee(__ax4_iter_127)) for (_tmp_ in __ax4_iter_127)
         {
            _loc1_ = _tmp_;
            if(_loc1_ != null)
            {
               _loc1_.destroy();
            }
         }
      }
      
      public function removeTileAtPosition(param1:Vector3D) 
      {
         var _loc2_:Float = getTileIndexAtPosition(param1);
         if(_loc2_ >= 0)
         {
            if(mTiles[Std.int(_loc2_)] != null)
            {
               mTiles[Std.int(_loc2_)].removeFromStage();
               mTiles[Std.int(_loc2_)].destroy();
            }
            mTiles[Std.int(_loc2_)] = null;
         }
      }
      
      public function destroy() 
      {
         var _loc2_= 0;
         var _loc1_:RectangleNavCollider = null;
         removeAllFromWorld();
         if(mEmptyTileColiders != null)
         {
            _loc2_ = 0;
            while(_loc2_ < mEmptyTileColiders.length)
            {
               _loc1_ = mEmptyTileColiders[_loc2_];
               if(_loc1_ != null)
               {
                  _loc1_.destroy();
                  _loc1_ = null;
               }
               _loc2_ = ASCompat.toInt(_loc2_) + 1;
            }
            mEmptyTileColiders.length = 0;
            mEmptyTileColiders = null;
         }
         mTiles = null;
      }
   }


