package net.vdombox.ide.events
{
	import flash.events.Event;

	public class ApplicationItemRendererEvent extends Event
	{
		public static var INIT_COMPLETE : String = "Init Complete";
		public static var LOGIN_OK : String = "Login OK";
		public static var RESULT : String = "Result";

		public var iconID : String;

		public function ApplicationItemRendererEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true,
								   iconID : String = null )
		{
			super( type, bubbles, cancelable );

			this.iconID = iconID;
		}

		override public function clone() : Event
		{
			return new ApplicationItemRendererEvent( type, bubbles, cancelable, iconID );
		}
	}
}