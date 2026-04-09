package brain.render
;
   import brain.utils.MemoryTracker;
   
    class SortedLayer extends Layer
   {
      
      public function new(param1:Int = 0)
      {
         super(param1);
         MemoryTracker.track(this,"SortedLayer sortIndex=" + param1 + " - created in SortedLayer()","brain");
      }
      
      override public function render() 
      {
         this.sortLayer();
      }
   }


