package com.maccherone.json
;
   
    class JSONEncoder
   {
      
      static inline final tabWidth= 4;
      
      var jsonString:String;
      
      var level:Int = 0;
      
      var maxLength:Int = 0;
      
      var pretty:Bool = false;
      
      public function new(param1:ASAny, param2:Bool = false, param3:Int = 60)
      {
         
         level = 0;
         this.pretty = param2;
         if(param2)
         {
            this.maxLength = param3;
         }
         else
         {
            this.maxLength = ASCompat.MAX_INT;
         }
         jsonString = convertToString(param1);
      }
      
      static function getPadding(param1:Int) : String
      {
         var _loc2_= param1 * tabWidth;
         var _loc3_= "";
         var _loc4_= 1;
         while(_loc4_ <= _loc2_)
         {
            _loc3_ += " ";
            _loc4_++;
         }
         return _loc3_;
      }
      
      function objectToStringPretty(param1:ASObject) : String
      {
         var __ax4_iter_36:compat.XMLList;
         var s:String;
         var classInfo:compat.XML;
         var value:ASObject = null;
         var key:String = null;
         var v:compat.XML = null;
         var o:ASObject = param1;
         ++level;
         s = "";
         classInfo = ASCompat.describeType(o);
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
                     s += ",\n";
                  }
                  s += getPadding(level) + escapeString(key) + ":";
                  if(pretty)
                  {
                     s += " ";
                  }
                  s += convertToString(value);
               }
            }
         }
         else
         {
            __ax4_iter_36 = ASCompat.filterXmlList(classInfo.descendants("*"), function(__xml:compat.XML):Bool{return __xml.name() == "variable" || __xml.name() == "accessor";});
            if (checkNullIteratee(__ax4_iter_36)) for (_tmp_ in __ax4_iter_36)
            {
               v  = _tmp_;
               if(s.length > 0)
               {
                  s += ",\n";
               }
               s += getPadding(level) + escapeString(v.attribute("name").toString()) + ":";
               if(pretty)
               {
                  s += " ";
               }
               s += convertToString(o[v.attribute("name")]);
            }
         }
         --level;
         return "{" + "\n" + s + "\n" + getPadding(level) + "}";
      }
      
      function arrayToString(param1:Array<ASAny>) : String
      {
         var _loc2_= "";
         var _loc3_= 0;
         while(_loc3_ < param1.length)
         {
            if(_loc2_.length > 0)
            {
               _loc2_ += ",";
               if(pretty)
               {
                  _loc2_ += " ";
               }
            }
            _loc2_ += convertToString(param1[_loc3_]);
            _loc3_++;
         }
         return "[" + _loc2_ + "]";
      }
      
      public function getString() : String
      {
         return jsonString;
      }
      
      function objectToString(param1:ASObject) : String
      {
         var __ax4_iter_37:compat.XMLList;
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
                     if(pretty)
                     {
                        s += " ";
                     }
                  }
                  s += escapeString(key) + ":";
                  if(pretty)
                  {
                     s += " ";
                  }
                  s += convertToString(value);
               }
            }
         }
         else
         {
            __ax4_iter_37 = ASCompat.filterXmlList(classInfo.descendants("*"), function(__xml:compat.XML):Bool{return __xml.name() == "variable" || __xml.name() == "accessor";});
            if (checkNullIteratee(__ax4_iter_37)) for (_tmp_ in __ax4_iter_37)
            {
               v  = _tmp_;
               if(s.length > 0)
               {
                  s += ",";
                  if(pretty)
                  {
                     s += " ";
                  }
               }
               s += escapeString(v.attribute("name").toString()) + ":";
               if(pretty)
               {
                  s += " ";
               }
               s += convertToString(o[v.attribute("name")]);
            }
         }
         return "{" + s + "}";
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
      
      function arrayToStringPretty(param1:Array<ASAny>) : String
      {
         ++level;
         var _loc2_= "";
         var _loc3_= 0;
         while(_loc3_ < param1.length)
         {
            if(_loc2_.length > 0)
            {
               _loc2_ += ",\n";
            }
            _loc2_ += getPadding(level) + convertToString(param1[_loc3_]);
            _loc3_++;
         }
         --level;
         return "[" + "\n" + _loc2_ + "\n" + getPadding(level) + "]";
      }
      
      function convertToString(param1:ASAny) : String
      {
         var _loc2_:String = null;
         if(Std.isOfType(param1 , String))
         {
            return escapeString(ASCompat.asString(param1 ));
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
            if(maxLength <= 2)
            {
               _loc2_ = arrayToStringPretty(ASCompat.dynamicAs(param1 , Array));
            }
            else
            {
               _loc2_ = arrayToString(ASCompat.dynamicAs(param1 , Array));
               if(_loc2_.length > maxLength)
               {
                  _loc2_ = arrayToStringPretty(ASCompat.dynamicAs(param1 , Array));
               }
            }
            return _loc2_;
         }
         if(param1 != null && param1 != null)
         {
            if(maxLength <= 2)
            {
               _loc2_ = objectToStringPretty(param1);
            }
            else
            {
               _loc2_ = objectToString(param1);
               if(_loc2_.length > maxLength)
               {
                  _loc2_ = objectToStringPretty(param1);
               }
            }
            return _loc2_;
         }
         return "null";
      }
   }


