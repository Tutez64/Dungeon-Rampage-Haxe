package org.as3commons.collections.framework
;
    interface ISortedMap extends IMap extends  ISortOrder
   {
      
      function higherKey(param1:ASAny) : ASAny;
      
      function lesserKey(param1:ASAny) : ASAny;
      
      function equalKeys(param1:ASAny) : Array<ASAny>;
   }


