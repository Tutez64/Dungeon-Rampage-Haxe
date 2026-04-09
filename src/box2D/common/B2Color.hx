package box2D.common
;
   import box2D.common.math.B2Math;
   
    class B2Color
   {
      
      var _r:UInt = (0 : UInt);
      
      var _g:UInt = (0 : UInt);
      
      var _b:UInt = (0 : UInt);
      
      public function new(param1:Float, param2:Float, param3:Float)
      {
         
         this._r = (Std.int(255 * B2Math.Clamp(param1,0,1)) : UInt);
         this._g = (Std.int(255 * B2Math.Clamp(param2,0,1)) : UInt);
         this._b = (Std.int(255 * B2Math.Clamp(param3,0,1)) : UInt);
      }
      
      public function Set(param1:Float, param2:Float, param3:Float) 
      {
         this._r = (Std.int(255 * B2Math.Clamp(param1,0,1)) : UInt);
         this._g = (Std.int(255 * B2Math.Clamp(param2,0,1)) : UInt);
         this._b = (Std.int(255 * B2Math.Clamp(param3,0,1)) : UInt);
      }
      
      @:isVar public var r(never,set):Float;
public function  set_r(param1:Float) :Float      {
         this._r = (Std.int(255 * B2Math.Clamp(param1,0,1)) : UInt);
return param1;
      }
      
      @:isVar public var g(never,set):Float;
public function  set_g(param1:Float) :Float      {
         this._g = (Std.int(255 * B2Math.Clamp(param1,0,1)) : UInt);
return param1;
      }
      
      @:isVar public var b(never,set):Float;
public function  set_b(param1:Float) :Float      {
         this._b = (Std.int(255 * B2Math.Clamp(param1,0,1)) : UInt);
return param1;
      }
      
      @:isVar public var color(get,never):UInt;
public function  get_color() : UInt
      {
         return ((this._r : Int) << 16 | (this._g : Int) << 8 | (this._b : Int) : UInt);
      }
   }


