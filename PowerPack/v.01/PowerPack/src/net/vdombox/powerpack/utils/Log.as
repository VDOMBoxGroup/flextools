package net.vdombox.powerpack.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.getTimer;
	

	public class Log
	{
		private static var instance : Log;
		
		public static const millisecondsPerSec		: int = 1000;
		public static const millisecondsPerMinute	: int = 1000 * 60;
		
		private var logFile : File = File.applicationStorageDirectory.resolvePath("log.txt");
		private var fileStream : FileStream = new FileStream();
		
		private var startTime : Number = 0;
		private var prevTime : Number = 0;
		
		public function Log()
		{
			if ( instance )
				throw new Error( "Singleton and can only be accessed through Log.getInstance()" );
		}
		
		public static function getInstance() : Log
		{
			return instance || ( instance = new Log());
		}
		
		public function clear() : void
		{
			fileStream.open(logFile, FileMode.WRITE)
			fileStream.writeUTFBytes("Time     \tCommand    \tDelta (sec)");
			fileStream.close();
		}
		
		public function addNote(value : String) : void
		{
			if (!value)
				return;
			
			value = value.replace(/\r/g, " ");
			value = value.replace(/\n/g, " ");
			
			startTime = TimeUtils.currentTime;
			var deltaTime : String = prevTime == 0 ? "" : TimeUtils.formatToSecondsString(startTime - prevTime); 
			prevTime = startTime;
			
			var logMsg : String = deltaTime + "\n" + TimeUtils.formatToTimeString(startTime) + "\t"+ value + "\t";
			
			fileStream.open(logFile, FileMode.APPEND)
			fileStream.writeUTFBytes(logMsg);
			fileStream.close();
		}
		
	}
}