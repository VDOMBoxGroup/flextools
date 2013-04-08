package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class StringAttributeEditWindowEvent extends Event
	{
		public var value : String;

		public static var APPLY : String = "apply";

		public static var CANCEL : String = "cancelw";

		public function StringAttributeEditWindowEvent( type : String, value : String = "" )
		{
			this.value = value;
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new StringAttributeEditWindowEvent( type, value );
		}
	}
}
