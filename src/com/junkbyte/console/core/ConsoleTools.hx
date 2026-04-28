package com.junkbyte.console.core
;
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.Console;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   
    class ConsoleTools extends ConsoleCore
   {
      
      public function new(param1:Console)
      {
         super(param1);
      }
      
      public function map(param1:DisplayObjectContainer, param2:UInt = (0 : UInt), param3:String = null) 
      {
         var _loc5_= false;
         var _loc9_:DisplayObject = null;
         var _loc10_:String = null;
         var _loc11_:DisplayObjectContainer = null;
         var _loc12_= 0;
         var _loc13_= 0;
         var _loc14_:DisplayObject = null;
         var _loc15_= (0 : UInt);
         var _loc16_:String = null;
         if(param1 == null)
         {
            report("Not a DisplayObjectContainer.",10,true,param3);
            return;
         }
         var _loc4_= 0;
         var _loc6_= 0;
         var _loc7_:DisplayObject = null;
         var _loc8_= new Array<ASAny>();
         _loc8_.push(param1);
         while(_loc6_ < _loc8_.length)
         {
            _loc9_ = ASCompat.dynamicAs(_loc8_[_loc6_], flash.display.DisplayObject);
            _loc6_++;
            if(Std.isOfType(_loc9_ , DisplayObjectContainer))
            {
               _loc11_ = ASCompat.reinterpretAs(_loc9_ , DisplayObjectContainer);
               _loc12_ = _loc11_.numChildren;
               _loc13_ = 0;
               while(_loc13_ < _loc12_)
               {
                  _loc14_ = _loc11_.getChildAt(_loc13_);
                  ASCompat.arraySplice(_loc8_, _loc6_ + _loc13_,(0 : UInt),[_loc14_]);
                  _loc13_++;
               }
            }
            if(_loc7_ != null)
            {
               if(Std.isOfType(_loc7_ , DisplayObjectContainer) && ASCompat.reinterpretAs(_loc7_ , DisplayObjectContainer).contains(_loc9_))
               {
                  _loc4_++;
               }
               else
               {
                  while(_loc7_ != null)
                  {
                     _loc7_ = _loc7_.parent;
                     if(Std.isOfType(_loc7_ , DisplayObjectContainer))
                     {
                        if(_loc4_ > 0)
                        {
                           _loc4_--;
                        }
                        if(ASCompat.reinterpretAs(_loc7_ , DisplayObjectContainer).contains(_loc9_))
                        {
                           _loc4_++;
                           break;
                        }
                     }
                  }
               }
            }
            _loc10_ = "";
            _loc13_ = 0;
            while(_loc13_ < _loc4_)
            {
               _loc10_ += _loc13_ == _loc4_ - 1 ? " ∟ " : " - ";
               _loc13_++;
            }
            if(param2 <= 0 || (_loc4_ : UInt) <= param2)
            {
               _loc5_ = false;
               _loc15_ = console.refs.setLogRef(_loc9_);
               _loc16_ = _loc9_.name;
               if(_loc15_ != 0)
               {
                  _loc16_ = "<a href=\'event:cl_" + _loc15_ + "\'>" + _loc16_ + "</a>";
               }
               if(Std.isOfType(_loc9_ , DisplayObjectContainer))
               {
                  _loc16_ = "<b>" + _loc16_ + "</b>";
               }
               else
               {
                  _loc16_ = "<i>" + _loc16_ + "</i>";
               }
               _loc10_ += _loc16_ + " " + console.refs.makeRefTyped(_loc9_);
               report(_loc10_,Std.isOfType(_loc9_ , DisplayObjectContainer) ? 5 : 2,true,param3);
            }
            else if(!_loc5_)
            {
               _loc5_ = true;
               report(_loc10_ + "...",5,true,param3);
            }
            _loc7_ = _loc9_;
         }
         report(param1.name + ":" + console.refs.makeRefTyped(param1) + " has " + (_loc8_.length - 1) + " children/sub-children.",9,true,param3);
         if(config.commandLineAllowed)
         {
            report("Click on the child display\'s name to set scope.",-2,true,param3);
         }
      }
      
      public function explode(param1:ASObject, param2:Int = 3, param3:Int = 9) : String
      {
         var V:compat.XML;
         var list:Array<ASAny>;
         var nodes:compat.XMLList = null;
         var n:String = null;
         var accessorX:compat.XML = null;
         var variableX:compat.XML = null;
         var X:String = null;
         var obj:ASObject = param1;
         var depth= param2;
         var p= param3;
         var t= ASCompat.typeof(obj);
         if(obj == null)
         {
            return "<p-2>" + Std.string(obj) + "</p-2>";
         }
         if(Std.isOfType(obj , String))
         {
            return "\"" + LogReferences.EscHTML(ASCompat.asString(obj )) + "\"";
         }
         if(t != "object" || depth == 0 || ASCompat.isByteArray(obj ))
         {
            return console.refs.makeString(obj);
         }
         if(p < 0)
         {
            p = 0;
         }
         V = ASCompat.describeType(obj);
         list = [];
         nodes = ((V : ASAny)["accessor"] : compat.XMLList);
         if (checkNullIteratee(nodes)) for (_tmp_ in nodes)
         {
            accessorX  = _tmp_;
            n = accessorX.attribute("name");
            if(accessorX.attribute("access") != "writeonly")
            {
               try
               {
                  list.push(this.stepExp(obj,n,depth,p));
               }
               catch(e:Dynamic)
               {
               }
               continue;
            }
            list.push(n);
         }
         nodes = ((V : ASAny)["variable"] : compat.XMLList);
         if (checkNullIteratee(nodes)) for (_tmp_ in nodes)
         {
            variableX  = _tmp_;
            n = variableX.attribute("name");
            list.push(this.stepExp(obj,n,depth,p));
         }
         try
         {
            if (checkNullIteratee(obj)) for(_tmp_ in obj.___keys())
            {
               X  = _tmp_;
               list.push(this.stepExp(obj,X,depth,p));
            }
         }
         catch(e:Dynamic)
         {
         }
         return "<p" + p + ">{" + LogReferences.ShortClassName(obj) + "</p" + p + "> " + list.join(", ") + "<p" + p + ">}</p" + p + ">";
      }
      
      function stepExp(param1:ASAny, param2:String, param3:Int, param4:Int) : String
      {
         return param2 + ":" + this.explode(param1[param2],param3 - 1,param4 - 1);
      }
      
      public function getStack(param1:Int, param2:Int) : String
      {
         var _loc3_= new Error();
         var _loc4_:String = (_loc3_ : ASAny).hasOwnProperty("getStackTrace") ? _loc3_.getStackTrace() : null;
         if(!ASCompat.stringAsBool(_loc4_))
         {
            return "";
         }
         var _loc5_= "";
         var _loc6_:Array<ASAny> = (cast new compat.RegExp("\\n\\sat\\s").split(_loc4_));
         var _loc7_= _loc6_.length;
         var _loc8_= new compat.RegExp("Function|" + ASCompat.getQualifiedClassName(Console) + "|" + ASCompat.getQualifiedClassName(Cc));
         var _loc9_= false;
         var _loc10_= 2;
         while(_loc10_ < _loc7_)
         {
            if(!_loc9_ && ASCompat.toNumber(_loc8_.search(Std.string(_loc6_[_loc10_]))) != 0)
            {
               _loc9_ = true;
            }
            if(_loc9_)
            {
               _loc5_ += "\n<p" + param2 + "> @ " + Std.string(_loc6_[_loc10_]) + "</p" + param2 + ">";
               if(param2 > 0)
               {
                  param2--;
               }
               param1--;
               if(param1 <= 0)
               {
                  break;
               }
            }
            _loc10_++;
         }
         return _loc5_;
      }
   }


