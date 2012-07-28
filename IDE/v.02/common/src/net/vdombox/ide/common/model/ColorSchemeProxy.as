package net.vdombox.ide.common.model
{
	import flash.net.SharedObject;
	
	import net.vdombox.ide.common.model._vo.ColorSchemeVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ColorSchemeProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ColorSchemeProxy";
		
		public function ColorSchemeProxy()
		{
			super( NAME, {} );
		}
		
		private var shObjData : Object;
		
		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "colorSheme" );
		}
		
		public function get colorSchemes() : Array
		{
			var nameSchemes : Array = shObjData.data["names"] ? shObjData.data["names"].toString().split(" ") : new Array;
			
			var colorSchemes : Array = new Array();
			
			colorSchemes.push( defaultColorSheme );
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
		
		public function setColorScheme( colorSchemeVO : ColorSchemeVO ) : void
		{
			var name : String = colorSchemeVO.name;
			
			shObjData.data["default" + name] 		= colorSchemeVO.defaul_t;
			shObjData.data["keyword" + name] 		= colorSchemeVO.keyword;
			shObjData.data["keyword2" + name] 		= colorSchemeVO.keyword2;
			shObjData.data["e4x" + name] 			= colorSchemeVO.e4x;
			shObjData.data["comment" + name] 			= colorSchemeVO.comment;
			shObjData.data["nameClass" + name] 		= colorSchemeVO.nameClass;
			shObjData.data["nameFunction" + name] 	= colorSchemeVO.nameFunction;
			shObjData.data["number" + name] 		= colorSchemeVO.number;
			shObjData.data["regExp" + name] 		= colorSchemeVO.regExp;
			shObjData.data["string" + name] 		= colorSchemeVO.string;
			shObjData.data["symbol" + name] 		= colorSchemeVO.symbol;
			shObjData.data["topType" + name] 		= colorSchemeVO.topType;
			
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
					
					break;
				}
					
				default:
				{
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
			
			return colorSchemeVO;
		}
		
		private function get defaultColorSheme() : ColorSchemeVO
		{
			var colorSchemeVO : ColorSchemeVO = new ColorSchemeVO( "default" );
			
			colorSchemeVO.defaul_t 		= 0x111111;
			colorSchemeVO.keyword 		= 0x1039FF;
			colorSchemeVO.keyword2 		= 0x247ECE;
			colorSchemeVO.e4x 			= 0x613BB9;
			colorSchemeVO.comment 		= 0x008000;
			colorSchemeVO.nameClass 	= 0xFF7200;
			colorSchemeVO.nameFunction 	= 0xFF00FF;
			colorSchemeVO.number 		= 0x990099;
			colorSchemeVO.regExp 		= 0xa3a020;
			colorSchemeVO.string 		= 0x990000;
			colorSchemeVO.symbol 		= 0x006060;
			colorSchemeVO.topType 		= 0x981056;
			
			return colorSchemeVO;
		}
	}
}