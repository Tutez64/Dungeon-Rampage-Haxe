package com.maccherone.json
;
    class JSONTokenizer
   {
      
      var ch:String;
      
      var loc:Int = 0;
      
      var jsonString:String;
      
      var strict:Bool = false;
      
      var obj:ASObject;
      
      public function new(param1:String, param2:Bool)
      {
         
         jsonString = param1;
         this.strict = param2;
         loc = 0;
         nextChar();
      }
      
      function skipComments() 
      {
         if(ch == "/")
         {
            nextChar();
            switch(ch)
            {
               case "/":
                  do
                  {
                     nextChar();
                  }
                  while(ch != "\n" && ch != "");
                  
                  nextChar();
                  
               case "*":
                  nextChar();
                  while(true)
                  {
                     if(ch == "*")
                     {
                        nextChar();
                        if(ch == "/")
                        {
                           break;
                        }
                     }
                     else
                     {
                        nextChar();
                     }
                     if(ch == "")
                     {
                        parseError("Multi-line comment not closed");
                     }
                  }
                  nextChar();
                  
               default:
                  parseError("Unexpected " + ch + " encountered (expecting \'/\' or \'*\' )");
            }
         }
      }
      
      function isDigit(param1:String) : Bool
      {
         return param1 >= "0" && param1 <= "9";
      }
      
      public function getNextToken() : JSONToken
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc1_= new JSONToken();
         skipIgnored();
         do {
                  switch(ch)
         {
            case "{":
               _loc1_.type = JSONTokenType.LEFT_BRACE;
               _loc1_.value = "{";
               nextChar();
               
            case "}":
               _loc1_.type = JSONTokenType.RIGHT_BRACE;
               _loc1_.value = "}";
               nextChar();
               
            case "[":
               _loc1_.type = JSONTokenType.LEFT_BRACKET;
               _loc1_.value = "[";
               nextChar();
               
            case "]":
               _loc1_.type = JSONTokenType.RIGHT_BRACKET;
               _loc1_.value = "]";
               nextChar();
               
            case ",":
               _loc1_.type = JSONTokenType.COMMA;
               _loc1_.value = ",";
               nextChar();
               
            case ":":
               _loc1_.type = JSONTokenType.COLON;
               _loc1_.value = ":";
               nextChar();
               
            case "t":
               _loc2_ = "t" + nextChar() + nextChar() + nextChar();
               if(_loc2_ == "true")
               {
                  _loc1_.type = JSONTokenType.TRUE_cpp;
                  _loc1_.value = true;
                  nextChar();
                  break;
               }
               parseError("Expecting \'true\' but found " + _loc2_);
               
            case "f":
               _loc3_ = "f" + nextChar() + nextChar() + nextChar() + nextChar();
               if(_loc3_ == "false")
               {
                  _loc1_.type = JSONTokenType.FALSE_cpp;
                  _loc1_.value = false;
                  nextChar();
                  break;
               }
               parseError("Expecting \'false\' but found " + _loc3_);
               
            case "n":
               _loc4_ = "n" + nextChar() + nextChar() + nextChar();
               if(_loc4_ == "null")
               {
                  _loc1_.type = JSONTokenType.NULL_cpp;
                  _loc1_.value = null;
                  nextChar();
                  break;
               }
               parseError("Expecting \'null\' but found " + _loc4_);
               
            case "N":
               _loc5_ = "N" + nextChar() + nextChar();
               if(_loc5_ == "NaN")
               {
                  _loc1_.type = JSONTokenType.NAN_cpp;
                  _loc1_.value = Math.NaN;
                  nextChar();
                  break;
               }
               parseError("Expecting \'NaN\' but found " + _loc5_);
               
            case "\"":
               _loc1_ = readString();
               
            default:
               if(isDigit(ch) || ch == "-")
               {
                  _loc1_ = readNumber();
                  break;
               }
               if(ch == "")
               {
                  return null;
               }
               parseError("Unexpected " + ch + " encountered");
         }
         } while (false);
         return _loc1_;
      }
      
      function skipWhite() 
      {
         while(isWhiteSpace(ch))
         {
            nextChar();
         }
      }
      
      function isWhiteSpace(param1:String) : Bool
      {
         return param1 == " " || param1 == "\t" || param1 == "\n" || param1 == "\r";
      }
      
      public function parseError(param1:String) 
      {
         throw new JSONParseError(param1,loc,jsonString);
      }
      
      function readString() : JSONToken
      {
         var _loc3_:String = null;
         var _loc4_= 0;
         var _loc1_= "";
         nextChar();
         while(ch != "\"" && ch != "")
         {
            if(ch != "\\")
            {
               _loc1_ += ch;
               nextChar();continue;
            }
            nextChar();
            switch(ch)
            {
               case "\"":
                  _loc1_ += "\"";
                  
               case "/":
                  _loc1_ += "/";
                  
               case "\\":
                  _loc1_ += "\\";
                  
               case "b":
                  _loc1_ += "\x08";
                  
               case "f":
                  _loc1_ += "\x0C";
                  
               case "n":
                  _loc1_ += "\n";
                  
               case "r":
                  _loc1_ += "\r";
                  
               case "t":
                  _loc1_ += "\t";
                  
               case "u":
                  _loc3_ = "";
                  _loc4_ = 0;
                  while(_loc4_ < 4)
                  {
                     if(!isHexDigit(nextChar()))
                     {
                        parseError(" Excepted a hex digit, but found: " + ch);
                     }
                     _loc3_ += ch;
                     _loc4_++;
                  }
                  _loc1_ += String.fromCharCode(ASCompat.parseInt(_loc3_,16));
                  
               default:
                  _loc1_ += "\\" + ch;
            }
nextChar();
         }
         if(ch == "")
         {
            parseError("Unterminated string literal");
         }
         nextChar();
         var _loc2_= new JSONToken();
         _loc2_.type = JSONTokenType.STRING;
         _loc2_.value = _loc1_;
         return _loc2_;
      }
      
      function nextChar() : String
      {
         return ch = jsonString.charAt(loc++);
      }
      
      function skipIgnored() 
      {
         var _loc1_= 0;
         do
         {
            _loc1_ = loc;
            skipWhite();
            skipComments();
         }
         while(_loc1_ != loc);
         
      }
      
      function isHexDigit(param1:String) : Bool
      {
         var _loc2_= param1.toUpperCase();
         return isDigit(param1) || _loc2_ >= "A" && _loc2_ <= "F";
      }
      
      function readNumber() : JSONToken
      {
         var _loc3_:JSONToken = null;
         var _loc1_= "";
         if(ch == "-")
         {
            _loc1_ += "-";
            nextChar();
         }
         if(!isDigit(ch))
         {
            parseError("Expecting a digit");
         }
         if(ch == "0")
         {
            _loc1_ += ch;
            nextChar();
            if(isDigit(ch))
            {
               parseError("A digit cannot immediately follow 0");
            }
            else if(!strict && ch == "x")
            {
               _loc1_ += ch;
               nextChar();
               if(isHexDigit(ch))
               {
                  _loc1_ += ch;
                  nextChar();
               }
               else
               {
                  parseError("Number in hex format require at least one hex digit after \"0x\"");
               }
               while(isHexDigit(ch))
               {
                  _loc1_ += ch;
                  nextChar();
               }
            }
         }
         else
         {
            while(isDigit(ch))
            {
               _loc1_ += ch;
               nextChar();
            }
         }
         if(ch == ".")
         {
            _loc1_ += ".";
            nextChar();
            if(!isDigit(ch))
            {
               parseError("Expecting a digit");
            }
            while(isDigit(ch))
            {
               _loc1_ += ch;
               nextChar();
            }
         }
         if(ch == "e" || ch == "E")
         {
            _loc1_ += "e";
            nextChar();
            if(ch == "+" || ch == "-")
            {
               _loc1_ += ch;
               nextChar();
            }
            if(!isDigit(ch))
            {
               parseError("Scientific notation number needs exponent value");
            }
            while(isDigit(ch))
            {
               _loc1_ += ch;
               nextChar();
            }
         }
         var _loc2_= ASCompat.toNumber(_loc1_);
         if(Math.isFinite(_loc2_) && !Math.isNaN(_loc2_))
         {
            _loc3_ = new JSONToken();
            _loc3_.type = JSONTokenType.NUMBER;
            _loc3_.value = _loc2_;
            return _loc3_;
         }
         parseError("Number " + _loc2_ + " is not valid!");
         return null;
      }
   }


