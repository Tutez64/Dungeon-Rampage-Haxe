package com.adobe.serialization.json
;
    class JSONDecoder
   {
      
      var strict:Bool = false;
      
      var value:ASAny;
      
      var tokenizer:JSONTokenizer;
      
      var token:JSONToken;
      
      public function new(param1:String, param2:Bool)
      {
         
         this.strict = param2;
         this.tokenizer = new JSONTokenizer(param1,param2);
         this.nextToken();
         this.value = this.parseValue();
         if(param2 && this.nextToken() != null)
         {
            this.tokenizer.parseError("Unexpected characters left in input stream");
         }
      }
      
      public function getValue() : ASAny
      {
         return this.value;
      }
      
      final function nextToken() : JSONToken
      {
         return this.token = this.tokenizer.getNextToken();
      }
      
      final function nextValidToken() : JSONToken
      {
         this.token = this.tokenizer.getNextToken();
         this.checkValidToken();
         return this.token;
      }
      
      final function checkValidToken() 
      {
         if(this.token == null)
         {
            this.tokenizer.parseError("Unexpected end of input");
         }
      }
      
      final function parseArray() : Array<ASAny>
      {
         var _loc1_= new Array<ASAny>();
         this.nextValidToken();
         if(this.token.type == JSONTokenType.RIGHT_BRACKET)
         {
            return _loc1_;
         }
         if(!this.strict && this.token.type == JSONTokenType.COMMA)
         {
            this.nextValidToken();
            if(this.token.type == JSONTokenType.RIGHT_BRACKET)
            {
               return _loc1_;
            }
            this.tokenizer.parseError("Leading commas are not supported.  Expecting \']\' but found " + Std.string(this.token.value));
         }
         while(true)
         {
            _loc1_.push(this.parseValue());
            this.nextValidToken();
            if(this.token.type == JSONTokenType.RIGHT_BRACKET)
            {
               break;
            }
            if(this.token.type == JSONTokenType.COMMA)
            {
               this.nextToken();
               if(!this.strict)
               {
                  this.checkValidToken();
                  if(this.token.type == JSONTokenType.RIGHT_BRACKET)
                  {
                     return _loc1_;
                  }
               }
            }
            else
            {
               this.tokenizer.parseError("Expecting ] or , but found " + Std.string(this.token.value));
            }
         }
         return _loc1_;
      }
      
      final function parseObject() : ASObject
      {
         var _loc2_:String = null;
         var _loc1_:ASObject = new ASObject();
         this.nextValidToken();
         if(this.token.type == JSONTokenType.RIGHT_BRACE)
         {
            return _loc1_;
         }
         if(!this.strict && this.token.type == JSONTokenType.COMMA)
         {
            this.nextValidToken();
            if(this.token.type == JSONTokenType.RIGHT_BRACE)
            {
               return _loc1_;
            }
            this.tokenizer.parseError("Leading commas are not supported.  Expecting \'}\' but found " + Std.string(this.token.value));
         }
         while(true)
         {
            if(this.token.type == JSONTokenType.STRING)
            {
               _loc2_ = ASCompat.toString(this.token.value);
               this.nextValidToken();
               if(this.token.type == JSONTokenType.COLON)
               {
                  this.nextToken();
                  _loc1_[_loc2_] = this.parseValue();
                  this.nextValidToken();
                  if(this.token.type == JSONTokenType.RIGHT_BRACE)
                  {
                     break;
                  }
                  if(this.token.type == JSONTokenType.COMMA)
                  {
                     this.nextToken();
                     if(!this.strict)
                     {
                        this.checkValidToken();
                        if(this.token.type == JSONTokenType.RIGHT_BRACE)
                        {
                           return _loc1_;
                        }
                     }
                  }
                  else
                  {
                     this.tokenizer.parseError("Expecting } or , but found " + Std.string(this.token.value));
                  }
               }
               else
               {
                  this.tokenizer.parseError("Expecting : but found " + Std.string(this.token.value));
               }
            }
            else
            {
               this.tokenizer.parseError("Expecting string but found " + Std.string(this.token.value));
            }
         }
         return _loc1_;
      }
      
      final function parseValue() : ASObject
      {
         this.checkValidToken();
         switch(this.token.type)
         {
            case JSONTokenType.LEFT_BRACE:
               return this.parseObject();
            case JSONTokenType.LEFT_BRACKET:
               return this.parseArray();
            case JSONTokenType.STRING
               | JSONTokenType.NUMBER
               | JSONTokenType.TRUE_cpp
               | JSONTokenType.FALSE_cpp
               | JSONTokenType.NULL_cpp:
               return this.token.value;
            case JSONTokenType.NAN_cpp:
               if(!this.strict)
               {
                  return this.token.value;
               }
               this.tokenizer.parseError("Unexpected " + Std.string(this.token.value));
         }
         this.tokenizer.parseError("Unexpected " + Std.string(this.token.value));
         return null;
      }
   }


