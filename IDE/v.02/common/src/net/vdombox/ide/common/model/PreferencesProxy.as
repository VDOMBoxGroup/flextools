package net.vdombox.ide.common.model
{
	import flash.net.SharedObject;
	
	import net.vdombox.ide.common.model._vo.ColorSchemeVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class PreferencesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ColorSchemeProxy";
		
		public static const SELECTED_COLOR_SCHEME_CHANGE : String = "selectedColorSchemeChange";
		public static const SELECTED_FONT_SIZE_CHANGE : String = "selectedFontSizeChange";
		
		public function PreferencesProxy()
		{
			super( NAME, {} );
		}
		
		private var shObjData : Object;
		
		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "colorSheme" );
		}
		
		public function set selectedFontSize( value : int ) : void
		{
			shObjData.data["selectedFontSize"] = value;
			sendNotification( SELECTED_FONT_SIZE_CHANGE );
		}
		
		public function get selectedFontSize() : int
		{
			return shObjData.data["selectedFontSize"] ? shObjData.data["selectedFontSize"] : 14;
		}
		
		public function get fontSizes() : Array
		{
			return new Array(14, 17, 24);
		}
		
		public function get colorSchemes() : Array
		{
			var nameSchemes : Array = shObjData.data["names"] ? shObjData.data["names"].toString().split(" ") : new Array;
			
			var colorSchemes : Array = new Array();
			
			colorSchemes.push( defaultColorSheme );
			colorSchemes.push( obsidianColorSheme );
			colorSchemes.push( hromeColorSheme );
			colorSchemes.push( pastelColorSheme );
			
			for each ( var name : String in nameSchemes )
			{
				colorSchemes.push( getColorScheme( name ) );
			}
			
			return colorSchemes;
		}
		
		public function get selectedColorScheme() : ColorSchemeVO
		{
			var name : String = shObjData.data["nameSelectColorScheme"] ? shObjData.data["nameSelectColorScheme"] : "default";
			return getColorScheme( name );
		}
		
		public function set selectedColorScheme( colorSchemeVO : ColorSchemeVO ) : void
		{
			shObjData.data["nameSelectColorScheme"]  = colorSchemeVO ? colorSchemeVO.name : "default";
			
			sendNotification( SELECTED_COLOR_SCHEME_CHANGE );
		}
		
		public function setColorScheme( colorSchemeVO : ColorSchemeVO ) : void
		{
			var name : String = colorSchemeVO.name;
			
			shObjData.data["default" + name] 		= colorSchemeVO.defaul_t;
			shObjData.data["keyword" + name] 		= colorSchemeVO.keyword;
			shObjData.data["keyword2" + name] 		= colorSchemeVO.keyword2;
			shObjData.data["e4x" + name] 			= colorSchemeVO.e4x;
			shObjData.data["comment" + name] 		= colorSchemeVO.comment;
			shObjData.data["nameClass" + name] 		= colorSchemeVO.nameClass;
			shObjData.data["nameFunction" + name] 	= colorSchemeVO.nameFunction;
			shObjData.data["number" + name] 		= colorSchemeVO.number;
			shObjData.data["regExp" + name] 		= colorSchemeVO.regExp;
			shObjData.data["string" + name] 		= colorSchemeVO.string;
			shObjData.data["symbol" + name] 		= colorSchemeVO.symbol;
			shObjData.data["topType" + name] 		= colorSchemeVO.topType;
			shObjData.data["backGroundColor" + name] = colorSchemeVO.backGroundColor;
			
			shObjData.data["names"] = shObjData.data["names"] ? shObjData.data["names"] + " " + name : name;
			shObjData.data["nameSelectColorScheme"] = name;
		}
		
		public function getColorScheme( name : String ) : ColorSchemeVO
		{
			switch(name)
			{
				case "default":
				{
					return defaultColorSheme;
				}
					
				case "obsidian":
				{
					return obsidianColorSheme;
				}
					
				case "chrome":
				{
					return hromeColorSheme;
				}
					
				case "pastel":
				{
					return pastelColorSheme;
				}
					
				default:
				{
					return defaultColorSheme;
					
					break;
				}
			}
			
			var colorSchemeVO : ColorSchemeVO = new ColorSchemeVO( name );
			
			colorSchemeVO.defaul_t 		= shObjData.data["default" + name];
			colorSchemeVO.keyword 		= shObjData.data["keyword" + name];
			colorSchemeVO.keyword2 		= shObjData.data["keyword2" + name];
			colorSchemeVO.e4x 			= shObjData.data["e4x" + name];
			colorSchemeVO.comment 		= shObjData.data["comment" + name];
			colorSchemeVO.nameClass 	= shObjData.data["nameClass" + name];
			colorSchemeVO.nameFunction 	= shObjData.data["nameFunction" + name];
			colorSchemeVO.number 		= shObjData.data["number" + name];
			colorSchemeVO.regExp 		= shObjData.data["regExp" + name];
			colorSchemeVO.string 		= shObjData.data["string" + name];
			colorSchemeVO.symbol 		= shObjData.data["symbol" + name];
			colorSchemeVO.topType 		= shObjData.data["topType" + name];
			colorSchemeVO.backGroundColor = shObjData.data["backGroundColor" + name];
			
			return colorSchemeVO;
		}
		
		private function get defaultColorSheme() : ColorSchemeVO
		{
			var colorSchemeVO : ColorSchemeVO = new ColorSchemeVO( "default" );
			
			colorSchemeVO.defaul_t 				= 0x111111;
			colorSchemeVO.keyword 				= 0x1039FF;
			colorSchemeVO.keyword2 				= 0x247ECE;
			colorSchemeVO.keyword3 				= 0x1039FF;
			colorSchemeVO.e4x 					= 0x613BB9;
			colorSchemeVO.comment 				= 0x008000;
			colorSchemeVO.nameClass 			= 0xFF7200;
			colorSchemeVO.nameFunction 			= 0xFF00FF;
			colorSchemeVO.number 				= 0x990099;
			colorSchemeVO.regExp 				= 0xa3a020;
			colorSchemeVO.string 				= 0x990000;
			colorSchemeVO.stringLiteral			= 0x111111;
			colorSchemeVO.symbol 				= 0x006060;
			colorSchemeVO.topType 				= 0x981056;
			colorSchemeVO.backGroundColor 		= 0xFFFFFF;
			colorSchemeVO.selectionColor 		= 0x3399FF;
			colorSchemeVO.selectionRectsColor	= 0xD4D4D4;
			colorSchemeVO.cursorColor			= 0;
			
			colorSchemeVO.needChangeColorSelected = true;
			
			return colorSchemeVO;
		}
		
		private function get obsidianColorSheme() : ColorSchemeVO
		{
			var colorSchemeVO : ColorSchemeVO = new ColorSchemeVO( "obsidian" );
			
			colorSchemeVO.defaul_t 				= 0xd0d2b5;
			colorSchemeVO.keyword 				= 0x93c754;
			colorSchemeVO.keyword2 				= 0xd0d2b5;
			colorSchemeVO.keyword3 				= 0x93c754;
			colorSchemeVO.e4x 					= 0x613BB9;
			colorSchemeVO.comment 				= 0x66747b;
			colorSchemeVO.nameClass 			= 0xd39745;
			colorSchemeVO.nameFunction 			= 0xb3b689;
			colorSchemeVO.number 				= 0x990099;
			colorSchemeVO.regExp 				= 0xa3a020;
			colorSchemeVO.string 				= 0xec7600;
			colorSchemeVO.stringLiteral			= 0xd0d2b5;
			colorSchemeVO.symbol 				= 0xd0d2b5;
			colorSchemeVO.topType 				= 0x981056;
			colorSchemeVO.backGroundColor 		= 0x293134;
			colorSchemeVO.selectionColor 		= 0x506064;
			colorSchemeVO.selectionRectsColor	= 0x404E51;
			colorSchemeVO.cursorColor			= 0xFFFFFF;
			
			colorSchemeVO.needChangeColorSelected = false;
			
			return colorSchemeVO;
		}
		
		private function get hromeColorSheme() : ColorSchemeVO
		{
			var colorSchemeVO : ColorSchemeVO = new ColorSchemeVO( "chrome" );
			
			colorSchemeVO.defaul_t 				= 0xd0d2b5;
			colorSchemeVO.keyword 				= 0xc12672;
			colorSchemeVO.keyword2 				= 0xf8f8f2;
			colorSchemeVO.keyword3 				= 0x64d9ce;
			colorSchemeVO.e4x 					= 0x613BB9;
			colorSchemeVO.comment 				= 0x75715e;
			colorSchemeVO.nameClass 			= 0xbfbdac;
			colorSchemeVO.nameFunction 			= 0xbfbdac;
			colorSchemeVO.number 				= 0xae81ff;
			colorSchemeVO.regExp 				= 0xa3a020;
			colorSchemeVO.string 				= 0xe6db74;
			colorSchemeVO.stringLiteral			= 0xf8f8f2;
			colorSchemeVO.symbol 				= 0xf8f8f2;
			colorSchemeVO.topType 				= 0x981056;
			colorSchemeVO.backGroundColor 		= 0x272822;
			colorSchemeVO.selectionColor 		= 0x9d550f;
			colorSchemeVO.selectionRectsColor	= 0x404E51;
			colorSchemeVO.cursorColor			= 0xFFFFFF;
			
			colorSchemeVO.needChangeColorSelected = false;
			
			return colorSchemeVO;
		}
		
		private function get pastelColorSheme() : ColorSchemeVO
		{
			var colorSchemeVO : ColorSchemeVO = new ColorSchemeVO( "pastel" );
			
			colorSchemeVO.defaul_t 				= 0xd0d2b5;
			colorSchemeVO.keyword 				= 0x728059;
			colorSchemeVO.keyword2 				= 0xc1c144;
			colorSchemeVO.keyword3 				= 0xdadada;
			colorSchemeVO.e4x 					= 0x613BB9;
			colorSchemeVO.comment 				= 0x555555;
			colorSchemeVO.nameClass 			= 0xdadada;
			colorSchemeVO.nameFunction 			= 0xdadada;
			colorSchemeVO.number 				= 0xdcd504;
			colorSchemeVO.regExp 				= 0xa3a020;
			colorSchemeVO.string 				= 0xad9361;
			colorSchemeVO.stringLiteral			= 0xdadada;
			colorSchemeVO.symbol 				= 0xdadada;
			colorSchemeVO.topType 				= 0x981056;
			colorSchemeVO.backGroundColor 		= 0x211e1e;
			colorSchemeVO.selectionColor 		= 0x4a3b4e;
			colorSchemeVO.selectionRectsColor	= 0x404E51;
			colorSchemeVO.cursorColor			= 0xDDDDDD;
			
			colorSchemeVO.needChangeColorSelected = false;
			
			return colorSchemeVO;
		}
	}
}