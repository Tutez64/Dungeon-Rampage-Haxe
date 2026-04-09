package com.facebook.graph.utils
;
    class FQLMultiQueryParser implements IResultParser
   {
      
      public function new()
      {
         
      }
      
      public function parse(param1:ASObject) : ASObject
      {
         var _loc3_:String = null;
         var _loc2_:ASObject = {};
         if (checkNullIteratee(param1)) for(_tmp_ in param1.___keys())
         {
            _loc3_  = _tmp_;
            _loc2_[param1[_loc3_].name] = param1[_loc3_].fql_result_set;
         }
         return _loc2_;
      }
   }


