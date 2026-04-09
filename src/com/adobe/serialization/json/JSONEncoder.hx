package com.adobe.serialization.json
;
   
    class JSONEncoder
   {
      
      var jsonString:String;
      
      public function new(param1:ASAny)
      {
         
         this.jsonString = this.convertToString(param1);
      }
      
      public function getString() : String
      {
         return this.jsonString;
      }
      
      function convertToString(param1:ASAny) : String
      {
         if(Std.isOfType(param1 , String))
         {
            return this.escapeString(ASCompat.asString(param1 ));
         }
         if(Std.isOfType(param1 , Float))
         {
            return Math.isFinite(ASCompat.asNumber(param1 )) ? Std.string(param1) : "null";
         }
         if(Std.isOfType(param1 , Bool))
         {
            return ASCompat.toBool(param1) ? "true" : "false";
         }
         if(Std.isOfType(param1 , Array))
         {
            return this.arrayToString(ASCompat.dynamicAs(param1 , Array));
         }
         if(param1 != null && param1 != null)
         {
            return this.objectToString(param1);
         }
         return "null";
      }
      
      function escapeString(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc2_= "";
         var _loc4_:Float = param1.length;
         var _loc5_= 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = param1.charAt(_loc5_);
            switch(_loc3_)
            {
               case "\"":
                  _loc2_ += "\\\"";
                  
               case "\\":
                  _loc2_ += "\\\\";
                  
               case "\x08":
                  _loc2_ += "\\b";
                  
               case "\x0C":
                  _loc2_ += "\\f";
                  
               case "\n":
                  _loc2_ += "\\n";
                  
               case "\r":
                  _loc2_ += "\\r";
                  
               case "\t":
                  _loc2_ += "\\t";
                  
               default:
                  if(_loc3_ < " ")
                  {
                     _loc6_ = ASCompat.toRadix(_loc3_.charCodeAt(0), (16 : UInt));
                     _loc7_ = _loc6_.length == 2 ? "00" : "000";
                     _loc2_ += "\\u" + _loc7_ + _loc6_;
                  }
                  else
                  {
                     _loc2_ += _loc3_;
                  }
            }
            _loc5_++;
         }
         return "\"" + _loc2_ + "\"";
      }
      
      function arrayToString(param1:Array<ASAny>) : String
      {
         var _loc2_= "";
         var _loc3_= param1.length;
         var _loc4_= 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc2_.length > 0)
            {
               _loc2_ += ",";
            }
            _loc2_ += this.convertToString(param1[_loc4_]);
            _loc4_++;
         }
         return "[" + _loc2_ + "]";
      }
      
      function objectToString(param1:ASObject) : String
      {
         var __ax4_iter_30:compat.XMLList;
         var value:ASObject = null;
         var key:String = null;
         var v:compat.XML = null;
         var o:ASObject = param1;
         var s= "";
         var classInfo= ASCompat.describeType(o);
         if(classInfo.attribute("name").toString() == "Object")
         {
            if (checkNullIteratee(o)) for(_tmp_ in o.___keys())
            {
               key  = _tmp_;
               value = o[key];
               if(!Reflect.isFunction(value ))
               {
                  if(s.length > 0)
                  {
                     s += ",";
                  }
                  s += this.escapeString(key) + ":" + this.convertToString(value);
               }
            }
         }
         else
         {
            __ax4_iter_30 = ASCompat.filterXmlList(classInfo.descendants("*"), function(__xml:compat.XML):Bool{return __xml.name() == "variable" || __xml.name() == "accessor" && __xml.attribute("access").charAt(0) == "r";});
            if (checkNullIteratee(__ax4_iter_30)) for (_tmp_ in __ax4_iter_30)
            {
               v  = _tmp_;
               if(!(ASCompat.toBool(v.child("metadata")) && ASCompat.filterXmlList(v.child("metadata"), function(__xml:compat.XML):Bool{return __xml.attribute("name") == "Transient";}).length() > 0))
               {
                  if(s.length > 0)
                  {
                     s += ",";
                  }
                  s += this.escapeString(v.attribute("name").toString()) + ":" + this.convertToString(o[v.attribute("name")]);
               }
            }
         }
         return "{" + s + "}";
      }
   }


