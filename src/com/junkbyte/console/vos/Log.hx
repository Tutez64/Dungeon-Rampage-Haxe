package com.junkbyte.console.vos
;
   import flash.utils.ByteArray;
   
    class Log
   {
      
      public var line:UInt = 0;
      
      public var text:String;
      
      public var ch:String;
      
      public var priority:Int = 0;
      
      public var repeat:Bool = false;
      
      public var html:Bool = false;
      
      public var time:UInt = 0;
      
      public var timeStr:String;
      
      public var lineStr:String;
      
      public var chStr:String;
      
      public var next:Log;
      
      public var prev:Log;
      
      public function new(param1:String, param2:String, param3:Int, param4:Bool = false, param5:Bool = false)
      {
         
         this.text = param1;
         this.ch = param2;
         this.priority = param3;
         this.repeat = param4;
         this.html = param5;
      }
      
      public static function FromBytes(param1:ByteArray) : Log
      {
         var _loc2_= param1.readUTFBytes(param1.readUnsignedInt());
         var _loc3_= param1.readUTF();
         var _loc4_= param1.readInt();
         var _loc5_= param1.readBoolean();
         return new Log(_loc2_,_loc3_,_loc4_,_loc5_,true);
      }
      
      public function toBytes(param1:ByteArray) 
      {
         var _loc2_= new ByteArray();
         _loc2_.writeUTFBytes(this.text);
         param1.writeUnsignedInt(_loc2_.length);
         param1.writeBytes(_loc2_);
         param1.writeUTF(this.ch);
         param1.writeInt(this.priority);
         param1.writeBoolean(this.repeat);
      }
      
      public function plainText() : String
      {
         return new compat.RegExp("&gt;", "g").replace(new compat.RegExp("&lt;", "g").replace(new compat.RegExp("<.*?>", "g").replace(this.text,""),"<"),">");
      }
      
      public function toString() : String
      {
         return "[" + this.ch + "] " + this.plainText();
      }
      
      public function clone() : Log
      {
         var _loc1_= new Log(this.text,this.ch,this.priority,this.repeat,this.html);
         _loc1_.line = this.line;
         _loc1_.time = this.time;
         return _loc1_;
      }
   }


