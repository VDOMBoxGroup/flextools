package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;

	public class ContainersPanelEvent extends Event
	{
		public static var CONTAINER_CHANGED : String = "containerChanged";

		public function ContainersPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new ContainersPanelEvent( type, bubbles, cancelable );
		}
	}
}
