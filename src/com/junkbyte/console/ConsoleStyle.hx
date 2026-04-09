package com.junkbyte.console
;
   import flash.text.StyleSheet;
   
    class ConsoleStyle
   {
      
      public var menuFont:String = "Arial";
      
      public var menuFontSize:Int = 12;
      
      public var traceFont:String = "Verdana";
      
      public var traceFontSize:Int = 11;
      
      public var backgroundColor:UInt = 0;
      
      public var backgroundAlpha:Float = 0.9;
      
      public var controlColor:UInt = (10027008 : UInt);
      
      public var controlSize:UInt = (5 : UInt);
      
      public var commandLineColor:UInt = (1092096 : UInt);
      
      public var highColor:UInt = (16777215 : UInt);
      
      public var lowColor:UInt = (12632256 : UInt);
      
      public var logHeaderColor:UInt = (12632256 : UInt);
      
      public var menuColor:UInt = (16746496 : UInt);
      
      public var menuHighlightColor:UInt = (14505216 : UInt);
      
      public var channelsColor:UInt = (16777215 : UInt);
      
      public var channelColor:UInt = (39372 : UInt);
      
      public var priority0:UInt = (3831610 : UInt);
      
      public var priority1:UInt = (4495684 : UInt);
      
      public var priority2:UInt = (7846775 : UInt);
      
      public var priority3:UInt = (10539168 : UInt);
      
      public var priority4:UInt = (14085846 : UInt);
      
      public var priority5:UInt = (15329769 : UInt);
      
      public var priority6:UInt = (16768477 : UInt);
      
      public var priority7:UInt = (16755370 : UInt);
      
      public var priority8:UInt = (16742263 : UInt);
      
      public var priority9:UInt = (16720418 : UInt);
      
      public var priority10:UInt = (16720418 : UInt);
      
      public var priorityC1:UInt = (39372 : UInt);
      
      public var priorityC2:UInt = (16746496 : UInt);
      
      public var topMenu:Bool = true;
      
      public var showCommandLineScope:Bool = true;
      
      public var maxChannelsInMenu:Int = 7;
      
      public var panelSnapping:Int = 3;
      
      public var roundBorder:Int = 10;
      
      var _css:StyleSheet;
      
      public function new()
      {
         
         this._css = new StyleSheet();
      }
      
      public function whiteBase() 
      {
         this.backgroundColor = (16777215 : UInt);
         this.controlColor = (16724787 : UInt);
         this.commandLineColor = (6736896 : UInt);
         this.highColor = (0 : UInt);
         this.lowColor = (3355443 : UInt);
         this.logHeaderColor = (4473924 : UInt);
         this.menuColor = (13373696 : UInt);
         this.menuHighlightColor = (8917248 : UInt);
         this.channelsColor = (0 : UInt);
         this.channelColor = (26282 : UInt);
         this.priority0 = (4497476 : UInt);
         this.priority1 = (3379251 : UInt);
         this.priority2 = (2258722 : UInt);
         this.priority3 = (1135889 : UInt);
         this.priority4 = (13056 : UInt);
         this.priority5 = (0 : UInt);
         this.priority6 = (6684672 : UInt);
         this.priority7 = (10027008 : UInt);
         this.priority8 = (12255232 : UInt);
         this.priority9 = (14483456 : UInt);
         this.priority10 = (14483456 : UInt);
         this.priorityC1 = (39372 : UInt);
         this.priorityC2 = (16737792 : UInt);
      }
      
      public function big() 
      {
         this.traceFontSize = 13;
         this.menuFontSize = 14;
      }
      
      public function updateStyleSheet() 
      {
         this._css.setStyle("high",{
            "color":this.hesh(this.highColor),
            "fontFamily":this.menuFont,
            "fontSize":this.menuFontSize,
            "display":"inline"
         });
         this._css.setStyle("low",{
            "color":this.hesh(this.lowColor),
            "fontFamily":this.menuFont,
            "fontSize":this.menuFontSize - 2,
            "display":"inline"
         });
         this._css.setStyle("menu",{
            "color":this.hesh(this.menuColor),
            "display":"inline"
         });
         this._css.setStyle("menuHi",{
            "color":this.hesh(this.menuHighlightColor),
            "display":"inline"
         });
         this._css.setStyle("chs",{
            "color":this.hesh(this.channelsColor),
            "fontSize":this.menuFontSize,
            "leading":"2",
            "display":"inline"
         });
         this._css.setStyle("ch",{
            "color":this.hesh(this.channelColor),
            "display":"inline"
         });
         this._css.setStyle("tt",{
            "color":this.hesh(this.menuColor),
            "fontFamily":this.menuFont,
            "fontSize":this.menuFontSize,
            "textAlign":"center"
         });
         this._css.setStyle("r",{
            "textAlign":"right",
            "display":"inline"
         });
         this._css.setStyle("p",{
            "fontFamily":this.traceFont,
            "fontSize":this.traceFontSize
         });
         this._css.setStyle("p0",{
            "color":this.hesh(this.priority0),
            "display":"inline"
         });
         this._css.setStyle("p1",{
            "color":this.hesh(this.priority1),
            "display":"inline"
         });
         this._css.setStyle("p2",{
            "color":this.hesh(this.priority2),
            "display":"inline"
         });
         this._css.setStyle("p3",{
            "color":this.hesh(this.priority3),
            "display":"inline"
         });
         this._css.setStyle("p4",{
            "color":this.hesh(this.priority4),
            "display":"inline"
         });
         this._css.setStyle("p5",{
            "color":this.hesh(this.priority5),
            "display":"inline"
         });
         this._css.setStyle("p6",{
            "color":this.hesh(this.priority6),
            "display":"inline"
         });
         this._css.setStyle("p7",{
            "color":this.hesh(this.priority7),
            "display":"inline"
         });
         this._css.setStyle("p8",{
            "color":this.hesh(this.priority8),
            "display":"inline"
         });
         this._css.setStyle("p9",{
            "color":this.hesh(this.priority9),
            "display":"inline"
         });
         this._css.setStyle("p10",{
            "color":this.hesh(this.priority10),
            "fontWeight":"bold",
            "display":"inline"
         });
         this._css.setStyle("p-1",{
            "color":this.hesh(this.priorityC1),
            "display":"inline"
         });
         this._css.setStyle("p-2",{
            "color":this.hesh(this.priorityC2),
            "display":"inline"
         });
         this._css.setStyle("logs",{
            "color":this.hesh(this.logHeaderColor),
            "display":"inline"
         });
      }
      
      @:isVar public var styleSheet(get,never):StyleSheet;
public function  get_styleSheet() : StyleSheet
      {
         return this._css;
      }
      
      function hesh(param1:Float) : String
      {
         return "#" + ASCompat.toRadix(param1, (16 : UInt));
      }
   }


