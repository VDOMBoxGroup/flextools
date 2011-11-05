package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class MultilineWindowEvent extends Event
	{
		public var value : String;
		public static var CLOSE 			: String = "closeWindow1";
		public static var APPLY 			: String = "apply";

		public function MultilineWindowEvent( type : String, value : String )
		{
			this.value = value;
			super( type, false, false );
		}
	}
}