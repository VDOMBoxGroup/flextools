package net.vdombox.powerpack.lib.player.utils
{
	import flash.net.SharedObject;

	public class Log
	{
		
		private static var index : int = 0;
		
		public static function get shObjData():Object
		{
			return SharedObject.getLocal( "LogData" );;
		}
		
		public static function clear() : void
		{
			shObjData.clear();
		}
		
		public static function addLog( string : String ) : void
		{
			shObjData.data[index++] = string;
			shObjData.flush();
		}
		
		
		
	}
}