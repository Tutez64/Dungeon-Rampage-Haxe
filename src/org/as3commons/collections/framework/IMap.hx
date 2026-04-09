package org.as3commons.collections.framework
;
    interface IMap extends IDuplicates
   {
      
      function add(param1:ASAny, param2:ASAny) : Bool;
      
      function hasKey(param1:ASAny) : Bool;
      
      function itemFor(param1:ASAny) : ASAny;
      
      function keysToArray() : Array<ASAny>;
      
      function removeKey(param1:ASAny) : ASAny;
      
      function replaceFor(param1:ASAny, param2:ASAny) : Bool;
      
      function keyIterator() : IIterator;
   }


