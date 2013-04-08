package net.vdombox.ide.core.model
{
	import flash.net.SharedObject;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class LogProxy
	{
		private static var index : int = 0;

		public static function get shObjData() : Object
		{
			return SharedObject.getLocal( "LogData" );;
		}

		public static function clear() : void
		{
			shObjData.clear();
		}

		public static function addLog( string : String ) : void
		{
			shObjData.data[ index++ ] = string;
			shObjData.flush();
		}
	}
}
