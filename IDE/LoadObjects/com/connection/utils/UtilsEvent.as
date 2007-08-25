package com.connection.utils
{
	import flash.events.Event;
	
	public class UtilsEvent extends Event
	{
		public static var FILE_UPLOAD_COMPLETE :String = "fileUploadCompleteOK";
		public static var FILE_UPLOAD_ERROR :String = "fileUploadErorr";
		public static var UNZIP_COMPLETE :String = "fileUploadErorr";
		public static var UNZIP_ERROR :String = "fileUploadErorr";
		
		public var result:Object = new Object();
		
		public function UtilsEvent(type:String, result		:Object = null, 
												bubbles		:Boolean = false,
								  				cancelable	:Boolean = true )
		{
			super(type, bubbles, cancelable);

			this.result = result;
		}
		
		
	}
}