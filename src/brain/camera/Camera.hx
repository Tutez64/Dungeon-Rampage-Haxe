package brain.camera
;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import com.greensock.TimelineMax;
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
    class Camera
   {
      
      var mTargetObject:DisplayObject;
      
      var mBounds:Rectangle;
      
      var mMaxZoom:Float = 10;
      
      var mMinZoom:Float = 0.01;
      
      var mZoom:Float = 1;
      
      var mRotation:Float = 0;
      
      var mTransformDirty:Bool = false;
      
      var mRootPosition:Vector3D = new Vector3D();
      
      var mRootTransform:Matrix = new Matrix();
      
      var mShakePosition:Vector3D = new Vector3D();
      
      var mShakeRotation:Float = 0;
      
      var mBackgroundFader:BackgroundFader;
      
      var mLetterboxEffect:LetterboxEffect;
      
      var mVisibleRect:Rectangle;
      
      var mDefaultZoom:Float = Math.NaN;
      
      var mTweenZoom:TweenLite;
      
      var mTweenRotation:TweenLite;
      
      var mOffset:Point;
      
      var mYClippingFromBottom:UInt = 0;
      
      var mWantScrollRectCulling:Bool = false;
      
      var mFacade:Facade;
      
      public function new(param1:Facade, param2:BackgroundFader, param3:LetterboxEffect)
      {
         
         mFacade = param1;
         mOffset = new Point();
         mBackgroundFader = param2;
         mLetterboxEffect = param3;
      }
      
      public function destroy() 
      {
         if(mTweenZoom != null)
         {
            mTweenZoom.kill();
         }
         if(mTweenRotation != null)
         {
            mTweenRotation.kill();
         }
         if(mBackgroundFader != null)
         {
            mBackgroundFader.forceStop();
            mBackgroundFader = null;
         }
         if(mLetterboxEffect != null)
         {
            mLetterboxEffect.forceStop();
            mLetterboxEffect = null;
         }
         if(mVisibleRect != null)
         {
            mVisibleRect = null;
         }
         mTargetObject = null;
      }
      
      public function removeShakes() 
      {
         mShakePosition.x = mShakePosition.y = 0;
         mTransformDirty = false;
      }
      
            
      @:isVar public var bounds(get,set):Rectangle;
public function  set_bounds(param1:Rectangle) :Rectangle      {
         return mBounds = param1;
      }
function  get_bounds() : Rectangle
      {
         return mBounds;
      }
      
      public function getDeltaToPoint(param1:Float, param2:Float) : Vector3D
      {
         if(mWantScrollRectCulling)
         {
            return new Vector3D((-param1 - mRootPosition.x) / mZoom,(-param2 - mRootPosition.y) / mZoom);
         }
         return new Vector3D(-param1 - mRootPosition.x,-param2 - mRootPosition.y);
      }
      
      public function centerCameraOnPoint(param1:Vector3D) 
      {
         var _loc2_= getDeltaToPoint(param1.x,param1.y);
         if(!_loc2_.equals(mRootPosition))
         {
            mRootPosition = _loc2_;
            mTransformDirty = true;
         }
      }
      
      public function update(param1:GameClock = null) 
      {
         var _loc4_= Math.NaN;
         var _loc2_= Math.NaN;
         var _loc5_= Math.NaN;
         var _loc3_= Math.NaN;
         if(mTransformDirty && mTargetObject != null)
         {
            mRootTransform.identity();
            if(mWantScrollRectCulling)
            {
               mRootTransform.scale(mZoom,mZoom);
               mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
               mTargetObject.transform.matrix = mRootTransform;
               mTargetObject.x = -mFacade.viewWidth * 0.5;
               mTargetObject.y = -mFacade.viewHeight * 0.5;
               _loc4_ = Math.fround(-mRootPosition.x - mFacade.viewWidth / mZoom * 0.5);
               _loc2_ = Math.fround(-mRootPosition.y - mFacade.viewHeight / mZoom * 0.5 + mOffset.y / mZoom);
               _loc5_ = Math.fround(mFacade.viewWidth / mZoom);
               _loc3_ = Math.fround(mFacade.viewHeight / mZoom - mYClippingFromBottom / mZoom);
               mTargetObject.scrollRect = new Rectangle(_loc4_,_loc2_,_loc5_,_loc3_);
            }
            else
            {
               mRootTransform.translate(mRootPosition.x + mOffset.x + mShakePosition.x,mRootPosition.y + mOffset.y + mShakePosition.y);
               mRootTransform.scale(mZoom,mZoom);
               mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
               mTargetObject.transform.matrix = mRootTransform;
            }
            mTransformDirty = false;
         }
      }
      
      public function translateTo(param1:Vector3D) 
      {
         mRootPosition = param1;
         mTransformDirty = true;
      }
      
      public function translateBy(param1:Float, param2:Float) 
      {
         mRootPosition.x += param1;
         mRootPosition.y += param2;
         mTransformDirty = true;
      }
      
            
      @:isVar public var targetObject(get,set):DisplayObject;
public function  set_targetObject(param1:DisplayObject) :DisplayObject      {
         return mTargetObject = param1;
      }
function  get_targetObject() : DisplayObject
      {
         return mTargetObject;
      }
      
            
      @:isVar public var rotation(get,set):Float;
public function  set_rotation(param1:Float) :Float      {
         mRotation = param1;
         mTransformDirty = true;
return param1;
      }
function  get_rotation() : Float
      {
         return mRotation;
      }
      
            
      @:isVar public var _shakeRotation(get,set):Float;
public function  set__shakeRotation(param1:Float) :Float      {
         mShakeRotation = param1;
         mTransformDirty = true;
return param1;
      }
function  get__shakeRotation() : Float
      {
         return mShakeRotation;
      }
      
            
      @:isVar public var _shakeX(get,set):Float;
public function  set__shakeX(param1:Float) :Float      {
         mShakePosition.x = param1;
         mTransformDirty = true;
return param1;
      }
      
            
      @:isVar public var _shakeY(get,set):Float;
public function  set__shakeY(param1:Float) :Float      {
         mShakePosition.y = param1;
         mTransformDirty = true;
return param1;
      }
function  get__shakeX() : Float
      {
         return mShakePosition.x;
      }
function  get__shakeY() : Float
      {
         return mShakePosition.y;
      }
      
      public function tweenRotation(param1:Float, param2:Float) 
      {
         if(mTweenRotation != null)
         {
            mTweenRotation.kill();
         }
         if(mFacade.featureFlags.getFlagValue("want-zoom"))
         {
            mTweenRotation = TweenLite.to(this,param1,{"rotation":param2});
         }
      }
      
            
      @:isVar public var zoom(get,set):Float;
public function  set_zoom(param1:Float) :Float      {
         if(mFacade.featureFlags.getFlagValue("want-zoom"))
         {
            param1 = Math.min(mMaxZoom,Math.max(mMinZoom,param1));
            if(mZoom == param1)
            {
               return param1;
            }
            mZoom = param1;
            mTransformDirty = true;
         }
return param1;
      }
function  get_zoom() : Float
      {
         return mZoom;
      }
      
      public function killTweenZooms() 
      {
         if(mTweenZoom != null)
         {
            mTweenZoom.kill();
            mTweenZoom = null;
         }
      }
      
      function shakeFunction(param1:ASFunction, param2:Float, param3:Float, param4:UInt) : TimelineMax
      {
         var _loc6_= Math.NaN;
         var _loc8_= 0;
         var _loc7_= new TimelineMax();
         var _loc5_= param2 / param4;
         _loc8_ = 0;
         while((_loc8_ : UInt) < param4)
         {
            param3 = -param3;
            _loc6_ = _loc8_ == 0 ? _loc5_ * 0.5 : _loc5_;
            _loc7_.append(ASCompat.dynamicAs(param1(_loc6_,param3), com.greensock.core.TweenCore));
            _loc8_ = ASCompat.toInt(_loc8_) + 1;
         }
         _loc7_.append(ASCompat.dynamicAs(param1(_loc5_ * 0.5,0), com.greensock.core.TweenCore));
         return _loc7_;
      }
      
      public function shakeRotation(param1:Float, param2:Float, param3:UInt) : TimelineMax
      {
         var duration= param1;
         var strength= param2;
         var numShakes= param3;
         var self= this;
         var createTween:ASFunction = function(param1:Float, param2:Float):TweenMax
         {
            return new TweenMax(self,param1,{
               "_shakeRotation":param2,
               "onUpdate":update
            });
         };
         return this.shakeFunction(createTween,duration,strength,numShakes);
      }
      
      public function shakeX(param1:Float, param2:Float, param3:UInt) : TimelineMax
      {
         var duration= param1;
         var strength= param2;
         var numShakes= param3;
         var self= this;
         var createTween:ASFunction = function(param1:Float, param2:Float):TweenMax
         {
            return new TweenMax(self,param1,{
               "_shakeX":param2,
               "onUpdate":update
            });
         };
         return this.shakeFunction(createTween,duration,strength,numShakes);
      }
      
      public function shakeY(param1:Float, param2:Float, param3:UInt) : TimelineMax
      {
         var duration= param1;
         var strength= param2;
         var numShakes= param3;
         var self= this;
         var createTween:ASFunction = function(param1:Float, param2:Float):TweenMax
         {
            return new TweenMax(self,param1,{
               "_shakeY":param2,
               "onUpdate":update
            });
         };
         return this.shakeFunction(createTween,duration,strength,numShakes);
      }
      
            
      @:isVar public var defaultZoom(get,set):Float;
public function  set_defaultZoom(param1:Float) :Float      {
         return mDefaultZoom = param1;
      }
function  get_defaultZoom() : Float
      {
         return mDefaultZoom;
      }
      
      public function tweenToDefaultZoom(param1:Float) : TweenLite
      {
         return tweenZoom(param1,defaultZoom);
      }
      
      public function tweenZoom(param1:Float, param2:Float, param3:Bool = false) : TweenLite
      {
         if(param3)
         {
            mDefaultZoom = param2;
         }
         killTweenZooms();
         mTweenZoom = TweenMax.to(this,param1,{
            "zoom":param2,
            "onUpdate":update
         });
         return mTweenZoom;
      }
      
      public function fadeBackground(param1:Array<ASAny>, param2:UInt, param3:Float, param4:Vector3D, param5:Float) 
      {
         mBackgroundFader.doFade(param1,param2,param3,param4,param5);
      }
      
      public function doLetterboxEffect(param1:UInt, param2:Float, param3:Vector3D, param4:Float) 
      {
         mLetterboxEffect.doFade(param1,param2,param3,param4);
      }
      
      public function killBackgroundFader() 
      {
         mBackgroundFader.forceStop();
      }
      
      public function killLetterboxEffect() 
      {
         mLetterboxEffect.forceStop();
      }
      
      @:isVar public var rootPosition(get,never):Vector3D;
public function  get_rootPosition() : Vector3D
      {
         return mRootPosition;
      }
      
      @:isVar public var visibleRectangle(get,never):Rectangle;
public function  get_visibleRectangle() : Rectangle
      {
         var _loc3_= Math.NaN;
         var _loc4_= Math.NaN;
         var _loc2_= Math.NaN;
         var _loc1_= Math.NaN;
         if(mWantScrollRectCulling)
         {
            _loc3_ = mFacade.viewWidth / mZoom;
            _loc4_ = mFacade.viewHeight / mZoom;
            _loc2_ = -mRootPosition.x - _loc3_ * 0.5 + mOffset.x / mZoom;
            _loc1_ = -mRootPosition.y - _loc4_ * 0.5 + mOffset.y / mZoom;
         }
         else
         {
            _loc2_ = (-mTargetObject.x - mTargetObject.parent.x) / mZoom;
            _loc1_ = (-mTargetObject.y - mTargetObject.parent.y) / mZoom;
            _loc3_ = mFacade.viewWidth / mZoom;
            _loc4_ = mFacade.viewHeight / mZoom;
         }
         if(mVisibleRect == null)
         {
            mVisibleRect = new Rectangle(_loc2_,_loc1_,_loc3_,_loc4_);
         }
         else
         {
            mVisibleRect.setTo(_loc2_,_loc1_,_loc3_,_loc4_);
         }
         return mVisibleRect;
      }
      
      public function isPointOnScreen(param1:Vector3D) : Bool
      {
         return this.visibleRectangle.contains(param1.x,param1.y);
      }
      
            
      @:isVar public var offset(get,set):Point;
public function  get_offset() : Point
      {
         return mOffset;
      }
function  set_offset(param1:Point) :Point      {
         return mOffset = param1;
      }
      
            
      @:isVar public var yCilppingFromBottom(get,set):Float;
public function  get_yCilppingFromBottom() : Float
      {
         return mYClippingFromBottom;
      }
function  set_yCilppingFromBottom(param1:Float) :Float      {
         mYClippingFromBottom = (Std.int(param1) : UInt);
return param1;
      }
      
      public function forceRedraw() 
      {
         mTransformDirty = true;
         update(null);
      }
      
      public function getWorldCoordinateFromMouse(param1:Float, param2:Float) : Vector3D
      {
         return new Vector3D(param1 / zoom + visibleRectangle.x,param2 / zoom + visibleRectangle.y);
      }
   }


