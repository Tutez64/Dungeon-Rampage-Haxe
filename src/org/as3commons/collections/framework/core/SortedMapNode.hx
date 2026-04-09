package org.as3commons.collections.framework.core
;
    class SortedMapNode extends SortedNode
   {
      
      public var key:ASAny;
      
      public function new(param1:ASAny, param2:ASAny)
      {
         super(param2);
         this.key = param1;
      }
   }


