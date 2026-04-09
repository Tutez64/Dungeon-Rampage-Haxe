package com.adobe.serialization.json
;
    class JSONTokenizer
   {
      
      var strict:Bool = false;
      
      var obj:ASObject;
      
      var jsonString:String;
      
      var loc:Int = 0;
      
      var ch:String;
      
      final controlCharsRegExp:compat.RegExp = new compat.RegExp("[\\x00-\\x1F]");
      
      public function new(param1:String, param2:Bool)
      {
         
         this.jsonString = param1;
         this.strict = param2;
         this.loc = 0;
         this.nextChar();
      }
      
      public function getNextToken() : JSONToken
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc1_:JSONToken = null;
         this.skipIgnored();
         do {
                  switch(this.ch)
         {
            case "{":
               _loc1_ = JSONToken.create(JSONTokenType.LEFT_BRACE,this.ch);
               this.nextChar();
               
            case "}":
               _loc1_ = JSONToken.create(JSONTokenType.RIGHT_BRACE,this.ch);
               this.nextChar();
               
            case "[":
               _loc1_ = JSONToken.create(JSONTokenType.LEFT_BRACKET,this.ch);
               this.nextChar();
               
            case "]":
               _loc1_ = JSONToken.create(JSONTokenType.RIGHT_BRACKET,this.ch);
               this.nextChar();
               
            case ",":
               _loc1_ = JSONToken.create(JSONTokenType.COMMA,this.ch);
               this.nextChar();
               
            case ":":
               _loc1_ = JSONToken.create(JSONTokenType.COLON,this.ch);
               this.nextChar();
               
            case "t":
               _loc2_ = "t" + this.nextChar() + this.nextChar() + this.nextChar();
               if(_loc2_ == "true")
               {
                  _loc1_ = JSONToken.create(JSONTokenType.TRUE_cpp,true);
                  this.nextChar();
                  break;
               }
               this.parseError("Expecting \'true\' but found " + _loc2_);
               
            case "f":
               _loc3_ = "f" + this.nextChar() + this.nextChar() + this.nextChar() + this.nextChar();
               if(_loc3_ == "false")
               {
                  _loc1_ = JSONToken.create(JSONTokenType.FALSE_cpp,false);
                  this.nextChar();
                  break;
               }
               this.parseError("Expecting \'false\' but found " + _loc3_);
               
            case "n":
               _loc4_ = "n" + this.nextChar() + this.nextChar() + this.nextChar();
               if(_loc4_ == "null")
               {
                  _loc1_ = JSONToken.create(JSONTokenType.NULL_cpp,null);
                  this.nextChar();
                  break;
               }
               this.parseError("Expecting \'null\' but found " + _loc4_);
               
            case "N":
               _loc5_ = "N" + this.nextChar() + this.nextChar();
               if(_loc5_ == "NaN")
               {
                  _loc1_ = JSONToken.create(JSONTokenType.NAN_cpp,Math.NaN);
                  this.nextChar();
                  break;
               }
               this.parseError("Expecting \'NaN\' but found " + _loc5_);
               
            case "\"":
               _loc1_ = this.readString();
               
            default:
               if(this.isDigit(this.ch) || this.ch == "-")
               {
                  _loc1_ = this.readNumber();
                  break;
               }
               if(this.ch == "")
               {
                  _loc1_ = null;
                  break;
               }
               this.parseError("Unexpected " + this.ch + " encountered");
         }
         } while (false);
         return _loc1_;
      }
      
      final function readString() : JSONToken
      {
         var _loc3_= 0;
         var _loc4_= 0;
         var _loc1_= this.loc;
         while(true)
         {
            _loc1_ = this.jsonString.indexOf("\"",_loc1_);
            if(_loc1_ >= 0)
            {
               _loc3_ = 0;
               _loc4_ = _loc1_ - 1;
               while(this.jsonString.charAt(_loc4_) == "\\")
               {
                  _loc3_++;
                  _loc4_--;
               }
               if((_loc3_ & 1) == 0)
               {
                  break;
               }
               _loc1_++;
            }
            else
            {
               this.parseError("Unterminated string literal");
            }
         }
         var _loc2_= JSONToken.create(JSONTokenType.STRING,this.unescapeString(this.jsonString.substr(this.loc,_loc1_ - this.loc)));
         this.loc = _loc1_ + 1;
         this.nextChar();
         return _loc2_;
      }
      
      public function unescapeString(param1:String) : String
      {
         var _loc4_= 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_= 0;
         var _loc9_= 0;
         var _loc10_:String = null;
         if(this.strict && this.controlCharsRegExp.test(param1))
         {
            this.parseError("String contains unescaped control character (0x00-0x1F)");
         }
         var _loc2_= "";
         var _loc3_= 0;
         _loc4_ = 0;
         var _loc5_= param1.length;
         do
         {
            _loc3_ = param1.indexOf("\\",_loc4_);
            if(_loc3_ < 0)
            {
               _loc2_ += param1.substr(_loc4_);
               break;
            }
            _loc2_ += param1.substr(_loc4_,_loc3_ - _loc4_);
            _loc4_ = _loc3_ + 2;
            _loc6_ = param1.charAt(_loc3_ + 1);
            switch(_loc6_)
            {
               case "\"":
                  _loc2_ += _loc6_;
                  
               case "\\":
                  _loc2_ += _loc6_;
                  
               case "n":
                  _loc2_ += "\n";
                  
               case "r":
                  _loc2_ += "\r";
                  
               case "t":
                  _loc2_ += "\t";
                  
               case "u":
                  _loc7_ = "";
                  _loc8_ = _loc4_ + 4;
                  if(_loc8_ > _loc5_)
                  {
                     this.parseError("Unexpected end of input.  Expecting 4 hex digits after \\u.");
                  }
                  _loc9_ = _loc4_;
                  while(_loc9_ < _loc8_)
                  {
                     _loc10_ = param1.charAt(_loc9_);
                     if(!this.isHexDigit(_loc10_))
                     {
                        this.parseError("Excepted a hex digit, but found: " + _loc10_);
                     }
                     _loc7_ += _loc10_;
                     _loc9_++;
                  }
                  _loc2_ += String.fromCharCode(ASCompat.parseInt(_loc7_,16));
                  _loc4_ = _loc8_;
                  
               case "f":
                  _loc2_ += "\x0C";
                  
               case "/":
                  _loc2_ += "/";
                  
               case "b":
                  _loc2_ += "\x08";
                  
               default:
                  _loc2_ += "\\" + _loc6_;
            }
         }
         while(_loc4_ < _loc5_);
         
         return _loc2_;
      }
      
      final function readNumber() : JSONToken
      {
         var _loc1_= "";
         if(this.ch == "-")
         {
            _loc1_ += "-";
            this.nextChar();
         }
         if(!this.isDigit(this.ch))
         {
            this.parseError("Expecting a digit");
         }
         if(this.ch == "0")
         {
            _loc1_ += this.ch;
            this.nextChar();
            if(this.isDigit(this.ch))
            {
               this.parseError("A digit cannot immediately follow 0");
            }
            else if(!this.strict && this.ch == "x")
            {
               _loc1_ += this.ch;
               this.nextChar();
               if(this.isHexDigit(this.ch))
               {
                  _loc1_ += this.ch;
                  this.nextChar();
               }
               else
               {
                  this.parseError("Number in hex format require at least one hex digit after \"0x\"");
               }
               while(this.isHexDigit(this.ch))
               {
                  _loc1_ += this.ch;
                  this.nextChar();
               }
            }
         }
         else
         {
            while(this.isDigit(this.ch))
            {
               _loc1_ += this.ch;
               this.nextChar();
            }
         }
         if(this.ch == ".")
         {
            _loc1_ += ".";
            this.nextChar();
            if(!this.isDigit(this.ch))
            {
               this.parseError("Expecting a digit");
            }
            while(this.isDigit(this.ch))
            {
               _loc1_ += this.ch;
               this.nextChar();
            }
         }
         if(this.ch == "e" || this.ch == "E")
         {
            _loc1_ += "e";
            this.nextChar();
            if(this.ch == "+" || this.ch == "-")
            {
               _loc1_ += this.ch;
               this.nextChar();
            }
            if(!this.isDigit(this.ch))
            {
               this.parseError("Scientific notation number needs exponent value");
            }
            while(this.isDigit(this.ch))
            {
               _loc1_ += this.ch;
               this.nextChar();
            }
         }
         var _loc2_= ASCompat.toNumber(_loc1_);
         if(Math.isFinite(_loc2_) && !Math.isNaN(_loc2_))
         {
            return JSONToken.create(JSONTokenType.NUMBER,_loc2_);
         }
         this.parseError("Number " + _loc2_ + " is not valid!");
         return null;
      }
      
      final function nextChar() : String
      {
         return this.ch = this.jsonString.charAt(this.loc++);
      }
      
      final function skipIgnored() 
      {
         var _loc1_= 0;
         do
         {
            _loc1_ = this.loc;
            this.skipWhite();
            this.skipComments();
         }
         while(_loc1_ != this.loc);
         
      }
      
      function skipComments() 
      {
         if(this.ch == "/")
         {
            this.nextChar();
            switch(this.ch)
            {
               case "/":
                  do
                  {
                     this.nextChar();
                  }
                  while(this.ch != "\n" && this.ch != "");
                  
                  this.nextChar();
                  
               case "*":
                  this.nextChar();
                  while(true)
                  {
                     if(this.ch == "*")
                     {
                        this.nextChar();
                        if(this.ch == "/")
                        {
                           break;
                        }
                     }
                     else
                     {
                        this.nextChar();
                     }
                     if(this.ch == "")
                     {
                        this.parseError("Multi-line comment not closed");
                     }
                  }
                  this.nextChar();
                  
               default:
                  this.parseError("Unexpected " + this.ch + " encountered (expecting \'/\' or \'*\' )");
            }
         }
      }
      
      final function skipWhite() 
      {
         while(this.isWhiteSpace(this.ch))
         {
            this.nextChar();
         }
      }
      
      final function isWhiteSpace(param1:String) : Bool
      {
         if(param1 == " " || param1 == "\t" || param1 == "\n" || param1 == "\r")
         {
            return true;
         }
         if(!this.strict && param1.charCodeAt(0) == 160)
         {
            return true;
         }
         return false;
      }
      
      final function isDigit(param1:String) : Bool
      {
         return param1 >= "0" && param1 <= "9";
      }
      
      final function isHexDigit(param1:String) : Bool
      {
         return this.isDigit(param1) || param1 >= "A" && param1 <= "F" || param1 >= "a" && param1 <= "f";
      }
      
      final public function parseError(param1:String) 
      {
         throw new JSONParseError(param1,this.loc,this.jsonString);
      }
   }


