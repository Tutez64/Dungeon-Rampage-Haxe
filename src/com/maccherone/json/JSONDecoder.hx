package com.maccherone.json
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
         tokenizer = new JSONTokenizer(param1,param2);
         nextToken();
         value = parseValue();
         if(param2 && nextToken() != null)
         {
            tokenizer.parseError("Unexpected characters left in input stream");
         }
      }
      
      function nextToken() : JSONToken
      {
         return token = tokenizer.getNextToken();
      }
      
      function parseObject() : ASObject
      {
         var _loc2_:String = null;
         var _loc1_:ASObject = new ASObject();
         nextToken();
         if(token.type == JSONTokenType.RIGHT_BRACE)
         {
            return _loc1_;
         }
         if(!strict && token.type == JSONTokenType.COMMA)
         {
            nextToken();
            if(token.type == JSONTokenType.RIGHT_BRACE)
            {
               return _loc1_;
            }
            tokenizer.parseError("Leading commas are not supported.  Expecting \'}\' but found " + Std.string(token.value));
         }
         while(true)
         {
            if(token.type == JSONTokenType.STRING)
            {
               _loc2_ = ASCompat.toString(token.value);
               nextToken();
               if(token.type == JSONTokenType.COLON)
               {
                  nextToken();
                  _loc1_[_loc2_] = parseValue();
                  nextToken();
                  if(token.type == JSONTokenType.RIGHT_BRACE)
                  {
                     break;
                  }
                  if(token.type == JSONTokenType.COMMA)
                  {
                     nextToken();
                     if(!strict)
                     {
                        if(token.type == JSONTokenType.RIGHT_BRACE)
                        {
                           return _loc1_;
                        }
                     }
                  }
                  else
                  {
                     tokenizer.parseError("Expecting } or , but found " + Std.string(token.value));
                  }
               }
               else
               {
                  tokenizer.parseError("Expecting : but found " + Std.string(token.value));
               }
            }
            else
            {
               tokenizer.parseError("Expecting string but found " + Std.string(token.value));
            }
         }
         return _loc1_;
      }
      
      function parseArray() : Array<ASAny>
      {
         var _loc1_= new Array<ASAny>();
         nextToken();
         if(token.type == JSONTokenType.RIGHT_BRACKET)
         {
            return _loc1_;
         }
         if(!strict && token.type == JSONTokenType.COMMA)
         {
            nextToken();
            if(token.type == JSONTokenType.RIGHT_BRACKET)
            {
               return _loc1_;
            }
            tokenizer.parseError("Leading commas are not supported.  Expecting \']\' but found " + Std.string(token.value));
         }
         while(true)
         {
            _loc1_.push(parseValue());
            nextToken();
            if(token.type == JSONTokenType.RIGHT_BRACKET)
            {
               break;
            }
            if(token.type == JSONTokenType.COMMA)
            {
               nextToken();
               if(!strict)
               {
                  if(token.type == JSONTokenType.RIGHT_BRACKET)
                  {
                     return _loc1_;
                  }
               }
            }
            else
            {
               tokenizer.parseError("Expecting ] or , but found " + Std.string(token.value));
            }
         }
         return _loc1_;
      }
      
      public function getValue() : ASAny
      {
         return value;
      }
      
      function parseValue() : ASObject
      {
         if(token == null)
         {
            tokenizer.parseError("Unexpected end of input");
         }
         switch(token.type)
         {
            case JSONTokenType.LEFT_BRACE:
               return parseObject();
            case JSONTokenType.LEFT_BRACKET:
               return parseArray();
            case JSONTokenType.STRING
               | JSONTokenType.NUMBER
               | JSONTokenType.TRUE_cpp
               | JSONTokenType.FALSE_cpp
               | JSONTokenType.NULL_cpp:
               return token.value;
            case JSONTokenType.NAN_cpp:
               if(!strict)
               {
                  return token.value;
               }
               tokenizer.parseError("Unexpected " + Std.string(token.value));
         }
         tokenizer.parseError("Unexpected " + Std.string(token.value));
         return null;
      }
   }


