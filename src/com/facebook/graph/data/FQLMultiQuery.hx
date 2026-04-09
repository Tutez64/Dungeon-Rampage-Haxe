package com.facebook.graph.data
;
   import com.adobe.serialization.json.JSON;
   
    class FQLMultiQuery
   {
      
      public var queries:ASObject;
      
      public function new()
      {
         
         this.queries = {};
      }
      
      public function add(param1:String, param2:String, param3:ASObject = null) 
      {
         var _loc4_:String = null;
         if(this.queries.hasOwnProperty(param2))
         {
            throw new Error("Query name already exists, there cannot be duplicate names");
         }
         if (checkNullIteratee(param3)) for(_tmp_ in param3.___keys())
         {
            _loc4_  = _tmp_;
            param1 = new compat.RegExp("\\{" + _loc4_ + "\\}","g").replace(param1,param3[_loc4_]);
         }
         this.queries[param2] = param1;
      }
      
      public function toString() : String
      {
         return com.adobe.serialization.json.JSON.encode(this.queries);
      }
   }


