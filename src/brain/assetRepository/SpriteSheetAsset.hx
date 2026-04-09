package brain.assetRepository
;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.utils.*;
   
    class SpriteSheetAsset extends Asset
   {
      
      var mFacade:Facade;
      
      var mFrames:Vector<BitmapData>;
      
      var mCenters:Vector<Point>;
      
      var mFrameWidth:UInt = 0;
      
      var mFrameHeight:UInt = 0;
      
      var mNumFramesX:UInt = (1 : UInt);
      
      var mNumFramesY:UInt = (1 : UInt);
      
      var mCacheKeyFor:String;
      
      var mBaseName:String;
      
      var mTimingVector:Vector<Float>;
      
      public function new(param1:Facade)
      {
         super();
         mFacade = param1;
      }
      
      public function FactoryCompiledIn(param1:String, param2:ASObject, param3:String) 
      {
         var _loc8_= 0;
         var _loc9_= Math.NaN;
         var _loc6_= 0;
         var _loc4_= 0;
         var _loc7_:String = null;
         var _loc5_:Dynamic = null;
         mBaseName = param1;
         mCacheKeyFor = param3;
         mCenters = new Vector<Point>();
         mFrames = new Vector<BitmapData>();
         mFrameWidth = (ASCompat.toInt(param2.width) : UInt);
         mFrameHeight = (ASCompat.toInt(param2.height) : UInt);
         mNumFramesY = (ASCompat.toInt(param2.offsets.length) : UInt);
         mNumFramesX = (ASCompat.toInt(param2.Timing.length) : UInt);
         mTimingVector = new Vector<Float>();
         _loc8_ = 0;
         while((_loc8_ : UInt) < mNumFramesX)
         {
            _loc9_ = ASCompat.toNumber(ASCompat.toNumber(param2.Timing[_loc8_]) * 1000) / 24;
            mTimingVector.push(_loc9_);
            _loc8_++;
         }
         var _loc10_= 0;
         _loc6_ = 0;
         while((_loc6_ : UInt) < mNumFramesY)
         {
            _loc4_ = 0;
            while((_loc4_ : UInt) < mNumFramesX)
            {
               _loc7_ = param1 + "_" + Std.string(_loc6_) + "_" + Std.string(_loc4_) + ".png";
               _loc5_ = Type.resolveClass(_loc7_) ;
               mFrames[_loc10_] = ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []), flash.display.BitmapData);
               mCenters[_loc10_] = new Point(ASCompat.toNumber(mFrameWidth * 0.5 - ASCompat.toNumberField(ASCompat.dynGetIndex(param2.offsets[_loc6_], _loc4_), "y")),ASCompat.toNumber(mFrameHeight * 0.5 - ASCompat.toNumberField(ASCompat.dynGetIndex(param2.offsets[_loc6_], _loc4_), "x")));
               _loc10_++;
               _loc4_++;
            }
            _loc6_++;
         }
      }
      
      public function FactoryFromSWf(param1:String, param2:ASObject, param3:SwfAsset) 
      {
         var _loc8_= 0;
         var _loc9_= Math.NaN;
         var _loc6_= 0;
         var _loc4_= 0;
         var _loc7_:String = null;
         var _loc5_:Dynamic = null;
         mBaseName = param1;
         mCacheKeyFor = param3.swfPath;
         mCenters = new Vector<Point>();
         mFrames = new Vector<BitmapData>();
         mFrameWidth = (ASCompat.toInt(param2.width) : UInt);
         mFrameHeight = (ASCompat.toInt(param2.height) : UInt);
         mNumFramesY = (ASCompat.toInt(param2.offsets.length) : UInt);
         mNumFramesX = (ASCompat.toInt(param2.Timing.length) : UInt);
         mTimingVector = new Vector<Float>();
         _loc8_ = 0;
         while((_loc8_ : UInt) < mNumFramesX)
         {
            _loc9_ = ASCompat.toNumber(ASCompat.toNumber(param2.Timing[_loc8_]) * 1000) / 24;
            mTimingVector.push(_loc9_);
            _loc8_++;
         }
         var _loc10_= 0;
         _loc6_ = 0;
         while((_loc6_ : UInt) < mNumFramesY)
         {
            _loc4_ = 0;
            while((_loc4_ : UInt) < mNumFramesX)
            {
               _loc7_ = param1 + "_" + Std.string(_loc6_) + "_" + Std.string(_loc4_) + ".png";
               _loc5_ = param3.getClass(_loc7_,false);
               mFrames[_loc10_] = ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []), flash.display.BitmapData);
               mCenters[_loc10_] = new Point(ASCompat.toNumber(mFrameWidth * 0.5 - ASCompat.toNumberField(ASCompat.dynGetIndex(param2.offsets[_loc6_], _loc4_), "y")),ASCompat.toNumber(mFrameHeight * 0.5 - ASCompat.toNumberField(ASCompat.dynGetIndex(param2.offsets[_loc6_], _loc4_), "x")));
               _loc10_++;
               _loc4_++;
            }
            _loc6_++;
         }
      }
      
      override public function destroy() 
      {
         mFacade = null;
         var _loc1_:BitmapData;
         final __ax4_iter_63 = mFrames;
         if (checkNullIteratee(__ax4_iter_63)) for (_tmp_ in __ax4_iter_63)
         {
            _loc1_ = _tmp_;
            _loc1_.dispose();
         }
         mFrames = null;
         super.destroy();
      }
      
      @:isVar public var cacheKey(get,never):String;
public function  get_cacheKey() : String
      {
         return mCacheKeyFor;
      }
      
      function getFrameIndex(param1:UInt, param2:UInt) : UInt
      {
         if(mNumFramesY == 1)
         {
            param2 = (0 : UInt);
         }
         var _loc3_= param2 * mNumFramesX + param1;
         if(_loc3_ >= (mFrames.length : UInt))
         {
            throw new Error("Tried to get frameIndex out of bounds: " + mBaseName + " " + _loc3_ + " / " + mFrames.length + " x:" + param1 + " y:" + param2 + " t1:" + mNumFramesY + " t2:" + mNumFramesX);
         }
         return _loc3_;
      }
      
      public function getFrame(param1:UInt, param2:UInt) : BitmapData
      {
         var _loc3_= getFrameIndex(param1,param2);
         if((mFrames.length : UInt) <= _loc3_)
         {
            Logger.error("Trying to access frame: " + _loc3_ + " but there are only " + mFrames.length + "frames in animation named: " + this.mBaseName);
            return null;
         }
         return mFrames[(_loc3_ : Int)];
      }
      
      public function getCenter(param1:UInt, param2:UInt) : Point
      {
         var _loc3_= getFrameIndex(param1,param2);
         if((mCenters.length : UInt) <= _loc3_)
         {
            Logger.error("Trying to access frame: " + _loc3_ + " but there are only " + mFrames.length + "frames in animation named: " + this.mBaseName);
            return null;
         }
         return mCenters[(_loc3_ : Int)];
      }
      
      @:isVar public var timingVector(get,never):Vector<Float>;
public function  get_timingVector() : Vector<Float>
      {
         return mTimingVector;
      }
      
      @:isVar public var numFramesX(get,never):UInt;
public function  get_numFramesX() : UInt
      {
         return mNumFramesX;
      }
      
      @:isVar public var numFramesY(get,never):UInt;
public function  get_numFramesY() : UInt
      {
         return mNumFramesY;
      }
   }


