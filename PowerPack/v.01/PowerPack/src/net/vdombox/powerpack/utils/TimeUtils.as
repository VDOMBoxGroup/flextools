package net.vdombox.powerpack.utils
{
	public class TimeUtils
	{
		public function TimeUtils()
		{
		}
		
		public static function get currentTime () : Number 
		{
			return new Date().time;
		}
		
		public static function formatToTimeString (time:Number) : String
		{
			var date:Date = new Date();
			date.setTime(time);
			
			return date.getHours()+":"+date.getMinutes()+":"+date.getSeconds()+"."+date.getMilliseconds();
		}
		
		public static function formatToSecondsString (time:Number) : String
		{
			var sec : String = String(time*0.001);
			
			var dotIndex : int = sec.indexOf(".");
			
			return sec.substr(0, dotIndex+4)
		}
		
		
	}
}