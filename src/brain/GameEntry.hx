package brain
;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import org.as3commons.collections.Map;
   
    class GameEntry extends MovieClip
   {
      
      var mStageRef:Stage;
      
      public function new()
      {
         super();
         mStageRef = stage;
         stage.addEventListener("keyDown",this.debugTrace);
      }
      
      function debugTrace(param1:KeyboardEvent) 
      {
         var mc:MovieClip = null;
         var nodeTypes:Map;
         var recurse:ASFunction = null;
         var keys:Array<ASAny>;
         var key:String;
         var event= param1;
         if(event.ctrlKey)
         {
            switch(event.charCode)
            {
               case 61:
                  (mc : ASAny).foo;
                  
               case 32:
                  nodeTypes = new Map();
                  recurse = function(param1:flash.display.DisplayObject, param2:Int)
                  {
                     var _loc4_= 0;
                     var _loc5_= 0;
                     var _loc8_= 0;
                     var _loc7_= ASCompat.getQualifiedClassName(param1);
                     if(nodeTypes.hasKey(_loc7_))
                     {
                        _loc4_ = ASCompat.toInt(nodeTypes.itemFor(_loc7_));
                        nodeTypes.replaceFor(_loc7_,_loc4_ + 1);
                     }
                     else
                     {
                        nodeTypes.add(_loc7_,1);
                     }
                     var _loc3_= "";
                     _loc5_ = 0;
                     while(_loc5_ < param2)
                     {
                        _loc3_ += "  ";
                        _loc5_++;
                     }
                     _loc3_ += param1.toString() + " " + param1.name;
                     trace(_loc3_);
                     var _loc6_= ASCompat.reinterpretAs(param1 , DisplayObjectContainer);
                     if(_loc6_ != null)
                     {
                        _loc8_ = 0;
                        while(_loc8_ < _loc6_.numChildren)
                        {
                           recurse(_loc6_.getChildAt(_loc8_),param2 + 1);
                           _loc8_++;
                        }
                     }
                  };
                  trace("======================================================================");
                  trace(" Stage Scene Graph");
                  trace("======================================================================");
                  recurse(stage,0);
                  trace("======================================================================");
                  trace(" Class Counts");
                  trace("======================================================================");
                  keys = nodeTypes.keysToArray();
                  ASCompat.ASArray.sort(keys, function(param1:String, param2:String):Int
                  {
                     return ASCompat.toInt(ASCompat.toNumber(nodeTypes.itemFor(param2)) - ASCompat.toNumber(nodeTypes.itemFor(param1)));
                  });
                  if (checkNullIteratee(keys)) for (_tmp_ in keys)
                  {
                     key  = _tmp_;
                     trace(nodeTypes.itemFor(key), "\t", key);
                  }
                  
            }
         }
      }
   }


