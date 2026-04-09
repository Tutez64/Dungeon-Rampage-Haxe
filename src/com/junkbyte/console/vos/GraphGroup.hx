package com.junkbyte.console.vos
;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
    class GraphGroup
   {
      
      public static inline final FPS= (1 : UInt);
      
      public static inline final MEM= (2 : UInt);
      
      public var type:UInt = 0;
      
      public var name:String;
      
      public var freq:Int = 1;
      
      public var low:Float = Math.NaN;
      
      public var hi:Float = Math.NaN;
      
      public var fixed:Bool = false;
      
      public var averaging:UInt = 0;
      
      public var inv:Bool = false;
      
      public var interests:Array<ASAny> = [];
      
      public var rect:Rectangle;
      
      public var idle:Int = 0;
      
      public function new(param1:String)
      {
         
         this.name = param1;
      }
      
      public static function FromBytes(param1:ByteArray) : GraphGroup
      {
         var _loc2_= new GraphGroup(param1.readUTF());
         _loc2_.type = param1.readUnsignedInt();
         _loc2_.idle = (param1.readUnsignedInt() : Int);
         _loc2_.low = param1.readDouble();
         _loc2_.hi = param1.readDouble();
         _loc2_.inv = param1.readBoolean();
         var _loc3_= param1.readUnsignedInt();
         while(_loc3_ != 0)
         {
            _loc2_.interests.push(GraphInterest.FromBytes(param1));
            _loc3_--;
         }
         return _loc2_;
      }
      
      public function updateMinMax(param1:Float) 
      {
         if(!Math.isNaN(param1) && !this.fixed)
         {
            if(Math.isNaN(this.low))
            {
               this.low = param1;
               this.hi = param1;
            }
            if(param1 > this.hi)
            {
               this.hi = param1;
            }
            if(param1 < this.low)
            {
               this.low = param1;
            }
         }
      }
      
      public function toBytes(param1:ByteArray) 
      {
         var _loc2_:GraphInterest = null;
         param1.writeUTF(this.name);
         param1.writeUnsignedInt(this.type);
         param1.writeUnsignedInt((this.idle : UInt));
         param1.writeDouble(this.low);
         param1.writeDouble(this.hi);
         param1.writeBoolean(this.inv);
         param1.writeUnsignedInt((this.interests.length : UInt));
         final __ax4_iter_46 = this.interests;
         if (checkNullIteratee(__ax4_iter_46)) for (_tmp_ in __ax4_iter_46)
         {
            _loc2_  = ASCompat.dynamicAs(_tmp_, com.junkbyte.console.vos.GraphInterest);
            _loc2_.toBytes(param1);
         }
      }
   }


