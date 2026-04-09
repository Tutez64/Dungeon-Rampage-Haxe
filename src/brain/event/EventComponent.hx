package brain.event
;
   import brain.component.Component;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import brain.utils.Receipt;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class EventComponent extends Component
   {
      
      var mRegisteredListeners:Map = new Map();
      
      public function new(param1:Facade)
      {
         super(param1);
         mFacade = param1;
      }
      
      public function addListener(param1:String, param2:ASFunction) : Receipt
      {
         var _loc4_:Receipt = null;
         var _loc3_= mRegisteredListeners.add(param1,param2);
         if(_loc3_)
         {
            mFacade.eventManager.addEventListener(param1,param2);
            _loc4_ = new Receipt(removeListener);
            MemoryTracker.track(_loc4_,"Receipt - EventComponent listener: " + param1,"brain");
            return _loc4_;
         }
         Logger.warn("Failed duplicate addListener for eventName: " + param1);
         return null;
      }
      
      public function removeListener(param1:String) 
      {
         var _loc2_= ASCompat.asFunction(mRegisteredListeners.removeKey(param1));
         if(_loc2_ == null)
         {
            return;
         }
         mFacade.eventManager.removeEventListener(param1,_loc2_);
      }
      
      public function dispatchEvent(param1:Event) 
      {
         mFacade.eventManager.dispatchEvent(param1);
      }
      
      override public function destroy() 
      {
         removeAllListeners();
         mRegisteredListeners = null;
         super.destroy();
      }
      
      public function removeAllListeners() 
      {
         var _loc2_:String = null;
         var _loc3_:ASFunction = null;
         var _loc1_= ASCompat.reinterpretAs(mRegisteredListeners.iterator() , IMapIterator);
         while(_loc1_.hasNext())
         {
            _loc3_ = ASCompat.asFunction(_loc1_.next());
            _loc2_ = _loc1_.key;
            mFacade.eventManager.removeEventListener(_loc2_,_loc3_);
         }
         mRegisteredListeners.clear();
      }
   }


