package com.junkbyte.console.core
;
   import com.junkbyte.console.vos.WeakObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
    class Executer extends EventDispatcher
   {
      
      public static inline final RETURNED= "returned";
      
      public static inline final CLASSES= "ExeValue|((com.junkbyte.console.core::)?Executer)";
      
      static inline final VALKEY= "#";
      
      var _values:Array<ASAny>;
      
      var _running:Bool = false;
      
      var _scope:ASAny;
      
      var _returned:ASAny;
      
      var _saved:ASObject;
      
      var _reserved:Array<ASAny>;
      
      public var autoScope:Bool = false;
      
      public function new()
      {
         super();
      }
      
      public static function Exec(param1:ASObject, param2:String, param3:ASObject = null) : ASAny
      {
         var _loc4_= new Executer();
         _loc4_.setStored(param3);
         return _loc4_.exec(param1,param2);
      }
      
      @:isVar public var returned(get,never):ASAny;
public function  get_returned() : ASAny
      {
         return this._returned;
      }
      
      @:isVar public var scope(get,never):ASAny;
public function  get_scope() : ASAny
      {
         return this._scope;
      }
      
      public function setStored(param1:ASObject) 
      {
         this._saved = param1;
      }
      
      public function setReserved(param1:Array<ASAny>) 
      {
         this._reserved = param1;
      }
      
      public function exec(param1:ASAny, param2:String) : ASAny
      {
         var s:ASAny = param1;
         var str= param2;
         if(this._running)
         {
            throw new Error("CommandExec.exec() is already runnnig. Does not support loop backs.");
         }
         this._running = true;
         this._scope = s;
         this._values = [];
         if(!ASCompat.toBool(this._saved))
         {
            this._saved = new ASObject();
         }
         if(this._reserved == null)
         {
            this._reserved = new Array<ASAny>();
         }
         try
         {
            this._exec(str);
         }
         catch(e:Dynamic)
         {
            reset();
            throw e;
         }
         this.reset();
         return this._returned;
      }
      
      function reset() 
      {
         this._saved = null;
         this._reserved = null;
         this._values = null;
         this._running = false;
      }
      
      function _exec(param1:String) 
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_= 0;
         var _loc9_= 0;
         var _loc10_:String = null;
         var _loc11_:ASAny = /*undefined*/null;
         var _loc2_= new compat.RegExp("''|\"\"|('(.*?)[^\\\\]')|(\"(.*?)[^\\\\]\")");
         var _loc3_:ASObject = _loc2_.exec(param1);
         while(_loc3_ != null)
         {
            _loc6_ = _loc3_[Std.string(0)];
            _loc7_ = _loc6_.charAt(0);
            _loc8_ = _loc6_.indexOf(_loc7_);
            _loc9_ = _loc6_.lastIndexOf(_loc7_);
            _loc10_ = new compat.RegExp("\\\\(.)", "g").replace(_loc6_.substring(_loc8_ + 1,_loc9_),"$1");
            param1 = this.tempValue(param1,new ExeValue(_loc10_),ASCompat.toInt(_loc3_.index + _loc8_),ASCompat.toInt(_loc3_.index + _loc9_ + 1));
            _loc3_ = _loc2_.exec(param1);
         }
         if(new compat.RegExp("'|\"").search(param1) >= 0)
         {
            throw new Error("Bad syntax extra quotation marks");
         }
         var _loc4_:Array<ASAny> = (cast new compat.RegExp("\\s*;\\s*").split(param1));
         if (checkNullIteratee(_loc4_)) for (_tmp_ in _loc4_)
         {
            _loc5_  = _tmp_;
            if(_loc5_.length != 0)
            {
               _loc11_ = this._saved[RETURNED];
               if(ASCompat.toBool(_loc11_) && _loc5_ == "/")
               {
                  this._scope = _loc11_;
                  dispatchEvent(new Event(Event.COMPLETE));
               }
               else
               {
                  this.execNest(_loc5_);
               }
            }
         }
      }
      
      function execNest(param1:String) : ASAny
      {
         var _loc3_= 0;
         var _loc4_= 0;
         var _loc5_= 0;
         var _loc6_:String = null;
         var _loc7_= false;
         var _loc8_= 0;
         var _loc9_:String = null;
         var _loc10_:Array<ASAny> = null;
         var _loc11_:String = null;
         var _loc12_:ExeValue = null;
         var _loc13_:String = null;
         param1 = this.ignoreWhite(param1);
         var _loc2_= param1.lastIndexOf("(");
         while(_loc2_ >= 0)
         {
            _loc3_ = param1.indexOf(")",_loc2_);
            if(new compat.RegExp("\\w").search(param1.substring(_loc2_ + 1,_loc3_)) >= 0)
            {
               _loc4_ = _loc2_;
               _loc5_ = _loc2_ + 1;
               while(_loc4_ >= 0 && _loc4_ < _loc5_)
               {
                  _loc4_++;
                  _loc4_ = param1.indexOf("(",_loc4_);
                  _loc5_ = param1.indexOf(")",_loc5_ + 1);
               }
               _loc6_ = param1.substring(_loc2_ + 1,_loc5_);
               _loc7_ = false;
               _loc8_ = _loc2_ - 1;
               while(true)
               {
                  _loc9_ = param1.charAt(_loc8_);
                  if(ASCompat.toBool(new compat.RegExp("[^\\s]").match(_loc9_)) || _loc8_ <= 0)
                  {
                     break;
                  }
                  _loc8_--;
               }
               if(new compat.RegExp("\\w").match(_loc9_) != null)
               {
                  _loc7_ = true;
               }
               if(_loc7_)
               {
                  _loc10_ = (cast _loc6_.split(","));
                  param1 = this.tempValue(param1,new ExeValue(_loc10_),_loc2_ + 1,_loc5_);
                  if (checkNullIteratee(_loc10_)) for(_tmp_ in 0..._loc10_.length)
                  {
                     _loc11_  = Std.string(_tmp_);
                     (_loc10_ : ASAny)[ASCompat.toInt(_loc11_)] = this.execOperations(this.ignoreWhite((_loc10_ : ASAny)[ASCompat.toInt(_loc11_)])).value;
                  }
               }
               else
               {
                  _loc12_ = new ExeValue(_loc12_);
                  param1 = this.tempValue(param1,_loc12_,_loc2_,_loc5_ + 1);
                  _loc12_.setValue(this.execOperations(this.ignoreWhite(_loc6_)).value);
               }
            }
            _loc2_ = param1.lastIndexOf("(",_loc2_ - 1);
         }
         this._returned = this.execOperations(param1).value;
         if(ASCompat.toBool(this._returned) && this.autoScope)
         {
            _loc13_ = ASCompat.typeof(this._returned);
            if(_loc13_ == "object" || _loc13_ == "xml")
            {
               this._scope = this._returned;
            }
         }
         dispatchEvent(new Event(Event.COMPLETE));
         return this._returned;
      }
      
      function tempValue(param1:String, param2:ASAny, param3:Int, param4:Int) : String
      {
         param1 = param1.substring(0,param3) + VALKEY + this._values.length + param1.substring(param4);
         this._values.push(param2);
         return param1;
      }
      
      function execOperations(param1:String) : ExeValue
      {
         var _loc7_:String = null;
         var _loc8_:ASAny = /*undefined*/null;
         var _loc11_= 0;
         var _loc12_= 0;
         var _loc13_:String = null;
         var _loc14_:ExeValue = null;
         var _loc15_:ExeValue = null;
         var _loc2_= new compat.RegExp("\\s*(((\\|\\||\\&\\&|[+|\\-|*|\\/|\\%|\\||\\&|\\^]|\\=\\=?|\\!\\=|\\>\\>?\\>?|\\<\\<?)\\=?)|=|\\~|\\sis\\s|typeof|delete\\s)\\s*", "g");
         var _loc3_:ASObject = _loc2_.exec(param1);
         var _loc4_:Array<ASAny> = [];
         if(_loc3_ == null)
         {
            _loc4_.push(param1);
         }
         else
         {
            _loc11_ = 0;
            while(_loc3_ != null)
            {
               _loc12_ = ASCompat.toInt(_loc3_.index);
               _loc13_ = _loc3_[Std.string(0)];
               _loc3_ = _loc2_.exec(param1);
               if(_loc3_ == null)
               {
                  _loc4_.push(param1.substring(_loc11_,_loc12_));
                  _loc4_.push(this.ignoreWhite(_loc13_));
                  _loc4_.push(param1.substring(_loc12_ + _loc13_.length));
               }
               else
               {
                  _loc4_.push(param1.substring(_loc11_,_loc12_));
                  _loc4_.push(this.ignoreWhite(_loc13_));
                  _loc11_ = _loc12_ + _loc13_.length;
               }
            }
         }
         var _loc5_= _loc4_.length;
         var _loc6_= 0;
         while(_loc6_ < _loc5_)
         {
            _loc4_[_loc6_] = this.execSimple(_loc4_[_loc6_]);
            _loc6_ += 2;
         }
         var _loc9_= new compat.RegExp("((\\|\\||\\&\\&|[+|\\-|*|\\/|\\%|\\||\\&|\\^]|\\>\\>\\>?|\\<\\<)\\=)|=");
         _loc6_ = 1;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = _loc4_[_loc6_];
            if(_loc9_.replace(_loc7_,"") != "")
            {
               _loc8_ = this.operate(ASCompat.dynamicAs(_loc4_[_loc6_ - 1], ExeValue),_loc7_,ASCompat.dynamicAs(_loc4_[_loc6_ + 1], ExeValue));
               _loc14_ = cast(_loc4_[_loc6_ - 1], ExeValue);
               _loc14_.setValue(_loc8_);
               _loc4_.splice(_loc6_,(2 : UInt));
               _loc6_ -= 2;
               _loc5_ -= 2;
            }
            _loc6_ += 2;
         }
         ASCompat.ASArray.reverse(_loc4_);
         var _loc10_= ASCompat.dynamicAs(_loc4_[0], ExeValue);
         _loc6_ = 1;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = _loc4_[_loc6_];
            if(_loc9_.replace(_loc7_,"") == "")
            {
               _loc10_ = ASCompat.dynamicAs(_loc4_[_loc6_ - 1], ExeValue);
               _loc15_ = ASCompat.dynamicAs(_loc4_[_loc6_ + 1], ExeValue);
               if(_loc7_.length > 1)
               {
                  _loc7_ = _loc7_.substring(0,_loc7_.length - 1);
               }
               _loc8_ = this.operate(_loc15_,_loc7_,_loc10_);
               _loc15_.setValue(_loc8_);
            }
            _loc6_ += 2;
         }
         return _loc10_;
      }
      
      function execSimple(param1:String) : ExeValue
      {
         var reg:compat.RegExp;
         var result:ASObject;
         var previndex:Int;
         var firstparts:Array<ASAny> = null;
         var newstr:String = null;
         var defclose= 0;
         var newobj:ASAny = /*undefined*/null;
         var classstr:String = null;
         var def:Dynamic = /*undefined*/null;
         var havemore= false;
         var index= 0;
         var isFun= false;
         var basestr:String = null;
         var newv:ExeValue = null;
         var newbase:ASAny = /*undefined*/null;
         var closeindex= 0;
         var paramstr:String = null;
         var params:Array<ASAny> = null;
         var nss:Array<ASAny> = null;
         var ns:ASAny = null;
         var nsv:ASAny = /*undefined*/null;
         var str= param1;
         var v= new ExeValue(this._scope);
         if(str.indexOf("new ") == 0)
         {
            newstr = str;
            defclose = str.indexOf(")");
            if(defclose >= 0)
            {
               newstr = str.substring(0,defclose + 1);
            }
            newobj = this.makeNew(newstr.substring(4));
            str = this.tempValue(str,new ExeValue(newobj),0,newstr.length);
         }
         reg = new compat.RegExp("\\.|\\(", "g");
         result = reg.exec(str);
         if(result == null || !Math.isNaN(ASCompat.toNumber(str)))
         {
            return this.execValue(str,this._scope);
         }
         firstparts = (cast str.split("(")[0].split("."));
         if(firstparts.length > 0)
         {
            while(firstparts.length != 0)
            {
               classstr = firstparts.join(".");
               try
               {
                  def = Type.resolveClass(this.ignoreWhite(classstr));
                  havemore = str.length > classstr.length;
                  str = this.tempValue(str,new ExeValue(def),0,classstr.length);
                  if(havemore)
                  {
                     reg.lastIndex = 0;
                     result = reg.exec(str);
                     break;
                  }
                  return this.execValue(str);
               }
               catch(e:Dynamic)
               {
                  firstparts.pop();
               }
            }
         }
         previndex = 0;
         while(true)
         {
            if(result == null)
            {
               return v;
            }
            index = ASCompat.toInt(result.index);
            isFun = str.charAt(index) == "(";
            basestr = this.ignoreWhite(str.substring(previndex,index));
            newv = previndex == 0 ? this.execValue(basestr,v.value) : new ExeValue(v.value,basestr);
            if(isFun)
            {
               newbase = newv.value;
               closeindex = str.indexOf(")",index);
               paramstr = str.substring(index + 1,closeindex);
               paramstr = this.ignoreWhite(paramstr);
               params = [];
               if(ASCompat.stringAsBool(paramstr))
               {
                  params = ASCompat.dynamicAs(this.execValue(paramstr).value, Array);
               }
               if(!Reflect.isFunction(newbase ))
               {
                  try
                  {
                     nss = [null];
                     if (checkNullIteratee(nss)) for (_tmp_ in nss)
                     {
                        ns  = _tmp_;
                        nsv = v.obj/*ns::*/[basestr];
                        if(Reflect.isFunction(nsv ))
                        {
                           newbase = nsv;
                           break;
                        }
                     }
                  }
                  catch(e:Dynamic)
                  {
                  }
                  if(!Reflect.isFunction(newbase ))
                  {
                     break;
                  }
               }
               v.obj = Reflect.callMethod(v.value,ASCompat.asFunction(newbase ), params);
               v.prop = null;
               index = closeindex + 1;
            }
            else
            {
               v = newv;
            }
            previndex = index + 1;
            reg.lastIndex = index + 1;
            result = reg.exec(str);
            if(result == null)
            {
               if(index + 1 < str.length)
               {
                  reg.lastIndex = str.length;
                  result = {"index":str.length};
               }
            }
         }
         throw new Error(basestr + " is not a function.");
return null;
      }
      
      function execValue(param1:String, param2:ASAny = null) : ExeValue
      {
         var v:ExeValue = null;
         var vv:ExeValue = null;
         var key:String = null;
         var str= param1;
         var base:ASAny = param2;
         v = new ExeValue();
         if(str == "true")
         {
            v.obj = true;
         }
         else if(str == "false")
         {
            v.obj = false;
         }
         else if(str == "this")
         {
            v.obj = this._scope;
         }
         else if(str == "null")
         {
            v.obj = null;
         }
         else if(!Math.isNaN(ASCompat.toNumber(str)))
         {
            v.obj = ASCompat.toNumber(str);
         }
         else if(str.indexOf(VALKEY) == 0)
         {
            vv = ASCompat.dynamicAs((this._values : ASAny)[ASCompat.toInt(str.substring(VALKEY.length))], ExeValue);
            v.obj = vv.value;
         }
         else if(str.charAt(0) == "$")
         {
            key = str.substring(1);
            if(this._reserved.indexOf(key) < 0)
            {
               v.obj = this._saved;
               v.prop = key;
            }
            else if(Std.isOfType(this._saved , WeakObject))
            {
               v.obj = cast(this._saved, WeakObject).get(key);
            }
            else
            {
               v.obj = this._saved[key];
            }
         }
         else
         {
            try
            {
               v.obj = Type.resolveClass(str);
            }
            catch(e:Dynamic)
            {
               v.obj = base;
               v.prop = str;
            }
         }
         return v;
      }
      
      function operate(param1:ExeValue, param2:String, param3:ExeValue) : ASAny
      {
         switch(param2)
         {
            case "=":
               return param3.value;
            case "+":
               return param1.value + param3.value;
            case "-":
               return ASCompat.toNumberField(param1, "value") - ASCompat.toNumberField(param3, "value");
            case "*":
               return ASCompat.toNumberField(param1, "value") * ASCompat.toNumberField(param3, "value");
            case "/":
               return ASCompat.toNumberField(param1, "value") / ASCompat.toNumberField(param3, "value");
            case "%":
               return ASCompat.toNumberField(param1, "value") % ASCompat.toNumberField(param3, "value");
            case "^":
               return ASCompat.toInt(param1.value) ^ ASCompat.toInt(param3.value);
            case "&":
               return ASCompat.toInt(param1.value) & ASCompat.toInt(param3.value);
            case ">>":
               return ASCompat.toInt(param1.value) >> ASCompat.toInt(param3.value);
            case ">>>":
               return ASCompat.toInt(param1.value) >>> ASCompat.toInt(param3.value);
            case "<<":
               return ASCompat.toInt(param1.value) << ASCompat.toInt(param3.value);
            case "~":
               return ~ASCompat.toInt(param3.value);
            case "|":
               return ASCompat.toInt(param1.value) | ASCompat.toInt(param3.value);
            case "!":
               return !ASCompat.toBool(param3.value);
            case ">":
               return param1.value > param3.value;
            case ">=":
               return param1.value >= param3.value;
            case "<":
               return param1.value < param3.value;
            case "<=":
               return param1.value <= param3.value;
            case "||":
               return if (ASCompat.toBool(param1.value)) param1.value else param3.value;
            case "&&":
               return param1.value && param3.value;
            case "is":
               return Std.isOfType(param1.value , param3.value);
            case "typeof":
               return ASCompat.typeof(param3.value);
            case "delete":
               return ASCompat.deleteProperty(param3.obj, param3.prop);
            case "==":
               return param1.value == param3.value;
            case "===":
               return param1.value == param3.value;
            case "!=":
               return param1.value != param3.value;
            case "!==":
               return param1.value != param3.value;
            default:
               return null;
         }
return null;
      }
      
      function makeNew(param1:String) : ASAny
      {
         var _loc5_= 0;
         var _loc6_:String = null;
         var _loc7_:Array<ASAny> = null;
         var _loc8_= 0;
         var _loc2_= param1.indexOf("(");
         var _loc3_= _loc2_ > 0 ? param1.substring(0,_loc2_) : param1;
         _loc3_ = this.ignoreWhite(_loc3_);
         var _loc4_:ASAny = this.execValue(_loc3_).value;
         if(_loc2_ > 0)
         {
            _loc5_ = param1.indexOf(")",_loc2_);
            _loc6_ = param1.substring(_loc2_ + 1,_loc5_);
            _loc6_ = this.ignoreWhite(_loc6_);
            _loc7_ = [];
            if(ASCompat.stringAsBool(_loc6_))
            {
               _loc7_ = ASCompat.dynamicAs(this.execValue(_loc6_).value, Array);
            }
            _loc8_ = _loc7_.length;
            if(_loc8_ == 0)
            {
               return ASCompat.createInstance(_loc4_, []);
            }
            if(_loc8_ == 1)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0]]);
            }
            if(_loc8_ == 2)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0],_loc7_[1]]);
            }
            if(_loc8_ == 3)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0],_loc7_[1],_loc7_[2]]);
            }
            if(_loc8_ == 4)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3]]);
            }
            if(_loc8_ == 5)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4]]);
            }
            if(_loc8_ == 6)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5]]);
            }
            if(_loc8_ == 7)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6]]);
            }
            if(_loc8_ == 8)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7]]);
            }
            if(_loc8_ == 9)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8]]);
            }
            if(_loc8_ == 10)
            {
               return ASCompat.createInstance(_loc4_, [_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8],_loc7_[9]]);
            }
            throw new Error("CommandLine can\'t create new class instances with more than 10 arguments.");
         }
         return null;
      }
      
      function ignoreWhite(param1:String) : String
      {
         param1 = new compat.RegExp("\\s*(.*)").replace(param1,"$1");
         var _loc2_= param1.length - 1;
         while(_loc2_ > 0)
         {
            if(new compat.RegExp("\\s").match(param1.charAt(_loc2_)) == null)
            {
               break;
            }
            param1 = param1.substring(0,_loc2_);
            _loc2_--;
         }
         return param1;
      }
   }


private class ExeValue
{
   
   public var obj:ASAny;
   
   public var prop:String;
   
   public function new(param1:ASObject = null, param2:String = null)
   {
      
      this.obj = param1;
      this.prop = param2;
   }
   
   @:isVar public var value(get,never):ASAny;
public function  get_value() : ASAny
   {
      return ASCompat.stringAsBool(this.prop) ? this.obj[this.prop] : this.obj;
   }
   
   public function setValue(param1:ASAny) 
   {
      if(ASCompat.stringAsBool(this.prop))
      {
         this.obj[this.prop] = param1;
      }
      else
      {
         this.obj = param1;
      }
   }
}
