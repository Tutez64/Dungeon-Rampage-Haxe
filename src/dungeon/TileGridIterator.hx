package dungeon
;
    class TileGridIterator
   {
      
      var mTiles:Vector<Tile>;
      
      var mIndex:UInt = (0 : UInt);
      
      var mOnlyOnStage:Bool = false;
      
      public function new(param1:Vector<Tile>, param2:Bool)
      {
         
         mTiles = param1;
         mOnlyOnStage = param2;
         reset();
      }
      
      public function hasNext() : Bool
      {
         return mIndex < (mTiles.length : UInt);
      }
      
      public function next() : Tile
      {
         var _loc1_= mTiles[(mIndex++ : Int)];
         seekNext();
         return _loc1_;
      }
      
      function seekNext() 
      {
         while(mIndex < (mTiles.length : UInt) && (mTiles[(mIndex : Int)] == null || mOnlyOnStage && !mTiles[(mIndex : Int)].isOnStage))
         {
            mIndex = mIndex + 1;
         }
      }
      
      public function reset() 
      {
         mIndex = (0 : UInt);
         seekNext();
      }
   }


