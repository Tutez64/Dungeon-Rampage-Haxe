package com.amanitadesign.steam
;
    class UserConstants
   {
      
      public static inline final BEGINAUTH_OK= 0;
      
      public static inline final BEGINAUTH_InvalidTicket= 1;
      
      public static inline final BEGINAUTH_DuplicateRequest= 2;
      
      public static inline final BEGINAUTH_InvalidVersion= 3;
      
      public static inline final BEGINAUTH_GameMismatch= 4;
      
      public static inline final BEGINAUTH_ExpiredTicket= 5;
      
      public static inline final LICENSE_HasLicense= 0;
      
      public static inline final LICENSE_DoesNotHaveLicense= 1;
      
      public static inline final LICENSE_NoAuth= 2;
      
      public static inline final SESSION_OK= 0;
      
      public static inline final SESSION_UserNotConnectedToSteam= 1;
      
      public static inline final SESSION_NoLicenseOrExpired= 2;
      
      public static inline final SESSION_VACBanned= 3;
      
      public static inline final SESSION_LoggedInElseWhere= 4;
      
      public static inline final SESSION_VACCheckTimedOut= 5;
      
      public static inline final SESSION_AuthTicketCanceled= 6;
      
      public static inline final SESSION_AuthTicketInvalidAlreadyUsed= 7;
      
      public static inline final SESSION_AuthTicketInvalid= 8;
      
      public static inline final AUTHTICKET_Invalid= (0 : UInt);
      
      public function new()
      {
         
      }
   }


