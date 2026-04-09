package com.junkbyte.console.vos
;
   import com.junkbyte.console.core.Executer;
   import flash.utils.ByteArray;
   
    class GraphInterest
   {
      
      var _ref:WeakRef;
      
      public var _prop:String;
      
      var useExec:Bool = false;
      
      public var key:String;
      
      public var col:Float = Math.NaN;
      
      public var v:Float = Math.NaN;
      
      public var avg:Float = Math.NaN;
      
      public function new(param1:String = "", param2:Float = 0)
      {
         
         this.col = param2;
         this.key = param1;
      }
      
      public static function FromBytes(param1:ByteArray) : GraphInterest
      {
         var _loc2_= new GraphInterest(param1.readUTF(),param1.readUnsignedInt());
         _loc2_.v = param1.readDouble();
         _loc2_.avg = param1.readDouble();
         return _loc2_;
      }
      
      public function setObject(param1:ASObject, param2:String) : Float
      {
         this._ref = new WeakRef(param1);
         this._prop = param2;
         this.useExec = new compat.RegExp("[^\\w\\d]").search(this._prop) >= 0;
         this.v = this.getCurrentValue();
         this.avg = this.v;
         return this.v;
      }
      
      @:isVar public var obj(get,never):ASObject;
public function  get_obj() : ASObject
      {
         return this._ref != null ? this._ref.reference : /*undefined*/null;
      }
      
      @:isVar public var prop(get,never):String;
public function  get_prop() : String
      {
         return this._prop;
      }
      
      public function getCurrentValue() : Float
      {
         return ASCompat.toNumber(this.useExec ? ASCompat.toNumber(Executer.Exec(this.obj,this._prop)) : ASCompat.toNumber(this.obj[this._prop]));
      }
      
      public function setValue(param1:Float, param2:UInt = (0 : UInt)) 
      {
         this.v = param1;
         if(param2 > 0)
         {
            if(Math.isNaN(this.avg))
            {
               this.avg = this.v;
            }
            else
            {
               this.avg += (this.v - this.avg) / param2;
            }
         }
      }
      
      public function toBytes(param1:ByteArray) 
      {
         param1.writeUTF(this.key);
         param1.writeUnsignedInt((Std.int(this.col) : UInt));
         param1.writeDouble(this.v);
         param1.writeDouble(this.avg);
      }
   }


