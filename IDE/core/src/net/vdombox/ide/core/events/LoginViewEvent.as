package net.vdombox.ide.core.events
{
	import flash.events.Event;

	public class LoginViewEvent extends Event
	{
		public static var SUBMIT : String = "submit";

		public static var LANGUAGE_CHANGED : String = "languageChanged";

		public static var DELETE_CLICK : String = "deleteClick";

		public function LoginViewEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new LoginViewEvent( type, bubbles, cancelable );
		}
	}
}
