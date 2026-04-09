package brain.sound
;
   import brain.event.EventComponent;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.Set;
   
    class SoundManager
   {
      
      static inline final GLOBAL_VOLUME_DAMPENER:Float = 0.2040816;
      
      static inline final DEFAULT_VOLUME:Float = 0.7;
      
      var mCategoryVolumeScale:Map;
      
      var mEventComponent:EventComponent;
      
      var mMaxConcurrentSounds:UInt = (20 : UInt);
      
      var mSoundsDictionary:Map;
      
      public function new(param1:Facade)
      {
         
         mCategoryVolumeScale = new Map();
         mSoundsDictionary = new Map();
         mEventComponent = new EventComponent(param1);
      }
      
      public function destroy() 
      {
         mEventComponent.destroy();
         mEventComponent = null;
         mSoundsDictionary = null;
         mCategoryVolumeScale = null;
      }
      
      public function registerSoundPlaying(param1:SoundHandle) 
      {
         var _loc2_:Set = null;
         if(mSoundsDictionary.hasKey(param1.category))
         {
            _loc2_ = ASCompat.dynamicAs(mSoundsDictionary.itemFor(param1.category) , Set);
            if(_loc2_.has(param1))
            {
               Logger.warn("Trying to register a sound handle that already exists in the set.");
               return;
            }
            _loc2_.add(param1);
         }
         else
         {
            _loc2_ = new Set();
            _loc2_.add(param1);
            mSoundsDictionary.add(param1.category,_loc2_);
         }
      }
      
      public function unregisterSoundPlaying(param1:SoundHandle) 
      {
         if(!mSoundsDictionary.hasKey(param1.category))
         {
            Logger.error("Tryign to remove soundHandle from a category that does not exist in the dictionary. Category: " + param1.category);
         }
         var _loc2_= ASCompat.dynamicAs(mSoundsDictionary.itemFor(param1.category) , Set);
         if(_loc2_.has(param1))
         {
            _loc2_.remove(param1);
         }
         else
         {
            Logger.warn("Trying to remove a soundHandle from a soundCategory that does not have it in the set.");
         }
      }
      
      public function setVolumeScaleForCategory(param1:String, param2:Float) 
      {
         if(mCategoryVolumeScale.hasKey(param1))
         {
            mCategoryVolumeScale.replaceFor(param1,param2);
         }
         else
         {
            mCategoryVolumeScale.add(param1,param2);
         }
         mEventComponent.dispatchEvent(new SoundCategoryVoumeChangedEvent());
      }
      
      public function getDampenedVolumeScaleForCategory(param1:String) : Float
      {
         return getVolumeScaleForCategory(param1) * getVolumeScaleForCategory(param1) * 0.2040816;
      }
      
      public function getVolumeScaleForCategory(param1:String) : Float
      {
         if(mCategoryVolumeScale.hasKey(param1))
         {
            return ASCompat.toNumber(mCategoryVolumeScale.itemFor(param1));
         }
         Logger.warn("No volume category found for category: " + param1 + "  Returning " + 0.7);
         return 0.7;
      }
   }


