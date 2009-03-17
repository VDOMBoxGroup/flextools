package vdom.events
{
	import flash.events.Event;

	public class ServerScriptsEvent extends Event
	{
		public static const SCRIPT_CHANGED : String = 'scriptChanged';

		public var name : String;
		public var data : String;

		public function ServerScriptsEvent( type : String, bubbles : Boolean = false,
											cancelable : Boolean = false, name : String = null,
											data : * = null )
		{
			super( type, bubbles, cancelable );

			this.name = name;
			this.data = data;
		}

	}
}