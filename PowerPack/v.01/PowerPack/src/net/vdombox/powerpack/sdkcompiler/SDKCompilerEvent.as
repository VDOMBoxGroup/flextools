package net.vdombox.powerpack.sdkcompiler
{
	import flash.events.Event;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;

	public class SDKCompilerEvent extends Event
	{
		public static var BUILD_COMPETE			: String = "buildComplete";
		public static var BUILD_ERROR			: String = "buildError";

		private var _message : String;

		public function SDKCompilerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

		override public function clone():Event
		{
			return new SDKCompilerEvent(type, bubbles, cancelable);
		}

		public function get message () : String
		{
			return Utils.convertStringToUTF(_message);
		}
		
		public function set message (msg : String) : void
		{
			_message = msg;
		}
		
		
	}
}

