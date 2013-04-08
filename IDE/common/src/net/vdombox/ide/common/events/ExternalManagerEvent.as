package net.vdombox.ide.common.events
{

	import flash.events.Event;

	public class ExternalManagerEvent extends Event
	{
		public static const CALL_COMPLETE : String = 'callComplete';

		public static const CALL_ERROR : String = 'callError';

		public function ExternalManagerEvent( type : String, result : Object = null, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );

			this.result = result;
		}

		public var result : Object;

		override public function clone() : Event
		{
			return new ExternalManagerEvent( type, result, bubbles, cancelable );
		}
	}
}
