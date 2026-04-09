package town
;
    class MessageOfTheDay
   {
      
      public static inline final IMAGE_PORTRAIT= (0 : UInt);
      
      public static inline final IMAGE_LANDSCAPE= (1 : UInt);
      
      public static inline final MOVIE= (2 : UInt);
      
      public var type:UInt = 0;
      
      public var title:String;
      
      public var message:String;
      
      public var imageURL:String;
      
      public var mainText:String;
      
      public var mainCallback:ASFunction;
      
      public var webText:String;
      
      public var webURL:String;
      
      public function new(param1:String, param2:String, param3:String, param4:String, param5:String, param6:ASFunction, param7:String, param8:String)
      {
         
         if(param1 == "IMAGE_PORTRAIT")
         {
            type = (0 : UInt);
         }
         else if(param1 == "IMAGE_LANDSCAPE")
         {
            type = (1 : UInt);
         }
         else if(param1 == "MOVIE")
         {
            type = (2 : UInt);
         }
         title = param2;
         message = param3;
         imageURL = param4;
         mainText = param5;
         mainCallback = param6;
         webText = param7;
         webURL = param8;
      }
   }


