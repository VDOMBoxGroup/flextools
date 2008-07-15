package vdom.connection.utils
{
	import flash.events.Event;
	
	public class UtilsEvent extends Event
	{
		public static var FILE_UPLOAD_COMPLETE :String = "fileUploadCompleteOK";
		public static var FILE_UPLOAD_ERROR :String = "fileUploadErorr";
		public static var UNZIP_COMPLETE :String = "fileUploadErorr";
		public static var UNZIP_ERROR :String = "fileUploadErorr";
		
		public var source:Object = new Object();
		public var base64data:String = new String();
		
		public function UtilsEvent(type:String, source		:Object = null, 
												base64data  :String = '',
												bubbles		:Boolean = false,
								  				cancelable	:Boolean = true )
		{
			super(type, bubbles, cancelable);

			this.source = source;
			this.base64data = base64data;
		}
		
		
	}
}